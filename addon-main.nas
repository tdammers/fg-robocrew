var fgHome = getprop("/sim/fg-home");

var rcprops = {
    flightPhase: props.globals.getNode('/robocrew/common/flight-phase', 1),
    crew: props.globals.getNode('/robocrew/crew', 1),
};

globals.robocrew = {};
globals.robocrew.rcprops = rcprops;

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
    load_crew(subtype) or load_crew(type) or load_crew(family) or load_crew('test');
};
