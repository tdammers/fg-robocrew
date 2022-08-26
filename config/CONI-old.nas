var crewProps = {
    'flightEngineer': globals.robocrew.rcprops.crew.getNode('flight-engineer[0]', 1),
};

crewProps.flightEngineer.setValue('name', 'Flight Engineer');

var controlProps = {
    flightEngineer: {},
};

controlProps.flightEngineer.throttle = crewProps.flightEngineer.getNode('control[0]', 1);
controlProps.flightEngineer.throttle.setValue('name', 'Throttle Control');
controlProps.flightEngineer.throttle.setValue('type', 'checkbox');
controlProps.flightEngineer.throttle.setValue('input', 1);
controlProps.flightEngineer.throttle.setValue('status', 'OK');

controlProps.flightEngineer.mixture = crewProps.flightEngineer.getNode('control[1]', 1);
controlProps.flightEngineer.mixture.setValue('name', 'Mixture Control');
controlProps.flightEngineer.mixture.setValue('type', 'checkbox');
controlProps.flightEngineer.mixture.setValue('input', 1);
controlProps.flightEngineer.mixture.setValue('status', 'OK');

controlProps.flightEngineer.rpm = crewProps.flightEngineer.getNode('control[2]', 1);
controlProps.flightEngineer.rpm.setValue('name', 'RPM Control');
controlProps.flightEngineer.rpm.setValue('type', 'checkbox');
controlProps.flightEngineer.rpm.setValue('input', 1);
controlProps.flightEngineer.rpm.setValue('status', 'OK');

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

var Worker = {
    new: func {
        return {
            parents: [Worker],
            jobs: {},
            nextJobID: 1,
        };
    },

    addJob: func (job) {
        var jobID = me.nextJobID;
        me.nextJobID += 1;
        me.jobs[jobID] = job;
        job.start();
        return jobID;
    },

    removeJob: func (jobID) {
        if (contains(me.jobs, jobID)) {
            me.jobs[jobID].stop();
            delete(me.jobs, jobID);
        }
    },

    update: func (dt) {
        foreach (var k; keys(me.jobs)) {
            var job = me.jobs[k];
            job.update(dt);
            if (job.finished()) {
                me.removeJob(k);
            }
        }
    },

    removeAllJobs: func {
        foreach (var k; keys(me.jobs)) {
            me.removeJob(k);
        }
    },
};

