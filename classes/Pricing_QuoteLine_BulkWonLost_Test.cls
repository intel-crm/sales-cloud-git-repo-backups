@isTest
public class Pricing_QuoteLine_BulkWonLost_Test {
    
    @testSetup
    static void dataSetup(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 5);
            test.stopTest();
        }
    }
    
    static testMethod void testProcessWonLost(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        String msg = '';
        Test.startTest();
        System.runAs(adminUser){
            quoteLineList[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLineList[1].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLineList[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLineList[3].Id;
            update quoteLineList;
            String base64Data = JSON.serialize('Quote Line Number,My Deals Folio ID,Deal ID,Quote Line Status,Won/Lost Comments,Lost Reason\n"'+quoteLineList[0].Pricing_Quote_Line_Number__c+'","","","lost","","Other"\n"'+quoteLineList[1].Pricing_Quote_Line_Number__c+'","","","lost","",""\n"'+quoteLineList[2].Pricing_Quote_Line_Number__c+'","","","cancel","",""\n"'+quoteLineList[3].Pricing_Quote_Line_Number__c+'","","","won","你好",""\n"'+quoteLineList[4].Pricing_Quote_Line_Number__c+'","","","","",""\n');
            msg = Pricing_QuoteLine_BulkWonLost.processWonLost(base64Data, 'bulkwonlost');
        }
        System.assertEquals(msg, 'Operation Completed');
        Test.stopTest();
    }
    
    static testMethod void testProcessWonLostinValid(){
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        String msg = '';
        Test.startTest();
        System.runAs(adminUser){
            quoteLineList[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLineList[1].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLineList[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLineList[3].Id;
            update quoteLineList;
            String base64Data = JSON.serialize('Quote Line Number,My Deals Folio ID,Deal ID,Quote Line Status,Won/Lost Comments,Lost Reason\n"'+quoteLineList[0].Pricing_Quote_Line_Number__c+'","","","lost",""\n"'+quoteLineList[1].Pricing_Quote_Line_Number__c+'","","","lost","",""\n"'+quoteLineList[2].Pricing_Quote_Line_Number__c+'","","","cancel","",""\n"'+quoteLineList[3].Pricing_Quote_Line_Number__c+'","","","won","你好",""\n"'+quoteLineList[4].Pricing_Quote_Line_Number__c+'","","","","",""\n');
            msg = Pricing_QuoteLine_BulkWonLost.processWonLost(base64Data, 'bulkwonlost');
        }
        System.assertEquals(msg.equals('Operation Completed'), false);
        Test.stopTest();
    }

}