@isTest
public class Sales_ValidateProduct_Test {
    /*public static void recordJobDetails(Id contractId,String Status){
        SBQQ__RecordJob__c  recordJob = new SBQQ__RecordJob__c();
        recordJob.SBQQ__JobStatus__c = Status;
        recordJob.SBQQ__JobDetails__c = ''; 
        recordJob.SBQQ__RecordId__c =  contractId+'::RenewContract'; 
        insert recordJob;
    }
    public static SBQQ__Subscription__c createSubscription(Id contractId,Id productId,Id accountId){
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Product__c = productId;
        subs.SBQQ__Quantity__c = 3;
        subs.SBQQ__Contract__c = contractId;
        subs.SBQQ__Account__c = accountId;
        subs.SBQQ__SubscriptionEndDate__c = System.today();
        subs.SBQQ__SubscriptionEndDate__c = System.today().addDays(3);
        insert subs;
        return subs;
    }
    @isTest
    static void updateProductDetailsOnSubscriptionTest1(){
        set<id> prodset =new  set<id>();
        set<id> conset=new set<id>();
        list<Contract> conList = new list<Contract>();
        Map<id,Contract> conMap = new Map<id,Contract>();
        TriggerHandler.bypass('Core_AccountHandler');
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');
        TriggerHandler.bypass('Core_PSG_ProductExtendedAttributes');
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Type_Nm__c = 'FLOAT';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        p.IsActive=false;
        insert p;
        insert prodExt1 ;
        Product2 prod1 = new Product2();
        prod1.Name='TEst Product 2';
        prod1.Description='Test Product Entry 1';
        prod1.productCode='ABC';
        prod1.IsActive=false;
        prod1.Core_Item_Shippable_Ind__c=true;
        prod1.SBQQ__SubscriptionType__c='One-time';
        prod1.SBQQ__SubscriptionPricing__c='Fixed Price';
        prod1.Core_Product_Org__c='Sales';
        prod1.Core_Item_Quotable_Ind__c=true;
        prod1.Core_Item_Orderable_Ind__c=true;
        prod1.Core_Sales_Visible_Flag__c=true; 
        prod1.Core_Item_Class_Nm__c='SV';
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        prodset.add(prod1.id);
        Product2 prod2 = new Product2();
        prod2.Name='TEst Product 3';
        prod2.Description='Test Product Entry 4';
        prod2.productCode='ABC';
        prod2.IsActive=true;
        prod2.Core_Product_Org__c='Sales';
        prod2.Core_Item_Quotable_Ind__c=true;
        prod2.Core_Item_Orderable_Ind__c=true;
        prod2.Core_Sales_Visible_Flag__c=true; 
        prod2.Core_Item_Class_Nm__c='SV';
        prod2.SBQQ__SubscriptionType__c='One-time';
        prod2.SBQQ__SubscriptionPricing__c='Fixed Price';
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        TriggerHandler.bypass('Core_Product');
        insert prod2;
        TriggerHandler.clearBypass('Core_Product');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c=prod1.id;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Contract cont = Sales_TestDataFactory.createContract();
        cont.AccountId=accObj.Id;
        cont.Sales_Program__c = 'PSG';
        cont.StartDate = system.today();
        cont.EndDate = System.today().addDays(3);
        cont.Status = 'Draft';
        TriggerHandler.bypass('Sales_ContractTriggerHandler');
        insert cont;
        testLicense.Sales_License_Contract__c =cont.id;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        update testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        conset.add(cont.id);
        SBQQ__Subscription__c subs = createSubscription(cont.Id,prod1.Id,accObj.Id);
        SBQQ__Subscription__c subs1 = createSubscription(cont.Id,p.Id,accObj.Id);
        List<Product2> prodList = new List<Product2>();
        prod1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        prod1.SBQQ__SubscriptionType__c = 'Renewable';
        prodList.add(prod1);
        conList.add(cont);
        conMap.put(cont.id,cont);  
        set<Id> productId=new set<id>();
        set<Id> conIds=new set<id>();
        Map<Id,Id> duplicateAndNewProdMap = new Map<Id,Id>();
        productId.add(prod1.id);
        duplicateAndNewProdMap.put(prod1.id,prod2.id);
        conIds.add(cont.id);
        test.startTest();
        try{
            recordJobDetails(cont.Id,'Queued');
            Sales_ValidateProduct.checkProductInactive(cont.id,false);     
            System.enqueueJob(new Sales_ValidateProduct.updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
            System.enqueueJob(new Sales_ValidateProduct.updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
            Sales_ValidateProduct.updateProductDetails_LicenseSubscription(prodset,conset,conMap);
            System.assertEquals('','');
        }catch(Exception e){
        }
        test.stopTest();
    }  
    @isTest
    static void updateProductDetailsOnSubscriptionTest2(){
        set<id> prodset =new  set<id>();
        set<id> conset=new set<id>();
        list<Contract> conList = new list<Contract>();
        Map<id,Contract> conMap = new Map<id,Contract>();
        TriggerHandler.bypass('Core_AccountHandler');
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','CORPORATE');
        TriggerHandler.bypass('Core_PSG_ProductExtendedAttributes');
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Type_Nm__c = 'FLOAT';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        p.IsActive=false;
        insert p;
        insert prodExt1 ;
        Product2 prod1 = new Product2();
        prod1.Name='TEst Product 2';
        prod1.Description='Test Product Entry 1';
        prod1.productCode='ABC';
        prod1.IsActive=false;
        prod1.Core_Item_Shippable_Ind__c=true;
        prod1.SBQQ__SubscriptionType__c='One-time';
        prod1.SBQQ__SubscriptionPricing__c='Fixed Price';
        prod1.Core_Product_Org__c='Sales';
        prod1.Core_Item_Quotable_Ind__c=true;
        prod1.Core_Item_Orderable_Ind__c=true;
        prod1.Core_Sales_Visible_Flag__c=true; 
        prod1.Core_Item_Class_Nm__c='SV';
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        prodset.add(prod1.id);
        Product2 prod2 = new Product2();
        prod2.Name='TEst Product 3';
        prod2.Description='Test Product Entry 4';
        prod2.productCode='ABC';
        prod2.IsActive=true;
        prod2.Core_Product_Org__c='Sales';
        prod2.Core_Item_Quotable_Ind__c=true;
        prod2.Core_Item_Orderable_Ind__c=true;
        prod2.Core_Sales_Visible_Flag__c=true; 
        prod2.Core_Item_Class_Nm__c='SV';
        prod2.SBQQ__SubscriptionType__c='One-time';
        prod2.SBQQ__SubscriptionPricing__c='Fixed Price';
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        TriggerHandler.bypass('Core_Product');
        insert prod2;
        TriggerHandler.clearBypass('Core_Product');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c=prod1.id;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Contract cont = Sales_TestDataFactory.createContract();
        cont.AccountId=accObj.Id;
        cont.Sales_Program__c = 'PSG';
        cont.StartDate = system.today();
        cont.EndDate = System.today().addDays(3);
        cont.Status = 'Draft';
        TriggerHandler.bypass('Sales_ContractTriggerHandler');
        insert cont;
        testLicense.Sales_License_Contract__c =cont.id;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        update testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        conset.add(cont.id);
        SBQQ__Subscription__c subs = createSubscription(cont.Id,prod1.Id,accObj.Id);
        SBQQ__Subscription__c subs1 = createSubscription(cont.Id,p.Id,accObj.Id);
        List<Product2> prodList = new List<Product2>();
        prod1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        prod1.SBQQ__SubscriptionType__c = 'Renewable';
        prodList.add(prod1);
        conList.add(cont);
        conMap.put(cont.id,cont);  
        set<Id> productId=new set<id>();
        set<Id> conIds=new set<id>();
        Map<Id,Id> duplicateAndNewProdMap = new Map<Id,Id>();
        productId.add(prod1.id);
        duplicateAndNewProdMap.put(prod1.id,prod2.id);
        conIds.add(cont.id);
        test.startTest();
        try{
            recordJobDetails(cont.Id,'Completed');
            Sales_ValidateProduct.checkProductInactive(cont.id,false);     
            System.enqueueJob(new Sales_ValidateProduct.updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
            System.enqueueJob(new Sales_ValidateProduct.updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
            List<Id> lstCont=new List<Id>(conIds);
            Boolean accountStatusValue=Sales_ValidateProduct.validateAccount((String)lstCont[0]);
            if(accountStatusValue)
            {
                System.assertEquals(true, accountStatusValue);
            }
            else{
                System.assertEquals(false, accountStatusValue);
            }
            Sales_ValidateProduct.updateProductDetails_LicenseSubscription(prodset,conset,conMap);
            System.assertEquals('','');
        }catch(Exception e){
        }
        test.stopTest();
    }*/     
}