var FuelWatchJob = {
    new: func {
        return {
            parents: [FuelWatchJob],
            tankProps: {
                tank1: props.globals.getNode('consumables/fuel/tank[4]/level-lbs'),
                tank2: props.globals.getNode('consumables/fuel/tank[5]/level-lbs'),
                tank3: props.globals.getNode('consumables/fuel/tank[6]/level-lbs'),
                tank4: props.globals.getNode('consumables/fuel/tank[7]/level-lbs'),
                tankCenter: props.globals.getNode('consumables/fuel/tank[8]/level-lbs'),
                tank1A: props.globals.getNode('consumables/fuel/tank[9]/level-lbs'),
                tank2A: props.globals.getNode('consumables/fuel/tank[10]/level-lbs'),
                tank3A: props.globals.getNode('consumables/fuel/tank[11]/level-lbs'),
                tank4A: props.globals.getNode('consumables/fuel/tank[12]/level-lbs'),
            },
            valveProps: {
                cross1: props.globals.getNode('controls/fuel/crossfeedvalve[0]'),
                cross2: props.globals.getNode('controls/fuel/crossfeedvalve[1]'),
                cross3: props.globals.getNode('controls/fuel/crossfeedvalve[2]'),
                cross4: props.globals.getNode('controls/fuel/crossfeedvalve[3]'),
                tank1: props.globals.getNode('controls/fuel/tankvalve[0]'),
                tank2: props.globals.getNode('controls/fuel/tankvalve[1]'),
                tank3: props.globals.getNode('controls/fuel/tankvalve[2]'),
                tank4: props.globals.getNode('controls/fuel/tankvalve[3]'),
                tankCenter: props.globals.getNode('controls/fuel/tankvalve[4]'),
            },
        };
    },

    start: func { },
    stop: func { },
    finished: func { return 0; },
    update: func (dt) {
        if (!controlProps.flightEngineer.fuel.getValue('input')) {
            controlProps.flightEngineer.fuel.setValue('status', 'OFF');
            return;
        }

        var eng1total = me.tankProps.tank1.getValue() + me.tankProps.tank1A.getValue();
        var eng2total = me.tankProps.tank2.getValue() + me.tankProps.tank2A.getValue();
        var eng3total = me.tankProps.tank3.getValue() + me.tankProps.tank3A.getValue();
        var eng4total = me.tankProps.tank4.getValue() + me.tankProps.tank4A.getValue();
        var diff12 = eng1total - eng2total;
        var diff43 = eng4total - eng3total;
        var centerLevel = me.tankProps.tankCenter.getValue();

        var usingCenter = 0;
        var crossfeeding = '';

        if (centerLevel > 200) {
            # Allow feeding from center tank
            me.valveProps.tankCenter.setValue(1);
            usingCenter = 1;

            # If tank 1 has substantially more fuel than tanks 2, set engine 1
            # to feed from tank 1, and engine 2 from center
            if (diff12 > 100) {
                me.valveProps.tank1.setValue(1);
                me.valveProps.cross1.setValue(0);
                me.valveProps.cross2.setValue(1);
                me.valveProps.tank2.setValue(0);
                crossfeeding ~= '2';
            }
            else {
                # Feed both 1 and 2 from center
                me.valveProps.cross1.setValue(1);
                me.valveProps.cross2.setValue(1);
                me.valveProps.tank1.setValue(0);
                me.valveProps.tank2.setValue(0);
                crossfeeding ~= '12';
            }

            # If tank 4 has substantially more fuel than tanks 3, set engine 4
            # to feed from tank 4, and engine 3 from center
            if (diff43 > 100) {
                me.valveProps.tank4.setValue(1);
                me.valveProps.cross4.setValue(0);
                me.valveProps.cross3.setValue(1);
                me.valveProps.tank3.setValue(0);
                crossfeeding ~= '4';
            }
            else {
                # Feed both 4 and 3 from center
                me.valveProps.cross4.setValue(1);
                me.valveProps.cross3.setValue(1);
                me.valveProps.tank4.setValue(0);
                me.valveProps.tank3.setValue(0);
                crossfeeding ~= '34';
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
            usingCenter = 1;
            crossfeeding = 'ALL';
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
            crossfeeding = 'OFF';
        }

        status = 'XF ' ~ crossfeeding;
        if (usingCenter) status ~= ', USING CTR';

        controlProps.flightEngineer.fuel.setValue('status', status);
    },
};

var ReportingJob = {
    new: func (controlProp, makeReport) {
        return {
            parents: [ReportingJob],
            controlProp: controlProp,
            makeReport: makeReport,
        };
    },

    start: func {},
    stop: func {},

    update: func (dt) {
        if (me.controlProp.getValue('input'))
            me.controlProp.setValue('status', 
                typeof(me.makeReport == 'func') ? me.makeReport() : 'ON');
        else
            me.controlProp.setValue('status', 'OFF');
    },

    finished: func { return 0; },
};

var PropertySetJob = {
    new: func (targetProp, targetValue, controlProp) {
        return {
            parents: [PropertySetJob],
            targetProp: props.globals.getNode(targetProp),
            targetValue: targetValue,
            controlProp: controlProp,
        };
    },

    start: func {
        printf("Start %s -> %0.3f", me.targetProp.getPath(), me.targetValue);
    },

    stop: func {
        printf("Stop %s -> %0.3f", me.targetProp.getPath(), me.targetValue);
    },

    update: func (dt) {
        if (!me.controlProp.getValue('input'))
            return;
        me.targetProp.setValue(me.targetValue);
    },

    finished: func {
        return 0;
    },
};

var PropertyTargetJob = {
    new: func (targetProp, targetValue, outputProp, controlProp, p, i=0, d=0, stepSize=nil) {
        return {
            parents: [PropertyTargetJob],
            targetProp: props.globals.getNode(targetProp),
            outputProp: props.globals.getNode(outputProp),
            controlProp: controlProp,
            targetValue: targetValue,
            stepSize: stepSize,
            p: p,
            i: i,
            d: d,
            lastError: 0,
        };
    },

    start: func {
        printf("Start %s -> %0.3f", me.targetProp.getPath(), me.targetValue);
    },

    stop: func {
        printf("Stop %s -> %0.3f", me.targetProp.getPath(), me.targetValue);
    },

    update: func (dt) {
        if (!me.controlProp.getValue('input'))
            return;
        var value = me.targetProp.getValue() or 0;
        var error = value - me.targetValue;
        var errorIntegral = (me.lastError + error) * 0.5 / dt;
        var errorDerivative = (error - me.lastError) / dt;
        var correction = (error * me.p + errorIntegral * me.i + errorDerivative * me.d) * dt;
        me.lastError = error;
        if (me.stepSize != nil)
            correction = math.round(correction / me.stepSize) * me.stepSize;
        var controlValue = me.outputProp.getValue() or 0;
        controlValue = math.min(1.0, math.max(-1.0, controlValue + correction));
        me.outputProp.setValue(controlValue);
        # printf("Update %s; v = %0.3f, e = %0.3f, ei = %0.3f, ed = %0.3f, delta = %0.3f",
        #    me.targetProp.getPath(),
        #    value, error, errorIntegral, errorDerivative, correction);
        # printf("    set %s = %0.3f", me.outputProp.getPath(), controlValue);
    },

    finished: func {
        return 0;
    },
};

var MaximizePropertyJob = {
    new: func (targetProp, outputProp, controlProp, stepSize, stepInterval = 1.0, waitInterval = 30) {
        return {
            parents: [MaximizePropertyJob],
            targetProp: props.globals.getNode(targetProp),
            outputProp: props.globals.getNode(outputProp),
            controlProp: controlProp,
            stepSize: stepSize,
            lastValue: 0,
            stepMade: 0,
            phase: 0,
            phaseCounter: 0,
            stepInterval: stepInterval,
            waitInterval: waitInterval,
        };
    },

    # Algorithm:
    # - 'UP' stage (0): increase control until target decreases, then decrease
    #   one step and proceed to WAIT.
    # - 'WAIT' stage (1): wait for waitInterval seconds, then proceed to UP.

    start: func {
        me.lastValue = me.targetProp.getValue();
        me.phase = 0;
        me.phaseCounter = 0;
        me.stepMade = 0;
    },

    stop: func {},
    finished: func 0,

    update: func (dt) {
        if (!me.controlProp.getValue('input'))
            return;
        me.phaseCounter -= dt;
        if (me.phaseCounter <= 0) {
            var value = me.targetProp.getValue();
            if (me.phase == 1) {
                # WAIT phase
                print("Checking mixture");
                me.phase = 0;
                me.phaseCounter = me.stepInterval;
                me.initialValue = value;
                me.stepMade = 0;
            }
            elsif (me.phase == 0) {
                # UP phase
                if (value < me.lastValue and me.stepMade) {
                    printf("Mixture: %f < %f", value, me.lastValue);
                    me.outputProp.setValue(me.outputProp.getValue() - me.stepSize);
                    me.phase = 1;
                    me.phaseCounter = me.waitInterval;
                    me.stepMade = 0;
                }
                else {
                    printf("Mixture: %f > %f", value, me.lastValue);
                    me.outputProp.setValue(me.outputProp.getValue() + me.stepSize);
                    me.phaseCounter = me.stepInterval;
                    me.stepMade = 1;
                }
            }
            me.lastValue = value;
        }
    },
};

var maintainMP = func (e, targetMP) {
    return
        PropertyTargetJob.new(
            '/engines/engine[' ~ e ~ ']/mp-inhg',
            targetMP,
            '/controls/engines/engine[' ~ e ~ ']/throttle',
            controlProps.flightEngineer.throttle,
            -0.01, -0.0002, -0.01);
};

var reportMP = func (targetMP) {
    return
        ReportingJob.new(
            controlProps.flightEngineer.throttle,
            func {
                if (targetMP == nil) {
                    return 'PILOTS HAVE CONTROL';
                }
                else {
                    var report = sprintf("T: %2.1f", targetMP);
                    for (var e = 0; e < 4; e +=1 ) {
                        report ~= sprintf("; #%i=%2.1f", e + 1,
                            getprop('/engines/engine[' ~ e ~ ']/mp-inhg'));
                        if (getprop('/fdm/jsbsim/propulsion/engine[' ~ e  ~ ']/boost-speed'))
                            report ~= '[L]';
                        else
                            report ~= '[H]';
                    }
                    return report;

                    return sprintf('T: %2.1f #1=%2.1f #2=%2.1f #3=%2.1f #4=%2.1f',
                        targetMP,
                        getprop('/engines/engine[0]/mp-inhg'),
                        getprop('/engines/engine[1]/mp-inhg'),
                        getprop('/engines/engine[2]/mp-inhg'),
                        getprop('/engines/engine[3]/mp-inhg'));
                }
            });
};

var maintainCHT = func (e, targetTemp) {
    return
        PropertyTargetJob.new(
            '/engines/engine[' ~ e ~ ']/cht-degf',
            targetTemp,
            '/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm',
            controlProps.flightEngineer.cowlFlaps,
            0.01, 0.01, 0.1, 0.1);
};

var reportCHT = func (targetCHT) {
    return
        ReportingJob.new(
            controlProps.flightEngineer.cowlFlaps,
            func {
                var report = sprintf("T: %3.0f", targetCHT);
                for (var e = 0; e < 4; e +=1 ) {
                    report ~= sprintf("; #%i=%3.0f/%i", e + 1,
                        getprop('/engines/engine[' ~ e ~ ']/cht-degf'),
                        getprop('/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm') * 100);
                }
                return report;
            });
};

var reportMixture = func () {
    return
        ReportingJob.new(
            controlProps.flightEngineer.mixture,
            func {
                var report = '';
                for (var e = 0; e < 4; e +=1 ) {
                    report ~= sprintf("#%i=%3.0f/%1.0f%% ", e + 1,
                        getprop('/engines/engine[' ~ e ~ ']/bmep'),
                        getprop('/controls/engines/engine[' ~ e ~ ']/mixture') * 100);
                }
                return report;
            });
};

var reportRPM = func (targetRPM) {
    return
        ReportingJob.new(
            controlProps.flightEngineer.rpm,
            func {
                var report = sprintf("T: %s", targetRPM);
                for (var e = 0; e < 4; e +=1 ) {
                    report ~= sprintf("; #%i=%4.0f", e + 1,
                        getprop('/engines/engine[' ~ e ~ ']/rpm'));
                }
                return report;
            });
};

var leanToPeak = func (e) {
    return
        MaximizePropertyJob.new(
            '/engines/engine[' ~ e ~ ']/bmep',
            '/controls/engines/engine[' ~ e ~ ']/mixture',
            controlProps.flightEngineer.mixture,
            -0.025);
};

var enrichToPeak = func (e) {
    return
        MaximizePropertyJob.new(
            '/engines/engine[' ~ e ~ ']/bmep',
            '/controls/engines/engine[' ~ e ~ ']/mixture',
            controlProps.flightEngineer.mixture,
            0.025);
};

var manageFuel = func () {
    return
        FuelWatchJob.new();
};

var makeFlightEngineer = func {
    var worker = Worker.new();

    var MasterJob = {
        new: func {
            return {
                parents: [MasterJob],
                listener: nil,
                jobs: [],
            };
        },

        finished: func { return 0; },

        start: func {
            me.listener = setlistener(rcprops.flightPhase, func (node) {
                var phase = node.getValue();
                me.removeAllJobs();
                foreach (var k; keys(controlProps.flightEngineer)) {
                    controlProps.flightEngineer[k].setValue('status', 'OFF');
                }
                if (phase == 'PREFLIGHT') {
                    foreach (var e; [0,1,2,3]) {
                        # cowl flaps: 100%
                        me.addJob(PropertySetJob.new(
                            '/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm',
                            1.0,
                            controlProps.flightEngineer.cowlFlaps));
                        me.addJob(PropertySetJob.new(
                            '/controls/engines/engine[' ~ e ~ ']/mixture',
                            -1.0,
                            controlProps.flightEngineer.mixture));
                        # blower: low
                        me.addJob(PropertySetJob.new(
                            '/fdm/jsbsim/propulsion/engine[' ~ e ~ ']/boost-speed',
                            0,
                            controlProps.flightEngineer.throttle));
                        # Fuel selectors: wing tanks, crossfeed off, center off
                        me.addJob(PropertySetJob.new(
                            '/controls/fuel/tankvalve[' ~ e ~ ']',
                            1,
                            controlProps.flightEngineer.fuel));
                        me.addJob(PropertySetJob.new(
                            '/controls/fuel/crossfeedvalve[' ~ e ~ ']',
                            0,
                            controlProps.flightEngineer.fuel));
                    }
                    me.addJob(PropertySetJob.new(
                        '/controls/fuel/tankvalve[4]',
                        0,
                        controlProps.flightEngineer.fuel));

                    # pitch: full fwd
                    me.addJob(PropertySetJob.new(
                        '/controls/engines/propeller-pitch-all',
                        -1.0,
                        controlProps.flightEngineer.rpm));
                }
                elsif (phase == 'TAKEOFF') {
                    foreach (var e; [0,1,2,3]) {
                        # cowl flaps: 100%
                        me.addJob(PropertySetJob.new(
                            '/controls/engines/engine[' ~ e ~ ']/cowl-flaps-norm',
                            1.0,
                            controlProps.flightEngineer.cowlFlaps));
                        me.addJob(PropertySetJob.new(
                            '/controls/engines/engine[' ~ e ~ ']/mixture',
                            -1.0,
                            controlProps.flightEngineer.mixture));
                        # blower: low
                        me.addJob(PropertySetJob.new(
                            '/fdm/jsbsim/propulsion/engine[' ~ e ~ ']/boost-speed',
                            0,
                            controlProps.flightEngineer.throttle));
                        # Fuel selectors: wing tanks, crossfeed off, center off
                        me.addJob(PropertySetJob.new(
                            '/controls/fuel/tankvalve[' ~ e ~ ']',
                            1,
                            controlProps.flightEngineer.fuel));
                        me.addJob(PropertySetJob.new(
                            '/controls/fuel/crossfeedvalve[' ~ e ~ ']',
                            0,
                            controlProps.flightEngineer.fuel));
                    }
                    me.addJob(PropertySetJob.new(
                        '/controls/fuel/tankvalve[4]',
                        0,
                        controlProps.flightEngineer.fuel));
                    me.addJob(reportMP(56.5));
                    foreach (var e; [0, 1, 2, 3]) {
                        me.addJob(maintainMP(e, 56.5));

                    }
                    # Maintain 2900 RPM (-0.95)
                    me.addJob(PropertySetJob.new(
                        '/controls/engines/propeller-pitch-all',
                        -0.95,
                        controlProps.flightEngineer.rpm));
                    me.addJob(reportRPM(2900));
                    me.addJob(reportMixture());
                }
                elsif (phase == 'CLIMB') {
                    me.addJob(reportMP(48));
                    me.addJob(reportCHT(490));
                    foreach (var e; [0, 1, 2, 3]) {
                        me.addJob(maintainMP(e, 48));
                        me.addJob(maintainCHT(e, 490));
                        me.addJob(manageFuel());
                        me.addJob(leanToPeak(e));
                        (func (ee) {
                            me.addJob({
                                start: func {},
                                stop: func {},
                                finished: func 0,
                                update: func (dt) {
                                    var alt = getprop('/instrumentation/altimeter/indicated-altitude-ft') or 0;
                                    var blower = getprop('/fdm/jsbsim/propulsion/engine[' ~ ee ~ ']/boost-speed') or 0;
                                    if (alt > 9000.0 and blower == 0) {
                                        setprop('/controls/engines/engine[' ~ ee ~ ']/throttle', 0.5);
                                        setprop('/fdm/jsbsim/propulsion/engine[' ~ ee ~ ']/boost-speed', 1);
                                    }
                                },
                            });
                        })(e);
                    }
                    # Maintain 2600 RPM (-0.6)
                    setprop('/controls/engines/propeller-pitch-all', -0.6);
                    me.addJob(reportRPM(2600));
                    me.addJob(reportMixture());
                }
                elsif (phase == 'CRUISE') {
                    foreach (var e; [0, 1, 2, 3]) {
                        me.addJob(maintainMP(e, 48));
                        me.addJob(maintainCHT(e, 480));
                        me.addJob(manageFuel());
                    }
                    me.addJob(reportMP(48));
                    me.addJob(reportCHT(480));
                    me.addJob(reportMixture());
                    # Maintain 2300 RPM (-0.2)
                    setprop('/controls/engines/propeller-pitch-all', -0.2);
                    me.addJob(reportRPM(2300));
                }
                elsif (phase == 'DESCENT') {
                    me.addJob(reportMP(nil));
                    # pitch: full fwd
                    setprop('/controls/engines/propeller-pitch-all', -1.0);
                    me.addJob(reportRPM('FULL'));
                    # Don't touch throttles (pilot manages throttle)
                    # When passing FL90: Blower LOW
                    me.addJob(reportMixture());
                    foreach (var e; [0, 1, 2, 3]) {
                        me.addJob(enrichToPeak(e));
                        (func (ee) {
                            me.addJob({
                                start: func {},
                                stop: func {},
                                finished: func 0,
                                update: func (dt) {
                                    var alt = getprop('/instrumentation/altimeter/indicated-altitude-ft') or 0;
                                    var blower = getprop('/fdm/jsbsim/propulsion/engine[' ~ ee ~ ']/boost-speed') or 0;
                                    if (alt < 9000.0 and blower == 1) {
                                        setprop('/fdm/jsbsim/propulsion/engine[' ~ ee ~ ']/boost-speed', 0);
                                    }
                                },
                            });
                        })(e);
                    }
                    me.addJob(manageFuel());
                }
                elsif (phase == 'APPROACH') {
                    me.addJob(reportMP(nil));

                    # mixture: full rich
                    setprop('/controls/engines/mixture-all', -1.0);
                    # pitch: full fwd
                    setprop('/controls/engines/propeller-pitch-all', -1.0);
                    me.addJob(reportRPM('FULL'));
                    me.addJob(reportMixture());

                    # Cowl flaps 100%
                    setprop('/controls/engines/engine[0]/cowl-flaps-norm', 1.0);
                    setprop('/controls/engines/engine[1]/cowl-flaps-norm', 1.0);
                    setprop('/controls/engines/engine[2]/cowl-flaps-norm', 1.0);
                    setprop('/controls/engines/engine[3]/cowl-flaps-norm', 1.0);

                    # Set up fuel for landing
                    setprop('controls/fuel/tankvalve[0]', 1);
                    setprop('controls/fuel/tankvalve[1]', 1);
                    setprop('controls/fuel/tankvalve[2]', 1);
                    setprop('controls/fuel/tankvalve[3]', 1);
                    setprop('controls/fuel/crossfeedvalve[0]', 0);
                    setprop('controls/fuel/crossfeedvalve[1]', 0);
                    setprop('controls/fuel/crossfeedvalve[2]', 0);
                    setprop('controls/fuel/crossfeedvalve[3]', 0);
                    setprop('controls/fuel/tankvalve[4]', 0);
                }
                elsif (phase == 'LANDING') {
                }
                elsif (phase == 'TAXI-IN') {
                }
                elsif (phase == 'SHUTDOWN') {
                }
            }, 1, 0);
        },

        stop: func {
            me.removeAllJobs();
            if (me.listener != nil) {
                removelistener(me.listener);
                me.listener = nil;
            }
        },

        addJob: func (job) {
            var jobID = worker.addJob(job);
            append(me.jobs, jobID);
            return jobID;
        },

        removeAllJobs: func {
            foreach (var jobID; me.jobs) {
                worker.removeJob(jobID);
            }
            me.jobs = [];
        },

        removeJob: func (jobID) {
            var i = find(jobID, me.jobs);
            if (i >= 0) {
                worker.removeJob(jobID);
                me.jobs = subvec(me.jobs, 0, i) ~ subvec(me.jobs, i+1);
            }
        },

        update: func (dt) {},
    };

    worker.addJob(MasterJob.new());

    return worker;
};

var workers = [];
var dt = 0.1;
var timer = maketimer(dt, func {
    foreach (var worker; workers) {
        worker.update(dt);
    }
});
timer.simulatedTime = 1;

var crew = {
    init: func {
        print("Constellation crew init");
        append(workers, makeFlightEngineer());
        timer.start();
    },

    teardown: func {
        print("Constellation crew teardown");
        timer.stop();
        foreach (var worker; workers) {
            worker.removeAllJobs();
        }
        workers = [];
    },
};
