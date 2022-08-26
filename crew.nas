var dt = 0.1;

var defaultFlightPhases = [
    'OFF',
    'PREFLIGHT',
    'TAXI-OUT',
    'TAKEOFF',
    'CLIMB',
    'CRUISE',
    'DESCENT',
    'APPROACH',
    'LANDING',
    'TAXI-IN',
    'SHUTDOWN',
];

var Crew = {
    new: func () {
        return {
            parents: [Crew],
            workers: [],
            timer: nil,
            flightPhases: defaultFlightPhases,
        };
    },

    setFlightPhases: func (flightPhases) {
        me.flightPhases = flightPhases;
        updateFlightPhases(flightPhases);
    },

    addWorker: func (worker) {
        append(me.workers, worker);
    },

    getNextFlightPhase: func (phase) {
        var i = vecindex(me.flightPhases, phase);
        if (i == nil) {
            i = 0;
        }
        else {
            i = math.mod(i + 1, size(me.flightPhases));
        }
        return me.flightPhases[i];
    },

    getPrevFlightPhase: func (phase) {
        var i = vecindex(me.flightPhases, phase);
        if (i == nil) {
            i = 0;
        }
        else {
            i = math.mod(i + size(me.flightPhases) - 1, size(me.flightPhases));
        }
        return me.flightPhases[i];
    },

    setNextFlightPhase: func {
        rcprops.flightPhase.setValue(
            me.getNextFlightPhase(
                rcprops.flightPhase.getValue()));
    },

    setFlightPhase: func (phase) {
        rcprops.flightPhase.setValue(phase);
    },

    init: func {
        var self = me;
        updateFlightPhases(me.flightPhases);
        if (me.timer == nil) {
            me.timer = maketimer(dt, func {
                foreach (var worker; self.workers) {
                    worker.update(dt);
                }
            });
            me.timer.simulatedTime = 1;
        }
        me.timer.start();
    },

    teardown: func {
        if (me.timer != nil) {
            me.timer.stop();
            me.timer = nil;
        }
        foreach (var worker; me.workers) {
            worker.removeAllJobs();
        }
        me.workers = [];
    },
};

