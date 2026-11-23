@IsTest
public class UCD_ACM_AccountQuerySelectorTest {
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
	@TestSetup
    private static void setCommonData(){
       Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id;
        User us = UCD_ACM_Cntrlr_TestDataInitialization.createUser(ProfileId);
        insert us;
        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;

        // Create End Customer Deal Account Intermediate1 child
        Account intChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount1','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc1.parentId = parentAccount.Id;
        insert intChildAcc1;
        
        // Create End Customer Deal Account Intermediate2 child
        Account intChildAcc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount2','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc2.parentId = intChildAcc1.Id;
        insert intChildAcc2;
        
        // Create End Customer Deal Account Country child
        Account ctryChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestCtryChildAccount','End Customer Deal Account','UNFD_CTRY_CUST');
        ctryChildAcc.parentId = intChildAcc2.Id;
        insert ctryChildAcc;
        
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        acc.Core_Business_Party_Id__c = '12345';
        insert acc;
        
        // Create Requested Account
        Account reuestedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount1','Requested Account','UNFD_GLBL_CUST');
        insert reuestedAccount;
        
        // Create Business Type
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV'));
        insert businessTypes;
        
        // Create Account Business Type
        List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
        For(Business_Types__c businessType : businessTypes){
            accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessType.Id));
        }
        insert accountBusinessTypes;
        
        // Create Compliance Watch List
        List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = new List<Core_Account_Compliance_Watch_List__c>();
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'NOTRDOUT'));
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'DPL'));
        insert complianceWatchLists;
    }
    
    @isTest
    private static void whenGetAccounts(){
        Account acc = [Select Id,Name,ParentId,Parent.Name,Core_Customer_Aggregation_Type__c from Account where Name = 'TestChildAccount'];
        Test.startTest();
        Map<Id,Account> accountsByIds = accountQuerySelectorInstance.getAccountsByIds(new Set<Id>{acc.ParentId},'Id,Name');
        system.assertEquals(acc.Parent.Name, AccountsByIds.get(acc.ParentId).Name);
        Map<Id,Account> accountsByIds1 = accountQuerySelectorInstance.getAccountsByIds(new Set<Id>{acc.Id},'Id,Name,Core_Customer_Aggregation_Type__c','Core_Customer_Aggregation_Type__c != null');
        system.assertEquals(acc.Name, accountsByIds1.get(acc.Id).Name);
        List<Account> accounts = accountQuerySelectorInstance.selectAccountsByName(new Set<String>{'TestChildAccount'},'Id,Name');
        system.assertEquals('TestChildAccount', accounts[0].Name);
        Map<Id,Account> accountsByIds2 = accountQuerySelectorInstance.getAccountsByParentId(new Set<Id>{acc.ParentId},'Id,Name','Core_Customer_Aggregation_Type__c != null');
        system.assertEquals('TestChildAccount', accountsByIds2.get(acc.Id).Name);
        Map<Id,Account> accountsByIds3 = accountQuerySelectorInstance.getAccountsByParentId(new Set<Id>{acc.ParentId},'Id,Name');
        Test.stopTest();
    }
    
    @isTest
    private static void whenGetAccountsWithFalse(){
        Account acc = [Select Id,Name,ParentId,Parent.Name,Core_Customer_Aggregation_Type__c from Account where Name = 'TestChildAccount'];
        Test.startTest();
        try{
            Map<Id,Account> accountsByIds = accountQuerySelectorInstance.getAccountsByIds(new Set<Id>{''},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: ', e.getMessage());
        }
        
        try{
            Map<Id,Account> accountsByIds = accountQuerySelectorInstance.getAccountsByIds(new Set<Id>{'43234234'},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: 43234234', e.getMessage());
        }
        
        try{
            List<Account> accounts = accountQuerySelectorInstance.selectAccountsByName(new Set<String>{'abcd'},'Id,Name');
            system.assert(accounts.size() == 0);
        }catch(Exception e){
            
        }
        
        try{
            Map<Id,Account> accountsByIds = accountQuerySelectorInstance.getAccountsByParentId(new Set<Id>{''},'Id,Name','Core_Customer_Aggregation_Type__c != null');
        }catch(Exception e){
            system.assertEquals('Invalid id: ', e.getMessage());
        }
        try{
            Map<Id,Account> accountsByIds = accountQuerySelectorInstance.getAccountsByParentId(new Set<Id>{'bhb23423'},'Id,Name','Core_Customer_Aggregation_Type__c != null');
        }catch(Exception e){
            system.assertEquals('Invalid id: bhb23423', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void whenGetBusinessTypeId(){
        Business_Types__c businessType = [Select Id from Business_Types__c where Name = 'Direct Price Exception'];
        Test.startTest();
        Map<String,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeId(new Set<String>{'DIR_PRC_EXCPT'});
        system.assertEquals(businessType.Id, businessTypeById.get('DIR_PRC_EXCPT').Id);
        
        Map<String,Business_Types__c> businessTypeById1 = accountQuerySelectorInstance.getBusinessTypeId(new Set<String>{'DIR_PRC_EXCP'});
        system.assertEquals(null, businessTypeById1);
        
        Map<String,Business_Types__c> businessTypeById2 = accountQuerySelectorInstance.getBusinessTypeId(new Set<String>{''});
        system.assertEquals(null, businessTypeById2);
        
        Test.stopTest();
    }
    /*
    @isTest
    private static void whenGetAccountByBpId(){
        Account acc = [Select Id,Name from Account where Name = 'TestChildAccount'];
        Test.startTest();
        String accountId = accountQuerySelectorInstance.getAccountByBpId('12345');
        system.assertEquals(acc.Id, accountId);
        
        String accountId1 = accountQuerySelectorInstance.getAccountByBpId('123');
        system.assert(String.isBlank(accountId1));
        
        String accountId2 = accountQuerySelectorInstance.getAccountByBpId('');
        system.assert(String.isBlank(accountId2));
        Test.stopTest();
    }*/
    
    @isTest
    private static void whenGetBusinessTypeByAccountId(){
        Account acc = [Select Id,Name from Account where Name = 'TestChildAccount'];
        test.startTest();
        Map<Id,List<Business_Types__c>> businessTypesByAccountId= accountQuerySelectorInstance.getBusinessTypesByAccountId(new Set<Id>{acc.Id},'Account__c,Business_Types__c');
        //system.debug('businessTypesByAccountId.get(acc.Id).size()--> '+businessTypesByAccountId);
        system.assertEquals(2, businessTypesByAccountId.get(acc.Id).size());
        try{
            Map<Id,List<Business_Types__c>> businessTypesByAccountId1= accountQuerySelectorInstance.getBusinessTypesByAccountId(new Set<Id>{''},'Account__c');
        }catch(Exception e){
            system.assertEquals('Invalid id: ', e.getMessage());
        }
        try{
            Map<Id,List<Business_Types__c>> businessTypesByAccountId1= accountQuerySelectorInstance.getBusinessTypesByAccountId(new Set<Id>{'r35345'},'Account__c,Business_Types__c');
        }catch(Exception e){
            system.assertEquals('Invalid id: r35345', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void whenGetComplianceWatchListByAccountId(){
        Account acc = [Select Id,Name from Account where Name = 'TestChildAccount'];
        test.startTest();
        Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId= accountQuerySelectorInstance.getComplianceWatchListByAccountId(new Set<Id>{acc.Id},'Core_Account_Id__c,Core_Type__c');
        //system.debug('complianceWatchListByAccountId.get(acc.Id).size()--> '+complianceWatchListByAccountId);
        system.assertEquals(2, complianceWatchListByAccountId.get(acc.Id).size());
        
        try{
           Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId1 = accountQuerySelectorInstance.getComplianceWatchListByAccountId(new Set<Id>{''},'Core_Account_Id__c,Core_Type__c'); 
        }catch(Exception e){
            system.assertEquals('Invalid id: ', e.getMessage());
        }
        
        try{
           Map<Id,List<Core_Account_Compliance_Watch_List__c>> complianceWatchListByAccountId1 = accountQuerySelectorInstance.getComplianceWatchListByAccountId(new Set<Id>{'wb3243'},'Core_Account_Id__c,Core_Type__c'); 
        }catch(Exception e){
            system.assertEquals('Invalid id: wb3243', e.getMessage());
        }
        Test.stopTest();
    }
    
    
    
    @isTest
    private static void whenGetBusinessTypeById(){
        Business_Types__c businessType = [Select Id,Name from Business_Types__c limit 1];
        Test.startTest();
        Map<Id,Business_Types__c> businessTypeById = accountQuerySelectorInstance.getBusinessTypeById(new Set<Id>{businessType.Id},'Id,Name');
        system.assertEquals(businessType.Name, businessTypeById.get(businessType.Id).Name);
        
        try{
            Map<Id,Business_Types__c> businessTypeById1 = accountQuerySelectorInstance.getBusinessTypeById(new Set<Id>{'8fuh87rh'},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: 8fuh87rh',e.getMessage());
        }
        
        try{
            Map<Id,Business_Types__c> businessTypeById2 = accountQuerySelectorInstance.getBusinessTypeById(new Set<Id>{''},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: ', e.getMessage());
        }
        
        Test.stopTest();
    }

    @isTest
    private static void whenGetIntegrationMessageQueueByAccountId(){
        List<Account> accounts = Database.query('Select Id,Name from account where name = \'TestChildAccount\'');
        Set<Id> accountIds = (new Map<Id,Account>(accounts)).keySet();
        test.startTest();
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageByAccountId = accountQuerySelectorInstance.getIntegrationMessageQueueByAccountId(accountIds);
        test.stopTest();
    }
    /*
    @isTest
    private static void whengetUserById(){
        User us = [Select Id from User limit 1];
        test.startTest();
        Map<Id,User> userById = accountQuerySelectorInstance.getUserById(new Set<Id>{us.Id});
        test.stopTest();
    }*/
    
    @isTest
    private static void whenUpdateHierarchyFieldsWithTrue(){
        Account account = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_Unified_Global_Customer__r.Core_Business_Party_Id__c,Core_Unified_Global_Customer__r.Core_Data_Simplified_Account_Nm__c from Account where Name = 'TestParentAccount' LIMIT 1];
        test.startTest();
        accountServiceInstance.updateHierarchyFields(account,true);
        test.stopTest();
    }

    @isTest
    private static void whengetChildAccountsWithParentTest(){
        Account acc = [Select Id,Name,ParentId,Parent.Name,Core_Customer_Aggregation_Type__c from Account where Name = 'TestChildAccount'];
        Test.startTest();
        String andClause = 'Core_Business_Party_Id__c != null AND  (RecordType.Name = \'End Customer Deal Account\' OR RecordType.Name = \'Intel Account\') Limit 100';

        Map< Id, List<Account> > accountsByIds2 = accountQuerySelectorInstance.getChildAccountsWithParent(new Set<Id>{acc.ParentId},'Id,Name,recordTypeId,ParentId', andClause);
        Test.stopTest();
    }
}