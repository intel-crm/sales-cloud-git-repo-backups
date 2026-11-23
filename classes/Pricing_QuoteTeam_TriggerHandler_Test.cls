/**
 * @description       : 
 * @author            : Siddharth Kant
 * @group             : 
 * @last modified on  : 10-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteTeam_TriggerHandler_Test {
    @testSetup
    public static void setUpData(){
        //test.startTest();
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        system.runAs(lstUsers[0]){
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();

            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Pricing_Quote_Team_Trigger_Handler_Test');        
            Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
            Contact con1 = new Contact();
            con1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
            con1.FirstName = 'FirstName2';
            con1.LastName = 'LastName2';
            con1.Email = 'FirstName2@intel.com';
            con1.AccountId = acc.Id;
            con1.Core_Primary_Contact__c = true;
            con1.MailingCountry = 'India';
            insert con1;
            
            Pricing_Test_Utility.createTemplate(lstUsers[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            
            Test.startTest();            
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
            PermissionSet permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1];
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
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
                User u4= new User(Alias = 'newUsr1', Email= 'dummyuser@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'dummyuser@Intel.com' + Math.floor(Math.random() * 1000));
                
                userList.add(u4);
               
            }
             
            insert userList;
            
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : userList){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
                
            }
            insert permissionList;
            
             User u3 = new User(alias = 'test123', email='partner@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con1.Id,
                             timezonesidkey='America/Los_Angeles', username='FirstName2@intel.com');
            insert u3;
            
            List<PermissionSetAssignment> permissionList1 = new List<PermissionSetAssignment>();
            permissionList1.add(new PermissionSetAssignment(AssigneeId = u3.Id, PermissionSetId = permissionRec.Id));
            permissionList1.add(new PermissionSetAssignment(AssigneeId = u3.Id, PermissionSetId = ps.Id));
            insert permissionList1;
            
            Pricing_Quote_Team_Role_Access_Mapping__mdt qtmRoleAccessMdt = new Pricing_Quote_Team_Role_Access_Mapping__mdt();
            qtmRoleAccessMdt.Pricing_Role_Nm__c = 'Account Executive';
            qtmRoleAccessMdt.Pricing_Access_Level_Nm__c = '';
            qtmRoleAccessMdt.Permission_Set_API_Nm__c = '';
            qtmRoleAccessMdt.Pricing_IsActive_Ind__c =true;
           // insert qtmRoleAccessMdt;
        }
         test.stopTest();
    }
    
    @isTest
    public static void testQuoteTeamTriggerHandlerTest(){
        List<SBQQ__Quote__c> lstquote = [SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,SBQQ__Account__c,
                                         Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c FROM SBQQ__Quote__c];        
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,
                                                  Pricing_pm_approval_comments_nm__c 	,SBQQ__Quote__r.SBQQ__SalesRep__r.Name 
                                                  FROM SBQQ__QuoteLine__c LIMIT 1];  
        
        User aeUser = [SELECT Id from User where Email= 'firstAE@intel.com'];
        User itsUser = [SELECT Id from User where Email= 'firstAE@intel.com'];
        User aeQuoteUser = [SELECT Id,Email from User where Email= 'firstNameAE@intel.com'];
        User primaryContact = [SELECT Id from User where Email= 'Pricing_Quote_Team_Trigger_Handler_Test@noemail.com'];
        User dummyUser = [SELECT Id FROM User WHERE EMail='dummyuser@intel.com' limit 1];
        List<User> fseUser2 = Pricing_Test_Utility.createFSEUser();
        AccountTeamMember act2 =  new AccountTeamMember(AccountId = lstquote[0].SBQQ__Account__c,
                                                            TeamMemberRole = 'Technical Sales',UserId = fseUser2[0].Id);
        
        Contact con = [Select id from Contact where Email='FirstName2@intel.com'];
        User fseUser = [Select id from User where Email='firstNameSalesRep@intel.com' ];
        
        
        
        List<Pricing_Quote_Team__c> quoteTeamMemberList = new  List<Pricing_Quote_Team__c>();
        
        Pricing_Quote_Team__c qtm2=new Pricing_Quote_Team__c();
        qtm2.Pricing_Quote_Id__c = lstquote[0].Id;
        qtm2.Pricing_Quote_Team_Member_Id__c = itsUser.Id;
        qtm2.Pricing_Role_Nm__c = 'ITS';
        quoteTeamMemberList.add(qtm2);        
       
        Pricing_Quote_Team__c qtm3=new Pricing_Quote_Team__c();
        qtm3.Pricing_Quote_Id__c = lstquote[0].Id;
        qtm3.Pricing_Quote_Team_Member_Id__c = dummyUser.Id;
        qtm3.Pricing_Role_Nm__c = 'Account Executive';
        quoteTeamMemberList.add(qtm3);
        
        Pricing_Quote_Team__c qtm4=new Pricing_Quote_Team__c();
        qtm4.Pricing_Quote_Id__c = lstquote[0].Id;
        qtm4.Pricing_Quote_Team_Member_Id__c = fseUser2[0].id;
        qtm4.Pricing_Role_Nm__c = 'FSE/SDM';
        quoteTeamMemberList.add(qtm4);
        insert quoteTeamMemberList;
        
        Test.startTest(); 
        System.runAs(fseUser){
        lstquote[0].SBQQ__PrimaryContact__c = con.id;
        update lstquote[0]; 
        }
        //Test.startTest(); 
        List<Pricing_Quote_Team__c> qtms = [SELECT id,Pricing_Quote_Team_Member_Id__r.Email FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c=:lstquote[0].Id AND Pricing_Role_Nm__c = 'Account Executive'];
        delete qtms[0];
       
        SBQQ__Quote__c quote = [SELECT Id,Pricing_Intel_Account_Exec_Email_Txt__c FROM SBQQ__Quote__c WHERE Id= :lstquote[0].Id];
        system.assertEquals('dummyuser@intel.com', quote.Pricing_Intel_Account_Exec_Email_Txt__c.toLowerCase(), 'AE Email has not been replaced');
        Test.stopTest();     
    }
    
    @isTest
    public static void testDeleteFSEQuoteTeam(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,SBQQ__Account__c,
                                         Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c,SBQQ__SalesRep__c FROM SBQQ__Quote__c];    
        List<User> fseUser2 = Pricing_Test_Utility.createFSEUser();
        AccountTeamMember act2 =  new AccountTeamMember(AccountId = lstquote[0].SBQQ__Account__c,
                                                            TeamMemberRole = 'Technical Sales',UserId = fseUser2[0].Id);
        List<Pricing_Quote_Team__c> quoteTeamMemberList = new List<Pricing_Quote_Team__c>();
        Pricing_Quote_Team__c qtm1=new Pricing_Quote_Team__c();
        qtm1.Pricing_Quote_Id__c = lstquote[0].Id;
        qtm1.Pricing_Quote_Team_Member_Id__c = lstquote[0].SBQQ__SalesRep__c;
        qtm1.Pricing_Role_Nm__c = 'FSE/SDM';
        quoteTeamMemberList.add(qtm1);
        
        Pricing_Quote_Team__c qtm2=new Pricing_Quote_Team__c();
        qtm2.Pricing_Quote_Id__c = lstquote[0].Id;
        qtm2.Pricing_Quote_Team_Member_Id__c = fseUser2[0].id;
        qtm2.Pricing_Role_Nm__c = 'FSE/SDM';
        quoteTeamMemberList.add(qtm2);
        insert quoteTeamMemberList;
        delete qtm1;
        SBQQ__Quote__c quote1 = [SELECT Id,SBQQ__SalesRep__c FROM SBQQ__Quote__c WHERE Id= :lstquote[0].Id];
        Test.stopTest();
        system.assert(quoteTeamMemberList.contains(qtm1), 'QuoteTeam did not get deleted.');
    }
}