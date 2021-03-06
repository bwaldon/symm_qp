# PREAMBLE

library(tidyverse)
library(ordinal)
library(bootstrap)
library(rwebppl)
library(jsonlite)
library(lme4)

setwd("~/Documents/GitHub/symm_qp/results/pipeline_pilot_11122018")

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

# VISUALIZE RESULTS BY CONDITION

dodge = position_dodge(.9)

toplot <- function (data) {
  output <- data %>% 
    group_by(condition) %>%
    summarize(Mean = mean(pcompetitor),CILow=ci.low(pcompetitor),CIHigh =ci.high(pcompetitor)) %>%
    ungroup() %>%
    mutate(Ymin=Mean-CILow,Ymax=Mean+CIHigh)
  return(output)
}

plot_means <- function (toplot) {
  ggplot(toplot, aes(x=condition,y=Mean)) +
    geom_bar(stat="identity",position = "dodge") +
    theme(axis.text.x=element_text(angle=20,hjust=1,vjust=1)) +
    geom_errorbar(aes(ymin=Ymin,ymax=Ymax),width=.25, position = dodge) + 
    labs(x = "Condition", y = "Proportion") +
    ggtitle("Proportion of a competitor chosen")
}

plot_means(toplot(sel_counts))

# LOGISTIC REGRESSION TO INVESTIGATE EFFECT OF CONDITION (MAX RANEF STRUCTURE)

d$selection <- relevel(d$selection, ref = "target")
d$condition <- relevel(d$condition, ref = "control")

d_filtered <- d %>%
  # ONLY INTERESTED IN "LOOKS LIKE" TRIALS...
  filter(type == "looks like") %>%
  # ... THAT THE CONDITIONS SHARE IN COMMON
  filter(id %in% (d %>% filter(type == "looks like" & condition == "symmetric"))$id)

# EXAMPLE: BINARY LOGISTIC REGRESSION BETWEEN CONTROL AND TARGET CONDITIONS

m <- glmer(selection ~ condition + (1|workerid) + (1 + condition|id), family = "binomial", data = d_filtered %>% filter(condition %in% c("control","target")))

summary(m)

# EXPLORATORY ANALYSIS: LOOKING FOR ORDER EFFECTS

m2 <- glmer(selection ~ condition + order + (1 + order|workerid) + (1 + order + condition|id), family = "binomial", data = d_filtered %>% filter(condition %in% c("control","target")))

summary(m2)

# BAYESIAN DATA ANALYSIS

# LOAD & TRANSFORM DATA FROM NORMING STUDIES 

d_noprompt <- read.csv("results_noprompt.csv")

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

# MERGE TO MAIN STUDY DATA FROM SYMMETRIC CONDITION

symmetric_byitem <- d %>%
  filter(condition == "symmetric" & kind == "critical" & type == "looks like") %>% 
  group_by(id) %>%
  summarize(ntarget = sum(selection == "target"), 
            ncompetitor = sum(selection == "competitor"), 
            observed_competitor = ncompetitor / (ncompetitor + ntarget))

symmetric_byitem <- merge(symmetric_byitem, d_naming, by = "id")
symmetric_byitem <- merge(symmetric_byitem, d_noprompt, by = "id")
symmetric_byitem <- symmetric_byitem %>%
  select(id,observed_competitor,competitor_prior,target_nameability,competitor_nameability)

# ANALYZE 

bda <- read_file("bda.txt")

symmetric_byitem_json <- toJSON(symmetric_byitem)

symmetric_bda <- webppl(paste("var itemData = ", symmetric_byitem_json, "\n", bda))

symmetric_posteriors <- (symmetric_bda$posteriors)$support

symmetric_predictions <- symmetric_bda$predictions

symmetric_byitem <- merge(symmetric_byitem, symmetric_predictions, by = "id")

colnames(symmetric_byitem)[colnames(symmetric_byitem)=="prediction"] <- "rsa_prediction"

# DETERMINE CORRELATION OF MODEL PREDICTIONS AND OBSERVED DATA - ONE POINT FOR EVERY TRIAL OF THE EXPERIMENT

# IGNORANCE-1 MODEL: PARTICIPANTS RESPOND AT CHANCE 

symmetric_byitem$ig1_prediction <- 0.5

ggplot(symmetric_byitem, aes(x=observed_competitor, y=ig1_prediction)) + geom_point()

# IGNORANCE-2 MODEL: PARTICIPANTS RESPOND ACCORDING TO PRIOR EXPECTATIONS OF REFERENT 

symmetric_byitem$ig2_prediction <- symmetric_byitem$competitor_prior

ggplot(symmetric_byitem, aes(x=observed_competitor, y=ig2_prediction)) + geom_point()

with(symmetric_byitem, cor(observed_competitor,ig2_prediction))

# RSA MODEL:

ggplot(symmetric_byitem, aes(x=observed_competitor, y=rsa_prediction)) + geom_point()

with(symmetric_byitem, cor(observed_competitor,rsa_prediction))

# GET POSTERIOR DISTRIBUTIONS OF PARAMETER VALUES FROM RSA MODEL, E.G. ALPHA PARAMETER AND COST OF "IS AN X" FROM SYMMETRIC CONDITION

hist(symmetric_posteriors$alpha)
hist(symmetric_posteriors$cost_istarget)
