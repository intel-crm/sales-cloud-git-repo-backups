@isTest
public class Pricing_QuoteLineApprovalEmailCntrl_Test {
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
            
			Test.stopTest();
        }
    }
    //Method to test Pricing_QuoteEmailAlertController class
    @isTest
    public static void testQuoteEmailAlertController1()
    {
        Test.StartTest();
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,
                                                  SBQQ__Quote__r.SBQQ__SalesRep__r.Name,Pricing_pm_approval_comments_nm__c 	
                                                  FROM SBQQ__QuoteLine__c LIMIT 1];      
        //Test.StartTest();
        List<User> lstUsers = Pricing_Test_Utility.createUser();
        Pricing_QuoteLineApprovalEmailController p1 = new Pricing_QuoteLineApprovalEmailController();
        p1.quoteLineId = lstquoteLines[0].Id;
        String domain = p1.getDomainName();
        String primaryContact = p1.getCurrentPrimaryContact();
        String changedFields = p1.getChangedFields();
        p1.getHeaderURL();
        System.assertEquals(String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()),domain,'Domain Name is Incorrect');
        Test.StopTest();
    }
    
    @isTest
    public static void testQuoteEmailAlertController2()
    {
        Test.StartTest();    
        //Test.StartTest();
        List<User> lstUsers = Pricing_Test_Utility.createUser();
        Pricing_QuoteLineApprovalEmailController p2 = new Pricing_QuoteLineApprovalEmailController();
        p2.quoteLineId = null;
        p2.quoteLineData = null;
        String changedFields2 = p2.getChangedFields();
        System.assertEquals(changedFields2,null);
        Test.StopTest();
    }
    
    @isTest
    public static void testQuoteEmailAlertController3()
    {
        List<SBQQ__QuoteLine__c> lstquoteLines = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        Test.StartTest();
        SBQQ__QuoteLine__c qliRef = new SBQQ__QuoteLine__c();
        qliRef.Pricing_Approved_End_Date_Dt__c = system.today();
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
        qli.Pricing_New_Quantity_qty__c = 300;
        qli.Pricing_Reference_Quote_Line_Nbr__r = qliRef;

        Pricing_QuoteLineApprovalEmailController p2 = new Pricing_QuoteLineApprovalEmailController();
        p2.quoteLineData = qli;
        String changedFields2 = p2.getChangedFields();
        System.assert(!String.isEmpty(changedFields2));
        Test.StopTest();
    }
}