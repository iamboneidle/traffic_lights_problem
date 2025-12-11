#define DIRECTIONS_QUANTITY 6
/* 
Матрица пересечений
   DN NS DE SW ES NE
DN  0  1  0  0  0  1
NS  1  0  1  1  0  0
DE  0  1  0  0  1  0
SW  0  1  0  0  1  0
ES  0  0  1  1  0  1
NE  1  0  0  0  1  0
*/

ltl DN_LIVENESS { [] (
    (DN_CONTROLLER:sensor_msg == YES_TRAFFIC && (DN_CONTROLLER:color == RED)) -> 
    (<> (DN_CONTROLLER:color == GREEN))
)};
ltl NS_LIVENESS { [] (
    (NS_CONTROLLER:sensor_msg == YES_TRAFFIC && (NS_CONTROLLER:color == RED)) -> 
    (<> (NS_CONTROLLER:color == GREEN))
)};
ltl DE_LIVENESS { [] (
    (DE_CONTROLLER:sensor_msg == YES_TRAFFIC && (DE_CONTROLLER:color == RED)) -> 
    (<> (DE_CONTROLLER:color == GREEN))
)};
ltl SW_LIVENESS { [] (
    (SW_CONTROLLER:sensor_msg == YES_TRAFFIC && (SW_CONTROLLER:color == RED)) -> 
    (<> (SW_CONTROLLER:color == GREEN))
)};
ltl ES_LIVENESS { [] (
    (ES_CONTROLLER:sensor_msg == YES_TRAFFIC && (ES_CONTROLLER:color == RED)) -> 
    (<> (ES_CONTROLLER:color == GREEN))
)};
ltl NE_LIVENESS { [] (
    (NE_CONTROLLER:sensor_msg == YES_TRAFFIC && (NE_CONTROLLER:color == RED)) -> 
    (<> (NE_CONTROLLER:color == GREEN))
)};

ltl DN_SAFETY { [] !(
    (DN_CONTROLLER:color == GREEN) && (
        (NS_CONTROLLER:color == GREEN) ||
        (NE_CONTROLLER:color == GREEN)
    )
)};

ltl NS_SAFETY { [] !(
    (NS_CONTROLLER:color == GREEN) && (
        (DN_CONTROLLER:color == GREEN) ||
        (DE_CONTROLLER:color == GREEN) ||
        (SW_CONTROLLER:color == GREEN)
    )
)};

ltl DE_SAFETY { [] !(
    (DE_CONTROLLER:color == GREEN) && (
        (NS_CONTROLLER:color == GREEN) ||
        (ES_CONTROLLER:color == GREEN)
    )
)};

ltl SW_SAFETY { [] !(
    (SW_CONTROLLER:color == GREEN) && (
        (NS_CONTROLLER:color == GREEN) ||
        (ES_CONTROLLER:color == GREEN)
    )
)};

ltl ES_SAFETY { [] !(
    (ES_CONTROLLER:color == GREEN) && (
        (DE_CONTROLLER:color == GREEN) ||
        (SW_CONTROLLER:color == GREEN) ||
        (NE_CONTROLLER:color == GREEN)
    )
)};

ltl NE_SAFETY { [] !(
    (NE_CONTROLLER:color == GREEN) && (
        (DN_CONTROLLER:color == GREEN) ||
        (ES_CONTROLLER:color == GREEN)
    )
)};

ltl DN_FAIRNESS { [] 
    (<> !(
        DN_CONTROLLER:color == GREEN && 
        DN_CONTROLLER:sensor_msg == YES_TRAFFIC
    ))
};

ltl NS_FAIRNESS { [] 
    (<> !(
        NS_CONTROLLER:color == GREEN && 
        NS_CONTROLLER:sensor_msg == YES_TRAFFIC
    ))
};

ltl DE_FAIRNESS { [] 
    (<> !(
        DE_CONTROLLER:color == GREEN && 
        DE_CONTROLLER:sensor_msg == YES_TRAFFIC
    ))
};

ltl SW_FAIRNESS { [] 
    (<> !(
        SW_CONTROLLER:color == GREEN && 
        SW_CONTROLLER:sensor_msg == YES_TRAFFIC
    ))
};

