@isTest
public class PRM_Account_Contact_Profiles_Test {
    
    @testSetup
    private static void createData(){
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> lstAccts = new List<Account>();
            
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',Core_User_Defined_Website__c='www.test.com',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        lstAccts.add(intelAccount1);
        Database.insert(lstAccts);
       
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c =intelAccount1.Id;
        Database.insert(accGroupMem);
        
        partnerAccount1.Core_PMP_Membership_Change_Ind__c = false;
        Database.update(partnerAccount1);
        List<Account> updatedAcct= new List<Account>();
        for(Account acc:[SELECT ID,NAME,Core_Account_Type__c,Core_IPA_Partner_Role__c FROM ACCOUNT]){
            acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_business_party_Id__c='12345';
            updatedAcct.add(acc);
        }
        
        //Get Contact Record Type
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@spamok.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_IPA_PartnerRole__c = 'Service Provider');
        insert cnt;
    
          
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Partner',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c='Run via Test class');
        insert acm;
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c(Name='IPA Program',PRM_Agreement_Category_Nm__c='Intel Insider Cloud All Agreements',
                                                                PRM_Agreement_Cd__c='IPAPRGM',PRM_Channel_Program_Id__c=cp.Id);
        insert pa;        
       
        
        PRM_AccountLegalAgreemntAssociation__c legalAgrmnt = new PRM_AccountLegalAgreemntAssociation__c();       
        legalAgrmnt.PRM_Account_Id__c = partnerAccount1.Id;
        legalAgrmnt.PRM_Agreement_Sign_Dt__c = system.now();
        legalAgrmnt.PRM_Partner_Agreement_Id__c = pa.Id;
        //legalAgrmnt.PRM_Contact__c = cnt.Id;
        insert legalAgrmnt;   
       
 /*       Account_Business_Types__c accBt = new Account_Business_Types__c();
      //  accBt.Id = 'a8I8A000000CtmXUAS';
      //  accBT.Name = 'BAT-00121';
      //  accBT.Business_Types__c = 'a8H8A000000DCiuUAG';
        accBT.Status__c = 'Approved';
    accBT.Account__c = partnerAccount1.Id;  
        accBT.Account__r.Name = partnerAccount1.Name;  
        insert accBT;
        
        Contact_Business_Types__c conBt = new Contact_Business_Types__c();
      //  conBt.Id = 'a8J8A000000XjWCUA0';
      //  conBt.Name = 'CAT-00121';
      //  conBt.Business_Types__c = 'a8H8A000000DCiuUAG';
        conBt.Status__c = 'Approved';
    conBt.Contact__c = cnt.Id;  
        conBt.Contact__r.Email = cnt.Email;
        insert conBt;
    */   
        PRM_Specialty__c specialty = new PRM_Specialty__c();
        specialty.name='Select Benefits';       
        specialty.PRM_Access_Level_Nm__c = 'Public';
        specialty.PRM_Role_Nm__c = 'Service Provider';
        specialty.PRM_Tier_Nm__c ='Gold';
        specialty.PRM_Description_Txt__c = 'Test';
        specialty.PRM_Funding_BU_Nm__c = 'Automotive Sales Group';
        specialty.PRM_Start_Date_Dt__c = system.Today();
        specialty.PRM_End_Date_Dt__c = system.Today()+60;
        insert specialty;
        
        PRM_Account_Specialty_Association__c acctSpecialty = new PRM_Account_Specialty_Association__c();
        acctSpecialty.PRM_Account_Id__c = partnerAccount1.id;
        acctSpecialty.PRM_Specialty_Id__c = specialty.Id;
        //acctSpecialty.PRM_Status_Nm__c = 'TBD';
        insert acctSpecialty;
        
        PRM_PartnerBenefit__c benefit = new PRM_PartnerBenefit__c();
        /*benefit.Name = 'Points Redemption';
        benefit.PRM_Channel_Program_Id__c = cp.Id;
        benefit.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        benefit.PRM_Benefit_Type_Nm__c = 'Financial';*/
        benefit.Name = 'Partner University';
        benefit.PRM_Channel_Program_Id__c = cp.id;
        benefit.PRM_Benefit_Cd__c = 'BNFTSMBA';
        benefit.PRM_Account_Type_Nm__c = 'Both';
        insert benefit;
        
        PRM_PartnerType__c partnerType = new PRM_PartnerType__c();
       /* partnerType.PRM_channelprogram__c = cp.Id;
        partnerType.PRM_PartnerRoleCode__c = 'Service Provider';
        partnerType.PRM_Role_Name__c = 'Service Provider';
        partnerType.PRM_PartneryTypeCode__c = 'CloudServiceProvider';
        partnerType.Name = 'Cloud Service Provider (CSP)';*/
        partnerType.Name = 'Cloud Service Provider (CSP)';
        partnerType.PRM_Role_Name__c='Service Provider';
        partnerType.PRM_PartneryTypeCode__c='CSP';
        partnerType.PRM_PartnerRoleCode__c='SPR';
        partnerType.PRM_channelprogram__c=cp.Id;
        insert partnerType;
        
