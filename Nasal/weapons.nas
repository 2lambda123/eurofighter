fire_MG = func {
        if(getprop("controls/armament/stick-selector")==1){
          setprop("/controls/armament/gun-trigger", 1);
        }
        if(getprop("controls/armament/stick-selector")>1){
#          setprop("/controls/armament/trigger", 1);
           var pylon = getprop("controls/armament/missile/current-pylon");
           load.dropLoad(pylon);
        }
}

stop_MG = func {
#        setprop("/controls/armament/trigger", 0); 
        setprop("/controls/armament/gun-trigger", 0); 
}
#var flash_trigger = props.globals.getNode("controls/armament/trigger", 0);

reload_Cannon = func {
        setprop("ai/submodels/submodel/count",150);
        setprop("ai/submodels/submodel[1]/count",150);
        setprop("ai/submodels/submodel[2]/count",150);
        setprop("ai/submodels/submodel[3]/count",150);
}