ltl ES_FAIRNESS { [] 
    (<> !(
        ES_CONTROLLER:color == GREEN && 
        ES_CONTROLLER:sensor_msg == YES_TRAFFIC
    ))
};

ltl NE_FAIRNESS { [] 
    (<> !(
        NE_CONTROLLER:color == GREEN && 
        NE_CONTROLLER:sensor_msg == YES_TRAFFIC
    ))
};

mtype = { 
    CHECK_TRAFFIC, YES_TRAFFIC, NO_TRAFFIC,
    ASK, FREE, LET,
    RED, GREEN,
    DN, NS, DE, SW, ES, NE
}

typedef RoundRobinParticipant {
    chan sensor_request;
    chan sensor_response;
    chan controller_request;
    chan controller_response;
    mtype dir_name;
};
RoundRobinParticipant participants[DIRECTIONS_QUANTITY]

typedef INTERSECTIONS_ARRAY {
    byte arr[DIRECTIONS_QUANTITY];
}
INTERSECTIONS_ARRAY intersections_config[DIRECTIONS_QUANTITY];


chan DN_SENSOR_REQUEST      = [0] of { mtype };
chan DN_SENSOR_RESPONSE     = [0] of { mtype };
chan DN_CONTROLLER_REQUEST  = [0] of { mtype };
chan DN_CONTROLLER_RESPONSE = [0] of { mtype };

chan NS_SENSOR_REQUEST      = [0] of { mtype };
chan NS_SENSOR_RESPONSE     = [0] of { mtype };
chan NS_CONTROLLER_REQUEST  = [0] of { mtype };
chan NS_CONTROLLER_RESPONSE = [0] of { mtype };

chan DE_SENSOR_REQUEST      = [0] of { mtype };
chan DE_SENSOR_RESPONSE     = [0] of { mtype };
chan DE_CONTROLLER_REQUEST  = [0] of { mtype };
chan DE_CONTROLLER_RESPONSE = [0] of { mtype };

chan SW_SENSOR_REQUEST      = [0] of { mtype };
chan SW_SENSOR_RESPONSE     = [0] of { mtype };
chan SW_CONTROLLER_REQUEST  = [0] of { mtype };
chan SW_CONTROLLER_RESPONSE = [0] of { mtype };

// ###################################################################
// ###################################################################
chan ES_SENSOR_REQUEST      = [0] of { mtype };
chan ES_SENSOR_RESPONSE     = [0] of { mtype };
chan ES_CONTROLLER_REQUEST  = [0] of { mtype };
chan ES_CONTROLLER_RESPONSE = [0] of { mtype };

chan NE_SENSOR_REQUEST      = [0] of { mtype };
chan NE_SENSOR_RESPONSE     = [0] of { mtype };
chan NE_CONTROLLER_REQUEST  = [0] of { mtype };
chan NE_CONTROLLER_RESPONSE = [0] of { mtype };
// ###################################################################
// ###################################################################


proctype ROUND_ROBIN() {
    mtype message_in_channel;
    bool requested[DIRECTIONS_QUANTITY] = false;
    bool granted[DIRECTIONS_QUANTITY] = false;
    byte curr = 0;
    byte curr_message = 0;

    do
    ::
        do
        :: curr_message < DIRECTIONS_QUANTITY ->
            if 
            :: participants[curr_message].controller_request ? message_in_channel ->
                if
                :: message_in_channel == ASK -> requested[curr_message] = true
                :: message_in_channel == FREE -> granted[curr_message] = false
                fi;
                curr_message = (curr_message + 1) % DIRECTIONS_QUANTITY;
                break;
            fi;
            curr_message = (curr_message + 1) % DIRECTIONS_QUANTITY;
            break;
        od;
        
        bool conjunction_result;

        do
        :: curr < DIRECTIONS_QUANTITY ->
            if
            :: requested[curr] ->
                if
                    :: intersections_config[curr].arr[0] == 1 && granted[0] -> conjunction_result = false
                    :: intersections_config[curr].arr[1] == 1 && granted[1] -> conjunction_result = false
                    :: intersections_config[curr].arr[2] == 1 && granted[2] -> conjunction_result = false
                    :: intersections_config[curr].arr[3] == 1 && granted[3] -> conjunction_result = false
// ###################################################################
// ###################################################################
                    :: intersections_config[curr].arr[4] == 1 && granted[4] -> conjunction_result = false
                    :: intersections_config[curr].arr[5] == 1 && granted[5] -> conjunction_result = false
// ###################################################################
// ###################################################################
                    :: else -> conjunction_result = true
                fi;

                if
                :: conjunction_result ->
                    granted[curr] = true;
                    requested[curr] = false;
                    participants[curr].controller_response ! LET;
                    curr = (curr + 1) % DIRECTIONS_QUANTITY;
                    break;
                :: else ->
                    curr = (curr + 1) % DIRECTIONS_QUANTITY;
                fi;
            :: else -> 
                curr = (curr + 1) % DIRECTIONS_QUANTITY;
                break;
             fi;
        od;
    od;
}


