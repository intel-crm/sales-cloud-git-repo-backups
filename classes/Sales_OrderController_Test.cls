@isTest
public class Sales_OrderController_Test {
    static testmethod void testSearchAccount(){
        Account intelAccount=Sales_TestFactory_Utility.createAccount();
        String searchText='TstAccIntel';
        test.startTest();
        List<Account> accList=Sales_OrderController.findRecords(searchText);
        test.stopTest();
        String Account = [SELECT Name FROM Account WHERE Id=:accList limit 1].Name;
        System.assert(Account.contains(searchText));
    }
    static testmethod void testCreateAccount(){
        Account soldTo = Sales_TestFactory_Utility.createSoldToAccount();
        insert soldTo;
        String selectedField='Core_Direct_Sales_Organization_Nm__c,Core_Direct_Payment_Term_Nm__c,Core_Direct_Distributor_Channel_Nm__c';
        test.startTest();
        List<Account> soldToDetails=Sales_OrderController.fetchSoldToDetails(soldTo.Id,selectedField);
        test.stopTest();
        Account soldToAccount=[SELECT Id FROM Account WHERE Id=:soldToDetails[0].Id LIMIT 1];
        System.assertEquals(soldTo.Id, soldToAccount.Id);
       }
    static testmethod void testEndCustAccount(){
        Account endCustAccount = Sales_TestFactory_Utility.createEndCustomerAccount();
        test.startTest();
        List<Account> endCustDetailsList=Sales_OrderController.fetchEndCustDetails(endCustAccount.Id);
        test.stopTest();
        Account ac = [SELECT Id FROM Account WHERE Id=:endCustDetailsList[0].Id LIMIT 1];
        System.assertEquals(endCustAccount.Id,ac.Id);
    }
    static testmethod void testPickListValues(){
        String objApiName='Order';
        String fieldName='Sales_Order_Reason__c';
        test.startTest();
        Sales_OrderController.getPickListValues(objApiName,fieldName);
        Sales_OrderController.getFieldLabel(objApiName,fieldName);
        test.stopTest();
    }
    static testmethod void testPickList(){
        String objApiName='Order';
        String fieldName=null;
        test.startTest();
        Sales_OrderController.getPickListValues(objApiName,fieldName);
        Sales_OrderController.getFieldLabel(objApiName,fieldName);
        test.stopTest();
    }
    static testmethod void testFieldLabel(){
        String objApiName='';
        String fieldName='';
        test.startTest();
         Sales_OrderController.getPickListValues(objApiName,fieldName);
        Sales_OrderController.getFieldLabel(objApiName,fieldName);
        test.stopTest();
    }
}