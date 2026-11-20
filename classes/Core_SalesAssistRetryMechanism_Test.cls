@isTest
public class Core_SalesAssistRetryMechanism_Test {
    static testMethod void testMethod1(){  
        List<Account> accList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.name = 'Test ';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sales_Groups__c = 'Americas US Sales Group';
        accountInstance.Core_Business_Party_Id__c = '12969875';    
        accList.add(accountInstance);   
        insert accList; 
        List<Id> lstOpptySalesAssistId= new List<Id>();
        List<Core_Sales_Assist_Staging__c> salesAssistListInsert = new List<Core_Sales_Assist_Staging__c>(); 
        List<Core_Sales_Assist_Staging__c> salesAssistListUpdate = new List<Core_Sales_Assist_Staging__c>();
        Core_Sales_Assist_Staging__c salAssist = new Core_Sales_Assist_Staging__c();
        salAssist.Core_Unified_Id__c = accList[0].Core_Business_Party_Id__c;
        salAssist.Core_Retry_Counter__c = 0;
        salAssist.Core_Status_Pkt__c = 'New';
        salesAssistListInsert.add(salAssist);
        insert salesAssistListInsert; 
        
        Core_Sales_Assist_Staging__c salAssist1 = new Core_Sales_Assist_Staging__c();
        salAssist1.Id = salesAssistListInsert[0].Id;
        salAssist1.Core_Unified_Id__c = accList[0].Core_Business_Party_Id__c;
        salAssist1.Core_Retry_Counter__c = 1;
        salAssist1.Core_Status_Pkt__c = 'Failure';
        salesAssistListInsert.add(salAssist1);
        update salesAssistListUpdate; 
        
                      
        Test.startTest();
            for(Core_Sales_Assist_Staging__c stagg : salesAssistListUpdate){
                lstOpptySalesAssistId.add(stagg.Id);
            }
            Core_SalesAssistRetryMechanism.retryFailedSalesAssit(lstOpptySalesAssistId);
        Test.stopTest();
    }
}