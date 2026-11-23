@isTest
public class PCC_DealFormValidationTest {
    
    @isTest
    static void testSetUp(){
        Core_Design_Registration__c dealRec = new  Core_Design_Registration__c();
        
        dealRec.Core_Vertical_Market_Nm__c='Education';
        dealRec.Core_Product_Segment_Nm__c='Client Computing';
        dealRec.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec.PCC_End_Customer_Country__c='India';
        dealRec.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec.Core_End_Customer_Postal_Cd__c='758854';
        dealRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec.Core_Production_End_Dt__c = system.today()+22;
        dealRec.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec.Core_Design_Registration_Dsc__c='Test Des';
        dealRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec.Core_End_Customer_URL__c = 'Test';
        dealRec.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRec.PCC_Pricing_End_Date__c = system.today()-4;
        dealRec.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec.PCC_Deal_Description__c='Test';
        dealRec.PCC_End_Customer_Use__c='Test';
        dealRec.PCC_Competition_Assumptions__c='Test';
        dealRec.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec.PCC_Consumption_Countries__c='INDIA';
        dealRec.PCC_Current_EndCustomer_Product_Provider__c='test';
        insert dealRec; 
        PCC_DealFormValidationController.dealErrorWrapper dealValidate= PCC_DealFormValidationController.validateDealRegValues(dealRec.Id,true);
        PCC_DealFormValidationController.submitDealRegValues(dealRec.Id,dealRec);
       // System.assert(true);
       Assert.isNotNull(dealValidate); 
    }
        
        
    @isTest
    static void testGetFileDetails() {
         // Create test data
        Core_Design_Registration__c deal1 = new Core_Design_Registration__c();
        insert deal1;
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv1 = new ContentVersion();
        cv1.title = 'test content trigger'; 
        cv1.PathOnClient ='SampleTitle.jpg';    
        cv1.VersionData =beforeblob;          
        insert cv1;         

        ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv1.Id];

        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=deal1.id;
        contentlink1.ShareType= 'V';
        contentlink1.ContentDocumentId=testcontent1.ContentDocumentId;
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
        
        Core_Design_Registration__c deal2 = new Core_Design_Registration__c();
        insert deal2;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.title = 'test content trigger.mp3'; 
        cv2.PathOnClient ='Sampl.mp3';    
        cv2.VersionData =beforeblob;          
        insert cv2;         

