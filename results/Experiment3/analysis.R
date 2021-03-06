# PREAMBLE

library(tidyverse)
library(ordinal)
library(bootstrap)
library(rwebppl)
library(jsonlite)
library(lme4)
library(lmerTest)
library(lsmeans)

setwd("~/Documents/GitHub/alts/results/Experiment3")

# HELPER SCRIPTS

theta <- function(x,xdata,na.rm=T) {mean(xdata[x],na.rm=na.rm)}

ci.low <- function(x,na.rm=T) {
  mean(x,na.rm=na.rm) - quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.025,na.rm=na.rm)}
ci.high <- function(x,na.rm=T) {
  quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.975,na.rm=na.rm) - mean(x,na.rm=na.rm)}

# LOAD DATA

d <- read.csv("results.csv")

# RUN EXCLUSIONS

# EXCLUDE NON-NATIVE ENGLISH SPEAKERS

levels(d$language) # KEEP DATA IF LANGUAGE = SOME SPELLING VARIATION OF 'ENGLISH' (OR NA)

d <- d %>%
  filter(!(language == "Russian"))

# EXCLUDE PEOPLE WHO FAIL MORE THAN ONE EXCLUSION TRIAL

to_exclude <- d %>%
  group_by(workerid, type, selection) %>%
  filter((type == "left" && selection == "right") || (type == "right" && selection  == "left")) %>%
  group_by(workerid) %>%
  summarize(n_mistakes = n()) %>%
  filter(n_mistakes > 0)

d <- d %>%
  filter(!(workerid %in% to_exclude$workerid))

# PROPORTION OF COMPETITOR PICTURES CHOSEN

sel_counts <- d %>%
  # ONLY INTERESTED IN "LOOKS LIKE" TRIALS...
  filter(type == "looks like") %>%
  # ... THAT THE CONDITIONS SHARE IN COMMON
  filter(id %in% (d %>% filter(type == "looks like" & condition == "symmetric"))$id) %>%
  group_by(workerid,condition) %>%
  summarize(n = n(), ntarget = sum(selection == "target"), 
            ncompetitor = sum(selection == "competitor"), 
            pcompetitor = ncompetitor / (ncompetitor + ntarget)) 

sel_counts_learning <- d %>%
  # ONLY INTERESTED IN "LOOKS LIKE" TRIALS...
  filter(type == "looks like") %>%
  # ... THAT THE CONDITIONS SHARE IN COMMON
  filter(id %in% (d %>% filter(type == "looks like" & condition == "symmetric"))$id) %>%
  mutate(half = ifelse(order < 13, 1, 2)) %>%
  group_by(workerid,condition,half) %>%
  summarize(n = n(), ntarget = sum(selection == "target"), 
            ncompetitor = sum(selection == "competitor"), 
            pcompetitor = ncompetitor / (ncompetitor + ntarget)) 

# LOGISTIC REGRESSION TO INVESTIGATE EFFECT OF CONDITION (MAX RANEF STRUCTURE)

d$selection <- relevel(d$selection, ref = "target")
d$condition <- relevel(d$condition, ref = "control")

d_filtered <- d %>%
  # ONLY INTERESTED IN "LOOKS LIKE" TRIALS...
  filter(type == "looks like") %>%
  # ... THAT THE CONDITIONS SHARE IN COMMON
  filter(id %in% (d %>% filter(type == "looks like" & condition == "symmetric"))$id)

# EXAMPLE: BINARY LOGISTIC REGRESSION BETWEEN CONTROL AND TARGET CONDITIONS

m <- glmer(selection ~ condition + (1|workerid) + (1 + condition|id), family = "binomial", data = d_filtered)

lsmeans(m, revpairwise~condition)

# EXPLORATORY ANALYSIS: LOOKING FOR ORDER EFFECTS

m2 <- glmer(selection ~ condition + order + (1 + order|workerid) + (1 + order + condition|id), family = "binomial", data = d_filtered)

summary(m2)

# BAYESIAN DATA ANALYSIS

