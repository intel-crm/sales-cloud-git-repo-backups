/**************************************************************************************
Apex Class Name:  Core_POP_Handler_Test
Version     : 1.0 
Created Date: 17/1/2019
Description : Test class for the Core_POP_Handler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            17/1/2019               Original Version
*************************************************************************************/

@isTest
public class Core_POP_Handler_Test {

    static testMethod void popTest(){
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'UpdateTerritoryInfoOnOppty';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OpportunityHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'Before Insert Before Update';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'determineApprovers';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OppApproval';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'Before Update';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'opportunityOppFactDelete';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OpportunityHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'Before Delete';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'opportunityTechnicalOwnerUpdate';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OpportunityHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'After Insert After Update';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'updateProductLineItems';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OppApproval';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'Before Update';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'opportunityStageUpdate';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OpportunityHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'after Update';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'updateActivityLineItems';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OpportunityHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'after Update';
        triggerExecList.add(triggerExec);
        
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'POPCheckOnUpdate';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_POP_Handler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'after Update';
        triggerExecList.add(triggerExec);
        
        insert triggerExecList;
        
        // Create a new account        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create a new opportunity using the account created above
        List<Opportunity> oppList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity4', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity5', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
        
        oppList.add(opp);
        insert oppList;
        oppList[0].Core_Approval_Status__c = 'Approved';
        try{
            update oppList;
        }catch(Exception e){
            system.debug('Error on update '+e.getStackTraceString());
        }
        
        Note n = new note(parentid=oppList[0].id,title='POP',body='test note contents');
        insert n;
        
        Attachment attach=new Attachment();      
        attach.Name='Proof Of Performance';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=oppList[1].id;
        insert attach;
        
        Task tasks = new Task();
        tasks.Subject = 'POP';
        tasks.Core_Task_Type__c = 'Proof of Performance Confirmed';
        tasks.WhatId = oppList[2].Id;
        insert tasks;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'POP';
        cv.PathOnClient ='test';
        cv.VersionData = Blob.valueOf('Testing base 64 encode');
        insert cv;
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contdocLink = new ContentDocumentLink();
        contdocLink.LinkedEntityId = oppList[3].Id;
        contdocLink.ContentDocumentId = testContent.ContentDocumentId;
        contdocLink.ShareType = 'V';
        insert contdocLink;
                
        for(Opportunity opps : oppList){
            opps.Core_Approval_Status__c = 'Approved';
        }
        try{
            update oppList;
        }catch(Exception e){
            system.debug('Error on update '+e.getStackTraceString());
        }
    }
}