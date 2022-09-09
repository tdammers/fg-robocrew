var crewProps = {
    'firstOfficer': globals.robocrew.rcprops.crew.getNode('first-officer[0]', 1),
    'flightEngineer': globals.robocrew.rcprops.crew.getNode('flight-engineer[0]', 1),
};

crewProps.firstOfficer.setValue('name', 'First Officer');
crewProps.flightEngineer.setValue('name', 'Flight Engineer');

var controlProps = {
    firstOfficer: {},
    flightEngineer: {},
};

controlProps.firstOfficer.callouts = crewProps.firstOfficer.getNode('control[0]', 1);
controlProps.firstOfficer.callouts.setValue('name', 'Callouts');
controlProps.firstOfficer.callouts.setValue('type', 'checkbox');
controlProps.firstOfficer.callouts.setValue('input', 1);
controlProps.firstOfficer.callouts.setValue('status', 'OK');

controlProps.firstOfficer.v1 = crewProps.firstOfficer.getNode('control[1]', 1);
controlProps.firstOfficer.v1.setValue('name', 'V1');
controlProps.firstOfficer.v1.setValue('type', 'text');
controlProps.firstOfficer.v1.setValue('input', '100');
controlProps.firstOfficer.v1.setValue('status', 'OK');

controlProps.firstOfficer.vr = crewProps.firstOfficer.getNode('control[2]', 1);
controlProps.firstOfficer.vr.setValue('name', 'Vr');
controlProps.firstOfficer.vr.setValue('type', 'text');
controlProps.firstOfficer.vr.setValue('input', '110');
controlProps.firstOfficer.vr.setValue('status', 'OK');

controlProps.firstOfficer.v2 = crewProps.firstOfficer.getNode('control[3]', 1);
controlProps.firstOfficer.v2.setValue('name', 'V2');
controlProps.firstOfficer.v2.setValue('type', 'text');
controlProps.firstOfficer.v2.setValue('input', '115');
controlProps.firstOfficer.v2.setValue('status', 'OK');


controlProps.flightEngineer.throttle = crewProps.flightEngineer.getNode('control[0]', 1);
controlProps.flightEngineer.throttle.setValue('name', 'Throttle & Boost');
controlProps.flightEngineer.throttle.setValue('type', 'checkbox');
controlProps.flightEngineer.throttle.setValue('input', 1);
controlProps.flightEngineer.throttle.setValue('status', 'OK');

controlProps.flightEngineer.rpm = crewProps.flightEngineer.getNode('control[1]', 1);
controlProps.flightEngineer.rpm.setValue('name', 'RPM Control');
controlProps.flightEngineer.rpm.setValue('type', 'checkbox');
controlProps.flightEngineer.rpm.setValue('input', 1);
controlProps.flightEngineer.rpm.setValue('status', 'OK');

controlProps.flightEngineer.mixture = crewProps.flightEngineer.getNode('control[2]', 1);
controlProps.flightEngineer.mixture.setValue('name', 'Mixture Control');
controlProps.flightEngineer.mixture.setValue('type', 'checkbox');
controlProps.flightEngineer.mixture.setValue('input', 1);
controlProps.flightEngineer.mixture.setValue('status', 'OK');

controlProps.flightEngineer.cowlFlaps = crewProps.flightEngineer.getNode('control[3]', 1);
controlProps.flightEngineer.cowlFlaps.setValue('name', 'Cowl Flaps Control');
controlProps.flightEngineer.cowlFlaps.setValue('type', 'checkbox');
controlProps.flightEngineer.cowlFlaps.setValue('input', 1);
controlProps.flightEngineer.cowlFlaps.setValue('status', 'OK');

controlProps.flightEngineer.fuel = crewProps.flightEngineer.getNode('control[4]', 1);
controlProps.flightEngineer.fuel.setValue('name', 'Fuel Management');
controlProps.flightEngineer.fuel.setValue('type', 'checkbox');
controlProps.flightEngineer.fuel.setValue('input', 1);
controlProps.flightEngineer.fuel.setValue('status', 'OK');

controlProps.flightEngineer.electrical = crewProps.flightEngineer.getNode('control[5]', 1);
controlProps.flightEngineer.electrical.setValue('name', 'Electrical Systems');
controlProps.flightEngineer.electrical.setValue('type', 'checkbox');
controlProps.flightEngineer.electrical.setValue('input', 1);
controlProps.flightEngineer.electrical.setValue('status', 'OK');

