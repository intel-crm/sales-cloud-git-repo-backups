global class Core_CDB_AI_Retry_Outbound_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Map<String,Id> params = new Map<String,Id>();
        Flow.Interview cdbAIOutboundRetryFlow = Flow.Interview.createInterview('Core_MDF_Retry_CDB_AI_Outbound',params);
        cdbAIOutboundRetryFlow.start();
    }
}