/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Claim_Lead_Ctrl_Test
Version     : 1.0 
Created Date: 22 November 2018
Function    : Test class for Core_Claim_Lead_Ctrl
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            22/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

@isTest
public class Core_Claim_Lead_Ctrl_Test {
    
    static testMethod void verifyOwnerTest(){
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'System Administrator'];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        lstLead = Core_Test_Utility.createLead(2);
        for (Lead sobjLead: lstLead) {
            sobjLead.recordtypeId = leadRecType;
            sobjLead.Status = 'Sales Generated Lead';
            sobjLead.Core_Lead_Status__c = 'Accepted';
            sobjLead.Core_Lead_Sub_Status__c = 'Attempting Contact';
            sobjLead.Core_Lead_State__c = 'In Pursuit';
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
            lstLead[0].Core_Lead_Sub_Status__c='In Contact';
            update lstLead[0];
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
            
            lstLead[1].OwnerId = UserInfo.getUserId();
            insert lstLead[1];
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[1].Id);
            System.assertEquals('Accepted', lstLead[1].Core_Lead_Status__c);

            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[1].Id);
        }
        
    }
    
    static testMethod void verifyOwnerTest1(){
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'System Administrator'];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        lstLead = Core_Test_Utility.createLead(2);
        for (Lead sobjLead: lstLead) {
            sobjLead.recordtypeId = leadRecType;
            sobjLead.Status = 'Marketing Qualified Lead';
            sobjLead.Core_Lead_Status__c = 'New';
            sobjLead.Core_Lead_Sub_Status__c = 'Waiting to be Claimed';
            sobjLead.Core_Lead_State__c = 'Unclaimed';
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
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
            lstLead[0].Core_Lead_Status__c = 'Qualified';
            lstLead[0].Core_Lead_Sub_Status__c = 'In Contact';
            update lstLead[0];
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
            
            lstLead[1].OwnerId = UserInfo.getUserId();
            insert lstLead[1];
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[1].Id);
            System.assertEquals('New', lstLead[1].Core_Lead_Status__c);

            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[1].Id);
        }
        
    }
    
    
    static testMethod void verifyOwnerTest2(){
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'System Administrator'];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        //lstLead = Core_Test_Utility.createLead(2);
        lead sobjLead = new lead();
        
        sobjLead.FirstName = 'Team';
        
        sobjLead.lastName = 'CSot';
        sobjLead.Company = 'Xcza';
        sobjLead.email = 'tes6578t@hh.com';
        sobjLead.CountryCode = 'USA';
        sobjLead.StateCode = 'AL';
        sobjLead.City = 'Alabama';
        sobjLead.Street = 'test';
        sobjLead.leadSource = 'Email';
        
        sobjLead.PostalCode = '57710';
        sobjLead.Title = 'He8lo';
        sobjLead.Core_Current_Architecture__c='Test';
        sobjLead.Phone='97788788';
        sobjLead.Core_Product_Interest__c='10';
        sobjLead.Core_Project_Phase__c='testing';
        sobjLead.Core_Project_Size__c='4';
        sobjLead.Core_Project_Timeframe__c='12-24 Months';
        sobjLead.Core_Lead_State__c = 'Unclaimed';
        sobjLead.recordtypeId = leadRecType;
        sobjLead.Status = 'PRL';
        sobjLead.Core_Lead_Status__c = 'New';
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
        sobjLead.Company = 'Abc new';
        sobjLead.LeadSource = 'Website';
        // sobjLead.Core_Sales_Group__c = '';
        lstLead.add(sobjLead);
        
        
        System.runAs(lstUser[0]) {
            // Insert the intialized Lead
            lstLead[0].OwnerId = lstUser[0].Id;
            insert lstLead[0];
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
            Core_Claim_Lead_Ctrl.validateLeadRecord(lstLead[0].Id);
            System.assertEquals('New', lstLead[0].Core_Lead_Status__c);
        }
        
        
        //lstLead[0].Core_Lead_State__c = 'Terminated';
        //update lstLead[0];
        //Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
    }
    static testMethod void verifyOwnerTest3(){
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'System Administrator'];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        //lstLead = Core_Test_Utility.createLead(2);
        lead sobjLead = new lead();
        
        sobjLead.FirstName = 'Team';
        
        sobjLead.lastName = 'CSot';
        sobjLead.Company = 'Xcza';
        sobjLead.email = 'tes6578t@hh.com';
        sobjLead.CountryCode = 'USA';
        sobjLead.StateCode = 'AL';
        sobjLead.City = 'Alabama';
        sobjLead.Street = 'test';
        sobjLead.leadSource = 'Email';
        
        sobjLead.PostalCode = '57710';
        sobjLead.Title = 'He8lo';
        sobjLead.Core_Current_Architecture__c='Test';
        sobjLead.Phone='97788788';
        sobjLead.Core_Product_Interest__c='10';
        sobjLead.Core_Project_Phase__c='testing';
        sobjLead.Core_Project_Size__c='4';
        sobjLead.Core_Project_Timeframe__c='12-24 Months';
        // sobjLead.Core_Lead_State__c = 'Un claimed';
        sobjLead.recordtypeId = leadRecType;
        sobjLead.Status = 'Rejected';
        sobjLead.Core_Lead_Status__c = 'New';
        sobjLead.Core_Lead_State__c = 'Terminated';
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
        sobjLead.Company = 'Abc new';
        sobjLead.LeadSource = 'Website';
        // sobjLead.Core_Sales_Group__c = '';
        lstLead.add(sobjLead);
        
        
        System.runAs(lstUser[0]) {
            // Insert the intialized Lead
            lstLead[0].OwnerId = lstUser[0].Id;
            insert lstLead[0];
            lstLead[0].Core_Partner_Lead_Owner__c=lstUser[0].Id;
            System.assertEquals('New', lstLead[0].Core_Lead_Status__c);
            Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
            //update lstLead[0];
        }
        
    }
    
    static testMethod void verifyOwnerTest4(){
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'System Administrator'];
        lstUser = Core_Test_Utility.Core_User(1);
        lstUser[0].Profileid = p1.id;
        insert lstUser;
        
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        //lstLead = Core_Test_Utility.createLead(2);
        lead sobjLead = new lead();
        
        sobjLead.FirstName = 'Team12';
        
        sobjLead.lastName = 'CSot12';
        sobjLead.Company = 'Xcza12';
        sobjLead.email = 'tes6578t@hhj.com';
        sobjLead.CountryCode = 'USA';
        sobjLead.StateCode = 'AL';
        sobjLead.City = 'Alabama';
        sobjLead.Street = 'test';
        sobjLead.leadSource = 'Email';
        
        sobjLead.PostalCode = '57710';
        sobjLead.Title = 'He8lo1';
        sobjLead.Core_Current_Architecture__c='Test';
        sobjLead.Phone='9778871188';
        sobjLead.Core_Product_Interest__c='10';
        sobjLead.Core_Project_Phase__c='testing';
        sobjLead.Core_Project_Size__c='4';
        sobjLead.Core_Project_Timeframe__c='12-24 Months';
        // sobjLead.Core_Lead_State__c = 'Un claimed';
        sobjLead.recordtypeId = leadRecType;
        sobjLead.Status = 'PRL';
        sobjLead.Core_Lead_Status__c = 'New';
        //sobjLead.Core_Lead_State__c = 'Unclaimed';
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
        sobjLead.Company = 'Abc new12';
        sobjLead.LeadSource = 'Website';
        // sobjLead.Core_Sales_Group__c = '';
        lstLead.add(sobjLead);
        
        
        System.runAs(lstUser[0]) {
            // Insert the intialized Lead
            lstLead[0].OwnerId = lstUser[0].Id;
            insert lstLead[0];
            lstLead[0].Core_Partner_Lead_Owner__c=lstUser[0].Id;
            Core_Claim_Lead_Ctrl.validateLeadRecord(lstLead[0].Id);
            System.assertEquals('New', lstLead[0].Core_Lead_Status__c);
            
            //update lstLead[0];
        }
        
        Core_Claim_Lead_Ctrl.verifyOwner(lstLead[0].Id);
        Core_Claim_Lead_Ctrl.validateLeadRecord(lstLead[0].Id);
        
        
    }
    
}