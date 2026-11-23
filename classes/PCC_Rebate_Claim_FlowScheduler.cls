global class PCC_Rebate_Claim_FlowScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        // Instantiate the Flow and set parameters if necessary
        Map<String, Object> params = new Map<String, Object>();
        Flow.Interview rebateactionsflow = new Flow.Interview.PCC_Rebate_Analyst_Actions(params);
        rebateactionsflow.start();
        
        //Optionally, capture and handle output variables
        // Object outputVariable = prrRebateFlow.getVariableValue('outputVariableName');
    }
}