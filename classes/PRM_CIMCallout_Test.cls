/*********************************************************************************************************************
Apex Class Name  : PRM_CIMCallout_Test
Version          : 1.0
Created Date     : DEC 2018
Function         : Test class for PRM_CIMCallout/PRM_CIMWrapper

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Rahul Kainth               12/05/2018              Test class for PRM_CIMCallout/PRM_CIMWrapper

*********************************************************************************************************************/
@isTest
private class PRM_CIMCallout_Test {
       
     @isTest static void testCalloutFullDup() {
        // Set mock callout class 
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
        
         Account acc2 = PRM_TestUtility.getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
           
        /*Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';       
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;*/
           
        PRM_Registration_Request__c rr1 = PRM_TestUtility.getPRMRegistrationRequest();
        rr1.PRM_Zip_Postal_Code__c = '1111';
        rr1.PRM_Email_ID__c = 'abcd@intel.com';          
        insert rr1;
        
         
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
           
        
    //soqlObj.soslQuery();
           
        Test.startTest();
        
        PRM_CIMCallout cim1 = new PRM_CIMCallout(rr1,0,null,null,'www.test1.com',true);
        /*cim1.execute(currentContext);
        Test.stopTest();
        System.assertEquals(rr1.Name,'RR1');*/
        
    }
    
    @isTest static void testCalloutFullDup4(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
        
         Account acc2 = PRM_TestUtility.getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
           
        /*Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';       
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;*/
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        /*Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
        
        PRM_Registration_Request__c rr5 = new PRM_Registration_Request__c();
        rr5.Name = 'RR5';
        rr5.PRM_First_Name__c = 'Test Request';
        rr5.PRM_Last_Name__c = 'New';
        rr5.PRM_Email_ID__c = 'testrequest123@mailinator.com';
        rr5.PRM_Preferred_Language__c='ENG';
        rr5.PRM_Account_Name__c='Intel';
        rr5.PRM_Company_Email_Domain__c='intel.com';
        rr5.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr5.PRM_Address_Line_2__c=''; 
        rr5.PRM_City__c='Las Vegas';
        rr5.PRM_State_Province__c='NY';
        rr5.PRM_Country__c='USA';
        insert rr5;
        
        Test.startTest();
        PRM_CIMCallout cim5 = new PRM_CIMCallout(rr5,0,null,null,'www.test1.com',true);
        Test.stopTest();
        /*cim5.execute(currentContext);
        
    System.assertEquals(rr5.Name,'RR5');*/
        
    }
    
    @isTest static void testCalloutFullDup3(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
        
         Account acc2 = PRM_TestUtility.getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
           
        /*Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';       
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;*/
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        /*Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
        
        PRM_Registration_Request__c rr4 = PRM_TestUtility.getPRMRegistrationRequest();
        rr4.PRM_Zip_Postal_Code__c = '9090';
        rr4.PRM_Email_ID__c = 'bcd@intel.com';
        rr4.PRM_Address_Line_2__c = '';
        insert rr4;
        
       Test.startTest();
        PRM_CIMCallout cim4 = new PRM_CIMCallout(rr4,0,null,null,'www.test1.com',true);
        Test.stopTest();
        /* cim4.execute(currentContext);
        
    system.assert(rr4.Name != null);*/
    }
    
    @isTest static void testCalloutFullDup2(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
        
         Account acc2 = PRM_TestUtility.getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
           
        /*Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';       
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;*/
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
       /* Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
        
        PRM_Registration_Request__c rr3 = PRM_TestUtility.getPRMRegistrationRequest();
        rr3.PRM_Zip_Postal_Code__c = '3333';
        rr3.PRM_Email_ID__c = 'a@intel.com';
        insert rr3;
        
        Test.startTest();
        PRM_CIMCallout cim3 = new PRM_CIMCallout(rr3,0,null,null,'www.test1.com',true);
        Test.stopTest();
        /*cim3.execute(currentContext);
        
    system.assert(rr3.Name != null);*/
    }
    @isTest static void testCalloutFullDup1(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
        
         Account acc2 = PRM_TestUtility.getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
           
        /*Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';       
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;*/
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
       /* Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
        
        PRM_Registration_Request__c rr2 = PRM_TestUtility.getPRMRegistrationRequest();
        rr2.PRM_Zip_Postal_Code__c = '2222';
        rr2.PRM_Email_ID__c = 'ab@intel.com';
        rr2.PRM_Salesforce_ID__c = acc1.Id; 
        insert rr2;
        
        Test.startTest();
        PRM_CIMCallout cim2 = new PRM_CIMCallout(rr2,0,'0',null,'www.test1.com',true);
        Test.stopTest();
        /*cim2.execute(currentContext);
        
    system.assert(rr2.Name != null);*/
    }
    
