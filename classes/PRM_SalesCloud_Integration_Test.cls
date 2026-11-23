@isTest
public class PRM_SalesCloud_Integration_Test {
    
    @TestSetup
    private static void createData(){
        String partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        List<Account> lstAccts = new List<Account>();
            
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor', /*Core_Sales_Groups__c= 'PRC Sales Group',*/
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='USA',BillingStreet='abc chowk delhi',BillingState='FL',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId(),
                                             Core_User_Defined_Website__c = 'www.testpartacc.com', Core_IPA_Partner_Role__c = 'Distributor');
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)', /*Core_Sales_Groups__c= 'PRC Sales Group',*/
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='cbc chowk delhi',BillingState='FL',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,
                                           Core_User_Defined_Website__c = 'www.testintelacc.com', Core_IPA_Partner_Role__c = 'Distributor');
        lstAccts.add(intelAccount1);
        Database.insert(lstAccts);
        
        partnerAccount1.Core_PMP_Membership_Change_Ind__c = false;
        Database.update(partnerAccount1);
        List<Account> updatedAcct= new List<Account>();
        for(Account acc:[SELECT ID,NAME,Core_Account_Type__c,Core_IPA_Partner_Role__c FROM ACCOUNT]){
            
            acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
            acc.Core_CIM_ID__c='12345';
            updatedAcct.add(acc);
        }
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c = partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c = intelAccount1.Id;
        accGroupMem.Core_Inactive_Ind__c = false;
        accGroupMem.Core_MDA_Ind__c = false;
        Database.insert(accGroupMem);
        
        
        //Get Contact Record Type
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Core_English_Only_First_Name__c = 'Test',Core_English_Only_Last_Name__c='Contact1',Email='testcontact1@spamok.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456', Core_IPA_PartnerRole__c = 'Distributor');
        insert cnt;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Partner',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c = 'Test class');
        insert acm;
         PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=intelAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c = 'Test class');
        insert acm1;
        
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
        specialty.name='Select Benefits';       
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
        benefit.Name = 'Advanced Warranty Replacement';
        benefit.PRM_Channel_Program_Id__c = cp.Id;
        benefit.PRM_Benefit_Cd__c = 'AWR';
        benefit.PRM_Benefit_Type_Nm__c = 'Sales';
        benefit.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert benefit;
        
        PRM_PartnerBenefit__c benefit1 = new PRM_PartnerBenefit__c();
        benefit1.Name = 'Standard Warranty Replacement';
        benefit1.PRM_Channel_Program_Id__c = cp.Id;
        benefit1.PRM_Benefit_Cd__c = 'SWR';
        benefit1.PRM_Quantitative_Ind__c = true;//RT
        benefit1.PRM_InActive_Ind__c = false;//RT
        benefit1.PRM_Benefit_Type_Nm__c = 'Sales';
        benefit1.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert benefit1;
        
        PRM_PartnerBenefit__c benefit2 = new PRM_PartnerBenefit__c();
        benefit2.Name = 'Customer Support- 48Hr SLA';
        benefit2.PRM_Channel_Program_Id__c = cp.Id;
        benefit2.PRM_Benefit_Cd__c = 'BNFTCS48S';
        benefit2.PRM_Benefit_Type_Nm__c = 'Sales';
        benefit2.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert benefit2;
        
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
        
        PRM_VXBnftMatrix__c benefitMatrix1 = new PRM_VXBnftMatrix__c();
        benefitMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        benefitMatrix1.PRM_Covered_Account_Ind__c = true;
        benefitMatrix1.PRM_IsActive_Ind__c = true;
        benefitMatrix1.PRM_Partner_Benefit_Id__c = benefit2.Id;
        benefitMatrix1.PRM_Channel_Program_Id__c = cp.Id;
        benefitMatrix1.PRM_Partner_Role_Nm__c = 'Service Provider';
        benefitMatrix1.PRM_Channel_Program_Level_Id__c = partnerTier.Id;
        benefitMatrix1.PRM_Partner_Type_Id__c = partnerType.Id;
        insert benefitMatrix1;

        PRM_VXBnftMatrix__c benefitMatrix2 = new PRM_VXBnftMatrix__c();//RT-start
        benefitMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        benefitMatrix2.PRM_Covered_Account_Ind__c = true;
        benefitMatrix1.PRM_IsActive_Ind__c = true;
        benefitMatrix2.PRM_Partner_Benefit_Id__c = benefit1.Id;
        benefitMatrix2.PRM_Channel_Program_Id__c = cp.Id;
        benefitMatrix2.PRM_Partner_Role_Nm__c = 'Service Provider';
        benefitMatrix2.PRM_Channel_Program_Level_Id__c = partnerTier.Id;
        benefitMatrix2.PRM_Partner_Type_Id__c = partnerType.Id;
        insert benefitMatrix2;//RT-end
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='partner;prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solution Marketplace Enhanced';
        insert bm; 
          
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = partnerAccount1.Id;
        aba.PRM_Partner_Benefit_Id__c = benefit.Id;
        aba.PRM_Source__c = 'Tier';                          
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c = 'Testclass';
        insert aba;

        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c();
        aba2.PRM_Account_Id__c = partnerAccount1.Id;
        aba2.PRM_Partner_Benefit_Id__c = benefit1.Id;
        aba2.PRM_Source__c = 'Tier';                             
        aba2.PRM_Status_Nm__c = 'Active';
        aba2.PRM_Status_Reason_Txt__c = 'Testclass';
        insert aba2;
        
        PRM_AccountBenefitAssociation__c aba3 = new PRM_AccountBenefitAssociation__c();
        aba3.PRM_Account_Id__c = partnerAccount1.Id;
        aba3.PRM_Partner_Benefit_Id__c = benefit2.Id;
        aba3.PRM_Source__c = 'Tier';                             
        aba3.PRM_Status_Nm__c = 'Active';
        aba3.PRM_Status_Reason_Txt__c = 'Testclass';
        insert aba3;
        
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
        
             
        // WhiteList 
        Core_Account_Whitelisted_Domains__c whiteList = new Core_Account_Whitelisted_Domains__c();
        whiteList.Name = 'Intel Account';
        whiteList.Partner_Program__c = channelPrograms[0].Id;
        whiteList.Account__c = partnerAccount1.Id ;
        insert whiteList;
        
        /*
        PRM_Partner_Assist_Consent__c partnerAssist = new PRM_Partner_Assist_Consent__c();
        partnerAssist.PRM_Account_Id__c = partnerAccount1.Id;
        //partnerAssist.Name = 'Intel';
        insert partnerAssist;
        */
        
        
        Core_Entitlement__c coreEntitlement = new Core_Entitlement__c();       
        coreEntitlement.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        coreEntitlement.Core_IsActive__c = True;
        coreEntitlement.Core_Display_Name__c = 'Lead Development Representative';
        coreEntitlement.Name = 'Lead Development Representative';
        insert coreEntitlement;
        
        Core_Entitlement__c coreEntitlement1 = new Core_Entitlement__c();       
        coreEntitlement1.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        coreEntitlement1.Core_IsActive__c = True;
        coreEntitlement1.Core_Display_Name__c = 'TESTENTITLEMENT';
        insert coreEntitlement1;
        
        
        PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
        ps.PRM_InActive_Ind__c = false;
        ps.Name = 'Intel® Cloud Insider Events and Tradeshows';
        ps.PRM_Subscription_Cd__c = 'IPASUB';
        insert ps;
        
        PRM_ContactSubscriptionAssociation__c contSub = new PRM_ContactSubscriptionAssociation__c();
        contSub.PRM_Contact_Id__c = cnt.Id;
        contSub.PRM_Partner_Subscription_Id__c = ps.Id;
        contSub.PRM_Status_Nm__c = 'Active';
        contSub.PRM_Status_Reason_Txt__c = 'Test class';
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
        
        /*PRM_CIMSearchResults__c cimSearchRes = new PRM_CIMSearchResults__c();
        cimSearchRes.PRM_RegReq_Id__c = acctReq.Id;
        cimSearchRes.PRM_Account_Id__c = partnerAccount1.Id;
        cimSearchRes.PRM_CIM_Id__c = '12345';
        insert cimSearchRes;
        
        
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c();
        tc.Name = 'Test T&C';
        tc.PRM_Registration_Requests__c = acctReq.Id;
        tc.PRM_Partner_Agreement__c = pa.Id;
        insert tc;
        */
        
        /*Subscription__c subscription = new Subscription__c();
        subscription.PRM_Partner_Subscription__c = ps.Id;
        subscription.PRM_RegistrationRequest__c = acctReq.id;
        subscription.Name = 'Test Subscription';
        insert subscription;*/
        
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
        
               
        Test.startTest(); 
        Core_Contact_Entitlement__c contEntitlement = new Core_Contact_Entitlement__c();
        contEntitlement.Core_Contact_Id__c = cnt.Id;
        contEntitlement.Core_Entitlement_Id__c = coreEntitlement.Id;
        contEntitlement.Core_Unique_Id__c = 'TESTENTITLEMENT';
        //insert contEntitlement;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = partnerAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_Status_Reason_Txt__c='Test';
        
        insert acr;
        
        PRM_Partner_Assist_Consent__c pac = new PRM_Partner_Assist_Consent__c();
       // pa.DistributorName = partnerConsent.PRM_Distributor_Id__r.Name;
        pac.PRM_Account_Id__c = partnerAccount1.Id;
        pac.PRM_Choice_Nm__c = 'Partner Assist Choice 1' ;
        pac.PRM_Consent_Provided_By_Id__c = cnt.Id;
        pac.PRM_Consent_Provided_Date_Dt__c = System.today()-10;
        pac.PRM_Start_Date_Dt__c = System.today()-5;
        pac.PRM_End_Date_Dt__c = system.today()+365;
        pac.PRM_Consent_Provided_Ind__c = true;
        
        insert pac;
     //   Database.Update(updatedAcct);   
        Test.stopTest();
        
    } 
    @isTest
    private static void SetAccountIPAIntegrationStatusToPending_test(){
        List<PRM_AccountBenefitAssociation__c> accBenList =[select id,PRM_Account_Id__c from PRM_AccountBenefitAssociation__c];
        List<Core_Account_Whitelisted_Domains__c> accWhitlist = [Select id, account__c from Core_Account_Whitelisted_Domains__c];
        List<PRM_Partner_Assist_Consent__c> partnerAssistList = [Select id, PRM_Account_Id__c,PRM_InActive_Ind__c from PRM_Partner_Assist_Consent__c];
        List<PRM_Profile_Responses__c> profileRespList = [Select id, PRM_Account_Id__c from PRM_Profile_Responses__c];
        List<PRM_AccountChannelMembership__c> acmList = [Select id, PRM_Account_Id__c from PRM_AccountChannelMembership__c];
        Test.startTest();
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(accBenList);
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(accWhitlist);
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(partnerAssistList);
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(profileRespList);
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending(acmList);
        Test.stopTest();
    }
    

    @isTest
    private static void SetAccountIPAIntegrationStatusToPendingOnUpdate_Test() {
        String partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            
        Account oldAccount = new Account(Name ='newAccount', RecordTypeId=partnerAccRecTypeId ,Core_CIM_ID__c='71172212',BillingStreet='abc chowk delhi',BillingCity='delhi',BillingState='FL',BillingCountry='USA',BillingPostalCode='Postal code' ,Core_Account_Type__c = 'Distributor', 
                                             Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId(), Core_IPA_Partner_Segment__c= 'Client Computing' ,Core_IPA_Partner_Role__c = 'Distributor',Core_IPA_Badge_Tier__c = 'Partner',PRM_IPA_Integration_Status__c = 'Successful' );
        Test.startTest();
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        List<Account> acctList = new List<Account>();
        Account newAccount = new Account();
        newAccount.Name='John Rick';
        newAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        newAccount.Core_CIM_ID__c='875390';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingState='IL';
        newAccount.BillingCountry='USA';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Core_IPA_Partner_Segment__c= 'Internet of Things and Embedded';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';
        newAccount.Core_IPA_Badge_Tier__c = 'Partner';
        newAccount.PRM_IPA_Integration_Status__c = 'Successful';
        insert newAccount;
        accountsMap.put(newAccount.Id, newAccount);
        acctList.add(newAccount);
        acctList[0].Core_IPA_Badge_Tier__c= 'Partner';
        acctList[0].PRM_IPA_Integration_Status__c= 'Pending';
        update acctList[0];
        Set<Id> accountIds = new Set<Id>{newAccount.Id};
        
        
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOnUpdate(acctList, accountsMap, accountIds);
        Test.stopTest();
    }
    
    
    @isTest
    private static void GenerateAccountOBM_Test(){
        test.startTest();
        Core_CustomMetadata_Object__c cust = new Core_CustomMetadata_Object__c(Program__c='IPA',DeveloperName__c='DeveloperName',Field_1__c='BenefitCode__c',Field_2__c='OperationCode__c',Field_3__c='BenefitCommonName__c',MasterLabel__c='MasterLabel',Metadata_Name__c='PRM_Warranty_Benefits_Configuration__mdt');
        insert cust;
        
        Core_CustomMetadata_Object__c cust1 = new Core_CustomMetadata_Object__c(Program__c='IPA',DeveloperName__c='X4HrSLA',Field_1__c='BNFTCS4S',Field_2__c='low',Field_3__c='SLA',Header_row__c=cust.id,MasterLabel__c='4HrSLA',Metadata_Name__c='PRM_Warranty_Benefits_Configuration__mdt');
        insert cust1;
        Map<Id,Account> acctList = new Map<Id,Account>([SELECT Id FROM Account]);
        Set<Id> acctIds = new Set<Id>();
        acctIds.addAll(acctList.keySet());
        PRM_SalesCloud_Integration.GenerateAccountOBM(acctIds);
        Account acct = [SELECT id,Name,PRM_IPA_Integration_Status__c FROM Account WHERE id= :(new List<Id>(acctIds) )[0]];
        system.assertEquals('Successful', acct.PRM_IPA_Integration_Status__c);
        test.stopTest();
    }   
     @isTest
    private static void GenerateAccountASA_Test(){
        test.startTest();
         Account acctList = [SELECT Id, (SELECT Name,PRM_Start_Date_Dt__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c,PRM_Specialty_Type__c FROM Account_Specialty_Associations__r) FROM Account where Name ='PartnerAccount1' LIMIT 1];
    
        PRM_SalesCloud_Integration.getAccountSpecialityAssociations(acctList);
        test.stopTest();
    }   
    @isTest
    private static void GenerateContactOBM_Test(){
        test.startTest();
        List<Contact> contactList = [SELECT Id FROM Contact];
        Set<Id> contactId = new Set<Id>();
        contactId.add(contactList[0].Id);
        PRM_SalesCloud_Integration.GenerateContactOBM(contactId);
        Contact cont = [SELECT id,Name,PRM_IPA_Integration_Status__c FROM Contact WHERE id= :(new List<Id>(contactId) )[0]];
        //system.assertEquals('Successful', cont.PRM_IPA_Integration_Status__c);
        test.stopTest();
    }
    
    
    @isTest
    private static void EmptyAddress_Test(){        
        String partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acct = new Account(Name ='Account No Address',Core_Account_Type__c = 'Distributor', /*Core_Sales_Groups__c= 'PRC Sales Group',*/
                                   Industry='Agriculture',RecordTypeId=partnerAccRecTypeId,Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId());
        test.startTest();
        insert acct;        
        Set<Id> idSet = new Set<Id>();
        idSet.add(acct.Id); 
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='NoAddress',LastName='Check',Email='noaddresscheck@spamok.com',AccountId=acct.Id,RecordTypeId=IntelContRecTypeId,MailingCountry='IND');
        insert cnt;       
        idSet.add(cnt.Id);
        PRM_SalesCloud_Integration.GenerateContactOBM(idSet);
        //PRM_SalesCloud_Integration_ForTesting salesCloudInteg = new PRM_SalesCloud_Integration_ForTesting();
        Contact cont = [SELECT id,Name,PRM_IPA_Integration_Status__c FROM Contact WHERE id= :cnt.Id];
        //system.assertEquals('Successful', cont.PRM_IPA_Integration_Status__c);
        test.stopTest();
    }
    @isTest
    private static void Eexception_Test(){
        test.startTest();
        
        PRM_SalesCloud_Integration_Model.AEAccountInformation aeAccountInformation = new PRM_SalesCloud_Integration_Model.AEAccountInformation();
        aeAccountInformation.name = 'AEInfoTest';
        aeAccountInformation.AccountNo = '12345';
        aeAccountInformation.PrimeAccountName = '12345';
        aeAccountInformation.SalesGroup = 'NA';
        aeAccountInformation.Industry = 'NA';
        aeAccountInformation.CoveredAccount = false;
        aeAccountInformation.CNDANumber = '12345';
        aeAccountInformation.CIMId = '12345';
        aeAccountInformation.UnifiedID = '12345';
        aeAccountInformation.BusinessPartnerId = '12345';
        aeAccountInformation.BusinessId = '12345';
        aeAccountInformation.BizOrgType = 'NA';
        aeAccountInformation.PartnerRole = 'NA';
        aeAccountInformation.Region = 'NA';
        aeAccountInformation.SubRegion = 'NA';
        aeAccountInformation.UserDefinedPhoneNumber = '12345';
        aeAccountInformation.UserDefinedWebsite = 'NA';
        aeAccountInformation.EnglishNameOnly = 'NA';
        aeAccountInformation.PartnerProgramSegment = 'NA';
        aeAccountInformation.PartnerProgramSpecialty = 'NA';
        aeAccountInformation.AccountLegalName = 'NA';
        aeAccountInformation.AccountBUFocus = 'NA';
        aeAccountInformation.OnePartnerIdAccountName = 'NA';    
        aeAccountInformation.RecordType = 'NA';     
        aeAccountInformation.BadgeTier = 'NA';
        aeAccountInformation.Deactivated = false; 
        aeAccountInformation.DeactivatedReason = 'NA';
        aeAccountInformation.IsIPA = false;
        aeAccountInformation.IsODM = false;
        aeAccountInformation.PAGAccountId = '12345';

        PRM_SalesCloud_Integration_Model.AccountBasicInformation accbasicinfo = new PRM_SalesCloud_Integration_Model.AccountBasicInformation();
        accbasicinfo.Name = 'AccBasicInfoTest';
        accbasicinfo.AccountNo = '12345';
        accbasicinfo.PrimeAccountName = 'AccBasicInfoTest';
        accbasicinfo.BusinessPartnerId = '12345';
        accbasicinfo.BusinessId = '12345';

        PRM_SalesCloud_Integration_Model.AccountAEPayload accAEPayload = new PRM_SalesCloud_Integration_Model.AccountAEPayload();
        accAEPayload.MessageType = 'NA';
        accAEPayload.AccountId = '12345';
        accAEPayload.AccountStatus = 'NA';
        accAEPayload.LastModifiedBy = 'NA';
        accAEPayload.CreatedBy = 'NA';

        PRM_SalesCloud_Integration_Model.DSAPayload dsapay = new PRM_SalesCloud_Integration_Model.DSAPayload();
        dsapay.AccountId = '12345';
        dsapay.AccountStatus = 'NA';
        dsapay.ContactStatus = 'NA';
        dsapay.DeletionReason = 'NA';
        dsapay.MessageType = 'NA';

        PRM_SalesCloud_Integration_Model.cmfWrapper cmfwrap = new PRM_SalesCloud_Integration_Model.cmfWrapper();
        cmfwrap.GroupName = 'NA';
        cmfwrap.GroupId = 'NA';
        cmfwrap.Description = 'NA';
        cmfwrap.Active = false;
        cmfwrap.ActiveCMFCount = 'NA';
        cmfwrap.InActiveCMFCount = 'NA';
        cmfwrap.ActiveContactCount = 'NA';
        cmfwrap.InActiveContactCount = 'NA';
        cmfwrap.LastModifiedBy  = 'NA';
        cmfwrap.CreatedBy  = 'NA';

        PRM_SalesCloud_Integration_Model.cmfWrapperAnE cmfwrapane = new PRM_SalesCloud_Integration_Model.cmfWrapperAnE();
        cmfwrapane.MessageType = 'NA';
        cmfwrapane.GroupName = 'NA';
        cmfwrapane.GroupId = 'NA';
        cmfwrapane.Description = 'NA';
        cmfwrapane.Active = false;
        cmfwrapane.ActiveCMFCount = 'NA';
        cmfwrapane.InActiveCMFCount = 'NA';
        cmfwrapane.ActiveContactCount = 'NA';
        cmfwrapane.InActiveContactCount = 'NA';
        cmfwrapane.LastModifiedBy = 'NA';
        cmfwrapane.CreatedBy = 'NA';

        PRM_SalesCloud_Integration_Model.cmfData cmfd = new PRM_SalesCloud_Integration_Model.cmfData();
        cmfd.CMFID = 'NA';
        cmfd.Name = 'NA';
        cmfd.SalesOrgCode = 'NA';
        cmfd.SalesOrgName = 'NA';
        cmfd.SalesDistiChannelCode = 'NA';
        cmfd.SalesDistiChannelName = 'NA';
        cmfd.Address = 'NA';
        cmfd.AccountGroup = 'NA';
        cmfd.DirectCustomerRoleName = 'NA';
        cmfd.DirectCustomerRoleCode = 'NA';

        PRM_SalesCloud_Integration_Model.ContactBasicInfoAE contbasicinfae = new PRM_SalesCloud_Integration_Model.ContactBasicInfoAE();
        contbasicinfae.FirstName = 'NA';
        contbasicinfae.LastName  = 'NA';
        contbasicinfae.AccountName  = 'NA';
        contbasicinfae.AccountId  = 'NA';
        contbasicinfae.Email  = 'NA';
        contbasicinfae.EnterpriseId  = 'NA';
        contbasicinfae.LastModifiedBy  = 'NA';
        contbasicinfae.CreatedBy  = 'NA';

        PRM_SalesCloud_Integration_Model.ContactBusinessType contbis = new PRM_SalesCloud_Integration_Model.ContactBusinessType();
        contbis.Name = 'NA';
        contbis.BusinessTypeCode  = 'NA';
        contbis.BusinessTypeCategory = 'NA';
        contbis.IsActive  = false;
        contbis.Status  = 'NA';
        contbis.StatusReason  = 'NA';
        contbis.PendingRegistration = false;

        PRM_SalesCloud_Integration_Model.AccountBusinessType accbis = new PRM_SalesCloud_Integration_Model.AccountBusinessType();
        accbis.Name = 'NA';
        accbis.BusinessTypeCode  = 'NA'; 
        accbis.IsActive  = false;
        accbis.Status  = 'NA';
        accbis.StatusReason  = 'NA';

        PRM_SalesCloud_Integration_Model.ContactEntitlement content = new PRM_SalesCloud_Integration_Model.ContactEntitlement();
        content.Name = 'NA';
        content.Type = 'NA';
        content.Status = 'NA';
        content.IsSelected = false;

        PRM_SalesCloud_Integration_Model.ContactEntitlementAnE contentae = new PRM_SalesCloud_Integration_Model.ContactEntitlementAnE();
        contentae.Name = 'NA';
        contentae.Type = 'NA';
        contentae.Status = 'NA';
        contentae.IsSelected = false;

        PRM_SalesCloud_Integration_Model.WarrantyOld oldwarranty = new PRM_SalesCloud_Integration_Model.WarrantyOld('NA','NA');
        
        /*
        Set<ID> accids=new Set<ID>();
        Set<ID> conids=new Set<ID>();
        List<Contact>conts=new List<Contact>();
        String partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Account acct = new Account(Name ='Account For Exception',Core_Account_Type__c = 'Distributor', /*Core_Sales_Groups__c= 'PRC Sales Group',
                                   Industry='Agriculture',RecordTypeId=partnerAccRecTypeId,Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId());
        insert acct;
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcont001@spamok.com',AccountId=acct.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456', Core_IPA_PartnerRole__c = 'Manufacturer');
        insert cnt;
        conids.add(cnt.id);
        conts.add(cnt);
        Exception exception1;
        //exception1.setMessage('my message');
        ER_Customer_Master_File_Group__c testCMFGroup = new ER_Customer_Master_File_Group__c(Name='testCMFGroup',ER_Active__c=true);
        insert testCMFGroup;
        Set<ID> ercmids= new Set<ID>();
        ercmids.add(testCMFGroup.id);
        List<ER_Customer_Master_File_Group__c> cmfids= new List<ER_Customer_Master_File_Group__c>();
        cmfids.add(testCMFGroup);
        test.startTest();
        //PRM_SalesCloud_Integration.GenerateCMFOutboundMessage(ercmids);
        //List<PRM_SalesCloud_Integration_Model.cmfWrapper> cmflist=PRM_SalesCloud_Integration.getCMFDetails(cmfids);
        accids.add(acct.id);
        //Core_Log_Entry__c cle=PRM_SalesCloud_Integration.createLogEntry('Exception',exception1,acct.id,'tags','low','Account'); //RT-commented
        PRM_SalesCloud_Integration.GenerateAnEAccountOBM(accids); //RT-Comment removed
        PRM_SalesCloud_Integration.GenerateContactOutboundMessage(conts);
        PRM_SalesCloud_Integration.GenerateContactOBMAnE(conids); // RT-Comment removed
        */
        test.stopTest();
    }
    /*
    @isTest
    private static void GenerateCMFOutboundTest(){
        Set<ID> accids=new Set<ID>();
        Set<ID> conids=new Set<ID>();
        List<Contact>conts=new List<Contact>();
        Account testAccount = new Account(Name='testAccountSetup',Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',BillingCountry='USA', BillingPostalCode='12345',
                                          ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_CNDA_Number__c = '126545');
        insert testAccount;
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact testContact = new Contact(FirstName='test',LastName='Contact1',RecordTypeId=IntelContRecTypeId, Email='testcontacterpmc00@spamok.com',
                                          AccountId=testAccount.id,MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456',Core_English_Only_First_Name__c = 'Joy',Core_Enterprise_Id__c='12345',Core_English_Only_Last_Name__c = 'Trump');
        insert testContact;
        conts.add(testContact);
        conids.add(testContact.id);
        testContact.Core_Login_Status__c ='Active';
        update testContact;
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
        insert business;
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
         insert bType;
        ER_Customer_Master_File_Group__c testCMFGroup = new ER_Customer_Master_File_Group__c(Name='testCMFGroup',ER_Active__c=true);
        insert testCMFGroup;
        ER_Customer_Master_File__c cmf= new ER_Customer_Master_File__c();
        cmf.Name='testCmfName';
        cmf.ER_CMF_Name__c='testCMF';
        cmf.ER_Sales_Disti_Chnl_Code__c='EU02';
        insert cmf;
        ER_CMFGroupAssociation__c cmfAssoc= new ER_CMFGroupAssociation__c();
           cmfAssoc.ER_Customer_Master_File__c=cmf.Id;
            cmfAssoc.ER_Customer_Master_File_Group__c=testCMFGroup.Id;
        insert cmfAssoc;
        Set<ID> ercmids= new Set<ID>();
        ercmids.add(testCMFGroup.id);
        List<ER_Customer_Master_File_Group__c> cmfids= new List<ER_Customer_Master_File_Group__c>();
        cmfids.add(testCMFGroup);
        ER_Customer_Master_File_Group__c cmfGroup= new ER_Customer_Master_File_Group__c();
            cmfGroup.Name= 'testName0';
        insert cmfGroup;
        ER_ContactGroupAssociation__c conAssoc = new ER_ContactGroupAssociation__c();
            conAssoc.ER_Contact__c = testContact.id;
            conAssoc.ER_Customer_Master_File_Group__c = testCMFGroup.id;
            insert conAssoc;
       
        /*List<ER_Customer_Master_File_Group__c> ercm=[select id from ER_Customer_Master_File_Group__c limit 5];
        for(ER_Customer_Master_File_Group__c rec:ercm)
        {
            ercmids.add(rec.id);
        }
        test.startTest();
        PRM_SalesCloud_Integration.GenerateCMFOutboundMessage(ercmids); // RT-removed comment
        PRM_SalesCloud_Integration.GenerateContactOutboundMessage(conts);
        PRM_SalesCloud_Integration.GenerateContactOutboundMessageAnE(conts); // RT-removed comment
        //List<PRM_SalesCloud_Integration_Model.cmfWrapper> cmflist=PRM_SalesCloud_Integration.getCMFDetails(cmfids);
        //PRM_SalesCloud_Integration_Model.ContactBusinessType ContactBusinessType = new PRM_SalesCloud_Integration_Model.ContactBusinessType();
          //  ContactBusinessType.Name = 'testContact.Business_Types__r.Name';
           // ContactBusinessType.BusinessTypeCode ='testContact.Business_Types__r.Business_Type_Code__c';
           // ContactBusinessType.BusinessTypeCategory ='testContact.Business_Types__r.Business_Types_Category__c' ;
            //ContactBusinessType.IsActive = True;
            //ContactBusinessType.Status = 'testContact.Status__c';
            //ContactBusinessType.StatusReason = 'testContact.Status_Reason__c';
            //ContactBusinessType.PendingRegistration = false;
         //PRM_SalesCloud_Integration_Model.AccountBusinessType AccountBusinessType= new PRM_SalesCloud_Integration_Model.AccountBusinessType();
        //AccountBusinessType.Name = 'abt.Business_Types__r.Name';
            //AccountBusinessType.BusinessTypeCode ='abt.Business_Types__r.Business_Type_Code__c';
            //AccountBusinessType.IsActive = True;
            //AccountBusinessType.Status = 'abt.Status__c';
            //AccountBusinessType.StatusReason = 'abt.Status_Reason__c';
            //AccountBusinessType.LastModifiedDate =bType.LastModifiedDate;
            //AccountBusinessType.CreatedDate=bType.CreatedDate;
            //AccountBusinessType.LastModifiedBy=bType.LastModifiedBy.Name;
            //AccountBusinessType.CreatedBy=bType.CreatedBy.Name;
        test.stopTest(); 
        } */

    /*
    @isTest
    private static void GenerateCMFOutboundTest(){
        Set<ID> accids=new Set<ID>();
        Set<ID> conids=new Set<ID>();
        List<Contact>conts=new List<Contact>();
        Account testAccount = new Account(Name='testAccountSetup',Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'testAccountSetup',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',BillingCountry='USA', BillingPostalCode='12345',
                                          ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_CNDA_Number__c = '126545');
        insert testAccount;
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact testContact = new Contact(FirstName='test',LastName='Contact1',RecordTypeId=IntelContRecTypeId, Email='testcontacterpmc00@spamok.com',
                                          AccountId=testAccount.id,MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456',Core_English_Only_First_Name__c = 'Joy',Core_Enterprise_Id__c='12345',Core_English_Only_Last_Name__c = 'Trump');
        insert testContact;
        conts.add(testContact);
        conids.add(testContact.id);
        testContact.Core_Login_Status__c ='Active';
        update testContact;
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='DZP', Name='Developer Zone Premier', Is_Active__c = true);
        insert business;
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
         insert bType;
        ER_Customer_Master_File_Group__c testCMFGroup = new ER_Customer_Master_File_Group__c(Name='testCMFGroup',ER_Active__c=true);
        insert testCMFGroup;
        ER_Customer_Master_File__c cmf= new ER_Customer_Master_File__c();
        cmf.Name='testCmfName';
        cmf.ER_CMF_Name__c='testCMF';
        cmf.ER_Sales_Disti_Chnl_Code__c='EU02';
        insert cmf;
        ER_CMFGroupAssociation__c cmfAssoc= new ER_CMFGroupAssociation__c();
           cmfAssoc.ER_Customer_Master_File__c=cmf.Id;
            cmfAssoc.ER_Customer_Master_File_Group__c=testCMFGroup.Id;
        insert cmfAssoc;
        Set<ID> ercmids= new Set<ID>();
        ercmids.add(testCMFGroup.id);
        List<ER_Customer_Master_File_Group__c> cmfids= new List<ER_Customer_Master_File_Group__c>();
        cmfids.add(testCMFGroup);
        ER_Customer_Master_File_Group__c cmfGroup= new ER_Customer_Master_File_Group__c();
            cmfGroup.Name= 'testName0';
        insert cmfGroup;
        ER_ContactGroupAssociation__c conAssoc = new ER_ContactGroupAssociation__c();
            conAssoc.ER_Contact__c = testContact.id;
            conAssoc.ER_Customer_Master_File_Group__c = testCMFGroup.id;
            insert conAssoc;
        
        /*List<ER_Customer_Master_File_Group__c> ercm=[select id from ER_Customer_Master_File_Group__c limit 5];
        for(ER_Customer_Master_File_Group__c rec:ercm)
        {
            ercmids.add(rec.id);
        }
        test.startTest();
        PRM_SalesCloud_Integration.GenerateCMFOutboundMessage(ercmids); // RT-removed comment
        PRM_SalesCloud_Integration.GenerateContactOutboundMessage(conts);
        PRM_SalesCloud_Integration.GenerateContactOutboundMessageAnE(conts); // RT-removed comment
        //List<PRM_SalesCloud_Integration_Model.cmfWrapper> cmflist=PRM_SalesCloud_Integration.getCMFDetails(cmfids);
        //PRM_SalesCloud_Integration_Model.ContactBusinessType ContactBusinessType = new PRM_SalesCloud_Integration_Model.ContactBusinessType();
          //  ContactBusinessType.Name = 'testContact.Business_Types__r.Name';
           // ContactBusinessType.BusinessTypeCode ='testContact.Business_Types__r.Business_Type_Code__c';
           // ContactBusinessType.BusinessTypeCategory ='testContact.Business_Types__r.Business_Types_Category__c' ;
            //ContactBusinessType.IsActive = True;
            //ContactBusinessType.Status = 'testContact.Status__c';
            //ContactBusinessType.StatusReason = 'testContact.Status_Reason__c';
            //ContactBusinessType.PendingRegistration = false;
         //PRM_SalesCloud_Integration_Model.AccountBusinessType AccountBusinessType= new PRM_SalesCloud_Integration_Model.AccountBusinessType();
        //AccountBusinessType.Name = 'abt.Business_Types__r.Name';
            //AccountBusinessType.BusinessTypeCode ='abt.Business_Types__r.Business_Type_Code__c';
            //AccountBusinessType.IsActive = True;
            //AccountBusinessType.Status = 'abt.Status__c';
            //AccountBusinessType.StatusReason = 'abt.Status_Reason__c';
            //AccountBusinessType.LastModifiedDate =bType.LastModifiedDate;
            //AccountBusinessType.CreatedDate=bType.CreatedDate;
            //AccountBusinessType.LastModifiedBy=bType.LastModifiedBy.Name;
            //AccountBusinessType.CreatedBy=bType.CreatedBy.Name;
        test.stopTest(); 
        } */

}