var EDITOR="vi";
var xs="executionStats";
var all="allPlansExecution";

/* Shows query coverage informations */
function is_covered(ret){
        return({ stage: ret.queryPlanner.winningPlan.stage,
                has_index: ret.queryPlanner.winningPlan.inputStage.stage,
                returned: ret.executionStats.executionStages.nReturned,
                from_index: ret.executionStats.totalKeysExamined,
                from_disc:ret.executionStats.totalDocsExamined,
                coverage: 1-ret.executionStats.totalDocsExamined/ret.executionStats.executionStages.nReturned

        });
};


/* Shows hostname - status from replicaset */
function rs_info(){
        function print_members(status, cfg) {
            print(status.name, status.stateStr, cfg.priority, cfg.hidden ? "hidden": "" );
        }
        status = rs.status().members;
        cfg = rs.conf().members;
        for (var i in status) {
            print_members(status[i], cfg[i]);
        }
};