var FuelManagementJob = {
    new: func (commandProp, mode) {
        var m = BaseJob.new(commandProp.getChild('input'), commandProp.getChild('status'));
        m.parents = [FuelManagementJob] ~ m.parents;
        m.mode = mode;
        m.tankProps = {
            tank1: props.globals.getNode('consumables/fuel/tank[4]/level-lbs'),
            tank2: props.globals.getNode('consumables/fuel/tank[5]/level-lbs'),
            tank3: props.globals.getNode('consumables/fuel/tank[6]/level-lbs'),
            tank4: props.globals.getNode('consumables/fuel/tank[7]/level-lbs'),
            tankCenter: props.globals.getNode('consumables/fuel/tank[8]/level-lbs'),
            tank1A: props.globals.getNode('consumables/fuel/tank[9]/level-lbs'),
            tank2A: props.globals.getNode('consumables/fuel/tank[10]/level-lbs'),
            tank3A: props.globals.getNode('consumables/fuel/tank[11]/level-lbs'),
            tank4A: props.globals.getNode('consumables/fuel/tank[12]/level-lbs'),
        };
        m.valveProps = {
            cross: [
                props.globals.getNode('controls/fuel/crossfeedvalve[0]'),
                props.globals.getNode('controls/fuel/crossfeedvalve[1]'),
                props.globals.getNode('controls/fuel/crossfeedvalve[2]'),
                props.globals.getNode('controls/fuel/crossfeedvalve[3]'),
            ],
            tank: [
                props.globals.getNode('controls/fuel/tankvalve[0]'),
                props.globals.getNode('controls/fuel/tankvalve[1]'),
                props.globals.getNode('controls/fuel/tankvalve[2]'),
                props.globals.getNode('controls/fuel/tankvalve[3]'),
                props.globals.getNode('controls/fuel/tankvalve[4]'),
            ],
        };
        m.scenario = 'DISENGAGED';
        return m;
    },

    update: func (dt) {
        var i = 0;
        var limit = 10;

        var totals = [
            me.tankProps.tank1.getValue() + me.tankProps.tank1A.getValue(),
            me.tankProps.tank2.getValue() + me.tankProps.tank2A.getValue(),
            me.tankProps.tank3.getValue() + me.tankProps.tank3A.getValue(),
            me.tankProps.tank4.getValue() + me.tankProps.tank4A.getValue(),
            me.tankProps.tankCenter.getValue()
        ];

        var totalsPerSide = [
            totals[0] + totals[1],
            totals[2] + totals[3],
        ];

        var onValues = [ 1, 1, 1, 1 ];
        var low2 = (me.tankProps.tank2.getValue() < limit);
        var low3 = (me.tankProps.tank3.getValue() < limit);

        if (low2 or low3) {
            onValues[1] = low2 ? 2 : 1;
            onValues[2] = low3 ? 2 : 1;
        }
        elsif (me.tankProps.tank2A.getValue() < me.tankProps.tank3A.getValue() - limit) {
            # Imbalance: 2A much lower than 3A
            onValues[1] = 1;
            onValues[2] = 2;
        }
        elsif (me.tankProps.tank3A.getValue() < me.tankProps.tank2A.getValue() - limit) {
            # Imbalance: 3A much lower than 2A
            onValues[1] = 2;
            onValues[2] = 1;
        }
        else {
            onValues[1] = 1;
            onValues[2] = 1;
        }

        var allLevels = sort(totals, func (a, b) { return b - a; });
        var median = (allLevels[1] + allLevels[2]) * 0.5;

        if (me.mode == 'TAKEOFF') {
            me.scenario = 'TAKEOFF';
            me.valveProps.tank[4].setValue(0);
            for (i = 0; i < 4; i += 1) {
                me.valveProps.tank[i].setValue(onValues[i]);
                me.valveProps.cross[i].setValue(0);
            }
        }
        elsif (totals[4] >= limit) {
            # 5 2 3 5
            me.scenario = 'EMPTY CTR';

            me.valveProps.tank[4].setValue(1);

            me.valveProps.cross[0].setValue(1);
            me.valveProps.tank[1].setValue(onValues[1]);
            me.valveProps.tank[2].setValue(onValues[2]);
            me.valveProps.cross[3].setValue(1);

            me.valveProps.tank[0].setValue(0);
            me.valveProps.cross[1].setValue(0);
            me.valveProps.cross[2].setValue(0);
            me.valveProps.tank[3].setValue(0);

        }
        elsif (totals[0] < totals[1] - limit) {
            # 2 2 3 4
            me.scenario = 'XFEED LEFT';

            me.valveProps.cross[0].setValue(1);
            me.valveProps.tank[1].setValue(onValues[1]);
            me.valveProps.cross[1].setValue(1);
            me.valveProps.tank[2].setValue(onValues[2]);
            me.valveProps.tank[3].setValue(onValues[3]);

            me.valveProps.tank[0].setValue(0);
            me.valveProps.cross[2].setValue(0);
            me.valveProps.cross[3].setValue(0);

            me.valveProps.tank[4].setValue(0);
        }
        elsif (totals[1] < totals[0] - limit) {
            # 1 1 3 4
            me.scenario = 'XFEED LEFT';

            me.valveProps.cross[1].setValue(1);
            me.valveProps.tank[0].setValue(onValues[0]);
            me.valveProps.cross[0].setValue(1);
            me.valveProps.tank[2].setValue(onValues[2]);
            me.valveProps.tank[3].setValue(onValues[3]);

            me.valveProps.tank[1].setValue(0);
            me.valveProps.cross[2].setValue(0);
            me.valveProps.cross[3].setValue(0);

            me.valveProps.tank[4].setValue(0);
        }
        elsif (totals[3] < totals[2] - limit) {
            # 1 2 3 3
            me.scenario = 'XFEED RIGHT';

            me.valveProps.tank[0].setValue(onValues[0]);
            me.valveProps.tank[1].setValue(onValues[1]);
            me.valveProps.tank[2].setValue(onValues[2]);
            me.valveProps.cross[2].setValue(1);
            me.valveProps.cross[3].setValue(1);

            me.valveProps.cross[0].setValue(0);
            me.valveProps.cross[1].setValue(0);
            me.valveProps.tank[3].setValue(0);

            me.valveProps.tank[4].setValue(0);
        }
        elsif (totals[2] < totals[3] - limit) {
            # 1 2 4 4
            me.scenario = 'XFEED RIGHT';

            me.valveProps.tank[0].setValue(onValues[0]);
            me.valveProps.tank[1].setValue(onValues[1]);
            me.valveProps.cross[2].setValue(1);
            me.valveProps.tank[3].setValue(onValues[3]);
            me.valveProps.cross[3].setValue(1);

            me.valveProps.cross[0].setValue(0);
            me.valveProps.cross[1].setValue(0);
            me.valveProps.tank[2].setValue(0);

            me.valveProps.tank[4].setValue(0);
        }
        else {
            # 1 2 3 4
            me.scenario = 'CRUISE/LAND';
            me.valveProps.tank[0].setValue(onValues[0]);
            me.valveProps.tank[1].setValue(onValues[1]);
            me.valveProps.tank[2].setValue(onValues[2]);
            me.valveProps.tank[3].setValue(onValues[3]);

            me.valveProps.cross[0].setValue(0);
            me.valveProps.cross[1].setValue(0);
            me.valveProps.cross[2].setValue(0);
            me.valveProps.cross[3].setValue(0);

            me.valveProps.tank[4].setValue(0);
        }
    },

    report: func {
        var result = me.scenario;
        for (i = 0; i < 4; i += 1) {
            result ~= ' ';
            if (me.valveProps.tank[i].getValue() == 0)
                result ~= '-';
            elsif (me.valveProps.tank[i].getValue() == 1)
                result ~= sprintf('%i', i + 1);
            elsif (me.valveProps.tank[i].getValue() == 2)
                result ~= sprintf('%iA', i + 1);
            if (me.valveProps.cross[i].getValue())
                result ~= 'X';
        }
        if (me.valveProps.tank[4].getValue()) {
            result ~= ' 5';
        }
        return result;
    },
};

