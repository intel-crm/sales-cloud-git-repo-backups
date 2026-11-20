/**************************************************************************************
Apex Class Name: PMP_SearchCompanyTranslationAction_Test
Version     : 1.0 
Created Date: 21 June, 2019
Description : Test Class for PMP_SearchCompanyTranslationAction
* Modification Log :
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Nikhil          21/06/2019               Original Version
* Nikhil          23/07/2019               Updated.
*************************************************************************************/
@isTest
private class PMP_SearchCompanyTranslationAction_Test {
    
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Partners');
        insert cs;
    }
   
    @isTest static void testTranslationTrigger(){
        PMP_Company__c comp = new PMP_Company__c();
      	comp.Name = 'testCompany';
        comp.PMP_Account_Industry__c = 'Agriculture';
        
        Test.startTest();
        
        insert comp;
        List<PMP_Company_Translation__c> transList = [SELECT Id FROM PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c =:comp.Id];
        system.assertEquals(2, transList.size());

        Test.stopTest();   
    }
}