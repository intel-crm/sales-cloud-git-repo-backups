@isTest()
public class PRM_Retrigger_Emaillog_Test {
    static testMethod void testSendEmail2(){
         List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
          Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.RecordTypeId = recordTypeIdAccount;
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
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Ebert';
        cont1.FirstName='Adam';
        cont1.email='we233ffg@mailinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.MailingCountryCode = 'IND';
        cont1.Core_Do_Not_Contact__c = false; 
        cont1.Core_Enterprise_Id__c = '300000551648';
        cont1.Core_Preferred_Language__c = 'ENG';
        insert cont1;
        
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
        
      /*  PRM_Registration_Request__c regRequestRec = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec.PRM_Status__c ='New' ;
      //  regRequestRec.PRM_Record_Type_Name_rpt_txt__c ='Account Create Request';
        regRequestRec.PRM_Email_ID__c = c.Email;
        insert regRequestRec;*/
       PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = testAccount.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Guest';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        approvedAcm.PRM_Status_Reason_Txt__c='Test00';
        insert approvedAcm;
        
        ChannelProgram cp = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        contRelation.PRM_InActive_Ind__c = false;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=testAccount.Id;
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Contact_Id__c=cont1.Id;
        acr.PRM_Status_Nm__c = System.label.Pending_Action  ;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr;
        
        Campaign campg = new Campaign();
        campg.Name = 'Test Campaign';
        campg.IsActive = true;
        campg.Type = 'Other';
        campg.Status = 'Palnned';
        campg.Core_Target_Geo__c = 'ASMO';
        campg.PRM_Bulk_Add_Invite_Email_Template__c = 'CampaignInviteForBulk';
        insert campg;
        

        
        
        PRM_EmailLog__c emaillog1 = new PRM_EmailLog__c();
        emaillog1.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog1.PRM_ToEmailID__c='we233ffg@mailinator.com';
        emaillog1.PRM_EmailContent__c='htmlbodyvar=EVVV256012UjVvhkwf826270target=wcm-ciqa.com';
        emaillog1.PRM_Contact__c=cont1.id;
        emaillog1.Language__c='ENG';
        emaillog1.Email_Template_Name__c ='ADMINREG';
        
        OrgWideEmailAddress owa = new OrgWideEmailAddress ();    
        owa.Address = 'PMP_Intel_partner_Alliance_Address';
        //insert owa;
        try{   
            //insert emaillog1;            
            //PRM_Retrigger_Emaillog_Utility.sendMail(true, emaillog1.id);
            PRM_Retrigger_Emaillog_Utility.sendMail(false, emaillog1.id);
         }catch(Exception ex){
            //System.debug(ex.getMessage());
        }
    }
    static testMethod void testSendEmail(){
         List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
         Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.RecordTypeId = recordTypeIdAccount;
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
        
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Ebert';
        cont.FirstName='Adam';
        cont.email='ebert123@mailinator.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountryCode = 'IND';
        cont.Core_Do_Not_Contact__c = false;
        cont.Core_IPA_Email_Verification_Date__c =System.today();
        cont.Core_Enterprise_Id__c = '300000551648';
        cont.Core_Preferred_Language__c = 'ENG';
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Ebert';
        cont1.FirstName='Adam';
        cont1.email='we233ffg@mailinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.MailingCountry='USA';
        cont1.Core_Do_Not_Contact__c = false;  
        cont1.Core_Enterprise_Id__c = '300000551644';
        cont1.Core_Preferred_Language__c = 'ENG';
        insert cont1;
        
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
        
         PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = testAccount.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Guest';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        approvedAcm.PRM_Status_Reason_Txt__c='Test01';
        insert approvedAcm;
        ChannelProgram cp = [Select Id,name,PRM_programCode__c from ChannelProgram where name='Intel Partner Alliance' Limit 1];
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        contRelation.PRM_InActive_Ind__c = false;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=testAccount.Id;
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Contact_Id__c=cont1.Id;
        acr.PRM_Status_Nm__c = System.label.Pending_Action  ;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr;
        
       
        
        Campaign campg = new Campaign();
        campg.Name = 'Test Campaign';
        campg.IsActive = true;
        campg.Type = 'Other';
        campg.Status = 'Palnned';
        campg.Core_Target_Geo__c = 'ASMO';
        campg.PRM_Bulk_Add_Invite_Email_Template__c = 'CampaignInviteForBulk';
        insert campg;
        

        
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
        emaillog.PRM_EmailContent__c='htmlbodyvar=EVVV256012UjVvhkwf826270target=wcm-ciqa.com';
        emaillog.PRM_Contact__c=cont.id;
        emaillog.Language__c='ENG';
        emaillog.Email_Template_Name__c ='SCRUACCTADD';
        insert emaillog;
        
        PRM_EmailLog__c emaillog1 = new PRM_EmailLog__c();
        emaillog1.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog1.PRM_ToEmailID__c='we233ffg@mailinator.com';
        emaillog1.PRM_EmailContent__c='htmlbodyvar=EVVV256012UjVvhkwf826270target=wcm-ciqa.com';
        emaillog1.PRM_Contact__c=cont1.id;
        emaillog1.Language__c='ENG';
        emaillog1.Email_Template_Name__c ='ADMINREG';
        insert emaillog1;
        
        
        try{            
            PRM_Retrigger_Emaillog_Utility.sendMail(true, emaillog.id);
            system.assert(emaillog.Id != null);
            PRM_Retrigger_Emaillog_Utility.sendMail(true, emaillog1.id);
            PRM_Retrigger_Emaillog_Utility.sendMail(false, emaillog.id);
        }catch(Exception ex){
            //System.debug(ex.getMessage());
        }
    }
    
