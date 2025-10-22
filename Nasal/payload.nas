# Phoenix ~~
# Put jsbsim orbital sattelites into the payload bay of an orbiter
# Then when ready to release, swiftly detach from the payload, renable the FDM, and set lat/lon/speed/alt/etc to the same as the orbiter that tugged us up once. 
# To avoid FDM invalidation! 


# Properties
# Location
setprop("payload/orbiter/latitude-deg",0.0);
setprop("payload/orbiter/longitude-deg",0.0);
setprop("payload/orbiter/heading-deg",0.0);
setprop("payload/orbiter/altitude-ft",0.0);

# Velocities
setprop("payload/orbiter/mach",0.0);
setprop("payload/orbiter/down-relground-fps",0.0);
setprop("payload/orbiter/east-relground-fps",0.0);
setprop("payload/orbiter/north-relground-fps",0.0);
setprop("payload/orbiter/speed-down-fps",0.0);
setprop("payload/orbiter/speed-east-fps",0.0);
setprop("payload/orbiter/speed-north-fps",0.0);
setprop("payload/orbiter/uBody-fps",0.0);
setprop("payload/orbiter/vBody-fps",0.0);
setprop("payload/orbiter/vertical-speed-fps",0.0);
setprop("payload/orbiter/wBody-fps",0.0);


setprop("sim/remote/dialog/b",0);
# FDM "Pause" button | fdm/jsbsim/simulation/pause
screen.log.write("Do not manually detech from the orbiter! Use the detach menu option instead!");
var dualcontrolfunc = func() {
    # Execute this everytime the user changes the status of the dualcontrol
    if (getprop("sim/remote/dialog/b") == 1) {
        # we have been put into a payload bay
        # Disable FDM
        setprop("fdm/jsbsim/simulation/pause",1);
        screen.log.write("In payload bay! to detech: Select 'detach' in the orbiter menu");
    }
}


var detach = func() {
    screen.log.write("Detaching - Please wait...");
    # Get all info currently before detatching and save them
    # Location
    setprop("payload/orbiter/latitude-deg",getprop("position/latitude-deg")); # These are accurate
    setprop("payload/orbiter/longitude-deg",getprop("position/longitude-deg")); # These are accurate
    setprop("payload/orbiter/heading-deg",getprop("orientation/heading-deg")); # These are accurate
    setprop("payload/orbiter/altitude-ft",getprop("position/altitude-ft")); # These are accurate

    # Velocities
    var mpid = misc.smallsearch(getprop("sim/remote/pilot-callsign")); # Find the orbiters properties
    # save them
    setprop("payload/orbiter/mach",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[9]"));
    setprop("payload/orbiter/down-relground-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[10]"));
    setprop("payload/orbiter/east-relground-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[11]"));
    setprop("payload/orbiter/north-relground-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[12]"));
    setprop("payload/orbiter/speed-down-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[13]"));
    setprop("payload/orbiter/speed-east-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[14]"));
    setprop("payload/orbiter/speed-north-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[15]"));
    setprop("payload/orbiter/uBody-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[16]"));
    setprop("payload/orbiter/vBody-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[17]"));
    #setprop("payload/orbiter/vertical-speed-fps",getprop("velocities/vertical-speed-fps"));
    setprop("payload/orbiter/wBody-fps",getprop("ai/models/multiplayer["~mpid~"]/sim/multiplay/generic/float[18]"));

    setprop("sim/remote/dialog/b",0); # leave the orbiter (return to the take off spot)
    setprop("sim/remote/pilot-callsign","");

    dual_control.main.reset(); # Disconnect DC
    setprop("fdm/jsbsim/simulation/pause",0); # Unpause the FDM
    # Restore saved position
    setprop("position/latitude-deg",getprop("payload/orbiter/latitude-deg"));
    setprop("position/longitude-deg",getprop("payload/orbiter/longitude-deg"));
    setprop("orientation/heading-deg",getprop("payload/orbiter/heading-deg")); 
    setprop("position/altitude-ft",getprop("payload/orbiter/altitude-ft"));
    # Restore saved velocities

    setprop("velocities/down-relground-fps",getprop("payload/orbiter/down-relground-fps"));
    setprop("velocities/east-relground-fps",getprop("payload/orbiter/east-relground-fps"));
    setprop("velocities/north-relground-fps",getprop("payload/orbiter/north-relground-fps"));
    setprop("velocities/speed-down-fps",getprop("payload/orbiter/speed-down-fps"));
    setprop("velocities/speed-east-fps",getprop("payload/orbiter/speed-east-fps"));
    setprop("velocities/speed-north-fps",getprop("payload/orbiter/speed-north-fps"));
    setprop("velocities/uBody-fps",getprop("payload/orbiter/uBody-fps"));
    setprop("velocities/vBody-fps",getprop("payload/orbiter/vBody-fps"));
   #setprop("velocities/vertical-speed-fps",getprop("payload/orbiter/vertical-speed-fps"));
    setprop("velocities/wBody-fps",getprop("payload/orbiter/wBody-fps"));
    setprop("velocities/mach",getprop("payload/orbiter/mach")); # should be last
}


setlistener("sim/remote/dialog/b", func {
dualcontrolfunc();
});