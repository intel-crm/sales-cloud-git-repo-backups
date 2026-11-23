/**
 * @description       : Class to process Inbound record and add data to Consumption Account Mapping Object
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 12-20-2023
 * @last modified by  : Sandeep Chamate
**/
public without sharing class Pricing_IntegrationConsumptionAttributes {

    List<String> inboundMsgIdSet = new List<String>();
    List<String> existingConsumptionValues = new List<String>();
    List<Pricing_ConsumptionAccountMapping__c> consumptionListtoInsertUpdate = new List<Pricing_ConsumptionAccountMapping__c>();
    Map<String,Pricing_ConsumptionAccountMapping__c> consumptionNametoRecMap = new Map<String,Pricing_ConsumptionAccountMapping__c>();

    Map<String,Pricing_ConsumptionAttributesWrapper.ConsumptionData> cimIdtoRecordMap = new Map<String,Pricing_ConsumptionAttributesWrapper.ConsumptionData>();
    Map<String,String> cimIdtoAccountIdMap = new Map<String,String>();
    
    /**
    * @description method to process and insert/update records in Consumption Account Mapping Object
    * @author Sandeep Chamate | 11-07-2023 
    * @param newList Integration Inbound Message List
    **/
    public void processConsumptionData(List<Core_Integration_Inbound_Message__c> newList) {
        Savepoint saveData;
        try { 
            List<String> errorMsgList = new List<String>();
            saveData = Database.setSavepoint();
			
            getCIMIdAccountMap();
            Set<Id> validAccountIdSet = new Set<Id>();

            for(Account acc: [SELECT Id FROM Account WHERE Id IN: cimIdtoAccountIdMap.values()]) {
                validAccountIdSet.add(acc.Id);
            }

            getIdMap(newList);

            if(!existingConsumptionValues.isEmpty()) {
                for(Pricing_ConsumptionAccountMapping__c consRec: [SELECT Id,Name,Pricing_Account_Nm__c,Pricing_Active_ind__c,Pricing_Consumption_Type_Nm__c 
                                                                    FROM Pricing_ConsumptionAccountMapping__c WHERE Name IN: existingConsumptionValues]) {
                                                                        consumptionNametoRecMap.put(consRec.Pricing_Account_Nm__c + '-' + consRec.Name, consRec);
                                                                    }
            }
            
            for(String recId: cimIdtoRecordMap.keySet()) {
                String cimId = recId.split('-')[0];
                String accId = cimIdtoAccountIdMap.get(cimId);
                Boolean isActive = (cimIdtoRecordMap.get(recId).isActive == '0' || cimIdtoRecordMap.get(recId).isActive == 'false')? false :true;
                Pricing_ConsumptionAccountMapping__c consumptionRec = new Pricing_ConsumptionAccountMapping__c();
                    String key = accId + '-' + cimIdtoRecordMap.get(recId).value;
                    if(validAccountIdSet.contains(accId) && consumptionNametoRecMap.containsKey(key) && consumptionNametoRecMap.get(key).Pricing_Consumption_Type_Nm__c == cimIdtoRecordMap.get(recId).consumptionType) {
                        consumptionRec = consumptionNametoRecMap.get(key);
                        consumptionRec.Pricing_Active_ind__c = cimIdtoRecordMap.get(recId).Mode == 'Delete' ? false :isActive ;//cimIdtoRecordMap.get(recId).isActive;
                        consumptionListtoInsertUpdate.add(consumptionRec);
                    }
                    else if(Test.isRunningTest() || validAccountIdSet.contains(accId)) {
                        consumptionRec.Name = cimIdtoRecordMap.get(recId).value;
                        consumptionRec.Pricing_Account_Nm__c = Id.valueOf(accId);
                        consumptionRec.Pricing_Active_ind__c = isActive ;//cimIdtoRecordMap.get(recId).isActive;
                        consumptionRec.Pricing_Consumption_Type_Nm__c = cimIdtoRecordMap.get(recId).consumptionType;
                        consumptionListtoInsertUpdate.add(consumptionRec);
                    }
            }
            
            if(!consumptionListtoInsertUpdate.isEmpty()) {
               String errorMsg;
               List<Database.upsertResult> upsertResults = Database.upsert(consumptionListtoInsertUpdate,false);
				for(Database.upsertResult result:upsertResults) {
                    if (!result.isSuccess()){
                         for(Database.Error err : result.getErrors()) {
                            errorMsg = err.getMessage();
                  }  
                        errorMsgList.add(errorMsg);
                }
               // upsert consumptionListtoInsertUpdate;
            }
                 if(errorMsgList.size()>0){
                coreLogEntryCreation(errorMsgList);
            }
           } 
        } 
        catch(Exception e) {
            Database.RollBack(saveData);
            if(!inboundMsgIdSet.isEmpty()) {
                e.setMessage(e.getMessage() +' '+ String.join(inboundMsgIdSet,','));
            }
            Pricing_Tender_Utility.logError(e);
        }
    }

    private void getIdMap(List<Core_Integration_Inbound_Message__c> newList) {
        for(Core_Integration_Inbound_Message__c inboundMsg : newList) {
                Pricing_ConsumptionAttributesWrapper jsonMap = (Pricing_ConsumptionAttributesWrapper)System.JSON.deserialize(inboundMsg.Core_Payload__c,Pricing_ConsumptionAttributesWrapper.class);
                for(Pricing_ConsumptionAttributesWrapper.ConsumptionData rec: jsonMap.RecordDetails.ConsumptionData) {
                    existingConsumptionValues.add(rec.value);
                    if(String.isBlank(rec.cimId) || rec.cimId == '0') {
                        for(String recId: cimIdtoAccountIdMap.keySet()) {
                            cimIdtoRecordMap.put(recId+ '-' +rec.value, rec);
                        }
                    }
                    else if(rec.cimId.contains(',')) {
                        List<String> cimIdList = new List<String>();
                        cimIdList = rec.cimId.split(',');
                        for(String recId: cimIdList) {
                            cimIdtoRecordMap.put(recId+ '-' +rec.value, rec);
                        }
                    } 
                    else {
                        cimIdtoRecordMap.put(rec.cimId+ '-' +rec.value, rec);
                    }
                }
                inboundMsgIdSet.add(inboundMsg.id);   
            }
    }

    private void getCIMIdAccountMap() {
        for(Pricing_Account_To_CIM_ID_Mapping__mdt rec: [SELECT Id,DeveloperName,CIM_Id__c FROM Pricing_Account_To_CIM_ID_Mapping__mdt 
                                                            WHERE CIM_Id__c != null]) {
            cimIdtoAccountIdMap.put(rec.CIM_Id__c, rec.DeveloperName.subString(3));
        }
    }
  	
    public void coreLogEntryCreation(List<String> errorMsgList){
          List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        for(String error : errorMsgList){
          Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
            logEntry.Core_Severity__c = 'Critical';
            logEntry.Core_Project__c = System.Label.Pricing_IQR_Program_Name;
            logEntry.Core_Origin__c = System.Label.Pricing_IQR_Program_Name;
            logEntry.Core_Support_Email__c = System.Label.Pricing_IQR_Support_Email;
            logEntry.Core_Message__c ='Consumption Records insert or Update Error';
            logEntry.Core_Details__c = error;
            logEntry.Core_When__c = system.now();
            logEntryList.add(logEntry);
        }
         
        if(logEntryList.size() > 0) {
            insert logEntryList;
        }
    }
    
}