    //method to test retrigger logic for MP emails
    static testMethod void testReSendEmailForOffering(){
        
        // creating offering instance using utility methods        
        //PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('TestOffering', 'Public Content','Offering Description',null,false,'draft','TaglineTest');
        //insert offering;
        
        //creating email log records
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c = 'Submitted: Your Testoffering Offering';
        emaillog.PRM_User__c = UserInfo.getUserId();
        //emaillog.PMP_Partner_Offering__c = offering.id;
        emaillog.Language__c = 'ENG';
        emaillog.Email_Template_Name__c = 'PMP OfferingSubmittedNotification';
        emaillog.PRM_ToEmailID__c = 'we233ffg@mailinator.com';
        //insert emaillog;
        
        test.startTest();
        try{            
            PRM_Retrigger_Emaillog_Utility.sendMail(true, emaillog.id);
            system.assert(emaillog.Id != null);
        }catch(Exception ex){
            //System.debug(ex.getMessage());
        }
        test.stopTest();
    }
    
    static testMethod void testSendEmailCidaasFalse(){
        
         List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
          Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account(); //Account
        testAccount.RecordTypeId = recordTypeIdAccount;
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
         
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Ebert';
        cont1.FirstName='Adam';
        cont1.email='we233ffg@mailinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.MailingCountry='USA';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Do_Not_Contact__c = false;   
       // cont1.Core_IPA_Email_Verification_Date__c = system.today();
        insert cont1;
        
       /* ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=testAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=cont1.Id;
        acr.PRM_Status_Nm__c = System.label.Pending_Action  ;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr;*/
        
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
        
         PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = testAccount.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Guest';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        approvedAcm.PRM_Status_Reason_Txt__c='Tes02';
        insert approvedAcm;
        
        Campaign campg = new Campaign();
        campg.Name = 'Test Campaign';
        campg.IsActive = true;
        campg.Type = 'Other';
        campg.Status = 'Palnned';
        campg.Core_Target_Geo__c = 'ASMO';
        campg.PRM_Bulk_Add_Invite_Email_Template__c = 'CampaignInviteForBulk';
        insert campg;
        
        PRM_EmailLog__c emaillog1 = new PRM_EmailLog__c();
        emaillog1.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog1.PRM_ToEmailID__c='we233ffg@mailinator.com';
        emaillog1.PRM_EmailContent__c='htmlbodyvar=EVVV256012UjVvhkwf826270&target=wcm-ciqa.com';
        emaillog1.PRM_Contact__c=cont1.id;
        emaillog1.Language__c='ENG';
        emaillog1.Email_Template_Name__c ='ADMINREG_English';
        
        String emailHTMLContent = emaillog1.PRM_EmailHTMLContent__c != null ? emaillog1.PRM_EmailHTMLContent__c : emaillog1.PRM_EmailContent__c;
        String AfterString=emailHTMLContent.substringAfter(System.Label.PRM_EV_TOKEN_Start_String);
        String newEVToken; 
        String OldToken;
        OldToken = AfterString.substringBefore(System.Label.PRM_EV_TOKEN_End_String);
        newEVToken = OldToken;
        system.debug('OldToken-->'+OldToken);
        system.debug('newEVToken-->'+newEVToken);
        
        
        
       
             
            insert emaillog1;
            List<PRM_EmailLog__c> logList = new List<PRM_EmailLog__c>();
            logList.add(emaillog1);
            PRM_Retrigger_Emaillog_Utility.sendMail(true, emaillog1.id);
            Messaging.SingleEmailMessage emailMsg = PRM_Retrigger_Emaillog_Utility.createEmailInstances(emaillog1.Email_Template_Name__c, cont1.id,testAccount.Id);
            
            EmailTemplate template = [SELECT Id,Name,
                                        Subject,
                                        Body 
                                        FROM EmailTemplate 
                                        WHERE Name = 'ADMINREG_English'];
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            
            
            emailMsg.setSubject('Test Subject');
            emailMsg.setPlainTextBody('This is a test email');
            emailMsg.setToAddresses(new String[] { 'test@example.com' });
            emailMsg.setWhatId(testAccount.Id);
            emailMsg.setTargetObjectId(cont1.id);//user or contact id
            emailMsg.setTemplateId(template.Id);
            emailMsg.setSaveAsActivity(false);
            emailMsg.setHtmlBody('Email Body content for TestClass');
            
            Messaging.SingleEmailMessage[] messages ;
            Messaging.SendEmailResult[] results ;
            messages = new List<Messaging.SingleEmailMessage> {emailMsg};
            results = Messaging.sendEmail(messages);
        
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{emailMsg};
            List<PRM_EmailLog__c> result = PRM_Retrigger_Emaillog_Utility.createRetriggerEmailLogs(emails,logList,emaillog1.Email_Template_Name__c,emaillog1.Language__c);
        
    }
    
