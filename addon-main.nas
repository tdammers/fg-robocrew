var fgHome = getprop("/sim/fg-home");

globals.propify = func (prop, create=0) {
    if (typeof(prop) == 'scalar') {
        var myprop = props.globals.getNode(prop, create);
        if (myprop == nil) {
            print('Warning: requested property ' ~ prop ~ ' does not exist');
        }
        return myprop;
    }
    else {
        return prop;
    }
};

var rcprops = {
    flightPhase: props.globals.getNode('/robocrew/common/flight-phase', 1),
    flightPhases: props.globals.getNode('/robocrew/common/flight-phases', 1),
    autoFlightPhase: props.globals.getNode('/robocrew/common/auto-flight-phase', 1),
    crew: props.globals.getNode('/robocrew/crew', 1),
    soundQueue: props.globals.getNode('/sim/sound/robocrew'),
};

rcprops.soundQueue.setBoolValue('enabled', 1);
rcprops.soundQueue.setValue('volume', 0.5);

globals.robocrew = {};
globals.robocrew.rcprops = rcprops;
globals.robocrew.updateFlightPhases = func (flightPhases) {
    rcprops.flightPhases.removeAllChildren();
    foreach (var phase; flightPhases) {
        rcprops.flightPhases.addChild('value').setValue(phase);
    }
};

globals.robocrew.updateFlightPhases(['OFF']);

var load_module = func (module) {
    var dirname = io.dirname(caller()[2]);
    io.load_nasal(dirname ~ '/' ~ module, 'robocrew');
};

if (!rcprops.flightPhase.getValue()) {
    rcprops.flightPhase.setValue('OFF');
}

var load_crew = func(name) {
    if (name == nil) return 0;
    var file = fgHome ~ "/Export/robocrew/" ~ name ~ ".nas";
    if (io.stat(file) != nil) {
        if (contains(globals.robocrew, 'crew')) {
            robocrew.crew.teardown();
            delete(globals.robocrew, 'crew');
        }
        print("Loading crew: " ~ file);
        io.load_nasal(file, 'robocrew');
        robocrew.crew.init();
        return 1;
    }
    else {
        return 0;
    }
};

var family_patterns = [
    [ "777-*", "777" ],
    [ "747-*", "747" ],
    [ "dhc6*", "DHC6" ],
    [ "PA28-*", "P28A" ],
    [ "Citation-II*", "C550" ],
    [ "Embraer1[79][05]", "E170" ],
    [ "EmbraerLineage1000", "E170" ],
    [ "A320*", "A320" ],
    [ "MD-11*", "MD11" ],
    [ "Lockheed1049*", "CONI" ],
];

var subtype = getprop('/sim/aircraft');
var type = getprop('/sim/variant-of');
var family = nil;
foreach (var pattern; family_patterns) {
    if (string.match(subtype, pattern[0])) {
        family = pattern[1];
        break;
    }
}

var unload = func (addon) {
    if (contains(globals, 'robocrew') and contains(globals.robocrew, 'crew')) {
        robocrew.crew.teardown();
    }
};

var main = func (addon) {
    globals.robocrew.addonPath = addon.basePath;
    load_module('worker.nas');
    load_module('crew.nas');
    load_module('actions.nas');
    load_module('job.nas');

    load_crew(subtype) or load_crew(type) or load_crew(family);
};