# LOAD & TRANSFORM DATA FROM NORMING STUDIES 

d_noprompt <- read.csv("results_noprompt.csv")

levels(d_noprompt$language) # KEEP DATA IF LANGUAGE = SOME SPELLING VARIATION OF 'ENGLISH' (OR NA)

noprompt_to_exclude <- d %>%
  group_by(workerid, type, selection) %>%
  filter((type == "left" && selection == "right") || (type == "right" && selection  == "left")) %>%
  group_by(workerid) %>%
  summarize(n_mistakes = n()) %>%
  filter(n_mistakes > 0)

d_noprompt <- d_noprompt %>%
  filter(!(workerid %in% noprompt_to_exclude$workerid))

d_noprompt <- d_noprompt %>%
  filter(kind == "critical") %>%
  group_by(id) %>%
  summarize(ntarget = sum(selection == "target"), 
            ncompetitor = sum(selection == "competitor"), 
            competitor_prior = ncompetitor / (ncompetitor + ntarget))

d_naming <- read.csv("results_naming.csv")

d_naming <- d_naming %>%
  group_by(id) %>%
  summarize(nknowtarget = sum(type == "target" & know == "True"),
            nknowcompetitor = sum(type == "competitor" & know == "True"),
            target_nameability = nknowtarget / sum(type == "target"),
            competitor_nameability = nknowcompetitor / sum(type == "competitor"))

# INFER PARAMS GLOBALLY

bda <- read_file("bda_inferglobal_6cost.txt")
# bda <- read_file("bda_inferglobal_3cost.txt")

d_total <- d %>%
  filter(kind == "critical" & type == "looks like") %>% 
  group_by(id,condition) %>%summarize(ntarget = sum(selection == "target"), 
                  ncompetitor = sum(selection == "competitor"), 
                  observed_competitor = ncompetitor / (ncompetitor + ntarget))

d_total <- merge(d_total, d_naming, by = "id")
d_total <- merge(d_total, d_noprompt, by = "id")
d_total <- d_total %>%
  select(id,observed_competitor,competitor_prior,target_nameability,competitor_nameability)

d_total_JSON <- toJSON(d_total)

full_bda <- webppl(paste("var itemData = ", d_total_JSON, "\n", bda))

full_posteriors <- (full_bda$posteriors)$support

full_maxap <- (full_bda$maxap)

# write.csv(full_posteriors, file = "posteriors/posteriors_fulldata.csv")

# INFER PARAMS BY CONDITION

# bda_bycondition <- read_file("bda_bycondition_6cost.txt")
bda_bycondition <- read_file("bda_bycondition_3cost.txt")

# GET BY-ITEM DATA BY CONDITION

data_byitem <- function(cond, data) {
  output <- data %>%
    filter(condition == cond & kind == "critical" & type == "looks like") %>% 
    group_by(id) %>%
    summarize(ntarget = sum(selection == "target"), 
              ncompetitor = sum(selection == "competitor"), 
              observed_competitor = ncompetitor / (ncompetitor + ntarget))
  output <- merge(output, d_naming, by = "id")
  output <- merge(output, d_noprompt, by = "id")
  output <- output %>%
    select(id,observed_competitor,competitor_prior,target_nameability,competitor_nameability)
}

symmetric_byitem <-data_byitem("symmetric",d)
control_byitem <-data_byitem("control",d)
target_byitem <-data_byitem("target",d)
nottarget_byitem <-data_byitem("nottarget",d)

# INFER PARAMETERS: CONTROL CONDITION

control_byitem_json <- toJSON(control_byitem)

control_bda <- webppl(paste("var itemData = ", control_byitem_json, 
                                        "\n var alpha =", full_maxap$alpha,
                                        "\n", bda_bycondition))

posteriors_control <- (control_bda$posteriors)$support

# write.csv(posteriors_control, file = "posteriors/posteriors_control.csv")

# INFER PARAMETERS: TARGET CONDITION

target_byitem_json <- toJSON(target_byitem)

