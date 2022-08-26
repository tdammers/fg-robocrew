var dt = 0.1;

var Crew = {
    new: func () {
        return {
            parents: [Crew],
            workers: [],
            timer: nil,
        };
    },

    addWorker: func (worker) {
        append(me.workers, worker);
    },

    init: func {
        var self = me;
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

