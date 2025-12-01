#   AI-UCAV-FDC-aDPB
#   Automated Intelligent Unmanned Combat Aerial Vehicle Flying and Dogfighting Controller and Datalink Point Bomber
# -----------------------------------------------------------------------> 
#   All Code Designed, Written, and Tested by Phoenix And Uapilot        > 
# ----------------------------------------------------------------------->
#   AI.nas can do the following:
#   it can control the plane to follow, dogfight/attack, formate up close with an MP player
#   it can listen, Detect and respond to incoming enemy missiles (all but heaters);
#   it can autonmously land a plane at almost any airport with 2 guiding MP followmes to help it guide to the runway.
#   it can land somewhat cleanly on aircraft carriers
#    
#    This file needs to be hidden.
#
#    ▀▀█▀▀ ▒█░▒█ ▀█▀ ▒█▀▀▀█ 　 ▒█▀▄▀█ ▒█░▒█ ▒█▀▀▀█ ▀▀█▀▀ 　 ▒█▀▀█ ▒█▀▀▀ ▒█▀▄▀█ ░█▀▀█ ▀█▀ ▒█▄░▒█ 
#    ░▒█░░ ▒█▀▀█ ▒█░ ░▀▀▀▄▄ 　 ▒█▒█▒█ ▒█░▒█ ░▀▀▀▄▄ ░▒█░░ 　 ▒█▄▄▀ ▒█▀▀▀ ▒█▒█▒█ ▒█▄▄█ ▒█░ ▒█▒█▒█ 
#    ░▒█░░ ▒█░▒█ ▄█▄ ▒█▄▄▄█ 　 ▒█░░▒█ ░▀▄▄▀ ▒█▄▄▄█ ░▒█░░ 　 ▒█░▒█ ▒█▄▄▄ ▒█░░▒█ ▒█░▒█ ▄█▄ ▒█░░▀█ 
#    
#    ▒█▀▀█ ▒█░░░ ░█▀▀█ ▒█▀▀▀█ ▒█▀▀▀█ ▀█▀ ▒█▀▀▀ ▀█▀ ▒█▀▀▀ ▒█▀▀▄ 
#    ▒█░░░ ▒█░░░ ▒█▄▄█ ░▀▀▀▄▄ ░▀▀▀▄▄ ▒█░ ▒█▀▀▀ ▒█░ ▒█▀▀▀ ▒█░▒█ 
#    ▒█▄▄█ ▒█▄▄█ ▒█░▒█ ▒█▄▄▄█ ▒█▄▄▄█ ▄█▄ ▒█░░░ ▄█▄ ▒█▄▄▄ ▒█▄▄▀

#    If you have come across this file by any means or ways of the following:
#    Communication, Stealing, any other acquasition, etc 
#    And you have not been given permission to obtain this file. YOU MUST DISCARD THIS FILE ASAP

# what you need to do to use ai.nas:
# Make sure the namespace for this file is aitrack. Place at the very end of the nasal listing
# You will need an Autopilot (The standard style) that can manuver the UAVs heading and altitude VERY QUICKLY! (super manuverable autopilot)
# Changing from heading 0 to heading 180 should take under 5-2 seconds if you want lethal dogfighting performance
# Also in the autopilot, Make the heading bank angle be controlable from controls/AI/bank

# Try to get the bankangle to match up like this:
# controls/AI/bank    bang-angle-limit-deg
# 100            --          20 deg
#                ...
# 1000           --          50 deg
# 1100           --          55 deg
# 1200           --          60 deg
# 1300           --          65 deg
# etc ...   
# 2200           --          110 deg

# Then you'll need a way that lets you control the features of this file (and autopilot when ai.nas is not in use) remotely via MPChat or any other method. drone.nas is a nice solution to this. Make it Secure with securedrone.nas!
# You will need a weapons system (With emersary damage) so the UAV can attack (and be attacked) by other things
# misc.nas and radar2.nas is nessory for getting target properties, (For the missiles too)
# Also make sure controls/AI/TGTCALLSIGN is defined (its case sensitive)
print("AI.nas: INIT...");

# Init properties
setprop("controls/AI/anglesens",0);
setprop("controls/AI/land",0);
setprop("controls/AI/isevading",0);
setprop("controls/AI/isyasim",0);    # Change this based on which FDM the plane is
setprop("controls/AI/lagbehind",0);  # Formation Lag in NM
setprop("controls/AI/usehdgclose",0); # Formation Close engagment mode
setprop("controls/AI/taximode",0);  # Easier way to taxi the plane if needed
setprop("controls/AI/agmode",0);    # Fighter jet air to ground mode off
setprop("controls/AI/agalt",100);
setprop("controls/AI/followenabled",0);
setprop("controls/AI/landpos/land1lat",19.72140381007823);
setprop("controls/AI/landpos/land1lon",-155.0620882010654);
setprop("controls/AI/landpos/land2lat",0.1);
setprop("controls/AI/landpos/land2lon",0.1);
setprop("controls/AI/landpos/usercoord",0);
setprop("controls/AI/style",0);
setprop("controls/AI/SITUENABLED",0); # For missile.nas Target report
setprop("controls/AI/attackag",0);
setprop("controls/AI/attacksh",0);
# Set these settings in your -set to the way your plane likes em when landing on land

if (getprop("controls/AI/hasrevthrust") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/hasrevthrust",0);
}
if (getprop("controls/AI/landingrate") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/landingrate",-800);
}
if (getprop("controls/AI/landingpitch") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/landingpitch",0);
}


if (getprop("controls/AI/gpsland2dist") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/gpsland2dist",0.6);
}
# Informational
screen.log.write("AI.nas: To land this UAV: Make sure you are atleast "~(getprop("controls/AI/gpsland2dist") + 30) ~" nautical miles apart from the start of the runway");

if (getprop("controls/AI/landaltagl") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/landaltagl",280);
}
if (getprop("controls/AI/landusepitchhold") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/landusepitchhold",0);
}

if (getprop("controls/AI/landspeed") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/landspeed",200);
}
if (getprop("controls/AI/landfinalspeed") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/landfinalspeed",170);
}
if (getprop("controls/AI/hasfullrollcontrol") == nil){ # Sometimes AI.nas on civil planes is cool. ill put this here
    setprop("controls/AI/hasfullrollcontrol",0);
}
setprop("controls/AI/pullhard-deg",89); # change this per plane if undesired effects are shown
setprop("controls/AI/carriertype",0); # 0 nimitz, 1 vinson, 2 esinhower, 3 truman
setprop("controls/AI/tgtq/tgt1","");
setprop("controls/AI/tgtq/tgt2","");
setprop("controls/AI/tgtq/tgt3","");
setprop("controls/AI/tgtq/tgt4","");
setprop("controls/AI/tgtq/tgt5","");
setprop("controls/AI/tgtq/tgt6","");
setprop("controls/AI/tgtq/tgt7","");
setprop("controls/AI/tgtq/tgt8","");
setprop("controls/AI/tgtq/tgt9","");
setprop("controls/AI/tgtq/tgt10","");
# Temps!
setprop("controls/AI/tgtqtemp/tgt1",getprop("controls/AI/tgtq/tgt1"));
setprop("controls/AI/tgtqtemp/tgt2",getprop("controls/AI/tgtq/tgt2"));
setprop("controls/AI/tgtqtemp/tgt3",getprop("controls/AI/tgtq/tgt3"));
setprop("controls/AI/tgtqtemp/tgt4",getprop("controls/AI/tgtq/tgt4"));
setprop("controls/AI/tgtqtemp/tgt5",getprop("controls/AI/tgtq/tgt5"));
setprop("controls/AI/tgtqtemp/tgt6",getprop("controls/AI/tgtq/tgt6"));
setprop("controls/AI/tgtqtemp/tgt7",getprop("controls/AI/tgtq/tgt7"));
setprop("controls/AI/tgtqtemp/tgt8",getprop("controls/AI/tgtq/tgt8"));
setprop("controls/AI/tgtqtemp/tgt9",getprop("controls/AI/tgtq/tgt9"));
setprop("controls/AI/tgtqtemp/tgt10",getprop("controls/AI/tgtq/tgt10"));
setprop("controls/AI/carrieroffset",0); # 9
setprop("controls/AI/canchat",1);
setprop("controls/AI/altlevel",1); # Enable/Disable
setprop("controls/AI/altlevelft",15000); # if the UAV is way too high from the bandit. change that
setprop("controls/AI/hdgaltlevelft",300);
setprop("controls/AI/gpslandmultiplyer",2);
# 10 SITU.nas Target queue!!

var weaponsextension = func(type) {
    return guns.report_extension(type);
}


var pitchcontrol = func() {
    setprop("autopilot/locks/altitude","pitch-hold")
}


var speedbrakecheck = func() {
    # Check if we want to slow down. then enable the speed brake (within 100kts)
    var ourspeed = getprop("velocities/airspeed-kt");
    var apspeed = getprop("autopilot/settings/target-speed-kt");
    if (ourspeed > apspeed + 50) {
        # Slow down!
        setprop("controls/flight/speedbrake",1);
        print("Speed brake");
    } else {
        setprop("controls/flight/speedbrake",0);
    }
}
speedbraketimer = maketimer(0.5,speedbrakecheck);
# New heavy bomber mode
# the bomber will stay far away at an airport, up high. then when it attacks itll turn to the point then itll drop a bomb on it
# Ideas: Make damage on by default -- Done
# Make Missiles add on by default -- Done see launcher.nas
# Make range be automatically at 160 -- Done launcher.nas

var missile_deg = 0; 
var active = 0; # if an active missile has been detected in the last minuet
var mslrun = 0;
var lastapspeed = 0;
var attackoverride = 0; # Set to 1 if using external attacking extension
# Extensions
var EXTWEP = 0;

var pullhard = func(mpid) {
        setprop("/autopilot/locks/altitude", "pitch-hold");
        setprop("/autopilot/internal/target-pitch-deg", 35);
        # Now do we bank low or high?
        #        setprop("/autopilot/settings/target-agl-ft",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/position/altitude-ft"));
        var banditalt = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/position/altitude-ft") - 400;
        var ouralt = getprop("position/altitude-ft");
        if (ouralt < banditalt) {
            # Go up!
            setprop("controls/AI/bank", 1000); # Bank 70
        }
        if (ouralt > banditalt) {
            # Go down!
            setprop("controls/AI/bank", 2600); # Bank 110
        }
}


# Small functions for timers
var start = func(){
timer_search.start();
setprop("controls/AI/followenabled", 1);
}
var startbomb = func(){
timer_bomb.start();
}
var stop = func(){
timer_search.stop();
setprop("controls/AI/followenabled", 0);
setprop("/autopilot/locks/heading","dg-heading-hold");
setprop("/autopilot/locks/altitude","altitude-hold");
setprop("/autopilot/locks/speed","speed-with-throttle");
}
var stopbomb = func(){
timer_bomb.stop();
}
var bombbay = func(){
timer_bombbay.start();
}

var braketoggle = func() {
    var brake = getprop("controls/gear/brake-parking");
    setprop("controls/gear/brake-parking",!brake);
}

braketimer = maketimer(0.7,braketoggle);

var search = func(){
var cs = getprop("controls/AI/TGTCALLSIGN");
# make sure your tgt callsign is in controls/AI/TGTCALLSIGN
var tracked = misc.smallsearch(cs);
track(tracked);
}

# Semi-active missile search (Sams and Fox 1s)
var search2 = func(){
var cs = getprop("payload/armament/MAW-semiactive-callsign");
var tracked = misc.smallsearch(cs);
evadesemi(tracked);
}


var togglehook = func(){
    if (getprop("fdm/jsbsim/systems/hook/tailhook-cmd-norm") == 0) {
        setprop("fdm/jsbsim/systems/hook/tailhook-cmd-norm",1);
        setprop("controls/flight/flaps",1);
    } else {
        setprop("fdm/jsbsim/systems/hook/tailhook-cmd-norm",0);
        setprop("controls/flight/flaps",0);
    }
}


# Fast Deploying flares. Basically a jammer

var flares = func{
    damage.flare_released(); # show a flare model on MP
	var flarerand = rand(); # get random decimal
  # every time these numbers change. the shooter runs chaff flare probability 
  # so if we change them really fast that will be good
    setprop("/rotors/main/blade[3]/flap-deg", flarerand);  #flarerand
    setprop("/rotors/main/blade[3]/position-deg", flarerand);
settimer(func {
  setprop("/rotors/main/blade[3]/flap-deg", 0);
    setprop("/rotors/main/blade[3]/position-deg", 0);
    #props.globals.getNode("/rotors/main/blade[3]/flap-deg").setValue(0); # SLOW
    #props.globals.getNode("/rotors/main/blade[3]/position-deg").setValue(0); # SLOW
    },0.1); # this may be the key to our speed!! 
                # can confirm this is the best way to evade missiles from the F-16!! 
}

