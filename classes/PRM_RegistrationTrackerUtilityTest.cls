@isTest
private class PRM_RegistrationTrackerUtilityTest{

 @isTest static void getprofileTest(){
    set<string> conemail=new set<string>();
    conemail.add('testrequest@maildrop.cc');
    list<PRM_Registration_Request__c> reglistt=new list<PRM_Registration_Request__c>();
    list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
    List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
     ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
     channelPrograms.add(cp);
     insert channelPrograms;
    PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
     	newRegistrationRequest11.PRM_Channel_Program__c=cp.Id;
        insert newRegistrationRequest11;
        reglistt.add(newRegistrationRequest11);
         PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_Registration__c=newRegistrationRequest11.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1;       
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_Registration__c=newRegistrationRequest11.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Current_Step__c=2;       
        tracklsi.add(trac2);
        
         PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_Registration__c=newRegistrationRequest11.Id;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Current_Step__c=3;       
        tracklsi.add(trac3);

     
     	/*PRM_Registration_Tracker__c trac4=new PRM_Registration_Tracker__c();
        trac4.Stage__c='53';
        trac4.PRM_Registration__c=newRegistrationRequest11.Id;
        trac4.PRM_Step_Number__c=53;
        trac4.PRM_Current_Step__c=53;       
        tracklsi.add(trac4);*/
        insert tracklsi;
     
     	
     
        Test.startTest();
   //  PRM_RegistrationTrackerUtility.IS_CIDAAS_ENABLED = false;

    PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(conemail,null,'PRM_Account_Contact_Profiles');
   	//PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(conemail,null,'PRM_CIMCallout');
    getlogentries l=new getlogentries();
    PRM_RegistrationTrackerUtility.CheckUserLoginHistory(reglistt);
       Test.stopTest(); 
    
    }
    
    @isTest static void regTrackerTest(){
    set<string> conemail=new set<string>();
    conemail.add('testrequest@maildrop.cc');
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas222';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount.BillingPostalCode='123456';
        newAccount.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount.Core_IPA_Partner_Role__c='Guest';
        newAccount.Core_IPA_Badge_Tier__c='Partner';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
       // newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount.Core_User_Defined_Website__c = 'abz.yz';
        newAccount.Core_Geo__c = 'ASMO';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount;
        
    list<PRM_Registration_Request__c> reglistt=new list<PRM_Registration_Request__c>();
    list<PRM_Registration_Tracker__c> tracklsi=new list<PRM_Registration_Tracker__c>();
    PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Status__c = 'New';
        newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest11.PRM_Email_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest11.PRM_Country__c = 'US';
        newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
        insert newRegistrationRequest11;
        reglistt.add(newRegistrationRequest11);
        PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
        trac.Stage__c='1';
        trac.PRM_Registration__c=newRegistrationRequest11.Id;
        trac.PRM_Step_Number__c=1;
        trac.PRM_Current_Step__c=1;  
        trac.PRM_Account__c = newAccount.Id;
        tracklsi.add(trac);
        PRM_Registration_Tracker__c trac2=new PRM_Registration_Tracker__c();
        trac2.Stage__c='2';
        trac2.PRM_Registration__c=newRegistrationRequest11.Id;
        trac2.PRM_Step_Number__c=2;
        trac2.PRM_Current_Step__c=2; 
        trac2.PRM_Account__c = newAccount.Id;
        tracklsi.add(trac2);
        
         PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_Registration__c=newRegistrationRequest11.Id;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Current_Step__c=3; 
        trac3.PRM_Account__c = newAccount.Id;
        tracklsi.add(trac3);
        insert tracklsi;
        
        Test.startTest();
    PRM_RegistrationTrackerUtility.getTrackers(newRegistrationRequest11.Id);
    
       Test.stopTest(); 
    
    }
    
