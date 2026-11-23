public with sharing class Del_Product_stageQueueable implements Queueable{
    public Integer i;
    public Map<Integer,Del_Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<Integer,Del_Product_ProcessInboundStagingRecords.InputWrapper>();
    public String ipaasId;
    
    public Del_Product_stageQueueable(Integer i,Map<Integer,Del_Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap, String ipaasId) {
        this.i = i;
        this.inputWrapperMap = inputWrapperMap;
        this.ipaasId = ipaasId;
    }

    public void execute(QueueableContext context) {
        system.debug('input arv'+i+'-'+inputWrapperMap.get(i).level2EPMIds);
        Del_Product_ProcessInboundStagingRecords.InputWrapper input  = inputWrapperMap.get(i);
        List<Product_Inbound_Staging__c> inboundList = new List<Product_Inbound_Staging__c>();

        if (input.atLevel2) {
            inboundList = [Select Id from Product_Inbound_Staging__c WHERE level_2_epm_id__c in:input.level2EPMIds AND iPaaS_Load_ID__c=:ipaasId];
        }
        else {
            inboundList = [Select Id from Product_Inbound_Staging__c WHERE level_1_epm_id__c =:input.level1EPMId AND iPaaS_Load_ID__c=:ipaasId];
        }

        System.debug('size arv'+inboundList.size());
        Integer count = i+1;
        if (inputWrapperMap.containsKey(count)){
           System.enqueueJob(new Del_Product_stageQueueable(count,inputWrapperMap,ipaasId));
        }
    }
}