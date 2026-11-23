/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_detail_overrideTest 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     test class for: Core_IPS_Project_detail_override
**************************************************************************************************************************************************/
@istest
public class Core_IPS_Project_detail_overrideTest {
static testMethod  void userTest(){
    
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        
        //Create User
        User u = new User(FirstName='test', Alias = 'stand', Email='emplo@intel.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = prof.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='popconrnapp@intel.com');
        insert u;
        system.runAs(u){
        Core_IPS_Project__c Project = new Core_IPS_Project__c();
        Project.Name = 'Test';
        Project.Core_Status__c = 'Draft';
        insert Project;
        Test.startTest();
        ApexPages.StandardController stdContrl = new ApexPages.StandardController(Project);
        Core_IPS_Project_detail_override contr = new Core_IPS_Project_detail_override(stdContrl);
        contr.redirectDetailPage();
    	Test.stopTest();
        }
   }
}