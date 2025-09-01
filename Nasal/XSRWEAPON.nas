
myRadar = radar.Radar.new();
myRadar.init();

var triggerloop = func() {
    setprop("sim/multiplay/visibility-range-nm",2000);
    if (getprop("controls/armament/trigger") == 1) {
        if (getprop("controls/weapontype") == 1) {
            laser();
        }
    }
}



var laser = func() {
 var callsign = radar.tgts_list[radar.Target_Index].Callsign.getValue();
 #var msg = notifications.ArmamentNotification.new("mhit", 4, damage.DamageRecipient.typeID2emesaryID(35));
 #msg.RelativeAltitude = 0;
 #msg.Bearing = 2;
 #msg.Distance = 1;
 #msg.RemoteCallsign = callsign;
 #notifications.hitBridgedTransmitter.NotifyAll(msg);
 var msg = notifications.ArmamentNotification.new("mhit", 4, -1*(damage.shells["M61A1 shell"][0]+1));
 msg.RelativeAltitude = 0;
 msg.Bearing = 0;
 msg.Distance = 8;
 msg.RemoteCallsign = callsign;
 notifications.hitBridgedTransmitter.NotifyAll(msg);
 screen.log.write("Firing laser at " ~ callsign ~ "!");
}


trigloop = maketimer(0.1,triggerloop);
trigloop.start();