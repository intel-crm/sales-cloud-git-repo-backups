@isTest
public class Core_TrackSalesGroupHistory_Batch_Test {
    @TestSetup
    private static void setCommonData(){
        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('SalesGroupHistoryAccount','Intel Account','UNFD_CTRY_CUST');
        account1.Core_Sales_Groups__c = 'Americas US Sales Group';
        account1.Core_Sales_Group_Preview__c='Americas US Sales Group';
        insert account1;

        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('SalesGroupHistoryAccount1','Intel Account','UNFD_CTRY_CUST');
        account2.Core_Sales_Groups__c = 'Americas US Sales Group';
        account2.Core_Sales_Group_Preview__c='Americas US Sales Group';
        insert account2;
    }
    @isTest
    private static void whenFirstHalfinsertSalesGroupHistory(){
        Account account = [Select Id, Core_Sales_Groups__c,Core_Sales_Group_Preview__c from Account where Name = 'SalesGroupHistoryAccount' LIMIT 1];
        Test.startTest();
        Database.executeBatch(new Core_TrackSalesGroupHistory_Batch());
        Test.stopTest(); 
        Datetime currentTime=System.now().addMonths(-6);
        Integer month=currentTime.month();
        List<Core_Sales_Group_History__c> salesGroupHistoryRecord=[Select Id,Account_Id__c,Sales_Group__c,Sales_Group_Preview__c,Period__c From Core_Sales_Group_History__c where Account_Id__c=:account.Id];
        if(month<=6){
            System.assertEquals('1H2023SalesGroup', salesGroupHistoryRecord[0].Period__c,'1stHalfSalesGroup');
        }
        else{
            System.assertEquals('2H2023SalesGroup', salesGroupHistoryRecord[0].Period__c,'2ndHalfSalesGroup');
        }
    }
}