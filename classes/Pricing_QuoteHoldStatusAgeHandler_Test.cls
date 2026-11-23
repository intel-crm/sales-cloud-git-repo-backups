@isTest
public class Pricing_QuoteHoldStatusAgeHandler_Test {
     @testSetup
    public static void setUpData(){
    	List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuote(acc.Id, con.Id, 1);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            
            Pricing_Quote_Hold_Status_Age__c onHoldEntry = new Pricing_Quote_Hold_Status_Age__c();
                        onHoldEntry.Pricing_QuoteOnHold__c = quoteList[0].Id;
                        onHoldEntry.Pricing_Is_On_Hold__c = quoteList[0].Pricing_On_Hold_Cb__c;
                        onHoldEntry.Pricing_Quote_On_Hold_Comment__c = quoteList[0].Pricing_On_Hold_Comment__c;
                        onHoldEntry.Pricing_QuoteOnHold_Start_Time__c = System.now();
                        onHoldEntry.Pricing_QuoteOnHold_User_Role__c = 'SDM';
                        
            Test.stopTest();
        }
    }

}