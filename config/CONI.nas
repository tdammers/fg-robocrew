var crewProps = {
    'flightEngineer': globals.robocrew.rcprops.crew.getNode('flight-engineer[0]', 1),
};

crewProps.flightEngineer.setValue('name', 'Flight Engineer');

var controlProps = {
    flightEngineer: {},
};

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

var FuelManagementJob = {
    new: func (commandProp) {
        var m = BaseJob.new(commandProp.getChild('input'), commandProp.getChild('status'));
        m.parents = [FuelManagementJob] ~ m.parents;
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
            cross1: props.globals.getNode('controls/fuel/crossfeedvalve[0]'),
            cross2: props.globals.getNode('controls/fuel/crossfeedvalve[1]'),
            cross3: props.globals.getNode('controls/fuel/crossfeedvalve[2]'),
            cross4: props.globals.getNode('controls/fuel/crossfeedvalve[3]'),
            tank1: props.globals.getNode('controls/fuel/tankvalve[0]'),
            tank2: props.globals.getNode('controls/fuel/tankvalve[1]'),
            tank3: props.globals.getNode('controls/fuel/tankvalve[2]'),
            tank4: props.globals.getNode('controls/fuel/tankvalve[3]'),
            tankCenter: props.globals.getNode('controls/fuel/tankvalve[4]'),
        };
        m.crossfeeding = '';
        m.usingCenter = 0;
        return m;
    },

    update: func (dt) {
        var eng1total = me.tankProps.tank1.getValue() + me.tankProps.tank1A.getValue();
        var eng2total = me.tankProps.tank2.getValue() + me.tankProps.tank2A.getValue();
        var eng3total = me.tankProps.tank3.getValue() + me.tankProps.tank3A.getValue();
        var eng4total = me.tankProps.tank4.getValue() + me.tankProps.tank4A.getValue();
        var diff12 = eng1total - eng2total;
        var diff43 = eng4total - eng3total;
        var centerLevel = me.tankProps.tankCenter.getValue();

        me.usingCenter = 0;
        me.crossfeeding = '';

        if (centerLevel > 200) {
            # Allow feeding from center tank
            me.valveProps.tankCenter.setValue(1);
            me.usingCenter = 1;

            # If tank 1 has substantially more fuel than tanks 2, set engine 1
            # to feed from tank 1, and engine 2 from center
            if (diff12 > 100) {
                me.valveProps.tank1.setValue(1);
                me.valveProps.cross1.setValue(0);
                me.valveProps.cross2.setValue(1);
                me.valveProps.tank2.setValue(0);
                me.crossfeeding ~= '2';
            }
            else {
                # Feed both 1 and 2 from center
                me.valveProps.cross1.setValue(1);
                me.valveProps.cross2.setValue(1);
                me.valveProps.tank1.setValue(0);
                me.valveProps.tank2.setValue(0);
                me.crossfeeding ~= '12';
            }

            # If tank 4 has substantially more fuel than tanks 3, set engine 4
            # to feed from tank 4, and engine 3 from center
            if (diff43 > 100) {
                me.valveProps.tank4.setValue(1);
                me.valveProps.cross4.setValue(0);
                me.valveProps.cross3.setValue(1);
                me.valveProps.tank3.setValue(0);
                me.crossfeeding ~= '4';
            }
            else {
                # Feed both 4 and 3 from center
                me.valveProps.cross4.setValue(1);
                me.valveProps.cross3.setValue(1);
                me.valveProps.tank4.setValue(0);
                me.valveProps.tank3.setValue(0);
                me.crossfeeding ~= '34';
            }
        }
        elsif (centerLevel > 10) {
            # Some fuel left in center, but just to be safe, feed engines from
            # wing tanks, too
            me.valveProps.tankCenter.setValue(1);
            me.valveProps.tank1.setValue(1);
            me.valveProps.tank2.setValue(1);
            me.valveProps.tank4.setValue(1);
            me.valveProps.tank3.setValue(1);
            me.valveProps.cross1.setValue(1);
            me.valveProps.cross2.setValue(1);
            me.valveProps.cross4.setValue(1);
            me.valveProps.cross3.setValue(1);
            me.usingCenter = 1;
            me.crossfeeding = 'ALL';
        }
        else {
            # Center tank is empty
            me.valveProps.tankCenter.setValue(0);
            me.valveProps.tank1.setValue(1);
            if (me.tankProps.tank2.getValue() > 5)
                me.valveProps.tank2.setValue(1);
            else
                me.valveProps.tank2.setValue(2);
            me.valveProps.tank4.setValue(1);
            if (me.tankProps.tank3.getValue() > 5)
                me.valveProps.tank3.setValue(1);
            else
                me.valveProps.tank3.setValue(3);
            me.valveProps.cross1.setValue(0);
            me.valveProps.cross2.setValue(0);
            me.valveProps.cross4.setValue(0);
            me.valveProps.cross3.setValue(0);
            me.crossfeeding = 'OFF';
        }
    },

    report: func {
        var status = 'XFEED ' ~ me.crossfeeding;
        if (me.usingCenter)
            status ~= ', CTR';
        return status;
    },
};