var evasion = func{
    setprop("payload/armament/MLW-launcher","");
    setprop("controls/AI/isevading",0);
    active = 0;
}

# MP Remotecontrol/Tracking/Following/Formating/Dogfighting/Attacking All in one function!
setprop("controls/AI/remotecontrol",0); # Init variable
var track = func(mpid){
# Standerd remote control. Not Automated flight
# MP Floats of the GCS
# 3 elevator
# 4 aileron
# 5 rudder
# 6 throttle
# Others
if (getprop("controls/AI/remotecontrol") == 1) {
    # Remote control
    setprop("controls/flight/elevator",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[3]"));   
    setprop("controls/flight/aileron",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[4]"));  
    setprop("controls/flight/rudder",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[5]"));
    setprop("controls/engines/engine[0]/throttle",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[6]")); # Engine 0
    setprop("controls/engines/engine[1]/throttle",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[6]")); # Engine 1
    setprop("controls/engines/engine[2]/throttle",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[6]")); # Engine 2
    setprop("controls/engines/engine[3]/throttle",getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[6]")); # Engine 3
    print("Remote control updated!");
    setprop("/autopilot/locks/altitude","");
    setprop("/autopilot/locks/heading","");
    setprop("/autopilot/locks/speed","");
    return 0; # Dont proceed forward to the flightcontrol
}


    #
    # Easy Taxi Mode
    #


if (getprop("controls/AI/taximode") == 1) {
    # mp props
    # float 10 is fwd cmd
    # float 11 is steer
    # float 12 is brake
    # float 13 is maxspeed-kts
    var maxspeed = getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[13]"); # in kts. defaults to 5
    var steer = getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[11]");
    # First lets check fwd

    if (getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[10]") == 1) {
        # we go forward
        setprop("/controls/gear/brake-parking",0); # off goes the parking brake
        screen.log.write(maxspeed);
        screen.log.write(getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[10]"));
        setprop("/autopilot/locks/speed","speed-with-throttle"); # enable throttle
        setprop("/autopilot/settings/target-speed-kt",maxspeed);
    } elsif (getprop("ai/models/multiplayer["~ mpid ~"]/sim/multiplay/generic/float[12]") == 0) {
        # stoppp
        setprop("/autopilot/locks/speed",""); # disable throttle(s)
        setprop("/autopilot/settings/target-speed-kt",0);
        setprop("/controls/gear/brake-parking",1); # brake
        setprop("controls/engines/engine[0]/throttle",0); # Engine 0
        setprop("controls/engines/engine[1]/throttle",0); # Engine 1
        setprop("controls/engines/engine[2]/throttle",0); # Engine 2
        setprop("controls/engines/engine[3]/throttle",0); # Engine 3
    }
    # check steer
    screen.log.write(steer);
    if (steer == 1) {
            # right
        setprop("controls/flight/rudder",1);
        if (getprop("controls/AI/isyasim") == 1) {
            # big yasim plane!
            setprop("controls/gear/brake-left",0);
            setprop("controls/gear/brake-right",1);
        }
    }
    if (steer == 0) {
            # straight
        setprop("controls/flight/rudder",0);
        if (getprop("controls/AI/isyasim") == 1) {
            # big yasim plane!
            setprop("controls/gear/brake-left",0);
            setprop("controls/gear/brake-right",0);
        }
    }
    if (steer == -1) {
            # left
        setprop("controls/flight/rudder",-1);
        if (getprop("controls/AI/isyasim") == 1) {
            # big yasim plane!
            setprop("controls/gear/brake-left",1);
            setprop("controls/gear/brake-right",0);
        }
    }
    # Done
    return 0; # Dont proceed forward to the flightcontrol
}

        # Flight control
        # The UAV is on its own right now.
        # FIRST!!! Check for Radar Missiles/Heat Missiles/SAM's before doing anything else!
        # Active Missile Detection
    if (getprop("payload/armament/MAW-active")){
        print("Active Missile Detected!!");
        timer_flare.start();                                # start flaring
        evadeactive();                                      # Turn the other way, then go really fucking fast!!
        active = 1;                                         # Enable active missile timer. Wait X seconds then check for missiles again. if they gone turn around and continue engaging
        return 0; # Dont proceed to the bottom!
    } elsif (getprop("payload/armament/MAW-semiactive")){
        # Semi Active Missile Detection (SAM's and FOX1)
        # TODO: evadesemi mostlikely has bugs.
        print("Missile Detected!! (Semi Active)");
        # Damage.nas dosent spit heading for Semi actives. it spits out a callsign.
        # Small problem, so we will take a little extra time figuring out the heading of our threat. then well react to it with evadesemi();
        # misc.nas will be of use
        search2(); # leads to evadesemi();                      
        timer_flare.start();
        return 0; # Dont proceed to flight automation
    } elsif (getprop("payload/armament/MLW-launcher") != "" and getprop("controls/AI/isevading") == 0){
        # General Missile detection (FOX 2)
        print("Heat seeking missile! Break!");
        if (getprop("controls/AI/isevading") == 0) {
            setprop("/autopilot/settings/heading-bug-deg",getprop("/autopilot/settings/heading-bug-deg") + 90); # BREAK RIGHT
        }
        setprop("controls/AI/isevading",1);
        setprop("controls/AI/followenabled",0);
        screen.log.write("start");
        active = 1;
        timer_flare.start();
        timer_evasion.start(); # after 15 seconds recheck then continue
        return 0;   # Dont proceed to flight automation
    }
    if (active == 1) {
        return 0;
    }

    #
    # Missiles are gone / No missiles
    #

    timer_flare.stop(); # Stop the flares
    
    # MP Information of who we told to follow!
    #print(mpid);
    #print(getprop("ai/models/multiplayer[" ~ mpid ~ "]/callsign"));
    

    #
    # Formation Controller
    #


    if (getprop("controls/AI/formationmode") == 1) {
        setprop("/autopilot/settings/target-altitude-ft",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/position/altitude-ft"));
        setprop("/autopilot/settings/target-agl-ft",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/position/altitude-ft"));        
        # Enable full altitude control
        setprop("controls/AI/followenabled",0);
        # solution needs testing. if our altitude is required to go really low we can bank the opposite way. this may cause massive instability issues aswell. 
        var pitchdeg = getprop("/orientation/pitch-deg");
        var speedasi = getprop("/velocities/airspeed-kt");
        var rolldeg = getprop("/orientation/roll-deg");
        var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm"); # Targets range
        var reqalt = getprop("/autopilot/settings/target-altitude-ft"); # targets altitude
        var altagl = getprop("/position/altitude-ft"); # UAV Altitude
        var bandithdg = getprop("/orientation/heading-deg"); # UAV Heading              
        var bandithdg1 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") - 8;  
        var bandithdg2 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") + 8;
        var highg = 0;
# uncomment if needed
# TODO put this no a property ena/dis
#if(reqalt < altagl - 500 and reqalt < altagl + 500){ # UAV is too high we have 500
#    setprop("controls/AI/bank",2200); # high bank angle to pull down 110* bank
#    if (rolldeg > 93 or rolldeg < -93){ # OK UAV is going to turn sharp!
#        highg = 1;
#        print("UAV TOO HIGH! +500 -500")
#    }
#} 
#if(reqalt > altagl - 500 and reqalt > altagl + 500){ # UAV is too low
#    setprop("controls/AI/bank",1700); # low bank angle to pull down 110* bank
#    if (rolldeg > 60 or rolldeg < -60){ # OK UAV is going to turn sharp!
#        highg = 1;
#    }
#}

        if (highg == 0) {
            # still no g
            if (rolldeg > 85 or rolldeg < -85){ # OK UAV is going to turn sharp!
            setprop("controls/AI/bank",2000);
                highg = 1;
            }                    
        }

          if(highg == 1){
              print("HIGH G TURN"); 
              setprop("autopilot/locks/altitude","agl-hold-rudder"); # rudder control!
              # Dont Highg if the pitch is too high!
               if (getprop("controls/flight/spoilers") == 0){
                   setprop("controls/flight/elevator",-1);    
               } else {
                   setprop("controls/flight/elevator",-1);    
               }                   
          } else{
              setprop("controls/flight/rudder",0);
              if (getprop("autopilot/locks/altitude") != "altitude-hold" and getprop("autopilot/locks/altitude") != "agl-hold") {
                setprop("autopilot/locks/altitude","altitude-hold"); 
              }
          }
        #
        # Formation speed control
        #

        var thespeed = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/velocities/airspeed-kt");
        if (thespeed == nil){
            print("nil");
            var thespeed = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/velocities/true-airspeed-kt");
            setprop("/autopilot/locks/speed","speed-with-throttle2");
        } else{
            print("not nil");
            setprop("/autopilot/locks/speed","speed-with-throttle");
        }
        var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm");
        var lag = getprop("controls/AI/lagbehind");
        # Heading

        if (getprop("controls/AI/usehdgclose") == 1) {
            if (range < 0.4 + lag) {
                    setprop("/autopilot/locks/heading","true-heading-hold");
            setprop("/autopilot/settings/true-heading-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/orientation/true-heading-deg"));
            }
             if (range > 0.4 + lag) {
                    setprop("/autopilot/locks/heading","dg-heading-hold");
            setprop("/autopilot/settings/heading-bug-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg"));
            }                   
        if (range < 100 + lag) {
            setprop("/autopilot/settings/target-speed-kt",700+thespeed);
        }
        if (range < 30 + lag) {
        setprop("/autopilot/settings/target-speed-kt",500+thespeed);
        }
        if (range < 20 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 500);
        }
        if (range < 10 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 200);
        }
        if (range < 5 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 200);
        }
        if (range < 3 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 100);
        }
        if (range < 1 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 100);
        }
        if (range < 0.53 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 80);
        }
        if (range < 0.33 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 40);
        }
        if (range < 0.20 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 17); # slow down 25 will work here but a tad bit too fast!

        }
        if (range < 0.13 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed - 40); # slow down too close
        }
            } else{ # Heading copy
                    setprop("/autopilot/locks/heading","dg-heading-hold");
            setprop("/autopilot/settings/heading-bug-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg"));
  if (range < 100 + lag) {
            setprop("/autopilot/settings/target-speed-kt",700+thespeed);
        }
        if (range < 30 + lag) {
        setprop("/autopilot/settings/target-speed-kt",500+thespeed);
        }
        if (range < 20 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 500);
        }
        if (range < 10 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 200);
        }
        if (range < 5 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 200);
        }
        if (range < 3 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 100);
        }
        if (range < 1 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 100);
        }
        if (range < 0.53 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 70);
        }
        if (range < 0.33 + lag) {
                setprop("/autopilot/settings/target-speed-kt", thespeed + 10);
        }
        if (range < 0.28 + lag) {
                setprop("/autopilot/settings/target-speed-kt", 0); # slow down

        }
        if (range < 0.17 + lag) {
                setprop("/autopilot/settings/target-speed-kt", 0); # slow down
        }
        }
    
        #setprop("/autopilot/settings/target-speed-kt", );
      
    } else {
        var bomber = 0;
        if (getprop("controls/AI/land") == 1){
            bomber = 1;
        }
        if (bomber == 0) {
            #
            # Dogfight Controller
            #

            # Dogfight Altitude Control (DAC)
        
        # we will allways be a few hundred feet above the target to make has allways have a little more potentional energy then our opponent.
        # Also so that we dont crash if they fly too low trying to cheat the system
        
            if (getprop("/controls/AI/agmode") == 0) { 
                    var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm");
                    if (range < 4) {
                        setprop("/autopilot/settings/target-agl-ft",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/position/altitude-ft"));
                    } else {
                        setprop("/autopilot/settings/target-agl-ft",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/position/altitude-ft") + 400); # raise the alt a bit for a slight advantage
                    }

                    # Check if the dogfight controller is not in AG mode
                    # When The AP is banking the plane hard for a sharp turn!
                    # Problem. recent testing has given information:
                    # When the autopilot controls the altitude and heading at the same time, it can run into conflicts such as:
                    # When the plane needs to turn left and go down lower, the plane banks left and the computer pulls down making it go right! Not Good!
                    # solution needs testing. if our altitude is required to go really low we can bank the opposite way. this may cause massive instability issues aswell. 
                    var pitchdeg = getprop("/orientation/pitch-deg");
                    var speedasi = getprop("/velocities/airspeed-kt");
                    var rolldeg = getprop("/orientation/roll-deg");
                    var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm"); # Targets range
                    var reqalt = getprop("/autopilot/settings/target-agl-ft"); # targets altitude
                    var altagl = getprop("/position/altitude-agl-ft"); # UAV Altitude
                    var bandithdg = getprop("/orientation/heading-deg"); # UAV Heading              
                    var bandithdg1 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") - 8;  
                    var bandithdg2 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") + 8;
                    var highg = 0;

                  #if(reqalt < altagl - 500 and reqalt < altagl + 500){ # UAV is too high we have 500
                  #    setprop("controls/AI/bank",2200); # high bank angle to pull down 110* bank
                  #    if (rolldeg > 93 or rolldeg < -93){ # OK UAV is going to turn sharp!
                  #        highg = 1;
                  #        print("UAV TOO HIGH!!!!!!!!!!!! +500 -500")
                  #    }
                  #} 
                  #if(reqalt > altagl - 500 and reqalt > altagl + 500){ # UAV is too low
                  #    setprop("controls/AI/bank",1700); # low bank angle to pull down 110* bank
                  #    if (rolldeg > 60 or rolldeg < -60){ # OK UAV is going to turn sharp!
                  #        highg = 1;
                  #    }
                  #}
                  if (highg == 0) {
                      var anglelimit = getprop("controls/AI/pullhard-deg");
                      var neganglelm = getprop("controls/AI/pullhard-deg") * -1;
                      # still no g
                      if (rolldeg > anglelimit or rolldeg < neganglelm){ # OK UAV is going to turn sharp!
                      setprop("controls/AI/bank",2000);
                          highg = 1;
                      }                    
                  }

                    if(highg == 1){
                        print("HIGH G TURN"); 
                        setprop("autopilot/locks/altitude","agl-hold-rudder");
                        # Dont Highg if the pitch is too high!
                        if (getprop("controls/flight/spoilers") == 0){
                            setprop("controls/flight/elevator",-0.8);    
                        } else {
                            setprop("controls/flight/elevator",-0.5);    
                        }
                   
                    } else{
                        setprop("controls/flight/rudder",0);
                        # Altitude controller
                        if (getprop("autopilot/locks/altitude") != "altitude-hold" and getprop("autopilot/locks/altitude") != "agl-hold") {
                          setprop("autopilot/locks/altitude","agl-hold"); # set it once
                        }
                    }
                    if (getprop("controls/AI/altlevel") == 1) {
                        # can check for altitude changes this way
                        screen.log.write("Dogfight controller alt check!");
                        if (altagl > reqalt + getprop("controls/AI/altlevelft")) {
                            screen.log.write("The UAV is too high! leveling out");
                            setprop("/autopilot/locks/heading","wing-leveler");
                        } else {
                            if (altagl < reqalt - getprop("controls/AI/altlevelft")) {
                                screen.log.write("The UAV is too low! leveling out");
                                setprop("/autopilot/locks/heading","wing-leveler");
                            } else {
                                setprop("/autopilot/locks/heading","true-heading-hold"); # Manually control the angle
                            } 
                        }  
                    } else {
                        setprop("/autopilot/locks/heading","true-heading-hold"); # Manually control the angle
                    }
            } else {
                
                #
                # Air to ground attack controller
                #

                var rolldeg = getprop("/orientation/roll-deg");
                setprop("controls/AI/followenabled",1);
                print("Air to ground attack is on. ag mode");
                if (getprop("controls/flight/elevator") < 0) {
                    # wants to pull up big bank angle
                    #screen.log.write("pulling up");
                    setprop("controls/AI/bank",1700);
                }
                if (getprop("controls/flight/elevator") > 0) {
                    # wants to pull up big bank angle
                    #screen.log.write("pulling down");
                    setprop("controls/AI/bank",1700);
                }
                var highg = 0;
                if (highg == 0) {
                      var anglelimit = getprop("controls/AI/pullhard-deg");
                      var neganglelm = getprop("controls/AI/pullhard-deg") * -1;
                      # still no g
                      if (rolldeg > anglelimit or rolldeg < neganglelm){ # OK UAV is going to turn sharp!
                    setprop("controls/AI/bank",1700);
                        highg = 1;
                    }                    
                }

                #
                # High-G Turning
                #
                
                if(highg == 1){
                    print("HIGH G TURN"); 
                    setprop("autopilot/locks/altitude","agl-hold-rudder");
                    # Dont Highg if the pitch is too high!
                    setprop("controls/flight/elevator",-1);                       
                    setprop("/autopilot/settings/target-agl-ft",getprop("/controls/AI/agalt") + 200); # increase alt to turn
                } else{
                    setprop("controls/flight/rudder",0);
                    setprop("/autopilot/settings/target-agl-ft",getprop("/controls/AI/agalt")); # stay low
                    if (getprop("position/altitude-agl-ft") > getprop("/controls/AI/agalt") + 500) {
                        # too high
                        screen.log.write("Too high");
                        setprop("autopilot/locks/altitude","agl-hold"); 
                    } else {
                        setprop("autopilot/locks/altitude","agl-hold-ag"); 
                    }
                }

                # Targeting
                if (getprop("controls/drone/slot") == 0) {
                    # Not connected to a sam control center :(
                    screen.log.write("Not connected to the control center");
                }
                if (getprop("controls/drone/slot") == 1) {
                    # slot 1
                    print("slot1");
                }
            }

            #
            # Dogfight heading controller
            #

            setprop("/autopilot/settings/heading-bug-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg")-10);
            setprop("/autopilot/settings/true-heading-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg")); 
            var direction = getprop("orientation/aitrack/direction");
            # Angle Adjustments
            var turnangle = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/elevation-deg") * getprop("controls/AI/anglesens");
            screen.log.write(turnangle);
            var altagl = getprop("/position/altitude-agl-ft"); # UAV Altitude
                                var pitchdeg = getprop("/orientation/pitch-deg");
                    var speedasi = getprop("/velocities/airspeed-kt");
                    var rolldeg = getprop("/orientation/roll-deg");
                    var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm"); # Targets range
                    var reqalt = getprop("/autopilot/settings/target-agl-ft"); # targets altitude
                    var bandithdg = getprop("/orientation/heading-deg"); # UAV Heading              
                    var bandithdg1 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") - 8;  
                    var bandithdg2 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") + 8;
                    var highg = 0;
            if (altagl > reqalt + getprop("controls/AI/hdgaltlevelft")) {
                # Above the threat | Turn angle negitive
                screen.log.write("above");
                if (direction == -1) {
                    var angle = getprop("controls/AI/anglesens"); # Turn more left. we need to fall
                    setprop("autopilot/internal/target-roll-deg-aitrack",getprop("autopilot/internal/target-roll-deg") + angle); # Increase the negitive output angle
                }
                if (direction == 1) {
                    var angle = getprop("controls/AI/anglesens") * -1; # Turn more right. we need to fall
                    setprop("autopilot/internal/target-roll-deg-aitrack",getprop("autopilot/internal/target-roll-deg") + angle); # Increase the positive output angle
                }
            } else {
                if (altagl < reqalt - getprop("controls/AI/hdgaltlevelft")) {
                    # Below the threat | Turn angle positive
                    screen.log.write("Below");
                    if (direction == -1) {
                        var angle = getprop("controls/AI/anglesens");  # Dont turn as much left. we need to climb
                        setprop("autopilot/internal/target-roll-deg-aitrack",getprop("autopilot/internal/target-roll-deg") + angle); # Reduce the negitive output angle
                    }
                    if (direction == 1) {
                        var angle = getprop("controls/AI/anglesens") * -1; # Dont turn as much right. we need to climb
                        setprop("autopilot/internal/target-roll-deg-aitrack",getprop("autopilot/internal/target-roll-deg") + angle); # Reduce the positive output angle
                    }
                } else {
                    # No angle adjustments are needed. Pass it through
                    setprop("autopilot/internal/target-roll-deg-aitrack",getprop("autopilot/internal/target-roll-deg"));
                } 
            }  

        } else {
            #
            # Bomber mode / Non combat mode
            #
            print("Bomber!");
            setprop("/autopilot/settings/heading-bug-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg")-10);
            setprop("/autopilot/settings/true-heading-deg",getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg")); 
        }
    }
    # If attack = 1. call attack(mpid); else dont attack
    if (getprop("controls/AI/attack") == 1){
        # Attack enabled
        Attack(mpid);
    }
}

