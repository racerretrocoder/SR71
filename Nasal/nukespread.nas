# Phoenix!
var spawn = func(lat,lon) {
    var heading = rand() * 360; # if rans is 1: 360 deg
    var distance = rand() * 3; # if rand is 1: 10 nm
    var geocoord = geo.Coord.new();
    var gndelev = 0;
    if (gndelev <= 0) {
        gndelev = geo.elevation(lat, lon);
       if (gndelev != nil) { 
            print("gndelev: " ~ gndelev);
        }
       if (gndelev == nil) {
            gndelev = 0;
        }
    }
    print(gndelev);
    geocoord.set_latlon(lat, lon, gndelev); 
    # Thats the impact point of the bomb
    geocoord.apply_course_distance(heading, distance * NM2M); 
    # Go to a random place!
    var newlat = geocoord.lat();
    var newlon = geocoord.lon();
    # Recalibrate the altitude
    gndelev = geo.elevation(newlat, newlon);
    if (gndelev != nil) {
        print("gndelev: " ~ gndelev);
     }
    if (gndelev == nil) {
        gndelev = 0;
    }
    var static = geo.put_model(getprop("payload/armament/models") ~ "crater_big.xml", newlat, newlon);
    var size = 1;
    print("Spawned a new crater!");
    # send it!
	var uni = int(rand()*15000000);
	var msg = notifications.StaticNotification.new("stat", uni, 1, size);
    # var altM = alt*FT2M;
    msg.Position.set_latlon(newlat,newlon,gndelev); # MUST BE METERS! LEARNED HARD WAY
    msg.IsDistinct = 0;
    msg.Heading = heading;
    notifications.hitBridgedTransmitter.NotifyAll(msg);
	damage.statics["obj_"~uni] = [static, newlat,newlon,gndelev, heading,size];
}