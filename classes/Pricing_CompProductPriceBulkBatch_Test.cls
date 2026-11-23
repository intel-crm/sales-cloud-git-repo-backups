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
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            //List<Pricing_Competitor_Product_Price_Staging__c> compProductsPriceList = Pricing_Test_Utility.createCompetitorProductPriceStaging();
            Id compRecordId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c','Pricing_Data_Center');
            Pricing_Competitor_Product__c compProduct1 = new Pricing_Competitor_Product__c(Name='TestCompProduct1',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
            insert compProduct1;
            Pricing_Competitor_Product__c compProduct2 = new Pricing_Competitor_Product__c(Name='TestCompProduct2',   RecordTypeId = compRecordId, Pricing_Active_cb__c = true);
            insert compProduct2;
            
            List<Pricing_Competitor_Product_Price_Staging__c> compProductsPriceList = new List<Pricing_Competitor_Product_Price_Staging__c>();
            Pricing_Competitor_Product_Price_Staging__c compProductPrice;
            compProductPrice = new Pricing_Competitor_Product_Price_Staging__c(Pricing_Competitor_Product_Name_Staging__c=compProduct1.Name,Pricing_Region_Staging_Nm__c='APJ',Pricing_Final_Meet_Comp_Price_Staging__c = 20,Pricing_Application_Staging_Nm__c = 'Enterprise',Pricing_List_Price_Staging__c = 10,Pricing_Median_Meet_Comp_Disty_Staging__c=10);
            compProductsPriceList.add(compProductPrice);
            compProductPrice = new Pricing_Competitor_Product_Price_Staging__c(Pricing_Competitor_Product_Name_Staging__c=compProduct2.Name,Pricing_Region_Staging_Nm__c='APJ',Pricing_Final_Meet_Comp_Price_Staging__c = 250,Pricing_Application_Staging_Nm__c = 'Enterprise',Pricing_List_Price_Staging__c = 10,Pricing_Median_Meet_Comp_Disty_Staging__c=10);
            compProductsPriceList.add(compProductPrice);    
            
            insert compProductsPriceList;
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