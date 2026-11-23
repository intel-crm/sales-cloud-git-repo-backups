public class UCD_ACM_Cntrlr_TestDataInitialization {
    public static Account createAccountByRecordType(String accountName,String recordType,String CustAggrType){
        Account account = new Account();
        account.Name = accountName;
        account.Core_Customer_Aggregation_Type__c = CustAggrType;
        account.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        account.BillingCountryCode	= 'IND';
        account.BillingCity = 'TestCity';
        account.BillingStreet = 'TestStreet';
        account.Core_Business_Party_Id__c = '1234';
        account.ShippingCountryCode = 'IND';
        return account;
    }
    public static Business_Types__c createBusinessType(String typeName,String typeCode){
        Business_Types__c businessType = new Business_Types__c(Name=typeName,Is_Active__c=true,Business_Type_Code__c=typeCode,Business_Types_Category__c = 'CPE');
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
        integrationMessage.Retry_Count__c = 0;
        return integrationMessage;
    }

    public static Account_Create_Request__c createApproveAccountRequest( Account account){
        Account_Create_Request__c accountCreateRequest=new Account_Create_Request__c();
        accountCreateRequest.Account_Name__c = 'Test';
      //  accountCreateRequest.Country__c = 'India';
        accountCreateRequest.Customer_Process_Engagement__c='DIR_PRC_EXCPT';
        accountCreateRequest.Rejected_Reason__c = 'Test Rejected';
        accountCreateRequest.Request_Flow_Status__c = 'Pending';
        accountCreateRequest.Process_Type__c = 'Opportunity Management';
        accountCreateRequest.Requestor_Name__c = UserInfo.getName();
        accountCreateRequest.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
     //   accountCreateRequest.State__c = 'New';
        accountCreateRequest.Requested_Account__c = account.Id;
        return accountCreateRequest;
    }

    public static Account_Create_Request__c createAccountRequest(String accountRequestName, String Status, Account account){
        Account_Create_Request__c accountCreateRequest=new Account_Create_Request__c();
        accountCreateRequest.Account_Name__c = accountRequestName;
     //   accountCreateRequest.Customer_Process_Engagement__c='DIR_PRC_EXCPT';
        accountCreateRequest.Rejected_Reason__c='Test Rejected';
        accountCreateRequest.Address__City__s = 'Kolkata';
        accountCreateRequest.Address__CountryCode__s= 'IND';
        accountCreateRequest.Address__Street__s = 'Demon Street';
        accountCreateRequest.Process_Type__c = 'Opportunity Management';
        if(account != null){
            accountCreateRequest.Requested_Account__c = account.Id;
        }
        if(Status == 'Approved'){
            accountCreateRequest.Requested_Account__c = account.Id;
            accountCreateRequest.Status__c = 'Approved';
        }else{
            accountCreateRequest.Status__c= Status;
        }
        return accountCreateRequest;
    }
}