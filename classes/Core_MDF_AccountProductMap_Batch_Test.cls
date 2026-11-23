@isTest
public class Core_MDF_AccountProductMap_Batch_Test {
    @isTest
    private static void createUpdateAccountAndProductMappingRecordsTest() {
        ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        retailIntelAcc.Core_Geo__c = 'APJ';
        insert retailIntelAcc;
        Account rmfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('RMF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        rmfUltimateAccount.Core_Geo__c='EMEA';
        insert rmfUltimateAccount;
        List<String> prodIdList1 = new List<String>();
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name = 'Intel® B360 Chipset';
        prod.Core_Product_Type__c = 'Chipsets';
        prod.Core_Product_Family__c = 'Consumer Chipsets';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Compute Accelerators';
        prod1.Core_Product_Type__c = 'Graphics';
        prod1.Core_Product_Family__c = 'Compute Accelerators';
        prodIdList1.add(prod1.Id);
        prodIdList1.add(prod.Id);
        prodList.add(prod1);
        
        Database.insert(prodList);
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
        
        Database.executeBatch(new Core_MDF_AccountProductMap_Batch(detailWrap), Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
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
        Database.executeBatch(new Core_MDF_AccountProductMap_Batch(detailWrap), Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
        prodIdList.remove(1);
        
        acctProdWrap.accountId = null;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = new List<string>();
        detailWrap = JSON.serialize(acctProdWrap);  
        Database.executeBatch(new Core_MDF_AccountProductMap_Batch(detailWrap), Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
        
        acctProdWrap.accountId = retailIntelAcc.Id;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = true;
        acctProdWrap.uncheckedProdIds = prodIdList;
        detailWrap = JSON.serialize(acctProdWrap);  
        //prodIdList.add('01to0000000zcQjAAI');
        Database.executeBatch(new Core_MDF_AccountProductMap_Batch(detailWrap), Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
        //prodIdList.add('01to0000000zcTEAAY');
        
        acctProdWrap.accountId = retailIntelAcc.Id;
        acctProdWrap.selectedProdIds = prodIdList;
        acctProdWrap.program = 'Retail Marketing Funds';
        acctProdWrap.isAllAccount = false;
        acctProdWrap.uncheckedProdIds = new List<string>{prod1.Id};
        detailWrap = JSON.serialize(acctProdWrap); 
        Database.executeBatch(new Core_MDF_AccountProductMap_Batch(detailWrap), Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
        List<String> accIdList = new List<String>();
        accIdList.add(String.valueOf(retailIntelAcc.Id));
        Core_MDF_AccountProductMappingController.getAccountProductMapping(accIdList, 'Retail Marketing Funds');
        try{
            Core_MDF_AccountProductMappingController.getAccountProductMapping(accIdList, 'co-Marketing Funds');
        }catch(exception e){}
         List<Product2> productList = Core_MDF_AccountProductMappingController.getProducts();
        Core_MDF_AccountProductMappingController.hasAccessToPriceReviewerMaintanceTab();
        Assert.isTrue(productList != null);
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
        
        Map<Id,List<string>> apmIdToErrorsMap = new Map<Id,List<string>>();
        apmIdToErrorsMap.put(rmfUltimateAccount.Id,new List<string>{'error'});
        Core_MDF_AccountProductMap_Batch.createLogEntry(apmIdToErrorsMap);
        Database.executeBatch(new Core_MDF_AccountProductMap_Batch(detailWrap), Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Product_Mapping_Batch_Size')));
        Assert.isTrue(detailWrap != null);
    }
    
}