var maintainMP = func (worker, targetMP) {
    if (targetMP != nil) {
        foreach (var e; [0,1,2,3]) {
            worker.addJob(
                PropertyTargetJob.new(
                    controlProps.flightEngineer.throttle.getChild('input'),
                    '/engines/engine[' ~ e ~ ']/mp-inhg',
                    targetMP,
                    '/controls/engines/engine[' ~ e ~ ']/throttle',
                    -0.01, -0.0002, -0.01, nil,
                    20));
        }
    }
    worker.addJob(
        ReportingJob.new(
            controlProps.flightEngineer.throttle,
            func {
                if (targetMP == nil) {
                    return 'PILOTS HAVE CONTROL';
                }
                else {
                    var report = sprintf("%2.1f", targetMP);
                    for (var e = 0; e < 4; e +=1 ) {
                        report ~= sprintf(" [%2.1f %s]",
                            getprop('/engines/engine[' ~ e ~ ']/mp-inhg'),
                            getprop('/fdm/jsbsim/propulsion/engine[' ~ e  ~ ']/boost-speed') ? 'H' : 'L');
                    }
                    return report;
                }
            }));
};

var maintainCHT = func (worker, targetTemp) {
    foreach (var e; [0,1,2,3]) {
        worker.addJob(
            PropertyTargetJob.new(
                controlProps.flightEngineer.cowlFlaps.getChild('input'),
                '/engines/engine[' ~ e ~ ']/cht-degf',
                targetTemp,
                '/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm',
                0.01, 0.01, 0.1, 0.1));
    }
    worker.addJob(
        ReportingJob.new(
            controlProps.flightEngineer.cowlFlaps,
            func {
                var report = sprintf("%1.0f*F", targetTemp);
                for (var e = 0; e < 4; e +=1 ) {
                    report ~= sprintf(" [%1.0f*F - %i%%]",
                        getprop('/engines/engine[' ~ e ~ ']/cht-degf'),
                        getprop('/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm') * 100);
                }
                return report;
            }));
};