        PRM_VXBnftMatrix__c benefitMatrix = new PRM_VXBnftMatrix__c();
        benefitMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        benefitMatrix.PRM_Covered_Account_Ind__c = true;
        benefitMatrix.PRM_IsActive_Ind__c = true;
        benefitMatrix.PRM_Partner_Benefit_Id__c = benefit.Id;
        benefitMatrix.PRM_Channel_Program_Id__c = cp.Id;
        benefitMatrix.PRM_Partner_Role_Nm__c = 'Service Provider';
        benefitMatrix.PRM_Channel_Program_Level_Id__c = partnerTier.Id;
        benefitMatrix.PRM_Partner_Type_Id__c = partnerType.Id;
        insert benefitMatrix;
          
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = partnerAccount1.Id;
        aba.PRM_Partner_Benefit_Id__c = benefit.Id;
        aba.PRM_Status_Reason_Txt__c = 'Testclass run';
        aba.PRM_Source__c = 'Select Benefit';                   
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
        Core_ERPM_Engagement__c erpmEngagement = new Core_ERPM_Engagement__c();
        erpmEngagement.Name = 'Intel Partner Alliance';
        erpmEngagement.Core_IsActive__c = True;
        erpmEngagement.Core_Engagement_Type__c = 'SEC';
        erpmEngagement.Core_Technical_DeDup_Number__c = 'DEDUPGPIPA';
        insert erpmEngagement;
        
        Core_Account_ERPM_Engagement__c acctEngagement = new Core_Account_ERPM_Engagement__c();
        acctEngagement.Core_Account_Id__c = partnerAccount1.Id;
        acctEngagement.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        insert acctEngagement;            
            
        //Account Contact Relationship
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Employee';
        contRel.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        insert contRel;
        Test.startTest();
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = partnerAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_Status_Reason_Txt__c = 'Test';
        insert acr;
        
        Core_Entitlement__c coreEntitlement = new Core_Entitlement__c();
        coreEntitlement.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        coreEntitlement.Core_IsActive__c = True;
        coreEntitlement.Core_Display_Name__c = 'Employee';
      
        insert coreEntitlement;
        
        Core_Contact_Entitlement__c contEntitlement1 = new Core_Contact_Entitlement__c();
        contEntitlement1.Core_Contact_Id__c = cnt.Id;
        contEntitlement1.Core_Entitlement_Id__c = coreEntitlement.Id;
        contEntitlement1.Core_Unique_Id__c = 'Partner Admin';
        insert contEntitlement1;
        
        PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
        ps.PRM_InActive_Ind__c = false;
        ps.Name = 'Intel® Cloud Insider Events and Tradeshows';
        ps.PRM_Subscription_Cd__c = 'IPASUB';
        insert ps;
        
        PRM_ContactSubscriptionAssociation__c contSub = new PRM_ContactSubscriptionAssociation__c();
        contSub.PRM_Contact_Id__c = cnt.Id;
        contSub.PRM_Partner_Subscription_Id__c = ps.Id;
        contSub.PRM_Status_Reason_Txt__c = 'Testclass run';
        contSub.PRM_Status_Nm__c = 'Active';
        insert contSub;    
        
        //Account Request
        PRM_Registration_Request__c acctReq = new PRM_Registration_Request__c();
        acctReq.Name = 'Test Account Request';
        acctReq.PRM_First_Name__c = 'Test';
        acctReq.PRM_Last_Name__c = 'Account Request';
        acctReq.PRM_Email_ID__c = cnt.Email;
        acctReq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        acctReq.PRM_Account_Name__c = 'Test Account Request';
        insert acctReq;
        
        /*
        PRM_CIMSearchResults__c cimSearchRes = new PRM_CIMSearchResults__c();
        cimSearchRes.PRM_RegReq_Id__c = acctReq.Id;
        cimSearchRes.PRM_Account_Id__c = partnerAccount1.Id;
        cimSearchRes.PRM_CIM_Id__c = '12345';
        insert cimSearchRes;
        
       
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c();
        tc.Name = 'Test T&C';
        tc.PRM_Registration_Requests__c = acctReq.Id;
        tc.PRM_Partner_Agreement__c = pa.Id;
        insert tc;
    
        
        Subscription__c subscription = new Subscription__c();
        subscription.PRM_Partner_Subscription__c = ps.Id;
        subscription.PRM_RegistrationRequest__c = acctReq.id;
        subscription.Name = 'Test Subscription';
        insert subscription;
    */
        
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        pq.PRM_Question_Display_Txt__c = 'Sample Question';
        pq.PRM_Question_Cd__c = 'SAMPLEQUESTION';
        insert pq;
        