proctype DN_CONTROLLER() {
    mtype sensor_msg;
    mtype round_robin_msg;
    mtype color = RED;

    do
    :: color == RED ->
        participants[0].sensor_request ! CHECK_TRAFFIC;
        participants[0].sensor_response ? sensor_msg;
        if
        :: sensor_msg == NO_TRAFFIC ->
            skip;
        :: sensor_msg == YES_TRAFFIC ->
            participants[0].controller_request ! ASK;
            participants[0].controller_response ? round_robin_msg;
            if
            :: round_robin_msg == LET -> color = GREEN;
            fi;
        fi;
    :: color == GREEN ->
        color = RED;
        participants[0].controller_request ! FREE
    od;
}

proctype DN_SENSOR() {
    mtype controller_msg;

    do
    :: 
        participants[0].sensor_request ? controller_msg;
        if
        :: controller_msg == CHECK_TRAFFIC ->
            if
            :: participants[0].sensor_response ! YES_TRAFFIC;
            :: participants[0].sensor_response ! NO_TRAFFIC;
            fi;
        fi;
    od;
}


proctype NS_CONTROLLER() {
    mtype sensor_msg;
    mtype round_robin_msg;
    mtype color = RED;

    do
    :: color == RED ->
        participants[1].sensor_request ! CHECK_TRAFFIC;
        participants[1].sensor_response ? sensor_msg;
        if
        :: sensor_msg == NO_TRAFFIC ->
            skip;
        :: sensor_msg == YES_TRAFFIC ->
            participants[1].controller_request ! ASK;
            participants[1].controller_response ? round_robin_msg;
            if
            :: round_robin_msg == LET -> color = GREEN;
            fi;
        fi;
    :: color == GREEN ->
        color = RED;
        participants[1].controller_request ! FREE
    od;
}

proctype NS_SENSOR() {
    mtype controller_msg;

    do
    :: 
        participants[1].sensor_request ? controller_msg;
        if
        :: controller_msg == CHECK_TRAFFIC ->
            if
            :: participants[1].sensor_response ! YES_TRAFFIC;
            :: participants[1].sensor_response ! NO_TRAFFIC;
            fi;
        fi;
    od;
}


proctype DE_CONTROLLER() {
    mtype sensor_msg;
    mtype round_robin_msg;
    mtype color = RED;

    do
    :: color == RED ->
        participants[2].sensor_request ! CHECK_TRAFFIC;
        participants[2].sensor_response ? sensor_msg;
        if
        :: sensor_msg == NO_TRAFFIC ->
            skip;
        :: sensor_msg == YES_TRAFFIC ->
            participants[2].controller_request ! ASK;
            participants[2].controller_response ? round_robin_msg;
            if
            :: round_robin_msg == LET -> color = GREEN;
            fi;
        fi;
    :: color == GREEN ->
        color = RED;
        participants[2].controller_request ! FREE
    od;
}

