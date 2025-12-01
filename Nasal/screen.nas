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


var altitude = func() {
    if (getprop("position/altitude-ft") < 125000 and getprop("position/altitude-ft") > 100000) {
        # pitch down
        screen.log.write("Pitching down!");
        setprop("autopilot/settings/target-pitch-deg",-5);
        setprop("controls/flight/speedbrake",1);
    }
    if (getprop("position/altitude-ft") < 90000) {
        setprop("controls/flight/speedbrake",0);
        setprop("autopilot/locks/altitude","");
        setprop("autopilot/locks/heading","");
        setprop("controls/flight/elevator",0);
        setprop("controls/flight/aileron",0);
        setprop("controls/flight/rudder",0);
        screen.log.write("Re-entry completed successfully! Welcome back to Earth!");
        screen.log.write("Autopilot disabled, Controls centered.");
        screen.log.write("Your controls!");
        altitudetimer.stop();
        
    }
}

var pitch = func() {
    setprop("autopilot/settings/target-pitch-deg",70);
    pitchtimer.stop();
}

var slowdown = func() {
    var periapsis = getprop("fdm/jsbsim/systems/orbital/periapsis-ft");
    if (periapsis > -9000000) {
        setprop("controls/engines/engine/throttle",1);
        setprop("controls/engines/engine[1]/throttle",1);
    } else {
        screen.log.write("Retrograde complete!");
        screen.log.write("Raising the nose to account for re-entry heating!");
        setprop("controls/engines/engine/throttle",0);
        setprop("controls/engines/engine[1]/throttle",0);
        setprop("autopilot/locks/altitude","pitch-hold-rentry");
        setprop("autopilot/settings/target-pitch-deg",40); # slowly raise the nose up to 40
        pitchtimer.start(); # wait 10 seconds before raising it up to 70
        reversethrust.togglereverser();screen.log.write("Toggling reverse thrust!");
        slowdowntimer.stop();
        altitudetimer.start(); # wait untill alt is less than 90000ft and then disable AP, center all controls
    }
}


var rentry = func() {
    var alt = getprop("position/altitude-ft");
    if (alt < 600000 and alt > 500000) {
        screen.log.write("Recomended AP: 600,000ft PE: 500,000ft");
        screen.log.write("Sit back, Relax. The flight computer will perform an automatic re-entry!");
        screen.log.write("Estimated Rentry distance: 1000NM");
        # Retrograde burn
        # Reverse the rockets
        reversethrust.togglereverser();screen.log.write("Toggling reverse thrust!");
        # increase engine power
        setprop("controls/engines/engine/throttle",1);
        setprop("controls/engines/engine[1]/throttle",1);
        screen.log.write("Slowing down!");
        slowdowntimer.start();
        
    } else {
        screen.log.write("You must be at an altituded greater than 500,000ft and less than 600,000ft. Ill bring you down anyways...");
        screen.log.write("Recomended AP: 600,000ft PE: 500,000ft");
        screen.log.write("Sit back, Relax. The flight computer will perform an automatic re-entry!");
        screen.log.write("Estimated Rentry distance: 1000NM");
        # Retrograde burn
        # Reverse the rockets
        reversethrust.togglereverser();screen.log.write("Toggling reverse thrust!");
        # increase engine power
        setprop("controls/engines/engine/throttle",1);
        setprop("controls/engines/engine[1]/throttle",1);
        screen.log.write("Slowing down!");
        slowdowntimer.start();
    }
}



var orbitauto = func() {
    setprop("controls/drone/orbitstage",0); # reset the stage on press
    if (getprop("position/altitude-ft") > 5000) {
        screen.log.write("Begining auto orbit! Do not touch the flight controls (Elevator, Rudder, Aileron, Throttle) until it has completed!");
        orbit.orbitauto.start();
    } else {
        screen.log.write("The spaceplane must be above 5000ft MSL, and must be in level non inverted flight in order to use the auto orbit system!");
    }
}


slowdowntimer = maketimer(0,slowdown);
pitchtimer = maketimer(10,pitch);
altitudetimer = maketimer(0,altitude);