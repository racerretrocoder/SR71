### Main SR-71 File ###

#Important global variables
MAIN_UPDATE_TIMER = 0.2;
SLOW_UPDATE_TIMER = 0.7;
var clamp = func(v, min, max) { v < min ? min : v > max ? max : v }
var cit_max = 427;
var ab_state = {};
ab_state[0] = 0;
ab_state[1] = 0;
setprop("orientation/beta-deg-added",0.1);
#path locations
var engine_damage = ["/engines/engine[0]/eng-damage","/engines/engine[1]/eng-damage"];
var cit_path = "/fdm/jsbsim/propulsion/cit";
var cit_left = "/engines/engine[0]/cit";
var cit_left_rand_offset = "/engines/engine[0]/cit-rand-offset";
var cit_left_alt_offset = "/engines/engine[0]/cit-alt-offset";
var cit_right = "/engines/engine[1]/cit";
var cit_right_rand_offset = "/engines/engine[1]/cit-rand-offset";
var cit_right_alt_offset = "/engines/engine[1]/cit-alt-offset";


var spacebetaupdate = func(){
	var addedbeta = getprop("fdm/jsbsim/fcs/beta-deg-added");
	var ourhdg = getprop("orientation/true-heading-deg");
	if (addedbeta > 90) {
		# we passwed 360
		print("Adjusted heading");
		var newdeg = addedbeta - 360;
		setprop("orientation/beta-deg-added",newdeg);
	} else {
		setprop("orientation/beta-deg-added",addedbeta);
	}
}

#initial sets
setprop(engine_damage[0],0);
setprop(engine_damage[1],0);
setprop(cit_left_rand_offset,0);
setprop(cit_left_alt_offset,0);
setprop(cit_right_rand_offset,0);
setprop(cit_right_alt_offset,0);
setprop("orientation/realcourse",1.3);
#Fast updating
var main = func () {
	
	#Do CIT stuff.

	#TEB - if throttle is over 55%, decrement teb. this is where A/B kicks in.
	for ( var i = 0 ; i < 2 ; i = i + 1 ) {
		if ( getprop("/controls/engines/engine["~i~"]/throttle") >= 0.55 and ab_state[i] == 0 ) {
			ab_state[i] = 1;
		} elsif ( getprop("/controls/engines/engine["~i~"]/throttle") <= 0.55 and ab_state[i] == 1 )  {
			ab_state[i] = 0;
		}
	}
	
	

	
	settimer(func { main(); }, MAIN_UPDATE_TIMER);
	
}





	# startup procedures

	# Disable engines if engine damage > 1. They melted.

	if ( getprop(engine_damage[0]) >= 1 ) {
		setprop("/sim/failure-manager/engines/engine[0]/serviceable",0);
	}

	if ( getprop(engine_damage[1]) >= 1 ) {
		setprop("/sim/failure-manager/engines/engine[1]/serviceable",0);
	}


var start_engine = func(v, stage) {
	for ( var i = 0 ; i < 2 ; i = i + 1 ) {
		if ( getprop("sim/input/selected/engine["~i~"]") == 1 ) {
			setprop("/controls/engines/engine["~i~"]/starter",v);
			if ( stage == 2 ) {
				print("ae");
			}
		}
	}	
}


var unstart = func() {
	setprop("/fdm/jsbsim/fcs/cutoff-switch0",0);
	setprop("/fdm/jsbsim/fcs/cutoff-switch1",0);
}

#init functions
main();

var trigger = func() {

	if (getprop("controls/armament/trigger") == 1){
		setprop("controls/flight/JAL",1000);
	} else {
		setprop("controls/flight/JAL",0);
	}
}
trigtimer = maketimer(0.1,trigger);
trigtimer.start();
betatimer = maketimer(0,spacebetaupdate);
betatimer.start();

 
var updatehdg = func() {
	var direction = getprop("orientation/heading-deg") + getprop("orientation/side-slip-deg");
	
	
	
var course = getprop("fdm/jsbsim/velocities/course-deg");
	if (course < 0){
		course = course + 360;
		setprop("orientation/realcourse",course);
	}
	var totaldirection = course - getprop("orientation/heading-deg");
	var ans = totaldirection;
		setprop("orientation/realcourse",course);
	setprop("orientation/direction-heading-deg",ans);
# Space check
	if (getprop("position/altitude-ft") > 100000) {
		setprop("controls/isspace",1);
	} else {
		setprop("controls/isspace",0);
	}

# Orbit check
	if (getprop("fdm/jsbsim/systems/orbital/apoapsis-ft") > 400000 and getprop("fdm/jsbsim/systems/orbital/periapsis-ft") > 400000) {
		setprop("controls/isorbit",1);
	} else {
		setprop("controls/isorbit",0);
	}

# autopilot controls check
	var newsetting = course + getprop("autopilot/settings/heading-bug-deg");
	setprop("autopilot/settings/side-slip-angle",newsetting);

}



hdgtimer = maketimer(0,updatehdg);
hdgtimer.start();                            