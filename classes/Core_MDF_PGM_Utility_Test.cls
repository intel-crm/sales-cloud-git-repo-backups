@isTest
public class Core_MDF_PGM_Utility_Test {

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
        
        Core_Trigger_Executions__c enableIPAMDFAccountOnboarding = new Core_Trigger_Executions__c();
        enableIPAMDFAccountOnboarding.name = 'Bypass_AccountOnboardOPIDValidations';
        enableIPAMDFAccountOnboarding.Core_Object__c = 'Core_MDF_Account_Onboarding__c';
        enableIPAMDFAccountOnboarding.Core_Trigger_Events__c = 'after Insert';
        enableIPAMDFAccountOnboarding.Core_Active__c = TRUE;
        enableIPAMDFAccountOnboarding.Core_Description__c = 'Bypass_AccountOnboardOPIDValidations';
        enableIPAMDFAccountOnboarding.Core_Class_Name__c = 'Core_MDF_AccountOnboardingHelper';
        //insert enableIPAMDFAccountOnboarding;
        triggerList.add(enableIPAMDFAccountOnboarding);
        insert triggerList;
        
        List<Account> accList = new List<Account>();

        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_MDF_CoMarketingActive__c = false;
        //acc1.Core_Prime_Id__c = 'Prime001';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc1.Core_Unified_Global_Customer_BP_Id__c = 'unified001%';
        accList.add(acc1);

        Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc2.Core_MDF_CoMarketingActive__c = false;
        //acc2.Core_Prime_Id__c = 'Prime001';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Unified_Global_Customer_BP_Id__c = 'unified001%';
        accList.add(acc2);

        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc3.Core_MDF_CoMarketingActive__c = false;
        //acc3.Core_Prime_Id__c = 'Prime002';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Unified_Global_Customer_BP_Id__c = 'Unifiedig01@';
        accList.add(acc3);

        Account acc4 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 4', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc4.Core_MDF_CoMarketingActive__c = false;
        //acc4.Core_Prime_Id__c = 'Prime002';
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc4.Core_Unified_Global_Customer_BP_Id__c = 'Unifiedig01@';
        accList.add(acc4);
		
         Account acc5 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 5', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc5.Core_MDF_CoMarketingActive__c = false;
        acc5.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accList.add(acc5);
        
        Account acc6 = Core_MDF_CCP_TestDataUtility.createIntelAccount('[Prime] Intel Account 6', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc6.Core_MDF_CoMarketingActive__c = false;
        acc6.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accList.add(acc6);
        
        insert accList;
		
         ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        insert cpIPATest;
        
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
        ChannelProgram eefProgram =  Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
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
         insert nonCoMarpgmRec;
            
            
        }

        Test.stopTest();
        
    }  
    @isTest
    public static void getAccPGMKeyGrpIdMapTest(){
        List<Account> accList = [Select id,Name from Account where RecordType.DeveloperName = 'Mastered_Account'];
        
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        pgmList = [Select id,name,Core_MDF_Group_Name__c,Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c limit 10];
        List<ChannelProgram> cpList= [Select id from ChannelProgram];
        List<Id> cpIdList = new List<Id>();
        for(ChannelProgram cp:cpList){
            cpIdList.add(cp.Id);
        }
         assert.isNotNull(accList);
        Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper pgmKeyGrpIdWrapper = new Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper();
        //pgmKeyGrpIdWrapper = Core_MDF_PGM_Utility.getAccPGMKeyGrpIdMap(accList,cpIdList,null);
        
        
    }
    
}