/******************************************************************************************************************************************
Class Name  : ER_SalesCloud_Integration
Test Class Name : ER_SalesCloud_Integration_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 May 2024
Function    : Apex class to generate A&E payloads for Accounts, Contacts, CMFs
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         15/05/2024             Original version 
*****************************************************************************************************************************************/
@isTest
public class ER_SalesCloud_Integration_Test {
    
    @testSetup
    private static void createData(){
        String partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        List<Account> lstAccts = new List<Account>();
            
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',/*Core_Account_Type__c = 'Distributor',*/ /*Core_Sales_Groups__c= 'PRC Sales Group',*/
                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='abc chowk delhi',BillingState='FL',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId(),
                                             Core_User_Defined_Website__c = 'www.testpartacc.com', Core_IPA_Partner_Role__c = 'Distributor',RecordTypeId=partnerAccRecTypeId);
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',/*Core_Account_Type__c = 'Original Design Manufacturer (ODM)',*/ /*Core_Sales_Groups__c= 'PRC Sales Group',*/
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='cbc chowk delhi',BillingState='FL',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,
                                           Core_User_Defined_Website__c = 'www.testintelacc.com', Core_IPA_Partner_Role__c = 'Distributor',Core_CNDA_Number__c = '126545',RecordTypeId=partnerAccRecTypeId);
        lstAccts.add(intelAccount1);
        Database.insert(lstAccts);
        
        
        
       
        
        
        //Get Contact Record Type
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456', Core_IPA_PartnerRole__c = 'Distributor');
        insert cnt;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Member',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved',PRM_Status_Reason_Txt__c='Updated');
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
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        //bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium;Member';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solution Marketplace Enhanced';
        //insert bm; 
          
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = partnerAccount1.Id;
        aba.PRM_Partner_Benefit_Id__c = benefit.Id;
        aba.PRM_Source__c = 'Tier';        					 
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Updated';
        insert aba;

        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c();
        aba2.PRM_Account_Id__c = partnerAccount1.Id;
        aba2.PRM_Partner_Benefit_Id__c = benefit1.Id;
        aba2.PRM_Source__c = 'Tier';        					 
        aba2.PRM_Status_Nm__c = 'Active';
        aba2.PRM_Status_Reason_Txt__c='Updated';
        insert aba2;
        
        PRM_AccountBenefitAssociation__c aba3 = new PRM_AccountBenefitAssociation__c();
        aba3.PRM_Account_Id__c = partnerAccount1.Id;
        aba3.PRM_Partner_Benefit_Id__c = benefit2.Id;
        aba3.PRM_Source__c = 'Tier';        					 
        aba3.PRM_Status_Nm__c = 'Active';
        aba3.PRM_Status_Reason_Txt__c='Updated';
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
        contSub.PRM_Status_Reason_Txt__c='Updated';
        insert contSub;    
        
        //Account Request
        PRM_Registration_Request__c acctReq = new PRM_Registration_Request__c();
        acctReq.Name = 'Test Account Request';
        acctReq.PRM_First_Name__c = 'Test';
        acctReq.PRM_Last_Name__c = 'Account Request';
        acctReq.PRM_Email_ID__c = cnt.Email;
        //acctReq.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
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
        
        //system.debug('DML Limit==>'+Limits.getDMLStatements()+':::'+Limits.getLimitDmlStatements());        
        Test.startTest(); 
        Core_Contact_Entitlement__c contEntitlement = new Core_Contact_Entitlement__c();
        contEntitlement.Core_Contact_Id__c = cnt.Id;
        contEntitlement.Core_Entitlement_Id__c = coreEntitlement.Id;
        contEntitlement.Core_Unique_Id__c = 'TESTENTITLEMENT';
        insert contEntitlement;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = partnerAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        
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
       
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='ACCS_ENTTL', Name='Access and Entitlement', Is_Active__c = true);
        insert business;
        Account_Business_Types__c aType = new Account_Business_Types__c(Account__c=intelAccount1.Id, Business_Types__c= business.Id,
                                                                            Status__c = 'Approved');
       insert aType;
        Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = cnt.Id, Business_Types__c= business.Id);
        insert bType;
        List<ER_Customer_Master_File_Group__c> cmfGroupList= new List<ER_Customer_Master_File_Group__c>();
        for(Integer i=0; i<5;i++){
            ER_Customer_Master_File_Group__c cmfGroup= new ER_Customer_Master_File_Group__c();
            cmfGroup.Name= 'testName'+i;
            cmfGroupList.add(cmfGroup);
        }
        insert cmfGroupList;
        ER_Customer_Master_File__c cmf= new ER_Customer_Master_File__c();
        cmf.Name='testCmfName';
        cmf.ER_CMF_Name__c='testCMF';
        cmf.ER_Sales_Disti_Chnl_Code__c='EU02';
        insert cmf;
        List<ER_CMFGroupAssociation__c> cmfAssocList = new  List<ER_CMFGroupAssociation__c>();
        for(ER_Customer_Master_File_Group__c cmfgroup:cmfGroupList){
            ER_CMFGroupAssociation__c cmfAssoc= new ER_CMFGroupAssociation__c();
            cmfAssoc.ER_Customer_Master_File__c=cmf.Id;
           cmfAssoc.ER_Customer_Master_File_Group__c=cmfgroup.Id;
            cmfAssocList.add(cmfAssoc);
        }
        insert cmfAssocList;
        cnt.Core_Login_Status__c ='Active';
        update cnt;
        List<ER_ContactGroupAssociation__c> contactAssocList = new List<ER_ContactGroupAssociation__c>();
           ER_ContactGroupAssociation__c conAssoc = new ER_ContactGroupAssociation__c();
            conAssoc.ER_Contact__c = cnt.id;
            conAssoc.ER_Customer_Master_File_Group__c = cmfGroupList[0].id;
           
        
			insert conAssoc;
     //   Database.Update(updatedAcct);   
        Test.stopTest();
        
    } 

    
    
    
    @isTest
    private static void GenerateAccountOBM_Test(){
        test.startTest();
        Map<Id,Account> acctList = new Map<Id,Account>([SELECT Id FROM Account]);
        Set<Id> acctIds = new Set<Id>();
		acctIds.addAll(acctList.keySet());
        ER_SalesCloud_Integration.GenerateAnEAccountOBM(acctIds);
        test.stopTest();
    }   
	
    @isTest
    private static void GenerateContactOBM_Test(){
        test.startTest();
        Map<Id,Contact> conList = new Map<Id,Contact>([SELECT Id FROM Contact]);
        Set<Id> contactId = new Set<Id>();
		contactId.addAll(conList.keySet());
        ER_SalesCloud_Integration.GenerateContactOBMAnE(contactId);
        test.stopTest();
    }
     @isTest
    private static void GenerateCMFOBM_Test(){
        
        test.startTest();
        Map<Id,ER_Customer_Master_File_Group__c> cmfGroupMap = new Map<Id,ER_Customer_Master_File_Group__c>([SELECT Id FROM ER_Customer_Master_File_Group__c]);
        Set<Id> cmfGroupId = new Set<Id>();
		cmfGroupId.addAll(cmfGroupMap.keySet());
        ER_SalesCloud_Integration.GenerateCMFOutboundMessage(cmfGroupId);
        List<Contact> conList = new List<Contact>();
        conList =[SELECT id from Contact where email ='testcontact1@mailinator.com'];
        ER_SalesCloud_Integration.GenerateContactOBMAnE(new Set<Id>{conList[0].id});
        try{
            Integer i = 1/0;
        }
        catch(Exception ex){
			ER_SalesCloud_Integration.createLogEntry('Error',ex,'','Low','');
        }
        test.stopTest();
        
       
    }

    @IsTest
    static void testGetCMFDetails() {

        User u = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

        ER_Customer_Master_File__c cmf = new ER_Customer_Master_File__c(
            Name = 'CMF-001',
            ER_CMF_Name__c = 'Test CMF',
            ER_Direct_Customer_Relationship_Name__c = 'Primary',
            ER_Direct_Customer_Relationship_Code__c = 'PR',
            ER_Sales_Org_Code__c = '1000',
            ER_Sales_Org_Name__c = 'North America',
            ER_Sales_Disti_Chnl_Code__c = '10',
            ER_Sales_Disti_Chnl_Name__c = 'Wholesale',
            ER_CMF_Address__c = '123 Main St',
            ER_Account_Group__c = 'AG1'
        );
        insert cmf;

        ER_Customer_Master_File_Group__c groupRec =
            new ER_Customer_Master_File_Group__c(
                Name = 'Test Group',
                ER_Active__c = true,
                ER_Description__c = 'Test Description'
                //ER_Count_of_Customer_Master_Files__c = 1,
                //ER_Inactive_Customer_Master_Files__c = 0,
                //ER_Count_of_Contacts__c = 2,
                //ER_Inactive_Contacts__c = 0
            );
        insert groupRec;

        ER_CMFGroupAssociation__c assoc =
            new ER_CMFGroupAssociation__c(
                ER_Customer_Master_File_Group__c = groupRec.Id,
                ER_Customer_Master_File__c = cmf.Id
            );
        insert assoc;

        List<ER_Customer_Master_File_Group__c> groupData =
            [
                SELECT Id, Name, CreatedDate, LastModifiedDate,
                       CreatedBy.Name, LastModifiedBy.Name,
                       ER_Active__c, ER_Description__c,
                       ER_Count_of_Customer_Master_Files__c,
                       ER_Inactive_Customer_Master_Files__c,
                       ER_Count_of_Contacts__c,
                       ER_Inactive_Contacts__c,
                       (SELECT Id,
                               ER_Customer_Master_File_Group__r.Name,
                               ER_Customer_Master_File__r.Name,
                               ER_Customer_Master_File__r.ER_CMF_Name__c,
                               ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c,
                               ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c,
                               ER_Customer_Master_File__r.ER_Sales_Org_Code__c,
                               ER_Customer_Master_File__r.ER_Sales_Org_Name__c,
                               ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c,
                               ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c,
                               ER_Customer_Master_File__r.ER_CMF_Address__c,
                               ER_Customer_Master_File__r.ER_Account_Group__c
                        FROM CMFGroupAssociations__r)
                FROM ER_Customer_Master_File_Group__c
                WHERE Id = :groupRec.Id
            ];

        Test.startTest();
            ER_SalesCloud_Integration.getCMFDetails(groupData);
        Test.stopTest();
    }


    
    
}