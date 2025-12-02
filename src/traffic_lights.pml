// Object types on the crossroad
mtype:traffic_light_color = {RED, GREEN};

// Defined objects on the crossroad
// Defined traffic lights
mtype:traffic_light_color tlc_SD = RED;
mtype:traffic_light_color tlc_DN = RED;
mtype:traffic_light_color tlc_NS = RED;
mtype:traffic_light_color tlc_DE = RED;
mtype:traffic_light_color tlc_SW = RED;
mtype:traffic_light_color tlc_ES = RED;
mtype:traffic_light_color tlc_NE = RED;
mtype:traffic_light_color tlc_SN = RED;

// Defined car presence sensors
bool cp_SD = false;
bool cp_DN = false;
bool cp_NS = false;
bool cp_DE = false;
bool cp_SW = false;
bool cp_ES = false;
bool cp_NE = false;
bool cp_SN = false;

// Defined locks for each traffic light
bool lock_SD = false;
bool lock_DN = false;
bool lock_NS = false;
bool lock_DE = false;
bool lock_SW = false;
bool lock_ES = false;
bool lock_NE = false;
bool lock_SN = false;

// Safety: G!((N_light=Green)||(S_light=Green)&(E_light=Green))
ltl safety_SD { [] !((tlc_DE == GREEN || tlc_ES == GREEN || tlc_DN == GREEN || tlc_NS == GREEN) && tlc_SD == GREEN) }
ltl safety_DN { [] !((tlc_NS == GREEN || tlc_SD == GREEN || tlc_DN == GREEN) && tlc_DN == GREEN) }
ltl safety_NS { [] !((tlc_SD == GREEN || tlc_DN == GREEN || tlc_DE == GREEN || tlc_SW == GREEN) && tlc_NS == GREEN) }
ltl safety_DE { [] !((tlc_NS == GREEN || tlc_ES == GREEN || tlc_SD == GREEN || tlc_SN == GREEN) && tlc_DE == GREEN) }
ltl safety_SW { [] !((tlc_SW == GREEN || tlc_NS == GREEN) && tlc_SW == GREEN) }
ltl safety_ES { [] !((tlc_SN == GREEN || tlc_NE == GREEN || tlc_SD == GREEN || tlc_DE == GREEN || tlc_SW == GREEN) && tlc_ES == GREEN) }
ltl safety_NE { [] !((tlc_DN == GREEN || tlc_ES == GREEN || tlc_SN == GREEN) && tlc_NE == GREEN) }
ltl safety_SN { [] !((tlc_DN == GREEN || tlc_NE == GREEN || tlc_ES == GREEN) && tlc_SN == GREEN) }

// Liveness: G(N_sense & (N_light=Red)->F(S_light=Green))
ltl liveness_SD { [] ((cp_SD && tlc_SD == RED) -> <> (tlc_SD == GREEN)) }
ltl liveness_DN { [] ((cp_DN && tlc_DN == RED) -> <> (tlc_DN == GREEN)) }
ltl liveness_NS { [] ((cp_NS && tlc_NS == RED) -> <> (tlc_NS == GREEN)) }
ltl liveness_DE { [] ((cp_DE && tlc_DE == RED) -> <> (tlc_DE == GREEN)) }
ltl liveness_SW { [] ((cp_SW && tlc_SW == RED) -> <> (tlc_SW == GREEN)) }
ltl liveness_ES { [] ((cp_ES && tlc_ES == RED) -> <> (tlc_ES == GREEN)) }
ltl liveness_NE { [] ((cp_NE && tlc_NE == RED) -> <> (tlc_NE == GREEN)) }
ltl liveness_SN { [] ((cp_SN && tlc_SN == RED) -> <> (tlc_SN == GREEN)) }

// Fairness: GF!((N_light=Green)&N_sense)
ltl fairness_SD { [] <> !((tlc_SD == GREEN) && cp_SD) }
ltl fairness_DN { [] <> !((tlc_DN == GREEN) && cp_DN) }
ltl fairness_NS { [] <> !((tlc_NS == GREEN) && cp_NS) }
ltl fairness_DE { [] <> !((tlc_DE == GREEN) && cp_DE) }
ltl fairness_SW { [] <> !((tlc_SW == GREEN) && cp_SW) }
ltl fairness_ES { [] <> !((tlc_ES == GREEN) && cp_ES) }
ltl fairness_NE { [] <> !((tlc_NE == GREEN) && cp_NE) }
ltl fairness_SN { [] <> !((tlc_SN == GREEN) && cp_SN) }


proctype traffic_light_controller_SD() {
    do
    :: (cp_SD && tlc_SD == RED) -> {
        atomic {
            (!lock_DE && !lock_ES && !lock_DN && !lock_NS); lock_SD = true;
        }
        tlc_SD = GREEN;
    };
    :: (!cp_SD && tlc_SD == GREEN) -> {
        lock_SD = false; tlc_SD = RED;
    };
    od;
}

