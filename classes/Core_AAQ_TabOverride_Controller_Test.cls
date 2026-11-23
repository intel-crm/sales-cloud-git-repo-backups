/**************************************************************************************
Apex Class Name:  Core_AAQ_TabOverride_Controller_Test
Version     : 1.0 
Created Date: 20 Jan 2017
Description    : This class is Test class for Core_AAQ_TabOverride_Controller
*************************************************************************************/
@isTest
public class Core_AAQ_TabOverride_Controller_Test{
   static testMethod void aaqOverride(){
       Core_AAQ_Profile_Handler__c handler= new Core_AAQ_Profile_Handler__c();
       handler.name='test';
       handler.Core_Description__c='test description';
       handler.Core_Profile_Image__c='image/test.jpg';
       handler.Core_Profile_Url__c='test url';
       handler.Core_Order__c = 1;
       insert handler;
       
       Core_AAQ_TabOverride_Controller controller=new Core_AAQ_TabOverride_Controller();
       controller.onLoadPage();
       System.assertEquals(1,controller.categoryColumn.size());
   }
    
    @isTest
    static void testOnLoad(){
        List<Core_AAQ_Profile_Handler__c> result = Core_AAQ_TabOverride_Controller.onLoadLWC();
        System.assertEquals(1,result.size());
    }
}