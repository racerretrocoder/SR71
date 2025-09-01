var spacehold = func{
setprop("position/altitude-ft", 500000);
setprop("velocities/mach", 28);
}

sph_timer = maketimer(0.0001, spacehold);

var hold = func{
    sph_timer.start();
    screen.log.write("Feel free to turn off your engines with } :)");
}

var stophold = func{
    sph_timer.stop();
}