proctype traffic_light_controller_DN() {
    do
    :: (cp_DN && tlc_DN == RED) -> {
        
        atomic {
            (!lock_NS && !lock_SD && !lock_DN); lock_DN = true;
        }
        tlc_DN = GREEN;
    };
    :: (!cp_DN && tlc_DN == GREEN) -> {
        lock_DN = false; tlc_DN = RED;
    };
    od;
}

proctype traffic_light_controller_NS() {
    do
    :: (cp_NS && tlc_NS == RED) -> {
        atomic {
            (!lock_SD && !lock_DN && !lock_DE && !lock_SW); lock_NS = true;
        }
        tlc_NS = GREEN;
    };
    :: (!cp_NS && tlc_NS == GREEN) -> {
        lock_NS = false; tlc_NS = RED;
    };
    od;
}

proctype traffic_light_controller_DE() {
    do
    :: (cp_DE && tlc_DE == RED) -> {
        
        atomic {
            (!lock_NS && !lock_ES && !lock_SD && !lock_SN); lock_DE = true;
        }
        tlc_DE = GREEN;
    };
    :: (!cp_DE && tlc_DE == GREEN) -> {
        lock_DE = false; tlc_DE = RED;
    };
    od;
}

proctype traffic_light_controller_SW() {
    do
    :: (cp_SW && tlc_SW == RED) -> {
        atomic {
            (!lock_ES && !lock_NS); lock_SW = true;
        }
        tlc_SW = GREEN;
    };
    :: (!cp_SW && tlc_SW == GREEN) -> {
        lock_SW = false; tlc_SW = RED;
    };
    od;
}

proctype traffic_light_controller_ES() {
    do
    :: (cp_ES && tlc_ES == RED) -> {
        atomic {
            (!lock_SN && !lock_NE && !lock_SD && !lock_DE && !lock_SW); lock_ES = true;
        }
        tlc_ES = GREEN;
    };
    :: (!cp_ES && tlc_ES == GREEN) -> {
        lock_ES = false; tlc_ES = RED;
    };
    od;
}

proctype traffic_light_controller_NE() {
    do
    :: (cp_NE && tlc_NE == RED) -> {
        atomic {
            (!lock_DN && !lock_ES && !lock_SN); lock_NE = true;
        }
        tlc_NE = GREEN;
    };
    :: (!cp_NE && tlc_NE == GREEN) -> {
        lock_NE = false; tlc_NE = RED;
    };
    od;
}

proctype traffic_light_controller_SN() {
    do
    :: (cp_SN && tlc_SN == RED) -> {
        atomic {
            (!lock_DE && !lock_NE && !lock_ES); lock_SN = true;
        }
        tlc_SN = GREEN;
    };
    :: (!cp_SN && tlc_SN == GREEN) -> {
        lock_SN = false; tlc_SN = RED;
    };
    od;
}

proctype environment() {
	do
	:: (!cp_SD && tlc_SD == RED) -> cp_SD = true;
	:: (!cp_DN && tlc_DN == RED) -> cp_DN = true;
	:: (!cp_NS && tlc_NS == RED) -> cp_NS = true;
	:: (!cp_DE && tlc_DE == RED) -> cp_DE = true;
	:: (!cp_SW && tlc_SW == RED) -> cp_SW = true;
	:: (!cp_ES && tlc_ES == RED) -> cp_ES = true;
    :: (!cp_NE && tlc_NE == RED) -> cp_NE = true;
	:: (!cp_SN && tlc_SN == RED) -> cp_SN = true;

	:: (cp_SD && tlc_SD == GREEN) -> cp_SD = false;
	:: (cp_DN && tlc_DN == GREEN) -> cp_DN = false;
	:: (cp_NS && tlc_NS == GREEN) -> cp_NS = false;
	:: (cp_DE && tlc_DE == GREEN) -> cp_DE = false;
	:: (cp_SW && tlc_SW == GREEN) -> cp_SW = false;
	:: (cp_ES && tlc_ES == GREEN) -> cp_ES = false;
    :: (cp_NE && tlc_NE == GREEN) -> cp_NE = false;
	:: (cp_SN && tlc_SN == GREEN) -> cp_SN = false;
	od;
}

init {
    atomic {
        run environment();
        run traffic_light_controller_SD();
        run traffic_light_controller_DN();
        run traffic_light_controller_NS();
        run traffic_light_controller_DE();
        run traffic_light_controller_SW();
        run traffic_light_controller_ES();
        run traffic_light_controller_NE();
        run traffic_light_controller_SN();
    }
}
