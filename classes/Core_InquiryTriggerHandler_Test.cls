/******************************************************************************************************************************************
Apex Class Name:  Core_InquiryTriggerHandler_Test
Version     : 1.0 
Created Date: 30 Jun 2020
Function    : Test Class for the Core_InquiryTriggerHandler_Test
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh             29/06/2020              Original Version
*******************************************************************************************************************************************/
@isTest
public class Core_InquiryTriggerHandler_Test {
   
     static testmethod void InquiryTest(){
               List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('SendInquiryEmailNotification');
        settingNameList.add('SendInquiryContactEmailNotification');
        settingNameList.add('InquiryRegionUpdate');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Inquiry';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_InquiryTrigger_Handler';
            triggerSetting.Core_Trigger_Events__c = 'After Insert';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
         
          /*List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_Job_Function_Code__c = 'TEST1';
            insert contact;
           Core_Inquiry__c Inq = new Core_Inquiry__c();
            Inq.Core_Contact_Inquiries__c=contact.id;
           Inq.Core_Inquiry_Type_Pkt__c='High Value Engagement';
         insert Inq;*/
        
    }
   /*static testmethod void InquiryTest1(){
                    List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('SendInquiryEmailNotification');
        settingNameList.add('SendInquiryContactEmailNotification');
        settingNameList.add('InquiryRegionUpdate');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Inquiry';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_InquiryTrigger_Handler';
            triggerSetting.Core_Trigger_Events__c = 'After Insert';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
         List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_Job_Function_Code__c = 'TEST1';
            insert contact;
       
              List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'IT Admin'];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        lstLead = Core_Test_Utility.createLead(2);
        for (Lead sobjLead: lstLead) {
            sobjLead.recordtypeId = leadRecType;
            sobjLead.Status = 'Tele Accepted Lead';
            sobjLead.Core_Lead_Status__c = 'Accepted';
            sobjLead.Core_Geo__c = '';
            sobjLead.Core_Sub_Geo__c = '';
            sobjLead.Phone = '(555) 555-5555';
            sobjLead.Title = '(555) 555-5555';
            sobjLead.Core_Current_Architecture__c = '(555) 555-5555';
            sobjLead.Core_Job_Function__c = '(555) 555-5555';
            sobjLead.Core_Product_Interest__c = '(555) 555-5555';
            sobjLead.Core_Project_Phase__c = '(555) 555-5555';
            sobjLead.Core_Project_Size__c = '555';
            sobjLead.Core_Project_Timeframe__c = '555';
            sobjLead.Core_Sales_Segment__c = '555';
            sobjLead.PostalCode = '560035';
        }
        
        System.runAs(lstUser[0]) {
            // Insert the intialized Lead
            lstLead[0].OwnerId = lstUser[0].Id;
            insert lstLead[0];
        }
           Core_Inquiry__c Inq = new Core_Inquiry__c();
            Inq.Core_Lead_Inquiries__c=lstLead[0].id;
           Inq.Core_Inquiry_Type_Pkt__c='High Value Engagement';
         insert Inq;
        
    }*/ 

}