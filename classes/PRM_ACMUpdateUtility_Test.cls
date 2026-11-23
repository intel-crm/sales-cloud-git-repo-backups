@isTest
public class PRM_ACMUpdateUtility_Test {
    
    public static boolean ipaRefresh = Boolean.valueOf(Label.PRM_IPARefresh);
    
    @isTest
    public static void Test(){ 
        // Custom Settings
        List<SObject> customSettings = new List<SObject>();
        prm_skip_trigger__c sk = new prm_skip_trigger__c(
            Name = 'ABA_Trigger',
            inactive__c = false
        );
        customSettings.add(sk);
        
        PRM_BatchCustomSetting__c bCs = new PRM_BatchCustomSetting__c(
            PRM_MP_Benefits__c = 'Solution Marketplace Enhanced',
            Name = 'BatchFieldValues',
            PRM_PartnerRole__c = 'Service Provider',
            PRM_PartnerType__c = 'Cloud Service Provider (CSP)'
        );
        customSettings.add(bCs);
        insert customSettings;
        
        // Record Type IDs
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdWithBnft = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByDeveloperName().get('PRM_EntitlementWithBenefits').getRecordTypeId();
        Id recordTypeIdWithoutBnft = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByDeveloperName().get('PRM_EntitlementWithoutBenefits').getRecordTypeId();
        
        
        
        // Accounts
        List<Account> accounts = new List<Account>();
        Account newAccount = new Account(
            RecordTypeId = recordTypeIdAccount,
            Name = 'Greg Thomas',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal code',
            Core_Account_Type__c = 'Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)',
            Core_IPA_Partner_Role__c = 'Service Provider;Distributor',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            Website = 'www.abc.com',
            Core_User_Defined_Website__c = 'www.abc.com'
        );
        accounts.add(newAccount);
        
        Account opidAcc = new Account(
            RecordTypeId = recordTypeIdPagAccount,
            Name = 'OPID',
            BillingCity = 'City1',
            BillingStreet = 'Street1',
            BillingCountry = 'India',
            BillingPostalCode = 'Postal code',
            Core_Account_Type__c = 'Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)',
            Core_IPA_Partner_Role__c = 'Service Provider;Distributor',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            Website = 'www.abc.com',
            Core_User_Defined_Website__c = 'www.abc.com'
        );
        accounts.add(opidAcc);
        insert accounts;
        
        Set<Id> accIds = new Set<Id>{newAccount.Id};
        
        // Contact
        Contact cont = new Contact(
            AccountId = newAccount.Id,
            LastName = 'Grill',
            FirstName = 'Adam',
            Email = 'AdamGrill@rediff.com',
            Core_Job_Function__c = 'Branch Manager',
            Core_eRPM_Language_Code__c = 'Eng',
            Core_IPA_PartnerRole__c = 'Service Provider',
            MailingCountry = 'USA'
        );
        insert cont;
        
        // Channel Program
        ChannelProgram cp = new ChannelProgram(
            Name = 'Intel Partner Alliance',
            PRM_programCode__c = 'IPA'
        );
        insert cp;
        
        // Channel Program Levels
        List<ChannelProgramLevel> programLevels = new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl = new ChannelProgramLevel(
            Name = !ipaRefresh ? 'Partner' : 'Partner',
            ProgramId = cp.Id
        );
        programLevels.add(cpl);
        
        ChannelProgramLevel cpl1 = new ChannelProgramLevel(
            Name = !ipaRefresh ? 'Prestige' : 'Prestige',
            ProgramId = cp.Id
        );
        programLevels.add(cpl1);
        insert programLevels;
        
        // Contact Relationships
        List<PRM_ContactRelationships__c> contactRelationships = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c admin = new PRM_ContactRelationships__c(
            Name = 'Partner Admin',
            PRM_Contact_Relationship_Cd__c = 'PRIMARY',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Default_Relationship_Ind__c = true
        );
        contactRelationships.add(admin);
        
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c(
            Name = 'Partner Admin',
            PRM_Contact_Relationship_Cd__c = 'WORKSFOR',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Default_Relationship_Ind__c = true
        );
        contactRelationships.add(employee);
        insert contactRelationships;
        
        // Account Contact Relationships
        List<PRM_Account_Contact_Relationship__c> acctContRels = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.Id,
            PRM_Relationship_Id__c = admin.Id,
            PRM_InActive_Ind__c = false,
            PRM_execute_trigger__c = true,
            PRM_Status_Nm__c = 'Complete'
        );
        acctContRels.add(acctContRel);
        
