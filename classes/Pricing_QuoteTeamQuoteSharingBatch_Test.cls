@isTest
public class Pricing_QuoteTeamQuoteSharingBatch_Test {
    static testMethod void batchQuoteTeamQuoteSharingTest(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        system.runAs(lstUsers[0]){
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Team_Quote_Sharing_Batch_Test');
            Pricing_Test_Utility.createTemplate(lstUsers[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email); 
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            
            List<User> userList = new List<User>();
            Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
            Set<Id> userProfileIdSet=new Set<Id>();
            for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
                userProfileIdSet.add(proId.Id);
            }
            
            for(Id profileId : userProfileIdSet){
            	User u1 = new User(Alias = 'newUser', Email= 'firstAE@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstAE@Intel.com' + Math.floor(Math.random() * 1000));
                
            	userList.add(u1);
                User u2 = new User(Alias = 'newUser', Email= 'secondAE@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'secondITS@Intel.com' + Math.floor(Math.random() * 1000));
                
            	userList.add(u2);
            }
            
            insert userList;
            
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : userList){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userList[0].Id, PermissionSetId = ps1.Id));
                //PermissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }
            //insert permissionList;
            //Test.startTest();
            List<Pricing_Quote_Team__c> quoteTeamMemberList = new  List<Pricing_Quote_Team__c>();
            Pricing_Quote_Team__c qtm1=new Pricing_Quote_Team__c();
            qtm1.Pricing_Quote_Id__c = lstquote[0].Id;
            qtm1.Pricing_Quote_Team_Member_Id__c = userList[0].Id;
            qtm1.Pricing_Role_Nm__c = 'Account Executive';
            quoteTeamMemberList.add(qtm1);
            
            Pricing_Quote_Team__c qtm2=new Pricing_Quote_Team__c();
            qtm2.Pricing_Quote_Id__c = lstquote[0].Id;
            qtm2.Pricing_Quote_Team_Member_Id__c = userList[1].Id;
            qtm2.Pricing_Role_Nm__c = 'ITS';
            quoteTeamMemberList.add(qtm2);
            insert quoteTeamMemberList;
            
            Pricing_QuoteTeam_QuoteSharing_Batch quoteTeamBatch = new Pricing_QuoteTeam_QuoteSharing_Batch();
            Id batchId = Database.executeBatch(quoteTeamBatch);
            System.assertEquals(batchId != null, true);
            Test.stopTest();
        }
    }
}