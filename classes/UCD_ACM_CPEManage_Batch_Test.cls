@isTest 
public class UCD_ACM_CPEManage_Batch_Test {
    
    @TestSetup
    static void createSetupData(){
        Account acc = TestUtilities.getAccountRecord();
        acc.Core_Sales_Groups__c = 'Global Solutions & Services Sales Group';
        acc.Industry ='Software and Services';
        acc.Core_Sub_Industry__c	='IT Services';
        acc.Core_Business_Party_Id__c = '1232243';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        insert acc;

        Business_Types__c businessType1 = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Sales CRM','SLS_CRM');
        insert businessType1;
        Business_Types__c businessType2 = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Partner','PTNR');
        insert businessType2;
        Business_Types__c businessTypeCoMarketing = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Co-Marketing','CO_MKT');
        insert businessTypeCoMarketing;
        Business_Types__c businessTypeDirectPrice = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price','DIR_PRC_EXCPT');
        insert businessTypeDirectPrice;

        

    }

    @isTest
    static void testInsertCPE(){
        Account acc = [SELECT Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c FROM Account LIMIT 1];
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_MDF_CoMarketingActive__c = true;
        update acc;

        Test.startTest();
        UCD_ACM_CPEManage_Batch cpe = new UCD_ACM_CPEManage_Batch();
        Id batchJobId = Database.ExecuteBatch(cpe);
        System.assertNotEquals(batchJobId,null);
        Test.stopTest();
    }
    @isTest
    static void testInsertCPE1(){
        Account acc = [SELECT Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c FROM Account LIMIT 1];
        List<Business_Types__c> businessTypes = [
            Select Id,Business_Type_Code__c, Name 
            from Business_Types__c 
            where Is_Active__c = true AND Business_Type_Code__c = 'PTNR'
        ];
        Core_ACM_Account_Staging__c accStag = new Core_ACM_Account_Staging__c();
        accStag.AccountId__c = acc.Id;
        accStag.Account_Action_Refrence__c = 'CO_MKT';
        accStag.Core_Action__c = 'ADD_CPE';
        accStag.Core_Status__c = 'NEW';
        insert accStag;
        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
        accountBusinessType.Account__c=acc.Id;
        accountBusinessType.Business_Types__c = businessTypes[0].Id;
        accountBusinessType.Effective_Start_Date__c = System.today();
        accountBusinessType.Account_Staging_Id__c = accStag.Id;
        insert accountBusinessType;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_MDF_CoMarketingActive__c = true;
        update acc;

        Test.startTest();
        UCD_ACM_CPEManage_Batch cpe = new UCD_ACM_CPEManage_Batch();
        Id batchJobId = Database.ExecuteBatch(cpe);
        System.assertNotEquals(batchJobId,null);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCPE(){
        Account acc = [SELECT Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c FROM Account LIMIT 1];
        List<Business_Types__c> businessTypes = [
            Select Id,Business_Type_Code__c, Name 
            from Business_Types__c 
            where Is_Active__c = true AND Business_Type_Code__c = 'PTNR'
        ];
        Core_ACM_Account_Staging__c accStag = new Core_ACM_Account_Staging__c();
        accStag.AccountId__c = acc.Id;
        accStag.Account_Action_Refrence__c = 'CO_MKT';
        accStag.Core_Action__c = 'ADD_CPE';
        accStag.Core_Status__c = 'NEW';
        insert accStag;
        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
        accountBusinessType.Account__c=acc.Id;
        accountBusinessType.Business_Types__c = businessTypes[0].Id;
        accountBusinessType.Effective_Start_Date__c = System.today();
        accountBusinessType.Account_Staging_Id__c = accStag.Id;
        insert accountBusinessType;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_MDF_CoMarketingActive__c = true;
        update acc;

        Test.startTest();
        UCD_ACM_CPEManage_Batch cpe = new UCD_ACM_CPEManage_Batch();
        Id batchJobId = Database.ExecuteBatch(cpe);
        System.assertNotEquals(batchJobId,null);
        Test.stopTest();
    }

    @isTest
    static void testDeleteCPE(){
        Test.startTest();
        Account acc = [SELECT Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c FROM Account LIMIT 1];
        List<Business_Types__c> businessTypes = [
            Select Id,Business_Type_Code__c, Name 
            from Business_Types__c 
            where Is_Active__c = true AND Business_Type_Code__c = 'PTNR'
        ];
        Core_ACM_Account_Staging__c accStag = new Core_ACM_Account_Staging__c();
        accStag.AccountId__c = acc.Id;
        accStag.Account_Action_Refrence__c = 'PTNR';
        accStag.Core_Action__c = 'REMOVE_CPE';
        accStag.Core_Status__c = 'NEW';
        insert accStag;
        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
        accountBusinessType.Account__c=acc.Id;
        accountBusinessType.Business_Types__c = businessTypes[0].Id;
        accountBusinessType.Effective_Start_Date__c = System.today();
        accountBusinessType.Account_Staging_Id__c = accStag.Id;
        insert accountBusinessType;

        //UCD_ACM_CPEManage_Batch ucd = new UCD_ACM_CPEManage_Batch();
        //Database.ExecuteBatch(ucd);

        
        UCD_ACM_CPEManage_Batch cpe = new UCD_ACM_CPEManage_Batch();
        Id batchJobId = Database.ExecuteBatch(cpe);
        System.assertNotEquals(batchJobId,null);
        Test.stopTest();
    }
    
    @isTest
    static void testRetry(){
        Test.startTest();
        Account acc = [SELECT Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c FROM Account LIMIT 1];
        List<Business_Types__c> businessTypes = [
            Select Id,Business_Type_Code__c, Name 
            from Business_Types__c 
            where Is_Active__c = true AND Business_Type_Code__c = 'PTNR'
        ];
        Core_ACM_Account_Staging__c accStag = new Core_ACM_Account_Staging__c();
        //accStag.AccountId__c = acc.Id;
        accStag.Account_Action_Refrence__c = 'PTNR';
        accStag.Core_Action__c = 'ADD_CPE';
        accStag.Core_Status__c = 'NEW';
        insert accStag;
        Account_Business_Types__c accountBusinessType=new Account_Business_Types__c();
        accountBusinessType.Account__c=acc.Id;
        accountBusinessType.Business_Types__c = businessTypes[0].Id;
        accountBusinessType.Effective_Start_Date__c = System.today();
        accountBusinessType.Account_Staging_Id__c = accStag.Id;
        insert accountBusinessType;

        //UCD_ACM_CPEManage_Batch ucd = new UCD_ACM_CPEManage_Batch();
        //Database.ExecuteBatch(ucd);

        
        UCD_ACM_CPEManage_Batch cpe = new UCD_ACM_CPEManage_Batch();
        Id batchJobId = Database.ExecuteBatch(cpe);
        System.assertNotEquals(batchJobId,null);
        Test.stopTest();
    }
}