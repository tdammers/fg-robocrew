var dirname = '';

(func () {
    dirname = io.dirname(caller()[2]);
})();

var playSound = func (file, volume=0.75) {
    print(dirname);
    fgcommand("play-audio-sample", props.Node.new({
        # path: dirname ~ 'Sounds/',
        path: getprop('/sim/aircraft-dir') ~ '/Sounds';
        file: '80kt.wav',
        volume: 1.0,
    }));
};