# trying to find a solution to the plane getting pulled down and turning the wrong way
# ap bankangle
# controls/AI/bank
# 100           -- 20 deg
# 1000          -- 50 deg
# 1100          -- 55 deg
# 1200          -- 60  deg
# etc
# 2200          -- 110 deg


var mslcheck = func() {
    print("Checking status of our threat");
    # Detect after some time if that active missile is still on to us!
    lastapspeed = 700;
    if (getprop("payload/armament/MAW-active")) {
        mslrun = 1;
        print("Missile still on us!");
        active = 1;
    } else {
        print("Missile most likely gone by now good");
        timer_mslcheck.stop();
        active = 0;
        mslrun = 0;
        setprop("autopilot/locks/heading","true-heading-hold");
        setprop("controls/AI/followenabled",1);
        setprop("/autopilot/settings/target-speed-kt", 500);
    }
}


    #
    #   Missile Evasion
    #

# Find the opposite bearing of the missile.
# maintain deafult dogfight speed until we are at the opposite bearing
# Then go full speed
# Idea / TODO: Altitude control here?
# We go low AGL Hold 600

var evadeactive = func(){
    var opposite = 0;
    print("active homing missile apon UAV! evading it!");
    setprop("/autopilot/locks/heading","dg-heading-hold");
    setprop("controls/AI/followenabled",0);
    if (getprop("payload/armament/MAW-bearing") == 0) {
        opposite == 180;
    }   elsif (getprop("payload/armament/MAW-bearing") > 0) {
        opposite = getprop("payload/armament/MAW-bearing") - 180;
        print(opposite);
    }   else {
        opposite = getprop("payload/armament/MAW-bearing") + 180;
        print(opposite);
    }
    setprop("/autopilot/settings/heading-bug-deg", opposite);

    # Check to see if were in the right spot before we go very fast
    if (opposite > 0) {
    var bandithdg = getprop("/orientation/heading-deg");                               
    var bandithdg1 = opposite - 13;  # Set this if you want to the UAV to accel at different deviation from the escape bearing
    var bandithdg2 = opposite + 13;

    if(bandithdg > bandithdg1) {
        print("Evade Heading 1/2");
        if(bandithdg < bandithdg2){
            print("Evade Heading 2/2");
        # Where in the heading window of our evasion course
        setprop("/autopilot/settings/target-speed-kt", 900); # We go fast
        }

    } else {
        print("not there yet");
    }

} else {
print("Opposite is less than zero!");
var opposite2 = oppfunc(getprop("/orientation/heading-deg"));
    var opposite3 = oppfunc(opposite);
    var bandithdg = opposite2;                               
    var bandithdg1 = opposite3 - 13;  # Set this if you want to the UAV to accel at different deviation from the escape bearing
    var bandithdg2 = opposite3 + 13;

    if(bandithdg > bandithdg1) {
        print("Evade Heading 1/2");
        if(bandithdg < bandithdg2){
            print("Evade Heading 2/2");
        # Where in the heading window of our evasion course
        setprop("/autopilot/settings/target-speed-kt", 900); # We go FAST AS FUCK!!!
            }   
        }
    }
    if (mslrun == 0) {
    timer_mslcheck.start();
    }
}

# needs revamp
var evadesemi = func(mpid){
    var opposite = 0;
    print(mpid);
    print(getprop("ai/models/multiplayer[" ~ mpid ~ "]/callsign")); # We found our threat

    if (getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") == 0) {
        opposite == 180;
    }   elsif (getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") > 0) {
        opposite = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") - 180;
    }   else {
        opposite = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") + 180
    }
  #  opposite = math.abs(opposite);
    setprop("/autopilot/settings/heading-bug-deg", opposite);
}

var oppfunc = func(heading) {
    var opposite = 0;
    if (heading == 0) {
        opposite == 180;
    }   elsif (heading > 0) {
        opposite = heading - 180;
    }   else {
        opposite = heading + 180
    }
    print(opposite);
return opposite;
}

# Debug
var evadetest = func(angle){
    var opposite = 0;
    print("active homing missile apon UAV! evading it!");

    if (angle == 0) {
        opposite == 180;
    }   elsif (angle > 0) {
        opposite = angle - 180;
        print(opposite);
    }   else {
        opposite = angle + 180;
        print(opposite);
    }
    # Not good. so no ABS the AP can take -heading its ok
    opposite = math.abs(opposite);
    print("Abs");
    print(opposite);
    #setprop("/autopilot/settings/heading-bug-deg", opposite);
    #setprop("/autopilot/settings/target-speed-kt", 750); # speaks for itself
}

# Hopefully these lines of code dont have to defend this UAV. 
# Hopefully. hehe.....


# Radar Spammer

var radarsearch = func(){
         radar.next_Target_Index();
         setprop("controls/AI/rdrcallsign", radar.tgts_list[radar.Target_Index].Callsign.getValue());
}


# SITU.nas attack compiler