target_bda <- webppl(paste("var itemData = ", target_byitem_json, 
                                        "\n var alpha =", full_maxap$alpha,
                                        "\n", bda_bycondition))

posteriors_target <- (target_bda$posteriors)$support

# write.csv(posteriors_target, file = "posteriors/posteriors_target.csv")

# INFER PARAMETERS: NOT-TARGET CONDITION

nottarget_byitem_json <- toJSON(nottarget_byitem)

nottarget_bda <- webppl(paste("var itemData = ", nottarget_byitem_json, 
                                      "\n var alpha =", full_maxap$alpha, 
                                      "\n", bda_bycondition))

posteriors_nottarget <- (nottarget_bda$posteriors)$support

# write.csv(posteriors_nottarget, file = "posteriors/posteriors_nottarget.csv")

# INFER PARAMETERS: SYMMETRIC CONDITION

symmetric_byitem_json <- toJSON(symmetric_byitem)

symmetric_bda <- webppl(paste("var itemData = ", symmetric_byitem_json, 
                                        "\n var alpha =", full_maxap$alpha,
                                        "\n", bda_bycondition))

posteriors_symmetric <- (symmetric_bda$posteriors)$support

# write.csv(posteriors_symmetric, file = "posteriors/posteriors_symmetric.csv")

# NEW VISUALIZATIONS

# BY-CONDITION VISUALIZATIONS

dodge = position_dodge(.9)

toplot <- function (data) {
  output <- data %>% 
    # group_by(condition,half) %>%
    group_by(condition) %>%
    summarize(Mean = mean(pcompetitor),CILow=ci.low(pcompetitor),CIHigh =ci.high(pcompetitor)) %>%
    ungroup() %>%
    mutate(Ymin=Mean-CILow,Ymax=Mean+CIHigh)
  return(output)
}

plot_means <- function (toplot) {
  ggplot(toplot, aes(x=condition,y=Mean)) +
    # facet_wrap(~half) +
    geom_bar(stat="identity",position = "dodge") +
    theme(axis.text.x=element_text(angle=20,hjust=1,vjust=1)) +
    geom_errorbar(aes(ymin=Ymin,ymax=Ymax),width=.25, position = dodge) + 
    labs(x = "Condition", y = "Proportion")  # +
  # ggtitle("Proportion of a competitor image chosen on 'looks like' trials\n(Experiment 3)")
}

plot_means(toplot(sel_counts))

# BY-ITEM VISUALIZATIONS 

byitem <- d %>%
  filter(kind == "critical" & type == "looks like") %>% 
  # ... THAT THE CONDITIONS SHARE IN COMMON
  filter(id %in% (d %>% filter(type == "looks like" & condition == "symmetric"))$id) %>%
  group_by(id,condition) %>%
  summarize(ntarget = sum(selection == "target"), 
            ncompetitor = sum(selection == "competitor"), 
            observed_competitor = ncompetitor / (ncompetitor + ntarget))

byitem <- merge(byitem, d_naming, by = "id")
byitem <- merge(byitem, d_noprompt, by = "id")
byitem <- byitem %>%
  mutate(nameability_index = target_nameability / competitor_nameability)

table(d$id, d$condition, d$type)

ggplot(byitem, aes(x=condition, y=observed_competitor)) +
  facet_wrap(~id)+
  geom_point() + 
  labs(x = "Condition", y = "Proportion") +
  # ggtitle("Proportion of a competitor image chosen on 'looks like' trials\n(By item, Experiment 3)") +
  theme(axis.text.x=element_text(angle=20,hjust=1,vjust=1))

# ALPHA PARAMETER GLOBAL DIST

ggplot(full_posteriors, aes(alpha)) + geom_density(alpha = 0.2) +
  labs(x = "Inferred alpha parameter value", y = "Density") # +
# ggtitle("Posterior distribution of alpha parameter values\n(Experiment 3)") 

# VISUALIZE POSTERIOR PARAMS BY CONDITION 

