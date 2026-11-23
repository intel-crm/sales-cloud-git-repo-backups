@isTest
public class Pricing_CustomerDivisionComp_cntrl_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]){
            //Pricing_Test_Utility.createPriceBook();
            
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            User partnerUserList = Pricing_Test_Utility.createPartnerUser(acc.Id);
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            List<Pricing_Performance_Metric__c> performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Pricing_Quote_Team__c quoteTM = new Pricing_Quote_Team__c();  
            quoteTM.Pricing_Quote_Id__c = quoteList[0].Id;
            quoteTM.Pricing_Quote_Team_Member_Id__c = adminUserList[0].id;
            quoteTM.Pricing_Role_Nm__c = 'Account Executive'; 
            insert quoteTM;
            
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
            //The setUpData covers 54% for quote creation
            
            //Creating data for Object1 and Object2
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedAccountObj;
            unifiedAccountObj = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedAccountObj.Name = 'Test';
            unifiedAccountObj.Pricing_Unified_EndCustomer_Id__c = '123';
            unifiedAccountObj.Pricing_Account_Nm__c = acc.Id;
            insert unifiedAccountObj;
            
            Pricing_UnifiedEndCustomerCountryMapping__c unifiedCountryObj;
            unifiedCountryObj = new Pricing_UnifiedEndCustomerCountryMapping__c();
            unifiedCountryObj.Pricing_Unified_EndCustomer_Act_Mapping__c = unifiedAccountObj.Id;
            unifiedCountryObj.Name = 'Test';
            unifiedCountryObj.Pricing_Unified_Country_EndCustomer_Id__c = '111';
            insert unifiedCountryObj;
            Pricing_Account_Division__c accDivision = new Pricing_Account_Division__c(Pricing_Account__c = acc.Id,Name = 'Dell',Pricing_Active_ind__c = true);
            insert accDivision;
        }
    }
    static testmethod void testAccountDivision() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c]; 
        quoteList[0].Pricing_Account_Division_Nm__c = 'ABC';
        update quoteList[0];
        Pricing_CustomerDivisionComp_cntrl.getCustomerDivision(quoteList[0].id);
        Pricing_CustomerDivisionComp_cntrl.getCustomerDivisionValue(quoteList[0].id);
        Pricing_CustomerDivisionComp_cntrl.updateQuoteCustomerDivision(quoteList[0].id , 'Dell A');
        Pricing_CustomerDivisionComp_cntrl.getstatusPrecedenceNumber(quoteList[0].id);
        
        Test.stopTest(); 
    }
    static testmethod void testAccountDivision2() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c];
        Pricing_CustomerDivisionComp_cntrl.getCustomerDivision(quoteList[0].id);
        Pricing_CustomerDivisionComp_cntrl.getCustomerDivisionValue(quoteList[0].id);
        Pricing_CustomerDivisionComp_cntrl.updateQuoteCustomerDivision(quoteList[0].id , 'Dell B');
        Pricing_CustomerDivisionComp_cntrl.getstatusPrecedenceNumber(quoteList[0].id);
        Test.stopTest(); 
    }
    static testmethod void testAccountDivision3() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c]; 
        quoteList[0].Pricing_Account_Division_Nm__c = 'test';
        update quoteList[0];
        SBQQ__QuoteLine__c qli = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id, 'Pending Intel Field Review');
        qli.Pricing_Quote_Line_Status_Number__c = 50;
        update qli;
        Pricing_CustomerDivisionComp_cntrl.getstatusPrecedenceNumber(quoteList[0].id);
        Test.stopTest();
    }
}