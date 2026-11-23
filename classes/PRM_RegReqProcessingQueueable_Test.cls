@isTest
private class PRM_RegReqProcessingQueueable_Test {
	static @isTest void checkRegReqProcessingQueueable() {
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);  
        
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        
        Contact con = PRM_TestUtility.getContact();
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        insert con;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='New Partner Program';
        cprogram.PRM_programCode__c='NPP';
        insert(cprogram);
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        PRM_PartnerAgreement__c pa = PRM_TestUtility.getPartnerAgreement();
        pa.PRM_Channel_Program_Id__c = cp.Id;
        insert pa;
        
        PRM_PartnerAgreement__c pa1 = PRM_TestUtility.getPartnerAgreement();
        pa1.PRM_Channel_Program_Id__c = cp.Id;
        pa1.Name='CSP_ACK_EMEA_ENG';
        pa1.PRM_Language_Codes__c='ENG';
        pa1.PRM_Agreement_Cd__c='CSP_ACK_EMEA_ENG';
        insert pa1;
                
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cprogram.Id;
        membership.PRM_Account_Id__c=acc.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Seller';
        insert(membership);  
        
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuser@gmail.com';
        newRequest.PRM_Channel_Program__c = cp.Id;
        newRequest.PRM_Legal_Agreements__c = 'CSP_ACK_EMEA_ENG';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Matching_Contact__c = con.Id;
        insert(newRequest);
        
        PRM_Registration_Request__c newAdminRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newAdminRequest.PRM_Partner_Role__c='Service Provider';
        newAdminRequest.PRM_CIM_ID__c='CIM1234';
        newAdminRequest.PRM_Salesforce_ID__c=acc.Id;
        newAdminRequest.PRM_Email_Verification_Criteria__c = 'PENDING';
        newAdminRequest.PRM_Legal_Agreements__c = 'CSP_ACK_EMEA_ENG';
        newAdminRequest.PRM_Subscriptions__c = 'CSPx2_Sub2';
        newAdminRequest.PRM_Status__c='New';
        newAdminRequest.PRM_Channel_Program__c = cp.Id;
        newAdminRequest.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        newAdminRequest.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_AIAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_AIAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_FnAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_FnAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext_Others | ResponseCode : CSPx2_ServicePlanTodayOrNext_Others | ResponseValue : TESTING}';
        insert(newAdminRequest);
                
        
        Test.startTest();
        System.enqueueJob( new PRM_RegReqProcessingQueueable(accountList,contactList,True,True,'businessEvent',newAdminRequest));
        System.enqueueJob( new PRM_RegReqProcessingQueueable(accountList,contactList,True,False,'businessEvent',newAdminRequest));
        System.enqueueJob( new PRM_RegReqProcessingQueueable(accountList,contactList,False,True,'businessEvent',newAdminRequest));
        System.enqueueJob( new PRM_RegReqProcessingQueueable(accountList,contactList,False,False,'businessEvent',newAdminRequest));
        Test.stopTest();
    }
}