/**************************************************************************************
Apex Class Name:  Core_First_ThirdParty_Data_Ctrl_Test
Version     : 1.0 
Created Date: 10 June 2020
Function    : Test class for Core_First_ThirdParty_Data_Compare_Ctrl  class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh             06/10/2020              Original Version
*************************************************************************************/

@isTest
public class Core_First_ThirdParty_Data_Ctrl_Test {
    
     testMethod static void InsertOppTest1() {
    Account accountInstance = new Account();
            accountInstance.name = 'TestAccount122';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';  
            accountInstance.Core_CIM_ID__c='10102356';
            accountInstance.Core_Sales_Groups__c='CCG Sales Group'; 
            accountInstance.Core_IPA_Partner_Role__c='Distributor'; 
            accountInstance.Core_bC_Role__c='Manufacturer';
             accountInstance.Core_IPA_Partner_Segment__c='Client Computing'; 
            accountInstance.Core_bC_Partner_Segment__c='Data Center';
            insert accountInstance;
         
         
         ApexPages.StandardController sc = new ApexPages.StandardController(accountInstance);
          Core_First_ThirdParty_Data_Compare_Ctrl testAccPlan = new Core_First_ThirdParty_Data_Compare_Ctrl(sc); 
        
         PageReference pageRef = Page.Core_First_ThirdPart_Data_Checklist;
         pageRef.getParameters().put('id', String.valueOf(accountInstance.Id));
         Test.setCurrentPage(pageRef);
       //  testAccPlan.cancel();
     }
    
         testMethod static void InsertOppTest2() {
    Account accountInstance = new Account();
            accountInstance.name = 'TestAccount122';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';  
            accountInstance.Core_CIM_ID__c='10102356';
            accountInstance.Core_Sales_Groups__c='CCG Sales Group'; 
            accountInstance.Core_IPA_Partner_Role__c='Distributor'; 
           // accountInstance.Core_bC_Role__c='Manufacturer';
             accountInstance.Core_IPA_Partner_Segment__c='Client Computing'; 
            //accountInstance.Core_bC_Partner_Segment__c='Data Center';
            insert accountInstance;
         
         
         ApexPages.StandardController sc = new ApexPages.StandardController(accountInstance);
          Core_First_ThirdParty_Data_Compare_Ctrl testAccPlan = new Core_First_ThirdParty_Data_Compare_Ctrl(sc); 
        
         PageReference pageRef = Page.Core_First_ThirdPart_Data_Checklist;
         pageRef.getParameters().put('id', String.valueOf(accountInstance.Id));
         Test.setCurrentPage(pageRef);
       //  testAccPlan.cancel();
     }
}