@isTest
public class Pricing_QuoteGroupUnlinkController_Test {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Account acc = new Account();
        Contact con = new  Contact();
        List<User> accountExecutiveUserList = new List<User>();
        List<User> salesRepUserList = new List<User>();
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
        System.runAs(adminUserList[0]){
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            acc = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Group_Unlink_Controller');
            accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();    
            endCustomer = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
            for(Integer i=0;i<3;i++){ 
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.SBQQ__Account__c = acc.Id;
                quote.SBQQ__PrimaryContact__c = con.Id;
                quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
                quote.Pricing_Project_Name_Nm__c = 'Test Project';
                quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
                quote.Pricing_Intel_Sales_Rep_Email_Txt__c = salesRepUserList[0].Email;
                quote.Pricing_End_Customer__c = endCustomer.Id;
                quote.Pricing_Customer_Nm__c = '';
                quote.Pricing_ShipmentStDate_Dt__c = system.today();
                quote.Pricing_Intel_Account_Exec_Email_Txt__c = accountExecutiveUserList[0].Email;
                quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
                quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
                quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
                quote.Pricing_Region_Nm__c = 'APJ';      
                quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
                lstQuote.add(quote);
            }
            insert lstQuote;
            Pricing_Quote_Group__c grp = new Pricing_Quote_Group__c();
            insert grp;
            test.stopTest();
        }
    }
    static testMethod void testGetQuoteGroupToDelete(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, Pricing_Group_Nm__c from SBQQ__Quote__c LIMIT 1];
        Pricing_Quote_Group__c qGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c LIMIT 1];
        quoteList[0].Pricing_Group_Nm__c = qGrp.Id;
        update quoteList;
        Test.startTest();
        Pricing_QuoteGroupUnlinkControllerDummy.getQuoteGroupToDelete(qGrp.Id);
        Test.stopTest();
    }
}