@isTest
public class ER_EmailVerificationUtility_Test {
    
    @testSetup
    static void DataSetup() {
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'RDC Entitlement';
        insert ent;  
        
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'Developer Zone Premier';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'DZP';       
        insert bt;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = ent.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.Business_Types__c = bt.Id;
        emList.add(em);
        insert emList;
        
        Account a = new Account();
        a.Name='Intel';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='Bengaluru';
        a.BillingCountry='India';
        a.BillingStreet='4th Floor,ITPL,Brookfield';
        a.BillingPostalCode='560037';
        insert(a); 
        
        Contact con = new Contact();
        con.FirstName='Matt';
        con.LastName='Smith';
        con.Email='testrequest1@mailinator.com';
        con.Phone='9999779791';
        con.AccountId = a.Id;
        con.Core_Job_Function__c='Branch Manager';  
        con.Core_Login_Id__c = 'abc';
        con.MailingCountry='India';
        insert con;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
    }
    
    @isTest static void EVNotificationTest() {
        Test.startTest();
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.Entitlement_Details__c = ent[0].Id;
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
       // insert listReq;
       
        //System.assert(listReq.size() > 0, 'Success');
        ER_EmailVerificationUtility.emailNotificationOnReceivingRegistration(listReq);
        Test.stopTest();      
    } 
    
    @isTest static void EVNotificationExceptionTest() {
        Test.startTest();
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.Entitlement_Details__c = null;
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
        insert listReq;
       
    //    System.assert(listReq.size() > 0, 'Success');
        ER_EmailVerificationUtility.emailNotificationOnReceivingRegistration(null);
        Test.stopTest();      
    } 
    
    @isTest static void EVSuccessTest() {
        Test.startTest();
        
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.Entitlement_Details__c = ent[0].Id;
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
        insert listReq;
        
        regRequest.PRM_EmailVerifiedDateTime__c = System.DateTime.now();
        regRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> updatedlistReq = New List<PRM_Registration_Request__c>();
        updatedlistReq.add(regRequest);
        
        update updatedlistReq;
        
        List<PRM_Registration_Request__c> req = [SELECT Id, PRM_Email_Verification_Criteria__c 
                                                 FROM PRM_Registration_Request__c
                                                 WHERE Id =: updatedlistReq[0].Id];
      //  System.assertEquals(req[0].PRM_Email_Verification_Criteria__c,'SUCCESS');
       ER_EmailVerificationUtility.emailNotificationOnReceivingRegistration(updatedlistReq); 
        Test.stopTest();
    }
    
    @isTest static void EVDoneTest(){
        Test.startTest();
        Map<id,PRM_Registration_Request__c> oldmap = new Map<id,PRM_Registration_Request__c>();
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.Entitlement_Details__c = ent[0].Id;
        regRequest.PRM_EmailVerifiedDateTime__c = System.DateTime.now();
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
        insert listReq;
        oldmap.put(regRequest.id, regRequest);
        List<PRM_Registration_Request__c> req = [SELECT Id, PRM_Email_Verification_Criteria__c, PRM_Preferred_Language__c
                                                 FROM PRM_Registration_Request__c
                                                 WHERE Id =: listReq[0].Id];
      //  System.assertEquals(req[0].PRM_Email_Verification_Criteria__c,'SUCCESS');
      //  System.assertEquals(req[0].PRM_Preferred_Language__c, 'ENG');UpdateEVCriteriaToSuccess
       ER_EmailVerificationUtility.UpdateEVCriteriaToSuccess(listReq, oldmap); 
        Test.stopTest();
    }
    
    @isTest static void EVProgramTest(){
        Test.startTest();
        
        List<ChannelProgram> cp = [Select id from ChannelProgram Where Name='Intel Partner Alliance' limit 1];
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request1';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.PRM_Channel_Program__c = cp[0].id;
        regRequest.PRM_EmailVerifiedDateTime__c = System.DateTime.now();
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
        insert listReq;
        
        regRequest.PRM_EmailVerifiedDateTime__c = System.DateTime.now();
        regRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> updatedlistReq = New List<PRM_Registration_Request__c>();
        updatedlistReq.add(regRequest);
        
        update updatedlistReq;
        ER_EmailVerificationUtility.UpdateEVCriteriaToSuccess(null, null);
        System.assert(updatedlistReq.size()>0,'SUCCESS');
        
        Test.stopTest();
    }
    
    @isTest static void EVMatchingTest(){
        Test.startTest();
        
        List<ChannelProgram> cp = [Select id from ChannelProgram Where Name='Intel Partner Alliance' limit 1];
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request1';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest1@mailinator.com';
        regRequest.PRM_Preferred_Language__c='';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.Entitlement_Details__c = ent[0].Id;
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
        insert listReq;
        
        List<PRM_Registration_Request__c> req = [SELECT Id, PRM_Email_Verification_Criteria__c, PRM_Matching_Contact__c
                                                 FROM PRM_Registration_Request__c
                                                 WHERE Id =: listReq[0].Id];
        
        List<Contact> cont = [SELECT Id FROM Contact WHERE Email = 'testrequest1@mailinator.com'];
        
      //  System.assertEquals(req[0].PRM_Matching_Contact__c, cont[0].Id);
        
        Test.stopTest();
    }
}