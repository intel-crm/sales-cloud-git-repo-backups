public class UCD_ACM_Cntrlr_TestDataInitialization {
    public static Account createAccountByRecordType(String accountName,String recordType,String CustAggrType){
        Account account = new Account();
        account.Name = accountName;
        account.Core_Customer_Aggregation_Type__c = CustAggrType;
        account.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        account.BillingCountryCode	= 'IN';
        account.BillingCity = 'TestCity';
        account.BillingStreet = 'TestStreet';
        account.Core_Business_Party_Id__c = '1234';
        account.ShippingCountryCode = 'IN';
        return account;
    }
    public static Business_Types__c createBusinessType(String typeName,String typeCode){
        Business_Types__c businessType = new Business_Types__c(Name=typeName,Is_Active__c=true,Business_Type_Code__c=typeCode);
        return businessType;

    }

    public static Account_Business_Types__c createAccountBusinessType(Id accountId,Id businessTypeId){
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Account__c = accountId;
        accountBusinessType.Business_Types__c = businessTypeId;
        accountBusinessType.Effective_Start_Date__c = system.today()-5;
        //accountBusinessType.Effective_End_Date__c = system.today()+5;
        return accountBusinessType;
    }

    public static Core_Account_Compliance_Watch_List__c createComplianceWatchList(Id accountId,String typeCode){
        Core_Account_Compliance_Watch_List__c complianceWatchList =  new Core_Account_Compliance_Watch_List__c();
        complianceWatchList.Core_Account_Id__c = accountId;
        complianceWatchList.Core_Type__c = typeCode;
        complianceWatchList.Core_Effective_Start_Date__c = system.today()-5;
        //complianceWatchList.Core_Effective_End_Date__c = system.today()+5;
        return complianceWatchList;
    }

    public static User createUser(String profileId){
        User u = new User();
        u.firstname = 'ABC';
        u.lastName = 'XYZ'; 
        u.email =  'uniqueName@test' + UserInfo.getOrganizationId() + '.intel.com'; 
        u.Username = 'uniqueName@test' + UserInfo.getOrganizationId() + '.intel.com'; 
        u.EmailEncodingKey = 'ISO-8859-1'; 
        u.Alias = 'ABC'; 
        u.TimeZoneSidKey = 'America/Los_Angeles'; 
        u.LocaleSidKey = 'en_US'; 
        u.LanguageLocaleKey = 'en_US'; 
        u.ProfileId = profileId;
        return u;
    }
    
    public static ACM_Integration_Message_Queue__c createIntegrationMessageQueue(String accountId){
        ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
        integrationMessage.Content__c = accountId;
        integrationMessage.Custom_Filter__c = accountId;
        integrationMessage.Content_Type__c = 'AccountId';
        integrationMessage.Message_Status__c = 'New';
        integrationMessage.Module_Name__c = 'ACM';
        integrationMessage.Queue_Type__c = 'Outbound';
        integrationMessage.Retry_Count__c = 0;
        integrationMessage.Source_System__c = 'Reltio';
        return integrationMessage;
    }

    /**public static Account_Create_Request__c createApproveAccountRequest(String accountRequestName, String accountRequestCountry){
        Account_Create_Request__c accountCreateRequest=new Account_Create_Request__c();
        accountCreateRequest.Name = accountRequestName;
        accountCreateRequest.Account_Name__c = accountRequestName;
        accountCreateRequest.City__c='Delhi';
        accountCreateRequest.Country__c=accountRequestCountry;
        accountCreateRequest.Customer_Process_Engagement__c='DIR_PRC_EXCPT';
        accountCreateRequest.Street__c='G.T road';
        return accountCreateRequest;
    }*/

    /**public static Account_Create_Request__c createRejectAccountRequest(String accountRequestName, String accountRequestCountry){
        Account_Create_Request__c accountCreateRequest=new Account_Create_Request__c();
        accountCreateRequest.Name = accountRequestName;
        accountCreateRequest.Account_Name__c = accountRequestName;
        accountCreateRequest.City__c='Kolkata';
        accountCreateRequest.Country__c=accountRequestCountry;
        accountCreateRequest.Customer_Process_Engagement__c='DIR_PRC_EXCPT';
        accountCreateRequest.Street__c='Test street';
        return accountCreateRequest;
    }*/

}