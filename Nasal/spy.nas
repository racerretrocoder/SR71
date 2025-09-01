# spy.nas
# written by Phoenix
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

# SC
var SC = func() {
    inittimer.stop();
    var num1 = phoenixcommnet.generatetestnum();
    var num2 = phoenixcommnet.gettestanaser();
    if (num1 == num2 / 2){
        screen.log.write("SPY.nas INIT:");
        setprop("controls/SPY/mode",0); 
        setprop("controls/SPY/mpchat/last","");
        setprop("controls/SPY/pilotlist/lastnum",0);
        setprop("controls/SPY/generalposition","");
        ae.start();
    }
}

var underscoreify = func(string1) {
    var string2 = string.replace(string1," ","_"); # make it compatible with phoenixcommnet
    return string2;
}

var sendmessage = func(message) {
    var string1 = ""~getprop("sim/multiplay/callsign")~": "~message~"";
    var string2 = string.replace(string1," ","_"); # make it compatible with phoenixcommnet
    var string3 = string.replace(string2,"+","plus"); # make it compatible with phoenixcommnet
    screen.log.write(string3);
    phoenixcommnet.sendmessage(string3);
}


var mainloop = func() {
    # spy.nas : Mainloop
    var mode = getprop("controls/SPY/mode");
    if (mode == 0) {
        # MP Chat logging mode
        var history = getprop("sim/multiplay/chat-history");
        var historyvector = split("\n", history);
        if (size(historyvector) > 0) {
            var last = historyvector[size(historyvector)-1];
            if (last != getprop("controls/SPY/mpchat/last")) {
                # New message was sent!
                setprop("controls/SPY/mpchat/last",last);
                sendmessage("MPCHATLOG: "~last~"");
                var last_vector = split(" ", last);
                screen.log.write(last);
            }
        }
    }
    if (mode == 1) {
        # Pilot list logging mode. detect joins
        multiplayer.dialog.show();
        var list = props.globals.getNode("/ai/models").getChildren("multiplayer");
        var total = size(list);
        var numplayers = getprop("ai/models/num-players");
        var mpid = 0;
        if (getprop("controls/SPY/pilotlist/lastnum") != numplayers){
            screen.log.write("pilot list changed!");
            setprop("controls/SPY/pilotlist/lastnum",numplayers);
            var themessage = "Pilot List changed:~```";
            var fighterpresent = 0;
            for(var i = 0; i < total; i += 1) {
                # Code loops for every MP
                var mpid = i;
                var callsign = getprop("ai/models/multiplayer["~i~"]/callsign");
                if (getprop("ai/models/multiplayer["~i~"]/valid") == 1){
                    # this guy is online
                    setprop("ai/models/multiplayer[" ~ mpid ~ "]/model-installed",1); # this is to make the model name be without "[]" ae!
                    var plane = getprop("ai/models/multiplayer[" ~ mpid ~ "]/model-short"); # What they are flying
                    # the plane variable only works if the mplist was toggled at least once! mplist must be shown again if they change planes
                    var shortType = "nil"; # lol
                    var stealth = 0;
                    # threat database
                    if (plane == "ADF-11F"){ # Dont do this yet
                        shortType = "Raven";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    if (plane == "F-16"){
                        shortType = "F-16";
                        fighterpresent = 1;
                    }
                    if (plane == "F-15C"){
                        shortType = "F-15C";
                        fighterpresent = 1;
                    }
                    if (plane == "F-15D"){
                        shortType = "F-15D";
                        fighterpresent = 1;
                    }
                    if (plane == "f-14b"){
                        shortType = "F-14B";
                        fighterpresent = 1;
                    }
                    if (plane == "F-22-Raptor"){
                        shortType = "F-22-Raptor";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    if (plane == "F-35A"){
                        shortType = "F-35A";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    if (plane == "F-35B"){
                        shortType = "F-35B";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    if (plane == "F-35C"){
                        shortType = "F-35C";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    if (plane == "X-02a"){
                        shortType = "Wyvern";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    if (plane == "X-02S"){
                        shortType = "Strike Wyvern";
                        fighterpresent = 1;
                        stealth = 1;
                    }
                    # end the calls!
                    # now is this plane a dogfighter?
                    if (shortType != "nil"){
                        themessage = ""~themessage~"Pilot:_"~callsign~"_Model:"~shortType~"_Fighter_Jet_Detected~";          
                        screen.log.write(themessage);
                    } else {
                        var model = getprop("ai/models/multiplayer["~mpid~"]/model/");
                        themessage = ""~themessage~"Pilot:_"~callsign~"_Model:_"~plane~"~";
                        print(themessage);
                        screen.log.write(themessage);
                    }
                }
            }
            themessage = ""~themessage~"```";
            screen.log.write(themessage);
            sendmessage(themessage);
        }
    }
}
inittimer = maketimer(10,SC);
inittimer.start();
ae = maketimer(1,mainloop);
print("SPY.nas: Ready");