        PRM_Account_Contact_Relationship__c acctContRelEmp = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Contact_Id__c = cont.Id,
            PRM_Relationship_Id__c = employee.Id,
            PRM_InActive_Ind__c = false,
            PRM_Status_Nm__c = 'Complete'
        );
        acctContRels.add(acctContRelEmp);
        insert acctContRels;
        
        test.startTest();
        // Account Channel Memberships
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c newAccountAcm = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id,
            PRM_Partner_Role__c = 'Solution Integrator'
        );
        acms.add(newAccountAcm);
        
        PRM_AccountChannelMembership__c opidACM = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = opidAcc.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id,
            PRM_Partner_Role__c = 'Solution Integrator'
        );
        acms.add(opidACM);
        insert acms;
        
        // Update ACM
        newAccountAcm.PRM_Partner_Role__c = 'Distributor';
        update newAccountAcm;
        
        // Partner Benefits
        List<PRM_PartnerBenefit__c> benefits = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(
            Name = 'Partner University',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Benefit_Cd__c = 'BFTTRGUNI',
            PRM_Account_Type_Nm__c = 'Both'
        );
        benefits.add(pb);
        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(
            Name = 'Test',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Benefit_Cd__c = 'TEST',
            PRM_Account_Type_Nm__c = 'both'
        );
        benefits.add(pb2);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(
            Name = 'Partner University1',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Benefit_Cd__c = 'BFTMKTPLBC',
            PRM_Account_Type_Nm__c = 'Both'
        );
        benefits.add(pb1);
        
        PRM_PartnerBenefit__c wrBnft = new PRM_PartnerBenefit__c(
            Name = 'Standard Warranty Replacement',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Benefit_Cd__c = 'SWR',
            PRM_Account_Type_Nm__c = 'Mastered_Account'
        );
        benefits.add(wrBnft);
        insert benefits;
        
        // Partner Type
        PRM_PartnerType__c pt = new PRM_PartnerType__c(
            Name = 'Cloud Service Provider (CSP)',
            PRM_Role_Name__c = 'Service Provider',
            PRM_PartneryTypeCode__c = 'CSP',
            PRM_PartnerRoleCode__c = 'SPR',
            PRM_channelprogram__c = cp.Id
        );
        insert pt;
        
        // Benefit Matrix
        List<PRM_VXBnftMatrix__c> benefitMatrices = new List<PRM_VXBnftMatrix__c>();
        PRM_VXBnftMatrix__c bem11 = new PRM_VXBnftMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl1.Id,
            PRM_Covered_Account_Ind__c = true,
            PRM_IsActive_Ind__c = true,
            PRM_Partner_Benefit_Id__c = pb2.Id,
            PRM_Partner_Type_Id__c = pt.Id,
            PRM_Partner_Role_Nm__c = 'Solution Integrator'
        );
        benefitMatrices.add(bem11);
        
        PRM_VXBnftMatrix__c bem = new PRM_VXBnftMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl1.Id,
            PRM_Covered_Account_Ind__c = true,
            PRM_IsActive_Ind__c = true,
            PRM_Partner_Benefit_Id__c = pb.Id,
            PRM_Partner_Type_Id__c = pt.Id,
            PRM_Partner_Role_Nm__c = 'Solution Integrator'
        );
        benefitMatrices.add(bem);
        
        PRM_VXBnftMatrix__c bem1 = new PRM_VXBnftMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id,
            PRM_Covered_Account_Ind__c = true,
            PRM_IsActive_Ind__c = true,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Partner_Type_Id__c = pt.Id,
            PRM_Partner_Role_Nm__c = 'Solution Integrator'
        );
        benefitMatrices.add(bem1);
        
        PRM_VXBnftMatrix__c bem111 = new PRM_VXBnftMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl1.Id,
            PRM_Covered_Account_Ind__c = true,
            PRM_IsActive_Ind__c = true,
            PRM_Partner_Benefit_Id__c = pb2.Id,
            PRM_Partner_Type_Id__c = pt.Id,
            //PRM_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder'
            PRM_Partner_Role_Nm__c = 'Solution Integrator'
        );
        benefitMatrices.add(bem111);
        
        PRM_VXBnftMatrix__c bem112 = new PRM_VXBnftMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl1.Id,
            PRM_Covered_Account_Ind__c = true,
            PRM_IsActive_Ind__c = true,
            PRM_Partner_Benefit_Id__c = pb.Id,
            PRM_Partner_Type_Id__c = pt.Id,
            //PRM_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder'
            PRM_Partner_Role_Nm__c = 'Solution Integrator'
        );
        benefitMatrices.add(bem112);
        
        PRM_VXBnftMatrix__c bem1111 = new PRM_VXBnftMatrix__c(
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id,
            PRM_Covered_Account_Ind__c = true,
            PRM_IsActive_Ind__c = true,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Partner_Type_Id__c = pt.Id,
            //PRM_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder'
            PRM_Partner_Role_Nm__c = 'Solution Integrator'
        );
        benefitMatrices.add(bem1111);
        insert benefitMatrices;
        
        // Account Benefit Associations
        List<PRM_AccountBenefitAssociation__c> abaLst = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Partner_Benefit_Id__c = pb.Id,
            PRM_Status_Nm__c = 'Active',
            PRM_Source__c = 'Tier'
        );
        abaLst.add(aba);
        
        PRM_AccountBenefitAssociation__c aba11 = new PRM_AccountBenefitAssociation__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Partner_Benefit_Id__c = wrBnft.Id,
            PRM_Status_Nm__c = 'Active',
            PRM_Source__c = 'Tier'
        );
        abaLst.add(aba11);
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Status_Nm__c = 'Active',
            PRM_Source__c = 'Tier'
        );
        abaLst.add(aba1);
        
        PRM_AccountBenefitAssociation__c abaSpec = new PRM_AccountBenefitAssociation__c(
            PRM_Account_Id__c = newAccount.Id,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Status_Nm__c = 'Active',
            PRM_Source__c = 'Select Benefit'
        );
        abaLst.add(abaSpec);
        
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert abaLst;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        // Update Account Benefit Association
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c = 'ACM change Request done';
        update aba1;
        
        // AGS Role
        Core_AGS_Role__c ags = new Core_AGS_Role__c(
            Name = 'Ags role',
            Core_Technical_Name__c = 'Ags role'
        );
        insert ags;
        
        // ERPM Engagement
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c(
            Name = 'Intel Partner Alliance',
            Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance',
            Core_Engagement_Type__c = 'SEC'
        );
        insert ee;
        
        // Entitlements
        List<Core_Entitlement__c> entitlements = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed = new Core_Entitlement__c(
            Name = 'Points Redeem',
            Core_Display_Name__c = 'Sales PRM- Partner Points Redemption User',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(ed);
        
        Core_Entitlement__c ed1 = new Core_Entitlement__c(
            Name = 'Points View',
            Core_Display_Name__c = 'Sales PRM - Partner University User',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(ed1);
        
        Core_Entitlement__c ed2 = new Core_Entitlement__c(
            Name = 'Technology Sandbox',
            Core_Display_Name__c = 'Sales PRM- Partner Technology Sandbox User',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(ed2);
        
        Core_Entitlement__c entitlement1 = new Core_Entitlement__c(
            Name = 'FPGA Partner Program Titanium Tier Access',
            Core_Display_Name__c = 'FPGA Partner Program Titanium Tier Access',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(entitlement1);
        
        Core_Entitlement__c entitlement2 = new Core_Entitlement__c(
            Name = 'FPGA Partner Program Gold Tier Access',
            Core_Display_Name__c = 'FPGA Partner Program Gold Tier Access',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(entitlement2);
        
        Core_Entitlement__c entitlement3 = new Core_Entitlement__c(
            Name = 'Partner Admin',
            Core_Display_Name__c = 'Partner Admin',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(entitlement3);
        
        Core_Entitlement__c entitlement4 = new Core_Entitlement__c(
            Name = 'Employee',
            Core_Display_Name__c = 'Employee',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(entitlement4);
        
        Core_Entitlement__c entitlement5 = new Core_Entitlement__c(
            Name = 'PSG Basic',
            Core_Display_Name__c = 'PSG Basic',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(entitlement5);
        
        Core_Entitlement__c entitlement6 = new Core_Entitlement__c(
            Name = 'Warranty Requestor',
            Core_Display_Name__c = 'Warranty Requestor',
            Core_ERPM_Engagement_Id__c = ee.Id,
            Core_AGS_Role_Id__c = ags.Id
        );
        entitlements.add(entitlement6);
        insert entitlements;
        
        // Entitlement Matrix
        List<PRM_VXEnttlmntMatrix__c> vxentLst = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c seller1 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithBnft,
            PRM_Partner_Benefit_Id__c = wrBnft.Id,
            PRM_Entitlement_Id__c = entitlement6.Id,
            PRM_Contact_Relationship_Id__c = admin.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            //PRM_IPA_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder',
            PRM_IPA_Partner_Role_Nm__c = 'Solution Integrator',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller1);
        
        PRM_VXEnttlmntMatrix__c seller112 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithBnft,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Entitlement_Id__c = ed2.Id,
            PRM_Contact_Relationship_Id__c = employee.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            //PRM_IPA_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder',
            PRM_IPA_Partner_Role_Nm__c = 'Solution Integrator',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller112);
        
        PRM_VXEnttlmntMatrix__c seller111 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithBnft,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Entitlement_Id__c = entitlement6.Id,
            PRM_Contact_Relationship_Id__c = employee.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            //PRM_IPA_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder',
            PRM_IPA_Partner_Role_Nm__c = 'Solution Integrator',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller111);
        
        PRM_VXEnttlmntMatrix__c seller114 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithBnft,
            PRM_Partner_Benefit_Id__c = pb1.Id,
            PRM_Entitlement_Id__c = entitlement6.Id,
            PRM_Contact_Relationship_Id__c = employee.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_IPA_Partner_Role_Nm__c = 'Solution Integrator',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller114);
        
        PRM_VXEnttlmntMatrix__c seller3 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithoutBnft,
            PRM_Entitlement_Id__c = entitlement3.Id,
            PRM_Contact_Relationship_Id__c = admin.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            //PRM_IPA_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder',
            PRM_IPA_Partner_Role_Nm__c = 'Solution Integrator',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller3);
        
        PRM_VXEnttlmntMatrix__c seller31 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithoutBnft,
            PRM_Entitlement_Id__c = ed2.Id,
            PRM_Contact_Relationship_Id__c = admin.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            //PRM_IPA_Partner_Role_Nm__c = !ipaRefresh ? 'Seller' : 'Builder',
            PRM_IPA_Partner_Role_Nm__c = 'Solution Integrator',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller31);
        
        PRM_VXEnttlmntMatrix__c seller4 = new PRM_VXEnttlmntMatrix__c(
            RecordTypeId = recordTypeIdWithoutBnft,
            PRM_Entitlement_Id__c = entitlement4.Id,
            PRM_Contact_Relationship_Id__c = admin.Id,
            PRM_Approval_Type_Nm__c = 'Automatic',
            PRM_IPA_Partner_Role_Nm__c = 'FPGA Designer',
            PRM_Channel_Program_Level_Id__c = cpl1.Id
        );
        vxentLst.add(seller4);
        insert vxentLst;
        
        // IPA Membership
        List<PRM_IPA_Membership__c> memberships = new List<PRM_IPA_Membership__c>();
        PRM_IPA_Membership__c ipaMem1 = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = newAccountAcm.Id,
            PRM_Old_Partner_Role__c = newAccountAcm.PRM_Partner_Role__c,
            PRM_Old_Partner_Tier__c = cpl.Name,
            PRM_Partner_Role__c = 'Solution Integrator',
            PRM_Partner_Tier__c = cpl1.Id
        );
        memberships.add(ipaMem1);
        
        PRM_IPA_Membership__c opidacmmem = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = opidACM.Id,
            PRM_Old_Partner_Role__c = opidACM.PRM_Partner_Role__c,
            PRM_Old_Partner_Tier__c = cpl.Name,
            PRM_Partner_Role__c = 	'Solution Integrator',
            PRM_Partner_Tier__c = cpl1.Id
        );
        memberships.add(opidacmmem);
        insert memberships;
        
        // Contact Entitlement
        Core_Contact_Entitlement__c conentRel = new Core_Contact_Entitlement__c(
            Core_Entitlement_Id__c = ed.Id,
            Core_Contact_Id__c = cont.Id,
            Core_Status__c = 'Pending',
            Core_Selected__c = true
        );
        insert conentRel;
        
        // Utility and Assertions
        PRM_ACMUpdateUtility utility = new PRM_ACMUpdateUtility();
        PRM_ACMUpdateUtility.contactEntilementResponse response = utility.assignBenefits(new List<PRM_IPA_Membership__c>{ipaMem1});
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.updateAccountandContact, 'Update account and contact list should not be null');
        System.assertNotEquals(null, response.entitlementsTOUpsert, 'Entitlements to upsert should not be null');
        
        Database.executeBatch(new PRM_ACMUpdateBatchUtility());
        test.stopTest();
    }
}