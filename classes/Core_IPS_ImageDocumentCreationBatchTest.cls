/**
* @description       : 
* @author            : Prem Ranjan
* @group             : 
* @last modified on  : 09-02-2020
* @last modified by  : Prem Ranjan
* Modifications Log 
* Ver   Date         Author        Modification
* 1.0   09-02-2020   Prem Ranjan   Initial Version
**/
@isTest
private class Core_IPS_ImageDocumentCreationBatchTest {
    
    static testmethod void caseDescriptionImage() {
        Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            BillingState = 'NV',
            BillingPostalCode = '591213',
            Core_CIM_ID__c = '11429344',
            Core_B2B_Entitlement__c = true,
            Core_Account_Legal_Name__c = 'TestLegalName',
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='babux5x52@intel.com',
            MailingCountry = 'India'
        );
        Database.insert(contact2);
        
        Case caseRecord = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'Low',
            Subject = 'TestSubject1',
            Core_Issue_Description__c = 'TestDescription1 <img alt="User-added image" src="https://inteltest.imageurl.com" style="height: 195px; width: 500px;"></img><br>'  
        );
        Database.insert(caseRecord);
        Case caseRecord1 = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'Low',
            Subject = 'TestSubject1',
            Core_Issue_Description__c = ''  
        );
        Database.insert(caseRecord1);
        Test.startTest();
        String query ='Select id,casenumber, Core_Issue_Description__c from case limit 10';
        Core_IPS_ImageDocumentCreationBatch createDoc = new Core_IPS_ImageDocumentCreationBatch(query);
        ID batchprocessid = Database.executeBatch(createDoc,5);
        Test.stopTest();    
        System.assertNOTEquals(batchprocessid, null, 'Batch job executed');
        
    }
    static testmethod void caseCommentDescriptionImage() {
        Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            BillingState = 'NV',
            BillingPostalCode = '591213',
            Core_CIM_ID__c = '11429344',
            Core_B2B_Entitlement__c = true,
            Core_Account_Legal_Name__c = 'TestLegalName',
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='babux5x52@intel.com',
            MailingCountry = 'India'
        );
        Database.insert(contact2);
        
        Case caseRecord = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'Low',
            Subject = 'TestSubject1',
            Core_Issue_Description__c = 'TestDescription1 <img alt="User-added image" src="https://inteltest.imageurl.com" style="height: 195px; width: 500px;"></img><br>'  
        );
        Database.insert(caseRecord);
        List<Core_IPS_Labels__c> ipsLabelList = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c label0 = new Core_IPS_Labels__c ();
        label0.name= 'PUBLIC_TO_CUSTOMERS';
        label0.value__c='Public to Customers';
        ipsLabelList.add(label0);
        
        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'PRIVATE_TO_AGENTS';
        label1.value__c= 'Private to Agents';
        ipsLabelList.add(label1);
        
        Core_IPS_Labels__c label2 = new Core_IPS_Labels__c ();
        label2.name= 'PRIVATE_TO_INTEL';
        label2.value__c= 'Private to Intel';
        ipsLabelList.add(label2);
        
        Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
        label3.name='Customer';
        label3.value__c='Customer';
        ipsLabelList.add(label3);
        
        Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
        label4.name='FAE';
        label4.value__c='FAE';
        ipsLabelList.add(label4);
        
        Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
        label5.name='Agent';
        label5.value__c='Agent';
        ipsLabelList.add(label5);
        
        Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
        label6.name='Backend Integration';
        label6.value__c='Backend Integration';
        ipsLabelList.add(label6);
        
        Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
        label7.name='Data Migration';
        label7.value__c='Data Migration';
        ipsLabelList.add(label7);
        
        Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
        label8.name='Partner';
        label8.value__c='Partner';
        ipsLabelList.add(label8);
        
        Core_IPS_Labels__c label9 = new Core_IPS_Labels__c ();
        label9.name= 'PRIVATE_TO_PARTNERS';
        label9.value__c= 'Private to Partner';
        ipsLabelList.add(label9);
        
        Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
        label10.name='Partner - DFAE';
        label10.value__c='Partner - DFAE';
        ipsLabelList.add(label10);
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - Agent';
        label11.value__c='Partner - Agent';
        ipsLabelList.add(label11);
        
        Core_IPS_Labels__c label12= new Core_IPS_Labels__c();
        label12.name='Comment Source - Customer';
        label12.value__c='Customer Portal';
        ipsLabelList.add(label12);
        
        Core_IPS_Labels__c label13= new Core_IPS_Labels__c();
        label13.name='Comment Source - Internal';
        label13.value__c='Internal Portal';
        ipsLabelList.add(label13);
        
        Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
        label14.name='Comment Source - Email';
        label14.value__c='Email';
        ipsLabelList.add(label14);
        
        Core_IPS_Labels__c label15= new Core_IPS_Labels__c();
        label15.name='Comment Source - N/A';
        label15.value__c='N/A';
        ipsLabelList.add(label15);
        
        Core_IPS_Labels__c label16= new Core_IPS_Labels__c();
        label16.name='Comment Source - Data Migration';
        label16.value__c='Data Migration';
        ipsLabelList.add(label16);
        
        insert ipsLabelList;        
        Core_IPS_Case_Comments__c casecomment = new Core_IPS_Case_Comments__c();
        casecomment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        casecomment.Core_IPS_Case__c = caseRecord.Id;
        casecomment.Core_IPS_Rich_Comment__c = 'TestDescription1 <img alt="User-added image" src="https://inteltest.imageurl.com" style="height: 195px; width: 500px;"></img><br>';
        insert casecomment;
        Core_IPS_Case_Comments__c casecomment1 = new Core_IPS_Case_Comments__c();
        casecomment1.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        casecomment1.Core_IPS_Case__c = caseRecord.Id;
        insert casecomment1;
        Test.startTest();
        String query ='SELECT Id, Name, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c limit 10';
        Core_IPS_ImageDocumentCreationBatch createDoc = new Core_IPS_ImageDocumentCreationBatch(query);
        ID batchprocessid = Database.executeBatch(createDoc,5);
        Test.stopTest();   
        Core_IPS_ImageDocumentCreationBatch.deleteMaxlinearDocument();
        System.assertNOTEquals(batchprocessid, null, 'Batch job executed');
    }
    
}