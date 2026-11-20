/****************************************************************************************************************************
Apex Class Name     : PRM_AddContactsToGroupController_Test 
Version             : 1.0
Created Date        : 19-May-2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre        19-May-2020                Test class to cover PRM_AddContactsToGroupController_Test class

****************************************************************************************************************************/
@isTest()
public class PRM_AddContactsToGroupController_Test {
  
    static testmethod void methodToCoverFetchContacts()
    {   
        Test.startTest();        
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        insert testAccount;
        
        Contact cnt = new Contact();
        cnt.FirstName = 'Adrian';
        cnt.LastName =  'Contact1';
        cnt.Email  = 'adriancontact1@mailinator.com';
        cnt.AccountId = testAccount.Id;
        cnt.MailingCity = 'delhi';
        cnt.MailingCountry ='India';
        cnt.MailingPostalCode ='123456';
        cnt.Core_Login_Id__c = 'Bill243546';
        insert cnt;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Corporation';
        cont1.FirstName='Acme';
        cont1.email='Acme@gmail.com';
        cont1.MailingCountry ='India';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
        insert cont1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont1.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        /*PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=testAccount.Id;
        acctContRel1.PRM_Contact_Id__c=cont1.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=True;
        insert acctContRel1;*/
                
        ContactWrapper cntdata = new ContactWrapper();
        cntdata.id = acctContRel.PRM_Contact_Id__c;
        cntdata.contactName = acctContRel.PRM_Contact_Id__r.Name;
        cntdata.contactFirstName = acctContRel.PRM_Contact_Id__r.FirstName;
        cntdata.contactLastName = acctContRel.PRM_Contact_Id__r.LastName;
        cntdata.contactPartnerRole = acctContRel.PRM_Contact_Id__r.Core_IPA_PartnerRole__c;
        cntdata.contactEmail = acctContRel.PRM_Contact_Id__r.Email;
        cntdata.contactPhone = acctContRel.PRM_Contact_Id__r.Phone;
        
        ContactWrapper cntdata1 = new ContactWrapper();
        cntdata1.id = cont1.Id;
        cntdata1.contactName = cont1.Name;
        cntdata1.contactFirstName = cont1.FirstName;
        cntdata1.contactLastName = cont1.LastName;
        cntdata1.contactPartnerRole = cont1.Core_IPA_PartnerRole__c;
        cntdata1.contactEmail = cont1.Email;
        cntdata1.contactPhone = cont1.Phone;
        
        List<ContactWrapper> lstOfWrapper = new List<ContactWrapper>();
        lstOfWrapper.add(cntdata);
        lstOfWrapper.add(cntdata1);
        
        List<PRM_Account_Contact_Relationship__c> lstOfcontact = new List<PRM_Account_Contact_Relationship__c>();
        lstOfcontact.add(acctContRel);
        //lstOfcontact.add(acctContRel1);
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA contact Group';
        cntGr.PRM_Description_Txt__c = 'New IPA Gr';
        insert cntGr;
        
        PRM_Contact_Group_Contact_Association__c cgcaObj = new PRM_Contact_Group_Contact_Association__c();
        cgcaObj.PRM_Contact_Id__c = cnt.Id;
        cgcaObj.PRM_Contact_Group_Id__c = cntGr.Id;
        insert cgcaObj;       
        
        
        
        //PRM_AddContactsToGroupController.fetchContactsData('adriancontact1@mailinator.com',cntGr.Id);
        PRM_AddContactsToGroupController.fetchContactsData(cont1.Email,cntGr.Id);
        String result = PRM_AddContactsToGroupController.insertContactGrContAssRecords(lstOfcontact,cntGr.Id);
            
        Test.stopTest();
        System.assertEquals('Failed', result);
        
    }
    static testmethod void methodToCoverExistCGCARec()
    {   
        Test.startTest(); 
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        insert testAccount;
        
        Contact cnt = new Contact();
        cnt.FirstName = 'Adrian';
        cnt.LastName =  'Contact1';
        cnt.Email  = 'adriancontact1@mailinator.com';
        cnt.AccountId = testAccount.Id;
        cnt.MailingCity = 'delhi';
        cnt.MailingCountry ='India';
        cnt.MailingPostalCode ='123456';
        cnt.Core_Login_Id__c = 'Bill243546';
        insert cnt;
        
        List<Contact> lstOfcotact = new List<contact>();
        lstOfcotact.add(cnt);
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA contact Group';
        cntGr.PRM_Description_Txt__c = 'New IPA Gr';
        insert cntGr;
        
        PRM_Contact_Group_Contact_Association__c cgcaObj = new PRM_Contact_Group_Contact_Association__c();
        cgcaObj.PRM_Contact_Id__c = cnt.Id;
        cgcaObj.PRM_Contact_Group_Id__c = cntGr.Id;
        cgcaObj.PRM_InActive_Ind__c = True;
        insert cgcaObj;
        
        PRM_AddContactsToGroupController.fetchContactsData('adriancontact1@mailinator.com',cntGr.Id);
        String result = PRM_AddContactsToGroupController.insertContactGrContAssRecords(lstOfcotact,cntGr.Id);
            
        Test.stopTest();  
        System.assertEquals('Success', result);
    }
    
    static testmethod void methodToCoverFailedRec()
    {   
        Test.startTest(); 
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        insert testAccount;
        
        Contact cnt = new Contact();
        cnt.FirstName = 'Adrian';
        cnt.LastName =  'Contact1';
        cnt.Email  = 'adriancontact1@mailinator.com';
        cnt.AccountId = testAccount.Id;
        cnt.MailingCity = 'delhi';
        cnt.MailingCountry ='India';
        cnt.MailingPostalCode ='123456';
        cnt.Core_Login_Id__c = 'Bill243546';
        insert cnt;
        
        List<Contact> lstOfcotact = new List<contact>();
        //lstOfcotact.add(cnt);
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();
        cntGr.Name = 'IPA contact Group';
        cntGr.PRM_Description_Txt__c = 'New IPA Gr';
        insert cntGr;
        
        PRM_Contact_Group_Contact_Association__c cgcaObj = new PRM_Contact_Group_Contact_Association__c();
        cgcaObj.PRM_Contact_Id__c = cnt.Id;
        cgcaObj.PRM_Contact_Group_Id__c = cntGr.Id;
        cgcaObj.PRM_InActive_Ind__c = True;
        insert cgcaObj;
        
        PRM_AddContactsToGroupController.fetchContactsData('test@mailinator.com',cntGr.Id);
        String result = PRM_AddContactsToGroupController.insertContactGrContAssRecords(lstOfcotact,cntGr.Id);
            
        Test.stopTest();  
        System.assertNotEquals('Success', result);
    }
    
    public with sharing class ContactWrapper {
         @auraEnabled public string id {get;set;}
         @auraEnabled public string contactName {get;set;}
         @auraEnabled public string contactFirstName {get;set;}
         @auraEnabled public string contactLastName {get;set;}
         @auraEnabled public string contactPartnerRole {get;set;}
         @auraEnabled public string contactEmail {get;set;}
         @auraEnabled public string contactPhone {get;set;}
             
    }
}