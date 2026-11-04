# INIT radar2.nas
myRadar = radar.Radar.new();
myRadar.init();

setprop("controls/armament/master-arm",1);


var loadasp120 = func() {
    screen.log.write("Loaded 6 ASM-120's");
    setprop("sim/weight[0]/selected","ASM-120");
    setprop("sim/weight[1]/selected","ASM-120");
    setprop("sim/weight[2]/selected","ASM-120");
    setprop("sim/weight[3]/selected","ASM-120");
    setprop("sim/weight[4]/selected","ASM-120");
    setprop("sim/weight[5]/selected","ASM-120");
    setprop("controls/armament/station[0]/release",0);
    setprop("controls/armament/station[1]/release",0);
    setprop("controls/armament/station[2]/release",0);
    setprop("controls/armament/station[3]/release",0);
    setprop("controls/armament/station[4]/release",0);
    setprop("controls/armament/station[5]/release",0);
}

var loadasp120asp9 = func() {
    screen.log.write("Loaded 6 ASM-120's - 2 ASM-9's");
    setprop("sim/weight[0]/selected","ASM-120");
    setprop("sim/weight[1]/selected","ASM-120");
    setprop("sim/weight[2]/selected","ASM-120");
    setprop("sim/weight[3]/selected","ASM-120");
    setprop("sim/weight[4]/selected","ASM-120");
    setprop("sim/weight[5]/selected","ASM-120");
    setprop("sim/weight[6]/selected","ASM-9");
    setprop("sim/weight[7]/selected","ASM-9");
    setprop("controls/armament/station[0]/release",0);
    setprop("controls/armament/station[1]/release",0);
    setprop("controls/armament/station[2]/release",0);
    setprop("controls/armament/station[3]/release",0);
    setprop("controls/armament/station[4]/release",0);
    setprop("controls/armament/station[5]/release",0);
    setprop("controls/armament/station[6]/release",0);
    setprop("controls/armament/station[7]/release",0);
}

var loadsgm120 = func() {
    screen.log.write("Loaded 6 SGM-120's - 2 ASM-120's");
    setprop("sim/weight[0]/selected","SGM-120");
    setprop("sim/weight[1]/selected","SGM-120");
    setprop("sim/weight[2]/selected","SGM-120");
    setprop("sim/weight[3]/selected","SGM-120");
    setprop("sim/weight[4]/selected","SGM-120");
    setprop("sim/weight[5]/selected","SGM-120");
    setprop("sim/weight[6]/selected","ASM-120");
    setprop("sim/weight[7]/selected","ASM-120");
    setprop("controls/armament/station[0]/release",0);
    setprop("controls/armament/station[1]/release",0);
    setprop("controls/armament/station[2]/release",0);
    setprop("controls/armament/station[3]/release",0);
    setprop("controls/armament/station[4]/release",0);
    setprop("controls/armament/station[5]/release",0);
    setprop("controls/armament/station[6]/release",0);
    setprop("controls/armament/station[7]/release",0);
}