var clearqueue = func() {
    setprop("controls/AI/tgtq/tgt1","");
    setprop("controls/AI/tgtq/tgt2","");
    setprop("controls/AI/tgtq/tgt3","");
    setprop("controls/AI/tgtq/tgt4","");
    setprop("controls/AI/tgtq/tgt5","");
    setprop("controls/AI/tgtq/tgt6","");
    setprop("controls/AI/tgtq/tgt7","");
    setprop("controls/AI/tgtq/tgt8","");
    setprop("controls/AI/tgtq/tgt9","");
    setprop("controls/AI/tgtq/tgt10","");
    # Temps!
    setprop("controls/AI/tgtqtemp/tgt1",getprop("controls/AI/tgtq/tgt1"));
    setprop("controls/AI/tgtqtemp/tgt2",getprop("controls/AI/tgtq/tgt2"));
    setprop("controls/AI/tgtqtemp/tgt3",getprop("controls/AI/tgtq/tgt3"));
    setprop("controls/AI/tgtqtemp/tgt4",getprop("controls/AI/tgtq/tgt4"));
    setprop("controls/AI/tgtqtemp/tgt5",getprop("controls/AI/tgtq/tgt5"));
    setprop("controls/AI/tgtqtemp/tgt6",getprop("controls/AI/tgtq/tgt6"));
    setprop("controls/AI/tgtqtemp/tgt7",getprop("controls/AI/tgtq/tgt7"));
    setprop("controls/AI/tgtqtemp/tgt8",getprop("controls/AI/tgtq/tgt8"));
    setprop("controls/AI/tgtqtemp/tgt9",getprop("controls/AI/tgtq/tgt9"));
    setprop("controls/AI/tgtqtemp/tgt10",getprop("controls/AI/tgtq/tgt10"));
    # 10 SITU.nas Target queue!!
    setprop("sim/messages/atc","Attack list cleared successfully!");
}


var missilesplash = func(callsign) {
    if (getprop("controls/AI/canchat") == 1){
        setprop("sim/multiplay/chat","Target hit!");
    }
    # TODO: Add some sort of uhh missile counter
    # if a beefier target is amoung us, we dont want to hit it once xd. will hit multiple times
    #mpid = misc.smallsearch(callsign);
    #setprop("ai/models/multiplayer[" ~ mpid ~ "]/MESITU/RWR",0); # RWR Reset
    # if target queue empty, disable attack go back to situ mode. 
    if (getprop("controls/AI/tgtq/tgt1") != "") {
    # temp hold to slot down the threats
    setprop("controls/AI/TGTCALLSIGN",getprop("controls/AI/tgtq/tgt1")); # Set TGT

    setprop("controls/AI/tgtqtemp/tgt1",getprop("controls/AI/tgtq/tgt1"));
    setprop("controls/AI/tgtqtemp/tgt2",getprop("controls/AI/tgtq/tgt2"));
    setprop("controls/AI/tgtqtemp/tgt3",getprop("controls/AI/tgtq/tgt3"));
    setprop("controls/AI/tgtqtemp/tgt4",getprop("controls/AI/tgtq/tgt4"));
    setprop("controls/AI/tgtqtemp/tgt5",getprop("controls/AI/tgtq/tgt5"));
    setprop("controls/AI/tgtqtemp/tgt6",getprop("controls/AI/tgtq/tgt6"));
    setprop("controls/AI/tgtqtemp/tgt7",getprop("controls/AI/tgtq/tgt7"));
    setprop("controls/AI/tgtqtemp/tgt8",getprop("controls/AI/tgtq/tgt8"));
    setprop("controls/AI/tgtqtemp/tgt9",getprop("controls/AI/tgtq/tgt9"));
    setprop("controls/AI/tgtqtemp/tgt10",getprop("controls/AI/tgtq/tgt10"));
    setprop("controls/AI/tgtq/tgt1", getprop("controls/AI/tgtqtemp/tgt2"));
    setprop("controls/AI/tgtq/tgt2", getprop("controls/AI/tgtqtemp/tgt3"));
    setprop("controls/AI/tgtq/tgt3", getprop("controls/AI/tgtqtemp/tgt4"));
    setprop("controls/AI/tgtq/tgt4", getprop("controls/AI/tgtqtemp/tgt5"));
    setprop("controls/AI/tgtq/tgt5", getprop("controls/AI/tgtqtemp/tgt6"));
    setprop("controls/AI/tgtq/tgt6", getprop("controls/AI/tgtqtemp/tgt7"));
    setprop("controls/AI/tgtq/tgt7", getprop("controls/AI/tgtqtemp/tgt8"));
    setprop("controls/AI/tgtq/tgt8", getprop("controls/AI/tgtqtemp/tgt9"));
    setprop("controls/AI/tgtq/tgt9", getprop("controls/AI/tgtqtemp/tgt10"));
    setprop("controls/AI/tgtq/tgt10","");
    screen.log.write("Shifted threats up!");
    setprop("controls/AI/attack",1);
    } else {
        setprop("controls/AI/TGTCALLSIGN","None"); # Set TGT
        screen.log.write("AI.nas: All targets in the queue have been killed!");
        setprop("sim/multiplay/generic/string[13]","1,f"); # Stop buddies from attacking!
        setprop("sim/multiplay/generic/string[12]","");
        aitrack.stop();
        setprop("/controls/AI/attack",0);
        aitrack.timer_attack.stop(); # stop attacking      
        if (getprop("controls/AI/canchat") == 1){
            setprop("sim/multiplay/chat","Air Superiority Regained!");
        }
        if (getprop("controls/AI/agmode") == 1) {
            setprop("autopilot/locks/altitude","agl-hold")
        }
    }
    # reset there rwr
    mpid = misc.smallsearch(callsign);
    setprop("ai/models/multiplayer[" ~ mpid ~ "]/MESITU/RWR",0);
}



