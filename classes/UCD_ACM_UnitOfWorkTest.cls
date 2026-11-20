@IsTest
public class UCD_ACM_UnitOfWorkTest {
	@IsTest
    private static void whenRegisterNew(){ 
        Account acc = new Account();
        acc.Name = 'UnityOfWorkTest';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Core_Intel_Requester_Email__c = 'Test@test.com';
        acc.Core_Intel_Requester_Name__c = 'TestUser';
        acc.Core_Intel_Requester_WWID__c = 'Test234';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        acc.OwnerId = System.Label.Core_Uncovered_Account_ID;
        acc.ShippingCountryCode	= 'IND';
        acc.BillingCountryCode	= 'IND';
        
        Account acc1 = new Account();
        acc1.Name = 'UnityOfWorkTest1';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc1.Core_Intel_Requester_Email__c = 'Test@test.com';
        acc1.Core_Intel_Requester_Name__c = 'TestUser';
        acc1.Core_Intel_Requester_WWID__c = 'Test234';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        acc1.OwnerId = System.Label.Core_Uncovered_Account_ID;
        acc1.ShippingCountryCode	= 'IND';
        acc1.BillingCountryCode	= 'IND';
        
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT'));
        insert businessTypes;
        
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Business_Types__c = businessTypes[0].Id;
        accountBusinessType.Effective_Start_Date__c = system.today()-5;
        
        Schema.sObjectField schemaFields = Account_Business_Types__c.Account__c.getDescribe().getSObjectField();
        
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        
        test.startTest();
        unitwork.registerNew(acc);
        unitwork.registerNew(new List<sObject>{acc1});
        unitwork.registerNew(accountBusinessType,schemaFields,acc);
        boolean isCommit = unitwork.commitWork(); 
        system.assertEquals(true, isCommit);
        test.stopTest();
        
    }
    
    @IsTest
    private static void whenRegisterNewFalse(){
        Account acc = new Account();
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Core_Intel_Requester_Email__c = 'Test@test.com';
        acc.Core_Intel_Requester_Name__c = 'TestUser';
        acc.Core_Intel_Requester_WWID__c = 'Test234';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        acc.OwnerId = System.Label.Core_Uncovered_Account_ID;
        acc.ShippingCountryCode	= 'IND';
        acc.BillingCountryCode	= 'IND';
        
        Account acc1 = new Account();
        acc1.Name = 'UnityOfWorkTest1';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc1.Core_Intel_Requester_Email__c = 'Test@test.com';
        acc1.Core_Intel_Requester_Name__c = 'TestUser';
        acc1.Core_Intel_Requester_WWID__c = 'Test234';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        acc1.OwnerId = System.Label.Core_Uncovered_Account_ID;
        acc1.ShippingCountryCode	= 'IND';
        acc1.BillingCountryCode	= 'IND';
        
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT'));
        insert businessTypes;
        
        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Business_Types__c = businessTypes[0].Id;
        accountBusinessType.Effective_Start_Date__c = system.today()-5;
        
        Schema.sObjectField schemaFields = Account_Business_Types__c.Account__c.getDescribe().getSObjectField();
        
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        
        test.startTest();
        unitwork.registerNew(acc);
        unitwork.registerNew(new List<sObject>{acc});
        unitwork.registerNew(accountBusinessType,schemaFields,acc1);
        boolean isCommit = unitwork.commitWork(); 
        system.assertEquals(false, isCommit);
        test.stopTest();
        
    }

    @IsTest
    private static void whenRegisterNewUpdate(){ 
        Account acc = new Account();
        acc.Name = 'UnityOfWorkTest';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Core_Intel_Requester_Email__c = 'Test@test.com';
        acc.Core_Intel_Requester_Name__c = 'TestUser';
        acc.Core_Intel_Requester_WWID__c = 'Test234';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        acc.OwnerId = System.Label.Core_Uncovered_Account_ID;
        acc.ShippingCountryCode	= 'IND';
        acc.BillingCountryCode	= 'IND';
        insert acc ;

        Account acc1 = new Account();
		acc1.Id = acc.id;
		acc1.Core_Intel_Requester_Email__c = 'Test1@test.com';

        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        test.startTest();
		unitwork.registerModified(acc1);
		        
		List<Schema.sObjectField> lstOfSchema = new List<Schema.sObjectField>();		
		Schema.sObjectField schemaFields1 = Account.Core_Intel_Requester_Email__c.getDescribe().getSObjectField();
		lstOfSchema.add(schemaFields1);
		
		Schema.sObjectField schemaFields2 = Account.Core_Intel_Requester_Name__c.getDescribe().getSObjectField();
		lstOfSchema.add(schemaFields2);

		unitwork.registerModified(acc1,lstOfSchema);
		boolean isCommit = unitwork.commitWork();
        system.assertEquals(true, isCommit);

        test.stopTest();
        
    }
    
    @IsTest
    private static void whenRegisterNewDelete(){ 
        Account acc = new Account();
        acc.Name = 'UnityOfWorkTest';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Core_Intel_Requester_Email__c = 'Test@test.com';
        acc.Core_Intel_Requester_Name__c = 'TestUser';
        acc.Core_Intel_Requester_WWID__c = 'Test234';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
        acc.OwnerId = System.Label.Core_Uncovered_Account_ID;
        acc.ShippingCountryCode	= 'IND';
        acc.BillingCountryCode	= 'IND';
        insert acc ;

        Account acc1 = new Account();
		acc1.Id = acc.id;
		acc1.Core_Intel_Requester_Email__c = 'Test1@test.com';

        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        test.startTest();
		unitwork.registerDeleted(acc1);
		boolean isCommit = unitwork.commitWork();
        system.assertEquals(true, isCommit);

        test.stopTest();
        
    }
}