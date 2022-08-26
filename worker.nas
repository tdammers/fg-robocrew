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
            job.tick(dt);
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

