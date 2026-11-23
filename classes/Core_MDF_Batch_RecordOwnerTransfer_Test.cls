@isTest
public class Core_MDF_Batch_RecordOwnerTransfer_Test {

    @testSetup 
    static void setup() {

        List<Core_Trigger_Executions__c> triggerList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c te1 = new Core_Trigger_Executions__c();
        te1.Name = 'Core_MDF_AccountOnBeforeInsert';
        te1.Core_Active__c = True;
        te1.Core_Class_Name__c = 'Core_Account';
        te1.Core_Description__c = 'Before Insert';
        te1.Core_Object__c = 'Account';
        te1.Core_Trigger_Events__c = 'before insert';
        triggerList.add(te1);
        Core_Trigger_Executions__c te2 = new Core_Trigger_Executions__c();
        te2.Name = 'Core_MDF_AccountOnBeforeUpdate';
        te2.Core_Active__c = True;
        te2.Core_Class_Name__c = 'Core_Account';
        te2.Core_Description__c = 'Before update';
        te2.Core_Object__c = 'Account';
        te2.Core_Trigger_Events__c = 'before update';
        triggerList.add(te2);
        Core_Trigger_Executions__c te3 = new Core_Trigger_Executions__c();
        te3.Name = 'Core_MDF_AccountOnAfterInsert';
        te3.Core_Active__c = True;
        te3.Core_Class_Name__c = 'Core_Account';
        te3.Core_Description__c = 'After Insert';
        te3.Core_Object__c = 'Account';
        te3.Core_Trigger_Events__c = 'after insert';
        triggerList.add(te3);
        Core_Trigger_Executions__c te4 = new Core_Trigger_Executions__c();
        te4.Name = 'Core_MDF_AccountOnAfterUpdate';
        te4.Core_Active__c = True;
        te4.Core_Class_Name__c = 'Core_Account';
        te4.Core_Description__c = 'After Update';
        te4.Core_Object__c = 'Account';
        te4.Core_Trigger_Events__c = 'after update';
        triggerList.add(te4);
        Core_Trigger_Executions__c te5 = new Core_Trigger_Executions__c();
        te5.Name = 'Core_MDF_AddOrRemoveUserFromPgmGrp';
        te5.Core_Active__c = True;
        te5.Core_Class_Name__c = 'Core_MDF_PGM_TriggerHandler';
        te5.Core_Description__c = 'After Update';
        te5.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
        te5.Core_Trigger_Events__c = 'after insert, after update';
        triggerList.add(te5);
        Core_Trigger_Executions__c te6 = new Core_Trigger_Executions__c();
        te6.Core_Active__c = true;
        te6.Core_Class_Name__c = 'Core_MDF_PGM_TriggerHandler';
        te6.Core_Trigger_Events__c = 'Before Delete';
        te6.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
        te6.Name = 'Core_MDF_BeforeDeletePGM';
        te6.Core_Description__c = 'description';
        triggerList.add(te6);
        Core_Trigger_Executions__c te7 = new Core_Trigger_Executions__c();
        te7.Core_Active__c = true;
        te7.Core_Class_Name__c = 'Core_MDF_PGM_TriggerHandler';
        te7.Core_Trigger_Events__c = 'After Update';
        te7.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
        te7.Name = 'Core_MDF_PGMProcessToAddToMasterGroup';
        te7.Core_Description__c = 'description';
        triggerList.add(te7);
        
        insert triggerList;

        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name=Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        insert cpIPATest;
        
        List<Account> accList = new List<Account>();
        Id opidRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account opid = new Account(Name = 'opidAcc01', RecordTypeId = opidRecType);
        insert opid;
        opid.Core_IPA_One_Partner_Id__c = opid.Id;
        update opid;
        
        Id benefitRec = Schema.SObjectType.PRM_PartnerBenefit__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        PRM_PartnerBenefit__c benefit = new PRM_PartnerBenefit__c();
        benefit.PRM_Benefit_Cd__c = 'MDFACCCCP';
        benefit.RecordTypeId = benefitRec;
        benefit.Name = 'Market Development Funds (Account MDF)-CCP';
        benefit.PRM_Channel_Program_Id__c = cpIPATest.Id;
        insert benefit;
            
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = opid.Id;
        aba.PRM_Partner_Benefit_Id__c = benefit.Id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
        insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_I_MDF_Benefit', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'MDFPRPCCP', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal I MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
		insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_II_MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Proposal II MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal II MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
		insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_II_MDF_Benefit', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'MDFPRPCCP', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal II MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
		insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Account_Plan_MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Account Plan MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Account_Based', Core_MDF_Budget_Type__c = 'Account Plan', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Account Based');
		insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Account_Plan_MDF_Benefit', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'MDFACCCCP', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Account_Based', Core_MDF_Budget_Type__c = 'Account Plan', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Account Based');
		insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_I_MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Proposal I MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal I MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');

        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_MDF_CoMarketingActive__c = false;
        //acc1.Core_Prime_Id__c = 'Prime001';
        acc1.Core_Unified_Global_Customer_BP_Id__c = 'Prime001';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accList.add(acc1);

        Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc2.Core_MDF_CoMarketingActive__c = false;
        //acc2.Core_Prime_Id__c = 'Prime001';
        acc2.Core_Unified_Global_Customer_BP_Id__c = 'Prime001';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accList.add(acc2);

        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc3.Core_MDF_CoMarketingActive__c = false;
        //acc3.Core_Prime_Id__c = 'Prime002';
        acc3.Core_Unified_Global_Customer_BP_Id__c = 'Prime002';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accList.add(acc3);

