# bigradar.nas
# Expermental awacs system
# Phoenix
# requires misc.nas

# can be used with laser.nas
# this is kinda an experimental awacs system for advanced aircraft. 
# such as sats, high altitude planes, and others
# very simple not alot of realism here
var numofmp = 0;


var sending = nil;
var data = nil;
var callsign = nil;

          setprop("instrumentation/datalink/data",1);  # stop reading untill all loops we want are running

var clearsend = func {
    print("stoped");
    sending = nil;
    
        timer_send.stop();
        clear_timer.stop();
}


var clearsendlong = func {
    print("stoped");
    sending = nil;
    data = nil;
    timer_send.stop();
    setprop("instrumentation/datalink/data",0); 
    clear_timer_long.stop();
}


var linksenddata = func() {
    print(callsign);
	datalink.send_data({"contacts":[{"callsign":callsign,"iff":0}]});

}


timer_send = maketimer(0.1, linksenddata);
clear_timer = maketimer(7, clearsend);
clear_timer_long = maketimer(10, clearsendlong);
# Datalink functions
# some inspired by f-16




var run = func {
    misc.smallsearch(); # find every player and start the awacs chain
}


var update = func(miscid,cs){
 #   print("Radar awacs updating");
    # we have mpid
    callsign = cs;
   # print("AWACS sending data!");
    print("mpid: ", miscid);
   # print(cs);
   # print("Sending");
    #timer_send.start();
    #clear_timer.start();
   # print("Sent");
	#datalink.clear_data();
    callsign = cs;
# datalink.send_data({"contacts":[{"callsign":"SAM3","iff":0},{"callsign": "testbad", "iff":0}]} )
    #settimer(, 2);
    #datalink.clear_data();
    # everything is done in misc.nas now. essentially making this file pointless

}

timer_awacs = maketimer(0.5, run);
timer_awacs.start();