# targetMP: nil = disengage
var maintainMP = func (worker, targetMP) {
    if (targetMP != nil) {
        foreach (var e; [0,1,2,3]) {
            worker.addJob(
                PropertyTargetJob.new(
                    controlProps.flightEngineer.throttle.getChild('input'),
                    '/engines/engine[' ~ e ~ ']/mp-inhg',
                    targetMP,
                    '/controls/engines/engine[' ~ e ~ ']/throttle',
                    -0.01, -0.0002, -0.01));
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
            pitchSetting));
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


var leanToPeak = func (worker) { return manageMixture(worker, 1); };
var enrichToPeak = func (worker) { return manageMixture(worker, 0); };

var manageFuel = func (worker, mode='CRUISE') {
    if (mode == 'TAKEOFF') {
        foreach (var e; [0,1,2,3]) {
            worker.addJob(PropertySetJob.new(
                controlProps.flightEngineer.fuel.getChild('input'),
                '/controls/fuel/tankvalve[' ~ e ~ ']',
                1));
            worker.addJob(PropertySetJob.new(
                controlProps.flightEngineer.fuel.getChild('input'),
                '/controls/fuel/crossfeedvalve[' ~ e ~ ']',
                0));
        }
        worker.addJob(PropertySetJob.new(
            controlProps.flightEngineer.fuel.getChild('input'),
            '/controls/fuel/tankvalve[4]',
            0));
        worker.addJob(ReportingJob.new(
            controlProps.flightEngineer.fuel,
            func { return 'TAKEOFF'; }));
    }
    elsif (mode == 'LANDING') {
        foreach (var e; [0,1,2,3]) {
            worker.addJob(PropertySetJob.new(
                controlProps.flightEngineer.fuel.getChild('input'),
                '/controls/fuel/tankvalve[' ~ e ~ ']',
                (e == 0 or e == 3) ? 2 : 1));
            worker.addJob(PropertySetJob.new(
                controlProps.flightEngineer.fuel.getChild('input'),
                '/controls/fuel/crossfeedvalve[' ~ e ~ ']',
                0));
        }
        worker.addJob(PropertySetJob.new(
            controlProps.flightEngineer.fuel.getChild('input'),
            '/controls/fuel/tankvalve[4]',
            0));
        worker.addJob(ReportingJob.new(
            controlProps.flightEngineer.fuel,
            func { return 'APPR/LAND'; }));
    }
    else {
        worker.addJob(FuelManagementJob.new(controlProps.flightEngineer.fuel));
    }
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

var makeFlightEngineer = func {
    var worker = Worker.new();
    worker.addJob(FlightEngineerMasterJob.new(worker));
    return worker;
};

var crew = Crew.new();
crew.addWorker(makeFlightEngineer());
