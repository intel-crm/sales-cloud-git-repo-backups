@IsTest
public class UCD_ACM_AccountDomainTest {
    private static UCD_ACM_DomainContracts.IAccountDomain accountDomianInstance = UCD_ACM_AccountDomain.getInstance();
    
    @TestSetup
    private static void setCommonData(){
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestDuplicateAccount','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.Core_Data_Country_Nm__c = 'India';
        acc.Core_Data_Simplified_Account_Nm__c = 'TestDuplicateAccount';
        insert acc;

        // Create Parent Account With Business Party Id
        List<Account> accountToInsertForBpId = new List<Account>();
        Account intParentAccountWithBpId1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId1','Intel Account','UNFD_INTRMD_CUST');
        intParentAccountWithBpId1.Core_Business_Party_Id__c = '11';
        insert intParentAccountWithBpId1;
        
         Account intParentAccountWithBpId2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId2','End Customer Deal Account','UNFD_INTRMD_CUST');
        intParentAccountWithBpId2.Core_Business_Party_Id__c = '11';
        insert intParentAccountWithBpId2;
        
        Account ECDParentAccountWithBpId1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId3','End Customer Deal Account','UNFD_INTRMD_CUST');
        ECDParentAccountWithBpId1.Core_Business_Party_Id__c = '11';
        insert ECDParentAccountWithBpId1;
        
        
        Account ecdParentAccountWithBpId2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId4','End Customer Deal Account','UNFD_INTRMD_CUST');
        ecdParentAccountWithBpId2.Core_Business_Party_Id__c = '12';
        ecdParentAccountWithBpId2.ParentId = acc.Id;
        insert ecdParentAccountWithBpId2;

         //Create Country Account With Business Party Id
        Account intChildAccWithBpId1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntelChildAccount','Intel Account','UNFD_CTRY_CUST');
        intChildAccWithBpId1.Core_Business_Party_Id__c = '13';
        insert intChildAccWithBpId1;

        Account intChildAccWithBpId2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntelChildAccount1','Intel Account','UNFD_CTRY_CUST');
        intChildAccWithBpId2.Core_Business_Party_Id__c = '15';
        insert intChildAccWithBpId2;
         
        Account ecdChildAccWithBpId2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestECDChildAccount','End Customer Deal Account','UNFD_CTRY_CUST');
        ecdChildAccWithBpId2.Core_Business_Party_Id__c = '14';
        ecdChildAccWithBpId2.ParentId = ecdParentAccountWithBpId2.Id;
        insert ecdChildAccWithBpId2;

        // Create End Customer Deal Account
        Account acc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount','End Customer Deal Account','UNFD_GLBL_CUST');
        acc1.parentId = acc.Id;
        acc1.Core_Survivor_Account_Id__c = ecdChildAccWithBpId2.Id;
        insert acc1;

        // Create Business Type
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV'));
        insert businessTypes;
        
        // Create Account Business Type
        List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
        For(Business_Types__c businessType : businessTypes){
            accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc1.Id,businessType.Id));
        }
        insert accountBusinessTypes;
        
        // Create Compliance Watch List
        List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = new List<Core_Account_Compliance_Watch_List__c>();
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc1.Id,'NOTRDOUT'));
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc1.Id,'DPL'));
        insert complianceWatchLists;
    }
    
	@isTest
    private static void whenValidateCustomerAggregationType(){
        List<UCD_ACM_Models.AccountModel> accountModel = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
    	accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUS','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount1','','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
        test.startTest();
        accountDomianInstance.ValidateCustomerAggregationType(accountModel,invalidResponse);
        system.assertEquals('CustomerAggregationTypeCode is not valid', invalidResponse[0].ErrorMessage);
        test.stopTest();
        
    }
    
    @isTest
    private static void whenValidateAccountRequestReference(){
        List<UCD_ACM_Models.AccountModel> accountModel = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        UCD_ACM_Models.AccountModel modelData = UCD_ACM_AccountTestData.getAccountModel('TestAccount','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND');
        modelData.AccountRequestReferences = UCD_ACM_AccountTestData.getAccountRequestReference('Test','Test');
        accountModel.add(modelData); 
        
        UCD_ACM_Models.AccountModel modelData2 = UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUS','DIR_PRC_EXCPT','Test','Test@test.com','India','IND');
    	modelData2.AccountRequestReferences = UCD_ACM_AccountTestData.getAccountRequestReference('MyDeals','Test2');
        accountModel.add(modelData2);
        test.startTest();
        accountDomianInstance.ValidateAccountRequestReference(accountModel,invalidResponse);
        test.stopTest();
        
    }
    
    @isTest
    private static void whenValidateCustomerProcessEngagement(){
        List<UCD_ACM_Models.AccountModel> accountModel = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
    	accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUST','DIR_PRC','Test','Test@test.com','India','IND'));
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUST','','Test','Test@test.com','India','IND'));
        test.startTest();
        accountDomianInstance.ValidateCustomerProcessEngagement(accountModel,invalidResponse);
        test.stopTest();
        
    }
    /*
    @isTest
    private static void whenMapAccountResponseModel(){
        Map<Id,Account> parentAccountById = new Map<Id,Account>();
        //List<Account> childAccounts = new List<Account>();
        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,
                                             Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,
                                             Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId from Account where Name = 'TestDuplicateAccount' limit 1];
        //System.debug('parentAccount--> '+parentAccount);
        parentAccountById.put(parentAccount.Id,parentAccount);

        Account childAccount  = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,
                                             Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,
                                             Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId from Account where Name = 'TestChildAccount' limit 1];
        
        //System.debug('childAccount--> '+childAccount);

        List<Account_Business_Types__c> accountBusinessTypes = [Select Id,Account__c,Business_Types__c,Effective_Start_Date__c from Account_Business_Types__c where Account__c =: childAccount.Id];
    	
        List<Business_Types__c> businessTypes = [Select Id,Name,Business_Type_Code__c from Business_Types__c where Business_Type_Code__c =:accountBusinessTypes[0].Business_Types__c];
       
        List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = [Select Id,Core_Account_Id__c,Core_Type__c,Core_Effective_Start_Date__c from Core_Account_Compliance_Watch_List__c where Core_Account_Id__c =:childAccount.Id];
        
        test.startTest();
        //UCD_ACM_Models.AccountResponseModel model = UCD_ACM_AccountDomain.mapAccountResponseModel(childAccount,parentAccountById,new Map<Id,List<Business_Types__c>>{childAccount.Id => businessTypes},new Map<Id,List<Core_Account_Compliance_Watch_List__c>>{childAccount.Id => complianceWatchLists});
        //UCD_ACM_Models.AccountResponseModel model = UCD_ACM_AccountDomain.mapAccountResponseModel(childAccounts,parentAccountById,Null,Null);
        test.stopTest();
    }*/
    
    @isTest
    private static void whenValidateDuplicateAccountRequests(){
        List<UCD_ACM_Models.AccountModel> accountModel = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        List<Account> accounts = [Select Id,Name,ParentId,Core_Data_Simplified_Account_Nm__c,ShippingCountryCode,Core_Customer_Aggregation_Type__c,Core_Data_Country_Nm__c from Account where Name = 'TestDuplicateAccount'];
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount','UNFD_GLBL_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
    	accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestDuplicateAccount','UNFD_GLBL_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IN'));
        test.startTest();
        accountDomianInstance.validateDuplicateAccountRequests(accountModel,accounts,invalidResponse);
        system.assert(invalidResponse.size() > 0);
        test.stopTest();
    }
    
    /*
    @isTest
    private static void whenRestrictUpdatingSFFields(){
        Account oldAccount = [Select Id,Name,OwnerId,BillingCity,BillingCountry,BillingCountryCode,BillingGeocodeAccuracy,BillingLatitude,
                              BillingLongitude,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,ShippingCity,ShippingCountry,
                              ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,
                              ShippingStateCode,Core_Account_Reference_Source_Name__c,ShippingStreet,Core_Customer_Aggregation_Type__c,RecordTypeId from Account where Name = 'TestDuplicateAccount' limit 1];
        Account newAccount = new Account();
        newAccount.Id = oldAccount.Id;
        newAccount.Name = 'Updated Account';
        newAccount.Core_Customer_Aggregation_Type__c = oldAccount.Core_Customer_Aggregation_Type__c;
        newAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
        test.startTest();
        accountDomianInstance.restrictUpdatingSFFields(new List<Account>{newAccount},new List<Account>{oldAccount});
        test.stopTest();
    } */

    @isTest
    private static void whenParentUpdate(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> ecdParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '12' LIMIT 1];
        List<Account> intelParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];
        List<Account> ecdChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '14' LIMIT 1];
        List<Account> intelChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '13' LIMIT 1];
        test.startTest();
        intelChild[0].ParentId = ecdParents[0].Id;
        accountDomianInstance.setParentOnUpdateOrMergeInMDM(unitwork,intelChild,new List<Account>(),new Map<Id,Account>(ecdParents),new Map<String,List<Account>>{ecdParents[0].Core_Business_Party_Id__c=>ecdParents},new Map<String,List<Account>>{intelChild[0].Core_Business_Party_Id__c=>intelChild});
        test.stopTest();
    }

    @isTest
    private static void whenBpIdUpdate(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> ecdParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '12' LIMIT 1];
        List<Account> intelParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];
        List<Account> ecdChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '14' LIMIT 1];
        List<Account> intelChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '13' LIMIT 1];
        List<Account> accountWithSameBpId = new List<Account>();
        accountWithSameBpId.addAll(intelChild);
        accountWithSameBpId.addAll(ecdChild);
        test.startTest();
        intelChild[0].Core_Business_Party_Id__c = '14';
        accountDomianInstance.setParentOnUpdateOrMergeInMDM(unitwork,new List<Account>(),intelChild,new Map<Id,Account>(),new Map<String,List<Account>>(),new Map<String,List<Account>>{intelChild[0].Core_Business_Party_Id__c=>accountWithSameBpId});
        test.stopTest();
    }

    @isTest
    private static void whenParentMerge(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> ecdParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '12' LIMIT 1];
        List<Account> intelParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];
        List<Account> ecdChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '14' LIMIT 1];
        List<Account> intelChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '13' LIMIT 1];
        intelParents[0].Core_Business_Party_Id__c = '12';
        update intelParents;

        List<Account> accountWithSameBpId = new List<Account>();
        accountWithSameBpId.addAll(intelChild);
        accountWithSameBpId.addAll(ecdChild);
        test.startTest();
        intelChild[0].Core_Business_Party_Id__c = '14';
        accountDomianInstance.setParentOnUpdateOrMergeInMDM(unitwork,new List<Account>(),intelChild,new Map<Id,Account>(),new Map<String,List<Account>>(),new Map<String,List<Account>>{intelChild[0].Core_Business_Party_Id__c=>accountWithSameBpId});
        test.stopTest();

    }

    @isTest
    private static void whenChildMerge(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> ecdParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '12' LIMIT 1];
        List<Account> intelParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];
        List<Account> ecdChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '14' LIMIT 1];
        List<Account> intelChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '13' LIMIT 1];
        intelChild[0].Core_Business_Party_Id__c = '14';
        update intelChild;
        
        List<Account> accountWithSameBpId = new List<Account>();
        accountWithSameBpId.addAll(intelParents);
        accountWithSameBpId.addAll(ecdParents);
        test.startTest();
        intelParents[0].Core_Business_Party_Id__c = '12';
        accountDomianInstance.setParentOnUpdateOrMergeInMDM(unitwork,new List<Account>(),intelParents,new Map<Id,Account>(),new Map<String,List<Account>>(),new Map<String,List<Account>>{intelParents[0].Core_Business_Party_Id__c=>accountWithSameBpId});
        test.stopTest();

    }

    /*
    @isTest
    private static void updateRecordtypewithBPid(){
        List<Account> ecdParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById,Core_Account_Reference_Source_Name__c from Account Where Core_Business_Party_Id__c = '12' LIMIT 1];
        List<Account> ecdChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '14' LIMIT 1];

        List<Account> intelParents1 = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById,Core_Account_Reference_Source_Name__c from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];
        List<Account> intelParents2 = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById,Core_Account_Reference_Source_Name__c from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];

        intelParents1[0].ParentId = ecdParents[0].Id;
        intelParents2[0].ParentId = ecdChild[0].Id;
        Map<Id, Account> oldAccount = new Map<Id, Account>(intelParents2);
        //accountDomianInstance.updateRecordtype(intelParents1,oldAccount);
       // accountDomianInstance.updateParentAccountRecordtype(new UCD_ACM_UnitOfWork(), intelParents1,oldAccount);
               

    }*/
     @isTest
    private static void updateRecordtypewithNullBpId(){
        List<Account> ecdParents = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById,Core_Account_Reference_Source_Name__c from Account Where Core_Business_Party_Id__c = '12' LIMIT 1];
        List<Account> ecdChild = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById from Account Where Core_Business_Party_Id__c = '14' LIMIT 1];

        List<Account> intelParents1 = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById,Core_Account_Reference_Source_Name__c from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];
        List<Account> intelParents2 = [Select Id,Name,RecordtypeId,ParentId,Core_Business_Party_Id__c,LastModifiedById,Core_Account_Reference_Source_Name__c from Account Where Core_Business_Party_Id__c = '11' LIMIT 1];

        intelParents1[0].ParentId = ecdParents[0].Id;
        intelParents2[0].ParentId = ecdChild[0].Id;
        intelParents2[0].Core_Business_Party_Id__c = null;
        intelParents2[0].RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Map<Id, Account> oldAccount = new Map<Id, Account>(intelParents2);
       // accountDomianInstance.updateRecordtype(intelParents1,oldAccount);
      

    }
}