var attackqueuecallsign = func(callsign) {
    # add a callsign to the queue
    if (getprop("controls/AI/tgtq/tgt1") == ""){
        setprop("controls/AI/tgtq/tgt1",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt2") == ""){
        setprop("controls/AI/tgtq/tgt2",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt3") == ""){
        setprop("controls/AI/tgtq/tgt3",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt4") == ""){
        setprop("controls/AI/tgtq/tgt4",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt5") == ""){
        setprop("controls/AI/tgtq/tgt5",callsign); # Hopefully no slots will be ever filled up past here. hopefully. ae
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt6") == ""){
        setprop("controls/AI/tgtq/tgt6",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt6") == ""){
        setprop("controls/AI/tgtq/tgt6",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt7") == ""){
        setprop("controls/AI/tgtq/tgt7",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt7") == ""){
        setprop("controls/AI/tgtq/tgt7",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt8") == ""){
        setprop("controls/AI/tgtq/tgt8",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt9") == ""){
        setprop("controls/AI/tgtq/tgt9",callsign);
        print("Added to queue!");
    } elsif (getprop("controls/AI/tgtq/tgt10") == ""){
        setprop("controls/AI/tgtq/tgt10",callsign);
        print("Added to queue!");
        screen.log.write("AI.nas: Warning! The queue has been filled completely!");
        setprop("sim/messages/atc","AI.nas: Warning! The queue has been filled completely!");
        print("Attack Queue is full. :skull:");
    }
    
}


var situengage = func(mpid,callsign,silly){
    setprop("controls/AI/SITUENABLED",1);
    if (silly == "ae") {
        print("ae xd");
    }
    if (getprop("controls/AI/agmode") == 0) {    
        print("AI.nas: Request has been recivied, to enage a threat from SITU.nas!");
        if (getprop("controls/AI/TGTCALLSIGN") != "" and getprop("controls/AI/TGTCALLSIGN") != "None") {
            screen.log.write("uhh... Attack() is ouccupied with "~getprop("controls/AI/TGTCALLSIGN")~" ill add it to the queue!");
            attackqueuecallsign(callsign);
            setprop("controls/AI/attack",1);
            aitrack.start();
            setprop("sim/multiplay/generic/string[13]","1,a");
            setprop("sim/multiplay/generic/string[12]",callsign);# Make squadron buddies attack our second target
        } else {
            # we are free!
            setprop("controls/AI/TGTCALLSIGN",callsign);
            setprop("/controls/drone/mode","follow");
            setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude
            aitrack.start();
            setprop("controls/AI/attack",1);
            # Squadron stuff
            setprop("sim/multiplay/generic/string[13]","1,a");
            setprop("sim/multiplay/generic/string[12]",callsign);
        }
    } else {
        # AG Mode
        print("AI.nas: Request has been recivied, to enage a threat from SITU.nas!");
        if (getprop("controls/AI/TGTCALLSIGN") != "" and getprop("controls/AI/TGTCALLSIGN") != "None") {
            screen.log.write("uhh... Attack() is ouccupied with "~getprop("controls/AI/TGTCALLSIGN")~" ill add it to the queue!");
            attackqueuecallsign(callsign);
            setprop("controls/AI/attack",1);
            aitrack.start();
            setprop("sim/multiplay/generic/string[13]","1,ag");
            setprop("sim/multiplay/generic/string[12]",callsign);# Make squadron buddies attack our second target
        } else {
            # we are free!
            setprop("controls/AI/TGTCALLSIGN",callsign);
            setprop("/controls/drone/mode","follow");
            setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude
            aitrack.start();
            setprop("controls/AI/attack",1);
            # Squadron stuff
            setprop("sim/multiplay/generic/string[13]","1,ag");
            setprop("sim/multiplay/generic/string[12]",callsign);
        }
    }
}


# Now for some real power
# Attack Controller

var Attack = func(mpid){
    print("Attack armed");
    var distance = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm");
    if (distance < 100) {
          # distance is less than 30nm lets allow us to attack
          # This depends on the missiles we are using. If were 10 degress +- away from dead center of the bandit, shoot.
    var bandithdg = getprop("/orientation/heading-deg");                               # Make that 10 13, Longer ranges is harder to get accurate
    var bandithdg1 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") - 13;  # Set this if you want to the UAV to shoot at different angles
    var bandithdg2 = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/bearing-deg") + 13;
          # print(getprop("ai/models/multiplayer[" ~ mpid ~ "]/callsign")); # We found our threat
    if(bandithdg > bandithdg1) {
        print("Attack Complies 1/2");
        if(bandithdg < bandithdg2){
            print("Attack Complies 2/2");
        # Where in the heading window of our selected target
        # Lets spam radarae change target until the radar target = The target we want dead
         radar_timer.start(); # Rapidly scan the radar for our threat
          var rdrtgt = getprop("controls/AI/rdrcallsign");
         if (rdrtgt == getprop("controls/AI/TGTCALLSIGN")) {
            # Hell yeah! we found him! Lets kill him!
            shoot(mpid);
            radar_timer.stop()
            }
        }
    } else{
        print("Bandit Not withen Heading");
        radar_timer.stop();
        # How to get the next locked radar target: radar.tgts_list[radar.Target_Index].Callsign.getValue()
        }
    } 
}

setprop("controls/AI/weapons/prevtime",0);
var weapondelay = func() {
    var prevtime = getprop("controls/AI/weapons/prevtime");
    var weapontime = getprop("controls/AI/weapons/weapontime");
    var thetimer = getprop("sim/time/elapsed-sec") - prevtime;
    screen.log.write(thetimer);
    if (thetimer > weapontime) {
        setprop("controls/AI/attack",1); # turn on attack again
        weapondelaytimer.stop();
    }
}

weapondelaytimer = maketimer(0.5,weapondelay);

# Shoot function
var shoot = func(mpid,customweapon=0,wep="none"){
          # We found our target lets fire a missile depending on range
    if (getprop("controls/AI/agmode") == 0) {   
        if (getprop("controls/AI/weapons/usecustom") == 0) { # use the custom weapon system?
             var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm");
            # if (range > 3){
             print("Long Range!");
             if (customweapon != 0){
             setprop("/controls/armament/selected-weapon", wep);    
             } else {
             setprop("/controls/armament/selected-weapon", "Aim-120");
             }
             print("firing missile!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
             m2000_load.SelectNextPylon();
             var pylon = getprop("/controls/armament/missile/current-pylon");
             m2000_load.dropMissile(pylon);
             print("AI.nas: Should fire Missile");
            # } 
             weaponsextension(2); # Shoot weapon
             if (customweapon == 0){
             if (getprop("controls/AI/canchat") == 1){
             setprop("/sim/multiplay/chat", "UAV Fireing Missile");
             }
             print("firing missile!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
             setprop("controls/AI/attack", 0); # One missile at a time
             timer_attack.start();
             setprop("controls/AI/rdrcallsign","None");
             }
        } else {
            print("Custom weapons shoot!");
            var numweapons = getprop("controls/AI/weapons/numweapons");
            # check each weapon. Decided to shoot it. then shoot it
            for(var i = 1; i < numweapons + 1; i += 1) {
                var canshoot = 0;
                var typemustbe = "AA";
                var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm");
                var callout = getprop("controls/AI/weapons/weapon"~i~"/callout");
                var weaponname = getprop("controls/AI/weapons/weapon"~i~"/name");
                var type = getprop("controls/AI/weapons/weapon"~i~"/type"); # if its A/G A/A or SH
                var weaponmaxrange = getprop("controls/AI/weapons/weapon"~i~"/max-range-nm"); # max weapon range
                var weaponminrange = getprop("controls/AI/weapons/weapon"~i~"/min-range-nm"); # min weapon range
                var attackag = getprop("controls/AI/attackag");
                var attacksh = getprop("controls/AI/attacksh");
                var ammount = getprop("controls/AI/weapons/weapon"~i~"/ammount"); # ammount of weapons we have
                print("AI.nas: Checking weapon: "~weaponname~"");
                if (attackag == 1) {
                    typemustbe = "AG";
                } elsif (attacksh == 1) {
                    typemustbe = "SH";
                }
                # Weapon type check
                if (type == typemustbe or type == "CUSTOM") {
                    if (ammount > 0 or ammount == -1) {
                        canshoot = 1;
                    }
                    screen.log.write("AI.nas: Weapon: "~weaponname~" is a valid weapon type!");
                }

                if (canshoot == 1 and range < weaponmaxrange and range > weaponminrange) {
                    print("Weapon: "~weaponname~" is in the engage envolupe!");
                    # assumeing its a missile
                    # Check for CUSTOM type
                    if (type == "CUSTOM") {
                        # Execute custom nasal code based on the weapon id
                        # variable i is the weapon id
                        var targetcallsign = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/callsign");
                        shootcustomweapon(i,targetcallsign); # Define this in a seperate script!
                    } else {
                        # fire off a regular missile
                        setprop("/controls/armament/selected-weapon", weaponname);
                        m2000_load.SelectNextPylon();
                        var pylon = getprop("/controls/armament/missile/current-pylon");
                        m2000_load.dropMissile(pylon);
                        print("AI.nas: Should fire Missile");
                    }

                    if (getprop("controls/AI/canchat") == 1){
                        if (callout != "NONE") {
                            setprop("sim/multiplay/chat","UAV "~callout~"");
                        } 
                    }
                    setprop("controls/AI/attack", 0); # One missile at a time
                    #timer_attack.start(); # delay attacking
                    setprop("controls/AI/weapons/prevtime",getprop("sim/time/elapsed-sec"));
                    setprop("controls/AI/weapons/weapontime",getprop("controls/AI/weapons/weapon"~i~"/delay-after-deploy"));
                    weapondelaytimer.start();
                    var newweaponamnt = ammount - 1;
                    setprop("controls/AI/weapons/weapon"~i~"/ammount",newweaponamnt); # ammount of weapons we have
                    screen.log.write("Weapon launched!");
                    break;
                }
            }
        }
    } else {
        # AG Mode
        print("Custom weapons shoot!");
        var numweapons = getprop("controls/AI/weaponsag/numweapons");
        # check each weapon. Decided to shoot it. then shoot it
        for(var i = 1; i < numweapons + 1; i += 1) {
            var range = getprop("/ai/models/multiplayer[" ~ mpid ~ "]/radar/range-nm");
            var callout = getprop("controls/AI/weaponsag/weapon"~i~"/callout");
            var weaponname = getprop("controls/AI/weaponsag/weapon"~i~"/name");
            print("AI.nas: Checking weapon: "~weaponname~"");
            var weaponmaxrange = getprop("controls/AI/weaponsag/weapon"~i~"/max-range-nm"); # max weapon range
            var weaponminrange = getprop("controls/AI/weaponsag/weapon"~i~"/min-range-nm"); # min weapon range
            if (range < weaponmaxrange and range > weaponminrange) {
                print("Weapon: "~weaponname~" is in the engage envolupe!");
                # assumeing its a missile
                setprop("/controls/armament/selected-weapon", weaponname);
                m2000_load.SelectNextPylon();
                var pylon = getprop("/controls/armament/missile/current-pylon");
                m2000_load.dropMissile(pylon);
                print("AI.nas: Should fire Missile");
                if (getprop("controls/AI/canchat") == 1){
                setprop("sim/multiplay/chat","UAV "~callout~"");
                }
                setprop("controls/AI/attack", 0); # One missile at a time
                #timer_attack.start(); # delay attacking
                setprop("controls/AI/weaponsag/prevtime",getprop("sim/time/elapsed-sec"));
                setprop("controls/AI/weaponsag/weapontime",getprop("controls/AI/weaponsag/weapon"~i~"/delay-after-deploy"));
                weapondelaytimer.start();
                break;
            }
        }
    }
}

var bombinprogress = 0;
var dropbomb = func(lat,lon,alt,wep="none"){
    if (bombinprogress == 0) {
                # We found our target lets fire a missile depending on range
    screen.log.write("Set Coords to the Current Weapon(s)!");   
    setprop("controls/radar/weaponcoords", 1);
    setprop("controls/radar/gpslock/lat", lat); 
    setprop("controls/radar/gpslock/lon", lon); 
    setprop("controls/radar/gpslock/alt", alt); 
    radar.RangeSelected.setValue(0);
    # Locked on coordnites
                print("Long Range!");
                setprop("/controls/armament/selected-weapon", wep);    
                m2000_load.SelectNextPylon();
                var pylon = getprop("/controls/armament/missile/current-pylon");
                m2000_load.dropMissile(pylon);
                bombinprogress = 0;
                print("Should fire Missile");
    } else {
        screen.log.write("a bomb is already falling! xd");
    }

}


var attackreset = func {
    setprop("controls/AI/attack", 1);
}


# Manual remote control
var setfltprop = func(prop1,prop2,prop3,prop4) {
setprop("controls/AI/elevator", getprop(prop1));
setprop("controls/AI/aileron", prop2);
setprop("controls/AI/rudder", prop3);
setprop("controls/AI/throttle", prop4);
}

var smallsearch = func(cs="land") {
  var list = props.globals.getNode("/ai/models").getChildren("multiplayer");
  var total = size(list);
  var mpid = 0;
  for(var i = 0; i < total; i += 1) {

      # were searching for someone...
      if (getprop("ai/models/multiplayer[" ~ i ~ "]/callsign") == cs) {
          # we have our number
          print(mpid);
          mpid = i;
          #track(mpid,0); # run the flare detection/RND on this Multiplayer property
          return mpid; # Bam!
          
     }
   }
}


var coord = func(nocheck=0) {
    var callsign = getprop("controls/drone/landcs");
    var coord = geo.Coord.new();
    var gndelev = alt*FT2M;
    print("coord: lat:" ~ lat);
    print("coord: lon:" ~ lon);
    print("coord: alt:" ~ alt);
    if (nocheck == 0) {
    coord.set_latlon(lat, lon, alt);
    setprop("controls/AI/main/lat",lat);
    setprop("controls/AI/main/lon",lon);
    setprop("controls/AI/main/alt",alt);
    } else {
        if (gndelev <= 0) {
        gndelev = geo.elevation(lat, lon);
       if (gndelev != nil){
            print("gndelev: " ~ gndelev);
        }
       if (gndelev == nil){
            # oh no
            gndelev = 0;
        }
    }
    print(gndelev);
    coord.set_latlon(lat, lon, gndelev);
    setprop("controls/AI/main/lat",lat);
    setprop("controls/AI/main/lon",lon);
    setprop("controls/AI/main/alt",gndelev);
    print("COORD SETUP DONE");
    }
    return coord;
}   


var oppositeland = func() {
    var bearing = getprop("/controls/AI/landhdg");
    setprop("/autopilot/settings/heading-bug-deg",bearing);
}

var land = func() {
var csog = getprop("controls/drone/landcs");
    var cs11 = ""~ csog ~"1";
    var cs22 = ""~ csog ~"2";
    print(cs11);
    print(cs22);

    var mpid1 = aitrack.smallsearch(cs11);
    var mpid2 = aitrack.smallsearch(cs22);
    var coord1 = geo.Coord.new();  
    var coord2 = geo.Coord.new();  
    var lat1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/latitude-deg");
    var lat2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/latitude-deg");
    var lon1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/longitude-deg");
    var lon2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/longitude-deg");
    var rng1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/radar/range-nm");
    var rng2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/radar/range-nm");
    var hdg2 = getprop("ai/models/multiplayer[" ~ mpid2 ~ "]/radar/bearing-deg");
    var opposite = 0;
        if (hdg2 == 0) {
            opposite == 180;
        }   elsif (hdg2 > 0) {
            opposite = hdg2 - 190;
            print(opposite);
        }   else {
            opposite = hdg2 + 190;
            print(opposite);
        }
        setprop("/controls/AI/oppositeland", opposite);



    # mp1
    gndelev1 = geo.elevation(lat1, lon1);
    if (gndelev1 != nil){
         print("gndelev: " ~ gndelev1);
     }
    if (gndelev1 == nil){
         # oh no
         gndelev1 = 0;
     }  
    coord1.set_latlon(lat1, lon1, gndelev1);  

    # mp2
    gndelev2 = geo.elevation(lat2, lon2);
    if (gndelev2 != nil){
         print("gndelev: " ~ gndelev2);
     }
    if (gndelev2 == nil){
         # oh no
         gndelev2 = 0;
     }  
    coord2.set_latlon(lat2, lon2, gndelev2);  

    # runway bearing     
    var bearing = coord1.course_to(coord2);
    print(bearing);
    #setprop("/autopilot/settings/heading-bug-deg",bearing);



# put marker followme land1 a bit behind the start of the runway of landing. about 0.2nm away from the runway on the map should be good
# put marker followme land2 a bit ahead of the start of the runway of landing. about 0.4nm away from the start should be good!
# Do not place land2 at the end of the runway
# If everything goes well the UAV should land successfully and be completely stopped 0.7nm away from land2 
# Best if the runway is atleast 1.0nm long. ive tested it on the following runways:
# PHTO 08/26
# then position the UAV somewhat alligned with the runway far away (20nm at least)
# put land2 somewhere in the middile of the runway

    var mode = getprop("controls/AI/landstage");
    var modeGPS = getprop("controls/AI/landgps");
    print("landing mode:");
    print(mode);
    print("Landing now");
    if (mode == 0){
        # Ok we are behind the runway to land on. off center
        setprop("/controls/AI/TGTCALLSIGN",cs11); # allign with the markers
        aitrack.start();      
        setprop("/autopilot/settings/target-speed-kt", 240); # Speed where flaps dont push the plane up too much
        setprop("/controls/gear/gear-down",1); # Gear down
        setprop("controls/AI/landstage",1);
    }
    if (rng1 < 13 and mode == 1){ # wait till UAV is 10nm away from land1
        setprop("/autopilot/locks/altitude", "agl-hold"); # Go down
        setprop("/autopilot/settings/target-agl-ft", 280); # Slow down   
        setprop("controls/AI/landstage",2);
        setprop("/autopilot/settings/target-speed-kt", 200); # Slow down       
    }
    if (rng1 < 0.2 and mode == 2){
        # about to be over the runway
        setprop("/controls/AI/TGTCALLSIGN",cs22); # Engage 2nd marker
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        setprop("/autopilot/settings/vertical-speed-fpm", -500); # start to go down
        setprop("controls/AI/landstage",3); 
        setprop("/autopilot/settings/target-speed-kt", 175); # Slow down      
    }
    if (rng2 < 0.2 and mode == 3){
        # about to be over the runway
        setprop("/controls/AI/TGTCALLSIGN",cs22); # Engage 2nd marker
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        aitrack.stop();
        #setprop("/autopilot/locks/heading", "wing-leveler"); # WE ARE ALIGNED! Stay!
        aitrack.oppositeland.start();
        setprop("/autopilot/settings/vertical-speed-fpm", -170); # start to go down
        setprop("controls/AI/landstage",4); # On final
        setprop("/autopilot/settings/target-speed-kt", 110); # Slow down   
        setprop("controls/gear/brake-parking",1);
        

    } 
    var gearwow = 0;
    var gearwow0 = getprop("gear/gear/wow");
    var gearwow1 = getprop("gear/gear[1]/wow");
    var gearwow2 = getprop("gear/gear[2]/wow");
    if (gearwow0 == 1 or gearwow1 == 1 or gearwow2 == 1){
        gearwow = 1;
        if (getprop("controls/AI/toucheddown") == 0){
            if (getprop("controls/AI/canchat") == 1){
            setprop("sim/multiplay/chat", "Touchdown");
            }
            setprop("controls/AI/toucheddown", 1);
        }
    }
    if (gearwow == 1 and mode == 4){
        # Touch down!
        aitrack.oppositeland.stop();
        setprop("/autopilot/locks/speed", "");
        setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
        setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
        if (getprop("controls/AI/hasrevthrust") == 1 and getprop("velocities/airspeed-kt") > 30){
            setprop("/controls/engines/engine[0]/reverser",1);
            setprop("/controls/engines/engine[1]/reverser",1);
            setprop("/controls/engines/engine[0]/throttle",1);
            setprop("/controls/engines/engine[1]/throttle",1);
            screen.log.write("REV THRUST!");
        } else {
            screen.log.write("Land finished");
            setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
            setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
            setprop("/controls/engines/engine[0]/reverser",0);
            setprop("/controls/engines/engine[1]/reverser",0);
            if (getprop("controls/AI/canchat") == 1){
            setprop("/sim/multiplay/chat", "Drone touched down");
            }
            setprop("/controls/AI/landstage",5);
        }
        setprop("/autopilot/locks/heading", ""); # WE ARE ALIGNED! Stay!
        setprop("/controls/flight/aileron",0);
        setprop("/controls/flight/rudder",0);
        setprop("/controls/gear/brake-parking",1);
        setprop("/autopilot/settings/vertical-speed-fpm", -100); # start to go down

    }
    #setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude
}



# Experimental GPS Landing
# UAV1 landgps
var gpsland = func() {
    var coord1 = geo.Coord.new();  
    var coord2 = geo.Coord.new();  
    var coord3 = geo.Coord.new();
    var ourcoord = geo.aircraft_position();
    var lat1 = getprop("controls/AI/landpos/land1lat"); # Start of the runway
    var lon1 = getprop("controls/AI/landpos/land1lon"); # Start of the runway
    gndelev1 = geo.elevation(lat1, lon1);
    if (gndelev1 != nil){
         print("gndelev: " ~ gndelev1);
     }
    if (gndelev1 == nil){
         # oh no
         gndelev1 = 0;
     }  
    coord1.set_latlon(lat1, lon1, gndelev1);  
    coord2.set_latlon(lat1, lon1, gndelev1); # Duplicate it 
    coord2.apply_course_distance(getprop("controls/AI/landhdg"), getprop("controls/AI/gpsland2dist") * NM2M);
    # Early Runway Guidance
    coord3.set_latlon(lat1, lon1, gndelev1); # Duplicate it 
    oppositerunway = oppfunc(getprop("controls/AI/landhdg"));
    distx2 = getprop("controls/AI/gpsland2dist") * getprop("controls/AI/gpslandmultiplyer");
    coord3.apply_course_distance(oppositerunway, distx2 * NM2M);
    var rng1 = ourcoord.direct_distance_to(coord1) * M2NM;
    var rng2 = ourcoord.direct_distance_to(coord2) * M2NM;
    var rng3 = ourcoord.direct_distance_to(coord3) * M2NM;
    var hdg1 = ourcoord.course_to(coord1); # Start of runway
    var hdg2 = ourcoord.course_to(coord2); # Middle of runway
    var hdg3 = ourcoord.course_to(coord3); # Before Runway
    var bearing = coord1.course_to(coord2);
    var mode = getprop("controls/AI/landstage");
    var modeGPS = getprop("controls/AI/landgps");
    print("landing mode:");
    print(mode);
    print("Landing now");
    if (mode == 0 or mode == 1 or mode == 2){
        screen.log.write("Aiming for pre runway");
        if (getprop("controls/AI/isyasim") == 1){
        setprop("/autopilot/settings/heading-bug-deg",hdg3); # Init runway guidance
        setprop("/autopilot/settings/true-heading-deg",hdg3); # Init runway guidance
        setprop("/autopilot/locks/heading", "dg-heading-hold");
        } else {
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg3); # Init runway guidance
        setprop("/autopilot/settings/true-heading-deg",hdg3); # Init runway guidance
        }
        screen.log.write(rng3);
    }

    if (mode == 2.5){
        screen.log.write("Aiming for start of runway");
        if (getprop("controls/AI/isyasim") == 1){
        setprop("/autopilot/settings/heading-bug-deg",hdg1); # Init runway guidance
        setprop("/autopilot/settings/true-heading-deg",hdg1); # Init runway guidance
        setprop("/autopilot/locks/heading", "dg-heading-hold");
        } else {
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg1); # Init runway guidance
        setprop("/autopilot/settings/true-heading-deg",hdg1); # Init runway guidance
        }
        screen.log.write(rng1);
    }

    if (mode == 3){
        screen.log.write("on final");
        if (getprop("controls/AI/isyasim") == 1){
        setprop("/autopilot/locks/heading", "dg-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg2);
        setprop("/autopilot/settings/true-heading-deg",hdg2);
        } else {
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg2);
        setprop("/autopilot/settings/true-heading-deg",hdg2);
        }
        screen.log.write(rng2);
    }

    if (mode == 0){
        # Ok we are behind the runway to land on. off center  
        setprop("/autopilot/settings/target-speed-kt", 200); # Speed where flaps dont push the plane up too much
        setprop("/controls/gear/gear-down",1); # Gear down
        setprop("controls/AI/landstage",1);
    }
    if (rng3 < 13 and mode == 1){ # wait till UAV is 10nm away from land1
        setprop("/autopilot/locks/altitude", "agl-hold"); # Go down
        setprop("/autopilot/settings/target-agl-ft", getprop("controls/AI/landaltagl")); # Slow down   
        setprop("controls/AI/landstage",2);
        setprop("/autopilot/settings/target-speed-kt",getprop("controls/AI/landspeed")); # Slow down       
    }
    if (rng3 < 0.3 and mode == 2){
        # about to be over prerunway
        setprop("controls/AI/landstage",2.5);   
    }
    if (rng1 < 0.3 and mode == 2.5){
        # about to be over start runway (aligned)

        if (getprop("/controls/AI/landusepitchhold") == 1) {
            # Touch down using the pitch hold
            # Check speedbrake settings
            if (getprop("/controls/AI/landusespeedbrake") == 1) {
                setprop("/controls/flight/speedbrake",1);
            } 
            # Speed check
            if (getprop("velocities/airspeed-kt") < getprop("controls/AI/landfinalspeed")) {
                setprop("/autopilot/locks/altitude", "pitch-hold");
                setprop("/autopilot/settings/target-pitch-deg", getprop("controls/AI/landpitch")); # start to go down
                screen.log.write("Begin Landing Flare");
                # continue on
                setprop("/controls/AI/landstage",3); 
            }
        } else {
            setprop("/autopilot/settings/target-pitch-deg", getprop("controls/AI/landingpitch")); # start to go down
            setprop("/autopilot/locks/altitude", "pitch-hold");
            setprop("/autopilot/settings/vertical-speed-fpm", getprop("controls/AI/landingrate")); # start to go down
            setprop("/controls/AI/landstage",3); 
        }
        setprop("/autopilot/settings/target-speed-kt", getprop("controls/AI/landfinalspeed")); # Slow down      
        setprop("/controls/gear/brake-parking",1);
    }
    var gearwow = 0;
    var gearwow0 = getprop("gear/gear/wow");
    var gearwow1 = getprop("gear/gear[1]/wow");
    var gearwow2 = getprop("gear/gear[2]/wow");
    if (gearwow0 == 1 or gearwow1 == 1 or gearwow2 == 1){
        gearwow = 1; 
        screen.log.write("Gear is on the ground!");
        if (getprop("controls/AI/toucheddown") == 0 and mode == 3){
            if (getprop("controls/AI/canchat") == 1){
            setprop("sim/multiplay/chat", "Touchdown!");
            }
            setprop("controls/AI/toucheddown", 0);
            setprop("controls/AI/landstage",4);
        }
    }
    if (gearwow == 1 and mode == 4){
        # Touch down!
        aitrack.oppositeland.stop();
        setprop("/autopilot/locks/speed", "");
        setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
        setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
        if (getprop("controls/AI/hasrevthrust") == 1 and getprop("velocities/airspeed-kt") > 30){
            setprop("/controls/engines/engine[0]/reverser",1);
            setprop("/controls/engines/engine[1]/reverser",1);
            setprop("/controls/engines/engine[2]/reverser",1);
            setprop("/controls/engines/engine[3]/reverser",1);
            setprop("/controls/engines/engine[0]/throttle",1);
            setprop("/controls/engines/engine[1]/throttle",1);
            setprop("/controls/engines/engine[2]/throttle",1);
            setprop("/controls/engines/engine[3]/throttle",1);
            screen.log.write("REV THRUST!");
        } else {
            screen.log.write("Land finished");
            setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
            setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
            setprop("/controls/engines/engine[2]/throttle",0);
            setprop("/controls/engines/engine[3]/throttle",0);
            setprop("/controls/engines/engine[0]/reverser",0);
            setprop("/controls/engines/engine[1]/reverser",0);
            setprop("/controls/engines/engine[2]/reverser",0);
            setprop("/controls/engines/engine[3]/reverser",0);
            if (getprop("controls/AI/canchat") == 1){
            setprop("/sim/multiplay/chat", "Drone Landing Complete");
            }
            setprop("/controls/AI/landstage",5);
            aitrack.gpslanding.stop();
        }
        setprop("/autopilot/locks/heading", ""); # WE ARE ALIGNED! Stay!
        setprop("/controls/flight/aileron",0);
        setprop("/controls/flight/rudder",0);
        setprop("/controls/gear/brake-parking",1);
        setprop("/autopilot/settings/target-pitch-deg", -3); # start to go down
        setprop("/autopilot/locks/altitude","pitch-hold");
        #setprop("/sim/multiplay/chat", "Drone touched down");
        #setprop("/controls/AI/landstage",5);
    }
    #setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude
}



# Experimental GPS landing Varrient 2
# Experimental GPS Landing
# UAV1 landgps
var gpsland2 = func() {
    var coord1 = geo.Coord.new();  
    var coord2 = geo.Coord.new();  
    var ourcoord = geo.aircraft_position();
    var lat1 = getprop("controls/AI/landpos/land1lat");
    var lon1 = getprop("controls/AI/landpos/land1lon");
    var lat2 = getprop("controls/AI/landpos/land2lat");
    var lon2 = getprop("controls/AI/landpos/land2lon");
    #var lon1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/longitude-deg");
    #var lon2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/longitude-deg");
    #var rng1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/radar/range-nm");
    #var rng2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/radar/range-nm");
    #var hdg2 = getprop("ai/models/multiplayer[" ~ mpid2 ~ "]/radar/bearing-deg");
    #var opposite = 0;
    #   if (hdg2 == 0) {
    #       opposite == 180;
    #   }   elsif (hdg2 > 0) {
    #       opposite = hdg2 - 190;
    #       print(opposite);
    #   }   else {
    #       opposite = hdg2 + 190;
    #       print(opposite);
    #   }
    #   setprop("/controls/AI/oppositeland", opposite);
    # mp1
    gndelev1 = geo.elevation(lat1, lon1);
    if (gndelev1 != nil){
         print("gndelev: " ~ gndelev1);
     }
    if (gndelev1 == nil){
         # oh no
         gndelev1 = 0;
     }  
    coord1.set_latlon(lat1, lon1, gndelev1);  
    coord2.set_latlon(lat2, lon2, gndelev1); # Duplicate it 
    var rng1 = ourcoord.direct_distance_to(coord1) * M2NM;
    var rng2 = ourcoord.direct_distance_to(coord2) * M2NM;
    var hdg1 = ourcoord.course_to(coord1);
    var hdg2 = ourcoord.course_to(coord2);
#2122.16 [INFO]:nasal      19.72140381007823
#2122.16 [INFO]:nasal      -155.0620882010654
    # mp2
    #gndelev2 = geo.elevation(lat2, lon2);
    #if (gndelev2 != nil){
    #     print("gndelev: " ~ gndelev2);
    # }
    #if (gndelev2 == nil){
    #     # oh no
    #     gndelev2 = 0;
    # }  
    #coord2.set_latlon(lat2, lon2, gndelev2);  
    # runway bearing     
    var bearing = coord1.course_to(coord2);
    print("coord1 course to coord2");
    print(bearing);
    #setprop("/autopilot/settings/heading-bug-deg",bearing);
    var mode = getprop("controls/AI/landstage");
    var modeGPS = getprop("controls/AI/landgps");
    print("landing mode:");
    print(mode);
    print("Landing now");
    if (mode == 0 or mode == 1 or mode == 2){

        if (getprop("controls/AI/isyasim") == 1){
        setprop("/autopilot/settings/heading-bug-deg",hdg1);
        setprop("/autopilot/settings/true-heading-deg",hdg1);
        setprop("/autopilot/locks/heading", "dg-heading-hold");
        } else {
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg1);
        setprop("/autopilot/settings/true-heading-deg",hdg1);
        }
        screen.log.write(rng1);
    }
    var gearwow = 0;
    if (mode == 3 or mode == 4 and gearwow != 1){
        if (getprop("controls/AI/isyasim") == 1){
        setprop("/autopilot/locks/heading", "dg-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg2);
        setprop("/autopilot/settings/true-heading-deg",hdg2);
        } else {
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/heading-bug-deg",hdg2);
        setprop("/autopilot/settings/true-heading-deg",hdg2);
        }
        screen.log.write(rng2);
    }

    if (mode == 0){
        # Ok we are behind the runway to land on. off center  
        setprop("/autopilot/settings/target-speed-kt", 200); # Speed where flaps dont push the plane up too much
        setprop("/controls/gear/gear-down",1); # Gear down
        setprop("controls/AI/landstage",1);
    }
    if (rng1 < 13 and mode == 1){ # wait till UAV is 10nm away from land1
        setprop("/autopilot/locks/altitude", "agl-hold"); # Go down
        setprop("/autopilot/settings/target-agl-ft", 280); 
        setprop("controls/AI/landstage",2);
        setprop("/autopilot/settings/target-speed-kt",200);     
    }
    if (rng1 < 0.1 and mode == 2){
    # start landing!
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        setprop("/autopilot/settings/vertical-speed-fpm", -550); # start to go down
        setprop("controls/AI/landstage",3); 
        setprop("/autopilot/settings/target-speed-kt", 175); # Slow down      
    }
    if (rng1 > 0.2 and mode == 3){
        # about to be over the runway
        screen.log.write("In mode 3! passed land1. Get ready to touchdown");
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        aitrack.stop();
        #setprop("/autopilot/locks/heading", "wing-leveler"); # WE ARE ALIGNED! Stay!
        setprop("/autopilot/settings/vertical-speed-fpm", -600); # start to go down
        setprop("controls/AI/landstage",4); # On final
        setprop("/autopilot/settings/target-speed-kt", 110); # Slow down   
        setprop("controls/gear/brake-parking",1);
    } 

    var gearwow0 = getprop("gear/gear/wow"); # Gear on ground detection
    var gearwow1 = getprop("gear/gear[1]/wow"); # Gear on ground detection
    var gearwow2 = getprop("gear/gear[2]/wow"); # Gear on ground detection
    if (gearwow0 == 1 or gearwow1 == 1 or gearwow2 == 1){
        gearwow = 1;
        if (getprop("controls/AI/toucheddown") == 0){
            if (getprop("controls/AI/canchat") == 1){
            setprop("sim/multiplay/chat", "Touchdown");
            }
            setprop("controls/AI/toucheddown", 1);
        }
    }
    if (gearwow == 1 and mode == 4){
        # Touch down!
        aitrack.oppositeland.stop();
        setprop("/autopilot/locks/speed", "");
        setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
        setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
        if (getprop("controls/AI/hasrevthrust") == 1 and getprop("velocities/airspeed-kt") > 30){
            setprop("/controls/engines/engine[0]/reverser",1);
            setprop("/controls/engines/engine[1]/reverser",1);
            setprop("/controls/engines/engine[0]/throttle",1);
            setprop("/controls/engines/engine[1]/throttle",1);
            screen.log.write("REV THRUST!");
        } else {
            screen.log.write("Land finished");
            setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
            setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
            setprop("/controls/engines/engine[0]/reverser",0);
            setprop("/controls/engines/engine[1]/reverser",0);
            if (getprop("controls/AI/canchat") == 1){
            setprop("/sim/multiplay/chat", "Drone touched down");
            }
            setprop("/controls/AI/landstage",5);
            aitrack.gpslanding2.stop();
        }
        setprop("/autopilot/locks/heading", ""); # WE ARE ALIGNED! Stay!
        setprop("/controls/flight/aileron",0);
        setprop("/controls/flight/rudder",0);
        setprop("/controls/gear/brake-parking",1);
        setprop("/autopilot/settings/vertical-speed-fpm", -100); # start to go down
        #setprop("/sim/multiplay/chat", "Drone touched down");
        #setprop("/controls/AI/landstage",5);
    }
    #setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude
}




# Carrier landing

# Version2. no need for a guide boat anymore
var landcarriergps = func() {
var csog = getprop("controls/drone/landcs");
    var cs11 = ""~ csog ~"1";
    var cs22 = "guide";
    print(csog);
    var coord1 = geo.Coord.new();  
    var coord2 = geo.Coord.new();  
    var ourcoord = geo.aircraft_position();
    var lat1 = getprop("controls/AI/landpos/land1lat");
    var lon1 = getprop("controls/AI/landpos/land1lon");
    gndelev1 = geo.elevation(lat1, lon1);
    if (gndelev1 != nil){
         print("gndelev: " ~ gndelev1);
     }
    if (gndelev1 == nil){
         # oh no
         gndelev1 = 0;
     }  

    var mpid1 = aitrack.smallsearch(csog);
    var mpid2 = aitrack.smallsearch(cs22);
    var oppcarrier = oppfunc(getprop("ai/models/multiplayer[" ~ mpid1 ~ "]/orientation/true-heading-deg"));
    screen.log.write(oppcarrier);
    var lat1 = getprop("ai/models/multiplayer[" ~ mpid1 ~ "]/position/latitude-deg");
    var lon1 = getprop("ai/models/multiplayer[" ~ mpid1 ~ "]/position/longitude-deg");
    gndelev1 = geo.elevation(lat1, lon1);
    if (gndelev1 != nil){
         print("gndelev: " ~ gndelev1);
     }
    if (gndelev1 == nil){
         # oh no
         gndelev1 = 0;
     }  

    coord2.set_latlon(lat1, lon1, gndelev1); # Duplicate it 
    var oppcarriercorrected = oppcarrier - getprop("controls/AI/carrieroffset");
    coord2.apply_course_distance(oppcarriercorrected, 1852);
    screen.log.write(coord2.lat());
    screen.log.write(coord2.lon());
    #setprop("position/latitude-deg",coord2.lat());
    #setprop("position/longitude-deg",coord2.lon());
    var hdg2 = ourcoord.course_to(coord2);
#   var coord1 = geo.Coord.new();  
#   var coord2 = geo.Coord.new();  
#   var lat1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/latitude-deg");
#   var lat2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/latitude-deg");
#   var lon1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/longitude-deg");
#   var lon2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/longitude-deg");
    var rng1 = getprop("ai/models/multiplayer[" ~ mpid1 ~ "]/radar/range-nm");
    var guiderng = ourcoord.direct_distance_to(coord2) * M2NM;
    var hdg2 = getprop("instrumentation/tacan/indicated-bearing-true-deg");
    var guidehdg2 = ourcoord.course_to(coord2);


# To land on the carrier you need:
# The carrier, and a small boat that can be used to guide the UAV to the carrier. The guideboats callsign must be: "guide"
# Place the guide boat about 1nm behind the carrier. centered facing the back of the runway.
# Then use the UAV to land.
    var mode = getprop("controls/AI/landstage");
    var modeGPS = getprop("controls/AI/landgps");
    print("Carrier mode:");
    print(mode);
    print("Carrier now");
if (mode == 0 or mode == 1 and mode != 3){
    setprop("/autopilot/settings/true-heading-deg",guidehdg2);
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/locks/altitude", "altitude-hold");

} else {
    if (mode != 3){
        setprop("/controls/AI/bank",1150);
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/true-heading-deg",hdg2 -3);
    }
}


    if (mode == 0){
        # Ok we are behind the carrier to land on. off center
        setprop("/controls/AI/TGTCALLSIGN",csog); # allign with the markers
        #aitrack.start();      
        setprop("/autopilot/settings/target-speed-kt", 180);
        # Speed where flaps dont push the plane up too much
        setprop("/controls/gear/gear-down",1); # Gear down
        setprop("controls/AI/landstage",1);
        setprop("/autopilot/locks/altitude", "altitude-hold"); # Go down
        setprop("/autopilot/settings/target-altitude-ft", 100); 
        setprop("/autopilot/locks/heading", "dg-heading-hold");
    }
    
    if (guiderng < 0.2 and mode == 1){ # wait till UAV is 10nm away from land1
        setprop("controls/AI/landstage",2);
        setprop("/autopilot/settings/target-speed-kt", 180);
    }
    if (getprop("controls/AI/isyasim") == 0 and rng1 < 0.20 and mode == 2){
        # SLAM IT!
        #setprop("/controls/AI/TGTCALLSIGN",cs22); # Engage 2nd marker
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        #setprop("/autopilot/settings/vertical-speed-fpm", -4030); # GO DOWN!
        if (getprop("controls/AI/isyasim") != 1){
        setprop("/autopilot/settings/vertical-speed-fpm", -4030); # GO DOWN! JSB
        } else {
        setprop("/autopilot/settings/vertical-speed-fpm", -1030); # GO DOWN!   
        }
        setprop("/controls/gear/brake-parking",1);
        setprop("controls/AI/landstage",3); 
        setprop("/autopilot/settings/target-speed-kt", 175); # Slow down      
    }
    # Delay it a bit more for yasim planes!
    if (getprop("controls/AI/isyasim") == 1 and rng1 < 0.17 and mode == 2){
        screen.log.write("Yasim slam");
        # SLAM IT!
        #setprop("/controls/AI/TGTCALLSIGN",cs22); # Engage 2nd marker
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        #setprop("/autopilot/settings/vertical-speed-fpm", -4030); # GO DOWN!
        if (getprop("controls/AI/isyasim") != 1){
        setprop("/autopilot/settings/vertical-speed-fpm", -4030); # GO DOWN! JSB
        } else {
        setprop("/autopilot/settings/vertical-speed-fpm", -1030); # GO DOWN!   
        }
        setprop("/controls/gear/brake-parking",1);
        setprop("controls/AI/landstage",3); 
        setprop("/autopilot/settings/target-speed-kt", 175); # Slow down      
    }

    var gearwow = 0;
    var gearwow0 = getprop("gear/gear/wow");
    var gearwow1 = getprop("gear/gear[1]/wow");
    var gearwow2 = getprop("gear/gear[2]/wow");
    if (gearwow0 == 1 or gearwow1 == 1 or gearwow2 == 1){
        gearwow = 1;
        if (getprop("controls/AI/toucheddown") == 0){
            if (getprop("controls/AI/canchat") == 1){
            setprop("sim/multiplay/chat", "A wheel touched on the caRrRiER");
            }
            setprop("controls/AI/toucheddown", 1);
        }
    }
    if (gearwow == 1 and mode == 3){
        # Touch down!
        #aitrack.oppositeland.stop();

        setprop("/controls/flight/speedbrake",1);
        setprop("/autopilot/locks/speed", "");
        setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
        setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
        #setprop("/autopilot/locks/heading", ""); # WE ARE ALIGNED! Stay!
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("/controls/flight/aileron",0);
        setprop("/controls/flight/rudder",0);
        setprop("/controls/gear/brake-parking",1);
        setprop("/autopilot/settings/vertical-speed-fpm", -100); # start to go down
        if (getprop("controls/AI/canchat") == 1){
        setprop("/sim/multiplay/chat", "A wheel touched down on the carrier!");
        }
        setprop("/fdm/jsbsim/external_reactions/hook2/magnitude", "200000"); # For jsbsim
        setprop("/controls/thrust/hook", 1); # For yasim stuff
        setprop("/controls/AI/landstage",4);
        if (getprop("controls/AI/isyasim") == 0){
        aitrack.keepstraight.start();
        }

    }
    var asi = getprop("velocities/airspeed-kt");
    if (asi < 30 and mode == 4){
        # Touch down!
        #aitrack.oppositeland.stop();
        setprop("/controls/flight/speedbrake",0);
        aitrack.stop();
        setprop("/autopilot/locks/heading", "wing-leveler");
        if (getprop("controls/AI/canchat") == 1){
        setprop("/sim/multiplay/chat", "kts < 30! Carrier Landing Complete!");
        }
        setprop("/fdm/jsbsim/external_reactions/hook2/magnitude", "0"); # For jsbsim
        setprop("/controls/thrust/hook", 0); # For yasim stuff
        setprop("/controls/AI/bank",2150);
        aitrack.carrierlanding.stop(); # Stop the script
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("/controls/AI/landstage",0);
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("controls/gear/tailhook",0); 
        setprop("/autopilot/locks/speed", "");
        setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
        setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
        aitrack.stopstraight.start(); # after 15 seconds stop magically auto leveling
    }

    #setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude
}

# Version1
var landcarrier = func() {
var csog = getprop("controls/drone/landcs");
    var cs11 = ""~ csog ~"1";
    var cs22 = "guide";
    print(csog);
#    print(cs22);
#

    var mpid1 = aitrack.smallsearch(csog);
    var mpid2 = aitrack.smallsearch(cs22);
#    var coord1 = geo.Coord.new();  
#    var coord2 = geo.Coord.new();  
#    var lat1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/latitude-deg");
#    var lat2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/latitude-deg");
#    var lon1 = getprop("ai/models/multiplayer["~ mpid1 ~"]/position/longitude-deg");
#    var lon2 = getprop("ai/models/multiplayer["~ mpid2 ~"]/position/longitude-deg");
    var rng1 = getprop("ai/models/multiplayer[" ~ mpid1 ~ "]/radar/range-nm");
    var guiderng = getprop("ai/models/multiplayer["~ mpid2 ~"]/radar/range-nm");
    var hdg2 = getprop("instrumentation/tacan/indicated-bearing-true-deg");
    var guidehdg2 = getprop("ai/models/multiplayer[" ~ mpid2 ~ "]/radar/bearing-deg");


# To land on the carrier you need:
# The carrier, and a small boat that can be used to guide the UAV to the carrier. The guideboats callsign must be: "guide"
# Place the guide boat about 1nm behind the carrier. centered facing the back of the runway.
# Then use the UAV to land.
    var mode = getprop("controls/AI/landstage");
    var modeGPS = getprop("controls/AI/landgps");
    print("Carrier mode:");
    print(mode);
    print("Carrier now");
if (mode == 0 or mode == 1 and mode != 3){

    if (getprop("controls/AI/isyasim") == 0){
    setprop("/controls/AI/bank",1150);
    setprop("/autopilot/settings/true-heading-deg",guidehdg2);
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/locks/altitude", "altitude-hold");
    } else {
    setprop("/controls/AI/bank",1150);
    setprop("/autopilot/settings/heading-bug-deg",guidehdg2);
        setprop("/autopilot/locks/heading", "dg-heading-hold");
        setprop("/autopilot/locks/altitude", "altitude-hold");
    }

} else {
    if (mode != 3){
        setprop("/controls/AI/bank",1150);
        setprop("/autopilot/locks/heading", "true-heading-hold");
        setprop("/autopilot/settings/true-heading-deg",hdg2 -3);
    }
}


    if (mode == 0){
        # Ok we are behind the carrier to land on. off center
        setprop("/controls/AI/TGTCALLSIGN",csog); # allign with the markers
        #aitrack.start();      
        if (getprop("controls/AI/isyasim") != 1){
            setprop("/autopilot/settings/target-speed-kt", 180);
        } else {
            setprop("/autopilot/settings/target-speed-kt", 100);      
            setprop("controls/flight/flaps",1);
            setprop("controls/gear/tailhook",1);
        }
 # Speed where flaps dont push the plane up too much
        setprop("/controls/gear/gear-down",1); # Gear down
        setprop("controls/AI/landstage",1);
        setprop("/autopilot/locks/altitude", "altitude-hold"); # Go down
        setprop("/autopilot/settings/target-altitude-ft", 100); 
        setprop("/autopilot/locks/heading", "dg-heading-hold");
    }
    
    if (guiderng < 0.2 and mode == 1){ # wait till UAV is 10nm away from land1

        setprop("controls/AI/landstage",2);
        if (getprop("controls/AI/isyasim") != 1){
            setprop("/autopilot/settings/target-speed-kt", 180);
        } else {
            setprop("/autopilot/settings/target-speed-kt", 100);      
            setprop("controls/flight/flaps",1);
        }   
    }
    if (rng1 < 0.20 and mode == 2){
        # SLAM IT!
        #setprop("/controls/AI/TGTCALLSIGN",cs22); # Engage 2nd marker
        setprop("/autopilot/locks/altitude", "vertical-speed-hold");
        #setprop("/autopilot/settings/vertical-speed-fpm", -4030); # GO DOWN!
        if (getprop("controls/AI/isyasim") != 1){
        setprop("/autopilot/settings/vertical-speed-fpm", -4030); # GO DOWN! JSB
        } else {
        setprop("/autopilot/settings/vertical-speed-fpm", -1030); # GO DOWN!   
        }
        setprop("/controls/gear/brake-parking",1);
        setprop("controls/AI/landstage",3); 
        setprop("/autopilot/settings/target-speed-kt", 175); # Slow down      
    }
    var gearwow = 0;
    var gearwow0 = getprop("gear/gear/wow");
    var gearwow1 = getprop("gear/gear[1]/wow");
    var gearwow2 = getprop("gear/gear[2]/wow");
    if (gearwow0 == 1 or gearwow1 == 1 or gearwow2 == 1){
        gearwow = 1;
        if (getprop("controls/AI/toucheddown") == 0){
            if (getprop("controls/AI/canchat") == 1){
            setprop("sim/multiplay/chat", "A wheel touched on the caRrRiER");
            }
            setprop("controls/AI/toucheddown", 1);
        }
    }
    if (gearwow == 1 and mode == 3){
        # Touch down!
        #aitrack.oppositeland.stop();
        aitrack.stop();

        setprop("/controls/flight/speedbrake",1);
        setprop("/autopilot/locks/speed", "");
        setprop("/controls/engines/engine[0]/throttle",0); # Engine Throttle Off!
        setprop("/controls/engines/engine[1]/throttle",0); # Engine Throttle Off!
        #setprop("/autopilot/locks/heading", ""); # WE ARE ALIGNED! Stay!
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("/controls/flight/aileron",0);
        setprop("/controls/flight/rudder",0);
        setprop("/controls/gear/brake-parking",1);
        setprop("/autopilot/settings/vertical-speed-fpm", -100); # start to go down
        if (getprop("controls/AI/canchat") == 1){
        setprop("/sim/multiplay/chat", "A wheel touched down on the carrier!");
        }
        setprop("/fdm/jsbsim/external_reactions/hook2/magnitude", "200000"); # For jsbsim
        setprop("/controls/thrust/hook", 1); # For yasim stuff
        setprop("/controls/AI/landstage",4);
        if (getprop("controls/AI/isyasim") == 0){
        aitrack.keepstraight.start();
        }

    }
    var asi = getprop("velocities/airspeed-kt");
    if (asi < 30 and mode == 4){
        # Touch down!
        #aitrack.oppositeland.stop();
        setprop("/controls/flight/speedbrake",0);
        aitrack.stop();
        setprop("/autopilot/locks/heading", "wing-leveler");
        if (getprop("controls/AI/canchat") == 1){
        setprop("/sim/multiplay/chat", "kts < 30! Carrier Landing Complete!");
        }
        setprop("/fdm/jsbsim/external_reactions/hook2/magnitude", "0"); # For jsbsim
        setprop("/controls/thrust/hook", 0); # For yasim stuff
        setprop("/controls/AI/bank",2150);
        aitrack.carrierlanding.stop(); # Stop the script
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("/controls/AI/landstage",0);
        setprop("/autopilot/locks/heading", "wing-leveler");
        setprop("controls/gear/tailhook",0); 

        aitrack.stopstraight.start(); # after 15 seconds stop magically auto leveling
    }


    #setprop("/autopilot/locks/altitude", "agl-hold"); # Maintain MPs altitude

}
 # Init more properties
setprop("controls/AI/bank", 1850);
setprop("controls/AI/oppositeland", 0);
setprop("controls/AI/landstage", 0);
setprop("controls/AI/landhdg", 80);
setprop("controls/AI/toucheddown", 0);
setprop("controls/AI/airport", "PHTO");
setprop("controls/AI/followenabled", 0); # For the autopilot when to control the altitude in a certain way

#
#   AI Long Distance Bombing
#

var coordsetup = func(lat,lon,alt,nocheck=0) {
    var coord = geo.Coord.new();
    var gndelev = alt*FT2M;
    print("coord: lat:" ~ lat);
    print("coord: lon:" ~ lon);
    print("coord: alt:" ~ alt);
    if (nocheck == 0) {
    coord.set_latlon(lat, lon, alt);
    setprop("controls/AI/main/lat",lat);
    setprop("controls/AI/main/lon",lon);
    setprop("controls/AI/main/alt",alt);
    } else {
        if (gndelev <= 0) {
        gndelev = geo.elevation(lat, lon);
       if (gndelev != nil){
            print("gndelev: " ~ gndelev);
        }
       if (gndelev == nil){
            # oh no
            gndelev = 0;
        }
    }
    print(gndelev);
    coord.set_latlon(lat, lon, gndelev);
    setprop("controls/AI/main/lat",lat);
    setprop("controls/AI/main/lon",lon);
    setprop("controls/AI/main/alt",gndelev);
    print("COORD SETUP DONE");
    }
    return coord;
}   





# Coordnite parser






var coordparse = func(callsign,lat,lon,alt) {
  var total = 5;
  var mpid = 1;
  var done = 0;
  for(var i = 0; i < total; i += 1) {
        print("controls/AI/frend" ~ i ~ "/callsign");
        if (done == 0) {
            if (getprop("/controls/AI/frend" ~ i ~ "/callsign") == "None") {
                # Free space!
                var numb = i;
                setprop("controls/AI/frend" ~ numb ~ "/callsign",callsign);
                setprop("controls/AI/frend" ~ numb ~ "/lat",lat);
                setprop("controls/AI/frend" ~ numb ~ "/lon",lon);
                setprop("controls/AI/frend" ~ numb ~ "/alt",alt);
                if (getprop("controls/AI/canchat") == 1){
                setprop("sim/multiplay/chat","Drone data confirmed");     
                }
                checkmodebomber(numb);
                done = 1;
            } else {
                screen.log.write("No more free spaces");
            }
        } else {
            screen.log.write("Ok we done now");
        }
    }
}

var checkmodebomber = func(numb) {
    screen.log.write("checkmodebomber");
    var mode = getprop("controls/drone/bomber-mode");
    if (mode == 0) {

        aibomb(numb);
    }
}


var aibomb = func(numb) {
    var lat = getprop("controls/AI/frend" ~ numb ~ "/lat");
    var lon = getprop("controls/AI/frend" ~ numb ~ "/lon");
    var alt = getprop("controls/AI/frend" ~ numb ~ "/alt");
    var c2 = coordsetup(lat,lon,alt,1);
    var c1 = geo.aircraft_position();
    #bombbay();
    screen.log.write("Turning to bomb!");
    var bearing = c1.course_to(c2);

    var lattgt = getprop("controls/AI/main/lat");
    var lontgt = getprop("controls/AI/main/lon");
    var alttgt = getprop("controls/AI/main/alt");
    screen.log.write(bearing);
    stop();
    setprop("/controls/drone/mode","free-flight");
    setprop("/autopilot/settings/heading-bug-deg",bearing);
    if (getprop("controls/AI/canchat") == 1){
    setprop("/sim/multiplay/chat", "Drone attacking the target");
    }
    startbomb();
}


var checkangleforbomb = func(ammnt=4) {
    var bandithdg = getprop("/orientation/heading-deg");                              
    var bandithdg1 = getprop("/autopilot/settings/heading-bug-deg") - 13;  
    var bandithdg2 = getprop("/autopilot/settings/heading-bug-deg") + 13;
    if(bandithdg > bandithdg1) {
        print("Attack Complies 1/2");
        if(bandithdg < bandithdg2){
            print("Attack Complies 2/2");
            # Where in the heading window of our selected target
            # Begin the bomb drop!
            screen.log.write("Bombs away!");
            setprop("sim/multiplay/chat","Bombs away!");
            var lattgt = getprop("controls/AI/main/lat");
            var lontgt = getprop("controls/AI/main/lon");
            var alttgt = getprop("controls/AI/main/alt");
            var bomb = getprop("controls/drone/bomb");
            dropbomb(lattgt,lontgt,alttgt,bomb);
            stopbomb();
        }
    } else{
        print("Not withen Heading");
    }
}

# coord to geo.Coord.course_to(coord);


#
# Loops!
#

var bombbaytoggle = func(){
    b2.bombbay.toggle();
    timer_bombbay.stop()
}

timer_bomb = maketimer(1, checkangleforbomb);
timer_flare = maketimer(0.001, flares);
timer_evasion = maketimer(5, evasion);
timer_search = maketimer(0.1, search); # High speed refresh for following a tartet
radar_timer = maketimer(0.00001, radarsearch); # As fast as possible refresh for radar
timer_mslcheck = maketimer(5, mslcheck); # missile evasion tech's
#timer_bombbay = maketiemr(1,bombbaytoggle);

var uncrash = func{
		setprop("sim/crashed", "false"); # yasim stuff
}

var maintainroll = func() {
    setprop("/orientation/roll-deg",0); # magicall keep the plane straight on landing (so it dosent roll and fall over. also the aircraft carrier dosent like consuming X-02's!)
    print("magically keeping level");
}

var stoproll = func() {
    aitrack.keepstraight.stop();
    aitrack.stopstraight.stop();
}

loop_timer = maketimer(0.1, uncrash);
loop_timer.start();
landing = maketimer(0.1, land);
gpslanding = maketimer(0.1, gpsland);
gpslanding2 = maketimer(0.1, gpsland2);
keepstraight = maketimer(0.1, maintainroll);
stopstraight = maketimer(13, stoproll);
carrierlanding = maketimer(0.1, landcarriergps);
oppositeland = maketimer(0.1, oppositeland);

timer_attack = maketimer(30, attackreset);
# Reset attack automatically after 20 seconds

# Todo make the sam control center control this timer


print("AI.nas: Ready");
# -----------------------   AI.nas Extensions   ----------------------- #
print("AI.nas: INIT Extensions...");
# Check for external weapons command
print("AI.nas: INIT Weapon Extension...");
var wepext = weaponsextension(0);
if (wepext == 1) {
    print(weaponsextension(1));
    EXTWEP = 1;
    print("AI.nas: Weapon Extension Ready");
}

var test = func() {
    return 1;
}

#               ------------------- End of AI.nas ------------------- 