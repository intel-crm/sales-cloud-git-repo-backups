@isTest
public class ER_DupCheck_CIMCallout_Test {
    
    @isTest static void testCalloutFullDup() {
        // Set mock callout class 
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new ER_MockCIMHttpResponse());
        Account acc1 = getAccount();
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,ITPL,Brookfield';
        acc1.BillingPostalCode='560037';
        acc1.Industry = '';
        acc1.Core_CIM_ID__c='10100006';
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc1;
        
        Account acc2 = getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
        
        Contact c = getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';
        c.MailingCountry='India';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        PRM_Registration_Request__c rr1 = getPRMRegistrationRequest();
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
        
        ER_DupCheck_CIMCallout cim1 = new ER_DupCheck_CIMCallout(rr1,0,null,null,'www.test1.com',true);
        cim1.execute(currentContext);
        Test.stopTest();
        System.assertEquals(rr1.Name,'RR1');
        
    }
    
    @isTest static void testCalloutPartDup(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new ER_MockCIMHttpResponse());
        Account acc1 = getAccount();
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
        
        Account acc2 = getAccount();
        acc2.name= 'test';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='5th Floor,ITPL,Brookfield';
        acc2.BillingPostalCode='5600378';       
        acc2.Industry = '';
        acc1.Core_CIM_ID__c='22213672';
        //acc2.Core_CIM_ID__c='10100006';
        acc2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        insert acc2;
        
        Contact c = getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';
        c.MailingCountry='India';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        
        PRM_Registration_Request__c rr4 = getPRMRegistrationRequest();
        rr4.PRM_Zip_Postal_Code__c = '9999';
        rr4.PRM_Email_ID__c = 'bcd@intel.com';
        rr4.PRM_Address_Line_2__c = '';
        rr4.PRM_Salesforce_ID__c =  acc1.Id;
        insert rr4;
        
        Test.startTest();
        ER_DupCheck_CIMCallout cim4 = new ER_DupCheck_CIMCallout(rr4,0,null,null,null,true);
        cim4.execute(currentContext);
        Test.stopTest();
        system.assert(rr4.Name != null);
    }
    
    @isTest static void testCalloutError1(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new ER_MockCIMHttpResponse());
        Account acc1 = getAccount();
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
        
        Account acc2 = getAccount();
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
        
        Contact c = getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';
        c.MailingCountry='India';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        
        PRM_Registration_Request__c rr3 = getPRMRegistrationRequest();
        rr3.PRM_Zip_Postal_Code__c = '3333';
        rr3.PRM_Email_ID__c = 'a@intel.com';
        insert rr3;
        
        Test.startTest();
        ER_DupCheck_CIMCallout cim3 = new ER_DupCheck_CIMCallout(rr3,0,null,null,'www.test1.com',true);
        cim3.execute(currentContext);
        Test.stopTest();
        system.assert(rr3.Name != null);
    }
    
    
    @isTest static void testCalloutNoDup(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new ER_MockCIMHttpResponse());
        Account acc1 = getAccount();
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
        
        Account acc2 = getAccount();
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
        
        Contact c = getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';
        c.MailingCountry='India';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        
        PRM_Registration_Request__c rr3 = getPRMRegistrationRequest();
        rr3.PRM_Zip_Postal_Code__c = '2222';
        rr3.PRM_Email_ID__c = 'a@intel.com';
        insert rr3;
        
        Test.startTest();
        ER_DupCheck_CIMCallout cim3 = new ER_DupCheck_CIMCallout(rr3,0,null,null,'www.test1.com',true);
        cim3.execute(currentContext);
        Test.stopTest();
        system.assert(rr3.Name != null);
    }
    
    @isTest static void testCalloutError2(){
        QueueableContext currentContext;
        Test.setMock(HttpCalloutMock.class, new ER_MockCIMHttpResponse());
        Account acc1 = getAccount();
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
        
        Account acc2 = getAccount();
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
        
        Contact c = getContact();
        c.AccountId = acc1.Id;
        c.Email='abc@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.FirstName='test';
        c.LastName='Contact';
        c.MailingCountry='India';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        insert c;
        
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= c.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        
        PRM_Registration_Request__c rr3 = getPRMRegistrationRequest();
        rr3.PRM_Zip_Postal_Code__c = '5555';
        rr3.PRM_Email_ID__c = 'a@intel.com';
        insert rr3;
        
        Test.startTest();
        ER_DupCheck_CIMCallout cim3 = new ER_DupCheck_CIMCallout(rr3,0,null,null,'www.test1.com',true);
        cim3.execute(currentContext);
        Test.stopTest();
        system.assert(rr3.Name != null);
    }
    
    public static Account getAccount(){
        Account a = new Account();
        a.Name='Intel';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        //a.Company_Domain__c='intel.com';
        return a;
    }
    
    /*Method to get 'Registration Request' object*/
    public static PRM_Registration_Request__c getPRMRegistrationRequest(){
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Account_Name__c='Intel';
        regRequest.PRM_Company_Email_Domain__c='intel.com';
        regRequest.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        regRequest.PRM_Address_Line_2__c='Bengaluru,India'; 
        regRequest.PRM_City__c='Las Vegas';
        regRequest.PRM_State_Province__c='NY';
        regRequest.PRM_Country__c='USA';
        return regRequest;
    }
    
    /*Method to get 'Contact' object */
    public static Contact getContact(){
        Contact con = new Contact();
        con.FirstName='Matt';
        con.LastName='Smith';
        con.Email='testrequest@mailinator.com';
        con.Phone='9999779791';
        return con;
    } 
    
}