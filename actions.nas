var playSound = func (file, volume=0.75) {
    fgcommand("play-audio-sample", props.Node.new({
        path: robocrew.addonPath ~ '/Sounds/',
        file: file,
        queue: 'robocrew',
        volume: volume,
    }));
};