    @isTest static void regTrackerTest1(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas222';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount.BillingPostalCode='123456';
        newAccount.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount.Core_IPA_Partner_Role__c='Guest';
        newAccount.Core_IPA_Badge_Tier__c='Partner';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount.Core_User_Defined_Website__c = 'abz.yz';
        newAccount.Core_Geo__c = 'ASMO';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount;
        
        Set<String> contatIds = new Set<String>();
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry='India';
        insert cont;
        contatIds.add(cont.Id);
        
        Contact con2 = new Contact();
        con2.FirstName='Ivory';
        con2.LastName='Smithy';
        con2.Email='testivorysmithy@mailinator.com';
        con2.Phone='9999779791';
        con2.AccountId = newAccount.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_Login_Id__c = 'tuv';
         con2.MailingCountry='India';
        insert con2;
        contatIds.add(con2.Id);
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Partner Admin';
        contRel.PRM_Contact_Relationship_Cd__c = 'PRIMARY';
        insert contRel;
        
         PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = newAccount.Id;
        acr.PRM_Contact_Id__c = cont.Id;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_InActive_Ind__c = False;
        acr.PRM_Status_Reason_Txt__c = 'Test';
        insert acr; 
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_EmailVerifiedDateTime__c=System.Today();
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
        regRequest.PRM_Country__c='US';
        regRequest.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regRequest.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        regRequest.PRM_Status__c = 'New';
        regRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest.PRM_Profile_Response__c = 'test pr'; 
        insert regRequest;
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_contact__c = cont.Id;
        trac3.PRM_Log_Entries__c = '';
        trac3.PRM_Email__c = 'soql.selfcontx@mail.com';
        trac3.Stage__c = '6';
        trac3.createddate = System.now();
        trac3.PRM_AGD_ID_Updated__c = System.today().addDays(1);
        trac3.PRM_Registration_Type__c = 'Self Registration';
        trac3.PRM_Account__c = newAccount.Id;
        trac3.PRM_Registration__c=null;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Current_Step__c=3;       
        insert trac3;
        
       PRM_Registration_Tracker_Steps__mdt stepsMetadata = [
            SELECT Id, MasterLabel, PRM_Current_Step__c, PRM_Display_Step_No__c, PRM_Revise__c, PRM_Update_field__c
            FROM PRM_Registration_Tracker_Steps__mdt WHERE PRM_Current_Step__c='1'
        ];
        
        PRM_RegistrationTrackerUtility.RegistrationWrapper wrap = new PRM_RegistrationTrackerUtility.RegistrationWrapper();
        wrap.registration = regRequest;
        Set<String> emailIds = new Set<String>{'testrequest@mailinator.com'};
        wrap.cont = cont;
		String intelog;  
		Set<String> recIds = new Set<String>{};
        Set<String> emailValues = new Set<String>{cont.email};
                
        Test.startTest();
        Set<String> result = PRM_RegistrationTrackerUtility.checkforEVMailforAdmin(new Set<String>{cont.Id});
        PRM_Registration_Tracker__c tracker = PRM_RegistrationTrackerUtility.createRegTrackerInstance(wrap, regRequest, cont, 'Self', stepsMetadata);
        PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable queueableJob = new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable(new List<PRM_Registration_Request__c>{regRequest}, new Set<String>{cont.Id}, false, false);
        System.enqueueJob(queueableJob);
        //PRM_RegistrationTrackerUtility.executeMethod(new List<PRM_Registration_Request__c>{regRequest}, new Set<String>{cont.Id}, false, false);
        PRM_RegistrationTrackerUtility.getmetadatafortestclass(null);
        PRM_RegistrationTrackerUtility.getRegistrationTracker(contatIds);
       	List<PRM_RegistrationTrackerUtility.RegistrationWrapper> result1 = PRM_RegistrationTrackerUtility.checkInviteEmail(new Set<String>{cont.Id});
        System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(recIds, emailValues, null, 'PRM_EntitlementUtility', 'Self'));
        System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(null, emailValues, null, 'PRM_SendInviteEmail_Batch', null));
        System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(null, emailValues, null, 'PRM_ProcessInboundOPIDRecords', null));
        Test.stopTest();

    }

    @isTest
    static void testRegistrationWrapper() {
        // Create test data
         Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;
        
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas2';
        newAccount.BillingCity='City22';
        newAccount.BillingStreet='Street222';
        newAccount.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount.BillingPostalCode='1234567';
        newAccount.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount.Core_IPA_Partner_Role__c='Guest';
        newAccount.Core_IPA_Badge_Tier__c='Partner';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount.Core_User_Defined_Website__c = 'abz.yz';
        newAccount.Core_Geo__c = 'ASMO';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount;
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_EmailVerifiedDateTime__c=System.Today();
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
        regRequest.PRM_Country__c='US';
        regRequest.PRM_Partner_Type__c = 'FPGA Design Services';
        regRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regRequest.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        regRequest.PRM_Status__c = 'New';
        regRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest.PRM_Profile_Response__c = 'test pr'; 
        insert regRequest;
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Gril';
        cont.FirstName='Adamm';
        cont.email='AdammGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry='India';
        insert cont;
        
        PRM_Registration_Tracker__c trac3=new PRM_Registration_Tracker__c();
        trac3.Stage__c='3';
        trac3.PRM_contact__c = cont.Id;
        trac3.PRM_Log_Entries__c = '';
        trac3.PRM_Email__c = 'soql.selfcontx@mail.com';
        trac3.Stage__c = '6';
        trac3.createddate = System.now();
        trac3.PRM_AGD_ID_Updated__c = System.today().addDays(1);
        trac3.PRM_Registration_Type__c = 'Self Registration';
        trac3.PRM_Account__c = newAccount.Id;
        trac3.PRM_Registration__c=null;
        trac3.PRM_Step_Number__c=3;
        trac3.PRM_Current_Step__c=3;       
        insert trac3;
        
        

        // Instantiate RegistrationWrapper
        PRM_RegistrationTrackerUtility.RegistrationWrapper wrap = new PRM_RegistrationTrackerUtility.RegistrationWrapper();
        
        // Set properties
        wrap.registration = regRequest;
        wrap.cont = cont;
        wrap.registrationTracker = trac3;
        wrap.regType = 'Self';
        wrap.stageName = 'Initial Stage';
        wrap.stepNo = '1';
        wrap.IntegrationLog = 'Integration Log Info';
        wrap.previousStepNo = '0';
        wrap.AccountId = newAccount.Id;
        wrap.ContactId = cont.Id;
        wrap.Admin_Reg_Initiated = true;
        wrap.GetProfile = false;
        wrap.SBC_Callout_Made = false;
        wrap.DUP_Check_Pending = false;
        wrap.DUP_Check_Success = true;
        wrap.DUP_Check_Failure = false;
        wrap.Azure_B2B_ID_Creation_Successful = true;
        wrap.Azure_B2B_ID_Creation_Failed = false;
        wrap.Azure_B2B_ID_Creation_Pending = false;
        wrap.Azure_B2B_ID_Creation_Retried = false;
        wrap.EV_Sent = true;
        wrap.EV_UnSent = false;
        wrap.EV_Pending = false;
        wrap.EV_Completed = true;
        wrap.Entitlement_Yet_to_Assign = false;
        wrap.Welcome_Email_Yet_to_Send = true;
        wrap.Login_Mail_Sent = false;
        wrap.Login_Mail_UnSent = true;
        wrap.Registration_Initiated = true;
        wrap.Registration_Submitted = false;
        wrap.Waiting_for_Approval = false;
        wrap.Approved = true;
        wrap.Approved_with_Error = false;
        wrap.LogEntries = 'Log Entry Info';
        wrap.Rejected = false;
        wrap.sameAPICall = false;
        wrap.ACR_Assigned = true;
        wrap.Benefit_Assigned = false;
        wrap.Entitlement_Assigned = true;
        wrap.Subscription_Added = false;
        wrap.ACR_Not_Assigned = true;
        wrap.Benefit_Not_Assigned = false;
        wrap.Entitlement_Not_Assigned = true;
        wrap.Benefit_Entitlement_Assigned = false;
        wrap.Benefit_Entitlement_Not_Assigned = true;
        wrap.Benefit_Entitlement_Yet_to_Assign = true;
        wrap.Subscription_Not_Added = false;
        wrap.Welcome_Email_Sent = true;
        wrap.Welcome_Email_Unsent = false;
        wrap.User_Logged_into_Partner_Portal = false;
        wrap.User_Yet_to_login = true;
        wrap.FieldToUpdate = 'Field Update Info';
        wrap.ACR_Yet_to_Assign = true;
        wrap.Subscription_Yet_to_Assign = false;
        wrap.Benefit_Yet_to_Assign = true;
        wrap.stageTrackerMap = new Map<String, PRM_Registration_Tracker__c>();
        wrap.classname = 'Test Class';
        wrap.autoapproved = false;
        wrap.Azure_B2B_ID_creation_Retry_Pending = false;
        wrap.Azure_B2B_ID_creation_Retry_Success = true;
        wrap.Azure_B2B_ID_creation_Retry_Failure = false;
        wrap.Partner_Invite_Initiated = false;
        wrap.External_Partner_Invite_Initiated = true;
        wrap.Bulk_Invite_Initiated = false;
        wrap.regInitiated = true;
        wrap.Invite_UnSent = false;
        wrap.Invite_Sent = true;
        wrap.Invite_Pending = false;
        wrap.Invite_Completed = true;
        wrap.Ack_Mail_Sent = true;
        wrap.Ack_Mail_UnSent = false;
        wrap.dupcheck = false;
        wrap.manulApproval = true;
        wrap.agsid = false;
        wrap.admin = true;
        wrap.ackmail = false;
        wrap.Guest_redemption_complete = true;
        wrap.Guest_redemption_pending = false;
        wrap.OPID_Assigned = true;
        wrap.OPID_Not_Assigned = false;
    }
    
    @IsTest
    static void testTrackerCoverageSingleMethod() {

    ChannelProgram cp = new ChannelProgram(
        Name='Intel Partner Alliance',
        Category='Reseller',
        PRM_programCode__c='IPA_TEST'
    );
    insert cp;
   

    Id accountRT =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Intel Account')
        .getRecordTypeId();

    Account acc = new Account(
        RecordTypeId = accountRT,
        Name = 'Tracker Test Acc1',
        BillingCity = 'Bangalore',
        BillingCountry = 'India',
        BillingStreet = 'Test Street',
        BillingPostalCode = '560001',
        Core_Account_Type__c = 'Cloud Service Provider (CSP)',
        Core_User_Defined_Website__c = 'www.test18.com',
        Core_Geo__c = 'ASMO',
        Core_IPA_Partner_Role__c = 'Service Provider'
    );
    insert acc;

    Contact con = new Contact(
        FirstName='Tracker',
        LastName='User10',
        Email='tracker90@mailinator.com',
        AccountId=acc.Id,
        Core_Job_Function__c='Branch Manager',
        Core_IPA_PartnerRole__c='Service Provider',
        Core_eRPM_Language_Code__c='Eng',
        MailingCountry='India'
    );
    insert con;

    PRM_ContactRelationships__c rel =
        new PRM_ContactRelationships__c(
            Name='Partner Admin',
            PRM_Contact_Relationship_Cd__c='PRIMARY',
            PRM_Channel_Program_Id__c=cp.Id
        );
    insert rel;

    PRM_Account_Contact_Relationship__c acr =
        new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c=acc.Id,
            PRM_Contact_Id__c=con.Id,
            PRM_Relationship_Id__c=rel.Id,
            PRM_isActive__c=true,
            PRM_Status_Nm__c='Complete',
            PRM_InActive_Ind__c=false,
            PRM_Status_Reason_Txt__c='Test',
            PRM_AGS_Response_Status__c='Success',
            PRM_Source_Agent__c='Admin Invite'
        );
    insert acr;

    PRM_EmailLog__c elog =
        new PRM_EmailLog__c(
            PRM_Contact__c=con.Id,
            Email_Template_Name__c='SCRRENGENRLREV'
        );
    insert elog;

    PRM_Integration_Log__c intLog =
        new PRM_Integration_Log__c(
            PRM_Callout_Type__c='GetProfile',
            PRM_System_Name__c='AEM',
            PRM_Record_ID__c=con.Email
        );
    insert intLog;

    PRM_Registration_Request__c reg =
        PRM_TestUtility.getPRMRegistrationRequest();

    reg.RecordTypeId =
        Schema.getGlobalDescribe()
        .get('PRM_Registration_Request__c')
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get(System.Label.PRM_Email_Verification_Request)
        .getRecordTypeId();

    reg.PRM_Email_ID__c = con.Email;
    reg.PRM_Contact_Login_ID__c =
        'login19@mailinator.com';

    reg.PRM_EmailVerifiedDateTime__c = System.now();
    reg.PRM_Channel_Program__c = cp.Id;
    reg.PRM_Salesforce_ID__c = acc.Id;
    reg.PRM_Matching_Contact__c = con.Id;
    reg.PRM_Status__c = 'New';
    reg.PRM_DeDup_Criteria__c='PENDING';
    reg.PRM_Legal_Agreements__c='IPA_TANDC';
    reg.PRM_Profile_Response__c='TEST';

    insert reg;

    List<PRM_Registration_Tracker__c> trackers =
        new List<PRM_Registration_Tracker__c>();

    trackers.add(
        new PRM_Registration_Tracker__c(
            PRM_Registration__c = reg.Id,
            PRM_Contact__c = con.Id,
            PRM_Account__c = acc.Id,
            PRM_Email__c = con.Email,
            Stage__c='1',
            PRM_Current_Step__c=1,
            PRM_Step_Number__c=1
        )
    );

    trackers.add(
        new PRM_Registration_Tracker__c(
            PRM_Registration__c = reg.Id,
            PRM_Contact__c = con.Id,
            PRM_Account__c = acc.Id,
            PRM_Email__c = con.Email,
            Stage__c='23',
            PRM_Current_Step__c=23,
            PRM_Step_Number__c=23,
            PRM_Integration_Log__c=intLog.Id
        )
    );

    trackers.add(
        new PRM_Registration_Tracker__c(
            PRM_Contact__c = con.Id,
            PRM_Account__c = acc.Id,
            PRM_Email__c = con.Email,
            Stage__c='24',
            PRM_Current_Step__c=24,
            PRM_Step_Number__c=24,
            PRM_Integration_Log__c=intLog.Id,
            PRM_Registration_Type__c='Admin Invite'
        )
    );

    insert trackers;
	
    PRM_Registration_Tracker__c tracker = new PRM_Registration_Tracker__c(
    PRM_Registration__c = reg.Id,
    Stage__c = '23',
    PRM_Current_Step__c = 23,
    PRM_Step_Number__c = 23
    );
    insert tracker;
    
    List<PRM_Registration_Request__c> queriedRegs =[SELECT Id,PRM_Email_ID__c,(SELECT Id, Stage__c FROM Registration_Trackers__r)
        FROM PRM_Registration_Request__c
        WHERE Id = :reg.Id];

    Test.startTest();
        
	PRM_RegistrationTrackerUtility.CheckUserLoginHistory(queriedRegs);
    PRM_RegistrationTrackerUtility.createRegistrationTracker(
        new List<PRM_Registration_Request__c>{reg},
        null,
        false,
        false
    );

    PRM_RegistrationTrackerUtility.createRegistrationTracker(
        null,
        new Set<String>{con.Id},
        false,
        false
    );
	
    reg.PRM_Status__c = 'Approved';
    update reg;
        
    PRM_RegistrationTrackerUtility.createRegistrationTracker(
        new List<PRM_Registration_Request__c>{reg},
        null,
        false,
        false
    );
        
    PRM_RegistrationTrackerUtility.checkforEVMailforAdmin(
        new Set<String>{con.Id}
    );

    PRM_RegistrationTrackerUtility.checkInviteEmail(
        new Set<String>{con.Id}
    );

    PRM_RegistrationTrackerUtility.getTrackers(reg.Id);

    PRM_RegistrationTrackerUtility.medata =
        PRM_RegistrationTrackerUtility.getmetadatafortestclass(
            'PRM_Account_Contact_Profiles'
        );

    PRM_RegistrationTrackerUtility.getregWithTrackersforGetProfileAPI(
        new Set<String>{con.Email},
        null,
        'PRM_Account_Contact_Profiles'
    );

    System.enqueueJob(
        new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable(
            new List<PRM_Registration_Request__c>{reg},
            null,
            false,
            false
        )
    );

    System.enqueueJob(
        new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(
            new Set<String>{reg.Id},
            new Set<String>{con.Id},
            null,
            'PRM_EntitlementUtility',
            'Self'
        )
    );

    System.enqueueJob(
        new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(
            new Set<String>{reg.Id},
            new Set<String>{con.Id},
            null,
            'PRM_RegistrationApprovalEmail',
            'Self'
        )
    );
	
    Core_Log_Entry__c ce=new Core_Log_Entry__c(Core_Severity__c='Test',Core_Origin__c='IPA',Core_When__c=DateTime.now());
    insert ce;
    PRM_RegistrationTrackerUtility.getLogEntries(ce.Id);
        
    Test.stopTest();

    System.assertNotEquals(null, reg.Id);
}

}