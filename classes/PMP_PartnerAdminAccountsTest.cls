@isTest
private class PMP_PartnerAdminAccountsTest {

    @isTest
    static void testGetPartnerAdminAccounts() {
        
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        
        User user = [SELECT AccountId FROM User WHERE id =:Userinfo.getUserId()];
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = user.AccountId; 
        coreAccnt.Core_Inactive_Ind__c = false;
        insert coreAccnt;
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
      
        insert company;
        System.assertNotEquals(company, Null);
       
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        system.runAs(user){
            Test.startTest();
            PMP_PartnerAdminAccounts.getPartnerAdminAccounts();
            Test.stopTest();
        }
        
    }
}