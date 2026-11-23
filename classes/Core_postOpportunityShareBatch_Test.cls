@isTest
global class Core_postOpportunityShareBatch_Test {
    @isTest
    public static void opportunityShare_test(){
        Test.startTest();
        String sLastName = 'User1';
        String sAlias = 'tuser1';
        String sEmail = 'test.user1@intel.com';
        String sUserName = 'test.user1@intel.com.crm.testclass';
        String sProfileName = 'Standard User';
        String userRole='00Eo0000000f9evEAA';
        
        String sLastName1 = 'User2';
        String sAlias1 = 'tuser2';
        String sEmail1 = 'test.user2@intel.com';
        String sUserName1 = 'test.user2@intel.com.crm.testclass';
        String sProfileName1 = 'Standard User';
        String userRole1='00Eo0000000f9elEAA';
        
        Id profileId;
        List<Profile> lstProfiles = null;
        
        // Get the Id of the Standard Profile             
        lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
        if (lstProfiles.size() == 0)
            profileId = null;
        else
            profileId = lstProfiles[0].Id;
        //List<User> userList= new List<User>();
        User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId,UserRoleId=userRole,
                                 EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert testUser;
        User testUser1 = new User(LastName = sLastName1, Alias = sAlias1, Email = sEmail1, UserName = sUserName1, ProfileId = profileId,UserRoleId=userRole1,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',DelegatedApproverId=testUser.Id);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert testUser1;}
       
        Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Business_Party_Id__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        
       // Id accId = [Select id from Account where Core_Business_Party_Id__c != null and RecordType.Name = 'Intel Account' limit 1][0].Id;
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to tEST for class', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1),Core_Approver_1__c= testUser1.Id,
                                                 Core_Approver_2__c=testUser1.Id,Core_Approver_3__c=testUser1.Id,Core_Approver_4__c=testUser1.Id,Core_Approver_5__c=testUser1.Id,
                                                 Core_Approval_Status__c='Not Submitted');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
        opportunityShare oppShare=new opportunityShare();
        oppShare.OpportunityId= oppForLoss.Id;
        oppShare.UserOrGroupId = testUser.Id;
        oppShare.OpportunityAccessLevel= 'Edit';
        oppShare.RowCause = Schema.opportunityShare.RowCause.Manual;
        List<Id> oppShareId=new List<Id>();
        Map<id,id> userId= new Map<Id,Id>();
        userId.put(testUser1.id,testUser1.id);
        //Database.SaveResult delegateResults= new Database.SaveResult();
          System.runAs(Core_Test_Utility.systemAdminUser) {
               Database.SaveResult delegateResults=DataBase.insert(oppShare,false);
               
              oppShareId.add(delegateResults.getId());
          } 
        Map<Id,opportunity> opp=new Map<Id,opportunity>();
        opp.put(testUser.Id,oppForLoss);
        Core_Delegate_Approver__c dele=new Core_Delegate_Approver__c(Core_User__c=testUser1.id,Core_Opportunity_ID__c='',Core_Manager__c=testUser.id);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert dele;
        }
        
        
        database.executebatch(new Core_postOpportunityShareBatch (opp,oppShareId,userId),50);
        
       
        
        Test.stopTest(); 
    }
}