/********************************************************************************************************************
Apex Class Name:  Core_IPS_ViewCase_Controller_Test
Version     : 1.0 
Description    : Test class for Core_IPS_ViewCase_Controller
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh Sahu                       08/23/2017                Created
*******************************************************************************************************************/
@isTest
private class Core_IPS_ViewCase_Controller_Test {
    
    @testSetup 
    static void TestData() {
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.ProfileID =  sysAdminProfileID;  
        sysadmin.username='intel.com.crm123@intel.com';      
        insert sysadmin;
        
        System.runAs(sysadmin) {
            Case objCase = TestUtilities.getCase();
            objCase.RecordTypeId = schema.sobjecttype.Case.getrecordtypeinfosbyname().get('IPS Case Create').getRecordTypeId(); 
            objCase.Core_IPS_Customer_Visible__c = false;
            insert objCase;
            System.assert(objCase.Id!=null,'Case Not Created');
        }
    }
    
    static testMethod void Test_Core_IPS_ViewCase_Controller() {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        //commented for classic EOL-Tejaswini
         /*   PageReference pageRef = Page.Core_IPS_ViewCase;
        pgref.getParameters().put('id', caseId);        
        Test.setCurrentPage(pgref);*/
        
        Test.startTest();
        Core_IPS_ViewCase_Controller inst_ViewCase = new Core_IPS_ViewCase_Controller(new ApexPages.StandardController(new Case(Id=caseId)));                
        Test.stopTest();
    }
}