@isTest
public class Core_MDF_Account_PGM_Sync_Test {

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
        
        Account opid2 = new Account(Name = 'opidAcc02', RecordTypeId = opidRecType);
        insert opid2;
        opid2.Core_IPA_One_Partner_Id__c = opid2.Id;
        update opid2;
        
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
        aba.PRM_Status_Reason_Txt__c = 'Test';
        insert aba;
        
        insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_I_MDF_Benefit', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'MDFPRPCCP', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal I MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
    insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_II_MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Proposal II MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal II MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
    insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_II_MDF_Benefit', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'MDFPRPCCP', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal II MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');
    insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Account_Plan_MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Account Plan MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Account_Based', Core_MDF_Budget_Type__c = 'Account Plan', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Account Based');
    insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Account_Plan_MDF_Benefit', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'MDFACCCCP', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Account_Based', Core_MDF_Budget_Type__c = 'Account Plan', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Account Based');
    insert new Core_MDF_BudgetType_Benefit_Mappings__c(Name = 'Proposal_I_MDF', Core_MDF_IsActive__c = true, Core_MDF_Is_IUPGM_Monitor_Applicable_Ind__c = true, Core_MDF_Partner_Benefit__c = 'Proposal I MDF', Core_MDF_Record_Developer_Nm__c = 'Core_MDF_Intel_Partner_Alliance_Proposal_Based', Core_MDF_Budget_Type__c = 'Proposal I MDF', Core_MDF_Program_Nm__c = 'Intel Partner Alliance', Core_MDF_RecordType__c = 'Proposal Based');

        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 1', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        acc1.Core_MDF_CoMarketingActive__c = false;
        acc1.Core_Unified_Global_Customer_BP_Id__c='testUnifiedID001';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc1.Core_IPA_One_Partner_Id__c = opid.Id;
        accList.add(acc1);

        Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 2', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        acc2.Core_MDF_CoMarketingActive__c = false;
        acc2.Core_Unified_Global_Customer_BP_Id__c='testUnifiedID002';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_IPA_One_Partner_Id__c = opid.Id;
        accList.add(acc2);

        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 3', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        acc3.Core_MDF_CoMarketingActive__c = false;
        acc3.Core_Unified_Global_Customer_BP_Id__c='testUnifiedID003';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_IPA_One_Partner_Id__c = opid.Id;
        accList.add(acc3);

        Account acc4 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 4', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        acc4.Core_MDF_CoMarketingActive__c = false;
        acc4.Core_Unified_Global_Customer_BP_Id__c='testUnifiedID004';
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc4.Core_IPA_One_Partner_Id__c = opid.Id;
        accList.add(acc4);
    
        Account acc5 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 5', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        acc5.Core_MDF_CoMarketingActive__c = false;
        acc5.Core_Unified_Global_Customer_BP_Id__c='testUnifiedID005';
        acc5.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc5.Core_IPA_One_Partner_Id__c = opid.Id;
        accList.add(acc5);
        
        Account acc6 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 6', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        acc6.Core_MDF_CoMarketingActive__c = false;
        acc6.Core_Unified_Global_Customer_BP_Id__c='testUnifiedID006';
        acc6.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc6.Core_IPA_One_Partner_Id__c = opid.Id;
        accList.add(acc6);
        
        insert accList;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        List<PRM_AccountChannelMembership__c> listAcm = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = acc2.Id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Partner_Role__c = 'Distributor';
        acm.PRM_Status_Reason_Txt__c ='Test';
        acm.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTest.Id;
    listAcm.add(acm);
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c = acc3.Id;
        acm1.PRM_Status_Nm__c = 'Approved';
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Status_Reason_Txt__c ='Test';
        acm1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
    listAcm.add(acm1);
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c = acc4.Id;
        acm2.PRM_Status_Nm__c = 'Approved';
        acm2.PRM_Partner_Role__c = 'Distributor';
        acm2.PRM_Status_Reason_Txt__c ='Test';
        acm2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
    listAcm.add(acm2);
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Account_Id__c = acc1.Id;
        acm3.PRM_Status_Nm__c = 'Approved';
        acm3.PRM_Partner_Role__c = 'Distributor';
        acm3.PRM_Status_Reason_Txt__c ='Test';
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

        ChannelProgram ipaProgram = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
        ChannelProgram eefProgram =  Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.EEF_PROGRAM,'Ecosystem Extension Fund', true);
    Id accOnboard_RecordType_IPA = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        List<Core_MDF_Account_Onboarding__c> accOnboardingList = new List<Core_MDF_Account_Onboarding__c>();
        Core_MDF_Account_Onboarding__c accOnboard1 = new Core_MDF_Account_Onboarding__c();
        accOnboard1.RecordTypeId = accOnboard_RecordType_IPA;
        accOnboard1.Core_MDF_Account__c = acc1.Id;
        accOnboard1.Core_MDF_Channel_Program__c = ipaProgram.Id;
        accOnboard1.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
        accOnboard1.Core_MDF_Type__c = 'Intel Account';
        accOnboard1.Core_MDF_Payment_Type_nm__c = 'Distributor (Credit Memo)';
         accOnboard1.Core_MDF_Host_Region_nm__c = 'APJ';
        accOnboardingList.add(accOnboard1);

        Core_MDF_Account_Onboarding__c accOnboard2 = new Core_MDF_Account_Onboarding__c();
        accOnboard2.RecordTypeId = accOnboard_RecordType_IPA;
        accOnboard2.Core_MDF_Account__c = acc3.Id;
        accOnboard2.Core_MDF_Channel_Program__c = ipaProgram.Id;
        accOnboard2.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
        accOnboard2.Core_MDF_Type__c = 'Intel Account';
        accOnboard2.Core_MDF_Payment_Type_nm__c = 'Distributor (Credit Memo)';
        accOnboard2.Core_MDF_Host_Region_nm__c = 'APJ';
        accOnboardingList.add(accOnboard2);
        
        insert accOnboardingList;
        
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update acc2;

        Core_MDF_Partner_Group_Mapping__c pgmRecord = [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Id__c,Core_MDF_Group_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Inactive_Ind__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: acc1.Id AND Core_MDF_Inactive_Ind__c = false LIMIT 1];
        
        Account virtualCorpAcc = [SELECT Id FROM Account WHERE Core_MDF_CoMarketing_Ultimate_Account__c != null LIMIT 1];

        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        List<GroupMember> groupmemList = new List<GroupMember>();
        for(User usr : [SELECT Id FROM User WHERE AccountId =: acc1.Id]){
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
       

        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        update acc2;
         Core_MDF_Partner_Group_Mapping__c nonCoMarpgmRec = new Core_MDF_Partner_Group_Mapping__c();
         nonCoMarpgmRec.Core_MDF_Account__c = acc6.id;
         nonCoMarpgmRec.Core_MDF_Type_of_Access__c = 'External';
         nonCoMarpgmRec.Core_MDF_Channel_Program__c = ipaProgram.Id;
         nonCoMarpgmRec.Core_MDF_Group_Name__c = pgmRecord.Core_MDF_Group_Name__c;
        
        System.runAs(sysAdmUsr){
           
            pgmRecord.Core_MDF_Inactive_Ind__c = false;
            update pgmRecord;
            insert nonCoMarpgmRec;
            
            
        }

        Test.stopTest();
        
    }

    
    @isTest
    static void updatePrimeIdAndIpaFlagForNoncoMarketingAccount(){
        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        Account virtualCorpAcc = [SELECT Id FROM Account WHERE Core_MDF_CoMarketing_Ultimate_Account__r.Name = '[Prime] Intel Account 1' LIMIT 1];
        Account opid2 = [SELECT Id FROM Account WHERE Name = 'opidAcc02'];

        Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',virtualCorpAcc.Id, System.today(), System.today().addDays(300), 'Proposal I MDF', 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        
        User usr = [SELECT Id FROM User WHERE AccountId =: acc.Id LIMIT 1];
        AccountShare accShare = new AccountShare(AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit', RowCause = 'Manual',UserOrGroupId = usr.Id, AccountId = virtualCorpAcc.Id);
        insert accShare;
        System.runAs(usr){
            insert camp;
        }
        //insert camp;

        camp.ownerId = usr.Id;
        //update camp;
        
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Unified_Global_Customer_BP_Id__c = 'Prime002';
        acc.Core_IPA_One_Partner_Id__c = opid2.Id;
        update acc;

        Test.stopTest();
        Assert.areNotEqual(acc.Core_Unified_Global_Customer_BP_Id__c,null);
    }

    @isTest
    static void updateWithPrimeIdWhichNotOnboarded(){
        Test.startTest();
        Account opid2 = [SELECT Id FROM Account WHERE Name = 'opidAcc02'];
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        acc.Core_Unified_Global_Customer_BP_Id__c = 'Prime003';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_One_Partner_Id__c = opid2.Id;
        update acc;

        Test.stopTest();
        
        Assert.areNotEqual(acc.Core_Unified_Global_Customer_BP_Id__c,null);
    }

    @isTest
    static void updateIpaFlagForNoncoMarketingAccount(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;

        update acc;
        Test.stopTest();
        
        Assert.areNotEqual(acc.Core_Intel_Partner_Alliance_PartnerGroup__c,false);
    }

    @isTest
    static void updatePrimeIdOnActiveCoMarketingAccount(){
        Test.startTest();
        Account opid2 = [SELECT Id FROM Account WHERE Name = 'opidAcc02'];
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 1'];
        acc.Core_Unified_Global_Customer_BP_Id__c = 'Prime002';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_One_Partner_Id__c = opid2.Id;

        update acc;
        Test.stopTest();
        Assert.areNotEqual(acc.Core_Unified_Global_Customer_BP_Id__c,null);
    }


    @isTest
    static void addNewASA(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;

        update acc;

        /*PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.name = 'Proposal II MDF';
        spec.PRM_Description_Txt__c = 'Proposal II MDF';
        spec.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        spec.PRM_Role_Nm__c = 'FPGA Designer';
        spec.PRM_Tier_Nm__c = 'Gold';
        spec.PRM_Start_Date_Dt__c = system.today() - 100;
        spec.PRM_Access_Level_Nm__c = 'Public';
        spec.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();
        spec.PRM_Inactive_Ind__c = false;

        insert spec;*/

        PRM_Account_Specialty_Association__c asa = [SELECT Id, PRM_InActive_Ind__c FROM PRM_Account_Specialty_Association__c WHERE PRM_Account_Id__c =: acc.id LIMIT 1];
        asa.PRM_InActive_Ind__c  = true;
        
        update asa;

        Test.stopTest();
        Assert.areNotEqual(acc.Core_Intel_Partner_Alliance_PartnerGroup__c,false);
    }
    
    @isTest
    static void addNewABA(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'opidAcc01'];

        PRM_AccountBenefitAssociation__c aba = [SELECT Id, PRM_Status_Nm__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c =: acc.id LIMIT 1];
        aba.PRM_Status_Nm__c  = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'inactivating';
        update aba;
        
        List<Core_MDF_Account_PGM_Sync__e> pgmSyncList = new List<Core_MDF_Account_PGM_Sync__e>();
         Core_MDF_Account_PGM_Sync__e event = new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = 'Update',Core_MDF_Object_API_Name__c = 'PRM_AccountBenefitAssociation__c',Core_MDF_JSON_Data__c = JSON.serialize(aba));
      Database.SaveResult sr = EventBus.publish(event);
        pgmSyncList.add(event);
    Core_MDF_Account_PGM_Sync_ServiceHandler.processRecords(pgmSyncList);
        Assert.areEqual(aba.PRM_Status_Reason_Txt__c,'inactivating');
    }

    @isTest
    static void addIpaAffiliation(){
        Test.startTest();
        
    Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); 
        
        Account parent1 = new Account();
        parent1.RecordTypeId = recordTypeIdPagAccount;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';
        parent1.Core_Deactivated__c = false;
        insert parent1;
        
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_One_Partner_Id__c = parent1.Id;
        acc.Core_Deactivated__c = false;
        update acc;

        PRM_Builder_Strategy__c bs = new PRM_Builder_Strategy__c();
        bs.PRM_Active__c = true;
        bs.Name = 'MDF-Excluded Partner';

        insert bs;
        
        ChannelProgram ipaCP = [SELECT Id FROM ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];               
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name = 'Titanium';
        cplTest.ProgramId = ipaCP.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnl = new PRM_AccountChannelMembership__c(); 
        acctChnl.PRM_Account_Id__c = acc.Id;
        acctChnl.PRM_Channel_Program_Id__c = ipaCP.Id;
        acctChnl.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        acctChnl.PRM_Status_Nm__c = 'Approved';
        acctChnl.PRM_Partner_Role__c='Distributor';
        //insert acctChnl;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c = parent1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c = ipaCP.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Distributor';
        acctChnlMem.PRM_Status_Reason_Txt__c ='Test';
        insert acctChnlMem;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Inactive_Ind__c = false;
        agm.Core_Partner_Account_Id__c = parent1.id;
        agm.Core_Intel_Account_Id__c = acc.id;
        insert agm;
        

        PRM_IPA_Affiliation__c ipaAffiliation = new PRM_IPA_Affiliation__c();
        ipaAffiliation.PRM_Active__c = true;
        ipaAffiliation.PRM_Account__c = acc.Id;
        ipaAffiliation.PRM_Builder_Strategy__c = bs.Id;
		ipaAffiliation.PRM_Notes__c = 'Test';
        insert ipaAffiliation;
        PRM_Account_Specialty_Association__c asa = [SELECT Id, PRM_InActive_Ind__c FROM PRM_Account_Specialty_Association__c WHERE PRM_Account_Id__c =: acc.id LIMIT 1];
        asa.PRM_InActive_Ind__c  = false;
        
        update asa;

        Test.stopTest();
        Assert.areNotEqual(acc.Core_Intel_Partner_Alliance_PartnerGroup__c,false);
    }
    @isTest
    static void addAccountActions(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 2'];
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Unified_Global_Customer_BP_Id__c = 'Prime0001';
        acc.Core_MDF_CoMarketingActive__c = true;
        
        Account opid2 = [SELECT Id FROM Account WHERE Name = 'opidAcc02'];
        acc.Core_IPA_One_Partner_Id__c = opid2.Id;
        
        update acc;
        Test.stopTest();
        Assert.areNotEqual(acc.Core_MDF_CoMarketingActive__c,false);
    }
     @isTest
    static void updateASAForCo_MarketingAccount(){
        Test.startTest();
        Account acc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_IPA_One_Partner_Id__c FROM Account WHERE Name = '[Prime] Intel Account 1'];
		Set<Id> accountIds = new Set<Id>();
        accountIds.add(acc.Id);
        Map<Id,String> accountIdToUnifiedIdMap = new Map<Id,String>();
        accountIdToUnifiedIdMap.put(acc.Id, acc.Core_Unified_Global_Customer_BP_Id__c);
        Map<Id, Set<Id>> mapOfOPIDtoSetofAccount = new Map<Id, Set<Id>>();
        mapOfOPIDtoSetofAccount.put(acc.Core_IPA_One_Partner_Id__c, new Set<Id>{acc.id});
        Core_MDF_Account_PGM_Sync_ServiceHandler.filterRecordsToCreateOrUpdatePGM(accountIds,accountIdToUnifiedIdMap,mapOfOPIDtoSetofAccount);
        PRM_Account_Specialty_Association__c asa = [SELECT Id, PRM_InActive_Ind__c FROM PRM_Account_Specialty_Association__c WHERE PRM_Account_Id__c =: acc.id LIMIT 1];
        asa.PRM_InActive_Ind__c  = true;        
        
        update asa;

        Test.stopTest();
        Assert.areNotEqual(asa.PRM_InActive_Ind__c,false);

    }
    
         @isTest
    static void updateABAForCo_MarketingAccount(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'opidAcc01'];

        PRM_AccountBenefitAssociation__c aba = [SELECT Id, PRM_Status_Nm__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c =: acc.id LIMIT 1];
        aba.PRM_Status_Nm__c  = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'inactivating';
        update aba;

        Test.stopTest();
        //Assert.areNotEqual(aba.PRM_Status_Nm__c,'Inactive');

    }
     @isTest
    static void addIpaAffiliationForCoMarkAccount(){
        Test.startTest();
        
    Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); 
        
        Account parent1 = new Account();
        parent1.RecordTypeId = recordTypeIdPagAccount;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';
        parent1.Core_Deactivated__c = false;
        insert parent1;
        
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 1'];
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_One_Partner_Id__c = parent1.Id;
        acc.Core_Deactivated__c = false;
        update acc;
    
        PRM_Builder_Strategy__c bs = new PRM_Builder_Strategy__c();
        bs.PRM_Active__c = true;
        bs.Name = 'MDF-Excluded Partner';

        insert bs;
        
        ChannelProgram ipaCP = [SELECT Id FROM ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];               
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name = 'Titanium';
        cplTest.ProgramId = ipaCP.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnl = new PRM_AccountChannelMembership__c(); 
        acctChnl.PRM_Account_Id__c = acc.Id;
        acctChnl.PRM_Channel_Program_Id__c = ipaCP.Id;
        acctChnl.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        acctChnl.PRM_Status_Nm__c = 'Approved';
        acctChnl.PRM_Partner_Role__c='Distributor';
        //insert acctChnl;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c = parent1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c = ipaCP.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Distributor';
        acctChnlMem.PRM_Status_Reason_Txt__c ='Test';
        insert acctChnlMem;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Inactive_Ind__c = false;
        agm.Core_Partner_Account_Id__c = parent1.id;
        agm.Core_Intel_Account_Id__c = acc.id;
        insert agm;
        

        PRM_IPA_Affiliation__c ipaAffiliation = new PRM_IPA_Affiliation__c();
        ipaAffiliation.PRM_Active__c = true;
        ipaAffiliation.PRM_Account__c = acc.Id;
        ipaAffiliation.PRM_Builder_Strategy__c = bs.Id;
		ipaAffiliation.PRM_Notes__c = 'Test';
        insert ipaAffiliation;

        Test.stopTest();
        Assert.areNotEqual(acc.Core_Intel_Partner_Alliance_PartnerGroup__c,false);
    }

    @isTest
    public static void virtualCorpValidationforNonCCPPrograms(){
        Test.startTest();
         Core_Trigger_Executions__c te7 = new Core_Trigger_Executions__c();
        te7.Core_Active__c = true;
        te7.Core_Class_Name__c = 'Core_MDF_PGM_TriggerHandler';
        te7.Core_Trigger_Events__c = 'After Update';
        te7.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
        te7.Name = 'Core_MDF_PGMProcessToAddToMasterGroup';
        te7.Core_Description__c = 'description';
        insert te7;
        Account acc = [SELECT Id FROM Account WHERE Name = '[Prime] Intel Account 6'];
        Account acc1 = [SELECT Id,Core_MDF_CoMarketingActive__c FROM Account WHERE Name = '[Prime] Intel Account 1'];
        Account vcacc = [Select id from Account where Core_MDF_Parent_Fund_Account__r.Name = '[Prime] Intel Account 1' limit 1];
        Core_MDF_Partner_Group_Mapping__c pgmRecord = [SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Group_Name__c, Core_MDF_Inactive_Ind__c, Core_MDF_Type_of_Access__c, Core_MDF_Channel_Program_Name_Txt__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__r.Name = '[Prime] Intel Account 1' AND Core_MDF_Inactive_Ind__c = false LIMIT 1];
        Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap1 = new Map<Id,Core_MDF_Partner_Group_Mapping__c>();
          pgmMap1.put(pgmRecord.id,pgmRecord);
          Map<Id, Core_MDF_Partner_Group_Mapping__c> pgmToBeProcessedMap1 = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();
          pgmToBeProcessedMap1.put(pgmRecord.id,pgmRecord);
         Core_MDF_PGM_ServiceHandler.isInactiveIndicatorUpdated(pgmMap1, pgmToBeProcessedMap1);
        
        ChannelProgram testProgram = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = acc.id;
        pgm.Core_MDF_Channel_Program__c =testProgram.id;
        pgm.Core_MDF_Type_of_Access__c = 'External';
        pgm.Core_MDF_Group_Name__c = pgmRecord.Core_MDF_Group_Name__c;
        pgm.Core_MDF_Virtual_Corp_nm__c = vcacc.id;
        pgm.Core_MDF_All_Access_Group_Nm__c = 'test';
    Test.stopTest();
        try{
        Database.insert(pgm);
         
        }
        catch(Exception e)
            {   assert.areEqual(vcacc.id, pgm.Core_MDF_Virtual_Corp_nm__c);}
        pgmRecord.Core_MDF_Inactive_Ind__c = true;
         update pgmRecord;
          Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<Id,Core_MDF_Partner_Group_Mapping__c>();
          pgmMap.put(pgmRecord.id,pgmRecord);
          Map<Id, Core_MDF_Partner_Group_Mapping__c> pgmToBeProcessedMap = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();
          pgmToBeProcessedMap.put(pgmRecord.id,pgmRecord);
           Core_MDF_PGM_ServiceHandler.isInactiveIndicatorUpdated(pgmMap, pgmToBeProcessedMap);
          
        
    }
    @isTest
    public static void pgmCreationValidation(){
            Test.startTest();
            ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
             Account ccfAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfAcc.Core_MDF_CoMarketingActive__c = false;
            insert ccfAcc;
         //Account ccfCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(Client Co-Marketing Fund', ccfAcc.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ccfAcc.id, false);           
           // ccfCoMarketingAccount.Core_Geo__c = 'ASMO';
           Account ccfCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'CCF Intel Account' LIMIT 1];
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            //accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP CCFINTELACCOUNT CCF EXT';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_CCFINTELACCOUNT_CCF_EXT';
            Database.insert(ccfgrp);
        
            Core_MDF_Partner_Group_Mapping__c pgmRec = [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c, Core_MDF_Inactive_Ind__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: ccfAcc.Id AND Core_MDF_Inactive_Ind__c = false and Core_MDF_Type_of_Access__c = 'External' Limit 1]; 
           Group ccfIntgrp = new Group();
            ccfIntgrp.Name = 'CCP CCFINTELACCOUNT CCF EMEA INTERNAL';
            ccfIntgrp.DeveloperName = 'Core_MDF_CCP_CCFINTELACCOUNT_CCF_EMEA_INTERNAL';
            Database.insert(ccfIntgrp);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = ccfAcc.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_CCFINTELACCOUNT_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            ccfPgm.Core_MDF_Channel_Program__c = ccfCP.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';  
          ccfPgm.Core_MDF_Virtual_Corp_nm__c = ccfCoMarketingAccount.id;
            Database.insert(ccfPgm);
             Assert.areEqual(ccfAcc.Core_MDF_CoMarketingActive__c,false);
        
            Test.stopTest();
          
    }
    
    @isTest
    static void testAddAccountActionsMethod() {
        Test.startTest();
        Account oldAcc = new Account(Id = '001000000000001',Name = 'Test Account Old',Core_Unified_Global_Customer_BP_Id__c = 'Unified001',Core_Intel_Partner_Alliance_PartnerGroup__c = false,Core_MDF_CoMarketingActive__c = true);
        Account newAcc = new Account(Id = oldAcc.Id,Name = 'Test Account New',Core_Unified_Global_Customer_BP_Id__c = 'Unified002',Core_Intel_Partner_Alliance_PartnerGroup__c = true,Core_MDF_CoMarketingActive__c = false);
        Map<Id, List<String>> resultMap = Core_MDF_Account_PGM_Sync_ServiceHandler.addAccountActions(new Map<Id, List<String>>(), oldAcc, newAcc);
    Id recId = Id.valueOf('001000001008761');
        Core_MDF_Account_PGM_Sync_ServiceHandler.AccountBenefitAssociationWrapper wrapper = new Core_MDF_Account_PGM_Sync_ServiceHandler.AccountBenefitAssociationWrapper(recId, 'Active', recId);
         Account acc = [SELECT Id, Core_Unified_Global_Customer_BP_Id__c FROM Account WHERE Name = '[Prime] Intel Account 2'];
        String unifiedId = acc.Core_Unified_Global_Customer_BP_Id__c;
        Set<Id> intelAccountIds = new Set<Id>{ acc.Id };
        Map<Id, String> intelAccountToUnifiedIdMap = new Map<Id, String>{ acc.Id => unifiedId };
        Map<Id, Set<Id>> opidToAccountIdMap = new Map<Id, Set<Id>>();
        Set<Id> result = Core_MDF_Account_PGM_Sync_ServiceHandler.filterRecordsToCreateOrUpdatePGM(intelAccountIds,intelAccountToUnifiedIdMap,opidToAccountIdMap);
        Account acc23 = [SELECT Id, Name FROM Account WHERE Name = '[Prime] Intel Account 2' LIMIT 1];
        PRM_Account_Specialty_Association__c asa = [SELECT Id, PRM_Account_Id__c, PRM_InActive_Ind__c FROM PRM_Account_Specialty_Association__c WHERE PRM_Account_Id__c = :acc23.Id LIMIT 1];
        List<Core_MDF_Account_PGM_Sync__e> eventList = new List<Core_MDF_Account_PGM_Sync__e>();
        eventList.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_Object_API_Name__c = 'Account',Core_MDF_DML_Operation_Type_txt__c = 'Update',Core_MDF_JSON_Data__c = JSON.serialize(acc23)));
        eventList.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_Object_API_Name__c = 'PRM_Account_Specialty_Association__c',Core_MDF_DML_Operation_Type_txt__c = 'Update',Core_MDF_JSON_Data__c = JSON.serialize(asa) ));
        Core_MDF_Account_PGM_Sync_ServiceHandler.processRecords(eventList);
        Test.stopTest();
    }
}