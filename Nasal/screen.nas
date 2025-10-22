var ap = func() {
    # enable autopilot. 
    setprop("autopilot/locks/heading","wing-leveler");
    setprop("autopilot/locks/altitude","pitch-hold");
    setprop("autopilot/settings/heading-bug-deg",0);
    setprop("autopilot/settings/target-pitch-deg",0); 
}

var prograde = func() {
    # enable autopilot. 
    setprop("autopilot/locks/heading","wing-leveler");
    setprop("autopilot/locks/altitude","vertical-speed-hold");
    setprop("autopilot/settings/heading-bug-deg",0);
    setprop("autopilot/settings/target-pitch-deg",0); 
}

var retrograde = func() {
    # enable autopilot. 
    setprop("autopilot/locks/heading","wing-leveler");
    setprop("autopilot/locks/altitude","pitch-hold");
    setprop("autopilot/settings/heading-bug-deg",180);
    setprop("autopilot/settings/target-pitch-deg",0); 
}

var up = func() {
    # enable autopilot. 
    setprop("autopilot/locks/altitude","pitch-hold");
    var old = getprop("autopilot/settings/target-pitch-deg"); 
    setprop("autopilot/settings/target-pitch-deg",old + 10); 
}

var dn = func() {
    # enable autopilot. 
    setprop("autopilot/locks/altitude","pitch-hold");
    var old = getprop("autopilot/settings/target-pitch-deg"); 
    setprop("autopilot/settings/target-pitch-deg",old - 10); 
}

var left = func() {
    # enable autopilot. 
    setprop("autopilot/locks/heading","wing-leveler");
    setprop("autopilot/settings/heading-bug-deg",-90);
}

var right = func() {
    # enable autopilot. 
    setprop("autopilot/locks/heading","wing-leveler");
    setprop("autopilot/settings/heading-bug-deg",90);
}


var orbitauto = func() {
    if (getprop("position/altitude-ft") > 5000) {
        screen.log.write("Begining auto orbi! Do not touch the flight controls until it has completed!");
        orbit.orbitauto.start();
    } else {
        screen.log.write("The spaceplane must be above 5000ft MSL, and it must be level in order to use the auto orbit system!");
    }
}