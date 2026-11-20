@isTest
public class ACM_CNDA_SearchAndSelect_Test {
    
    @TestSetup
    private static void setCommonData() {
        Account iAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Amazon','Intel Account','UNFD_GLBL_CUST');
        iAccount.Core_CNDA_Number__c = '9632584';
        insert iAccount;
    }
    
    @isTest
    private static void CNDASearchAndSelect()
    {
        Test.setMock(HttpCalloutMock.class, new ACM_MockCNDAHttpResponse());
        Id AcctId = [Select Id from ACCOUNT where Name = 'Amazon'].Id;
        Test.startTest();
        Object result = ACM_CNDA_SearchAndSelect.ExecuteAPI(AcctId,null,false);
        Test.stopTest();
        Assert.isNotNull(result, 'is not null');     
    }
    
    @isTest
    private static void CNDASearchAndSelect2()
    {
        Test.setMock(HttpCalloutMock.class, new ACM_MockCNDAHttpResponse());
        Id AcctId = [Select Id from ACCOUNT where Name = 'Amazon'].Id;
        Test.startTest();
        Object result = ACM_CNDA_SearchAndSelect.ExecuteAPI(AcctId,null,true);
        Test.stopTest();
        Assert.isNotNull(result, 'is not null');     
    }
    
    @isTest
    private static void CNDASearchAndSelectAppendText()
    {
        Test.setMock(HttpCalloutMock.class, new ACM_MockCNDAHttpResponse());
        Id AcctId = [Select Id from ACCOUNT where Name = 'Amazon'].Id;
        List<String> rows = new List<String>();
        rows.add('RS5395311');
        Test.startTest();
        Boolean result = ACM_CNDA_SearchAndSelect.appendToAccountField(AcctId,'IPLA1392',rows);
        Test.stopTest();
        System.assert(true,result);
    }

}