var cowlFlapsFullOpen = func (worker) {
    foreach (var e; [0,1,2,3]) {
        worker.addJob(
            PropertySetJob.new(
                controlProps.flightEngineer.cowlFlaps.getChild('input'),
                '/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm',
                1.0));
    }
    worker.addJob(
        ReportingJob.new(
            controlProps.flightEngineer.cowlFlaps,
            func {
                return 'FULL OPEN';
            }));
};


var setRPM = func (worker, targetRPM, pitchSetting) {
    if (pitchSetting != nil) {
        worker.addJob(PropertySetJob.new(
            controlProps.flightEngineer.rpm.getChild('input'),
            '/controls/engines/propeller-pitch-all',
            pitchSetting, 0.5));
    }
    worker.addJob(
        ReportingJob.new(
            controlProps.flightEngineer.rpm,
            func {
                var report = sprintf("%s", targetRPM);
                for (var e = 0; e < 4; e +=1 ) {
                    report ~= sprintf(" [%04.0f]",
                        getprop('/engines/engine[' ~ e ~ ']/rpm'));
                }
                return report;
            }));
};

var BlowerJob = {
    new: func (masterSwitchProp, e) {
        var m = BaseJob.new(masterSwitchProp);
        m.parents = [BlowerJob] ~ m.parents;
        m.altProp = props.globals.getNode('/instrumentation/altimeter/indicated-altitude-ft');
        m.blowerProp = props.globals.getNode('/fdm/jsbsim/propulsion/engine[' ~ e ~ ']/boost-speed');
        m.throttleProp = props.globals.getNode('/controls/engines/engine[' ~ e ~ ']/throttle');
        return m;
    },

    update: func (dt) {
        var alt = me.altProp.getValue() or 0;
        var blower = me.blowerProp.getValue() or 0;
        if (alt > 9050.0 and blower == 0) {
            me.throttleProp.setValue(0.5);
            me.blowerProp.setValue(1);
        }
        elsif (alt < 8950.0 and blower == 1) {
            me.blowerProp.setValue(0);
        }
    },
};

