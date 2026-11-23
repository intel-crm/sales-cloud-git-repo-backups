/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_Edit_Detail_Ctrl_Test 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec$lstConlstConlstCon 2018                     test class for: Core_IPS_Project_Edit_Controller
**************************************************************************************************************************************************/
@istest
public class Core_IPS_Project_Edit_Detail_Ctrl_Test {
    public static user userRecord;
    static testMethod  void userTest(){
            Account acc = new Account();
            acc.Name='Test Account';
            acc.Core_IPS_Active__c=True;
            acc.BillingCity='Hyderabad';
            acc.BillingCountry='India';
            acc.BillingStreet='Banjara Hills Hyderabad';
            insert acc;
        	System.assert(acc.Id != null, 'Record not created');

            Contact cont =new Contact();
            cont.Core_IPS_Email_Opt_Out__c= true;
            cont.FirstName='test';
            cont.AccountId = acc.Id;
            cont.LastName = 'Herry';
            cont.Email = 'partner@fae.com';
            cont.Core_IPS_Active__c= True;
        	cont.MailingCountry= 'India';
            insert cont;   
        	System.assert(cont.Id != null, 'Record not created');

            Profile ProfileRec = [select Id,name from Profile where name = 'System Administrator' limit 1];
            // Create User
            userRecord = TestUtilities.getUser();
            userRecord.username = 'TestClassUser@intel.com';
            userRecord.ProfileID = ProfileRec.id;
            insert userRecord;
            System.assert(userRecord.Id != null, 'Record not created');

            system.runAs(userRecord){
            
            Core_IPS_Project__c Project = new Core_IPS_Project__c();
            Project.Name = 'Test';
            Project.Core_Status__c = 'Draft';
            Project.Core_IPS_Private__c= true; //US230261
            insert Project;
            update Project;
            System.assert(Project.Id != null, 'Record not created');

            
            PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Core_IPS_Permission_Set'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userRecord.Id;
            psa.PermissionSetId = ps.Id;
            insert psa; 
            System.assert(psa.Id != null, 'Record not created');

          /*  PageReference pageRef = Page.Core_IPS_Project_Detail_Page;
            Test.setCurrentPage(pageRef); */
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Project);
            Id strProId = ApexPages.currentPage().getParameters().put('id',Project.Id);  
            List<Core_IPS_Project_Member__c> coreIpsProjList = new List<Core_IPS_Project_Member__c>();
            
            Core_IPS_Project_Member__c coreIpsProj = new Core_IPS_Project_Member__c();
            coreIpsProj.Core_User__c = userRecord.Id;
            coreIpsProj.Core_Status__c = 'Active';
            coreIpsProj.Core_IPS_Project__c= Project.id; 
            
            Core_IPS_Project_Member__c coreIpsProj1 = new Core_IPS_Project_Member__c();
            coreIpsProj1.Core_User__c = userRecord.Id;
            coreIpsProj1.Core_IPS_Project__c= Project.id;
            
            coreIpsProjList.add(coreIpsProj);
            coreIpsProjList.add(coreIpsProj1);
            insert coreIpsProjList;
            System.assert(coreIpsProjList[0].Id != null, 'Record not created');

            Test.startTest();
            ApexPages.StandardController stdContrl = new ApexPages.StandardController(Project);
            Core_IPS_Project_Edit_Detail_Controller contr = new Core_IPS_Project_Edit_Detail_Controller(stdContrl);
            List<SelectOption>  x=contr.UserList;
            contr.fieldUpdate();
            contr.getContactData();
            contr.usersList1=coreIpsProjList;
            contr.usersList2=coreIpsProjList;
            contr.saveNew();
            contr.isEmailOptCheck= True;
            contr.selectedVal='Test';
            
            
            Test.stopTest();
        }
   }
   static testMethod  void userTestNegative(){
            Account acc = new Account();
            acc.Name='Test Account';
            acc.Core_IPS_Active__c=True;
            acc.BillingCity='Hyderabad';
            acc.BillingCountry='India';
            acc.BillingStreet='Banjara Hills Hyderabad';
            insert acc;
       		System.assert(acc.Id != null, 'Record not created');

            Contact cont =new Contact();
            cont.Core_IPS_Email_Opt_Out__c= true;
            cont.FirstName='test';
            cont.AccountId = acc.Id;
            cont.LastName = 'Herry';
            cont.Email = 'partner@fae.com';
            cont.Core_IPS_Active__c= True;
       		cont.MailingCountry = 'India';
            insert cont;
			System.assert(cont.Id != null, 'Record not created');
            
            //Create User        
            Profile prof = [SELECT Id FROM Profile WHERE Name='IPS Agent-Partner' LIMIT 1]; 
            
            User u = new User(FirstName='test', Alias = 'stand', Email='emplo@intel.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=cont.id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='popconrnapp@intel.com',isActive=true);
            insert u;
            System.assert(u.Id != null, 'Record not created');

            Core_IPS_Project__c Project = new Core_IPS_Project__c();
            Project.Name = 'Test';
            Project.Core_Status__c = 'Draft';
            insert Project;
            System.assert(Project.Id != null, 'Record not created');

        /*    PageReference pageRef = Page.Core_IPS_Project_Detail_Page;
            Test.setCurrentPage(pageRef); */
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Project);
            Id strProId = ApexPages.currentPage().getParameters().put('id',Project.Id);  
            List<Core_IPS_Project_Member__c> coreIpsProjList = new List<Core_IPS_Project_Member__c>();  
            Core_IPS_Project_Member__c coreIpsProj = new Core_IPS_Project_Member__c();
            coreIpsProj.Core_User__c = u.Id;
            coreIpsProj.Core_Status__c = 'Active';
            coreIpsProj.Core_IPS_Project__c= Project.id; 
            
            Core_IPS_Project_Member__c coreIpsProj1 = new Core_IPS_Project_Member__c();
            coreIpsProj1.Core_User__c = u.Id;
            coreIpsProj1.Core_IPS_Project__c= Project.id;
            coreIpsProjList.add(coreIpsProj);
            coreIpsProjList.add(coreIpsProj1);
            insert coreIpsProjList;
       		system.assert(coreIpsProjList!= null);
            Test.startTest();
            ApexPages.StandardController stdContrl = new ApexPages.StandardController(Project);
            Core_IPS_Project_Edit_Detail_Controller contr = new Core_IPS_Project_Edit_Detail_Controller(stdContrl);
            List<SelectOption>  x=contr.UserList;
            contr.fieldUpdate();
            contr.getContactData();
            contr.usersList1=coreIpsProjList;
            contr.usersList2=coreIpsProjList;
            contr.saveNew();
            contr.isEmailOptCheck= True;
            contr.selectedVal='Test';
            Test.stopTest();

   }

}