/**************************************************************************************
Apex Class Name:  Core_EloquaProfilerController_Test
Version     : 1.0 
Created Date: 01 JULY 2020
Function    : Test Class for the Core_EloquaProfilerController
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             07/1/2020              Original Version

*************************************************************************************/
@isTest
public class Core_EloquaProfilerController_Test{

    /*
     * Method name  : contactTest
     * Description  : test method to cover contact object
     * Return Type  : VOID
     * Parameter    : NONE
     */
    static testMethod void contactTest() {
        List<account> ac = Core_Test_Utility.createAccount(1);
        insert ac;
        List<contact> cn = Core_Test_Utility.createContacts(1);
        cn[0].email = 'test@test1.com';
        cn[0].LastName = 'a';
        cn[0].accountid = ac[0].id;        
        insert cn;        
        String email = Core_EloquaProfilerController.getUserSessionData(cn[0].id);        
        system.assertEquals('test@test1.com',email);
    }
    
    /*
     * Method name  : leadTest
     * Description  : test method to cover lead object
     * Return Type  : VOID
     * Parameter    : NONE
     */
    static testMethod void leadTest() {
        
        List<lead> ld = Core_Test_Utility.Core_Lead(1);        
        ld[0].RecordTypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        ld[0].LeadSource = 'Event';
        ld[0].country = 'AFG';
        ld[0].email = 'test@test1.com';
        insert ld;
        String email = Core_EloquaProfilerController.getUserSessionData(ld[0].id);
        system.assertEquals('test@test1.com',email);
    }
}