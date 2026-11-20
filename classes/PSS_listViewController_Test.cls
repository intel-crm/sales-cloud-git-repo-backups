/****************************************************************************************************************************************
* Class Name  : PSS_listViewController_Test
* Version     : 1.0 
* Created Date: 08-18-2021
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sooriya     08/18/2021                   Test class of PSS_listViewController
*****************************************************************************************************************************************/
@isTest
public class PSS_listViewController_Test {
    
    @isTest
     public static void listValuesTest(){

         Test.startTest();
         /*IPA2.0: US-TWC729-7976*/
         /*Map<String,object> listReturn = PSS_listViewController.listValues('ArdiraSurvey__Survey_Result__c');
         system.assertNotEquals(listReturn.get('listViewWrapper'), Null,'List View is Not Null');*/
         Map<String,object> listReturn2 = PSS_listViewController.listValues('PMP_Partner_offering__c');
         system.assertNotEquals(listReturn2.get('listViewWrapper'), Null,'List View is Not Null');
         Map<String,object> listReturn3 = PSS_listViewController.listValues('PMP_Company__c');
         system.assertNotEquals(listReturn3.get('listViewWrapper'), Null,'List View is Not Null');
         Test.stopTest();
     }

}