    @istest static void testCallout_Error1(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
           
       /* Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';        
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
        
        PRM_Registration_Request__c rr6 = PRM_TestUtility.getPRMRegistrationRequest();
        rr6.PRM_Zip_Postal_Code__c = '4444';
        rr6.PRM_Email_ID__c = 'abcdef@intel.com';
        rr6.PRM_Address_Line_2__c = '';
        rr6.PRM_Matching_Contact__c = null;
        rr6.PRM_Country__c = 'IND';
        insert rr6;
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
       test.startTest();
        PRM_CIMCallout cim6 = new PRM_CIMCallout(rr6,0,'3',null,'www.test1.com',true);
        test.stopTest();
        /* cim6.execute(currentContext);
        
    system.assert(rr6.Name != null);*/

    }
    @istest static void testCallout_Error2(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new PRM_MockHttpResponse());
        
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
           
        /*Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';   
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
        

        PRM_Registration_Request__c rr7 = PRM_TestUtility.getPRMRegistrationRequest();
        rr7.PRM_Zip_Postal_Code__c = '5555';
        rr7.PRM_Email_ID__c = 'abcdef@intel.com';
        rr7.PRM_Address_Line_2__c = '';
        rr7.PRM_Matching_Contact__c = null;
        rr7.PRM_Country__c = 'IND';
        insert rr7;
        
        test.startTest();
        PRM_CIMCallout cim7 = new PRM_CIMCallout(rr7,0,'3',null,'www.test1.com',true);
        test.stopTest();
        /*cim7.execute(currentContext);
        
    system.assert(rr7.Name != null);*/

    }
    
       @isTest static void testCalloutFullDup_NoResponse() {
        // Set mock callout class 
        QueueableContext currentContext;
       Test.setMock(HttpCalloutMock.class, new PRM_MockEmptyHttpResponse());
        Account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        //acc1.Core_CIM_ID__c='22213672';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
           
       /* Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact'; 
        c.MailingCountryCode = 'USA';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;*/
           
        PRM_Registration_Request__c rr1 = PRM_TestUtility.getPRMRegistrationRequest();
        rr1.PRM_Zip_Postal_Code__c = '1111';
        rr1.PRM_Email_ID__c = 'abcd@intel.com';          
        insert rr1;
           
        PRM_Registration_Request__c rr2 = PRM_TestUtility.getPRMRegistrationRequest();
        rr2.PRM_Zip_Postal_Code__c = '2222';
        rr2.PRM_Email_ID__c = 'ab@intel.com';
        rr2.PRM_Salesforce_ID__c = acc1.Id; 
        insert rr2;
        PRM_Registration_Request__c rr3 = PRM_TestUtility.getPRMRegistrationRequest();
        rr3.PRM_Zip_Postal_Code__c = '3333';
        rr3.PRM_Email_ID__c = 'a@intel.com';
        insert rr3;
        PRM_Registration_Request__c rr4 = PRM_TestUtility.getPRMRegistrationRequest();
        rr4.PRM_Zip_Postal_Code__c = '9090';
        rr4.PRM_Email_ID__c = 'bcd@intel.com';
        insert rr4;
           
       /* Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);*/
    //soqlObj.soslQuery();
           
       Test.startTest();
        PRM_CIMCallout cim1 = new PRM_CIMCallout(rr1,2,null,null,'www.test1.com',true);
        
        PRM_CIMCallout cim2 = new PRM_CIMCallout(rr2,2,'0',null,null,true);
        
        PRM_CIMCallout cim3 = new PRM_CIMCallout(rr3,2,'2',null,'www.test1.com',true);
        
        PRM_CIMCallout cim4 = new PRM_CIMCallout(rr4,2,null,null,'www.test1.com',true);
        Test.stopTest();
         /*cim1.execute(currentContext);
        cim2.execute(currentContext);
        cim3.execute(currentContext);
        cim4.execute(currentContext);
        
        
        System.assertEquals(rr1.Name,'RR1');*/
        
    }
}