/**************************************************************************************
Apex Class Name:  Core_POP_Handler_Test
Version     : 1.0 
Created Date: 17/1/2019
Description : Test class for the Core_POP_Handler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            17/1/2019               Original Version
* Pratik Padwal             23/2/2023        TWC3123-3686 - Added test method for new PW POP check.
*************************************************************************************/

@isTest
public class Core_POP_Handler_Test {
    
    static testMethod void popValTest(){
        
        User sysUser = [select Id from User where Profile.name='System Administrator' and isActive=true limit 1];
        system.runAs(sysUser)
        {
            Core_Opp_Bypass_Validation_Rule__c triggerByPass = new Core_Opp_Bypass_Validation_Rule__c();
            triggerByPass.Bypass__c = true;
            INSERT triggerByPass;
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
            
            //   
            Account acct = new Account();
            acct.name = 'Testxxxx 1000999';
            acct.BillingCountryCode = 'USA';
            acct.BIllingStateCode = 'AL';
            acct.BillingCity = 'Alabama';
            acct.BillingStreet = 'test';
            acct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            acct.Industry = 'Telecommunications';
            acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
            Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            acct.RecordTypeId = masterRecordTypeId;
            // acct.Core_Approved_Account__c = true;
            insert acct;
            
            //  Id AccId = [select id from account where Core_Approved_Account__c= true and IsDeleted = false limit 1][0].Id;
            //List<Account> lstAccount = [select id from account where Core_Approved_Account__c= true and IsDeleted = false limit 1];
            // Create a new product
            Product2 product = new Product2(Name = 'Test Product111');
            insert product;
            
            // Create a new price book entry using the product created above
            PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                    UnitPrice = 100, IsActive = true);
            insert pbe;
            
            // Create a new opportunity using the account created above
            List<Opportunity> oppList = new List<Opportunity>();
            List<Opportunity> oppListold = new List<Opportunity>();
            Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
            Opportunity opp = new Opportunity(Name = 'Test Opportunity 145', RecordTypeId = newOppRecTypeId,OwnerId= UserInfo.getUserId(),
                                              AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Approval_Status__c ='Not Submitted');
            
            
            
            
            oppList.add(opp);
            
            insert oppList;
            
            
            oppListold = [select Id, name,Core_Approval_Status__c,StageName, AccountId   from Opportunity where Id In : oppList] ;
            System.assertEquals(true, true);
            
            
            
            System.assertEquals(true, true);
            
            
            Attachment attach=new Attachment();      
            attach.Name='Proof Of Performance POP1';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=oppList[0].id;
            insert attach;
            
            Attachment attach1=new Attachment();      
            attach1.Name='Proof Of Performance POP';
            Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body 111111111111111111111111111111');
            attach1.body=bodyBlob1;
            attach1.parentId=oppList[0].id;
            insert attach1;
            
            Attachment attach2=new Attachment();      
            attach2.Name='Proof Of Performance POP';
            Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
            attach2.body=bodyBlob2;
            attach2.parentId=oppList[0].id;
            insert attach2;
            
            Task tasks = new Task();
            tasks.Subject = 'POP';
            tasks.Core_Task_Type__c = 'Proof of Performance Confirmed';
            tasks.WhatId = oppList[0].Id;
            insert tasks;
            ContentVersion cv = new ContentVersion();
            cv.title = 'POP';
            cv.PathOnClient ='test';
            cv.VersionData = Blob.valueOf('Testing base 64 encode');
            insert cv;
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            ContentDocumentLink contdocLink = new ContentDocumentLink();
            contdocLink.LinkedEntityId = oppList[0].Id;
            contdocLink.ContentDocumentId = testContent.ContentDocumentId;
            contdocLink.ShareType = 'V';
            insert contdocLink;
            for(Opportunity opps : oppList){
                opps.Core_Approval_Status__c = 'Approved';
                opps.StageName= 'Design';
            }  
            update oppList;
            System.assertEquals(true, true);
            
            List<Attachment> attachsize = new List<Attachment>();
            List<String> POPFileNames = new List<String>();
            if(Label.Core_Performance_indicator3.contains(',')){
                POPFileNames = Label.Core_Performance_indicator3.split(',');
            }else{
                POPFileNames.add(Label.Core_Performance_indicator3); 
            } 
            
        }
    }
    
    static testMethod void TechOwnerValidation(){
        Core_Opp_Bypass_Validation_Rule__c triggerByPass = new Core_Opp_Bypass_Validation_Rule__c();
        triggerByPass.Bypass__c = true;
        INSERT triggerByPass;
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'Tech_CIMID_Validation';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_OpportunityHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'Before Insert Before Update';
        triggerExecList.add(triggerExec);
        insert triggerExecList;
        
        CRM_UCD_CIM_switch__c UCDSwitch = new CRM_UCD_CIM_switch__c(Name ='UCD_switch',Active__c = true);
        insert UCDSwitch;
        // Create a new account 
        
        Account acct = new Account();
        acct.name = 'Test 532342';
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama';
        acct.BillingStreet = 'test';
        acct.Core_Business_Party_Id__c = null;
        acct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        acct.Industry = 'Telecommunications';
        acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acct.RecordTypeId = masterRecordTypeId;
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
        //Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,Core_Approval_Status__c='Not Submitted',OwnerId= UserInfo.getUserId(),
                                          AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c = 'Design: Original');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,OwnerId= UserInfo.getUserId(),
                              AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Approval_Status__c ='Not Submitted',Core_Opportunity_Type__c = 'Design: Original');
        
        oppList.add(opp);
        opp = new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,OwnerId= UserInfo.getUserId(),
                              AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Approval_Status__c ='Not Submitted',Core_Opportunity_Type__c = 'Design: Original');
        
        oppList.add(opp);
        insert oppList;
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=oppList[0].Id, PricebookEntryId=pbe.Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        OpportunityLineItem testOppLineItem1 = new OpportunityLineItem(OpportunityId=oppList[1].Id, PricebookEntryId=pbe.Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        OpportunityLineItem testOppLineItem2 = new OpportunityLineItem(OpportunityId=oppList[2].Id, PricebookEntryId=pbe.Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        
        try{            
            insert testOppLineItem;
            insert testOppLineItem1;
            insert testOppLineItem2;
            oppList[0].Core_Approval_Status__c = 'Approved';
            update oppList;            
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_POP_Handler_Test.techOwnerValidation');
        }
        for(Opportunity opps : oppList){
            opps.Core_Approval_Status__c = 'Approved';
            opps.Core_Technical_Owner__c = null;
            opps.Core_Is_Product_Vendor_Inactive__c = true;
        }
        try{
            update oppList;
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_POP_Handler_Test.techOwnerValidation');
        }
        for(Opportunity opps : oppList){
            opps.Core_Technical_Owner__c = UserInfo.getUserId();
        }
        try{
            update oppList;
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_POP_Handler_Test.techOwnerValidation');
        }
    }
    
    static testMethod void popPWApprovalTest2(){
        Core_Opp_Bypass_Validation_Rule__c triggerByPass = new Core_Opp_Bypass_Validation_Rule__c();
        triggerByPass.Bypass__c = true;
        INSERT triggerByPass;
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
        triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'POPCheckOnUpdate';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'Core_POP_Handler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'Opportunity';
        triggerExec.Core_Trigger_Events__c = 'after Update';
        triggerExecList.add(triggerExec);        
        insert triggerExecList;
        
        Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Create a new account   
        
        
        Account acct = new Account();
        acct.name = 'Test ';
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama';
        acct.BillingStreet = 'test';
        acct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        acct.Industry = 'Telecommunications';
        acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acct.RecordTypeId = masterRecordTypeId;
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create a new opportunity using the account created above
        
        Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,Core_Commissionable__c = 'Yes',OwnerId= UserInfo.getUserId(),
                                          AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Approval_Status__c ='Not Submitted');
        
        insert opp;
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        
        insert testOppLineItem;
        Note n = new note(parentid=opp.id,title='POP',body='test note contents');
        insert n;
        opp.Core_Approval_Status__c = 'Approved';
        opp.StageName='Design Win';
        try{
            update opp;
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_POP_Handler_Test.popPWApprovalTest');
        }
        opp.Core_PW_Approval_Status__c = 'Approved';
        opp.StageName = 'Production Win';
        try{
            update opp;
            List<Opportunity> ListOp = new List<Opportunity>();
            ListOp.Add(opp);
            Map<Id, Opportunity> OpMap = new Map<Id, Opportunity>(ListOp);
            Core_POP_Handler.popCheckOnPWApproval(ListOp, OpMap);
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_POP_Handler_Test.popPWApprovalTest');
        }        
    }
    
}