/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountOnboardingHelper_test
* Version     : 1.0 
* Created Date: 26-Oct-2021
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel -Areefa          26-Oct-2021                    Created to test AccountOnboarding Functionality 
*****************************************************************************************************************************************/
@isTest(seeAllData = false)
public class Core_MDF_AccountOnboardingHelper_test {
    @testSetup 
    static void setup() { 
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        testUser.Email = 'sysadmin@example.com';
        Database.insert(testUser);
        
        System.runAs(testUser){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            cpList.add(cpCCF);
            ChannelProgram cpRMF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
            cpList.add(cpRMF);
            ChannelProgram cpIPA = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', false);
            cpList.add(cpIPA);
            Database.insert(cpList);
            
            Id opidRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        	Account opid = new Account(Name = 'opidAcc01', RecordTypeId = opidRecType);
        	insert opid;
        	opid.Core_IPA_One_Partner_Id__c = opid.Id;
        	update opid;
            
            List<Account> ultimateAccList = new List<Account>();
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(ccfUltimateAccount);
            Account ccfUltimateAccount2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Intel Account2',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount2.Core_MDF_CoMarketingActive__c = true;
            ultimateAccList.add(ccfUltimateAccount2);
            Account rmfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('RMF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            rmfUltimateAccount.Core_Geo__c='';
            rmfUltimateAccount.Core_Sub_Geo__c='';
            rmfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(rmfUltimateAccount);
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccount.Core_MDF_CoMarketingActive__c = false;            
            ultimateAccList.add(ipaUltimateAccount);                       	
            
            Id benefitRec = Schema.SObjectType.PRM_PartnerBenefit__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
            PRM_PartnerBenefit__c benefit = new PRM_PartnerBenefit__c();
            benefit.PRM_Benefit_Cd__c = 'MDFACCCCP';
            benefit.RecordTypeId = benefitRec;
            benefit.Name = 'Market Development Funds (Account MDF)-CCP';
            benefit.PRM_Channel_Program_Id__c = cpIPA.Id;
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

            
            List<Account> ipaAccList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account2',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_MDF_CoMarketingActive__c = false;
            acc1.Core_IPA_One_Partner_Id__c = opid.Id;
            acc1.Core_Unified_Global_Customer_BP_Id__c = '324619';
            acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            ipaAccList.add(acc1);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account3',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc2.Core_MDF_CoMarketingActive__c = false;
            acc2.Core_Unified_Global_Customer_BP_Id__c = '324619';
            acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            ipaAccList.add(acc2);
            Database.insert(ipaAccList);
            Id PAG_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            Account pagAccount = new Account(Name='IPA PAG Account', RecordTypeId=PAG_Account_Record_Type);           
            insert pagAccount;
            
            Account pagAcc = [Select id from Account where Name='IPA PAG Account' and RecordTypeId=:PAG_Account_Record_Type limit 1];
            
            Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=pagAcc.Id,Core_Intel_Account_Id__c=acc1.Id);
            insert agm;
            
            ChannelProgram cpid = new ChannelProgram(); //Channel Program
            cpid.Name=Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
            //cpid.PRM_programCode__c='IPA';
            insert cpid;   
            
            PRM_BatchCustomSetting__c bcss = new PRM_BatchCustomSetting__c();
            bcss.name= 'BatchFieldValues';
            //bcss.PRM_MP_Benefits__c='Speciality';
            bcss.PRM_PartnerRole__c='Service Provider';
            bcss.PRM_PartnerType__c='Cloud Service Provider (CSP)';
            insert bcss;
            
            Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
            PRM_Specialty__c spec1 = new PRM_Specialty__c();
            //spec1.name='Business Client Acceleration - MDF';
            spec1.name='Proposal I MDF';
            spec1.PRM_Description_Txt__c='This is description';
            spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
            spec1.PRM_Role_Nm__c='Service Provider';
            spec1.PRM_Tier_Nm__c='Gold';
            spec1.PRM_Start_Date_Dt__c= system.today() + 7;
            spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
            spec1.PRM_Access_Level_Nm__c='Public';
            spec1.RecordTypeId=selectBenRT;
            spec1.PRM_Inactive_Ind__c=false;
            insert spec1;
            
            List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
            PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
            asa.PRM_InActive_Ind__c  = FALSE;
            asa.PRM_Specialty_Id__c = spec1.ID;
            asa.PRM_Account_Id__c =pagAcc.id;
            asaList.add(asa);
            PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
            asa1.PRM_InActive_Ind__c  = FALSE;
            asa1.PRM_Specialty_Id__c = spec1.ID;
            asa1.PRM_Account_Id__c =acc1.id;
            PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
            asa2.PRM_InActive_Ind__c  = FALSE;
            asa2.PRM_Specialty_Id__c = spec1.ID;
            asa2.PRM_Account_Id__c =acc2.id;
            asaList.add(asa1);
            asaList.add(asa2);
            Database.insert(asaList);
                        
            Test.startTest();
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Sharing_to_PGM');
            bypassFunctionKeys.add('Bypass_Account_Program_based_Sharing');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            
            Database.insert(ultimateAccList);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testIntelAccOnboardMethod(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Client'];
            Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            Account ccfAcc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'CCF Intel Account' LIMIT 1];
            ccfAcc.Core_Unified_Global_Customer_BP_Id__c = 'testUnifiedIdValue';
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            
            assert.areEqual('Intel Account', accOnb.Core_MDF_Type__c);
            
            Core_MDF_Account_Onboarding__c accOnbAfterInsert = [SELECT Id, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c FROM Core_MDF_Account_Onboarding__c WHERE Core_MDF_Account__c =: ccfAcc.Id LIMIT 1];
            if(accOnbAfterInsert != NULL){
                assert.areEqual(TRUE, accOnbAfterInsert.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c);
            }
            
            String accountId = '%'+accOnb.Core_MDF_Account__c+'%';
            
            Group gp = [SELECT Id,Name,DeveloperName FROM Group WHERE Name LIKE :accountId LIMIT 1];
            
            String grpDevName = 'Core_MDF_CCP_'+accOnb.Core_MDF_Account__c+'_'+'CCF_EXT';
            
            if(gp != NULL){
                assert.areEqual(grpDevName, gp.DeveloperName);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c,Core_MDF_All_Access_Group_Nm__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(pgm != NULL){
              // Highlight: Unused Local Variable
              // String accId = String.valueOf(pgm.Core_MDF_Account__c);
                assert.areEqual(grpDevName, pgm.Core_MDF_Group_Name__c);
                assert.areEqual('External', pgm.Core_MDF_Type_of_Access__c);
                
                List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = [SELECT Id, Name, Core_MDF_Partner_Group_Mapping_Id__c FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Core_MDF_Partner_Group_Mapping_Id__c =: pgm.Id];
                assert.areEqual(TRUE, pgdmList != NULL);
            }
            
            Account vcAccount = [SELECT Id,Name FROM Account WHERE Core_MDF_Parent_Fund_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(vcAccount != NULL){
                assert.areEqual('CCF Virtual Corp Account', vcAccount.Name);
            }
            Test.stopTest();
        }
    }
    @isTest
    static void testIntelIPAAccOnboardMethod(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];
            Id accOnboard_RecordType_IPA = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            Account opid = [Select Id from Account where Name = 'opidAcc01'];
            Account ccfAcc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'IPA Intel Account2' LIMIT 1];
            ccfAcc.Core_MDF_CoMarketingActive__c = TRUE;
            ccfAcc.Core_Unified_Global_Customer_BP_Id__c = 'testUnifiedIdValue';
            ccfAcc.Core_IPA_One_Partner_Id__c = opid.Id;
            update ccfAcc;            
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_IPA;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            acconb.Core_MDF_Host_Region_nm__c = 'APJ';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'IPA Virtual Corp Account';
            Database.insert(accOnb);
            
            assert.areEqual('Intel Account', accOnb.Core_MDF_Type__c);
            
            Core_MDF_Account_Onboarding__c accOnbAfterInsert = [SELECT Id, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c FROM Core_MDF_Account_Onboarding__c WHERE Core_MDF_Account__c =: ccfAcc.Id LIMIT 1];
            if(accOnbAfterInsert != NULL){
                assert.areEqual(TRUE, accOnbAfterInsert.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c);
            }
            
            String accountId = '%'+accOnb.Core_MDF_Account__c+'%';
            
            Group gp = [SELECT Id,Name,DeveloperName FROM Group WHERE Name LIKE :accountId LIMIT 1];
            
            String grpDevName = 'Core_MDF_CCP_'+accOnb.Core_MDF_Account__c+'_'+'IPA_EXT';
            
            if(gp != NULL){
                assert.areEqual(grpDevName, gp.DeveloperName);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(pgm != NULL){
                assert.areEqual(grpDevName, pgm.Core_MDF_Group_Name__c);
                assert.areEqual('External', pgm.Core_MDF_Type_of_Access__c);
                
                List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = [SELECT Id, Name, Core_MDF_Partner_Group_Mapping_Id__c FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Core_MDF_Partner_Group_Mapping_Id__c =: pgm.Id];
                assert.areEqual(TRUE, pgdmList != NULL);
            }
            
            Account vcAccount = [SELECT Id,Name FROM Account WHERE Core_MDF_Parent_Fund_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(vcAccount != NULL){
                assert.areEqual('IPA Virtual Corp Account', vcAccount.Name);
            }
            Test.stopTest();
            
        }
    } 
    @isTest
    static void testBypassIntelIPAAccOnboardMethod(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            Core_Trigger_Executions__c enableIPAMDFAccountOnboarding = new Core_Trigger_Executions__c();
            enableIPAMDFAccountOnboarding.name = 'Bypass_AccountOnboardOPIDValidations';
            enableIPAMDFAccountOnboarding.Core_Object__c = 'Core_MDF_Account_Onboarding__c';
            enableIPAMDFAccountOnboarding.Core_Trigger_Events__c = 'after Insert';
            enableIPAMDFAccountOnboarding.Core_Active__c = TRUE;
            enableIPAMDFAccountOnboarding.Core_Description__c = 'Bypass_AccountOnboardOPIDValidations';
            enableIPAMDFAccountOnboarding.Core_Class_Name__c = 'Core_MDF_AccountOnboardingHelper';
            insert enableIPAMDFAccountOnboarding;
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];
            
            Account ccfAcc = [SELECT Id,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'IPA Intel Account2' LIMIT 1];
            ccfAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            update ccfAcc;
            Id accOnboard_RecordType_IPA = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId =accOnboard_RecordType_IPA; 
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            acconb.Core_MDF_Host_Region_nm__c = 'APJ';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'IPA Virtual Corp Account';
            Database.insert(accOnb);
            
            assert.areEqual('Intel Account', accOnb.Core_MDF_Type__c);
            
            Core_MDF_Account_Onboarding__c accOnbAfterInsert = [SELECT Id, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c FROM Core_MDF_Account_Onboarding__c WHERE Core_MDF_Account__c =: ccfAcc.Id LIMIT 1];
            if(accOnbAfterInsert != NULL){
                assert.areEqual(TRUE, accOnbAfterInsert.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c);
            }
            
            String accountId = '%'+accOnb.Core_MDF_Account__c+'%';
            
            Group gp = [SELECT Id,Name,DeveloperName FROM Group WHERE Name LIKE :accountId LIMIT 1];
            
            String grpDevName = 'Core_MDF_CCP_'+accOnb.Core_MDF_Account__c+'_'+'IPA_EXT';
            
            if(gp != NULL){
                assert.areEqual(grpDevName, gp.DeveloperName);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(pgm != NULL){
                assert.areEqual(grpDevName, pgm.Core_MDF_Group_Name__c);
                assert.areEqual('External', pgm.Core_MDF_Type_of_Access__c);
                
                List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = [SELECT Id, Name, Core_MDF_Partner_Group_Mapping_Id__c FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Core_MDF_Partner_Group_Mapping_Id__c =: pgm.Id];
                assert.areEqual(TRUE, pgdmList != NULL);
            }
            
            Account vcAccount = [SELECT Id,Name FROM Account WHERE Core_MDF_Parent_Fund_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(vcAccount != NULL){
                assert.areEqual('IPA Virtual Corp Account', vcAccount.Name);
            }
            Test.stopTest();
    
        }
    }    
    @isTest
    static void testAgencyAccOnboardMethod(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Client'];
            Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            Account ccfAcc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'CCF Intel Account' LIMIT 1];
            ccfAcc.Core_Unified_Global_Customer_BP_Id__c = 'testUnifiedIdValue';
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Agency Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            Database.insert(ccfUltimateAccount);
            
            Core_MDF_Account_Onboarding__c agencyAccOnboard = new Core_MDF_Account_Onboarding__c();
            agencyAccOnboard.RecordTypeId = accOnboard_RecordType_CCF;
            agencyAccOnboard.Core_MDF_Account__c = ccfUltimateAccount.Id;
            //agencyAccOnboard.Core_MDF_Channel_Program__c = ccfCP.Id;
            agencyAccOnboard.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            agencyAccOnboard.Core_MDF_Type__c = 'Agency Account';
            agencyAccOnboard.Core_MDF_Works_For__c = ccfAcc.Id;
            //agencyAccOnboard.Core_MDF_Domains_txt__c = 'ccfagency.com;ccfagency1.com';
            Database.insert(agencyAccOnboard);
            
            assert.areEqual('Agency Account', agencyAccOnboard.Core_MDF_Type__c);
            
            Core_MDF_Account_Onboarding__c accOnbAfterInsert = [SELECT Id, Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c FROM Core_MDF_Account_Onboarding__c WHERE Core_MDF_Account__c =: ccfUltimateAccount.Id LIMIT 1];
            if(accOnbAfterInsert != NULL){
                assert.areEqual(TRUE, accOnbAfterInsert.Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c);
            }
            
            String accountId = '%'+accOnb.Core_MDF_Account__c+'%';
            
            Group gp = [SELECT Id,Name,DeveloperName FROM Group WHERE Name LIKE :accountId LIMIT 1];
            
            String grpDevName = 'Core_MDF_CCP_'+accOnb.Core_MDF_Account__c+'_'+'CCF_EXT';
            
            if(gp != NULL){
                assert.areEqual(grpDevName, gp.DeveloperName);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: agencyAccOnboard.Core_MDF_Account__c LIMIT 1];
            if(pgm != NULL){
                assert.areEqual(grpDevName, pgm.Core_MDF_Group_Name__c);
                assert.areEqual('External', pgm.Core_MDF_Type_of_Access__c);
                
                List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = [SELECT Id, Name, Core_MDF_Partner_Group_Mapping_Id__c FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Core_MDF_Partner_Group_Mapping_Id__c =: pgm.Id];
                assert.areEqual(TRUE, pgdmList != NULL);
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testAccAlreadyExistsError(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
            Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            Account ccfAcc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'CCF Intel Account' LIMIT 1];
            ccfAcc.Core_Unified_Global_Customer_BP_Id__c = 'testUnifiedIdValue';            
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            
            Core_MDF_Account_Onboarding__c accOnb1 = new Core_MDF_Account_Onboarding__c();
            accOnb1.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb1.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb1.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb1.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb1.Core_MDF_Type__c = 'Intel Account';
            accOnb1.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb1.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb1.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            
            try{
                Database.insert(accOnb1);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AccountAlreadyExistError')),True);}
            Test.stopTest();
        }
    }
    
    @isTest
    static void testWorksForError(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
             Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            Account ccfAcc = [SELECT Id,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'CCF Intel Account' LIMIT 1];
            
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Agency Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            Database.insert(ccfUltimateAccount);
            
            Core_MDF_Account_Onboarding__c agencyAccOnboard = new Core_MDF_Account_Onboarding__c();
            agencyAccOnboard.RecordTypeId = accOnboard_RecordType_CCF;
            agencyAccOnboard.Core_MDF_Account__c = ccfUltimateAccount.Id;
            agencyAccOnboard.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            //agencyAccOnboard.Core_MDF_Channel_Program__c = ccfCP.Id;
            agencyAccOnboard.Core_MDF_Type__c = 'Agency Account';
            agencyAccOnboard.Core_MDF_Works_For__c = ccfAcc.Id;
            agencyAccOnboard.Core_MDF_Domains_txt__c = 'ccfagency.com;ccfagency1.com';
            
            try{
                Database.insert(agencyAccOnboard);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_WorksforAccountError')),True);}
            Test.stopTest();
        }
    } 
    
    @isTest
    static void testIpaFlagError(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ipaCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Intel Partner Alliance' LIMIT 1];
            Id accOnboard_RecordType_IPA = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            Account ipaAcc = [SELECT Id,Core_MDF_CoMarketingActive__c,Core_Intel_Partner_Alliance_PartnerGroup__c, Name FROM Account WHERE Name = 'IPA Intel Account' LIMIT 1];
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_IPA;
            accOnb.Core_MDF_Account__c = ipaAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ipaCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Intel Partner Alliance';
            acconb.Core_MDF_Host_Region_nm__c = 'APJ';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            
            try{
                Database.insert(accOnb);
            }catch(Exception e)
            {
            assert.areEqual(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPAAccountFlagError')),true);}
            Test.stopTest();
        }
    } 
    @isTest
    static void testRMFGeoError(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram rmfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Retail Marketing Funds'];
             Id rmf_RT = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            Account rmfAcc = [SELECT Id,Core_Geo__c,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'RMF Intel Account' LIMIT 1];
            
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = rmf_RT;
            accOnb.Core_MDF_Account__c = rmfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = rmfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Retail Marketing Funds';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'RMF Virtual Corp Account';
            
            try{
                Database.insert(accOnb);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_RegionMandatoryError')),True);}
            Test.stopTest();
        }
    }
    @isTest
    static void testRMFGeo(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram rmfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Retail Marketing Funds'];
            Id rmf_RT = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            Account rmfAcc = [SELECT Id,Core_Geo__c,Core_Sub_Geo__c,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'RMF Intel Account' LIMIT 1];
            rmfAcc.Core_Geo__c='ASMO';
            rmfAcc.Core_Sub_Geo__c='NAR';
            update rmfAcc;
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = rmf_RT;
            accOnb.Core_MDF_Account__c = rmfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = rmfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Retail Marketing Funds';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'RMF Virtual Corp Account';
            
            try{
                Database.insert(accOnb);
            }catch(Exception e){}
            //{assert.areEqual(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_RegionMandatoryError')),True);}
            Account vcAccount = [SELECT Id,Name,Core_Geo__c FROM Account WHERE Core_MDF_Parent_Fund_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(vcAccount != NULL)
            {
                assert.areEqual('ASMO', vcAccount.Core_Geo__c);
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testAgencyOnboardRestrictionsMethod(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
             Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            Account ccfAcc = [SELECT Id,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'CCF Intel Account' LIMIT 1];            
            
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            assert.areEqual('Intel Account',accOnb.Core_MDF_Type__c);
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Agency Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Core_MDF_Account_Onboarding__c agencyAccOnboard = new Core_MDF_Account_Onboarding__c();
            agencyAccOnboard.Core_MDF_Account__c = ccfUltimateAccount.Id;
            //agencyAccOnboard.Core_MDF_Channel_Program__c = ccfCP.Id;
            agencyAccOnboard.RecordTypeId = accOnboard_RecordType_CCF;
            agencyAccOnboard.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            agencyAccOnboard.Core_MDF_Type__c = 'Agency Account';
            agencyAccOnboard.Core_MDF_Works_For__c = ccfAcc.Id;
            agencyAccOnboard.Core_MDF_Domains_txt__c = 'ccfagency.com;ccfagency1.com';
            
            try{
                Database.insert(agencyAccOnboard);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AgencyOnboardingRestriction')),True);}
            Test.stopTest();
        }
    }
    @isTest
    static void testIntelAccOnboardMethodForIsPartner(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.startTest();
            //ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
             Id accOnboard_RecordType_CCF = Schema.SObjectType.Core_MDF_Account_Onboarding__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();
            Account ccfAcc = [SELECT Id,Core_MDF_CoMarketingActive__c, Name FROM Account WHERE Name = 'CCF Intel Account2' LIMIT 1];
            
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.RecordTypeId = accOnboard_RecordType_CCF;
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            //accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Technical_Program_nm__c = 'Client CoMarketing Fund';
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            
            assert.areEqual('Intel Account', accOnb.Core_MDF_Type__c);
            
            Core_MDF_Account_Onboarding__c accOnbAfterInsert = [SELECT Id, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c FROM Core_MDF_Account_Onboarding__c WHERE Core_MDF_Account__c =: ccfAcc.Id LIMIT 1];
            if(accOnbAfterInsert != NULL){
                assert.areEqual(TRUE, accOnbAfterInsert.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c);
            }
            
            String accountId = '%'+accOnb.Core_MDF_Account__c+'%';
            
            Group gp = [SELECT Id,Name,DeveloperName FROM Group WHERE Name LIKE :accountId LIMIT 1];
            
            String grpDevName = 'Core_MDF_CCP_'+accOnb.Core_MDF_Account__c+'_'+'CCF_EXT';
            
            if(gp != NULL){
                assert.areEqual(grpDevName, gp.DeveloperName);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c,Core_MDF_Type_of_Access__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(pgm != NULL){
                assert.areEqual(grpDevName, pgm.Core_MDF_Group_Name__c);
                assert.areEqual('External', pgm.Core_MDF_Type_of_Access__c);
                
                List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = [SELECT Id, Name, Core_MDF_Partner_Group_Mapping_Id__c FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Core_MDF_Partner_Group_Mapping_Id__c =: pgm.Id];
                assert.areEqual(TRUE, pgdmList != NULL);
            }
            
            Account vcAccount = [SELECT Id,Name FROM Account WHERE Core_MDF_Parent_Fund_Account__c =: accOnb.Core_MDF_Account__c LIMIT 1];
            if(vcAccount != NULL){
                assert.areEqual('CCF Virtual Corp Account', vcAccount.Name);
            }
            Test.stopTest();
        }
    }
}