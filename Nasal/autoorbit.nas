# autoorbit.nas 
# Phoenix

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
        if (getprop("fdm/jsbsim/systems/orbital/apoapsis-ft") > 500000) {
            setprop("controls/engines/engine/throttle",0);
            setprop("controls/engines/engine[1]/throttle",0);
            setprop("autopilot/locks/heading","wing-leveler");
            setprop("autopilot/settings/heading-bug-deg",0);
            setprop("controls/drone/orbitstage",2);
        }
    }
    if (stage == 2) {
        if (getprop("position/altitude-ft") > 300000) {
            setprop("autopilot/settings/target-pitch-deg",0);
        }
        if (getprop("position/altitude-ft") > 480000) {
            print("preping for burn 2");
            if (getprop("autopilot/internal/vert-speed-fpm") < 1000) {
                if (getprop("fdm/jsbsim/systems/orbital/periapsis-ft") < 400000) {
                    if (getprop("fdm/jsbsim/systems/orbital/apoapsis-ft") < 600000) {
                    setprop("controls/engines/engine/throttle",1);
                    setprop("controls/engines/engine[1]/throttle",1);
                    setprop("autopilot/settings/target-pitch-deg",-2);
                    print("Burn 2 active!");
                    }
                } else {
                    print("Orbit! Waiting for periapsis!");
                    setprop("controls/drone/orbitstage",3);
                }


            } else {
                # climbing again set 0 throt
                print("VS is greater than 1000!");
                setprop("controls/engines/engine/throttle",0);
                setprop("controls/engines/engine[1]/throttle",0);
            }

            print("in space!");
            }
    }
}
