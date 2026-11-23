/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Lead_SLA_SendEmailBatch_Test
Version     : 1.0 
Created Date: 11 Nov 2018
Function    : Test class for Core_Lead_SLA_SendEmailBatch batch class
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

@isTest
public class Core_Lead_SLA_SendEmailBatch_Test {

    static testMethod void batchTest1(){
        String leadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
        Lead lead1 = new lead();
        lead1.RecordTypeId = leadRecType;
        lead1.FirstName = 'Test Lead';
        lead1.Title = 'title';
        lead1.City = 'Banglore';
        lead1.Core_Current_Architecture__c = 'ARM';
        lead1.LastName = 'Test';
        lead1.Company = 'Testing';
        lead1.phone = '9876543210';
        lead1.Email = 'test@gmail.com';
        lead1.CountryCode = 'IND';
        lead1.StateCode = 'KA';
        lead1.Core_Job_Function__c = 'Branch Manager';
        lead1.Core_Product_Interest__c = 'Ethernet Controllers';
        lead1.Core_Project_Phase__c = 'Explore';
        lead1.Core_Project_Size__c = '$10,000,000 - $5,000,000';
        lead1.Core_Project_Timeframe__c = '0-6 Months';
        lead1.Street = 'ECity';
        lead1.PostalCode = '560099';
        lead1.LeadSource = 'Intel Customer Support';
        insert lead1;
        //lead1.Status = 'Tele Accepted Lead';
        update lead1;
        //lead1.Status = 'Tele Qualified Lead';
        update lead1;
        lead1.Status = 'Sales Accepted Lead';
        lead1.Core_SAL_Email_Trigger_Date__c = system.now();
        lead1.Core_SendEmail__c = false;
        lead1.Core_SendEmail4__c = false;
        update lead1;
        Database.executeBatch(new Core_Lead_SLA_SendEmailBatch());
        
        lead1.Core_SAL_Email_Trigger_Date__c = null;
        lead1.Core_SAL_Weekend_Email_Trigger_Date__c = system.now();
        lead1.Core_SendEmail__c = false;
        lead1.Core_SendEmail4__c = false;
        update lead1;
        Database.executeBatch(new Core_Lead_SLA_SendEmailBatch());
        
        String cronExp = '0 0 5 ? * *';
        system.schedule('Send Email at 5am', cronExp, new Core_Schedule_SendEmail());
    }
}