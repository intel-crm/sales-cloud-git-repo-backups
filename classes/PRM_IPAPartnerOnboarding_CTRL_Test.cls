/***************************************************************************************************************************************
Apex Class Name     : PRM_IPAPartnerOnboarding_CTRL_Test
Version             : 1.0
Created Date        : July 2020
Function            : This controller class will load different steps on Post Launch Onboarding Page on the baisis of type and User Entitlement on UI.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty Sharma                       11th-July-2020                     US640819-IPA - POST-LAUNCH [ONBOARDING]: Create an On-boarding experience for new and existing user to accept the T&Cs
*************************************************************************************************************************************/
@isTest
public class PRM_IPAPartnerOnboarding_CTRL_Test {
    
    @testSetup static void setup(){
        Id profileCommunity =[Select id from Profile where Name='Partner'].Id;
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        //List<Account> lstAccts = new List<Account>();
        Account PAGAcc1 = new Account(Name ='PAGAccount1',Core_Account_Type__c = 'Distributor',
                                      Industry='Agriculture',RecordTypeId=OpidAccRecordTypeId, BillingCity='Eau Claire',BillingCountry='India',BillingStreet='1385  Mercer Street',
                                      ShippingCity='delhi',ShippingCountry='India',ShippingStreet='1453  Grant Street',Core_Intel_Partner_Alliance_PartnerGroup__c=True,
                                      Core_IPA_One_Partner_Id__c='12345',Core_IPA_Partner_Role__c='Distributor');
        insert PAGAcc1;
        
        List<Account> acc = new List<Account>();
        Account intelAccount = new Account();//Account
        intelAccount.RecordTypeId = recordTypeIdAccount;
        intelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        intelAccount.Name='Johrt Rick';
        intelAccount.BillingCity='City';
        intelAccount.BillingStreet='Street';
        intelAccount.BillingCountry='India';
        intelAccount.BillingPostalCode='Postal code';
        intelAccount.Core_IPA_Partner_Role__c = 'Distributor';
        intelAccount.Core_CNDA_Number__c='';
        intelAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert intelAccount;
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =PAGAcc1.Id;
        accGroupMem.Core_Intel_Account_Id__c =intelAccount.Id;
        Database.insert(accGroupMem);
        
        //contact for Intel Account
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact();
        cnt.FirstName='Boyle';
        cnt.LastName='Mendez';
        cnt.Email='boyleMendez@spamok.com';
        cnt.AccountId=intelAccount.Id;
        cnt.RecordTypeId=IntelContRecTypeId;
        cnt.MailingCity='Knoxville';
        cnt.MailingCountry='India';
        cnt.MailingPostalCode='123456';
        cnt.Core_IPA_PartnerRole__c='Distributor';
        cnt.Core_Preferred_Language__c='';
        insert cnt;
        Contact cnt2 = new Contact();
        cnt2.FirstName='John';
        cnt2.LastName='Test';
        cnt2.Email='johnemp@test.com';
        cnt2.AccountId=intelAccount.Id;
        cnt2.RecordTypeId=IntelContRecTypeId;
        cnt2.MailingCity='Knoxville';
        cnt2.MailingCountry='India';
        cnt2.MailingPostalCode='123456';
        cnt2.Core_IPA_PartnerRole__c='Distributor';
        cnt.Core_Preferred_Language__c='ENG';
        insert cnt2;
        
        
        
        Profile partnerCommunityProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        //user
        User empUser = new User(FirstName='John',LastName='Test',alias='john',Email='johnemp@test.com',UserName='johnemp@test.com', ContactId=cnt2.Id,ProfileId=partnerCommunityProfile.Id,
                                emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        insert empUser;
        User partnerUser = new User(FirstName='Partner',LastName='User',alias='testusr',Email='testusercon1@test.com',UserName='testusercon1@test.com', ContactId=cnt.Id,ProfileId=partnerCommunityProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        insert partnerUser;
        
        
        //ACR - 
        //ChannelProgram cp = [SELECT id FROM ChannelProgram];
        ChannelProgram cp=new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.IsActive=true;
        insert cp;
        Id cpId=cp.id;
        
        PRM_ContactRelationships__c contctRel = new PRM_ContactRelationships__c();
        contctRel.PRM_Channel_Program_Id__c = cpId;
        contctRel.Name = 'Partner Admin';
        contctRel.PRM_Contact_Relationship_Cd__c = 'PRIMARY';
        insert contctRel;
        
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = intelAccount.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contctRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_InActive_Ind__c = false;
        insert acr;
        
        
        //ACM
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Partner',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        //acm
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=intelAccount.Id;
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Partner_Role__c='Distributor';
        acm.PRM_Channel_Program_Level_Id__c=partnerTier.Id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Status_Reason_Txt__c = 'Test Class';
        insert acm;
        
        //Entitlements
        Core_ERPM_Engagement__c erpmEngagement = new Core_ERPM_Engagement__c();
        erpmEngagement.Name = 'Intel Partner Alliance';
        erpmEngagement.Core_IsActive__c = True;
        erpmEngagement.Core_Engagement_Type__c = 'SEC';
        erpmEngagement.Core_Technical_DeDup_Number__c = 'DEDUPGPIPA';
        insert erpmEngagement;
        
        Core_Entitlement__c coreEntitlement = new Core_Entitlement__c();
        coreEntitlement.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        coreEntitlement.Core_IsActive__c = True;
        coreEntitlement.Core_Display_Name__c = 'Partner Admin';
        coreEntitlement.Name='Partner Admin';
        insert coreEntitlement;
        
        test.startTest(); 
        Core_Contact_Entitlement__c contEntitlement = new Core_Contact_Entitlement__c();
        contEntitlement.Core_Contact_Id__c = cnt.Id;
        contEntitlement.Core_Entitlement_Id__c = coreEntitlement.Id;
        contEntitlement.Core_Unique_Id__c = 'Partner Admin';
        contEntitlement.Core_Status__c='Complete';
        contEntitlement.Core_Selected__c=true;
        insert contEntitlement;
        test.stopTest();
        
        PRM_Partner_Terms_and_Conditions__c termsNConditionsPart1 = new PRM_Partner_Terms_and_Conditions__c();
        termsNConditionsPart1.Name='IPA _Terms _And _Condition_ENG_Part1';
        termsNConditionsPart1.PRM_Content_Code_Txt__c=System.Label.PRM_IPATermsandConditions_ContentCode.split(',')[0];
        termsNConditionsPart1.PRM_Content_Language_Nm__c=PRM_IPAPartnerOnboarding_CTRL.DEFAULT_LANGUAGE;
        termsNConditionsPart1.PRM_Terms_and_Conditions_Type_Nm__c=System.Label.PRM_PartnerTermsandConditions_Type;
        termsNConditionsPart1.PRM_Content_Message_Txt__c='Text1';
        insert termsNConditionsPart1;
        PRM_Partner_Terms_and_Conditions__c termsNConditionsPart2 = new PRM_Partner_Terms_and_Conditions__c();
        termsNConditionsPart2.Name='IPA _Terms _And _Condition_ENG_Part2';
        termsNConditionsPart2.PRM_Content_Code_Txt__c=System.Label.PRM_IPATermsandConditions_ContentCode.split(',')[1];
        termsNConditionsPart2.PRM_Content_Language_Nm__c=PRM_IPAPartnerOnboarding_CTRL.DEFAULT_LANGUAGE;
        termsNConditionsPart2.PRM_Terms_and_Conditions_Type_Nm__c=System.Label.PRM_PartnerTermsandConditions_Type;
        termsNConditionsPart2.PRM_Content_Message_Txt__c='Text2';
        insert termsNConditionsPart2;
        
        PRM_Partner_Terms_and_Conditions__c termsNConditionsPart3 = new PRM_Partner_Terms_and_Conditions__c();
        termsNConditionsPart3.Name='IPA _Terms _And _Condition_ENG_Part3';
        termsNConditionsPart3.PRM_Content_Code_Txt__c=System.Label.PRM_PartnerTermsandConditions_GDPR_Code;
        termsNConditionsPart3.PRM_Terms_and_Conditions_Type_Nm__c = System.Label.PRM_PartnerTermsandConditions_Type;
        termsNConditionsPart3.PRM_Content_Language_Nm__c=PRM_IPAPartnerOnboarding_CTRL.DEFAULT_LANGUAGE;
        termsNConditionsPart3.PRM_Content_Message_Txt__c='Text3';
        insert termsNConditionsPart3;
        
        PRM_PartnerAgreement__c agreement= new PRM_PartnerAgreement__c();
        agreement.Name=System.Label.PRM_IPA_Terms_Condition;
        agreement.PRM_Agreement_Cd__c='IPA_TANDC';
        agreement.PRM_Channel_Program_Id__c=cpId;
        insert agreement;
        List<PRM_Partner_Subscription__c> subsList =new List<PRM_Partner_Subscription__c>();
        PRM_Partner_Subscription__c sub1=new PRM_Partner_Subscription__c(Name ='Points Communications',PRM_Subscription_Cd__c='	POINTCOM',PRM_Subscription_Dsc__c='Points Communications');
        PRM_Partner_Subscription__c sub2=new PRM_Partner_Subscription__c(Name ='Product and Solution Communications',PRM_Subscription_Cd__c='PRDSOLCOM',PRM_Subscription_Dsc__c='Product and Solution Communications');
        PRM_Partner_Subscription__c sub3=new PRM_Partner_Subscription__c(Name ='Events Communications',PRM_Subscription_Cd__c='EVENTCOM',PRM_Subscription_Dsc__c='Events Communications');
        PRM_Partner_Subscription__c sub4=new PRM_Partner_Subscription__c(Name ='Membership Communications',PRM_Subscription_Cd__c='MEMBCOM',PRM_Subscription_Dsc__c='Membership Communications');
        PRM_Partner_Subscription__c sub5=new PRM_Partner_Subscription__c(Name ='Partner Research Communications',PRM_Subscription_Cd__c='PARRESCOM',PRM_Subscription_Dsc__c='Partner Research Communications');
        PRM_Partner_Subscription__c sub6=new PRM_Partner_Subscription__c(Name ='Training and Webinar Communications',PRM_Subscription_Cd__c='TRAWEBCOM',PRM_Subscription_Dsc__c='Training and Webinar Communications');
        subsList.add(sub1);
        subsList.add(sub2);
        subsList.add(sub3);
        subsList.add(sub4);
        subsList.add(sub5);
        subsList.add(sub6);
        insert subsList;
        
        PRM_Partner_Community_Enrollment_Request__c partnerCommunityEnrollmentRequest = new PRM_Partner_Community_Enrollment_Request__c();
        partnerCommunityEnrollmentRequest.PRM_Partner_Community_Nm__c = 'Tech Ambassador';
        partnerCommunityEnrollmentRequest.PRM_Contact_Id__c = cnt.Id;
        partnerCommunityEnrollmentRequest.PRM_Status_Nm__c = PRM_IPAPartnerOnboarding_CTRL.STATUS_PENDING;
        partnerCommunityEnrollmentRequest.PRM_Start_Date_Dt__c=System.today();
        insert partnerCommunityEnrollmentRequest;
    }
    
    @isTest
    public static void testLoadTermAndConditions(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        System.runAs(u){
            test.startTest();
            
            String primaryContent = PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch('terms-and-conditions');
            PRM_SubComponentDataWrapper primaryTACWrapper = (PRM_SubComponentDataWrapper)JSON.deserialize(primaryContent, PRM_SubComponentDataWrapper.class);
            System.assertEquals(System.Label.PRM_Onboarding_AcceptTermsAndConditions, primaryTACWrapper.title);
            String nonPrimaryContent = PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch('terms-and-conditions-non-primary');
            PRM_SubComponentDataWrapper nonPrimaryTACWrapper = (PRM_SubComponentDataWrapper)JSON.deserialize(nonPrimaryContent, PRM_SubComponentDataWrapper.class);
            System.assertEquals(System.Label.PRM_Onboarding_AcceptTermsAndConditions, nonPrimaryTACWrapper.title);
            
            test.stopTest();
        }
    }
    
    @isTest
    public static void testLoadTermAndConditionsException(){
        test.startTest();
        String content = PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch('terms-and-conditions');
        test.stopTest();
        PRM_SubComponentDataWrapper tACWrapper = (PRM_SubComponentDataWrapper)JSON.deserialize(content, PRM_SubComponentDataWrapper.class);
        System.assertEquals(null,tACWrapper.title);
    }
    
    @isTest
    public static void testSubmitTermAndConditions(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        System.runAs(u){
            test.startTest();
            PRM_IPAPartnerOnboarding_CTRL.submitTermsAndCondtion('12345','TNCCheckbox');
            String completionStatus = PRM_IPAPartnerOnboarding_CTRL.getStepCompletionStatus();
            test.stopTest();
            List<PRM_ContactSubscriptionAssociation__c> subsCount=[Select Id from PRM_ContactSubscriptionAssociation__c];
            List<PRM_AccountLegalAgreemntAssociation__c> accLegalCount=[Select Id from PRM_AccountLegalAgreemntAssociation__c];
            //System.assertEquals(5, subsCount.size(), 'Contact Subscription Count');
            System.assertEquals(1, accLegalCount.size(), 'Account Legal Count');
            PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper successResponse = (PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper)JSON.deserialize(completionStatus, PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper.class);
            System.assert(successResponse.stepOneCompleted);
            System.assert(successResponse.stepTwoCompleted);
        }
    }
    
    
    @isTest
    public static void testLoadCommuniySelection(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        System.runAs(u){
            test.startTest();
            String primaryComm=PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch('community-picklist');
            String nonPrimaryComm=PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch('community-picklist-non-primary');
            test.stopTest();
            PRM_SubComponentDataWrapper primaryCommunityResponse=(PRM_SubComponentDataWrapper)JSON.deserialize(primaryComm, PRM_SubComponentDataWrapper.class); 
            System.assertEquals(System.Label.PRM_Onboarding_Communities, primaryCommunityResponse.title);
            PRM_SubComponentDataWrapper nonPrimaryCommunityResponse=(PRM_SubComponentDataWrapper)JSON.deserialize(nonPrimaryComm, PRM_SubComponentDataWrapper.class); 
            System.assertEquals(System.Label.PRM_Onboarding_Communities, nonPrimaryCommunityResponse.title);
        }
    }
    
    @isTest
    public static void testSubmitCommunityEnrollmentRequest(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        /*userrole ur = [select id from userrole where name='admin' limit 1];
        
        u.UserRoleId=ur.id;
        update u;*/
        System.runAs(u){
            test.startTest();
            String community='["Intel® FPGA Partner"]';
            PRM_IPAPartnerOnboarding_CTRL.submitCommunityEnrollmentRequest('1234',community);
            test.stopTest();
            List<PRM_Partner_Community_Enrollment_Request__c> enrollment=[Select Id from PRM_Partner_Community_Enrollment_Request__c];
            System.assertEquals(1, enrollment.size());
        }
    }
    
    @isTest
    public static void testGetSubComponentDataWithoutType(){
        test.startTest();
        String content = PRM_IPAPartnerOnboarding_CTRL.getSubComponentDataPostLaunch('Test');
        test.stopTest();
        System.assertEquals('Type not specified', content);
    }
    
    @isTest
    public static void testGetStepCompletionStatus(){
        User testUser=[Select Id from User where UserName='johnemp@test.com' limit 1 ];
        Id cnt2=[Select Id from contact where Email='johnemp@test.com' limit 1][0].Id;
        PRM_Partner_Community_Enrollment_Request__c newEnrollmentRequest = new PRM_Partner_Community_Enrollment_Request__c();
        newEnrollmentRequest.PRM_Contact_Id__c = cnt2;
        newEnrollmentRequest.PRM_Partner_Community_Nm__c = 'Intel® FPGA Partner';
        newEnrollmentRequest.PRM_Status_Nm__c = PRM_IPAPartnerOnboarding_CTRL.STATUS_PENDING;
        insert newEnrollmentRequest;
        System.runAs(testUser){
            test.startTest();
            String stepCompleted= PRM_IPAPartnerOnboarding_CTRL.getStepCompletionStatus();
            test.stopTest();
            PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper successResponse = (PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper)JSON.deserialize(stepCompleted, PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper.class);
            System.assert(!successResponse.stepOneCompleted);
            System.assert(successResponse.stepTwoCompleted);
        }
    }  
    
    @isTest
    public static void testGetStepCompletionStatusException(){
        test.startTest();
        String stepCompleted= PRM_IPAPartnerOnboarding_CTRL.getStepCompletionStatus();
        test.stopTest();
        PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper successResponse = (PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper)JSON.deserialize(stepCompleted, PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper.class);
        System.assert(!successResponse.stepOneCompleted);
        System.assert(!successResponse.stepTwoCompleted);
    }  

@isTest
    public static void testIsTandCandSubscriptionCheck(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        System.runAs(u){
              Boolean isTandCSubscriptionCheck = false;
            test.startTest();
            PRM_IPAPartnerOnboarding_CTRL.isTandCandSubscriptionCheck();
            String completionStatus = PRM_IPAPartnerOnboarding_CTRL.getStepCompletionStatus();
             test.stopTest();
            List<PRM_ContactSubscriptionAssociation__c> contactSubs=[Select Id from PRM_ContactSubscriptionAssociation__c];
           // System.assertEquals(null,contactSubs.size(), 'Contact Subscription Count');
            PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper successResponse = (PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper)JSON.deserialize(completionStatus, PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper.class);
           // System.assert(successResponse.stepOneCompleted);
           // System.assert(successResponse.stepTwoCompleted);

    }  
}
     @isTest
    public static void testIsTandCandSubscriptionCheckException(){
         Boolean isTandCSubscriptionCheck = false;
          test.startTest();
        Boolean content = PRM_IPAPartnerOnboarding_CTRL.IsTandCandSubscriptionCheck();
        test.stopTest();
        String stepCompleted= PRM_IPAPartnerOnboarding_CTRL.getStepCompletionStatus();
        PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper successResponse = (PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper)JSON.deserialize(stepCompleted, PRM_IPAPartnerOnboarding_CTRL.SuccessResponseWrapper.class);
        System.assert(!successResponse.stepOneCompleted);
        System.assert(!successResponse.stepTwoCompleted);
    }
   
    @isTest
    public static void getredirect(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        System.runAs(u){
            test.startTest();
            String content = PRM_IPAPartnerOnboarding_CTRL.getRedirectUrl();
            test.stopTest();
        }
    }
     @isTest
    public static void getredirectException(){
            test.startTest();
            String content = PRM_IPAPartnerOnboarding_CTRL.getRedirectUrl();
            test.stopTest();
        
    }
    
    @istest
    public static void  onBoardingRedirect(){
        User u=[Select Id,ContactId from User where UserName='testusercon1@test.com' limit 1];
        System.runAs(u){
            test.startTest();
           // List content<PRM_ContactSubscriptionAssociation__c> = 
                PRM_IPAPartnerOnboarding_CTRL.onBoardingRedirect();
            test.stopTest();}
         }
}