  /*      PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = partnerAccount1.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        pr.PRM_InActive_Ind__c = false;
        pr.PRM_Response_Txt__c = 'SampleResponse';   
        insert pr;
  */      
        Core_Account_Whitelisted_Domains__c whiteList = new Core_Account_Whitelisted_Domains__c();
        whiteList.Name = 'Intel Account';
        whiteList.Partner_Program__c = channelPrograms[0].Id;
        whiteList.Account__c = partnerAccount1.Id ;
        insert whiteList;       
        
        Core_Country_Code_Mapping__c cc = new Core_Country_Code_Mapping__c();
        cc.Name = 'India';
        cc.ISO_Code__c = 'IND';
        cc.Country_Code__c = 'IN';
        insert cc;
          
        //insert contEntitlement; 
        PRM_Partner_Assist_Consent__c partnerAssist = new PRM_Partner_Assist_Consent__c();
        partnerAssist.PRM_Account_Id__c = partnerAccount1.Id;
        //partnerAssist.Name = 'Intel';
        partnerAssist.PRM_Consent_Provided_By_Id__c = cnt.Id;
        insert partnerAssist;            
        Database.Update(updatedAcct);    
        Test.stopTest();  
        
    }   
    
    /*********************** GetRegRequestAccountProfile Test ******************************/
     private static testMethod void GetRegRequestAccountProfileTest(){
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
         
        PRM_Registration_Request__c acctReq = [Select id,PRM_Email_ID__c,PRM_Contact_Login_ID__c From PRM_Registration_Request__c LIMIT 1]; 
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
         
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+acctReq.PRM_Email_ID__c+'", "IsProgramBased":"true","Name":"IPA"}}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles  profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
       // system.assert(profiles.ContactAccount != null || profiles.AccountRequest != null ); 
         
         reqBody = '{"KeyInput":{"InputField":"LOGINID","InputValue":"'+acctReq.PRM_Email_ID__c+'", "IsProgramBased":"true","Name":"IPA"}}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ContactAccount == null || profiles.AccountRequest != null ); 
         
        
         
        //Negative Test Cases
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"'+acct.Id+'"}}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);       
         
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"TESTRECID"}}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles();        
        system.assert(profiles.ExceptionDetails != null || profiles.ErrorMsg != null);
         
        reqBody = '{"KeyInput":{"InputField":"TESTID","InputValue":"'+acct.Id+'"}}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles();
        system.assert(profiles.ExceptionDetails != null || profiles.ErrorMsg != null);
         
        test.stopTest();
    }
    /*********************** End of GetRegRequestAccountProfile Test ******************************/
    /*********************** Account Request Test ******************************/
     private static testMethod void getAccountRequestTest(){
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        PRM_Registration_Request__c acctReq = [Select id,PRM_Email_ID__c, PRM_Salesforce_ID__c From PRM_Registration_Request__c LIMIT 1]; 
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"'+acctReq.Id+'"},"Attribute":"ACCOUNTREQUEST"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountRequest != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+acctReq.PRM_Email_ID__c+'"},"Attribute":"ACCOUNTREQUEST"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountRequest != null);
         
         
        //Negative Test Cases
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"'+acct.Id+'"},"Attribute":"ACCOUNTREQUEST"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null);
         
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"TESTRECID"},"Attribute":"ACCOUNTREQUEST"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ExceptionDetails != null);
         
        reqBody = '{"KeyInput":{"InputField":"TESTID","InputValue":"'+acct.Id+'"},"Attribute":"ACCOUNTREQUEST"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null);
         
        test.stopTest();
    }
    /*********************** End of Account Request Test ******************************/
    /*********************** Person Account Test *************************************/
    private static testMethod void getPersonAccountTest(){
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        PRM_AccountBenefitAssociation__c accABA = [Select id from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c =:acct.id LIMIT 1];
        ChannelProgram cpg = [select id from ChannelProgram LIMIT 1];

        
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cpg.Id;
        pq.PRM_InActive_Ind__c = false;
        pq.PRM_Question_Cd__c = 'Test Ques';
        pq.PRM_Question_Display_Txt__c = 'test display';
        insert pq;
        
        PRM_Profile_Answer__c pa = new PRM_Profile_Answer__c();
        pa.PRM_Answer_Cd__c = 'Test Ans';
        pa.PRM_Display_Order_Nbr__c = 2;
        pa.PRM_InActive_Ind__c = false;
        pa.PRM_Profile_Questions_Id__c = pq.Id;
        insert pa;
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        pr.PRM_Response_Txt__c = 'Test res';
        pr.PRM_Profile_Answer_Id__c = pa.id;
        pr.PRM_InActive_Ind__c = false;
        pr.PRM_Account_Id__c = acct.id;
        insert pr;
        
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"'+cont.Id+'"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.ContactAccount != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+cont.EMail+'"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.ContactAccount != null);
        
        //*******************Negative Test Cases
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"'+acct.Id+'"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null);
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"TESTRECID"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ExceptionDetails != null);
                
        reqBody = '{"KeyInput":{"InputField":"Test","InputValue":"'+acct.Id+'"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"test@test.com"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation> listABA = PRM_Account_Contact_Profiles_Utility.getAccoutBenefitAssociations(accABA);
       // system.assert(profiles.ErrorMsg != null ||profiles.ExceptionDetails != null );
        
        test.stopTest();
    }
    /*********************** End of Person Account Test *************************************/
    /*********************** Business Person Account Test ***********************************/
    private static testMethod void getBusinessPersonTest(){       
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"'+cont.Id+'"},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ContactBasicProfile != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+cont.EMail+'"},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ContactBasicProfile != null);
        
        //Negative Test Cases
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"test1@test.com"},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"'+acct.Id+'"},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"TESTRECID "},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        List<PRM_Account_Contact_Profiles_Model.ContactEntitlement> listCE = PRM_Account_Contact_Profiles_Utility.getPersonEntitlements(cont);
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        test.stopTest();
    }
    /*********************** End of Business Person Test ***********************************/
    /*********************** Account Result Test ******************************************/
    private static testMethod void getAccountResultTest(){       
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
    
        reqBody = '{"KeyInput":{"InputField":"CIMID","InputValue":"'+acct.Core_business_party_Id__c+'"},"Attribute":"ACCOUNTRESULT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountResults != null);
        
        //************************** Negative Test Cases        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'Test"},"Attribute":"ACCOUNTRESULT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.AccountResults.Status == 'Error');
        
        reqBody = '{"KeyInput":{"InputField":"CIMID","InputValue":"TEST121212"},"Attribute":"ACCOUNTRESULT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountResults.Status == 'Error');
        
        test.stopTest();
    }        
     /*********************** End of Account Result Test ******************************************/
    /*********************** Account Profile Test ******************************************/
    private static testMethod void getAccountProfileTest(){       
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
       // system.assert(profiles.AccountProfile != null);
        
        reqBody = '{"KeyInput":{"InputField":"CIMID","InputValue":"'+acct.Core_business_party_Id__c+'"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.AccountProfile != null);
        
        //************************** Negative Test Cases        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'Test"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+cont.Id+'"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null);
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"TESTRECID"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"TESTID","InputValue":"'+cont.Id+'Test"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        test.stopTest();
    }        
     /*********************** End of Account Profile Test ******************************************/
    /*********************** OnePartnerIDGroupMembersTest ******************************************/
    private static testMethod void getOnePartnerIDGroupMembersTest(){
        String reqBody = '';
        String strJSON = '';
        
        test.startTest();
        Account acct = [Select id From Account WHERE Name='IntelAccount1' LIMIT 1]; 
        Core_Account_Group_Member__c cagm = [SELECT id FROM Core_Account_Group_Member__c LIMIT 1];
        
        RestRequest request = new RestRequest();        
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'"},"Attribute":"ONEPARTNERIDGROUPMEMBERS"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles();    
       // system.assert(profiles.OnePartnerIDGroupMembers != null);
        
        /*
        reqBody = '{"KeyInput":{"InputField":"CIMID","InputValue":"12345"},"Attribute":"ONEPARTNERIDGROUPMEMBERS"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        strJSON = PRM_Account_Contact_Profiles.GetProfiles();    
        system.assert(strJSON.indexOf('OnePartnerIDGroupMembers') > -1);
        */
        //*****************************Negative Test cases
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'Test"},"Attribute":"ONEPARTNERIDGROUPMEMBERS"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles();       
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+cagm.Id+'"},"Attribute":"ONEPARTNERIDGROUPMEMBERS"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles();       
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"TESTID","InputValue":"'+cagm.Id+'Test"},"Attribute":"ONEPARTNERIDGROUPMEMBERS"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles();       
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        test.stopTest();        
    }    
    /*********************** End of OnePartnerIDGroupMembersTest ******************************************/
    /*********************** GetRegRequestProfileTest ******************************************/
    private static testMethod void getRegRequestProfileTest(){
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        PRM_Registration_Request__c acctReq = [Select id,PRM_Email_ID__c From PRM_Registration_Request__c LIMIT 1]; 
        Account acct = [Select id,Core_business_party_Id__c From Account LIMIT 1];
        Core_Country_Code_Mapping__c ccode = [select id, Name from Core_Country_Code_Mapping__c LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"'+acctReq.Id+'"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.RegistrationRequestProfile != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+acctReq.PRM_Email_ID__c+'"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        //system.assert(profiles.RegistrationRequestProfile != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":""},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.RegistrationRequestProfile == null);
         
        //Negative Test Cases
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"'+acct.Id+'"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);    
         
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"TESTRECID"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);   
         
        reqBody = '{"KeyInput":{"InputField":"TESTID","InputValue":"'+acct.Id+'"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        String country = PRM_Account_Contact_Profiles_Utility.getCountryCodeNameMapping(ccode.Name);
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);   
         
        test.stopTest();
    }
    /*********************** End of GetRegRequestProfileTest ******************************************/
     
    private static testMethod void testWrongAttribute(){
        String reqBody = '';
        String strJSON = '';
        
        test.startTest();
        
        Account acct = [Select id From Account WHERE Name='IntelAccount1' LIMIT 1]; 
        Core_Account_Group_Member__c cagm = [SELECT id FROM Core_Account_Group_Member__c LIMIT 1];
        
        RestRequest request = new RestRequest();        
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'"},"Attribute":"TESTATTRIBUTE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);   
        
        test.stopTest();
    } 
    private static testMethod void testCMF(){
        List<ER_Customer_Master_File_Group__c> cmfGroupList= new List<ER_Customer_Master_File_Group__c>();
        for(Integer i=0; i<5;i++){
            ER_Customer_Master_File_Group__c cmfGroup= new ER_Customer_Master_File_Group__c();
            cmfGroup.Name= 'testName'+i;
            cmfGroupList.add(cmfGroup);
        }
        Database.Insert(cmfGroupList);
        ER_Customer_Master_File__c cmf= new ER_Customer_Master_File__c();
        cmf.Name='testCmfName';
        cmf.ER_CMF_Name__c='testCMF';
        cmf.ER_Sales_Disti_Chnl_Code__c='EU02';
        Database.Insert(cmf);
        List<ER_CMFGroupAssociation__c> cmfAssocList = new  List<ER_CMFGroupAssociation__c>();
        for(ER_Customer_Master_File_Group__c cmfgroup:cmfGroupList){
            ER_CMFGroupAssociation__c cmfAssoc= new ER_CMFGroupAssociation__c();
            cmfAssoc.ER_Customer_Master_File__c=cmf.Id;
           cmfAssoc.ER_Customer_Master_File_Group__c=cmfgroup.Id;
            cmfAssocList.add(cmfAssoc);
        }
        Database.Insert(cmfAssocList);
        List<Contact> ContactList = new List<Contact>();
        ContactList =[SELECT id from CONTACT];
        ContactList[0].Core_Login_Status__c ='Active';
        Database.Update(ContactList);
        List<ER_ContactGroupAssociation__c> contactAssocList = new List<ER_ContactGroupAssociation__c>();
        for(Contact con : [SELECT id from CONTACT WHERE Core_Login_Status__c ='Active']){
            ER_ContactGroupAssociation__c conAssoc = new ER_ContactGroupAssociation__c();
            conAssoc.ER_Contact__c = con.id;
            conAssoc.ER_Customer_Master_File_Group__c = cmfGroupList[0].id;
            contactAssocList.add(conAssoc);
        }
        Database.Insert(contactAssocList);
         String reqBody = '';
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"testcontact1@spamok.com"},"Attribute":"CONTACTCMFGROUP"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        PRM_Account_Contact_Profiles_Utility.getCMfDetails('testcontact1@mailinator.com','EMAILID');
    }
    public static testMethod void checksystemAccountsTest(){
        Test.startTest();
        PRM_Account_Contact_Profiles_Utility.ChecksystemAccounts('EmailId');
        PRM_Account_Contact_Profiles_Utility.systemAccountMethod();
        Test.stopTest();
    }
     public static testMethod void getProfileRespFromMembership(){
         Account acct = [Select id From Account WHERE Name='IntelAccount1' LIMIT 1];
         Account partnerAcct = [
            SELECT Id
            FROM Account
            WHERE Name = 'PartnerAccount1'
            LIMIT 1
        ];
        
        acct.Core_IPA_One_Partner_Id__c = partnerAcct.Id;
        update acct;
         
        Core_CustomMetadata_Object__c meta = new Core_CustomMetadata_Object__c(
            DeveloperName__c = 'POINT_OPT_IN',
            MasterLabel__c = 'Point Opt In',
            Metadata_Name__c = 'PRM_IPAMembership_Mapping__mdt',
            Field_1__c = 'Points Opt In',
            Field_2__c = 'POINT_OPT',
            Field_3__c = 'TRUE',
            Field_6__c = 'PRM_Points_Opt_in_Ind__c',
            Field_7__c = 'TRUE'
        );
        insert meta;
         
         PRM_IPAMembership_Attributes__c membership =
            new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = partnerAcct.Id,
                PRM_Inactive_ind__c = false,
                PRM_Points_Opt_in_Ind__c = true
            );
		insert membership;
         
        Test.startTest();
        PRM_Account_Contact_Profiles_Utility.getProfileResponseFromMembership(acct.Id);
        Test.stopTest();
    }
    
     @IsTest
    static void testComplianceWatchListProperties() {
        // Arrange
        Datetime startDate = Datetime.newInstance(2024, 1, 1, 0, 0, 0);
        Datetime endDate = Datetime.newInstance(2024, 12, 31, 23, 59, 59);

        // Act
        /*PRM_Account_Contact_Profiles_Model.ComplianceWatchList watchList = new PRM_Account_Contact_Profiles_Model.ComplianceWatchList();
        watchList.ComplianceType = 'Regulatory';
        watchList.ComplianceName = 'AML Watch';
        watchList.EffectiveStartDate = startDate;
        watchList.EffectiveEndDate = endDate;*/
    }
    
    @IsTest
    static void testContactBusinessType() {
        // Act
        PRM_Account_Contact_Profiles_Model.ContactBusinessType cbt =
            new PRM_Account_Contact_Profiles_Model.ContactBusinessType();

        cbt.BusinessTypeName = 'Retail';
        cbt.BusinessTypeCode = 'RTL';
        cbt.Status = 'Active';
        cbt.Email = 'test@email.com';
        cbt.ContactName = 'John Doe';
        cbt.StatusReason = 'Verified';
    }

    @IsTest
    static void testProfileResponseAndResponse() {
        // Arrange
        PRM_Account_Contact_Profiles_Model.Response response =
            new PRM_Account_Contact_Profiles_Model.Response();

        response.ResponseText = 'Yes';
        response.ResponseCode = 'Y';

        List<PRM_Account_Contact_Profiles_Model.Response> responses =
            new List<PRM_Account_Contact_Profiles_Model.Response>{ response };

        PRM_Account_Contact_Profiles_Model.ProfileResponse profileResponse =
            new PRM_Account_Contact_Profiles_Model.ProfileResponse();

        profileResponse.QuestionText = 'Do you agree?';
        profileResponse.QuestionCode = 'Q1';
        profileResponse.Responses = responses;
    }

    @IsTest
    static void testAccountSpecialityAssociation() {
        // Act
        PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation asa =
            new PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation();

        asa.Name = 'Cardiology Association';
        asa.IsInactive = false;
        asa.SpecialityName = 'Cardiology';
        asa.SpecialityType = 'Medical';
        asa.SpecialityRole = 'Primary';
        asa.SpecialityRoleLabel = 'Primary Specialist';
        asa.SpecialityTier = 'Tier 1';
}

    @IsTest
    static void testCmfWrapperAndCmfData() {
        // Arrange
        PRM_Account_Contact_Profiles_Model.cmfData cmf =
            new PRM_Account_Contact_Profiles_Model.cmfData();

        cmf.CMFID = 'CMF001';
        cmf.Name = 'Test CMF';
        cmf.SalesOrgCode = '1000';
        cmf.SalesOrgName = 'North America';
        cmf.SalesDistiChannelCode = '10';
        cmf.SalesDistiChannelName = 'Wholesale';
        cmf.Address = '123 Main Street';
        cmf.AccountGroup = 'AG1';
        cmf.DirectCustomerRoleName = 'Primary';
        cmf.DirectCustomerRoleCode = 'PR';
        cmf.CentralBlock = false;
        cmf.SalesAreaOrderBlockCd = 'N';

        List<PRM_Account_Contact_Profiles_Model.cmfData> cmfList =
            new List<PRM_Account_Contact_Profiles_Model.cmfData>{ cmf };

        // Act
        PRM_Account_Contact_Profiles_Model.cmfWrapper wrapper =
            new PRM_Account_Contact_Profiles_Model.cmfWrapper();

        wrapper.GroupName = 'Test Group';
        wrapper.Description = 'Test Description';
        wrapper.Active = true;
        wrapper.ActiveCMFCount = '1';
        wrapper.InActiveCMFCount = '0';
        wrapper.ActiveContactCount = '5';
        wrapper.InActiveContactCount = '0';
        wrapper.CMFs = cmfList;

    }

    @IsTest
    static void testAccountReqTermsCondition() {

        Datetime signedDate = Datetime.newInstance(2024, 6, 1, 10, 0, 0);

        PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition terms =
            new PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition();

        terms.Name = 'Standard Terms';
        terms.SignedDate = signedDate;
        terms.PartnerAgreementName = 'Partner Agreement A';
        terms.PartnerAgreementCode = 'PA001';
        terms.PartnerAgreementCategory = 'Legal';
    }

    @IsTest
    static void testAccountReqSubscription() {
        // Act
        PRM_Account_Contact_Profiles_Model.AccountReqSubscription subscription =
            new PRM_Account_Contact_Profiles_Model.AccountReqSubscription();

        subscription.name = 'Sub1';
        subscription.SubscriptionName = 'Premium Plan';
        subscription.SubscriptionCode = 'PREM';
}


    @IsTest
    static void testAccountRequest() {
        // Arrange
        PRM_Account_Contact_Profiles_Model.AccountRequestWrapper reqWrapper =
            new PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();

        // Act
        PRM_Account_Contact_Profiles_Model.AccountRequest accountRequest =
            new PRM_Account_Contact_Profiles_Model.AccountRequest();

        accountRequest.AccountRequest = reqWrapper;

    }

    @IsTest
    static void testAccountProfileWrapper() {
        // Arrange
        PRM_Account_Contact_Profiles_Model.AccountProfileWrapper profileWrapper =
            new PRM_Account_Contact_Profiles_Model.AccountProfileWrapper();

        profileWrapper.AccountContactRelationships =
            new List<PRM_Account_Contact_Profiles_Model.AccountContactRelationship>();

        profileWrapper.AccountEngagements =
            new List<PRM_Account_Contact_Profiles_Model.AccountERPMEngagement>();

        profileWrapper.AccountChannelMemberships =
            new List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership>();

        profileWrapper.AccoutBenefitAssociations =
            new List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation>();

        profileWrapper.AccountSpecialityAssociations =
            new List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation>();

        profileWrapper.AccountLegalAgreements =
            new List<PRM_Account_Contact_Profiles_Model.AccountLegalAgreement>();

        profileWrapper.AccountBusinessTypes =
            new List<PRM_Account_Contact_Profiles_Model.AccountBusinessType>();

       /* profileWrapper.ComplianceWatchLists =
            new List<PRM_Account_Contact_Profiles_Model.ComplianceWatchList>();*/

    }

    @IsTest
    static void testAccountBusinessType() {
        // Arrange
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate = Date.newInstance(2024, 12, 31);

        // Act
        PRM_Account_Contact_Profiles_Model.AccountBusinessType abt =
            new PRM_Account_Contact_Profiles_Model.AccountBusinessType();

        abt.BusinessTypeName = 'Distributor';
        abt.BusinessTypeCode = 'DIST';
        abt.Status = 'Active';
        abt.AccountName = 'Test Account';
        abt.EffectiveStartDate = startDate;
        abt.EffectiveEndDate = endDate;
        abt.StatusReason = 'Approved';

    }
    
    @IsTest
        static void testGetProfiles()
        {
            PRM_Registration_Request__c regReq =new PRM_Registration_Request__c(
                    Name = 'CovThis',
                    PRM_First_Name__c = 'Test03',
                    PRM_Last_Name__c = 'User09',
                    PRM_Email_ID__c = 'nomatch@inteltest.com',
                    PRM_Status__c = 'New',
                    PRM_Contact_Country__c = 'IND'
             );
            insert regReq;
        
            RestRequest request = new RestRequest();
            request.requestUri = '/services/apexrest/GetProfile/';
            request.httpMethod = 'POST';
        
            request.requestBody = Blob.valueOf(
                '{"KeyInput":{"InputField":"EMAILID",' +
                '"InputValue":"nomatch@inteltest.com",' +
                '"IsProgramBased":"true",' +
                '"Name":"IPA"}}'
            );
        
            RestContext.request = request;
        
            Test.startTest();       
            PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles();       
            Test.stopTest();       
            System.assertNotEquals(null, profiles);
        }
	
    /*
     @IsTest
    static void testGetProfileResponses() {

        // ---------- Test Data Setup ---------- 

        // Account
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;            
        
        Account acc = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',Core_User_Defined_Website__c='www.test.com',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True
        );
        insert acc;

        // Channel Program
        ChannelProgram cp = [
            SELECT Id, Name
            FROM ChannelProgram
            WHERE Name = 'Intel Partner Alliance'
            LIMIT 1
        ];

        System.assertNotEquals(null, cp, 'Channel Program must exist');


        // Profile Question
        PRM_Profile_Questions__c question = new PRM_Profile_Questions__c(
            PRM_Question_Display_Txt__c = 'What is your primary market?',
            PRM_Question_Cd__c = 'PRIMARY_MARKET',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Display_Order_Nbr__c = 1
        );
        insert question;

        // Profile Answer
        PRM_Profile_Answer__c answer = new PRM_Profile_Answer__c(
            PRM_Answer_Cd__c = 'ENTERPRISE',
            PRM_Profile_Questions_Id__c = question.id
        );
        insert answer;

        // Profile Response
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c(
            PRM_Profile_Questions_Id__c = question.Id,
            PRM_Profile_Answer_Id__c = answer.Id,
            PRM_Response_Txt__c = 'Enterprise Customers',
            PRM_Account_Id__c = acc.Id,
            PRM_InActive_Ind__c = false
        );
        insert response;

        // ---------- Execute ---------- 
        Test.startTest();
        List<PRM_Account_Contact_Profiles_Model.ProfileResponse> results =
            PRM_Account_Contact_Profiles_Utility.getProfileResponses(acc.Id);
        Test.stopTest();

        // ---------- Assertions ---------- 
        System.assertNotEquals(null, results, 'Result list should not be null');
        System.assertEquals(1, results.size(), 'One profile response expected');

        PRM_Account_Contact_Profiles_Model.ProfileResponse pr = results[0];
        System.assertEquals(
            'What is your primary market?',
            pr.QuestionText,
            'Question text mismatch'
        );
        System.assertEquals(
            'PRIMARY_MARKET',
            pr.QuestionCode,
            'Question code mismatch'
        );

        System.assertEquals(1, pr.Responses.size(), 'One response expected');

        PRM_Account_Contact_Profiles_Model.Response r = pr.Responses[0];
        System.assertEquals(
            'Enterprise Customers',
            r.ResponseText,
            'Response text mismatch'
        );
        System.assertEquals(
            'ENTERPRISE',
            r.ResponseCode,
            'Response code mismatch'
        );
    }

    @IsTest
    static void testGetProfileResponses_NoResponses() {

        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;            
        
        Account acc = new Account(Name ='Empty Account',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',Core_User_Defined_Website__c='www.test.com',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True
        );

        Test.startTest();
        List<PRM_Account_Contact_Profiles_Model.ProfileResponse> results =
            PRM_Account_Contact_Profiles_Utility.getProfileResponses(acc.Id);
        Test.stopTest();

        System.assertEquals(0, results.size(),
            'No profile responses should be returned when no data exists');
    }
    
    
    @IsTest
    static void testGetAccountSpecialityAssociations() {

        //-------- Account -------- 
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;            
        Account acc = new Account(Name ='Test Account',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',Core_User_Defined_Website__c='www.test.com',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True        );
        insert acc;

        //-------- Specialty -------- 
        Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
        Id specnRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Video Specialty';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=specnRT;
        spec1.PRM_Inactive_Ind__c=false;
        insert spec1;

        // -------- Account–Specialty Association -------- 
        PRM_Account_Specialty_Association__c asaRec =
            new PRM_Account_Specialty_Association__c(
                //Name = 'Cloud Association',
                PRM_Account_Id__c = acc.Id,
                PRM_Specialty_Id__c = spec1.Id,
                PRM_InActive_Ind__c = false,
                PRM_Partner_Role__c='Service Provider'
                //PRM_Specialty_Type__c = 'Primary'
            );
        insert asaRec;

        // -------- Re-query Account WITH child relationship -------- 
        Account accWithChildren = [
            SELECT Id,
                   (SELECT Id,
                           Name,
                           PRM_InActive_Ind__c,
                           PRM_Specialty_Type__c,
                           PRM_Specialty_Id__r.Name,
                           PRM_Specialty_Id__r.PRM_Role_Nm__c,
                           PRM_Specialty_Id__r.PRM_Tier_Nm__c
                    FROM Account_Specialty_Associations__r)
            FROM Account
            WHERE Id = :acc.Id
        ];

        // -------- Execute -------- 
        Test.startTest();
        List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation> results =
            PRM_Account_Contact_Profiles_Utility.getAccountSpecialityAssociations(accWithChildren);
        Test.stopTest();

        //-------- Assertions -------- 
        System.assertEquals(1, results.size(), 'One association expected');

        PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation result =
            results[0];

        //System.assertEquals('Cloud Association', result.Name);
        System.assertEquals(false, result.IsInactive);
        System.assertEquals('Video Specialty', result.SpecialityName);
        System.assertEquals('Service Provider', result.SpecialityRole);
        System.assertEquals('Gold', result.SpecialityTier);
        //System.assertEquals('Primary', result.SpecialityType);

        // Label assertion is org-dependent (picklist labels)
        System.assertNotEquals(
            null,
            result.SpecialityRoleLabel,
            'Role label should be populated'
        );
    }
   */
   
}