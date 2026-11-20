/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-31-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_CompProductPriceBulkBatch_Test {
	@testSetup
    static void dataSetup(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<Pricing_Competitor_Product_Price_Staging__c> compProductsPriceList = Pricing_Test_Utility.createCompetitorProductPriceStaging();
            test.stopTest();
        }
    }
    
    static testMethod void testProcessCompProdPrice(){
        Test.startTest();
        List<Pricing_Competitor_Product_Price_Staging__c> cppList =  [SELECT Id, Pricing_Competitor_Product_Name_Staging__c, 
                                                                      Pricing_Region_Staging_Nm__c, Pricing_Final_Meet_Comp_Price_Staging__c, Pricing_Application_Staging_Nm__c, 
                                                                      Pricing_List_Price_Staging__c, Pricing_Median_Meet_Comp_Disty_Staging__c 
                                                                      from Pricing_Competitor_Product_Price_Staging__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Map<String, Pricing_Competitor_Product_Price_Staging__c> cppMap = New Map<String, Pricing_Competitor_Product_Price_Staging__c>();

        cppMap.put(cppList[0].Pricing_Competitor_Product_Name_Staging__c,cppList[0]);
        System.runAs(adminUser){
            Pricing_CompProductPriceBulkBatch bulkCPPBatch = new Pricing_CompProductPriceBulkBatch(cppMap);
            Database.executeBatch(bulkCPPBatch, Integer.valueOf(Label.Pricing_QuoteLine_BulkWonLost_BatchSize));
        }
        System.assertEquals(cppList.size() > 0,true);
        Test.stopTest();
    }
}