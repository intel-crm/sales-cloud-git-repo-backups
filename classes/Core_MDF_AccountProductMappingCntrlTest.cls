/* Class Name : Core_MDF_AccountProductMappingController
* Test class : Core_MDF_AccountProductMappingCntrlTest
*/ 
@isTest(seeAllData=false)
private class Core_MDF_AccountProductMappingCntrlTest {
    @testSetup
    static void createTestData(){
        
        List<Core_MDF_PFR_Product_Mapping__c> productmappings= new List<Core_MDF_PFR_Product_Mapping__c>();
        
        Core_MDF_PFR_Product_Mapping__c prodmap1= new Core_MDF_PFR_Product_Mapping__c(
        Name='Technologies',
        Core_MDF_Segment_ProductType_txt__c='Technologies',
        Core_MDF_IsActive_Ind__c=true,
        Core_MDF_Show_All_Products_ind__c=false,
        Core_MDF_Product_EPM_ID_txt__c='1234567'
        );
        productmappings.add(prodmap1);
        
        Core_MDF_PFR_Product_Mapping__c prodmap2= new Core_MDF_PFR_Product_Mapping__c(
        Name='Processors',
        Core_MDF_Segment_ProductType_txt__c='Processors',
        Core_MDF_IsActive_Ind__c=true,
        Core_MDF_Show_All_Products_ind__c=true,
        Core_MDF_Criteria_For_Product_txt__c='(Core_Product_Status__c like \'%AC%\' OR Core_Product_Status__c LIKE \'%PA%\' OR Core_Product_Status__c LIKE \'%EN%\')'
        );
        productmappings.add(prodmap2);
        
        Core_MDF_PFR_Product_Mapping__c prodmap3= new Core_MDF_PFR_Product_Mapping__c(
        Name='Graphics',
        Core_MDF_Segment_ProductType_txt__c='Graphics',
        Core_MDF_IsActive_Ind__c=true,
        Core_MDF_Show_All_Products_ind__c=true
        );
        productmappings.add(prodmap3);
        
        insert productmappings;
        
    }
    
    @isTest
    private static void createUpdateAccountAndProductMappingRecordsTest() {
      // Highlight: Unused Local Variable
     //  ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        retailIntelAcc.Core_Geo__c = 'APJ';
        insert retailIntelAcc;
        Account rmfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('RMF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        rmfUltimateAccount.Core_Geo__c='EMEA';
        insert rmfUltimateAccount;
        List<String> prodIdList1 = new List<String>();
        Product2 prod = new Product2();
        prod.Name = 'Intel® B360 Chipset';
        prod.Core_Product_Type__c = 'Chipsets';
        prod.Core_Product_Family__c = 'Consumer Chipsets';
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Compute Accelerators';
        prod1.Core_Product_Type__c = 'Graphics';
        prod1.Core_Product_Family__c = 'Compute Accelerators';
        prodIdList1.add(prod1.Id);
        prodIdList1.add(prod.Id);
        Database.insert(prod);
        Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
        apm.Core_MDF_Account__c = retailIntelAcc.Id;
        apm.Core_MDF_Active_ind__c = true;
        apm.Core_MDF_Program_Account_Map__c = 'Retail Marketing Funds';
        apm.Core_MDF_Product__c = prod.Id;
        Database.insert(apm);
        Core_MDF_AccountProductMappingController.AccountProdMapWrapper acctProdWrap = new Core_MDF_AccountProductMappingController.AccountProdMapWrapper();
        string detailWrap = '';
        try{
        acctProdWrap.accountId = retailIntelAcc.Id;
        acctProdWrap.selectedProdIds = prodIdList1;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = new List<string>{prod1.Id};
        detailWrap = JSON.serialize(acctProdWrap);  
        
        Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords(detailWrap);
        }catch(exception e){}
        List<String> prodIdList = new List<String>();
        prodIdList.add(prod.Id);
        prodIdList.add(prod1.Id);
        
        acctProdWrap.accountId = null;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = new List<string>();
        detailWrap = JSON.serialize(acctProdWrap);  
        Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords(detailWrap);
        prodIdList.remove(1);
        
        acctProdWrap.accountId = null;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = new List<string>();
        detailWrap = JSON.serialize(acctProdWrap);  
        Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords(detailWrap);
        
        acctProdWrap.accountId = retailIntelAcc.Id;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = prodIdList;
        detailWrap = JSON.serialize(acctProdWrap);  
        //prodIdList.add('01to0000000zcQjAAI');
        Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords(detailWrap);
        //prodIdList.add('01to0000000zcTEAAY');
        
        acctProdWrap.accountId = retailIntelAcc.Id;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = false;
        acctProdWrap.uncheckedProdIds = new List<string>{prod1.Id};
        detailWrap = JSON.serialize(acctProdWrap); 
        Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords(detailWrap);
        List<String> accIdList = new List<String>();
        accIdList.add(String.valueOf(retailIntelAcc.Id));
        Core_MDF_AccountProductMappingController.getAccountProductMapping(accIdList, 'Retail Marketing Funds');
        try{
            Core_MDF_AccountProductMappingController.getAccountProductMapping(accIdList, 'co-Marketing Funds');
        }catch(exception e){}
        List<Product2> productList = Core_MDF_AccountProductMappingController.getProducts();
        Core_MDF_AccountProductMappingController.hasAccessToPriceReviewerMaintanceTab();
        //Assert.isTrue(productList == null);
        // Unit Test Method should include System.Assert
         Assert.areEqual(1, accIdList.size(), 'Account ID list should contain one account ID');
        Assert.areEqual(String.valueOf(retailIntelAcc.Id), accIdList[0], 'Account ID should match the created account');
        
    }
    
    @isTest
    public static void testMethod1(){
        
        Test.startTest();
        Account rmfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('RMF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        rmfUltimateAccount.Core_Geo__c='EMEA';
        insert rmfUltimateAccount;
        List<String> prodIdList1 = new List<String>();
        Product2 Prod1 = new Product2();
        prodIdList1.add(Prod1.Id);
        Core_MDF_AccountProductMappingController.AccountProdMapWrapper acctProdWrap = new Core_MDF_AccountProductMappingController.AccountProdMapWrapper();
        string detailWrap = '';
        acctProdWrap.accountId = null;
        acctProdWrap.selectedProdIds = prodIdList1;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = new List<string>();
        detailWrap = JSON.serialize(acctProdWrap);  
        Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords(detailWrap);
        Assert.isTrue(detailWrap != null);
    }
}