exports.models = [
  {
    "alts": "3alt",
    "cost": "3cost",
    "nameability": "N"
  },
  {
    "alts": "3alt",
    "cost": "3cost",
    "nameability": "noN"
  },
  {
    "alts": "6alt",
    "cost": "3cost",
    "nameability": "N"
  },
  {
    "alts": "6alt",
    "cost": "3cost",
    "nameability": "noN"
  },
  {
    "alts": "6alt",
    "cost": "6cost",
    "nameability": "N"
  },
  {
    "alts": "6alt",
    "cost": "6cost",
    "nameability": "noN"
  }
];

exports.inferencesettings = '{ method: "MCMC", samples: 1200, burn: 12000, lag: 10, verbose: true, model: dataAnalysis2}';

exports.controlresults = [{"id":"baseball","observed_competitor":0.0857,"competitor_prior":0.6,"target_nameability":1,"competitor_nameability":0.9667,"condition":"control"},{"id":"cake","observed_competitor":0.0286,"competitor_prior":0.5333,"target_nameability":1,"competitor_nameability":1,"condition":"control"},{"id":"cat","observed_competitor":0.0571,"competitor_prior":0.5667,"target_nameability":0.9667,"competitor_nameability":1,"condition":"control"},{"id":"flower","observed_competitor":0.0571,"competitor_prior":0.6,"target_nameability":0.9667,"competitor_nameability":0.8,"condition":"control"},{"id":"hammer","observed_competitor":0.0571,"competitor_prior":0.5333,"target_nameability":1,"competitor_nameability":0.4667,"condition":"control"},{"id":"hedgehog","observed_competitor":0.0857,"competitor_prior":0.5667,"target_nameability":0.9667,"competitor_nameability":0.5333,"condition":"control"},{"id":"horse","observed_competitor":0.0571,"competitor_prior":0.5667,"target_nameability":1,"competitor_nameability":1,"condition":"control"},{"id":"house","observed_competitor":0.0286,"competitor_prior":0.6667,"target_nameability":1,"competitor_nameability":1,"condition":"control"},{"id":"monkey","observed_competitor":0.1429,"competitor_prior":0.5333,"target_nameability":0.9667,"competitor_nameability":1,"condition":"control"},{"id":"mouse","observed_competitor":0.0571,"competitor_prior":0.7333,"target_nameability":1,"competitor_nameability":0.4,"condition":"control"},{"id":"panda","observed_competitor":0.0571,"competitor_prior":0.4,"target_nameability":1,"competitor_nameability":0.6667,"condition":"control"},{"id":"rabbit","observed_competitor":0.0286,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.4333,"condition":"control"},{"id":"railroad","observed_competitor":0.0286,"competitor_prior":0.4333,"target_nameability":0.9667,"competitor_nameability":0.9333,"condition":"control"},{"id":"rainbow","observed_competitor":0.0571,"competitor_prior":0.5333,"target_nameability":0.9667,"competitor_nameability":0.8667,"condition":"control"},{"id":"reindeer","observed_competitor":0.0571,"competitor_prior":0.6333,"target_nameability":0.9667,"competitor_nameability":1,"condition":"control"},{"id":"sailboat","observed_competitor":0.0571,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.6333,"condition":"control"},{"id":"shark","observed_competitor":0.0571,"competitor_prior":0.3667,"target_nameability":1,"competitor_nameability":1,"condition":"control"},{"id":"skateboard","observed_competitor":0.0286,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.8333,"condition":"control"},{"id":"spoon","observed_competitor":0.0286,"competitor_prior":0.6333,"target_nameability":1,"competitor_nameability":0.9667,"condition":"control"},{"id":"sundial","observed_competitor":0.0286,"competitor_prior":0.3667,"target_nameability":0.9667,"competitor_nameability":0.7333,"condition":"control"},{"id":"tadpole","observed_competitor":0.2,"competitor_prior":0.5333,"target_nameability":0.7667,"competitor_nameability":0.4667,"condition":"control"},{"id":"waspsnest","observed_competitor":0.0857,"competitor_prior":0.4667,"target_nameability":0.9,"competitor_nameability":0.4333,"condition":"control"},{"id":"wheel","observed_competitor":0.0571,"competitor_prior":0.4,"target_nameability":0.9667,"competitor_nameability":0.4667,"condition":"control"},{"id":"zebra","observed_competitor":0.0571,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.4,"condition":"control"}]

exports.targetresults = [{"id":"baseball","observed_competitor":0.2273,"competitor_prior":0.6,"target_nameability":1,"competitor_nameability":0.9667},{"id":"cake","observed_competitor":0.2727,"competitor_prior":0.5333,"target_nameability":1,"competitor_nameability":1},{"id":"flower","observed_competitor":0.1818,"competitor_prior":0.6,"target_nameability":0.9667,"competitor_nameability":0.8},{"id":"hedgehog","observed_competitor":0.2273,"competitor_prior":0.5667,"target_nameability":0.9667,"competitor_nameability":0.5333},{"id":"horse","observed_competitor":0.1818,"competitor_prior":0.5667,"target_nameability":1,"competitor_nameability":1},{"id":"house","observed_competitor":0.2727,"competitor_prior":0.6667,"target_nameability":1,"competitor_nameability":1},{"id":"mouse","observed_competitor":0.2727,"competitor_prior":0.7333,"target_nameability":1,"competitor_nameability":0.4},{"id":"panda","observed_competitor":0.3182,"competitor_prior":0.4,"target_nameability":1,"competitor_nameability":0.6667},{"id":"railroad","observed_competitor":0.3182,"competitor_prior":0.4333,"target_nameability":0.9667,"competitor_nameability":0.9333},{"id":"rainbow","observed_competitor":0.3182,"competitor_prior":0.5333,"target_nameability":0.9667,"competitor_nameability":0.8667},{"id":"shark","observed_competitor":0.2273,"competitor_prior":0.3667,"target_nameability":1,"competitor_nameability":1},{"id":"spoon","observed_competitor":0.2273,"competitor_prior":0.6333,"target_nameability":1,"competitor_nameability":0.9667},{"id":"sundial","observed_competitor":0.2727,"competitor_prior":0.3667,"target_nameability":0.9667,"competitor_nameability":0.7333},{"id":"tadpole","observed_competitor":0.4091,"competitor_prior":0.5333,"target_nameability":0.7667,"competitor_nameability":0.4667},{"id":"wheel","observed_competitor":0.3182,"competitor_prior":0.4,"target_nameability":0.9667,"competitor_nameability":0.4667},{"id":"zebra","observed_competitor":0.3182,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.4}]

