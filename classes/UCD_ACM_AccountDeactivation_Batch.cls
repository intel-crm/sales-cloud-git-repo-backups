public class UCD_ACM_AccountDeactivation_Batch implements Database.Batchable<sObject> , Database.AllowsCallouts {
    Id inactiveAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
    public Boolean retryProcess = false;
    public static Integer failedRecordsCounter = 0;
    public static Integer retryCount = 0;
    
    public Map<Id,Account> failedRecords = new Map<Id,Account>();
    public Map<Id,Account> successRecords = new Map<Id,Account>();

    public Map<Id,Account> failedRecordsforQuery = new Map<Id,Account>();

    public List<Id> accountsIdsForQuery = new List<Id>();
    public UCD_ACM_AccountDeactivation_Batch() {
        retryProcess = false;
    }
    public UCD_ACM_AccountDeactivation_Batch(Map<Id,Account> failedRecordsforQuery) {
        this.failedRecordsforQuery = failedRecordsforQuery;
        retryProcess = true;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<Account> accounts  = new List<Account>();

        DateTime now = DateTime.now();

        Integer hours = now.hour(); 
        Integer minutes = now.minute(); 
        Integer seconds = now.second();
        Integer days = now.day();
        Integer months = now.month();
        Integer years = now.year();

        DateTime startDate = DateTime.newInstanceGMT(years, months, days, hours, minutes, seconds);
        DateTime endDate = DateTime.newInstanceGMT(years, months, days - 1, hours, minutes, seconds);

        
        if(!retryProcess) {
            List<Core_Log_Entry__c> ErrorLogs = [Select id,Core_Details__c  from Core_Log_Entry__c where  createddate <=:startDate AND createddate >:endDate AND Core_Project__c = 'ACM' AND Core_Origin__c = 'UCD_ACM_AccountDeactivation_Batch' AND Core_Severity__c = 'Error' ];

            if(ErrorLogs!= null &&  !ErrorLogs.isEmpty()) {
                for(Core_Log_Entry__c errorLogRec : ErrorLogs) {

                    if(String.isNotBlank(errorLogRec.Core_Details__c)) {
                        List<String> setFaildAccountId = errorLogRec.Core_Details__c.split(',');
                        for(String accId : setFaildAccountId){
                            if(accId.startsWith('001')){
                                accountsIdsForQuery.addAll(setFaildAccountId); 
                            }
                        }
                    }
                }
            }

           accounts =[Select Id From Account Where Core_Business_Party_Id__c!=null AND RecordTypeId =:inactiveAccountRTId AND Core_Deactivated__c=true AND Core_Customer_Aggregation_Type__c != null AND Id IN(Select AccountId From AccountHistory Where (Field= 'Core_Deactivated__c') AND createddate <=:startDate AND createddate >:endDate ) ]; 
        	System.debug('Accounts'+accounts);
        }
        else {
           accounts =[Select Id From Account Where Core_Business_Party_Id__c!=null AND Core_Deactivated__c=true AND RecordTypeId =:inactiveAccountRTId  AND Core_Customer_Aggregation_Type__c != null AND Id IN:failedRecordsforQuery.keySet()]; 
        }    

        if(!accounts.isEmpty()) {
            for(Account acc : accounts) {
                accountsIdsForQuery.add(acc.Id);
            }
        }

        String querys = '';
        if(!accountsIdsForQuery.isEmpty()){
             querys = 'Select Id,Name,Core_Business_Party_Id__c,RecordTypeId From Account Where Core_Business_Party_Id__c!=null AND Core_Deactivated__c=true AND RecordTypeId =:inactiveAccountRTId AND Id IN:accountsIdsForQuery' ;
        }else{
            querys = 'Select id from Account where Recordtype.Name = \'test\' ';
        }

        System.debug('querys@@@'+querys);
        return Database.getQueryLocator(querys);    
    }
    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        try{

            System.debug('accounts@@@'+accounts);
            for(Account accRec : accounts){

                UCD_ACM_AccountDeactivationService accountDeactivationRef = new UCD_ACM_AccountDeactivationService();
                UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation responseFromReltio = accountDeactivationRef.accountDeactivation(accRec.Core_Business_Party_Id__c, accRec.Id);
				
                System.debug('responseFromReltio@@@'+responseFromReltio);

                if(responseFromReltio != null && responseFromReltio.status == 'inactivated'){
                    UCD_ACM_Logger.information('UCD_ACM_AccountDeactivation_Batch','Success Record From Reltio',accRec.Id, String.valueOf(responseFromReltio));
                    successRecords.put(accRec.Id, accRec);
                
                }else{
                    failedRecords.put(accRec.Id, accRec);
                }

            }

            System.debug('successRecords==>' + successRecords);
            if(!successRecords.isempty()) {
                UCD_ACM_AccountDeactivation.removeUCDAttributes(successRecords); 
            }

            if(!failedRecords.isEmpty()) {
                failedRecordsCounter++;
            }

        } catch(Exception ex) {
            System.debug('Exception ==>'+ ex.getMessage());   
            System.debug('Exception ==>'+ ex.getStackTraceString());
            String accountColleactionIds = '' ;
            for(Account accRec : accounts){
                accountColleactionIds += accRec.Id + ',';
            }

            if(String.isNotBlank(accountColleactionIds)){
                UCD_ACM_Logger.error('UCD_ACM_AccountDeactivation_Batch','Failed Records',accountColleactionIds,ex.getMessage());
            }
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    public void finish(Database.BatchableContext BC) {
        
        if(failedRecordsCounter > 0 && retryCount <= 3) {
            retryCount++;
            UCD_ACM_AccountDeactivation_Batch cpeBatchJob=new UCD_ACM_AccountDeactivation_Batch(failedRecords);
            Database.executeBatch(cpeBatchJob);
        } else if(retryCount > 3) {
            String accountColleactionIds = '' ;

            for(Id accountId : failedRecords.keySet()){
                accountColleactionIds += accountId + ',';
            }
            if(String.isNotBlank(accountColleactionIds)){
        	    UCD_ACM_Logger.error('UCD_ACM_AccountDeactivation_Batch', 'Failed Records',accountColleactionIds, NULL);
                UCD_ACM_Logger.setLogDetails();
            }
        }
    }
}