        Account acc4 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 4', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc4.Core_MDF_CoMarketingActive__c = false;
        //acc4.Core_Prime_Id__c = 'Prime002';
        acc4.Core_Unified_Global_Customer_BP_Id__c = 'Prime002';
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accList.add(acc4);

        insert accList;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        List<PRM_AccountChannelMembership__c> listAcm = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = acc2.Id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Partner_Role__c = 'Seller';
        acm.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTest.Id;
		listAcm.add(acm);
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c = acc3.Id;
        acm1.PRM_Status_Nm__c = 'Approved';
        acm1.PRM_Partner_Role__c = 'Seller';
        acm1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
		listAcm.add(acm1);
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c = acc4.Id;
        acm2.PRM_Status_Nm__c = 'Approved';
        acm2.PRM_Partner_Role__c = 'Seller';
        acm2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
		listAcm.add(acm2);
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Account_Id__c = acc1.Id;
        acm3.PRM_Status_Nm__c = 'Approved';
        acm3.PRM_Partner_Role__c = 'Seller';
        acm3.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm3.PRM_Channel_Program_Level_Id__c=cplTest.Id;
		listAcm.add(acm3);
        insert listAcm;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.name = 'Proposal I MDF';
        spec.PRM_Description_Txt__c = 'Proposal I MDF';
        spec.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        spec.PRM_Role_Nm__c = 'FPGA Designer';
        spec.PRM_Tier_Nm__c = 'Gold';
        spec.PRM_Start_Date_Dt__c = system.today() - 100;
        spec.PRM_Access_Level_Nm__c = 'Public';
        spec.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();
        spec.PRM_Inactive_Ind__c = false;

        insert spec;

        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        for(Account acc : accList){
            PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
            asa.PRM_Account_Id__c = acc.id;
            asa.PRM_Specialty_Id__c = spec.Id;
            asa.PRM_InActive_Ind__c  = FALSE;
            asaList.add(asa);
        }

        insert asaList;

        List<Contact> conList = new List<Contact>();
        for(Account acc : accList){
            conList.add(Core_MDF_CCP_TestDataUtility.createContact(acc.Id,false));
            conList.add(Core_MDF_CCP_TestDataUtility.createContact(acc.Id,false));
        }
        insert conList;