proctype DE_SENSOR() {
    mtype controller_msg;

    do
    :: 
        participants[2].sensor_request ? controller_msg;
        if
        :: controller_msg == CHECK_TRAFFIC ->
            if
            :: participants[2].sensor_response ! YES_TRAFFIC;
            :: participants[2].sensor_response ! NO_TRAFFIC;
            fi;
        fi;
    od;
}


proctype SW_CONTROLLER() {
    mtype sensor_msg;
    mtype round_robin_msg;
    mtype color = RED;

    do
    :: color == RED ->
        participants[3].sensor_request ! CHECK_TRAFFIC;
        participants[3].sensor_response ? sensor_msg;
        if
        :: sensor_msg == NO_TRAFFIC ->
            skip;
        :: sensor_msg == YES_TRAFFIC ->
            participants[3].controller_request ! ASK;
            participants[3].controller_response ? round_robin_msg;
            if
            :: round_robin_msg == LET -> color = GREEN;
            fi;
        fi;
    :: color == GREEN ->
        color = RED;
        participants[3].controller_request ! FREE
    od;
}

proctype SW_SENSOR() {
    mtype controller_msg

    do
    :: 
        participants[3].sensor_request ? controller_msg;
        if
        :: controller_msg == CHECK_TRAFFIC ->
            if
            :: participants[3].sensor_response ! YES_TRAFFIC;
            :: participants[3].sensor_response ! NO_TRAFFIC;
            fi;
        fi;
    od;
}


// ###################################################################
// ###################################################################
proctype ES_CONTROLLER() {
    mtype sensor_msg;
    mtype round_robin_msg;
    mtype color = RED;

    do
    :: color == RED ->
        participants[4].sensor_request ! CHECK_TRAFFIC;
        participants[4].sensor_response ? sensor_msg;
        if
        :: sensor_msg == NO_TRAFFIC ->
            skip;
        :: sensor_msg == YES_TRAFFIC ->
            participants[4].controller_request ! ASK;
            participants[4].controller_response ? round_robin_msg;
            if
            :: round_robin_msg == LET -> color = GREEN;
            fi;
        fi;
    :: color == GREEN ->
        color = RED;
        participants[4].controller_request ! FREE
    od;
}

proctype ES_SENSOR() {
    mtype controller_msg;

    do
    :: 
        participants[4].sensor_request ? controller_msg;
        if
        :: controller_msg == CHECK_TRAFFIC ->
            if
            :: participants[4].sensor_response ! YES_TRAFFIC;
            :: participants[4].sensor_response ! NO_TRAFFIC;
            fi;
        fi;
    od;
}

proctype NE_CONTROLLER() {
    mtype sensor_msg;
    mtype round_robin_msg;
    mtype color = RED;

    do
    :: color == RED ->
        participants[5].sensor_request ! CHECK_TRAFFIC;
        participants[5].sensor_response ? sensor_msg;
        if
        :: sensor_msg == NO_TRAFFIC ->
            skip;
        :: sensor_msg == YES_TRAFFIC ->
            participants[5].controller_request ! ASK;
            participants[5].controller_response ? round_robin_msg;
            if
            :: round_robin_msg == LET -> color = GREEN;
            fi;
        fi;
    :: color == GREEN ->
        color = RED;
        participants[5].controller_request ! FREE
    od;
}

proctype NE_SENSOR() {
    mtype controller_msg;

    do
    :: 
        participants[5].sensor_request ? controller_msg;
        if
        :: controller_msg == CHECK_TRAFFIC ->
            if
            :: participants[5].sensor_response ! YES_TRAFFIC;
            :: participants[5].sensor_response ! NO_TRAFFIC;
            fi;
        fi;
    od;
}
// ###################################################################
// ###################################################################