vizparams_bycondition <- function(posteriors) {
  toplot <- posteriors %>% 
    select(cost_is,cost_not,cost_lookslike) %>%
   # select(cost_istarget,cost_looksliketarget,cost_nottarget) %>%
    gather(key = "parameter", value = "cost")
  ggplot(toplot, aes(cost, fill = parameter)) + geom_density(alpha = 0.2) +
    labs(x = "Inferred value", y = "Density")
}

vizparams_bycondition(posteriors_control)
vizparams_bycondition(posteriors_target)
vizparams_bycondition(posteriors_nottarget)
vizparams_bycondition(posteriors_symmetric)

# VISUALIZE POSTERIOR PREDICTIVES BY CONDITION 

target_predictives <- target_bda$predictions
nottarget_predictives <- nottarget_bda$predictions
symmetric_predictives <- symmetric_bda$predictions
control_predictives <- control_bda$predictions %>%
  filter(id %in% symmetric_predictives$id)

target_byitem$condition <- "target"
nottarget_byitem$condition <- "nottarget"
symmetric_byitem$condition <- "symmetric"
control_byitem$condition <- "control"

target_predictive_toplot <- cbind(target_predictives,target_byitem$observed_competitor,target_byitem$condition)
nottarget_predictive_toplot <- cbind(nottarget_predictives,nottarget_byitem$observed_competitor,nottarget_byitem$condition)
symmetric_predictive_toplot <- cbind(symmetric_predictives,symmetric_byitem$observed_competitor,symmetric_byitem$condition)
control_predictive_toplot <- cbind(control_predictives,(control_byitem %>% filter (id %in% control_predictives$id))$observed_competitor,
                                   (control_byitem %>% filter (id %in% control_predictives$id))$condition)

colnames(target_predictive_toplot) <- c("id","prediction","observation","condition")
colnames(nottarget_predictive_toplot) <- c("id","prediction","observation","condition")
colnames(control_predictive_toplot) <- c("id","prediction","observation","condition")
colnames(symmetric_predictive_toplot) <- c("id","prediction","observation","condition")

toplot_predictive <- rbind(target_predictive_toplot, nottarget_predictive_toplot, 
                           symmetric_predictive_toplot, control_predictive_toplot)

ggplot(toplot_predictive, aes(x=prediction, y=observation, color = condition)) + geom_point() +
    labs(x = "Predicted proportion of competitor chosen", y = "Observed proportion of competitor chosen") +
  expand_limits(x = c(0,0.75), y = c(0,0.75)) +
  geom_abline()
  
summary(lmer(observation ~ prediction + (prediction|id), data = toplot_predictive))

# NAMEABILITY PLOTS

toplot_nameability <- rbind(target_byitem,nottarget_byitem,symmetric_byitem,control_byitem)

competitor_nameability_plot <- ggplot(toplot_nameability, aes(x=competitor_nameability, y = observed_competitor)) +
  facet_wrap(~condition) +
  labs(x = "Competitor nameability", y = "Observed proportion of competitor chosen") +
  geom_point() +
  geom_smooth(method='lm',formula=y~x)

d_filtered_total <- merge(d_filtered, d_naming, by = "id")

m_nameability <- glm (selection ~ condition * competitor_nameability, family = "binomial", data = d_filtered_total)

summary(glmer(selection ~ condition * competitor_nameability + (1|workerid) + (1 + condition|id), family = "binomial", data = d_filtered_total))

write.csv(symmetric_bda$predictions,"predictives/symmetric_predictives.csv" )
write.csv(control_bda$predictions,"predictives/control_predictives.csv" )
write.csv(target_bda$predictions,"predictives/target_predictives.csv" )
write.csv(nottarget_bda$predictions,"predictives/nottarget_predictives.csv" )

full_posteriors <- read.csv("posteriors/posteriors_fulldata.csv")
posteriors_control <- read.csv("posteriors/posteriors_control.csv")
posteriors_target <- read.csv("posteriors/posteriors_target.csv")
posteriors_nottarget <- read.csv("posteriors/posteriors_nottarget.csv")
posteriors_symmetric <- read.csv("posteriors/posteriors_symmetric.csv")



