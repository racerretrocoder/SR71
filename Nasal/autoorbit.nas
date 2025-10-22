# autoorbit.nas 
# Phoenix

# Give me a float
setprop("controls/drone/orbitstage",0.1);
setprop("controls/drone/orbitstage",0);

var climb = func() {
    var stage = getprop("controls/drone/orbitstage");
    print("in check function");
    if (stage == 0) {
        setprop("autopilot/locks/altitude","pitch-hold");
        setprop("autopilot/settings/target-pitch-deg",14);
        setprop("autopilot/locks/heading","wing-leveler-atmos");
        setprop("controls/engines/engine/throttle",1);
        setprop("controls/engines/engine[1]/throttle",1);
        setprop("controls/drone/orbitstage",1);
    }
    # Apoapsis check
    if (stage == 1) {
        if (getprop("position/altitude-ft") > 100000) {
        setprop("autopilot/locks/heading","wing-leveler");
        setprop("autopilot/settings/heading-bug-deg",0);
        }
        if (getprop("fdm/jsbsim/systems/orbital/apoapsis-ft") > 600000) { # Set this based on orbit
            setprop("controls/engines/engine/throttle",0);
            setprop("controls/engines/engine[1]/throttle",0);
            setprop("autopilot/locks/heading","wing-leveler");
            setprop("autopilot/settings/heading-bug-deg",0);
            setprop("controls/drone/orbitstage",2);
            screen.log.write("Main Engines Idle",0,1,0); # orbit.orbitauto.start()
            setprop("autopilot/locks/altitude","pitch-hold-rentry");
        }
    }
    if (stage == 2) {
        if (getprop("position/altitude-ft") > 300000) {
            setprop("autopilot/locks/altitude","pitch-hold");
            setprop("autopilot/settings/target-pitch-deg",0);
            setprop("controls/drone/orbitstage",2.5);
            screen.log.write("In space",0,1,0);
        }
    }

    if (stage == 2.5) {
        if (getprop("position/altitude-ft") > 480000) {
            print("preping for burn 2");
            if (getprop("autopilot/internal/vert-speed-fpm") < 1000) {
                if (getprop("fdm/jsbsim/systems/orbital/periapsis-ft") < 100000) {
                    if (1 == 1) {
                    setprop("controls/engines/engine/throttle",1);
                    setprop("controls/engines/engine[1]/throttle",1);
                    setprop("autopilot/settings/target-pitch-deg",0);
                    setprop("autopilot/locks/altitude","vertical-speed-hold");
                    print("Burn 2 active!");
                    } else {
                        print("Complete!");
                    }
                } else {
                    print("Orbit! Waiting for periapsis!");
                    setprop("controls/drone/orbitstage",3);
                    setprop("controls/engines/engine/throttle",0);
                    setprop("controls/engines/engine[1]/throttle",0);
                    screen.log.write("Auto Oribit Completed",0,1,0);
                    orbitauto.stop();
                    return 1;
                }


            } else {
                # climbing again set 0 throt
                print("VS is greater than 1000!");
                if (getprop("fdm/jsbsim/systems/orbital/periapsis-ft") < 100000) {
                    var ae = 0;
                } else {
                    print("Orbit! Waiting for periapsis!");
                    setprop("controls/drone/orbitstage",3);
                    setprop("controls/engines/engine/throttle",0);
                    setprop("controls/engines/engine[1]/throttle",0);
                    setprop("autopilot/locks/altitude","pitch-hold");
                    setprop("autopilot/settings/target-pitch-deg",0);
                    screen.log.write("Auto Orbit Completed!",0,1,0);
                    orbitauto.stop();
                    return 1;
                }
            }

            print("in space!");
            }
    }
}

orbitauto = maketimer(0,climb);
