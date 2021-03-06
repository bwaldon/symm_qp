var exclusion_controls = [  {
    "ref": "left",
    "noun": "control_1",
    "noun_pretty": null,
    "ref_pretty": "Click on the image on the left.",
    "kind": "control"
  },
  {
    "ref": "right",
    "noun": "control_2",
    "noun_pretty": null,
    "ref_pretty": "Click on the image on the right.",
    "kind": "control"
  },
  {
    "ref": "left",
    "noun": "control_3",
    "noun_pretty": null,
    "ref_pretty": "Click on the image on the left.",
    "kind": "control"
  },
  {
    "ref": "right",
    "noun": "control_4",
    "noun_pretty": null,
    "ref_pretty": "Click on the image on the right.",
    "kind": "control"
  }];

var order = 1;

function make_slides(f) {
  var   slides = {};

  var makelist = function(stims) {
    var exc = _.shuffle(exclusion_controls);
    var firsthalf = stims.slice(0,12).concat(exc.slice(0,2))
    firsthalf = _.shuffle(firsthalf)
    var secondhalf = stims.slice(12,24).concat(exc.slice(2,4))
    secondhalf = _.shuffle(secondhalf)
    return firsthalf.concat(secondhalf);
  }

  present_list = makelist(control);
 
  slides.consent = slide({
     name : "consent",
     start: function() {
      exp.startT = Date.now();
      $("#consent_2").hide();
      exp.consent_position = 0;
     },
    button : function() {
      if(exp.consent_position == 0) {
         exp.consent_position++;
         $("#consent_1").hide();
         $("#consent_2").show();
      } else {
        exp.go(); //use exp.go() if and only if there is no "present" data.
      }
    }
  });

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

slides.instructions = slide({
    name : "instructions",
    button : function() {
        exp.go(); //use exp.go() if and only if there is no "present" data.    
    }
  });

 slides.auth = slide({
    name : "auth",
  });

slides.critical = slide({

    name : "img_select",

    /* trial information for this block
     (the variable 'stim' will change between each of these values,
      and for each of these, present_handle will be run.) */

    present : present_list,

    //this gets run only at the beginning of the block
  
    present_handle : function(stim) {
    this.stim = stim; 

    if (stim.kind == "critical") {
      $(".prompt").html('<b>Mr. Davis: </b>*mumble mumble*<p><b>What was Mr. Davis looking at?</b>');
      img_order = _.shuffle(["good","bad"]);
      $(".images").html('<img src = "resources/images/' + stim.noun + '_' + img_order[0] + '.jpeg" onclick = "_s.selection_' + img_order[0] + '()">' + 
        '<img src = "resources/images/' + stim.noun + '_' + img_order[1] + '.jpeg" onclick = "_s.selection_' + img_order[1] + '()">')
    } else if (stim.kind == "control") {
      $(".prompt").html('<b><i>' + stim.ref_pretty + '</i></b>');
      $(".images").html('<img src = "resources/images/' + stim.noun + '_left.jpeg" onclick = "_s.selection_left()">' + 
        '<img src = "resources/images/' + stim.noun + '_right.jpeg" onclick = "_s.selection_right()">')
    }

    },

    selection_right : function() {
      img_order = "null";
      this.selection = "right";
      this.log_responses();
      _stream.apply(this);
    },

    selection_left : function() {
      img_order = "null";
      this.selection = "left";
      this.log_responses();
      _stream.apply(this);
    },

    selection_good : function() {
        this.selection = "target";
        this.log_responses();

        /* use _stream.apply(this); if and only if there is
        "present" data. (and only *after* responses are logged) */
        _stream.apply(this);
      },

    selection_bad : function() {
        this.selection = "competitor";
        this.log_responses();

        /* use _stream.apply(this); if and only if there is
        "present" data. (and only *after* responses are logged) */
        _stream.apply(this);
      },

    log_responses : function() {
      exp.data_trials.push({
        "img_order" : img_order,
        "selection" : this.selection,
        "type" : this.stim.ref,
        "id" : this.stim.noun,
        "order" : order,
        "kind" : this.stim.kind,
      });
    order = order + 1;
    },
  });


  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        comments : $("#comments").val(),
        problems: $("#problems").val(),
        fairprice: $("#fairprice").val()
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          // "order" : exp.order,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {
  exp.trials = [];
  exp.catch_trials = [];
  exp.condition = _.sample(["control","target","nottarget","symmetric"]); //can randomize between subject conditions here
  // exp.order = _.sample(["4fillerspacing","nofillerspacing"]);
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=["auth","i0", "instructions", "critical", 'subj_info', 'thanks'];

  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  exp.go(); //show first slide
}