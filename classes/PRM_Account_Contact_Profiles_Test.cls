@isTest
public class PRM_Account_Contact_Profiles_Test {
    
    @testSetup
    private static void createData(){
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> lstAccts = new List<Account>();
            
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
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
            //System.debug('acc ='+acc);
            acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_CIM_ID__c='12345';
            updatedAcct.add(acc);
        }
        
        //Get Contact Record Type
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456');
        insert cnt;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Member',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved');
        insert acm;
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c(Name='IPA Program',PRM_Agreement_Category_Nm__c='Intel Insider Cloud All Agreements',
                                                                PRM_Agreement_Cd__c='IPAPRGM',PRM_Channel_Program_Id__c=cp.Id);
        insert pa;        
       
        
        PRM_AccountLegalAgreemntAssociation__c legalAgrmnt = new PRM_AccountLegalAgreemntAssociation__c();       
        legalAgrmnt.PRM_Account_Id__c = partnerAccount1.Id;
        legalAgrmnt.PRM_Agreement_Sign_Dt__c = system.now();
        legalAgrmnt.PRM_Partner_Agreement_Id__c = pa.Id;
        legalAgrmnt.PRM_Contact__c = cnt.Id;
        insert legalAgrmnt;        
        
        PRM_Specialty__c specialty = new PRM_Specialty__c();
        specialty.Name = 'Test Specialty';        
        specialty.PRM_Access_Level_Nm__c = 'Public';
        specialty.PRM_Role_Nm__c = 'Service Provider';
        specialty.PRM_Tier_Nm__c = 'Gold';
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
        benefit.Name = 'TESTBENEFIT1';
        benefit.PRM_Channel_Program_Id__c = cp.Id;
        benefit.PRM_Benefit_Cd__c = 'BFTSECLIB';
        benefit.PRM_Benefit_Type_Nm__c = 'Sales';
        insert benefit;
        
        PRM_PartnerType__c partnerType = new PRM_PartnerType__c();
        partnerType.PRM_channelprogram__c = cp.Id;
        partnerType.PRM_PartnerRoleCode__c = 'Service Provider';
        partnerType.PRM_Role_Name__c = 'Service Provider';
        partnerType.PRM_PartneryTypeCode__c = 'CloudServiceProvider';
        partnerType.Name = 'Cloud Service Provider (CSP)';
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
        /*   
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = partnerAccount1.Id;
        aba.PRM_Partner_Benefit_Id__c = benefit.Id;
        aba.PRM_Source__c = 'Specialty';        					 
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        */
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
        contRel.Name = 'Works for';
        contRel.PRM_Contact_Relationship_Cd__c = 'CONTRELWORKSFOR';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = partnerAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        
        Core_Entitlement__c coreEntitlement = new Core_Entitlement__c();
        coreEntitlement.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        coreEntitlement.Core_IsActive__c = True;
        coreEntitlement.Core_Display_Name__c = 'TESTENTITLEMENT';
        insert coreEntitlement;
        
        Core_Contact_Entitlement__c contEntitlement = new Core_Contact_Entitlement__c();
        contEntitlement.Core_Contact_Id__c = cnt.Id;
        contEntitlement.Core_Entitlement_Id__c = coreEntitlement.Id;
        contEntitlement.Core_Unique_Id__c = 'TESTENTITLEMENT';
        
        
        PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
        ps.PRM_InActive_Ind__c = false;
        ps.Name = 'Intel® Cloud Insider Events and Tradeshows';
        ps.PRM_Subscription_Cd__c = 'IPASUB';
        insert ps;
        
        PRM_ContactSubscriptionAssociation__c contSub = new PRM_ContactSubscriptionAssociation__c();
        contSub.PRM_Contact_Id__c = cnt.Id;
        contSub.PRM_Partner_Subscription_Id__c = ps.Id;
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
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = partnerAccount1.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        pr.PRM_InActive_Ind__c = false;
        pr.PRM_Response_Txt__c = 'SampleResponse';   
        insert pr;
        
        //system.debug('DML Limit==>'+Limits.getDMLStatements()+':::'+Limits.getLimitDmlStatements());        
        Test.startTest();
        insert contEntitlement;
        Database.Update(updatedAcct);      
        Test.stopTest();        
    }   
    
    /*********************** GetRegRequestAccountProfile Test ******************************/
     private static testMethod void GetRegRequestAccountProfileTest(){
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
         
        PRM_Registration_Request__c acctReq = [Select id,PRM_Email_ID__c From PRM_Registration_Request__c LIMIT 1]; 
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
         
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+acctReq.PRM_Email_ID__c+'"}}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles  profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ContactAccount != null || profiles.AccountRequest != null );
         
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
         
        PRM_Registration_Request__c acctReq = [Select id,PRM_Email_ID__c From PRM_Registration_Request__c LIMIT 1]; 
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
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
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"'+cont.Id+'"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ContactAccount != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+cont.EMail+'"},"Attribute":"PERSONACCOUNT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ContactAccount != null);
        
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
        system.assert(profiles.ErrorMsg != null ||profiles.ExceptionDetails != null );
        
        test.stopTest();
    }
    /*********************** End of Person Account Test *************************************/
    /*********************** Business Person Account Test ***********************************/
    private static testMethod void getBusinessPersonTest(){       
        
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
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
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"'+acct.Id+'"},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        reqBody = '{"KeyInput":{"InputField":"ContactId","InputValue":"TESTRECID "},"Attribute":"BUSINESSPERSON"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.ErrorMsg != null || profiles.ExceptionDetails != null);
        
        test.stopTest();
    }
    /*********************** End of Business Person Test ***********************************/
    /*********************** Account Result Test ******************************************/
    private static testMethod void getAccountResultTest(){       
        String strJSON = '';
        String reqBody = '';
      
        test.startTest();
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
    
        reqBody = '{"KeyInput":{"InputField":"CIMID","InputValue":"'+acct.Core_CIM_ID__c+'"},"Attribute":"ACCOUNTRESULT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountResults != null);
        
        //************************** Negative Test Cases        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'Test"},"Attribute":"ACCOUNTRESULT"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountResults.Status == 'Error');
        
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
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
        Contact cont = [Select id,Email,Core_Enterprise_Id__c,Core_Login_Id__c From Contact LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"AccountId","InputValue":"'+acct.Id+'"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountProfile != null);
        
        system.debug('acct.Core_CIM_ID__c ===>'+acct.Core_CIM_ID__c);
        reqBody = '{"KeyInput":{"InputField":"CIMID","InputValue":"'+acct.Core_CIM_ID__c+'"},"Attribute":"ACCOUNTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.AccountProfile != null);
        
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
        system.assert(profiles.OnePartnerIDGroupMembers != null);
        
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
        Account acct = [Select id,Core_CIM_ID__c From Account LIMIT 1];
        RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--crmdevint2.cs93.my.salesforce.com/services/apexrest/GetProfile/';
        request.requestUri = '/services/apexrest/GetProfile/';
        request.httpMethod = 'POST';
        
        reqBody = '{"KeyInput":{"InputField":"RequestId","InputValue":"'+acctReq.Id+'"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        PRM_Account_Contact_Profiles_Model.Profiles profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.RegistrationRequestProfile != null);
        
        reqBody = '{"KeyInput":{"InputField":"EMAILID","InputValue":"'+acctReq.PRM_Email_ID__c+'"},"Attribute":"REGREQUESTPROFILE"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        profiles = PRM_Account_Contact_Profiles.GetProfiles(); 
        system.assert(profiles.RegistrationRequestProfile != null);
         
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
}