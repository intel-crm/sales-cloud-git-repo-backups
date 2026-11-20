@isTest
public without Sharing class PRM_RetryIPAFlow_Test {

    public static final String LOG_ENTRY_ORIGIN   = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    public static final String LOG_ENTRY_ORIGIN_ACCOUNT_UPDATE   = 'PRM_RegReqProcessingQueueable';
    public static final String LOG_ENTRY_SCOPE_ACCOUNT_UPDATE   = 'Account_Update';
    
    @testSetup
     static void createData(){
        Account__c accNum = new Account__c();
        accNum.Name='AccountNumber';
        accNum.PRM_Max_Account_Number__c ='10000';
        insert accNum;
    
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.Name='TestUser';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='234567';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        insert accIntel;
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;
         
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = accIntel.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Distributor';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest.PRM_Profession__c='PROFESSOR';
        prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest.PRM_Status__c = 'Approved' ; 
        insert prmRegRequest;
        
         List<Core_Log_Entry__c> logEntryToUpdate = new List<Core_Log_Entry__c>();
         
        String LogEntryId_Account_Update = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN_ACCOUNT_UPDATE, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_ACCOUNT_UPDATE, LOG_ENTRY_SEVERITY ,'unable to obtain exclusive access to this record or',JSON.serialize(new List<Account>{accIntel}),accIntel.Id, 'Account', accIntel.Id);
                        Core_Log_Entry__c logEntry_Account_Update = new Core_Log_Entry__c(Id = LogEntryId_Account_Update, Core_Retry_Counter__c = 1);
                        System.debug('LogEntryId_Account_Update'+LogEntryId_Account_Update);
                        logEntryToUpdate.add(logEntry_Account_Update);
        
        String LogEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY ,'unable to obtain exclusive access to this record or','','', '', 'checkuser@mailinator.com');
                        System.debug('LogEntryId'+LogEntryId);
                        Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Id = LogEntryId, Core_Retry_Counter__c = 1);
                        logEntryToUpdate.add(logEntry);
         
         If(!logEntryToUpdate.isEmpty()){
             update logEntryToUpdate;
         }
         
     }
    @istest static void callRetryIpaFlow(){
        List<String> logEntryIdList = new List<String>();
        List<Core_Log_Entry__c> logEntryList = [SELECT Id, Name, Core_Retry_Counter__c, Core_Origin__c, Core_Message__c, Core_Tags__c, Core_sObjectId__c,Core_Scope__c ,Core_Details__c
                                             FROM Core_Log_Entry__c 
                                             WHERE Core_Scope__c = 'Account_Update' or Core_Origin__c = 'CreateAccountAndRelatedRecords' ];
        for(Core_Log_Entry__c logEntry : logEntryList){
            logEntryIdList.add(logEntry.id);
        }
         PRM_RetryIPAFlow.retryIpaFlow(logEntryIdList);
    }

    
}