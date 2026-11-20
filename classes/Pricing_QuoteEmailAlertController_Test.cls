/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 03-27-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteEmailAlertController_Test {
    //Method to setup test data
    @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        system.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<Contact> drLimitedConList = Pricing_Test_Utility.createDrafterLimitedContact(acc.Id,1);
            Contact con =drLimitedConList[0];
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
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

			Test.stopTest();
        }
    }
    //Method to test Pricing_QuoteEmailAlertController class
    @isTest
    public static void testQuoteEmailAlert()
    {
        Test.StartTest();
       // List<User> lstUsers = Pricing_Test_Utility.createUser();
        List<SBQQ__Quote__c> lstquote = [SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,SBQQ__PrimaryContact__r.Name,SBQQ__PrimaryContact__c,
                                         Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Name__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Name,Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c,SBQQ__Status__c FROM SBQQ__Quote__c];        
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,
                                                  SBQQ__Quote__r.SBQQ__SalesRep__r.Name,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c
                                                  FROM SBQQ__QuoteLine__c LIMIT 1];      
        //Test.StartTest();
        Pricing_QuoteEmailAlertController p1 = new Pricing_QuoteEmailAlertController();
        p1.quoteId = lstquote[0].Id;
        p1.quoteLineId = lstquoteLines[0].Id;
        String domain = p1.getDomainName();
        
        System.assertEquals(String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()),domain,'Domain Name is Incorrect');
        
        SBQQ__Quote__c quote = p1.getQuoteData();
        
        System.assertEquals(lstquote[0],quote);
        
        SBQQ__QuoteLine__c quoteLine = p1.getQuoteLineData();
        String primaryContact = p1.getCurrentPrimaryContact();
        List<String> approverEmail = p1.getApproverEmailList();
        
        System.assertEquals(lstquoteLines[0].Id,quoteLine.Id, 'Clone assertion failed');
        
        Pricing_QuoteEmailAlertController p2 = new Pricing_QuoteEmailAlertController();
        p2.quoteId = null;
        p2.quoteLineId = null;
        p2.quoteData = null;
        p2.quoteLineData = null;
        P2.headerURL = 'test';
        SBQQ__Quote__c quote2 = p2.getQuoteData();
        System.assertEquals(new SBQQ__Quote__c(),quote2, 'Assertion failed for clone');
        SBQQ__QuoteLine__c quoteLine2 = p2.getQuoteLineData();
        System.assertEquals(new SBQQ__QuoteLine__c(),quoteLine2, 'Assertion failed for clone');
        P2.getHeaderURL();
        
        Test.StopTest();
    }
    
    @isTest
    public static void testQuoteTeamEmailAlertTest(){
        Test.StartTest();
        List<SBQQ__Quote__c> lstquote = [SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,
                                         Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c FROM SBQQ__Quote__c];        
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c,
                                                  SBQQ__Quote__r.SBQQ__SalesRep__r.Name 
                                                  FROM SBQQ__QuoteLine__c LIMIT 1];  
        List<Pricing_Quote_Team__c> quoteTeamMemberList = [SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__r.Name,LastModifiedBy.Name,
                                            Pricing_Quote_Id__c,Pricing_Quote_Id__r.Name,Pricing_Quote_Id__r.Pricing_Customer_Nm__c,
                                            Pricing_Quote_Id__r.Pricing_Project_Name_Nm__c,Pricing_Quote_Id__r.Pricing_Bid_Dt__c,Pricing_Grant_Access_Ind__c 
                                         	FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c= :lstquote[0].Id LIMIT 2];

       //Test.startTest();
        Pricing_QuoteEmailAlertController p1 = new Pricing_QuoteEmailAlertController();
        p1.qtmId=quoteTeamMemberList[0].Id;
        String domain = p1.getDomainName();
        System.assertEquals(String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()),domain,'Domain Name is Incorrect');
        Pricing_Quote_Team__c qtm = p1.getQtmData();
        p1.getHeaderURL();
        String externalDomain = p1.getExternalDomainName();
        //String primaryContact = p1.getCurrentPrimaryContact();
        delete quoteTeamMemberList;
        Test.stopTest();
        
        //delete quoteTeamMemberList;
        
    }

    @isTest
    public static void testQuoteEmailAlertControllerChangesFields()
    {
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        Test.StartTest();
        SBQQ__QuoteLine__c qliRef = new SBQQ__QuoteLine__c();
        qliRef.Pricing_Approved_End_Date_Dt__c = system.today();
        qliRef.Pricing_Approved_Start_Date_Dt__c = system.today();
        qliRef.Pricing_ECAP_Price_Amt__c = 10;
        qliRef.Pricing_End_Date_dt__c = system.today()+1;
        qliRef.Pricing_Approved_Unit_Qty__c = 100;
        qliRef.Pricing_Req_Discounted_Unit_Price__c = 10;
        
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.id = lstquoteLines[0].id;
        qli.Pricing_Request_Discount_Unit_Price_qty__c = 100;
        qli.Pricing_ECAP_Price_Amt__c = 150;
        qli.Pricing_Approved_Unit_Qty__c = 200;
        qli.Pricing_Req_Discounted_Unit_Price__c = 250;
        qli.Pricing_End_Date_dt__c = system.today()+2;
        qli.Pricing_Start_Date_dt__c = system.today()+2;
        qli.Pricing_New_Quantity_qty__c = 300;
        qli.Pricing_Reference_Quote_Line_Nbr__r = qliRef;

        String changedFields2 = Pricing_QuoteEmailAlertController.getChangedFields(qli);
        System.assert(!String.isEmpty(changedFields2));
        Test.StopTest();
    }

    @isTest
    public static void testGetQlList() {
        Test.StartTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Pricing_QuoteEmailAlertController p1 = new Pricing_QuoteEmailAlertController();
        p1.quotesIds = quote.Id;
        List<SBQQ__QuoteLine__c> qliList =  p1.getQlList();
        String toEmail = p1.gettoEmails();
        String ccEmail = p1.getccEmails();
        String bccEmail = p1.getbccEmails();
        System.assert(!qliList.isEmpty());
        Test.StopTest();
    }
}