# mode:
# 0 = enrich to peak BMEP
# 1 = lean to peak BMEP
# 2 = full rich
var manageMixture = func (worker, mode) {
    foreach (var e; [0,1,2,3]) {
        if (mode == 2) {
            worker.addJob(
                PropertySetJob.new(
                    controlProps.flightEngineer.mixture.getChild('input'),
                    '/controls/engines/engine[' ~ e ~ ']/mixture',
                    1));
        }
        else {
            worker.addJob(
                MaximizePropertyJob.new(
                    controlProps.flightEngineer.mixture.getChild('input'),
                    '/engines/engine[' ~ e ~ ']/bmep',
                    '/controls/engines/engine[' ~ e ~ ']/mixture',
                    (mode == 1) ? -0.025 : 0.025));
            worker.addJob(BlowerJob.new(controlProps.flightEngineer.throttle.getChild('input'), e));
        }
    }
    if (mode == 2) {
        worker.addJob(
            ReportingJob.new(
                controlProps.flightEngineer.mixture,
                func {
                    return 'FULL RICH';
                }));
    }
    else {
        var what = (mode == 1) ? 'LEAN' : 'RICH';
        worker.addJob(
            ReportingJob.new(
                controlProps.flightEngineer.mixture,
                func {
                    var report = what;
                    for (var e = 0; e < 4; e +=1 ) {
                        report ~= sprintf(" [%3.0f | %1.0f%%]",
                            math.max(0, getprop('/engines/engine[' ~ e ~ ']/bmep')),
                            getprop('/controls/engines/engine[' ~ e ~ ']/mixture') * 100);
                    }
                    return report;
                }));
    }
};

