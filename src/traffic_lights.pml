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
    (DN_CONTROLLER:message_from_sensor == YES_TRAFFIC && (DN_CONTROLLER:color == RED)) -> 
    (<> (DN_CONTROLLER:color == GREEN))
)};
ltl NS_LIVENESS { [] (
    (NS_CONTROLLER:message_from_sensor == YES_TRAFFIC && (NS_CONTROLLER:color == RED)) -> 
    (<> (NS_CONTROLLER:color == GREEN))
)};
ltl DE_LIVENESS { [] (
    (DE_CONTROLLER:message_from_sensor == YES_TRAFFIC && (DE_CONTROLLER:color == RED)) -> 
    (<> (DE_CONTROLLER:color == GREEN))
)};
ltl SW_LIVENESS { [] (
    (SW_CONTROLLER:message_from_sensor == YES_TRAFFIC && (SW_CONTROLLER:color == RED)) -> 
    (<> (SW_CONTROLLER:color == GREEN))
)};
ltl ES_LIVENESS { [] (
    (ES_CONTROLLER:message_from_sensor == YES_TRAFFIC && (ES_CONTROLLER:color == RED)) -> 
    (<> (ES_CONTROLLER:color == GREEN))
)};
ltl NE_LIVENESS { [] (
    (NE_CONTROLLER:message_from_sensor == YES_TRAFFIC && (NE_CONTROLLER:color == RED)) -> 
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


ltl DN_FAIRNESS { [] 
    (<> !(
        DN_CONTROLLER:color == GREEN && 
        DN_CONTROLLER:message_from_sensor == YES_TRAFFIC
    ))
};

ltl NS_FAIRNESS { [] 
    (<> !(
        NS_CONTROLLER:color == GREEN && 
        NS_CONTROLLER:message_from_sensor == YES_TRAFFIC
    ))
};

ltl DE_FAIRNESS { [] 
    (<> !(
        DE_CONTROLLER:color == GREEN && 
        DE_CONTROLLER:message_from_sensor == YES_TRAFFIC
    ))
};

ltl SW_FAIRNESS { [] 
    (<> !(
        SW_CONTROLLER:color == GREEN && 
        SW_CONTROLLER:message_from_sensor == YES_TRAFFIC
    ))
};

ltl ES_FAIRNESS { [] 
    (<> !(
        ES_CONTROLLER:color == GREEN && 
        ES_CONTROLLER:message_from_sensor == YES_TRAFFIC
    ))
};

ltl NE_FAIRNESS { [] 
    (<> !(
        NE_CONTROLLER:color == GREEN && 
        NE_CONTROLLER:message_from_sensor == YES_TRAFFIC
    ))
};

mtype = { 
    CHECK_TRAFFIC, YES_TRAFFIC, NO_TRAFFIC, CHECK_FROM_ROBIN
    ASK, FREE, APPROVED, DECLINED
    RED, GREEN,
};

typedef RoundRobinParticipant {
    chan check_from_robin;
    chan controller_response;
    chan sensor_request;
    chan sensor_response;
    chan grant_channel;
};
RoundRobinParticipant participants[DIRECTIONS_QUANTITY]

typedef INTERSECTIONS_ARRAY {
    byte arr[DIRECTIONS_QUANTITY];
};
INTERSECTIONS_ARRAY intersections_config[DIRECTIONS_QUANTITY];


chan DN_CHECK_FROM_ROBIN      = [0] of { mtype };
chan DN_CONTROLLER_RESPONSE   = [0] of { mtype };
chan DN_SENSOR_REQUEST        = [0] of { mtype };
chan DN_SENSOR_RESPONSE       = [0] of { mtype };
chan DN_GRANT_CHANNEL         = [0] of { mtype };

chan NS_CHECK_FROM_ROBIN      = [0] of { mtype };
chan NS_CONTROLLER_RESPONSE   = [0] of { mtype };
chan NS_SENSOR_REQUEST        = [0] of { mtype };
chan NS_SENSOR_RESPONSE       = [0] of { mtype };
chan NS_GRANT_CHANNEL         = [0] of { mtype };

chan DE_CHECK_FROM_ROBIN      = [0] of { mtype };
chan DE_CONTROLLER_RESPONSE   = [0] of { mtype };
chan DE_SENSOR_REQUEST        = [0] of { mtype };
chan DE_SENSOR_RESPONSE       = [0] of { mtype };
chan DE_GRANT_CHANNEL         = [0] of { mtype };

chan SW_CHECK_FROM_ROBIN      = [0] of { mtype };
chan SW_CONTROLLER_RESPONSE   = [0] of { mtype };
chan SW_SENSOR_REQUEST        = [0] of { mtype };
chan SW_SENSOR_RESPONSE       = [0] of { mtype };
chan SW_GRANT_CHANNEL         = [0] of { mtype };

chan ES_CHECK_FROM_ROBIN      = [0] of { mtype };
chan ES_CONTROLLER_RESPONSE   = [0] of { mtype };
chan ES_SENSOR_REQUEST        = [0] of { mtype };
chan ES_SENSOR_RESPONSE       = [0] of { mtype };
chan ES_GRANT_CHANNEL         = [0] of { mtype };

chan NE_CHECK_FROM_ROBIN      = [0] of { mtype };
chan NE_CONTROLLER_RESPONSE   = [0] of { mtype };
chan NE_SENSOR_REQUEST        = [0] of { mtype };
chan NE_SENSOR_RESPONSE       = [0] of { mtype };
chan NE_GRANT_CHANNEL         = [0] of { mtype };


proctype ROUND_ROBIN() {
    mtype message_from_controller;
    bool granted[DIRECTIONS_QUANTITY] = false;
    byte current_direction = 0;

    do
    ::
        do
        :: current_direction < DIRECTIONS_QUANTITY ->
            bool is_safe = true;

            atomic {

                if
                :: intersections_config[current_direction].arr[0] == 1 && granted[0] -> is_safe = false
                :: intersections_config[current_direction].arr[1] == 1 && granted[1] -> is_safe = false
                :: intersections_config[current_direction].arr[2] == 1 && granted[2] -> is_safe = false
                :: intersections_config[current_direction].arr[3] == 1 && granted[3] -> is_safe = false
                :: intersections_config[current_direction].arr[4] == 1 && granted[4] -> is_safe = false
                :: intersections_config[current_direction].arr[5] == 1 && granted[5] -> is_safe = false

                :: else -> is_safe = true
                fi;
            }

            participants[current_direction].check_from_robin ! CHECK_FROM_ROBIN;
            participants[current_direction].controller_response ? message_from_controller;

            if
            :: message_from_controller == ASK -> 
                if 
                :: is_safe == true ->
                    granted[current_direction] = true;
                    participants[current_direction].grant_channel ! APPROVED;
                :: else -> 
                    granted[current_direction] = false;
                    participants[current_direction].grant_channel ! DECLINED;
                    current_direction = (current_direction + 1) % DIRECTIONS_QUANTITY;
                    break;
                fi;
            :: message_from_controller == FREE ->
                granted[current_direction] = false;
            fi;
            current_direction = (current_direction + 1) % DIRECTIONS_QUANTITY;
        od;
    od;
}

proctype DN_CONTROLLER() {
    mtype message_from_robin;
    mtype approve_message;
    mtype message_from_sensor;
    mtype color = RED;
    bool waiting_for_approval = false;

    do
    ::  
        participants[0].check_from_robin ? message_from_robin;
        if
        :: waiting_for_approval == false ->
            participants[0].sensor_request ! CHECK_TRAFFIC;
            participants[0].sensor_response ? message_from_sensor;
        fi;

        if
        :: message_from_sensor == YES_TRAFFIC ->
            participants[0].controller_response ! ASK;
            participants[0].grant_channel ? approve_message;
            if 
            :: approve_message == APPROVED ->
                color = GREEN;
            :: approve_message == DECLINED ->
                skip;
            fi;
        :: message_from_sensor == NO_TRAFFIC ->
            color = RED;
            participants[0].controller_response ! FREE;
        fi;
    od;
}

proctype DN_SENSOR() {
    mtype message;

    do
    :: 
        participants[0].sensor_request ? message;
        if
        :: participants[0].sensor_response ! YES_TRAFFIC;
        :: participants[0].sensor_response ! NO_TRAFFIC;
        fi;
    od;
}


proctype NS_CONTROLLER() {
    mtype message_from_robin;
    mtype approve_message;
    mtype message_from_sensor;
    mtype color = RED;
    bool waiting_for_approval = false;

    do
    :: 
        participants[1].check_from_robin ? message_from_robin;
        if
        :: waiting_for_approval == false ->
            participants[1].sensor_request ! CHECK_TRAFFIC;
            participants[1].sensor_response ? message_from_sensor;
        fi;

        if
        :: message_from_sensor == YES_TRAFFIC ->
            participants[1].controller_response ! ASK;
            participants[1].grant_channel ? approve_message;
            if 
            :: approve_message == APPROVED ->
                color = GREEN;
            :: approve_message == DECLINED ->
                skip;
            fi;
        :: message_from_sensor == NO_TRAFFIC ->
            color = RED;
            participants[1].controller_response ! FREE;
        fi;
    od;
}

proctype NS_SENSOR() {
    mtype message;

    do
    :: 
        participants[1].sensor_request ? message;
        if
        :: participants[1].sensor_response ! YES_TRAFFIC;
        :: participants[1].sensor_response ! NO_TRAFFIC;
        fi;
    od;
}


proctype DE_CONTROLLER() {
    mtype message_from_robin;
    mtype approve_message;
    mtype message_from_sensor;
    mtype color = RED;
    bool waiting_for_approval = false;

    do
    :: 
        participants[2].check_from_robin ? message_from_robin;
        if
        :: waiting_for_approval == false ->
            participants[2].sensor_request ! CHECK_TRAFFIC;
            participants[2].sensor_response ? message_from_sensor;
        fi;

        if
        :: message_from_sensor == YES_TRAFFIC ->
            participants[2].controller_response ! ASK;
            participants[2].grant_channel ? approve_message;
            if 
            :: approve_message == APPROVED ->
                color = GREEN;
            :: approve_message == DECLINED ->
                skip;
            fi;
        :: message_from_sensor == NO_TRAFFIC ->
            color = RED;
            participants[2].controller_response ! FREE;
        fi;
    od;
}

proctype DE_SENSOR() {
    mtype message;

    do
    :: 
        participants[2].sensor_request ? message;
        if
        :: participants[2].sensor_response ! YES_TRAFFIC;
        :: participants[2].sensor_response ! NO_TRAFFIC;
        fi;
    od;
}


proctype SW_CONTROLLER() {
    mtype message_from_robin;
    mtype approve_message;
    mtype message_from_sensor;
    mtype color = RED;
    bool waiting_for_approval = false;

    do
    :: 
        participants[3].check_from_robin ? message_from_robin;
        if
        :: waiting_for_approval == false ->
            participants[3].sensor_request ! CHECK_TRAFFIC;
            participants[3].sensor_response ? message_from_sensor;
        fi;

        if
        :: message_from_sensor == YES_TRAFFIC ->
            participants[3].controller_response ! ASK;
            participants[3].grant_channel ? approve_message;
            if 
            :: approve_message == APPROVED ->
                color = GREEN;
            :: approve_message == DECLINED ->
                skip;
            fi;
        :: message_from_sensor == NO_TRAFFIC ->
            color = RED;
            participants[3].controller_response ! FREE;
        fi;
    od;
}

proctype SW_SENSOR() {
    mtype message;

    do
    :: 
        participants[3].sensor_request ? message;
        if
        :: participants[3].sensor_response ! YES_TRAFFIC;
        :: participants[3].sensor_response ! NO_TRAFFIC;
        fi;
    od;
}


proctype ES_CONTROLLER() {
    mtype message_from_robin;
    mtype approve_message;
    mtype message_from_sensor;
    mtype color = RED;
    bool waiting_for_approval = false;

    do
    :: 
        participants[4].check_from_robin ? message_from_robin;
        if
        :: waiting_for_approval == false ->
            participants[4].sensor_request ! CHECK_TRAFFIC;
            participants[4].sensor_response ? message_from_sensor;
        fi;

        if
        :: message_from_sensor == YES_TRAFFIC ->
            participants[4].controller_response ! ASK;
            participants[4].grant_channel ? approve_message;
            if 
            :: approve_message == APPROVED ->
                color = GREEN;
            :: approve_message == DECLINED ->
                skip;
            fi;
        :: message_from_sensor == NO_TRAFFIC ->
            color = RED;
            participants[4].controller_response ! FREE;
        fi;
    od;
}

proctype ES_SENSOR() {
    mtype message;

    do
    :: 
        participants[4].sensor_request ? message;
        if
        :: participants[4].sensor_response ! YES_TRAFFIC;
        :: participants[4].sensor_response ! NO_TRAFFIC;
        fi;
    od;
}


proctype NE_CONTROLLER() {
    mtype message_from_robin;
    mtype approve_message;
    mtype message_from_sensor;
    mtype color = RED;
    bool waiting_for_approval = false;

    do
    :: 
        participants[5].check_from_robin ? message_from_robin;
        if
        :: waiting_for_approval == false ->
            participants[5].sensor_request ! CHECK_TRAFFIC;
            participants[5].sensor_response ? message_from_sensor;
        fi;

        if
        :: message_from_sensor == YES_TRAFFIC ->
            participants[5].controller_response ! ASK;
            participants[5].grant_channel ? approve_message;
            if 
            :: approve_message == APPROVED ->
                color = GREEN;
            :: approve_message == DECLINED ->
                skip;
            fi;
        :: message_from_sensor == NO_TRAFFIC ->
            color = RED;
            participants[5].controller_response ! FREE;
        fi;
    od;
}

proctype NE_SENSOR() {
    mtype message;

    do
    :: 
        participants[5].sensor_request ? message;
        if
        :: participants[5].sensor_response ! YES_TRAFFIC;
        :: participants[5].sensor_response ! NO_TRAFFIC;
        fi;
    od;
}


init {
    participants[0].check_from_robin    = DN_CHECK_FROM_ROBIN;
    participants[0].controller_response = DN_CONTROLLER_RESPONSE;
    participants[0].sensor_request      = DN_SENSOR_REQUEST;
    participants[0].sensor_response     = DN_SENSOR_RESPONSE;
    participants[0].grant_channel       = DN_GRANT_CHANNEL;
    intersections_config[0].arr[0]      = 0;
    intersections_config[0].arr[1]      = 1;
    intersections_config[0].arr[2]      = 0;
    intersections_config[0].arr[3]      = 0;
    intersections_config[0].arr[4]      = 0;
    intersections_config[0].arr[5]      = 1;

    // NS - 1
    participants[1].check_from_robin    = NS_CHECK_FROM_ROBIN;
    participants[1].controller_response = NS_CONTROLLER_RESPONSE;
    participants[1].sensor_request      = NS_SENSOR_REQUEST;
    participants[1].sensor_response     = NS_SENSOR_RESPONSE;
    participants[1].grant_channel       = NS_GRANT_CHANNEL;
    intersections_config[1].arr[0]      = 1;
    intersections_config[1].arr[1]      = 0;
    intersections_config[1].arr[2]      = 1;
    intersections_config[1].arr[3]      = 1;
    intersections_config[1].arr[4]      = 0;
    intersections_config[1].arr[5]      = 0;   
    // DE - 2
    participants[2].check_from_robin    = DE_CHECK_FROM_ROBIN;
    participants[2].controller_response = DE_CONTROLLER_RESPONSE;
    participants[2].sensor_request      = DE_SENSOR_REQUEST;
    participants[2].sensor_response     = DE_SENSOR_RESPONSE;
    participants[2].grant_channel       = DE_GRANT_CHANNEL;
    intersections_config[2].arr[0]      = 0;
    intersections_config[2].arr[1]      = 1;
    intersections_config[2].arr[2]      = 0;
    intersections_config[2].arr[3]      = 0;
    intersections_config[2].arr[4]      = 1;
    intersections_config[2].arr[5]      = 0;
    // SW - 3
    participants[3].check_from_robin    = SW_CHECK_FROM_ROBIN;
    participants[3].controller_response = SW_CONTROLLER_RESPONSE;
    participants[3].sensor_request      = SW_SENSOR_REQUEST;
    participants[3].sensor_response     = SW_SENSOR_RESPONSE;
    participants[3].grant_channel       = SW_GRANT_CHANNEL;
    intersections_config[3].arr[0]      = 0;
    intersections_config[3].arr[1]      = 1;
    intersections_config[3].arr[2]      = 0;
    intersections_config[3].arr[3]      = 0;
    intersections_config[3].arr[4]      = 1;
    intersections_config[3].arr[5]      = 0;
    // ES - 4
    participants[4].check_from_robin    = ES_CHECK_FROM_ROBIN;
    participants[4].controller_response = ES_CONTROLLER_RESPONSE;
    participants[4].sensor_request      = ES_SENSOR_REQUEST;
    participants[4].sensor_response     = ES_SENSOR_RESPONSE;
    participants[4].grant_channel       = ES_GRANT_CHANNEL;
    intersections_config[4].arr[0]      = 0;
    intersections_config[4].arr[1]      = 0;
    intersections_config[4].arr[2]      = 1;
    intersections_config[4].arr[3]      = 1;
    intersections_config[4].arr[4]      = 0;
    intersections_config[4].arr[5]      = 1;
    // NE - 5
    participants[5].check_from_robin    = NE_CHECK_FROM_ROBIN;
    participants[5].controller_response = NE_CONTROLLER_RESPONSE;
    participants[5].sensor_request      = NE_SENSOR_REQUEST;
    participants[5].sensor_response     = NE_SENSOR_RESPONSE;
    participants[5].grant_channel       = NE_GRANT_CHANNEL;
    intersections_config[5].arr[0]      = 1;
    intersections_config[5].arr[1]      = 0;
    intersections_config[5].arr[2]      = 0;
    intersections_config[5].arr[3]      = 0;
    intersections_config[5].arr[4]      = 1;
    intersections_config[5].arr[5]      = 0;

    run ROUND_ROBIN();
    run DN_CONTROLLER();
    run DN_SENSOR();
    run NS_CONTROLLER();
    run NS_SENSOR();
    run DE_CONTROLLER();
    run DE_SENSOR();
    run SW_CONTROLLER();
    run SW_SENSOR();
    run ES_CONTROLLER();
    run ES_SENSOR();
    run NE_CONTROLLER();
    run NE_SENSOR();
}
