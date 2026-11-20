public without sharing class Core_BUMapping_Retry {
    
    @InvocableMethod(label='BU Mapping Retry' description='Reprocess the failed records' category='Exception')
    public static void RetryFailedRecords(List<ID> ids) {
        List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
        Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
        wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
        List<ID> FailedOppLineItemRecordIds= new List<ID>();
        List<OpportunityLineItem> FailedOppLineItemLst= new List<OpportunityLineItem>();
        List<Core_Exceptions__c> ExpList=[Select id,Core_Record_Id__c,Core_Next_Scheduled_Run__c,Core_Retry_Counter__c from Core_Exceptions__c where id IN :ids];
        for(Core_Exceptions__c Exp : ExpList){
            FailedOppLineItemRecordIds.add(Exp.Core_Record_Id__c); 
        }
        FailedOppLineItemLst=[SELECT Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId,Core_BU_Mapping_record__c FROM OpportunityLineItem Where ID IN:FailedOppLineItemRecordIds];
        
        Core_BU_Mapping_Table__c finalBuMap;
        for(OpportunityLineItem oppLineItem : FailedOppLineItemLst){
            finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppLineItem, wrap);
            if(finalBuMap == null){
                failedList.add(oppLineItem);
            }else{
                oppLineItem.Core_BU_Mapping_record__c = finalBuMap.Id;
            }
        }
        
        try{
            Database.update(FailedOppLineItemLst);
        }catch(Exception ex){
            //System.debug('Exception occured:'+ex.getMessage());
            //Core_OpportunityLineItemHandler.Insert_logexception(scope,ex.getmessage()); 
            UpdateLogEntryRecordCounter(ExpList,ex.getmessage());
            
        }
        
    }
    
    public static void UpdateLogEntryRecordCounter(List<Core_Exceptions__c> ExpList,String ExceptionMsg) {
        list<Core_Exceptions__c> exceplist=new list<Core_Exceptions__c>();
        
        For (Core_Exceptions__c Exp : ExpList){
            Core_Exceptions__c excep=new Core_Exceptions__c();
            excep.id=Exp.id;
            excep.Core_Retry_Counter__c=Exp.Core_Retry_Counter__c+1;
            excep.Core_Method_Name__c='Retry Method';
            excep.Core_Exception__c=ExceptionMsg;
            excep.Core_Next_Scheduled_Run__c=System.now();
            
            
            
            exceplist.add(excep);
            
        }
        if(exceplist != null && !(exceplist.isEmpty())){
            Database.Update(exceplist);
        }        
        
    }
    
}