takeoffCallouts = func (worker) {
    worker.addJob(
        TriggerJob.new(
            controlProps.firstOfficer.callouts,
            func (on) { if (on) setprop('/sim/messages/copilot', '80 knots'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') > 80; },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') < 40; }));
    worker.addJob(
        TriggerJob.new(
            controlProps.firstOfficer.callouts,
            func (on) { if (on) setprop('/sim/messages/copilot', 'V1'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') > controlProps.firstOfficer.v1.getValue('input'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') < 40; }));
    worker.addJob(
        TriggerJob.new(
            controlProps.firstOfficer.callouts,
            func (on) { if (on) setprop('/sim/messages/copilot', 'Rotate'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') > controlProps.firstOfficer.vr.getValue('input'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') < 40; }));
    worker.addJob(
        TriggerJob.new(
            controlProps.firstOfficer.callouts,
            func (on) { if (on) setprop('/sim/messages/copilot', 'V2'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') > controlProps.firstOfficer.v2.getValue('input'); },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') < 40; }));
    worker.addJob(
        TriggerJob.new(
            controlProps.firstOfficer.callouts,
            func (on) { if (on) setprop('/sim/messages/copilot', 'Positive climb'); },
            func {
                return
                    (getprop('/instrumentation/vertical-speed-indicator/indicated-speed-fpm') > 500) and
                    (getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') > 120);
            },
            func { return getprop('/instrumentation/airspeed-indicator/indicated-speed-kt') < 40; }));
};

climbCallouts = func (worker) {
    worker.addJob(
        TriggerJob.new(
            controlProps.firstOfficer.callouts,
            func (on) { if (on) setprop('/sim/messages/copilot', '1000 to go'); },
            func {
                var altitude = getprop('/instrumentation/altimeter/indicated-altitude-ft');
                var cruiseAltitude =
                        getprop('/autopilot/route-manager/cruise/altitude-ft') or
                        (getprop('/autopilot/route-manager/cruise/flight-level') or 0) * 100;
                if (cruiseAltitude) {
                    return altitude >= cruiseAltitude - 1000;
                }
            }));
};

landingCallouts = func (worker) {
    foreach (var alt; [1000, 500, 400, 300, 200, 100, 50, 40, 30, 20, 10])
        (func (alt) {
            worker.addJob(
                TriggerJob.new(
                    controlProps.firstOfficer.callouts,
                    func (on) { if (on) setprop('/sim/messages/copilot', alt); },
                    func { getprop('/position/altitude-agl-ft') <= alt; }));
        })(alt);
};

var manageFuel = func (worker, mode='CRUISE') {
    worker.addJob(FuelManagementJob.new(controlProps.flightEngineer.fuel, mode));
};

setupElectrical = func (worker) {
    for (var e = 0; e < 4; e += 1) {
        worker.addJob(
            PropertySetJob.new(
                controlProps.flightEngineer.electrical.getNode('input'),
                'controls/switches/generator[' ~ e ~ ']',
                1));
        worker.addJob(
            PropertySetJob.new(
                controlProps.flightEngineer.electrical.getNode('input'),
                'controls/engines/engine[' ~ e ~ ']/magnetos',
                3));
    }
    worker.addJob(
        PropertySetJob.new(
            controlProps.flightEngineer.electrical.getNode('input'),
            'controls/switches/battery-ship',
            1));
    worker.addJob(
        PropertySetJob.new(
            controlProps.flightEngineer.electrical.getNode('input'),
            'controls/switches/gen-apu',
            1));
    worker.addJob(
        ReportingJob.new(
            controlProps.flightEngineer.electrical,
            func { return 'OK'; }));
};

var FirstOfficerMasterJob = {
    new: func (worker) {
        var m = MasterJob.new(worker);
        m.parents = [FirstOfficerMasterJob] ~ m.parents;
        return m;
    },

    loadJobs: func (phase) {
        if (phase == 'PREFLIGHT' or phase == 'TAXI-OUT') {
        }
        elsif (phase == 'TAKEOFF') {
            takeoffCallouts(me);
        }
        elsif (phase == 'CLIMB') {
            climbCallouts(me);
        }
        elsif (phase == 'CRUISE') {
        }
        elsif (phase == 'DESCENT') {
        }
        elsif (phase == 'APPROACH') {
        }
        elsif (phase == 'LANDING') {
            landingCallouts(me);
        }
        elsif (phase == 'TAXI-IN') {
        }
    },
};

var FlightEngineerMasterJob = {
    new: func (worker) {
        var m = MasterJob.new(worker);
        m.parents = [FlightEngineerMasterJob] ~ m.parents;
        return m;
    },

    loadJobs: func (phase) {
        if (phase == 'PREFLIGHT' or phase == 'TAXI-OUT') {
            cowlFlapsFullOpen(me);
            manageMixture(me, 2);
            maintainMP(me, nil);
            manageFuel(me, 'TAKEOFF');
            setRPM(me, 'FULL FWD', -1.0);
            setupElectrical(me);
        }
        elsif (phase == 'TAKEOFF') {
            cowlFlapsFullOpen(me);
            manageMixture(me, 2);
            maintainMP(me, 56.5);
            manageFuel(me, 'TAKEOFF');
            setRPM(me, '2900', -0.95);
        }
        elsif (phase == 'CLIMB') {
            maintainCHT(me, 490);
            manageMixture(me, 1);
            maintainMP(me, 48);
            manageFuel(me, 'CRUISE');
            setRPM(me, '2600', -0.6);
        }
        elsif (phase == 'CRUISE') {
            maintainCHT(me, 480);
            manageMixture(me, 1);
            maintainMP(me, 48);
            manageFuel(me, 'CRUISE');
            setRPM(me, '2300', -0.2);
        }
        elsif (phase == 'DESCENT') {
            maintainCHT(me, 480);
            manageMixture(me, 0);
            maintainMP(me, nil);
            manageFuel(me, 'CRUISE');
            setRPM(me, 'FULL FWD', -1);
        }
        elsif (phase == 'APPROACH' or phase == 'LANDING') {
            cowlFlapsFullOpen(me);
            manageMixture(me, 0);
            maintainMP(me, nil);
            manageFuel(me, 'LANDING');
            setRPM(me, 'FULL FWD', -1);
        }
        elsif (phase == 'TAXI-IN') {
        }
    },
};

var AutoFlightPhaseJob = {
    new: func (crew) {
        var m = BaseJob.new(rcprops.autoFlightPhase);
        m.parents = [AutoFlightPhaseJob] ~ m.parents;

        m.props = {};
        m.props.engineRunning = [];
        m.props.throttle = [];
        m.props.reverser = [];
        for (var e = 0; e < 4; e += 1) {
            append(m.props.engineRunning, props.globals.getNode('/engines/engine[' ~ e ~ ']/running'));
            append(m.props.throttle, props.globals.getNode('/controls/engines/engine[' ~ e ~ ']/throttle'));
            append(m.props.reverser, props.globals.getNode('/controls/engines/engine[' ~ e ~ ']/reverser'));
        }
        m.props.agl = props.globals.getNode('position/altitude-agl-ft');
        m.props.airspeed = props.globals.getNode('instrumentation/airspeed-indicator/indicated-speed-kt');
        m.props.groundspeed = props.globals.getNode('velocities/groundspeed-kt');
        m.props.flaps = props.globals.getNode('controls/flight/flaps');
        m.props.cruiseAlt = props.globals.getNode('autopilot/route-manager/cruise/altitude-ft');
        m.props.cruiseSpeed = props.globals.getNode('autopilot/route-manager/cruise/speed-kts');
        m.props.destination = props.globals.getNode('autopilot/route-manager/destination/runway');
        m.props.distanceRemaining = props.globals.getNode('autopilot/route-manager/distance-remaining-nm');
        m.props.vspeed = props.globals.getNode('instrumentation/vertical-speed-indicator/indicated-speed-fpm');

        return m;
    },

    update: func (dt) {
        var phase = rcprops.flightPhase.getValue();
        var nextPhase = me.nextPhase(phase);
        if (nextPhase != nil)
            robocrew.crew.setFlightPhase(nextPhase);
    },

    nextPhase: func(phase) {
        if (phase == 'OFF') {
            return nil; # Never auto-advance from OFF
        }
        elsif (phase == 'PREFLIGHT') {
            # PREFLIGHT becomes TAXI-OUT when all engines are running
            var allEnginesRunning = 1;
            foreach (var erp; me.props.engineRunning) {
                if (!erp.getBoolValue()) {
                    allEnginesRunning = 0;
                    break;
                }
            }
            if (allEnginesRunning)
                return 'TAXI-OUT';
            else
                return nil;
        }
        elsif (phase == 'TAXI-OUT') {
            return nil; # Initiating takeoff is always manual
        }
        elsif (phase == 'TAKEOFF') {
            # Transition from TAKEOFF to CLIMB when at safe altitude,
            # sufficient airspeed, and flaps up
            if (me.props.agl.getValue() > 300
                and me.props.airspeed.getValue() > 150
                and me.props.flaps.getValue() < 0.125)
                return 'CLIMB';
        }
        elsif (phase == 'CLIMB') {
            # Transition from CLIMB to CRUISE when:
            # - cruise altitude configured and reached
            # - levelled off
            # - cruise speed reached
            var alt = me.props.agl.getValue();
            var airspeed = me.props.airspeed.getValue();
            var cruiseAlt = me.props.cruiseAlt.getValue();
            var cruiseSpeed = me.props.cruiseSpeed.getValue() or 210;
            var vspeed = me.props.vspeed.getValue() or 0;
            if (!cruiseAlt) return nil; # Cruise altitude not configured
            if (alt >= cruiseAlt - 100
                and airspeed >= cruiseSpeed - 5
                and vspeed < 100)
                return 'CRUISE';
            else
                return nil;
        }
        elsif (phase == 'CRUISE') {
            # Transition from CRUISE to DESCENT to be performed manually
            return nil;
        }
        elsif (phase == 'DESCENT') {
            # DESCENT -> APPROACH:
            # - flaps set to APPR
            # OR:
            # - destination runway configured
            # - within 10 miles from touchdown
            if (me.props.flaps.getValue() >= 0.375) return 'APPROACH';
            if (me.props.destination.getValue() == '') return nil;
            if (me.props.distanceRemaining.getValue() < 10) return 'APPROACH';
            return nil;
        }
        elsif (phase == 'APPROACH') {
            # APPROACH -> LANDING:
            # - Landing flaps set
            # OR
            # - Below 500 ft AGL
            if (me.props.flaps.getValue() >= 0.875 or
                me.props.agl.getValue() < 500)
                return 'LANDING';
            else
                return nil;
        }
        elsif (phase == 'LANDING') {
            # Check for go-around
            var allEnginesTOGA = 1;
            for (var e = 0; e < 4; e += 1) {
                if (me.props.throttle[e].getValue() < 0.9 or
                    me.props.reverser[e].getBoolValue() or
                    !me.props.engineRunning[e].getBoolValue()) {
                    allEnginesTOGA = 0;
                    break;
                }
            }
            if (allEnginesTOGA)
                return 'TAKEOFF';
            if (me.props.groundspeed.getValue() < 40)
                return 'TAXI-OUT';
            return nil;
        }
        else {
            return nil;
        }
    },
};

var makeFlightEngineer = func {
    var worker = Worker.new();
    worker.addJob(FlightEngineerMasterJob.new(worker));
    return worker;
};

var makeFirstOfficer = func {
    var worker = Worker.new();
    worker.addJob(FirstOfficerMasterJob.new(worker));
    return worker;
};

var makeAutoFlightPhaseWorker = func {
    var worker = Worker.new();
    worker.addJob(AutoFlightPhaseJob.new(worker));
    return worker;
};

var crew = Crew.new();
crew.addWorker(makeFlightEngineer());
crew.addWorker(makeFirstOfficer());
crew.addWorker(makeAutoFlightPhaseWorker());