        /*List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleIpa = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, false);
        agsRoleList.add(agsRoleIpa);
        
        Core_AGS_Role__c agsRoleIpaUser = Core_MDF_CCP_TestDataUtility.createAgsRole('Sales-PRM-External-IPA-MP User', 'Sales-PRM-External-IPA-MP User', true, false);
        agsRoleList.add(agsRoleIpaUser);
        
        Database.insert(agsRoleList);*/


        Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'Intel Partner Alliance', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementIPA);

        Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User', null ,'Intel Partner Alliance (IPA)','MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',false);
        Database.insert(entitlementIPA);

        List<Core_Contact_Entitlement__c> conEntitlmentList = new List<Core_Contact_Entitlement__c>();

        for(Contact con : conList){
            conEntitlmentList.add(Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id, entitlementIPA.Id , true, 'Complete', false));
        }

        insert conEntitlmentList;

		Test.startTest();
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1].Id;

        List<User> userList = new List<User>();
        for(Contact con : conList){
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr.Email='test'+ con.Id +'@example.com';
            usr.ContactId = con.Id;
            usr.ProfileId = profileId;
            usr.isActive = true;
            userList.add(usr);
        }

        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        userList.add(sysAdmUsr);

        User sysAdmUsr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr1.LastName = 'System Adm1';
        userList.add(sysAdmUsr1);

        insert userList;

        List<PermissionSet> ipaBasicPS = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('Core_MDF_IPA_USER', 'Core_MDF_CCP_External_IPA_Proposal_Manager')];

        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(User usr : userList){
            if(!usr.LastName.contains('System Adm')){
                for(PermissionSet ps : ipaBasicPS){
                    psAssignList.add(new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id));
                }
            }
        }

        System.runAs(sysAdmUsr){
            insert psAssignList;
        }

        ChannelProgram ipaProgram = Core_MDF_CCP_TestDataUtility.createProgram('Intel Partner Alliance','Intel Partner Alliance', true);
		Id accOnboard_RecordType_IPA = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        List<Core_MDF_Account_Onboarding__c> accOnboardingList = new List<Core_MDF_Account_Onboarding__c>();

        Core_MDF_Account_Onboarding__c accOnboard1 = new Core_MDF_Account_Onboarding__c();
        accOnboard1.Core_MDF_Account__c = acc1.Id;
        accOnboard1.RecordTypeId = accOnboard_RecordType_IPA;
        accOnboard1.Core_MDF_Channel_Program__c = ipaProgram.Id;
        accOnboard1.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
        accOnboard1.Core_MDF_Type__c = 'Intel Account';
        accOnboard1.Core_MDF_Payment_Type_nm__c = 'Customer';
        accOnboard1.Core_MDF_Host_Region_nm__c = 'APJ';
        accOnboardingList.add(accOnboard1);

        Core_MDF_Account_Onboarding__c accOnboard2 = new Core_MDF_Account_Onboarding__c();
        accOnboard2.Core_MDF_Account__c = acc3.Id;
        accOnboard2.RecordTypeId = accOnboard_RecordType_IPA;
        accOnboard2.Core_MDF_Channel_Program__c = ipaProgram.Id;
        accOnboard2.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
        accOnboard2.Core_MDF_Type__c = 'Intel Account';
        accOnboard2.Core_MDF_Payment_Type_nm__c = 'Customer';
        accOnboard2.Core_MDF_Host_Region_nm__c = 'APJ';
        accOnboardingList.add(accOnboard2);

        insert accOnboardingList;

        
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update acc2;

        Core_MDF_Partner_Group_Mapping__c pgmRecord = [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c, Core_MDF_Inactive_Ind__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: acc1.Id AND Core_MDF_Inactive_Ind__c = false LIMIT 1];
        
        Account virtualCorpAcc = [SELECT Id FROM Account WHERE Core_MDF_CoMarketing_Ultimate_Account__c != null LIMIT 1];

        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        List<GroupMember> groupmemList = new List<GroupMember>();
        for(User usr : [SELECT Id FROM User WHERE AccountId =: acc2.Id]){
            groupmemList.add(new GroupMember(GroupId = pgmRecord.Core_MDF_Group_Id__c, UserOrGroupId = usr.Id ));
            pnumList.add(new Core_MDF_Partner_Node_User_Mapping__c(Core_MDF_Active_Ind__c = true, Core_MDF_Account__c = virtualCorpAcc.Id, Core_MDF_User__c = usr.Id));
        }

        //GroupMember gm = new GroupMember(GroupId = pgmRecord.Core_MDF_Group_Id__c, UserOrGroupId = sysAdmUsr.Id );
        System.runAs(sysAdmUsr1){
            insert groupmemList;
        }
        
        System.runAs(sysAdmUsr){
            insert pnumList;
        }

        Test.stopTest();

    }

    
    @isTest
    static void updatePrimeIdAndIpaFlagForNoncoMarketingAccount(){
        
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        Account virtualCorpAcc = [SELECT Id FROM Account WHERE Core_MDF_CoMarketing_Ultimate_Account__r.Name = '[Prime] Intel Account 1' LIMIT 1];
        
        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',virtualCorpAcc.Id, System.today(), System.today().addDays(300), 'Proposal I MDF', 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        
        
        
        User usr = [SELECT Id FROM User WHERE AccountId =: acc.Id LIMIT 1];
        AccountShare accShare = new AccountShare(AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit', RowCause = 'Manual',UserOrGroupId = usr.Id, AccountId = virtualCorpAcc.Id);
        insert accShare;
        System.runAs(usr){
            insert camp;
        }
        
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Active_Ind__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Active_Ind__c = true]){
            pnumList.add(new Core_MDF_Partner_Node_User_Mapping__c(Id = pnum.Id, Core_MDF_Active_Ind__c = false, Core_MDF_Action_Needed_nm__c = 'Owner Update'));
        }
        
        if(!pnumList.isEmpty()){
            update pnumList;
        }
        
        Database.executeBatch(new Core_MDF_Batch_RecordOwnerTransfer(), 20);
        
        Test.stopTest();        
        Assert.areNotEqual(acc , null);
    }
    
}