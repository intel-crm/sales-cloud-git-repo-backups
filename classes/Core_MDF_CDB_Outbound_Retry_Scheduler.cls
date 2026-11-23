global class Core_MDF_CDB_Outbound_Retry_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Map<String,Id> params = new Map<String,Id>();
        Flow.Interview cdbAIOutboundRetryFlow = Flow.Interview.createInterview('Core_MDF_Retry_CDB_AI_Outbound',params);
        cdbAIOutboundRetryFlow.start();
    }
}