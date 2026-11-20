public without sharing class UCD_ACM_AccountReqQueueTriggerHandler {
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    
    /** 
    * description : process Account Request Queue after update. 
    * params : List<Account_Create_Request__c>, Map<Id,Account_Create_Request__c>
    * return : void
    * author and date : yenugantix.tejasri@intel.com, ajayx.gat@intel.com 04/01/2024.
    */
    public static void processAccountRequestQueueAfterUpdate(List<Account_Create_Request__c> accountRequestQueueLists, Map<Id,Account_Create_Request__c> accountRequestQueueById) {
        Set<Id> arqIds = new Set<Id>();
        try{            
            For(Account_Create_Request__c accountRequestQueueList :accountRequestQueueLists){
                if((accountRequestQueueList.Status__c != accountRequestQueueById.get(accountRequestQueueList.Id).Status__c) &&
                     (accountRequestQueueList.Status__c == 'Approved' || accountRequestQueueList.Status__c == 'Rejected')){
                       arqIds.add(accountRequestQueueList.Id);
                   }
            }
            
            if(arqIds.size() > 0) {
                setIntegrationMessage(arqIds);
            }   
        } catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountReqQueueTriggerHandler','processAccountRequestQueueAfterUpdate','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'AccountRequestIds:'+arqIds.toString());
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    /** 
    * description : Insert or Update ACM_Integration_Message_Queue__c 
    * params : Set<Id>
    * return : void
    * author and date : ajayx.gat@intel.com 04/01/2024.
    */
    public static void setIntegrationMessage(Set<Id> arqIds){
        
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueById = new  Map<Id,ACM_Integration_Message_Queue__c>();
        List<ACM_Integration_Message_Queue__c> insertIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        List<ACM_Integration_Message_Queue__c> updateIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueByArqId = new Map<Id,ACM_Integration_Message_Queue__c>(); 
        
        try{
            List<ACM_Integration_Message_Queue__c> integrationMessages = [SELECT Id,Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c,Custom_Filter__c, Retry_Count__c FROM ACM_Integration_Message_Queue__c WHERE Custom_Filter__c IN: arqIds AND Content_Type__c = 'ARQId' AND Module_Name__c = 'SBR' AND Queue_Type__c = 'Outbound'];
            
            for(ACM_Integration_Message_Queue__c integrationMessage : integrationMessages) {
                integrationMessageQueueById.put(integrationMessage.Id, integrationMessage);
                integrationMessageQueueByArqId.put(integrationMessage.Content__c, integrationMessage);
            }
            
            For(Id arqId : arqIds) {   
                if(!integrationMessageQueueByArqId.isEmpty() && integrationMessageQueueByArqId.containsKey(arqId)) {
                    if(integrationMessageQueueByArqId.get(arqId).Message_Status__c == 'Success' || ( integrationMessageQueueByArqId.get(arqId).Message_Status__c == 'Error' && integrationMessageQueueByArqId.get(arqId).Retry_Count__c > 3)) {
                        ACM_Integration_Message_Queue__c integrationMessage = integrationMessageQueueByArqId.get(arqId);
                        integrationMessage.Message_Status__c = 'New';
                        integrationMessage.Retry_Count__c = 0;
                        updateIntegrationMessages.add(integrationMessage);
                    }
                } else {
                    ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
                    integrationMessage.Content__c = arqId;
                    integrationMessage.Custom_Filter__c = arqId;
                    integrationMessage.Content_Type__c = 'ARQId';
                    integrationMessage.Message_Status__c = 'New';
                    integrationMessage.Module_Name__c = 'SBR';
                    integrationMessage.Queue_Type__c = 'Outbound';
                    integrationMessage.Retry_Count__c = 0;
                    integrationMessage.Source_System__c = 'SBR';
                    insertIntegrationMessages.add(integrationMessage);
                }
            }
            
            if(!insertIntegrationMessages.isEmpty() && Schema.sObjectType.ACM_Integration_Message_Queue__c.isCreateable()) {
                insert insertIntegrationMessages;
            }
            if(!updateIntegrationMessages.isEmpty() && Schema.sObjectType.ACM_Integration_Message_Queue__c.isUpdateable()) {
                update updateIntegrationMessages;
            }
            
        } catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountReqQueueTriggerHandler','setIntegrationMessage','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),'ArqIds: '+arqIds.toString());
        }       
    }

    public static void checkForDuplicate(List<Account_Create_Request__c> accountRequestQueueRecords){
        Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Set<String> accReqName=new Set<String>();
        Set<String> alternateLangName=new Set<String>();
        Set<String> primaryCountry=new Set<String>();
        Set<String> primaryStreet=new Set<String>();
        Set<String> primaryCity=new Set<String>();
        Set<String> primaryState=new Set<String>();
        
        try{
            for(Account_Create_Request__c accReq:accountRequestQueueRecords){
                if((accReqName.contains(accReq.Account_Name__c) || (accReq.Core_Alternate_Language_Name__c!=null && alternateLangName.contains(accReq.Core_Alternate_Language_Name__c))) && primaryCountry.contains(accReq.Address__CountryCode__s) && primaryStreet.contains(accReq.Address__Street__s) && primaryCity.contains(accReq.Address__City__s) && primaryState.contains(accReq.Address__StateCode__s) ){
                    accReq.addError('Error! An account matching the customer name & address you entered has been found. You can’t submit this new request as it is a duplicate.');
                }
                else{
                    accReqName.add(accReq.Account_Name__c);
                    alternateLangName.add(accReq.Core_Alternate_Language_Name__c);
                    primaryCountry.add(accReq.Address__CountryCode__s);
                    primaryStreet.add(accReq.Address__Street__s);
                    primaryCity.add(accReq.Address__City__s);
                    primaryState.add(accReq.Address__StateCode__s);
                }
            }
    
            List<Account_Create_Request__c> existingRequestQueueRecord=new List<Account_Create_Request__c>();
            if(Schema.sObjectType.Account_Create_Request__c.fields.Account_Name__c.isAccessible() && Schema.sObjectType.Account_Create_Request__c.fields.Core_Alternate_Language_Name__c.isAccessible() &&
            Schema.sObjectType.Account_Create_Request__c.fields.Status__c.isAccessible() && Schema.sObjectType.Account_Create_Request__c.fields.Address__CountryCode__s.isAccessible() &&
            Schema.sObjectType.Account_Create_Request__c.fields.Address__Street__s.isAccessible() && Schema.sObjectType.Account_Create_Request__c.fields.Address__City__s.isAccessible() &&
            Schema.sObjectType.Account_Create_Request__c.fields.Address__StateCode__s.isAccessible() && Schema.sObjectType.Account_Create_Request__c.fields.Address__PostalCode__s.isAccessible() &&
            Schema.sObjectType.Account_Create_Request__c.fields.Requested_Account__c.isAccessible() && Schema.sObjectType.Account_Create_Request__c.fields.Requestor_Name__c.isAccessible() &&
            Schema.sObjectType.Account_Create_Request__c.fields.Process_Type__c.isAccessible()){
                existingRequestQueueRecord=[Select Id, Account_Name__c, Core_Alternate_Language_Name__c,
                Status__c, Address__CountryCode__s, Address__Street__s, 
                Address__City__s,Address__StateCode__s,Address__PostalCode__s,Requested_Account__c,
                CreatedDate,Requestor_Name__c,Process_Type__c 
                From Account_Create_Request__c
                Where (Account_Name__c IN:accReqName OR (Core_Alternate_Language_Name__c!=null AND Core_Alternate_Language_Name__c IN:alternateLangName)) 
                AND (Address__CountryCode__s IN:primaryCountry AND Address__Street__s IN:primaryStreet AND Address__City__s IN:primaryCity AND Address__StateCode__s IN:primaryState)
                AND (Status__c='In Process' OR Status__c='Pending Approval')
                ];
            }
            
            List<Account> existingAccountRecord=new List<Account>();
            if(Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.Core_Alternate_Language_Name__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible() && Schema.sObjectType.Account.fields.BillingCountry.isAccessible() &&
            Schema.sObjectType.Account.fields.BillingStreet.isAccessible() && Schema.sObjectType.Account.fields.BillingCity.isAccessible() &&
            Schema.sObjectType.Account.fields.BillingState.isAccessible() && Schema.sObjectType.Account.fields.BillingPostalCode.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Unified_Global_Customer_Name__c.isAccessible()){
                    existingAccountRecord=[Select Id, Name, Core_Alternate_Language_Name__c,Core_Business_Party_Id__c,
                    BillingCountry, BillingStreet, BillingCity, 
                    BillingState, BillingPostalCode,Core_Unified_Global_Customer_Name__c 
                    From Account
                    Where (Name IN:accReqName OR (Core_Alternate_Language_Name__c!=null AND Core_Alternate_Language_Name__c IN:alternateLangName)) 
                    AND (BillingCountry IN:primaryCountry AND BillingStreet IN:primaryStreet AND BillingCity IN:primaryCity AND BillingState IN:primaryState AND RecordTypeId=:intelAccountRTId)
                    ];
            }

            for(Account_Create_Request__c accRequest: accountRequestQueueRecords){
                if(!existingRequestQueueRecord.isEmpty()){
                    for(Account_Create_Request__c dupaccReq:existingRequestQueueRecord){
                        if((accRequest.Account_Name__c==dupaccReq.Account_Name__c || (accRequest.Core_Alternate_Language_Name__c==dupaccReq.Core_Alternate_Language_Name__c)) && (accRequest.Address__CountryCode__s==dupaccReq.Address__CountryCode__s && accRequest.Address__Street__s==dupaccReq.Address__Street__s && accRequest.Address__City__s==dupaccReq.Address__City__s && accRequest.Address__StateCode__s==dupaccReq.Address__StateCode__s)){
                            accRequest.addError('Error! An account matching the customer name & address you entered has been found. You can’t submit this new request as it is a duplicate.');
                        }
                    }
                }
                if(!existingAccountRecord.isEmpty()){
                    for(Account acc:existingAccountRecord){
                        if((accRequest.Account_Name__c==acc.Name || accRequest.Core_Alternate_Language_Name__c==acc.Core_Alternate_Language_Name__c) && (accRequest.Address__CountryCode__s==acc.BillingCountry && accRequest.Address__Street__s==acc.BillingStreet && accRequest.Address__City__s==acc.BillingCity && accRequest.Address__StateCode__s==acc.BillingState)){
                            accRequest.addError('Error! An account matching the customer name & address you entered has been found. You can’t submit this new request as it is a duplicate.');
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountReqQueueTriggerHandler','checkForDuplicate','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        } 
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
}