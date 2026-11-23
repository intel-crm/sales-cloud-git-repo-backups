public class UCD_ACM_AccountReqQueueTriggerHandler {
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
 
    
    // After Update
    public static void triggerPlatformEventOnUpdate(List<Account_Create_Request__c> accountRequestQueueLists,Map<Id,Account_Create_Request__c> accountRequestQueueById){
        List<Account_Create_Request__c> accountRequests = new List<Account_Create_Request__c>();
        System.debug('arq trigger'+accountRequestQueueLists);
        System.debug('old map'+accountRequestQueueById);
        try{
            Set<Id> accountRequestIdsToPublish = new Set<Id>();
            Set<Id> parentAccountIds = new Set<Id>();
            set<Id> accountIds = new Set<Id>();
 
            For(Account_Create_Request__c accountRequestQueueList :accountRequestQueueLists){
                System.debug('accountRequestQueueList@@@'+accountRequestQueueList);

                  if( ((accountRequestQueueList.Requested_Account__c != accountRequestQueueById.get(accountRequestQueueList.Id).Requested_Account__c) ||
                    (accountRequestQueueList.Status__c != accountRequestQueueById.get(accountRequestQueueList.Id).Status__c) || 
                    (accountRequestQueueList.Rejected_Reason__c != accountRequestQueueById.get(accountRequestQueueList.Id).Rejected_Reason__c) )  
                     && (accountRequestQueueList.Status__c == 'Approved' || accountRequestQueueList.Status__c == 'Rejected') ){
                       System.debug('inside if');
                       accountRequests.add(accountRequestQueueList);   
                       if(accountRequestQueueList.Requested_Account__c != null ){
                            if(accountRequestQueueList.Requested_Account__r.ParentId != null){
                                parentAccountIds.add(accountRequestQueueList.Requested_Account__r.ParentId);
                            }
                            accountIds.add(accountRequestQueueList.Requested_Account__c);                   
                       }
                    }
                
            }
 
 
            if(accountRequests.size() > 0){
               PublishAccountRequestPlatformEvent(accountRequests,  parentAccountIds, accountIds);
            }

 
        }catch(Exception ex){
            System.debug('Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString());
            UCD_ACM_Logger.error('UCD_ACM_AccountReqQueueTriggerHandler','triggerPlatformEventOnUpdate','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'AccountRequestIds:');
        }

    }
    public static void PublishAccountRequestPlatformEvent(List<Account_Create_Request__c> accountRequests,  Set<Id> parentAccountIds,  Set<Id> accountIds) {
 
        //Create Instance for AccountSelector and initialize models and platform event class
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel();
        UCD_ACM_Models.PE_HeaderResponse headerModel = new UCD_ACM_Models.PE_HeaderResponse();
        List<ACM_Account_Request_Event__e> accountChangeEvents  = new List<ACM_Account_Request_Event__e>();
        List<Database.SaveResult> eventPublishResultList = new List<Database.SaveResult>();
        List<String> eventPayloads=new List<String>();

        System.debug('accountRequests&&&'+accountRequests);
        // Fetch parent account details        
        List<Account> accounts = new List<Account>();
        
        
        Map<Id, Account> AccountsById = accountQuerySelectorInstance.getAccountsByIds(accountIds, model.getParentAccountQueryForEvent());
        Map<Id, Account> parentAccountById = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent());
        Map<Id,List<Business_Types__c>> businessTypesByAccountId = accountQuerySelectorInstance.getBusinessTypesByAccountId(accountIds, model.getAccountBusinessTypesQueryForEvent());
        Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId = accountQuerySelectorInstance.getComplianceWatchListByAccountId(accountIds, model.getComplianceWatchListQueryForEvent());               

        // Publish event 
        For(Account_Create_Request__c accountRequest: accountRequests) {
            UCD_ACM_Models.PE_HeaderResponse mappedHeaderResponse = new UCD_ACM_Models.PE_HeaderResponse();
            UCD_ACM_Models.AccountRequestQueueModel mappedResponse = new UCD_ACM_Models.AccountRequestQueueModel();
            
            
            
            mappedResponse =  UCD_ACM_AccountDomain.mapAccountRequestQueueResponseModel(accountRequest, AccountsById,parentAccountById,businessTypesByAccountId,complianceWatchListByAccountId);
            System.debug('mappedResponse===>'+mappedResponse);
            
            Account account = AccountsById != null && accountRequest.Requested_Account__c != null && AccountsById.get(accountRequest.Requested_Account__c ) != null ? AccountsById.get(accountRequest.Requested_Account__c ) : null ;
            mappedHeaderResponse = accountRequest.Requested_Account__c != null ? businessTypesByAccountId != null && businessTypesByAccountId.containsKey(accountRequest.Requested_Account__c) && businessTypesByAccountId.get(accountRequest.Requested_Account__c).size() > 0  ? headerModel.mapAccountsToHeaders(account,businessTypesByAccountId.get(accountRequest.Requested_Account__c)): headerModel.mapAccountsToHeaders(account,null)   : null ;
            System.debug('mappedHeaderResponse===>'+mappedHeaderResponse);
            ACM_Account_Request_Event__e accountChangeEvent=new ACM_Account_Request_Event__e(Message__c = JSON.serialize(mappedResponse,true),Headers__c = JSON.serialize(mappedHeaderResponse,true));
            accountChangeEvents.add(accountChangeEvent);
            eventPayloads.add(accountChangeEvent.Message__c);
        }                    
        
        System.debug('accountChangeEvents'+accountChangeEvents);
        //call the publish event method
        if(accountChangeEvents.size() > 0) {    
            eventPublishResultList = EventBus.publish(accountChangeEvents);
        }
        
        if(eventPublishResultList.size() > 0){
            for (Database.SaveResult sr : eventPublishResultList) {
                if (sr.isSuccess()) {
                    UCD_ACM_Logger.information('UCD_ACM_AccountReqQueueTriggerHandler','PublishAccountRequestPlatformEvent','Account Change Event publish successfully for accounts :'+'.Payload:'+eventPayloads,'AccountIds: ');
                    break;
                }else {
                    // This method update the IntegrationMessageQueue status with error.
                    String errorMessage = '';
                    For(Database.error error : sr.getErrors()){
                        errorMessage += error.getMessage();
                    }
                    UCD_ACM_Logger.error('UCD_ACM_AccountReqQueueTriggerHandler','PublishAccountRequestPlatformEvent',errorMessage+' Failed Account Ids :','AccountIds: ');
                    break;
                }
            }
            
            
        }

    }
}