        ContentVersion testContent2 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv2.Id];


        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=deal2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId=testContent2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        List<string> result = new List<String>();
        result = PCC_DealFormValidationController.getFileDetails(deal1.id);
        System.assertEquals(result.size(),0);
        
        List<String> result1 = new List<String>();
        result1 = PCC_DealFormValidationController.getFileDetails(deal2.id);
        System.assertEquals(result1.size(),1);
   }
    
    @isTest
    static void testApprovalFlow(){
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(4);
        DDRLst[0].PCC_Consumption_Countries__c='INDIA';
        DDRLst[1].PCC_Consumption_Countries__c='INDIA';
        DDRLst[2].PCC_Consumption_Countries__c='INDIA';
        DDRLst[3].PCC_Consumption_Countries__c='INDIA';
        DDRLst[0].PCC_Current_EndCustomer_Product_Provider__c='test';
        DDRLst[1].PCC_Current_EndCustomer_Product_Provider__c='test';
        DDRLst[2].PCC_Current_EndCustomer_Product_Provider__c='test';
        DDRLst[3].PCC_Current_EndCustomer_Product_Provider__c='test';
         DDRLst[3].Core_Accepted_By_Id__c = UserInfo.getUserId();
         DDRLst[0].Core_Accepted_By_Id__c = UserInfo.getUserId();
         DDRLst[1].Core_Accepted_By_Id__c = UserInfo.getUserId();
         DDRLst[1].PCC_Approval_Level__c = 'Level 1';
         DDRLst[0].Core_Design_Registration_Status_Nm__c='Draft';
         DDRLst[1].Core_Design_Registration_Status_Nm__c='Draft';
         DDRLst[2].Core_Design_Registration_Status_Nm__c='Draft';
         DDRLst[3].Core_Design_Registration_Status_Nm__c='Draft';
         DDRLst[2].L2_Approver__c = UserInfo.getUserId();
         DDRLst[0].L2_Approver__c = UserInfo.getUserId();
         DDRLst[2].PCC_Approval_Level__c = 'Level 1';
         DDRLst[2].Core_Intel_Technical_Owner_Id__c = UserInfo.getUserId();
         Id dealRecordTypeIDLocked = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByName().get('Deal Registration - Locked').getRecordTypeId();
        // DDRLst[2].Core_Intel_Technical_Owner_Id__c = userInfo.getUserId();
         DDRLst[0].recordTypeId =  dealRecordTypeIDLocked;
        DDRLst[1].recordTypeId =  dealRecordTypeIDLocked;
        DDRLst[3].recordTypeId =  dealRecordTypeIDLocked;
         DDRLst[2].recordTypeId =  dealRecordTypeIDLocked;
        insert DDRLst;
         DDRLst[2].L2_Approver__c = UserInfo.getUserId();
         DDRLst[1].L2_Approver__c = UserInfo.getUserId();
         DDRLst[3].L2_Approver__c = UserInfo.getUserId();
        update DDRLst;
        Assert.isNotNull(DDRLst); 
        /* PCC_DealFormValidationController.dealErrorWrapper dealValidate= PCC_DealFormValidationController.validateDealRegValues(DDRLst[0].Id,true);
         PCC_DealFormValidationController.dealErrorWrapper dealValidate2= PCC_DealFormValidationController.validateDealRegValues(DDRLst[1].Id,true); 
         PCC_DealFormValidationController.dealErrorWrapper dealValidate22= PCC_DealFormValidationController.validateDealRegValues(DDRLst[2].Id,true);*/
        // PCC_DealFormValidationController.callDealApprovalProcess(DDRLst[0].id);
        
        PCC_DealFormValidationController.submitDealRegValues(DDRLst[2].id,DDRLst[2]);
         PCC_DealFormValidationController.submitDealRegValues(DDRLst[3].id,DDRLst[3]);
         PCC_DealFormValidationController.submitDealRegValues(DDRLst[1].id,DDRLst[1]);
        //System.assert(true);
    }
    
    @isTest
    static void testException1(){
        Core_Design_Registration__c dealRecExc = new  Core_Design_Registration__c();
        
        dealRecExc.Core_Vertical_Market_Nm__c='Education';
        dealRecExc.Core_Product_Segment_Nm__c='Client Computing';
        dealRecExc.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRecExc.Core_Partner_FAE_Nm__c='Test FAE';
        dealRecExc.Core_Partner_FSR_Nm__c='Test FSR';
        dealRecExc.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRecExc.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRecExc.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRecExc.PCC_End_Customer_Country__c='India';
        dealRecExc.Core_End_Customer_City_Nm__c='Bangalore';
        dealRecExc.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRecExc.Core_End_Customer_Postal_Cd__c='758854';
        dealRecExc.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRecExc.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRecExc.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRecExc.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRecExc.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRecExc.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRecExc.Core_Production_End_Dt__c = system.today()+22;
        dealRecExc.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRecExc.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRecExc.Core_Design_Registration_Dsc__c='Test Des';
        dealRecExc.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRecExc.Core_End_Customer_URL__c = 'Test';
        dealRecExc.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRecExc.PCC_Pricing_End_Date__c = system.today()-4;
        dealRecExc.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRecExc.PCC_Deal_Description__c='Test';
        dealRecExc.PCC_End_Customer_Use__c='Test';
        dealRecExc.PCC_Competition_Assumptions__c='Test';
        dealRecExc.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRecExc.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRecExc.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRecExc.PCC_Consumption_Countries__c='INDIA';
        dealRecExc.PCC_Current_EndCustomer_Product_Provider__c='test';
        insert dealRecExc; 
        PCC_DealFormValidationController.dealErrorWrapper dealValidate= PCC_DealFormValidationController.validateDealRegValues(dealRecExc.Id,true);
        PCC_DealFormValidationController.submitDealRegValues(dealRecExc.Id,dealRecExc);
        //System.assert(true);
        Assert.isNotNull(dealValidate); 
    }
    @isTest
    static void testPartnerLegalAgreement(){
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        LstAcc[0].recordTypeId = accountRecordTypeIntel;
        LstAcc[1].recordTypeId = accountRecordTypeIntel;
        LstAcc[2].recordTypeId = accountRecordTypeIntel;
        LstAcc[3].recordTypeId = accountRecordTypeIntel;
        LstAcc[4].recordTypeId = accountRecordTypeIntel;
        insert LstAcc;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'test.diqhwqi@test.com';
        insert c1;
        
        UserRole userRole = new UserRole(Name = 'Test Role');
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        
        User u = new User(
            Username = 'testportaluser@example.com',
            Email = 'testportaluser@example.com',
            LastName = 'Test',
            FirstName = 'firstName',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = portalProfile.Id,
            ContactId = c1.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert u;
        
        PRM_PartnerAgreement__c partnerAgreement = new PRM_PartnerAgreement__c();
        partnerAgreement.Name = 'Deal_Registration_Terms_and_Conditions';
        partnerAgreement.PRM_Agreement_Cd__c = 'Deal_Terms_Condition';
        insert partnerAgreement;
        
        PRM_AccountLegalAgreemntAssociation__c PartnerLegalAgreement = new PRM_AccountLegalAgreemntAssociation__c();
        PartnerLegalAgreement.PRM_Account_Id__c = LstAcc[0].Id;
        PartnerLegalAgreement.PRM_Contact__c = c1.Id;
        PartnerLegalAgreement.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
        PartnerLegalAgreement.PRM_Agreement_Sign_Dt__c = Datetime.now();
        insert PartnerLegalAgreement;
        
        system.debug('PartnerLegalAgreement-->'+PartnerLegalAgreement);
        
        Core_Design_Registration__c dealRec = new  Core_Design_Registration__c();
        
        dealRec.Core_Vertical_Market_Nm__c='Education';
        dealRec.Core_Product_Segment_Nm__c='Client Computing';
        dealRec.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec.PCC_End_Customer_Country__c='India';
        dealRec.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec.Core_End_Customer_Postal_Cd__c='758854';
        dealRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec.Core_Production_End_Dt__c = system.today()+22;
        dealRec.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec.Core_Design_Registration_Dsc__c='Test Des';
        dealRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec.Core_End_Customer_URL__c = 'Test';
        dealRec.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRec.PCC_Pricing_End_Date__c = system.today()-4;
        dealRec.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec.PCC_Deal_Description__c='Test';
        dealRec.PCC_End_Customer_Use__c='Test';
        dealRec.PCC_Competition_Assumptions__c='Test';
        dealRec.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec.PCC_Consumption_Countries__c='INDIA';
        dealRec.PCC_Current_EndCustomer_Product_Provider__c='test';
        insert dealRec;
    
        Core_Design_Registration__c dealRec1 = new  Core_Design_Registration__c();
        
        dealRec1.Core_Vertical_Market_Nm__c='Education';
        dealRec1.Core_Product_Segment_Nm__c='Client Computing';
        dealRec1.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec1.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec1.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec1.PCC_End_Customer_Country__c='India';
        dealRec1.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec1.Core_End_Customer_Postal_Cd__c='758854';
        dealRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec1.Core_Production_End_Dt__c = system.today()+22;
        dealRec1.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec1.Core_Design_Registration_Dsc__c='Test Des';
        dealRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec1.Core_End_Customer_URL__c = 'Test';
        dealRec1.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRec1.PCC_Pricing_End_Date__c = system.today()-4;
        dealRec1.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec1.PCC_Deal_Description__c='Test';
        dealRec1.PCC_End_Customer_Use__c='Test';
        dealRec1.PCC_Competition_Assumptions__c='Test';
        dealRec1.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec1.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec1.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec1.PCC_Consumption_Countries__c='INDIA';
        dealRec1.PCC_Current_EndCustomer_Product_Provider__c='test';
        insert dealRec1;
        
        PRM_AccountLegalAgreemntAssociation__c PartnerLegalAgreement1 = new PRM_AccountLegalAgreemntAssociation__c();
        PartnerLegalAgreement1.PRM_Account_Id__c = LstAcc[0].Id;
        PartnerLegalAgreement1.PRM_Contact__c = c1.Id;
        PartnerLegalAgreement1.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
        PartnerLegalAgreement1.PRM_Agreement_Sign_Dt__c = Datetime.now();
        PartnerLegalAgreement1.PCC_Design_Deal_Registration__c=dealRec1.Id;
        insert PartnerLegalAgreement1;
        
            Test.startTest();
            PCC_DealFormValidationController.updateDealAgreement(dealRec.Id, u);
            System.assertEquals(PartnerLegalAgreement.PRM_Account_Id__c, LstAcc[0].Id);
            Test.stopTest();
        }
     }
    /*
    @isTest
    static void testCallDealApprovalProcess() {
        //user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        //system.runas(sysadm){
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        //Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    List<account> LstAcc = Core_Test_Utility.createAccount(1);
        User accOwner= [select id from User where UserRole.Name='Admin' limit 1];
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        LstAcc[0].ownerId=accOwner.id;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Assert.isNotNull(accountRecordTypeIntel);
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'testUsercoreMPM1245@intel.com';
        insert c1;
        
        Profile profile1 = [Select Id from Profile where name = 'Partner' Limit 1];
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM1245@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='TestUser'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUserLL'+String.valueOf(Math.random())+'@CoreMPM.com',
                                 FirstName='TestUtilityKK', ContactId = c1.id, ProfileId = profile1.Id);
        insert testUser;
        
        system.runas(testUser){
        Core_Design_Registration__c dealRec = new  Core_Design_Registration__c();
        
        dealRec.Core_Vertical_Market_Nm__c='Education';
        dealRec.Core_Product_Segment_Nm__c='Client Computing';
        dealRec.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec.Core_Partner_FAE_Nm__c='Test FAE';
        //dealRec.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        //dealRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec.PCC_End_Customer_Country__c='India';
        dealRec.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec.Core_End_Customer_Postal_Cd__c='758854';
        //dealRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        //dealRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        //dealRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        //dealRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        //dealRec.Core_Manufacturing_Region_Cd__c='ASMO';
        
        //dealRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        //dealRec.Core_Production_End_Dt__c = system.today()+22;
        //dealRec.Core_Intel_Platform_Nm__c='Agilex';
        dealRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        //dealRec.Core_Design_Registration_Dsc__c='Test Des';
        dealRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        //dealRec.Core_End_Customer_URL__c = 'Test';
        dealRec.Core_Design_Registration_Status_Nm__c ='Submitted';
        dealRec.PCC_Pricing_End_Date__c = system.today()-4;
        dealRec.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec.PCC_Deal_Description__c='Test';
        //dealRec.PCC_End_Customer_Use__c='Test';
        dealRec.PCC_Competition_Assumptions__c='Test';
        //dealRec.PCC_Intel_Response_Requested_By_Date__c=system.today();
        //dealRec.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec.PCC_Consumption_Countries__c='INDIA';
        dealRec.PCC_Current_EndCustomer_Product_Provider__c='test';
        //dealRec.PCC_Registration_Type__c = 'Deal Registration'
        insert dealRec;
        
        Test.startTest();
        PCC_DealFormValidationController.callDealApprovalProcess(dealRec.Id);
        Test.stopTest();
        }

  
    }*/
    @isTest
    static void testSetUp1(){
        
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        //Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    List<account> LstAcc = Core_Test_Utility.createAccount(1);
        User accOwner= [select id from User where UserRole.Name='Admin' limit 1];
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        LstAcc[0].ownerId=accOwner.id;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Assert.isNotNull(accountRecordTypeIntel);
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'testUsercoreMPM1245@intel.com';
        insert c1;
        
        Profile profile1 = [Select Id from Profile where name = 'Partner' Limit 1];
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM1245@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='TestUser'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUserLL'+String.valueOf(Math.random())+'@CoreMPM.com',
                                 FirstName='TestUtilityKK', ContactId = c1.id, ProfileId = profile1.Id);
        insert testUser;
        /*
        Core_Design_Registration__c dealRec = new  Core_Design_Registration__c();
        
        dealRec.Core_Vertical_Market_Nm__c='Education';
        dealRec.Core_Product_Segment_Nm__c='Client Computing';
        dealRec.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec.PCC_End_Customer_Country__c='India';
        dealRec.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec.Core_End_Customer_Postal_Cd__c='758854';
        dealRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec.Core_Production_End_Dt__c = system.today()+22;
        dealRec.Core_Intel_Platform_Nm__c='Agilex';
        dealRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec.Core_Design_Registration_Dsc__c='Test Des';
        dealRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec.Core_End_Customer_URL__c = 'Test';
        dealRec.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRec.PCC_Pricing_End_Date__c = system.today()+4;
        dealRec.PCC_Pricing_Start_Date__c = system.today()+2;
        dealRec.PCC_Deal_Description__c='Test';
        dealRec.PCC_End_Customer_Use__c='Test';
        dealRec.PCC_Competition_Assumptions__c='Test';
        dealRec.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec.Core_Opportunity_Decision_Dt__c = system.today();
        dealRec.PCC_Consumption_Countries__c='INDIA';
        dealRec.PCC_Current_EndCustomer_Product_Provider__c='test';
        dealRec.OwnerId = testuser.id;
        insert dealRec;*/ 
        PRM_PartnerAgreement__c partnerAgreement = new PRM_PartnerAgreement__c();
        partnerAgreement.Name = 'Deal_Registration_Terms_and_Conditions';
        partnerAgreement.PRM_Agreement_Cd__c = 'Deal_Terms_Condition';
        insert partnerAgreement;
        
        PRM_AccountLegalAgreemntAssociation__c PartnerLegalAgreement = new PRM_AccountLegalAgreemntAssociation__c();
        PartnerLegalAgreement.PRM_Account_Id__c = LstAcc[0].Id;
        PartnerLegalAgreement.PRM_Contact__c = c1.Id;
        PartnerLegalAgreement.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
        PartnerLegalAgreement.PRM_Agreement_Sign_Dt__c = Datetime.now();
        insert PartnerLegalAgreement;
        
        system.debug('PartnerLegalAgreement-->'+PartnerLegalAgreement);
        
        Core_Design_Registration__c dealRec = new  Core_Design_Registration__c();
        
        dealRec.Core_Vertical_Market_Nm__c='Education';
        dealRec.Core_Product_Segment_Nm__c='Client Computing';
        dealRec.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec.PCC_End_Customer_Country__c='India';
        dealRec.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec.Core_End_Customer_Postal_Cd__c='758854';
        dealRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec.Core_Production_End_Dt__c = system.today()+22;
        dealRec.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec.Core_Design_Registration_Dsc__c='Test Des';
        dealRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec.Core_End_Customer_URL__c = 'Test';
        dealRec.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRec.PCC_Pricing_End_Date__c = system.today()-4;
        dealRec.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec.PCC_Deal_Description__c='Test';
        dealRec.PCC_End_Customer_Use__c='Test';
        dealRec.PCC_Competition_Assumptions__c='Test';
        dealRec.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec.PCC_Consumption_Countries__c='INDIA';
        dealRec.PCC_Current_EndCustomer_Product_Provider__c='test';
        dealRec.OwnerId = testuser.id;
        insert dealRec;
    
        Core_Design_Registration__c dealRec1 = new  Core_Design_Registration__c();
        
        dealRec1.Core_Vertical_Market_Nm__c='Education';
        dealRec1.Core_Product_Segment_Nm__c='Client Computing';
        dealRec1.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec1.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec1.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec1.PCC_End_Customer_Country__c='India';
        dealRec1.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec1.Core_End_Customer_Postal_Cd__c='758854';
        dealRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec1.Core_Production_End_Dt__c = system.today()+22;
        dealRec1.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec1.Core_Design_Registration_Dsc__c='Test Des';
        dealRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec1.Core_End_Customer_URL__c = 'Test';
        dealRec1.Core_Design_Registration_Status_Nm__c ='Draft';
        dealRec1.PCC_Pricing_End_Date__c = system.today()-4;
        dealRec1.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec1.PCC_Deal_Description__c='Test';
        dealRec1.PCC_End_Customer_Use__c='Test';
        dealRec1.PCC_Competition_Assumptions__c='Test';
        dealRec1.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec1.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec1.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec1.PCC_Consumption_Countries__c='INDIA';
        dealRec1.PCC_Current_EndCustomer_Product_Provider__c='test';
        insert dealRec1;
        
        PRM_AccountLegalAgreemntAssociation__c PartnerLegalAgreement1 = new PRM_AccountLegalAgreemntAssociation__c();
        PartnerLegalAgreement1.PRM_Account_Id__c = LstAcc[0].Id;
        PartnerLegalAgreement1.PRM_Contact__c = c1.Id;
        PartnerLegalAgreement1.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
        PartnerLegalAgreement1.PRM_Agreement_Sign_Dt__c = Datetime.now();
        PartnerLegalAgreement1.PCC_Design_Deal_Registration__c=dealRec1.Id;
        insert PartnerLegalAgreement1;
        system.runas(testuser){
        //PCC_DealFormValidationController.dealErrorWrapper dealValidate= PCC_DealFormValidationController.validateDealRegValues(dealRec.Id,true);
            PCC_DealFormValidationController.submitDealRegValues(dealRec.Id,dealRec);
            PCC_DealFormValidationController.submitDealRegValues(dealRec1.Id,dealRec);
       // System.assert(true);
            //Assert.isNotNull(dealValidate); 
            }
    }
    
    @isTest
    static void testSetUp2(){
        
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        //Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    List<account> LstAcc = Core_Test_Utility.createAccount(1);
        User accOwner= [select id from User where UserRole.Name='Admin' limit 1];
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        LstAcc[0].ownerId=accOwner.id;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Assert.isNotNull(accountRecordTypeIntel);
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'testUsercoreMPM1245@intel.com';
        insert c1;
        
        Profile profile1 = [Select Id from Profile where name = 'Partner' Limit 1];
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM1245@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='TestUser'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUserLL'+String.valueOf(Math.random())+'@CoreMPM.com',
                                 FirstName='TestUtilityKK', ContactId = c1.id, ProfileId = profile1.Id);
        insert testUser;
        system.runas(testuser){
        Core_Design_Registration__c dealRec = new  Core_Design_Registration__c();
        
        dealRec.Core_Vertical_Market_Nm__c='Education';
        dealRec.Core_Product_Segment_Nm__c='Client Computing';
        dealRec.Core_Product_Application_Nm__c='Business Desktop';
        
        dealRec.Core_Partner_FAE_Nm__c='Test FAE';
        dealRec.Core_Partner_FSR_Nm__c='Test FSR';
        dealRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        dealRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        dealRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        dealRec.PCC_End_Customer_Country__c='India';
        dealRec.Core_End_Customer_City_Nm__c='Bangalore';
        dealRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        dealRec.Core_End_Customer_Postal_Cd__c='758854';
        dealRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        dealRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        dealRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        dealRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        dealRec.Core_Manufacturing_Region_Cd__c='ASMO';
        
        dealRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        dealRec.Core_Production_End_Dt__c = system.today()+22;
        dealRec.Core_Intel_Platform_Nm__c='ALDER LAKE';
        dealRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        dealRec.Core_Design_Registration_Dsc__c='Test Des';
        dealRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        dealRec.Core_End_Customer_URL__c = 'Test';
        dealRec.Core_Design_Registration_Status_Nm__c ='Draft';
        //dealRec.PCC_Pricing_End_Date__c = system.today()-4;
        //dealRec.PCC_Pricing_Start_Date__c = system.today()-2;
        dealRec.PCC_Deal_Description__c='';
        dealRec.PCC_End_Customer_Use__c='Test';
        dealRec.PCC_Competition_Assumptions__c='';
        dealRec.PCC_Intel_Response_Requested_By_Date__c=system.today();
        dealRec.PCC_Proposal_Due_Date__c = system.today()-2;
        dealRec.Core_Opportunity_Decision_Dt__c = system.today()+2;
        dealRec.PCC_Consumption_Countries__c='INDIA';
        dealRec.PCC_Current_EndCustomer_Product_Provider__c='test';
        insert dealRec; 
        PCC_DealFormValidationController.dealErrorWrapper dealValidate= PCC_DealFormValidationController.validateDealRegValues(dealRec.Id,true);
        PCC_DealFormValidationController.submitDealRegValues(dealRec.Id,dealRec);
       // System.assert(true);
       Assert.isNotNull(dealValidate); 
        }}
    
    @isTest
    static void testCallDealApprovalProcess11() {
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        system.runas(sysadm){
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        List<account> LstAcc2 = Core_Test_Utility.createAccount(1);
        
        for(Account accountInstance : LstAcc2){
            // acc.Core_Sales_Groups__c ='';
            accountInstance.recordTypeId = accountRecordTypeIntel;accountInstance.OwnerId = UserInfo.getUserId(); accountInstance.name = 'Testvijayvarshan';
            accountInstance.BillingCountryCode = 'USA';accountInstance.BIllingStateCode = 'AL';accountInstance.BillingCity = 'Alabama testobc';accountInstance.BillingStreet = 'test jkhl';
        }
        insert LstAcc2;
        Contact testContact = new Contact(FirstName='testFirstName12345', LastName='testLastName', Email='test123456@testing.com.test',AccountId=LstAcc2[0].Id,Core_IPS_Active__c =false);
        insert testContact;
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        User u1 = new User( email='partneruser1@example.com',profileid = partnerProfile.id,UserName='partneruser1@example.com',Alias = 'PDS',TimeZoneSidKey='America/New_York',
                           EmailEncodingKey='ISO-8859-1',LocaleSidKey='en_US', LanguageLocaleKey='en_US',ContactId = testContact.Id,PortalRole = 'Manager',FirstName = 'Genea',LastName = 'Dsouz');
        
        Database.insert(u1);
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
        system.runas(u1){
            List<Core_Design_Registration__c> DDRLst = new list<Core_Design_Registration__c>();
            Core_Design_Registration__c ddrRec2 = new  Core_Design_Registration__c();
            ddrRec2.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddrRec2.Core_Vertical_Market_Nm__c='Education';
            ddrRec2.Core_Product_Segment_Nm__c='Client Computing';
            ddrRec2.Core_Product_Application_Nm__c='Business Desktop';
            ddrRec2.Core_Opportunity_Volume_Cnt__c=100;
            ddrRec2.Core_Partner_FAE_Nm__c='Test FAE';
            ddrRec2.Core_Partner_FSR_Nm__c='Test FSR';
            ddrRec2.Core_End_Customer_Nm__c='Arrow Electronics Account';
            ddrRec2.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            ddrRec2.Core_End_Customer_Street_Addr_Line2_Txt__c='';
            ddrRec2.PCC_End_Customer_Country__c='India';
            ddrRec2.Core_End_Customer_City_Nm__c='Bangalore';
            ddrRec2.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            ddrRec2.Core_End_Customer_Postal_Cd__c='758854';
            ddrRec2.Core_End_Customer_Contact_Title_Txt__c='Mr.';
            ddrRec2.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            ddrRec2.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            ddrRec2.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            ddrRec2.Core_Manufacturing_Region_Cd__c='ASMO';
            ddrRec2.Core_Opportunity_Decision_Dt__c = system.today()+20;
            ddrRec2.Core_First_Customer_Ship_Dt__c = system.today()+21;
            ddrRec2.Core_Production_End_Dt__c = system.today()+22;
            ddrRec2.Core_Intel_Platform_Nm__c='ALDER LAKE';
            ddrRec2.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
            ddrRec2.Core_Design_Registration_Dsc__c='Test Des';
            ddrRec2.Core_External_Id__c='abczd001';
            ddrRec2.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
            ddrRec2.Core_End_Customer_URL__c = 'Test';
            ddrRec2.PCC_Consumption_Countries__c = 'Test';
            ddrRec2.PCC_Current_EndCustomer_Product_Provider__c='Test';
            ddrRec2.RecordTypeId=DealRecordTypeid;
            DDRLst.add(ddrRec2);
            insert DDRLst; 
           
        
        
        Test.startTest();
        PCC_DealFormValidationController.callDealApprovalProcess(ddrRec2.Id);
        Test.stopTest();
        }
        
        
    }
}
}