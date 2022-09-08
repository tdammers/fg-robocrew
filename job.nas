var BaseJob = {
    new: func (masterSwitchProp, reportOutputProp=nil) {
        return {
            parents: [BaseJob],
            masterSwitchProp: propify(masterSwitchProp),
            reportOutputProp: propify(reportOutputProp),
        };
    },

    start: func {},
    stop: func {},
    finished: func { return 0; },
    update: func (dt) {},
    report: func () {},
    
    tick: func (dt) {
        if (me.masterSwitchProp == nil) {
            print('Master switch prop not set');
        }
        if (me.masterSwitchProp.getBoolValue()) {
            me.update(dt);
            if (me.reportOutputProp != nil) {
                me.reportOutputProp.setValue(me.report());
            }
        }
        else {
            if (me.reportOutputProp != nil) {
                me.reportOutputProp.setValue('---');
            }
        }
    },
};

var ReportingJob = {
    new: func (controlProp, makeReport) {
        var m = BaseJob.new(controlProp.getChild('input'), controlProp.getChild('status'));
        m.parents = [ReportingJob] ~ m.parents;
        m.makeReport = makeReport;
        return m;
    },

    report: func {
        return me.makeReport();
    },
};

var TriggerJob = {
    new: func (controlProp, action, setCondition = nil, resetCondition = nil, isSet = 0) {
        var m = BaseJob.new(controlProp.getChild('input'), controlProp.getChild('status'));
        m.parents = [TriggerJob] ~ m.parents;
        m.setCondition = setCondition;
        m.resetCondition = resetCondition;
        m.isSet = isSet;
        m.action = action;
        return m;
    },

    report: func () {
        return 'OK';
    },

    update: func (dt) {
        if (me.isSet and typeof(me.resetCondition) == 'func' and me.resetCondition()) {
            printf("turn off");
            me.action(0);
            me.isSet = 0;
        }
        elsif (!me.isSet and typeof(me.setCondition) == 'func' and me.setCondition()) {
            printf("turn on");
            me.action(1);
            me.isSet = 1;
        }
    },
};

var PropertySetJob = {
    new: func (masterSwitchProp, targetProp, targetValue, easeRate=nil) {
        var m = BaseJob.new(masterSwitchProp);
        m.parents = [PropertySetJob] ~ m.parents;
        m.targetProp = propify(targetProp);
        m.targetValue = targetValue;
        m.easeRate = easeRate;
        return m;
    },

    update: func (dt) {
        if (me.easeRate == nil)
            me.targetProp.setValue(me.targetValue);
        else {
            var current = me.targetProp.getValue() or 0;
            if (current > me.targetValue)
                current = math.max(me.targetValue, current - me.easeRate * dt);
            elsif (current < me.targetValue)
                current = math.min(me.targetValue, current + me.easeRate * dt);
            me.targetProp.setValue(current);
        }
    },
};

var PropertyTargetJob = {
    new: func (masterSwitchProp, targetProp, targetValue, outputProp, p, i=0, d=0, stepSize=nil, easeRate=1) {
        var m = BaseJob.new(masterSwitchProp);
        m.parents = [PropertyTargetJob] ~ m.parents;
        m.targetProp = propify(targetProp);
        m.targetValue = targetValue;
        m.currentTargetValue = m.targetProp.getValue();
        m.outputProp = propify(outputProp);
        m.stepSize = stepSize;
        m.p = p;
        m.i = i;
        m.d = d;
        m.lastError = 0;
        m.easeRate = easeRate;
        m.engaged = 0;
        return m;
    },

    update: func (dt) {
        var value = me.targetProp.getValue() or 0;
        var targetValue = (typeof(me.targetValue) == 'func') ? (me.targetValue()) : (me.targetValue);
        if (targetValue == nil) {
            me.engaged = 0;
        }
        else {
            me.engaged = 1;
            if (me.currentTargetValue > targetValue) {
                me.currentTargetValue = math.max(targetValue, me.currentTargetValue - me.easeRate * dt);
            }
            elsif (me.currentTargetValue < targetValue) {
                me.currentTargetValue = math.min(targetValue, me.currentTargetValue + me.easeRate * dt);
            }
            var error = value - me.currentTargetValue;
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
        }
    },
};

var MaximizePropertyJob = {
    new: func (masterSwitchProp, targetProp, outputProp, stepSize, stepInterval = 1.0, waitInterval = 30) {
        var m = BaseJob.new(masterSwitchProp);
        m.parents = [MaximizePropertyJob] ~ m.parents;
        m.targetProp = propify(targetProp);
        m.outputProp = propify(outputProp);
        m.stepSize = stepSize;
        m.lastValue = 0;
        m.stepMade = 0;
        m.phase = 0;
        m.phaseCounter = 0;
        m.stepInterval = stepInterval;
        m.waitInterval = waitInterval;
        return m;
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
        me.phaseCounter -= dt;
        if (me.phaseCounter <= 0) {
            var value = me.targetProp.getValue();
            if (me.phase == 1) {
                # WAIT phase
                me.phase = 0;
                me.phaseCounter = me.stepInterval;
                me.initialValue = value;
                me.stepMade = 0;
            }
            elsif (me.phase == 0) {
                # UP phase
                if (value < me.lastValue and me.stepMade) {
                    me.outputProp.setValue(me.outputProp.getValue() - me.stepSize);
                    me.phase = 1;
                    me.phaseCounter = me.waitInterval;
                    me.stepMade = 0;
                }
                else {
                    me.outputProp.setValue(me.outputProp.getValue() + me.stepSize);
                    me.phaseCounter = me.stepInterval;
                    me.stepMade = 1;
                }
            }
            me.lastValue = value;
        }
    },
};

var MasterJob = {
    new: func (worker) {
        return {
            parents: [MasterJob],
            listener: nil,
            jobs: [],
            worker: worker,
        };
    },

    finished: func { return 0; },

    loadJobs: func (phase) {
    },

    start: func {
        me.listener = setlistener(rcprops.flightPhase, func (node) {
            var phase = node.getValue();
            me.removeAllJobs();
            var crewMembers = props.globals.getNode('robocrew/crew').getChildren();
            foreach (var role; crewMembers) {
                foreach (var control; role.getChildren('control')) {
                    control.setValue('status', '---');
                }
            }
            me.loadJobs(phase);
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
        var jobID = me.worker.addJob(job);
        append(me.jobs, jobID);
        return jobID;
    },

    removeAllJobs: func {
        foreach (var jobID; me.jobs) {
            me.worker.removeJob(jobID);
        }
        me.jobs = [];
    },

    removeJob: func (jobID) {
        var i = find(jobID, me.jobs);
        if (i >= 0) {
            me.worker.removeJob(jobID);
            me.jobs = subvec(me.jobs, 0, i) ~ subvec(me.jobs, i+1);
        }
    },

    tick: func (dt) {},
};
