/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_Edit_ControllerTest 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     test class for: Core_IPS_Project_Edit_Controller
**************************************************************************************************************************************************/
@istest
public class Core_IPS_Project_Edit_ControllerTest {
static testMethod  void userTest(){
    
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        
        //Create User
        User u = new User(FirstName='test', Alias = 'stand', Email='emplo@intel.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = prof.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='popconrnapp@intel.com');
        insert u;
    	System.assert(u.Id != null, 'Record not created');

        system.runAs(u){
        Core_IPS_Project__c Project = new Core_IPS_Project__c();
        Project.Name = 'Test';
        Project.Core_Status__c = 'Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        Test.startTest();
        ApexPages.StandardController stdContrl = new ApexPages.StandardController(Project);
        Core_IPS_Project_Edit_Controller contr = new Core_IPS_Project_Edit_Controller(stdContrl);
        contr.redirectEditPage();
    	contr.saveNew();
    	Test.stopTest();
        }
   }
    //Added by Sowmya -Start - 25/09/2024 - TWC745-6800 - Fix test coverage for all failed classes 
     static testMethod  void userTestDetail(){
    
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        
        //Create User
        User u = new User(FirstName='test', Alias = 'stand', Email='emplo@intel.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = prof.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='popconrnapp@intel.com');
        insert u;
        System.assert(u.Id != null, 'Record not created');

        system.runAs(u){
        Core_IPS_Project__c Project = new Core_IPS_Project__c();
        Project.Name = 'Test';
        Project.Core_Status__c = 'Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        Test.startTest();
        ApexPages.StandardController stdContrl = new ApexPages.StandardController(Project);
        Core_IPS_Project_Edit_Controller contr = new Core_IPS_Project_Edit_Controller(stdContrl);
        contr.redirectDetailPage();
    	contr.saveNew();
    	Test.stopTest();
        }
         //Sowmya End - TWC745-6800 - Fix test coverage for all failed classes 
   }
}