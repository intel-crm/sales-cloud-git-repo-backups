/***************************************************************************************************
* Apex Class Name: Core_IPS_Email_Reprocess_Test 
* Version     : 1.0 
* Created Date: 6th Dec 2015
* Function    : Test class for Core_IPS_Email_Reprocess
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     12/06/2015              Created
****************************************************************************************************/
@isTest public class Core_IPS_Email_Reprocess_Test {    
    private static User SystUserRunAs;
    private static Account Accnt;
/***************************************************************************************************
* Method Name:  ContactEmailReprocessFile
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 6th Dec 2015
* Description: Reprocess failed external email notifications for a single file  
* Scenario Type: Positive and Negative  
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/       
    private static testMethod void ContactEmailReprocessFile(){
        Setup_Common_Test_Data(); 
        ContactEmailReprocessFilesRun(1);
    }
/***************************************************************************************************
* Method Name:  ContactEmailReprocessFiles
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 6th Dec 2015
* Description: Reprocess failed external email notifications for a multiple file  
* Scenario Type: Positive and Negative  
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/   
    private static testMethod void ContactEmailReprocessFiles(){
        Setup_Common_Test_Data(); 
        ContactEmailReprocessFilesRun(5);
    }
/***************************************************************************************************
* Method Name:  ContactEmailReprocessFilesRun
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 6th Dec 2015
* Description: Reprocess failed external email notifications for a single & multiple files  
* Scenario Type: Positive and Negative  
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/       
    private static void ContactEmailReprocessFilesRun(Integer FileCount){     
        Contact Cont;     
        List<Id> FailedEmailLogIds = new List<Id>();
        String Message;
        Integer LogCount;
        System.runAs(SystUserRunAs) {
            //Create Contact
            Cont = TestUtilities.getContact();
            Cont.AccountId = Accnt.Id;
            Cont.Email = 'email@intel.com';
            Cont.EmailBouncedReason = 'testbounce'; 
            Cont.EmailBouncedDate = System.now();            
            Database.insert(Cont);
            system.assert(Cont.Id != null);
            //File Upload Master
            List<Core_IPS_File_Upload_Master__c> lstFuplm = new List<Core_IPS_File_Upload_Master__c>();
            for(Integer i = 0; i < FileCount; i++){
                Core_IPS_File_Upload_Master__c FileUplm;
                FileUplm = TestUtilities.getFileUploadMasterRecord();
                DateTime ExpDate;
                ExpDate = System.now().AddDays(60);
                FileUplm.Core_File_GUID__c =  'Testfl' + i;
                FileUplm.Core_File_Name__c =  'Testfl' + i;
                FileUplm.Core_Upload_Status__c = 'Complete';
                FileUplm.Core_Expiration_Date__c = ExpDate;
                lstFuplm.add(FileUplm);    
            }
            Database.insert(lstFuplm); 
            //Create log
            List<Core_IPS_Email_Log__c> lstEmailLog = new List<Core_IPS_Email_Log__c>();
            for (Integer i = 0; i < lstFuplm.size(); i++) {
                Core_IPS_File_Upload_Master__c FileUplm = lstFuplm[i];
                Core_IPS_Email_Log__c EmailLog = new Core_IPS_Email_Log__c(); 
                EmailLog.Core_TargetObjectId__c = Cont.Id;
                EmailLog.Core_WhatId__c = FileUplm.Id;
                EmailLog.Core_TemplateID__c = '';    
                EmailLog.Core_OrgWideEmailAddressId__c = '';
                EmailLog.Core_Project__c = 'IPS';
                EmailLog.Core_ApplicationArea__c = 'IPS External Download Notification';
                EmailLog.Core_Status__c = 'Error';
                lstEmailLog.add(EmailLog);     
            }
            Database.insert(lstEmailLog);
            //check log
            LogCount = [select count() from Core_IPS_Email_Log__c];
            System.assertEquals(FileCount,LogCount); 
            //Reprocess - should not send email as  error not fixed
            lstEmailLog = [select Id, Core_TargetObjectId__c, Core_TemplateID__c, Core_WhatId__c, Core_OrgWideEmailAddressId__c from Core_IPS_Email_Log__c];
            for(Core_IPS_Email_Log__c EmailLogObj : lstEmailLog ){
                FailedEmailLogIds.add(EmailLogObj.id);    
            }
            Test.startTest();
            Message = Core_IPS_Email_Reprocess.ReprocessExtDownloadNotifEmail(FailedEmailLogIds);
            system.debug('#######' + Message);
            system.assert(Message != null); 
            //check log
            LogCount = 0;
            LogCount = [select count() from Core_IPS_Email_Log__c];
            system.debug('#######' + LogCount);
            System.assertEquals(FileCount,LogCount);  
            //Correct Entry
            List<Contact> lstTobeUpdatedContact = new List<Contact>();
            Contact ContactUpdObj = new Contact(Id = Cont.Id);
            ContactUpdObj.EmailBouncedReason = ''; 
            ContactUpdObj.EmailBouncedDate = null;
            lstTobeUpdatedContact.add(ContactUpdObj);  
            update lstTobeUpdatedContact;
            Message = '';
            Message = Core_IPS_Email_Reprocess.ReprocessExtDownloadNotifEmail(FailedEmailLogIds);
            Test.stopTest();
            system.debug('#######' + Message);
            system.assert(Message != null); 
            //check log
            LogCount = 0;
            LogCount = [select count() from Core_IPS_Email_Log__c];
            system.debug('#######' + LogCount);
            System.assertEquals(0,LogCount);              
        }        
    }    
/***************************************************************************************************
* Method Name:  Setup_Common_Test_Data
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 6th Dec 2015
* Description: Utility internal method to create common test data  
* Scenario Type: N/A
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/           
    private static void Setup_Common_Test_Data(){
        Id RoleId;
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name = : System.label.Core_System_Admin_Profile_Name];
        //Get an Existing System Admin User
        List<User> lstSysUsers = [select id, Name, UserRoleId from User where isActive = true and 
                                  ProfileId =:SysAdmPrf.Id and UserRoleId != null and 
                                  id !=:userinfo.getuserid() limit 1];
        if (lstSysUsers != null && lstSysUsers.size()> 0 ) {
            SystUserRunAs = lstSysUsers[0];  
            system.assert(SystUserRunAs.Id != null);
        } else {
            //Create a New Sys User with New Role
            UserRole TestRl = new UserRole(name = 'TEST ROLE');
            Database.insert(TestRl);
            system.assert(TestRl.Id != null);
            RoleId = TestRl.Id; 
            SystUserRunAs = TestUtilities.getUser();
            SystUserRunAs.userroleid = RoleId;
            SystUserRunAs.alias = 'sysrunas'; 
            SystUserRunAs.email = 'testsysusrrunas@intel.com';
            SystUserRunAs.profileid = SysAdmPrf.Id;
            SystUserRunAs.userName = 'testsysusrrunas@intel.com';
            Database.insert(SystUserRunAs); 
            system.assert(SystUserRunAs.Id != null);            
        }        
        System.runAs(SystUserRunAs) {
            //Create Account        
            //Accnt =  TestUtilities.getAccount();@@@Utility has issues
            Accnt = new Account();
            Accnt.Name = 'Test Account';
            Accnt.BillingCountryCode = 'USA';
            Accnt.BillingStateCode = 'AL';
            Accnt.BillingCity = 'Alabama';
            Accnt.BillingStreet = 'street';
            Accnt.Core_IPS_Active__c = true;
            Database.insert(Accnt);
            system.assert(Accnt.Id != null);
            //Custom setting Core_IPS_ExtDownNotif_Email_Settings__c
            List<Core_IPS_ExtDownNotif_Email_Settings__c> lstCSExtEmail  = new List<Core_IPS_ExtDownNotif_Email_Settings__c>();
            for (Integer i = 0; i < 2; i++) {
                Core_IPS_ExtDownNotif_Email_Settings__c CSExtEmail = new Core_IPS_ExtDownNotif_Email_Settings__c();
                //AllOrNone
                if (i == 0) {    
                    CSExtEmail.Name = 'AllOrNone';
                    CSExtEmail.Core_value__c = 'false';
                    lstCSExtEmail.add(CSExtEmail);
                }
                //SaveAsActivity
                if (i == 1) {    
                    CSExtEmail.Name = 'SaveAsActivity';
                    CSExtEmail.Core_value__c = 'false';
                    lstCSExtEmail.add(CSExtEmail);
                }
            }
            Database.insert(lstCSExtEmail);                        
        }
    }
}