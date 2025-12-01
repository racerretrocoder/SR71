# autoorbit.nas | control a space craft automatically
# Phoenix

# me float
setprop("controls/drone/orbitstage",0.1);
setprop("controls/drone/orbitstage",0);
setprop("controls/drone/turnstage",0.1);
setprop("controls/drone/turnstage",0);
setprop("controls/drone/turnto",0.1);
setprop("controls/drone/turnto",0);
setprop("controls/drone/isturninginspace",0);
setprop("controls/drone/isrev",0);

var turn = func() {
    # Automatically turn the vehicle untill real-course matches our direction
    # Then re-establish an orbit
    var turnto = getprop("controls/drone/turnto");
    screen.log.write("Turning to: "~turnto~"");
    var heading = 0;
    var realcourse = getprop("orientation/realcourse");
    var stage = getprop("controls/drone/turnstage");
    var ourhdg = getprop("orientation/heading-deg");  # in TRUE
    var apoapsis = getprop("fdm/jsbsim/systems/orbital/apoapsis-ft");
    var periapsis = getprop("fdm/jsbsim/systems/orbital/periapsis-ft");
    # determine which direction is the most effective to burn to
    if (realcourse < 180 and turnto < 180) {
        if (turnto < realcourse) {
            # we want to go left 
            var heading = -90;
        } else {
            var heading = 90; 
        }
    } elsif (realcourse < 180 and turnto > 180) {
        # right
        var heading = 90;
    } elsif (realcourse > 180 and turnto < 180) {
        if (turnto < realcourse) {
            # we want to go left 
            var heading = -90;
        } else {
            var heading = 90; 
        }
    } elsif (realcourse > 180 and turnto > 180) {
        if (turnto < realcourse) {
            # we want to go left 
            var heading = -90;
        } else {
            var heading = 90; 
        }
    } else {
        # last resort
        print("last resort heading = 90");
        var heading = 90;
    }
    var desiredheading = realcourse + heading;
    if (desiredheading < 0) {
        # add 360
        desiredheading = desiredheading + 360;
    } elsif (desiredheading > 360) {
        # sub 360
        desiredheading = desiredheading - 360;
    }

    # Code staging

    if (stage == 0) {
        # the autopilot is already enabled
        # First set the heading
        screen.log.write("TURN: "~stage~"");
        setprop("autopilot/settings/heading-bug-deg",heading); # the spacecraft starts to YAW over to the point of interest.
        setprop("controls/drone/isturninginspace",1); # disable entering command again
        # check heading


        # check if in heading window
        # +- 5 is good here
        if (desiredheading > ourhdg - 5 and desiredheading < ourhdg + 5) {
            # the spacecraft desiredheading is within the window of burning
            # Activate the engines
            setprop("controls/engines/engine/throttle",1);
            setprop("controls/engines/engine[1]/throttle",1);
            # Enable V/S Hold
            setprop("autopilot/locks/altitude","vertical-speed-hold");
            setprop("controls/drone/turnstage",stage + 1); # increment the stage
        }
    }

    if (stage == 1) {
        screen.log.write("TURN: "~stage~"");
        # spacecraft is burning and keeping V/S at 0
        # check untill if we are within 10 deg of turn to
        if (turnto > realcourse - 3 and turnto < realcourse + 3) {
            # the spacecraft realcourse is within the window of our destination heading
            # disable the engines
            setprop("controls/engines/engine/throttle",0);
            setprop("controls/engines/engine[1]/throttle",0);
            # Enable V/S Hold
            setprop("autopilot/locks/altitude","vertical-speed-hold");
            setprop("autopilot/settings/heading-bug-deg",0); # center the spacecraft
            # wait untill the spacecraft is leveled
            # setprop("controls/drone/turnstage",stage + 1); # increment the stage
            if (ourhdg > realcourse - 5 and ourhdg < realcourse + 5) {
                # Check if we are still in orbit?
                setprop("controls/drone/turnstage",stage + 1); # increment the stage

            }
        }
    }

    if (stage == 2) {
        # final stage. orbit finalization
        screen.log.write("spacecraft centerd");
        if (periapsis > 480000 and apoapsis < 1000000) {
            screen.log.write("Turn complete! still in orbit");
            setprop("autopilot/locks/altitude","pitch-hold");
            turningloop.stop(); # stop checking the stage
            setprop("controls/drone/turnstage",3); # reset the stage
            setprop("controls/drone/isturninginspace",0); # renable the command
            setprop("controls/engines/engine/throttle",0);
            setprop("controls/engines/engine[1]/throttle",0);
        } elsif (apoapsis > 1000000) {
            # enable REV Thrust and slow down till AP less than 800,000ft
            if (getprop("controls/drone/isrev") == 0) {
                reversethrust.togglereverser();screen.log.write("Toggling reverse thrust");
                setprop("controls/drone/isrev",1);
            }  
            setprop("controls/engines/engine/throttle",0.38);
            setprop("controls/engines/engine[1]/throttle",0.38);
            if (periapsis < 500000) {
                screen.log.write("abort! Periapsis less than 500,000");
                setprop("controls/engines/engine/throttle",0);
                setprop("controls/engines/engine[1]/throttle",0);
                if (getprop("controls/drone/isrev") == 1) {
                    reversethrust.togglereverser();screen.log.write("Toggling reverse thrust");
                    setprop("controls/drone/isrev",0);
                }  
            } elsif (apoapsis < 900000) {
                # good
                setprop("controls/engines/engine/throttle",0);
                setprop("controls/engines/engine[1]/throttle",0);
                if (getprop("controls/drone/isrev") == 1) {
                    reversethrust.togglereverser();screen.log.write("Toggling reverse thrust");
                    setprop("controls/drone/isrev",0);
                }   
            }

        } else {
            screen.log.write("Turn complete! re-circling orbit periapsis...");
            setprop("controls/engines/engine/throttle",0.38);
            setprop("controls/engines/engine[1]/throttle",0.38);
            print("Orbit! Waiting for periapsis!");
        }
    }
    if (stage == 3) {
        turningloop.stop(); # stop checking the stage
    }
}

# setprop("controls/drone/isturninginspace",0);

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
turningloop = maketimer(0,turn);