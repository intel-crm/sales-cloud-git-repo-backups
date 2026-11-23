public class BatchableError {
    
    public String ApexClassName;
    public Id Id;
    public Id AsyncApexJobId;
    //public boolean DoesExceedJobScopeMaxLength;
    public String ExceptionType;
    public String JobScope;
    public String Message;
    //public String RequestId;
    public String StackTrace;

    /**
     * Decomposes a persisted batch error into a BatchableError
     **/
    public static BatchableError newInstance(Core_MDF_Batch_Apex_Error_Log__c error) {
        BatchableError newError = new BatchableError();
        newError.ApexClassName = error.Core_MDF_Apex_Class_txt__c;
        newError.Id = error.Id;
        newError.AsyncApexJobId = error.Core_MDF_Job_Id__c;
        newError.ExceptionType = error.Core_MDF_Type_of_exception_txt__c;
        newError.JobScope = error.Core_MDF_Scope_txt__c;
        newError.Message = error.Core_MDF_Exception_Message_txt__c;
        newError.StackTrace =error.Core_MDF_Details_txt__c;
        return newError;
    }

    /**
     * BatchableErrors are used by the BatchableRetryJob which implements RaisesPlatformEvents.
     *   If errors occur during retry (execute method) this ensures this state is 
     *   passed on (via the JobScope field on BatchApexErrorEvent) so that the another retry can occur.
     **/      
    public override String toString() {
        return JSON.serialize(this, true);
    }
}