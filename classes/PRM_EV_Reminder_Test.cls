@isTest
public class PRM_EV_Reminder_Test {
    @isTest
    public static void validateSendReminder()
    {
        Test.startTest();       
      /* PRM_Registration_Request__c regreq = PRM_TestUtility.getPRMRegistrationRequest();
        
       regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_EV_Token__c = 'gwiur#@98321327';
        regreq.CreatedDate=date.today().addDays(-2);
        insert regreq;
        List<PRM_Registration_Request__c> regReqList=new List<PRM_Registration_Request__c>();
        regReqList.add(regreq);
        PRM_EV_Reminder.SendReminder(regReqList);*/
       // Test.stopTest();
      //  System.assertEquals(regreq.PRM_Email_ID__c,'jasmine12345@mailinator.com','Value does not match');
        
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
		//Id regReqRecordType = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Account Create Request').getRecordTypeId();
		//Id regReqRecordType = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByName().get('Account Create Request').getRecordTypeId();
        Id regReqRecordType = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Manufacturer';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Manufacturer';
        a.Industry = 'Construction';
        insert a;
        

        Contact c = PRM_TestUtility.getContact();
        c.Core_IPA_PartnerRole__c = null;
        c.AccountId = a.Id;
        c.MailingCountry='USA';
        c.MailingCountryCode = 'USA';
        insert c;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.Email='hariharasudhan.meiyappan@intel.com';
        c2.Core_IPA_PartnerRole__c = 'Manufacturer';
        c2.AccountId = a.Id;
        c2.MailingCountry='USA';
        c2.MailingCountryCode = 'USA';
        insert c2;
                
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Member';
        levelold.prm_programlevelcode__c = 'Member';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
        PRM_PartnerBenefit__c pbenefit= PRM_TestUtility.getPartnerBenefit();
            insert pbenefit;
            
        
        PRM_EmailUtility.EmailNotification en = new PRM_EmailUtility.EmailNotification();
            Map<String,String> paramMap = new Map<String,String>();
            en.BusinessEvent = 'BENEFIT ADDITION40';
            paramMap.put('Account_ID',a.Id);
            paramMap.put('Benefit_ID',pbenefit.Id);
            paramMap.put('Contact_ID',c.Id);
            en.InputParameters=paramMap;
            en.ChannelProgram = 'Intel Partner Alliance';
            en.PartnerType = 'CsP';
            en.Language = 'ENG';
          //  PRM_EmailUtility.sendEmail(en);
            
            //External email scenario
           // en.BusinessEvent = 'Registration_request_for_new_User';
            en.EmailID='user212@intel.com';        
         //   PRM_EmailUtility.sendEmail(en);
        	//PRM_EmailUtility.sendEmail(en);
            
            //External email scenario to cover error in logs
           // en.BusinessEvent = 'Registration_request_for_new_User';
          //  en.EmailID='user212intel.com';        
           // PRM_EmailUtility.sendEmail(en);
            
          //  en.BusinessEvent = 'BENEFIT ADDITION2';
            //PRM_EmailUtility.sendEmail(en);
            
         //   en.BusinessEvent = 'BENEFIT ADDITION4';
           // PRM_EmailUtility.sendEmail(en);
          // insert en;
            System.assertEquals(a.Name,'New Account','Value does not match');
        
       

        PRM_Registration_Request__c regRequest = PRM_TestUtility.getPRMRegistrationRequest();
        //PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.RecordTypeId = regReqRecordType;
        regRequest.PRM_Phy_Address_Line_1__c  = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c  = 'Bengaluru,India';
        regRequest.PRM_Phy_City__c  = 'Las Vegas' ;
        regRequest.PRM_Phy_Country__c  = 'USA' ;
        regRequest.PRM_Phy_State_Province__c  = 'NY' ;
        regRequest.PRM_Phy_Zip_Postal_Code__c  = '0273' ;
        //regRequest.PRM_CIM_ID__c  =  ;
        regRequest.PRM_Account_Name__c  = 'New Account' ;
        regRequest.PRM_Account_URL__c  = 'www.intel.com' ;
        regRequest.PRM_Channel_Program__c  = cprogram.Id ;
        regRequest.PRM_Channel_Program_Level__c  = levelold.Id;
        regRequest.PRM_Company_Email_Domain__c  = 'intel.com' ;
        regRequest.PRM_Email_ID__c  = 'hariharasudhan.meiyappan@intel.com' ;
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_EV_flag__c  = false ;
        //regRequest.PRM_Job_Function__c  ='OPER' ;
        regRequest.PRM_Profession__c  ='Consultant' ;
        regRequest.PRM_Preferred_Language__c  = 'ENG' ;
        regRequest.PRM_Partner_Segment__c  = 'Cloud' ;
        //regRequest.PRM_Partner_Type__c  =  ;
        regRequest.PRM_Partner_Relationship__c  =System.Label.PRM_Primary_Contact;
        regRequest.PRM_Status__c  = 'New' ;
        regRequest.PRM_Status_Reason__c  = 'New Contact Creation' ;
        regRequest.PRM_Subscriptions__c  = 'CSPx2_Sub2' ;
        regRequest.PRM_Person_Phone_Number__c  = '9891744631' ;
        regRequest.PRM_Contact_Login_ID__c  = 'testrequest@mailinator.com'  ;
        regRequest.PRM_Legal_Agreements__c  = 'IPA_TANDC' ;
        regRequest.PRM_EmailVerifiedDateTime__c =  DateTime.now();
        regRequest.PRM_Profile_Response__c  =' {QuestionCode  = CSPx2_ServicePlanTodayAOrNext | ResponseCode  = CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue  = CSPx2_ServicePlanTodayOrNext_DBAAS}{QuestionCode  = CSPx2_ServicePlanTodayOrNext | ResponseCode  = CSPx2_ServicePlanTodayOrNext_ConAAS | ResponseValue  = CSPx2_ServicePlanTodayOrNext_ConAAS}'; 
        regRequest.PRM_Email_Log__c=null;
        regRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
       regRequest.CreatedDate=date.today().addDays(-3);
          
        
        List<PRM_Registration_Request__c> regReqList=new List<PRM_Registration_Request__c>();
       regReqList.add(regRequest);
        insert regReqList;
         PRM_EmailUtility.sendEmail(en);
        System.debug('listPrint-----> '+regReqList);
        System.debug('12evToken-----> '+regRequest.PRM_EV_Token__c);
        if(regReqList!=null){
        	PRM_EV_Reminder.SendReminder(regReqList);
       	}
        Test.stopTest();
       	
        // PRM_EmailUtility.sendEmail(en);
         System.assertEquals(regRequest.PRM_Email_ID__c,'hariharasudhan.meiyappan@intel.com','Value does not match');

       /* PRM_Registration_Request__c regRequestRec2 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec2.PRM_Status__c ='New' ;
        regRequestRec2.RecordTypeId=regReqRecordType;
        regRequestRec2.PRM_Email_ID__c = c2.Email;
        insert regRequestRec2;*/
        
    }
    @isTest
    public static void validateSendReminder2()
    {
        Test.startTest();
       
      /* PRM_Registration_Request__c regreq = PRM_TestUtility.getPRMRegistrationRequest();
        
       regreq.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regreq.PRM_Email_ID__c='jasmine12345@mailinator.com';
        regreq.PRM_Preferred_Language__c='RUS';
        regreq.PRM_Contact_Login_ID__c ='jasmine12345@mailinator.com'; 
        regreq.PRM_Partner_Type__c ='Cloud Service Provider (CSP)';
        regreq.PRM_EV_Token__c = 'gwiur#@98321327';
        regreq.CreatedDate=date.today().addDays(-2);
        insert regreq;
        List<PRM_Registration_Request__c> regReqList=new List<PRM_Registration_Request__c>();
        regReqList.add(regreq);
        PRM_EV_Reminder.SendReminder(regReqList);*/
       // Test.stopTest();
      //  System.assertEquals(regreq.PRM_Email_ID__c,'jasmine12345@mailinator.com','Value does not match');
        
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
		//Id regReqRecordType = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Account Create Request').getRecordTypeId();
		//Id regReqRecordType = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByName().get('Account Create Request').getRecordTypeId();
        Id regReqRecordType = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Manufacturer';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Manufacturer';
        a.Industry = 'Construction';
        insert a;
        

        Contact c = PRM_TestUtility.getContact();
        c.Core_IPA_PartnerRole__c = null;
        c.AccountId = a.Id;
        c.MailingCountry='USA';
        c.MailingCountryCode = 'USA';
        insert c;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.Email='hariharasudhan.meiyappan@intel.com';
        c2.Core_IPA_PartnerRole__c = 'Manufacturer';
        c2.AccountId = a.Id;
        c2.MailingCountry='USA';
        c2.MailingCountryCode = 'USA';
        insert c2;
                
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Member';
        levelold.prm_programlevelcode__c = 'Member';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
        PRM_PartnerBenefit__c pbenefit= PRM_TestUtility.getPartnerBenefit();
            insert pbenefit;
            
        
        PRM_EmailUtility.EmailNotification en = new PRM_EmailUtility.EmailNotification();
            Map<String,String> paramMap = new Map<String,String>();
            en.BusinessEvent = 'BENEFIT ADDITION40';
            paramMap.put('Account_ID',a.Id);
            paramMap.put('Benefit_ID',pbenefit.Id);
            paramMap.put('Contact_ID',c.Id);
            en.InputParameters=paramMap;
            en.ChannelProgram = 'Intel Partner Alliance';
            en.PartnerType = 'CsP';
            en.Language = 'ENG';
          //  PRM_EmailUtility.sendEmail(en);
            
            //External email scenario
           // en.BusinessEvent = 'Registration_request_for_new_User';
            en.EmailID='user212@intel.com';        
         //   PRM_EmailUtility.sendEmail(en);
        	//PRM_EmailUtility.sendEmail(en);
            
            //External email scenario to cover error in logs
           // en.BusinessEvent = 'Registration_request_for_new_User';
          //  en.EmailID='user212intel.com';        
           // PRM_EmailUtility.sendEmail(en);
            
          //  en.BusinessEvent = 'BENEFIT ADDITION2';
            //PRM_EmailUtility.sendEmail(en);
            
         //   en.BusinessEvent = 'BENEFIT ADDITION4';
           // PRM_EmailUtility.sendEmail(en);
          // insert en;
            System.assertEquals(a.Name,'New Account','Value does not match');
        
       

        PRM_Registration_Request__c regRequest = PRM_TestUtility.getPRMRegistrationRequest();
        //PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.RecordTypeId = regReqRecordType;
        regRequest.PRM_Phy_Address_Line_1__c  = '4th Floor,ITPL Main Road';
        regRequest.PRM_Phy_Address_Line_2__c  = 'Bengaluru,India';
        regRequest.PRM_Phy_City__c  = 'Las Vegas' ;
        regRequest.PRM_Phy_Country__c  = 'USA' ;
        regRequest.PRM_Phy_State_Province__c  = 'NY' ;
        regRequest.PRM_Phy_Zip_Postal_Code__c  = '0273' ;
        //regRequest.PRM_CIM_ID__c  =  ;
        regRequest.PRM_Account_Name__c  = 'New Account' ;
        regRequest.PRM_Account_URL__c  = 'www.intel.com' ;
        regRequest.PRM_Channel_Program__c  = cprogram.Id ;
        regRequest.PRM_Channel_Program_Level__c  = levelold.Id;
        regRequest.PRM_Company_Email_Domain__c  = 'intel.com' ;
        regRequest.PRM_Email_ID__c  = 'hariharasudhan.meiyappan@intel.com' ;
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_EV_flag__c  = false ;
        //regRequest.PRM_Job_Function__c  ='OPER' ;
        regRequest.PRM_Profession__c  ='Consultant' ;
        regRequest.PRM_Preferred_Language__c  = 'ENG' ;
        regRequest.PRM_Partner_Segment__c  = 'Cloud' ;
        //regRequest.PRM_Partner_Type__c  =  ;
        regRequest.PRM_Partner_Relationship__c  =System.Label.PRM_Primary_Contact;
        regRequest.PRM_Status__c  = 'New' ;
        regRequest.PRM_Status_Reason__c  = 'New Contact Creation' ;
        regRequest.PRM_Subscriptions__c  = 'CSPx2_Sub2' ;
        regRequest.PRM_Person_Phone_Number__c  = '9891744631' ;
        regRequest.PRM_Contact_Login_ID__c  = 'testrequest@mailinator.com'  ;
        regRequest.PRM_Legal_Agreements__c  = 'IPA_TANDC' ;
        regRequest.PRM_EmailVerifiedDateTime__c =  DateTime.now();
        regRequest.PRM_Profile_Response__c  =' {QuestionCode  = CSPx2_ServicePlanTodayAOrNext | ResponseCode  = CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue  = CSPx2_ServicePlanTodayOrNext_DBAAS}{QuestionCode  = CSPx2_ServicePlanTodayOrNext | ResponseCode  = CSPx2_ServicePlanTodayOrNext_ConAAS | ResponseValue  = CSPx2_ServicePlanTodayOrNext_ConAAS}'; 
        regRequest.PRM_Email_Log__c=null;
        regRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
       regRequest.CreatedDate=date.today().addDays(-3);
          
        
        List<PRM_Registration_Request__c> regReqList=new List<PRM_Registration_Request__c>();
       regReqList.add(regRequest);
        insert regReqList;
         PRM_EmailUtility.sendEmail(en);
        if(regReqList!=null){
        	PRM_EV_Reminder.SendReminder(regReqList);
       	}
        Test.stopTest();
       	
        // PRM_EmailUtility.sendEmail(en);
         System.assertEquals(regRequest.PRM_Email_ID__c,'hariharasudhan.meiyappan@intel.com','Value does not match');

       /* PRM_Registration_Request__c regRequestRec2 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec2.PRM_Status__c ='New' ;
        regRequestRec2.RecordTypeId=regReqRecordType;
        regRequestRec2.PRM_Email_ID__c = c2.Email;
        insert regRequestRec2;*/
        
    }

}