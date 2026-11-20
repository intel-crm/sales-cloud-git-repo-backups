public without sharing class Pricing_MyDeals_RetryIntegration implements System.Queueable {
    
	public List<Pricing_Integration_Staging__c> pricingStageRecs = new List<Pricing_Integration_Staging__c>();
    public Pricing_MyDeals_RetryIntegration(List<Pricing_Integration_Staging__c> recObjs){
        this.pricingStageRecs = recObjs;
    }
    public void execute(QueueableContext qc){
        Map<String,String> successMap = new Map<String,String>();
        Map<String,Id> successSObjectNameToRecordIdMap = new Map<String,Id>();
        Map<String,String> errorMap = new Map<String,String>();
        Map<String,Id> errorSObjectNameToRecordIdMap = new Map<String,Id>();
        Map<Id,String> stageRecordMap = new Map<Id,String>();
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        String errorMsg;
        if(pricingStageRecs.size() > 0){
            //Pricing_MyDeals_Integration.sendPayloadToMydeals(pricingStageRecIds);
            for(Pricing_Integration_Staging__c pricingStage : pricingStageRecs){
                pricingStage.Pricing_Retry_Number__c = 0;
                pricingStage.Pricing_Status__c = 'Pending';
                stageRecordMap.put(pricingStage.Id,pricingStage.Name);
            }
            Database.SaveResult[] results = database.update(pricingStageRecs, false);

            for(Database.SaveResult res : results){
                if(res.isSuccess()){
                    errorMsg = 'Record: '+stageRecordMap.get(res.getId())+' has been processed successfully.';
                    successMap.put(stageRecordMap.get(res.getId()),errorMsg);
                    successSObjectNameToRecordIdMap.put(stageRecordMap.get(res.getId()),res.getId());
                }else {
                    /*for(Database.Error err : res.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }*/
                        errorMsg = 'Record: '+stageRecordMap.get(res.getId())+' is processed with an error';
                        errorMap.put(stageRecordMap.get(res.getId()),errorMsg);
                        errorSObjectNameToRecordIdMap.put(stageRecordMap.get(res.getId()),res.getId());
                }
            }
            if(successMap.size()>0 && successSObjectNameToRecordIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(successMap,successSObjectNameToRecordIdMap,'Low'));
            }
            if(errorMap.size()>0 && errorSObjectNameToRecordIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(errorMap,errorSObjectNameToRecordIdMap,'Critical'));
            }
            if(logEntryList.size() > 0){
                insert logEntryList;    
            }
        }
    }
}