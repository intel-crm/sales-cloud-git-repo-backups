@isTest
public class Pricing_QuoteTeamEmailController_Test {
	@testSetup
    public static void setUpData(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        system.runAs(lstUsers[0]){
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email); 
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            
            Document document;
            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            
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
            
        }
    }
    
    @isTest
    public static void testQuoteTeamEmailAlertTest(){
        List<SBQQ__Quote__c> lstquote = [SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,
                                         Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c FROM SBQQ__Quote__c];        
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,Pricing_pm_approval_comments_nm__c 	,
                                                  SBQQ__Quote__r.SBQQ__SalesRep__r.Name 
                                                  FROM SBQQ__QuoteLine__c LIMIT 1];  
        List<Pricing_Quote_Team__c> quoteTeamMemberList = [SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__r.Name,LastModifiedBy.Name,
                                            Pricing_Quote_Id__c,Pricing_Quote_Id__r.Name,Pricing_Quote_Id__r.Pricing_Customer_Nm__c,
                                            Pricing_Quote_Id__r.Pricing_Project_Name_Nm__c,Pricing_Quote_Id__r.Pricing_Bid_Dt__c,Pricing_Grant_Access_Ind__c 
                                         	FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c= :lstquote[0].Id LIMIT 2];
        
        Test.startTest();
        Pricing_QuoteTeamEmailAlertController p1 = new Pricing_QuoteTeamEmailAlertController();
        p1.qtmId=quoteTeamMemberList[0].Id;
        String domain = p1.getDomainName();
        System.assertEquals(String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()),domain,'Domain Name is Incorrect');
        Pricing_Quote_Team__c qtm = p1.getQtmData();
        p1.getHeaderURL();
        Test.stopTest();
        
        delete quoteTeamMemberList;
        
    }
    
}