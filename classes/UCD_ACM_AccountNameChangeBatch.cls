/***************************************************************************************************************************
 * Apex Class Name  : UCD_ACM_AccountNameChangeBatch
 * Author And Date  : Rohit Podder, 20 NOV 2026
 * Function         : To create case in PEGA system when account name will be changed
 ****************************************************************************************************************************/
public without sharing class UCD_ACM_AccountNameChangeBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    Map<Id,Core_ACM_Account_Staging__c> failedRecords = new Map<Id,Core_ACM_Account_Staging__c>();
    List<Core_ACM_Account_Staging__c> successRecords = new List<Core_ACM_Account_Staging__c>();
    Set<Id> failedRecordsToRetry = new Set<Id>();
    private Integer retryCount;
    
    public UCD_ACM_AccountNameChangeBatch(){
        this.retryCount = 0;
    }
    public UCD_ACM_AccountNameChangeBatch(Set<Id> failedRecordsId,Integer retryCounter){
        this.failedRecordsToRetry = failedRecordsId;
        this.retryCount = retryCounter + 1;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        if (failedRecordsToRetry.size() > 0) {
            return Database.getQueryLocator([SELECT Id, AccountId__c, Account_Action_Refrence__c,createdBy.Email  FROM Core_ACM_Account_Staging__c WHERE ID IN :failedRecordsToRetry]);
        }else{
            return Database.getQueryLocator([SELECT Id, AccountId__c, Account_Action_Refrence__c,createdBy.Email  FROM Core_ACM_Account_Staging__c WHERE Core_Status__c = 'New' AND Core_Action__c = 'NAME_UPDATE']);
        }
    }
    
    public void execute(Database.BatchableContext context, List<Core_ACM_Account_Staging__c> listAccountStaging) {
        
        try{
            for (Core_ACM_Account_Staging__c accountStaging : listAccountStaging) {
                String unifiedId = accountStaging.Account_Action_Refrence__c.split(';')[0].trim();
                String updatedName = accountStaging.Account_Action_Refrence__c.split(';')[1].trim();
                HttpResponse response = makeHttpRequestToPega(unifiedId, updatedName, accountStaging.createdBy.Email);
                System.debug('response'+response);
                accountStaging.Status_Details__c = response.getBody();
                if(response.getStatusCode() == 200) {
                    accountStaging.Core_Status__c = 'COMPLETED';
                    successRecords.add(accountStaging);
                }else {
                    accountStaging.Core_Retry_Counter__c = retryCount;
                    accountStaging.Core_Status__c = 'FAILED';
                    failedRecords.put(accountStaging.Id, accountStaging);
                }
            }
        }catch(Exception e){
            UCD_ACM_Logger.error('UCD_ACM_AccountNameChangeBatch', 'execute', e.getMessage()+' '+e.getStackTraceString(), null);
            UCD_ACM_Logger.setLogDetails();
            
        }
    }
    
    public void finish(Database.BatchableContext context) {
        if (successRecords.size() > 0) {
            DataBase.SaveResult[] saveResults = Database.update(successRecords, false);
            for (DataBase.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    UCD_ACM_Logger.error('UCD_ACM_AccountNameChangeBatch', 'finish', saveResult.getErrors()[0].getMessage(), null);
                    UCD_ACM_Logger.setLogDetails();
                }
            }
        }
        
        if (failedRecords.size() > 0) {
            DataBase.SaveResult[] saveResults = Database.update(failedRecords.values(), false);
            for (DataBase.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    UCD_ACM_Logger.error('UCD_ACM_AccountNameChangeBatch', 'finish', saveResult.getErrors()[0].getMessage(), null);
                    UCD_ACM_Logger.setLogDetails();
                    
                }
            }
            if(retryCount < 3) {
                DataBase.executeBatch(new UCD_ACM_AccountNameChangeBatch(failedRecords.keySet(), retryCount), 50);
            }
        }       
    }
    
    public static HttpResponse makeHttpRequestToPega(String unifiedId, String updatedName, String requestorEmail){
        Core_ACM_CalloutService.RequestConfig rc = Core_ACM_CalloutService.getRequestConfig('PEGA');
        Map<String,String> requestHeader = new Map<String,String>{'Content-Type' => rc.contentType};
            
            //Build Payload
            Map<String, Object> customerData = new Map<String, Object>{
                	'Priority'          => 'Low',
                    'ReasonOfRequest'   => 'Create Data for Validation',
                    'UnifiedCustomerID' => unifiedId
                    };
                        
                        Map<String, Object> proposedData = new Map<String, Object>{
                            'ProposedCustName' => updatedName
                                };
                                    
                                    Map<String, Object> payload = new Map<String, Object>{
                                        'RequestorEmail' => requestorEmail,
                                            'CustomerData'   => customerData,
                                            'ProposedData'   => proposedData
                                            };
                                                
        String jsonBody = JSON.serialize(payload);
        //System.debug('json Body'+jsonBody);
        
        Core_RestClient restClient = new Core_RestClient(rc.endpoint, rc.method, requestHeader, jsonBody, rc.timeoutMs);
        return restClient.invokeApi();
    }
}