init {
    // DN - 0
    participants[0].sensor_request      = DN_SENSOR_REQUEST;
    participants[0].sensor_response     = DN_SENSOR_RESPONSE;
    participants[0].controller_request  = DN_CONTROLLER_REQUEST;
    participants[0].controller_response = DN_CONTROLLER_RESPONSE;
    participants[0].dir_name            = DN;
    intersections_config[0].arr[0]      = 0;
    intersections_config[0].arr[1]      = 1;
    intersections_config[0].arr[2]      = 0;
    intersections_config[0].arr[3]      = 0;
    // intersections_config[0].arr[4]      = 0;
    // intersections_config[0].arr[5]      = 1;
    // NS - 1
    participants[1].sensor_request      = NS_SENSOR_REQUEST;
    participants[1].sensor_response     = NS_SENSOR_RESPONSE;
    participants[1].controller_request  = NS_CONTROLLER_REQUEST;
    participants[1].controller_response = NS_CONTROLLER_RESPONSE;
    participants[1].dir_name            = NS;
    intersections_config[1].arr[0]      = 1;
    intersections_config[1].arr[1]      = 0;
    intersections_config[1].arr[2]      = 1;
    intersections_config[1].arr[3]      = 1;
    // intersections_config[1].arr[4]      = 0;
    // intersections_config[1].arr[5]      = 0;   
    // DE - 2
    participants[2].sensor_request      = DE_SENSOR_REQUEST;
    participants[2].sensor_response     = DE_SENSOR_RESPONSE;
    participants[2].controller_request  = DE_CONTROLLER_REQUEST;
    participants[2].controller_response = DE_CONTROLLER_RESPONSE;
    participants[2].dir_name            = DE;
    intersections_config[2].arr[0]      = 0;
    intersections_config[2].arr[1]      = 1;
    intersections_config[2].arr[2]      = 0;
    intersections_config[2].arr[3]      = 0;
    intersections_config[2].arr[4]      = 1;
    intersections_config[2].arr[5]      = 0;
    // SW - 3
    participants[3].sensor_request      = SW_SENSOR_REQUEST;
    participants[3].sensor_response     = SW_SENSOR_RESPONSE;
    participants[3].controller_request  = SW_CONTROLLER_REQUEST;
    participants[3].controller_response = SW_CONTROLLER_RESPONSE;
    participants[3].dir_name            = SW;
    intersections_config[3].arr[0]      = 0;
    intersections_config[3].arr[1]      = 1;
    intersections_config[3].arr[2]      = 0;
    intersections_config[3].arr[3]      = 0;
    intersections_config[3].arr[4]      = 1;
    intersections_config[3].arr[5]      = 0;

// ###################################################################
// ###################################################################
    // ES - 4
    participants[4].sensor_request      = ES_SENSOR_REQUEST;
    participants[4].sensor_response     = ES_SENSOR_RESPONSE;
    participants[4].controller_request  = ES_CONTROLLER_REQUEST;
    participants[4].controller_response = ES_CONTROLLER_RESPONSE;
    participants[4].dir_name            = ES;
    intersections_config[4].arr[0]      = 0;
    intersections_config[4].arr[1]      = 0;
    intersections_config[4].arr[2]      = 1;
    intersections_config[4].arr[3]      = 1;
    intersections_config[4].arr[4]      = 0;
    intersections_config[4].arr[5]      = 1;
    // NE - 5
    participants[5].sensor_request      = NE_SENSOR_REQUEST;
    participants[5].sensor_response     = NE_SENSOR_RESPONSE;
    participants[5].controller_request  = NE_CONTROLLER_REQUEST;
    participants[5].controller_response = NE_CONTROLLER_RESPONSE;
    participants[5].dir_name            = NE;
    intersections_config[5].arr[0]      = 1;
    intersections_config[5].arr[1]      = 0;
    intersections_config[5].arr[2]      = 0;
    intersections_config[5].arr[3]      = 0;
    intersections_config[5].arr[4]      = 1;
    intersections_config[5].arr[5]      = 0;
// ###################################################################
// ###################################################################
    run ROUND_ROBIN();
    run DN_CONTROLLER();
    run DN_SENSOR();
    run NS_CONTROLLER();
    run NS_SENSOR();
    run DE_CONTROLLER();
    run DE_SENSOR();
    run SW_CONTROLLER();
    run SW_SENSOR();
// ###################################################################
// ###################################################################
    run ES_CONTROLLER();
    run ES_SENSOR();
    run NE_CONTROLLER();
    run NE_SENSOR();
// ###################################################################
// ###################################################################
}