/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapHelper 
* Version     : 1.0 
* Created Date: 04-30-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        5/09/2019                 Prevents the claim creation/Update if claimed amount exceeds the remaining budget cap
* NP(11630236)                  15-4-2020                 US633341 - Enabling Multiple Budget Cap Functionality
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_BudgetCapHelper_Clone{ 
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
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            cpList.add(cpCCF);
            ChannelProgram cpDCF = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            cpList.add(cpDCF);
            ChannelProgram cpSPCF = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', false);
            cpList.add(cpSPCF);
            ChannelProgram cpCCFB = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund Boost','Client CoMarketing Fund Boost', false);
            cpList.add(cpCCFB);
            ChannelProgram cpRMF = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            cpList.add(cpRMF);
            ChannelProgram cpIPA = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(cpIPA);
            Database.insert(cpList);
            
            List<Account> ultimateAccList = new List<Account>();
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(ccfUltimateAccount);
            Account dcfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('DCF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            dcfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(dcfUltimateAccount);
            Account spcfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('SPCF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            spcfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(spcfUltimateAccount);
            Account ccfbUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCFB Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfbUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(ccfbUltimateAccount);
            Account rmfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('RMF Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            rmfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(rmfUltimateAccount);
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            ultimateAccList.add(ipaUltimateAccount);
            Test.startTest();
            Database.insert(ultimateAccList);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testAccOnboardMethod(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            ChannelProgram ccfCP = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
            Account ccfAcc = [SELECT Id, Name FROM Account WHERE Name = 'CCF Intel Account'];
            Core_MDF_Account_Onboarding__c accOnb = new Core_MDF_Account_Onboarding__c();
            accOnb.Core_MDF_Account__c = ccfAcc.Id;
            accOnb.Core_MDF_Channel_Program__c = ccfCP.Id;
            accOnb.Core_MDF_Type__c = 'Intel Account';
            accOnb.Core_MDF_SubParent_Account_to_be_Created__c = TRUE;
            accOnb.Core_MDF_Domains_txt__c = 'ccf.com;ccf1.com';
            accOnb.Core_MDF_Virtual_Account_Name_txt__c = 'CCF Virtual Corp Account';
            Database.insert(accOnb);
            
            Account ccfUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Agency Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccfUltimateAccount.Core_MDF_CoMarketingActive__c = false;
            Database.insert(ccfUltimateAccount);
            Core_MDF_Account_Onboarding__c agencyAccOnboard = new Core_MDF_Account_Onboarding__c();
            agencyAccOnboard.Core_MDF_Account__c = ccfUltimateAccount.Id;
            agencyAccOnboard.Core_MDF_Channel_Program__c = ccfCP.Id;
            agencyAccOnboard.Core_MDF_Type__c = 'Agency Account';
            agencyAccOnboard.Core_MDF_Works_For__c = ccfAcc.Id;
            agencyAccOnboard.Core_MDF_Domains_txt__c = 'ccfagency.com;ccfagency1.com';
            Database.insert(agencyAccOnboard);
        }
    }
    
}