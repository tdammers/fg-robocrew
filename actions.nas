var dirname = '';

(func () {
    dirname = io.dirname(caller()[2]);
})();

# dirname = getprop('/sim/fg-root');

var playSound = func (file, volume=0.75) {
    printf("%s / %s\n", dirname ~ '/Sounds/', file);
    fgcommand("play-audio-sample", props.Node.new({
        path: dirname ~ '/Sounds/',
        file: file,
        volume: 0.5,
    }));
};
