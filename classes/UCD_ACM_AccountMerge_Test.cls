@isTest
public class UCD_ACM_AccountMerge_Test {
    
    @TestSetup
    private static void createCommonData(){
        
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Business_Party_Id__c = '22334455';
        insert parentAccount;

        Account IntelintChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IntelTestIntChildAccount1','Intel Account','UNFD_INTRMD_CUST');
        IntelintChildAcc1.parentId = parentAccount.Id;
        IntelintChildAcc1.Core_Business_Party_Id__c = '22334455';
        insert IntelintChildAcc1;

        Account mergeAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestMergeAccount','Intel Account','UNFD_GLBL_CUST');
        mergeAccount.Core_Business_Party_Id__c='100998765';
        insert mergeAccount;

        Business_Types__c businessType = new Business_Types__c(Name='Sales CRM',Is_Active__c=true,Business_Type_Code__c='SLS_CRM',Business_Types_Category__c = 'CPE');
        insert businessType;

        Account_Business_Types__c accountBusinessType = new Account_Business_Types__c();
        accountBusinessType.Account__c = mergeAccount.Id;
        accountBusinessType.Business_Types__c = businessType.Id;
        accountBusinessType.Effective_Start_Date__c = system.today();
        insert accountBusinessType; 
        
        Core_Account_Compliance_Watch_List__c complianceWatchList =  new Core_Account_Compliance_Watch_List__c();
        complianceWatchList.Core_Account_Id__c = mergeAccount.Id;
        complianceWatchList.Core_Type__c = 'NOSNCTN';
        complianceWatchList.Core_Effective_Start_Date__c = system.today();
        insert complianceWatchList;
    }

    @IsTest
    static void testSetAcctOnMerge() {
        
        List<Account> accList = [
            SELECT Id, RecordTypeId, Core_Business_Party_Id__c,MasterRecordId
            FROM Account
            WHERE Core_Business_Party_Id__c = '22334455' LIMIT 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse());
        UCD_ACM_AccountMerge.afterDeleteAccountMerge(accList);
        Test.stopTest();
    }

    @IsTest
    static void testSetAcctCWLOnMerge1() {
        
        List<Account> accList = [
            SELECT Id, RecordTypeId, Core_Business_Party_Id__c,MasterRecordId
            FROM Account
            WHERE Core_Business_Party_Id__c = '22334455' LIMIT 1
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse());
        UCD_ACM_AccountDeactivationService.setCWLDeleteDate('test','test');
        Test.stopTest();
    }

    @IsTest
    static void testSetAcctCpeOnMerge1() {
        
        List<Account> accList = [
            SELECT Id, RecordTypeId, Core_Business_Party_Id__c,MasterRecordId
            FROM Account
            WHERE Core_Business_Party_Id__c = '100998765' LIMIT 1
        ];
        Set<Id> acctBusinessTypeId=new Set<Id>();
        List<Account_Business_Types__c> acctBusineesType=[Select Id, Account__c, Business_Types__c, Effective_Start_Date__c From Account_Business_Types__c Where Account__c=:accList[0].Id];
        for(Account_Business_Types__c accBus:acctBusineesType){
            acctBusinessTypeId.add(accBus.Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse());
        UCD_ACM_AccountDeactivationService acctRelitoService = new UCD_ACM_AccountDeactivationService();
        acctRelitoService.removeCPEXwalk('test','test',acctBusinessTypeId);
        Test.stopTest();
    }

    public class Core_HttpCallouts_MockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"inactivated","crosswalks":["crosswalk1","crosswalk2"],"message":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    Public static void testBeforeDeleteMerge(){
        List<Account> accList = [
            SELECT Id, RecordTypeId, Core_Business_Party_Id__c,MasterRecordId
            FROM Account
            WHERE Core_Business_Party_Id__c = '100998765' LIMIT 1
        ];
        Test.startTest();
        UCD_ACM_AccountMerge.beforeDeleteAccountMerge(accList);
        Test.stopTest();
    }
}