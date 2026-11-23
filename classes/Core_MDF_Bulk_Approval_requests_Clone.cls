global class Core_MDF_Bulk_Approval_requests_Clone implements Database.Batchable<Approval.ProcessWorkitemRequest>, Database.Stateful {
    global List<Approval.ProcessWorkitemRequest> finalPwrList = new List<Approval.ProcessWorkitemRequest>();
    global Core_MDF_Bulk_Approval_requests_Clone(List<Approval.ProcessWorkitemRequest> pwrList) {
        finalPwrList = pwrList;
        System.debug('CONSTRUCTOR: '+finalPwrList);
    }
    global Core_MDF_Bulk_Approval_requests_Clone(String pwrRecord) {
        List<Approval.ProcessWorkitemRequest> prList = (List<Approval.ProcessWorkitemRequest>) JSON.deserialize(pwrRecord, List<Approval.ProcessWorkitemRequest>.class);
        //finalPwrList = prList;
        System.debug('CONSTRUCTOR: '+prList);
    }
    public List<Approval.ProcessWorkitemRequest> start(Database.BatchableContext context) {
        System.debug('ASYNC finalPwrList: '+finalPwrList);
        System.debug('ASYNC finalPwrList SIZE: '+finalPwrList.size());
        return finalPwrList;
    }
    global void execute(Database.BatchableContext context, List<Approval.ProcessWorkitemRequest> pwrListScope) {
        List<Approval.ProcessResult> processResultList = Approval.process(pwrListScope);
        System.debug('ASYNC processResultList: '+processResultList);
        System.debug('ASYNC processResultList SIZE: '+processResultList.size());
        for(Approval.ProcessResult result : processResultList){
            if(result.isSuccess()){
                //Success
            }
            else if(result != null && !result.isSuccess()){
                string errorlog = 'Approval failed for the request ID ->' + 'result' + ';'; 
                for(Database.Error errDet : result.getErrors()){
                    errorlog += errDet.getMessage();
                } 
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'submitBulkApprovalRequests Method');
            }
        }  
    }
    global void finish(Database.BatchableContext context) {
        //Need to send an email to the user who does the processing
    }
}