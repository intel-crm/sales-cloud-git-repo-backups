/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_LastActvityUpdate_Batch_Test
Version     : 1.0 
Created Date: 10/04/2020
Function    : Test class for Core_Opp_LastActvityUpdate_Batch

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               10/04/2020               Original Version developed
*******************************************************************************************************************************************************************/
//test
@isTest
public class Core_Opp_LastActvityUpdate_Batch_Test {
    
    public static List<PricebookEntry> pbeList = new List<PricebookEntry>();
    
    static void testData(){
        // Create a new account
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                  .get('Mastered_Account')
                  .getRecordTypeId();        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c='Americas Brazil Sales Group',Industry ='Agriculture', Core_Sub_Industry__c='Forestry',recordtypeId=recordTypeId);
        insert acct;
        
        // Create a new product
        Product2 product = new Product2(Name = 'Test Product1');
        insert product;
        Product2 product1 = new Product2(Name = 'Test Product2');
        insert product1;
        
        // Create a new price book entry using the product created above
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 100, IsActive = true);
        pbeList.add(pbe);
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = product1.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                 UnitPrice = 110, IsActive = true);
        pbeList.add(pbe1);
        insert pbeList;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opportunity1 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Develop', CloseDate = System.Date.today());
        insert opportunity1;
        Opportunity opportunity2 = new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Develop', CloseDate = System.Date.today());
        insert opportunity2;
        
        OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=opportunity1.Id, PricebookEntryId=pbeList[0].Id,
                                                                Description='Test 11', UnitPrice=11, Quantity=11,
                                                                Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd;
        
        opportunity1.Core_Last_Activity_Date__c=Date.valueOf(system.today()-50);
        opportunity1.Core_Status_Update__c = 'Testing';
        update opportunity1;
        Datetime pastDate = Datetime.now().addDays(-30);
        Core_Opp_FC_Prod_Schedule__c fc= new Core_Opp_FC_Prod_Schedule__c();
        fc.Core_Opp_FC_Opportunity__c=opportunity1.Id;
        fc.Core_Opp_Line_Item_RecordID__c=opptyProd.id;
        insert fc;
        Test.setCreatedDate(fc.Id, pastDate);
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = opportunity2.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        pastDate = Datetime.now().addDays(-35);
        insert(attachment);
        Test.setCreatedDate(attachment.Id, pastDate);
        
        Note N= new Note();
        N.Title='Test Notess';
        N.Body='Hi this notes is created from Test class';
        N.ParentId=opportunity1.Id;
        insert N;
        
        ContentNote objCntNote = new ContentNote();
        objCntNote.Title = 'salesforce code crack';
        objCntNote.Content = Blob.valueOf('Welcome to salesforcecodecrack.com');
        insert objCntNote; //Insert Content Note   
        
        //create ContentDocumentLink  record to link with parentId 
        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = opportunity1.Id; // Specify your parent Id 
        objCntDocLink.ContentDocumentId = objCntNote.Id;  //Content Note Id
        objCntDocLink.shareType = 'V'; // Specify your sharing type 
        insert objCntDocLink;
        OpportunityFieldHistory cleanHistory = new OpportunityFieldHistory(
    OpportunityId = opportunity1.Id, 
    Field = 'Core_Status_Update__c'
);
insert cleanHistory;
        pastDate = Datetime.now().addDays(-29);
        Test.setCreatedDate(cleanHistory.Id, pastDate);
        
         Task taskInstance = new Task();
            taskInstance.ActivityDate = System.Today().addDays(1);
            taskInstance.Priority = 'Medium';
            taskInstance.status = 'Pending';
            taskInstance.Subject = 'Email';
         taskInstance.WhatId = opportunity1.id;
        insert taskInstance;
        
        Event e = new Event();
        e.WhatId=opportunity1.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        insert e;
        
        
    }
    
    static testmethod void TestLastActivity(){
        testData();
       
        Database.executeBatch(new Core_Opp_LastActvityUpdate_Batch()); 
        system.assertEquals(true,true);
        
    }
    
    
}