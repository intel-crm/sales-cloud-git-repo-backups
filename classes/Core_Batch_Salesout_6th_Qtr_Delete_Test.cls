/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_Salesout_6th_Qtr_Delete_Test 
Version     : 1.0 
Created Date: 1/6/15
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              1/6/15                 Initial Version
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_Batch_Salesout_6th_Qtr_Delete_Test 
{
    static testMethod void testSalesout6thQtrDelete()
    {
        List<Account> lstAccount = Core_Test_Utility.createAccount(1);
        insert lstAccount;
    
        List<Core_Channel_Salesout__c> lstSalesout = Core_Test_Utility.Core_Channel_Salesout(200);
        for (Integer i=0; i < 100; i++)
            lstSalesout[i].Core_Invoice_Quarter__c = 201402;

        for (Core_Channel_Salesout__c cs : lstSalesout)
            cs.Core_Account_Name__c = lstAccount[0].Id;            
            
        insert lstSalesout;
        
        test.startTest();
        database.executebatch(new Core_Batch_Salesout_6th_Qtr_Delete());
        test.stopTest();
    }  
}