     static testMethod void testSendEmailCidaasFalseTwo(){
        
         List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
          Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account(); //Account
          testAccount.RecordTypeId = recordTypeIdAccount;
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
        
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Ebert';
        cont1.FirstName='Adam';
        cont1.email='we233ffg@mailinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.MailingCountry='USA';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Do_Not_Contact__c = false;   
        cont1.Core_IPA_Email_Verification_Date__c = system.today();
        insert cont1;
        
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
        
         PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = testAccount.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Guest';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        approvedAcm.PRM_Status_Reason_Txt__c='Test03';
        insert approvedAcm;
        
        Campaign campg = new Campaign();
        campg.Name = 'Test Campaign';
        campg.IsActive = true;
        campg.Type = 'Other';
        campg.Status = 'Palnned';
        campg.Core_Target_Geo__c = 'ASMO';
        campg.PRM_Bulk_Add_Invite_Email_Template__c = 'CampaignInviteForBulk';
        insert campg;
        

        
        PRM_EmailLog__c emaillog1 = new PRM_EmailLog__c();
        emaillog1.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog1.PRM_ToEmailID__c='we233ffg@mailinator.com';
        emaillog1.PRM_EmailContent__c='htmlbodyvar=EVVV256012UjVvhkwf826270target=wcm-ciqa.com';
        emaillog1.PRM_Contact__c=cont1.id;
        emaillog1.Language__c='ENG';
        emaillog1.Email_Template_Name__c ='ADMINREG';
       
        try{      
            insert emaillog1;            
            PRM_Retrigger_Emaillog_Utility.sendMail(true, emaillog1.id);
        }catch(Exception ex){
            //System.debug(ex.getMessage());
        }
    }
}