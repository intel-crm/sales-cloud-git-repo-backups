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
@isTest
public class Core_Opp_LastActvityUpdate_Batch_Test {
    
    public static List<PricebookEntry> pbeList = new List<PricebookEntry>();
    
    static void testData(){
        // Create a new account        
        Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
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
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Develop', CloseDate = System.Date.today());
        insert opportunity;
        
        OpportunityLineItem opptyProd = new OpportunityLineItem(OpportunityId=opportunity.Id, PricebookEntryId=pbeList[0].Id,
                                                                Description='Test 11', UnitPrice=11, Quantity=11,Core_BU_Short_Name__c='T11',
                                                                Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert opptyProd;
        
        opportunity.Core_Last_Activity_Date__c=Date.valueOf(system.today()-2);
        update opportunity;
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = opportunity.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert(attachment);
        
        Note N= new Note();
        N.Title='Test Notess';
        N.Body='Hi this notes is created from Test class';
        N.ParentId=opportunity.Id;
        insert N;
        
        ContentNote objCntNote = new ContentNote();
        objCntNote.Title = 'salesforce code crack';
        objCntNote.Content = Blob.valueOf('Welcome to salesforcecodecrack.com');
        insert objCntNote; //Insert Content Note   
        
        //create ContentDocumentLink  record to link with parentId 
        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = opportunity.Id; // Specify your parent Id 
        objCntDocLink.ContentDocumentId = objCntNote.Id;  //Content Note Id
        objCntDocLink.shareType = 'V'; // Specify your sharing type 
        insert objCntDocLink;
        
        Core_Opp_FC_Prod_Schedule__c fc= new Core_Opp_FC_Prod_Schedule__c();
        fc.Core_Opp_FC_Opportunity__c=opportunity.Id;
        fc.Core_Opp_Line_Item_RecordID__c=opptyProd.id;
        insert fc;
        
        
    }
    
    static testmethod void TestLastActivity(){
        testData();
       
        Database.executeBatch(new Core_Opp_LastActvityUpdate_Batch()); 
        
    }
    
    
}