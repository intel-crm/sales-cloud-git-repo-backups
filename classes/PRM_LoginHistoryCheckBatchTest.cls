@istest
Public class PRM_LoginHistoryCheckBatchTest{
    public static testMethod void testschedule() {
     Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'WWW.test123.com';
        acc.Name='attempet';
        insert acc;    
        
        List<Contact> contactList = new List<Contact>();
        Contact con = PRM_TestUtility.getContact();
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.MailingCountryCode = 'USA';
        con.Core_Login_Id__c='abc';
        insert con;
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
      PRM_Registration_Request__c newRequest1 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest1.PRM_CIM_ID__c='';
        newRequest1.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest1.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest1.PRM_Email_ID__c = 'testrequest@mailinator.com';
        newRequest1.PRM_Channel_Program__c = cp.Id;
        newRequest1.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest1.PRM_Partner_Relationship__c = '';
        newRequest1.PRM_Preferred_Language__c = '';
        newRequest1.PRM_Matching_Contact__c = con.Id;
        newRequest1.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest1.PRM_Salesforce_ID__c = acc.Id;
        newRequest1.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest1.PRM_Subscriptions__c = 'PRDSOLCOM;TRAWEBCOM;POINTCOM;EVENTCOM;PARRESCOM;MEMBCOM';
        newRequest1.PRM_Profile_Response__c = 'test pr';
        newRequest1.PRM_EmailVerifiedDateTime__c=system.now();
        newRequest1.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        newRequest1.PRM_User_Login_History__c=true;
        newRequest1.PRM_Status__c='Approved';
        insert newRequest1;
        
        
        Test.StartTest();
        PRM_LoginHistoryCheckScheduler testsche = new PRM_LoginHistoryCheckScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}