exports.symmetricresults = [{"id":"baseball","observed_competitor":0.1786,"competitor_prior":0.6,"target_nameability":1,"competitor_nameability":0.9667},{"id":"cake","observed_competitor":0.25,"competitor_prior":0.5333,"target_nameability":1,"competitor_nameability":1},{"id":"flower","observed_competitor":0.1786,"competitor_prior":0.6,"target_nameability":0.9667,"competitor_nameability":0.8},{"id":"hedgehog","observed_competitor":0.2143,"competitor_prior":0.5667,"target_nameability":0.9667,"competitor_nameability":0.5333},{"id":"horse","observed_competitor":0.25,"competitor_prior":0.5667,"target_nameability":1,"competitor_nameability":1},{"id":"house","observed_competitor":0.3929,"competitor_prior":0.6667,"target_nameability":1,"competitor_nameability":1},{"id":"mouse","observed_competitor":0.3571,"competitor_prior":0.7333,"target_nameability":1,"competitor_nameability":0.4},{"id":"panda","observed_competitor":0.3929,"competitor_prior":0.4,"target_nameability":1,"competitor_nameability":0.6667},{"id":"railroad","observed_competitor":0.3571,"competitor_prior":0.4333,"target_nameability":0.9667,"competitor_nameability":0.9333},{"id":"rainbow","observed_competitor":0.4286,"competitor_prior":0.5333,"target_nameability":0.9667,"competitor_nameability":0.8667},{"id":"shark","observed_competitor":0.3214,"competitor_prior":0.3667,"target_nameability":1,"competitor_nameability":1},{"id":"spoon","observed_competitor":0.2143,"competitor_prior":0.6333,"target_nameability":1,"competitor_nameability":0.9667},{"id":"sundial","observed_competitor":0.3929,"competitor_prior":0.3667,"target_nameability":0.9667,"competitor_nameability":0.7333},{"id":"tadpole","observed_competitor":0.4643,"competitor_prior":0.5333,"target_nameability":0.7667,"competitor_nameability":0.4667},{"id":"wheel","observed_competitor":0.3929,"competitor_prior":0.4,"target_nameability":0.9667,"competitor_nameability":0.4667},{"id":"zebra","observed_competitor":0.3571,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.4}]

exports.nottargetresults = [{"id":"baseball","observed_competitor":0.1667,"competitor_prior":0.6,"target_nameability":1,"competitor_nameability":0.9667},{"id":"cake","observed_competitor":0.0667,"competitor_prior":0.5333,"target_nameability":1,"competitor_nameability":1},{"id":"flower","observed_competitor":0.1333,"competitor_prior":0.6,"target_nameability":0.9667,"competitor_nameability":0.8},{"id":"hedgehog","observed_competitor":0.1333,"competitor_prior":0.5667,"target_nameability":0.9667,"competitor_nameability":0.5333},{"id":"horse","observed_competitor":0.2333,"competitor_prior":0.5667,"target_nameability":1,"competitor_nameability":1},{"id":"house","observed_competitor":0.2667,"competitor_prior":0.6667,"target_nameability":1,"competitor_nameability":1},{"id":"mouse","observed_competitor":0.1667,"competitor_prior":0.7333,"target_nameability":1,"competitor_nameability":0.4},{"id":"panda","observed_competitor":0.2,"competitor_prior":0.4,"target_nameability":1,"competitor_nameability":0.6667},{"id":"railroad","observed_competitor":0.1333,"competitor_prior":0.4333,"target_nameability":0.9667,"competitor_nameability":0.9333},{"id":"rainbow","observed_competitor":0.1333,"competitor_prior":0.5333,"target_nameability":0.9667,"competitor_nameability":0.8667},{"id":"shark","observed_competitor":0.1333,"competitor_prior":0.3667,"target_nameability":1,"competitor_nameability":1},{"id":"spoon","observed_competitor":0.1333,"competitor_prior":0.6333,"target_nameability":1,"competitor_nameability":0.9667},{"id":"sundial","observed_competitor":0.1667,"competitor_prior":0.3667,"target_nameability":0.9667,"competitor_nameability":0.7333},{"id":"tadpole","observed_competitor":0.2333,"competitor_prior":0.5333,"target_nameability":0.7667,"competitor_nameability":0.4667},{"id":"wheel","observed_competitor":0.2,"competitor_prior":0.4,"target_nameability":0.9667,"competitor_nameability":0.4667},{"id":"zebra","observed_competitor":0.1,"competitor_prior":0.5,"target_nameability":1,"competitor_nameability":0.4}]