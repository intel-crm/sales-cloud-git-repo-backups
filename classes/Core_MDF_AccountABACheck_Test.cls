/* Class Name : Core_MDF_AccountABACheck
* Test class : Core_MDF_AccountABACheck_Test
*/
@isTest(seeAllData=false)
public class Core_MDF_AccountABACheck_Test {
    //Set Up All Data
    @TestSetup static void setUpData() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        System.runAs(testUser){
            
            Core_Trigger_Executions__c execution2 = new Core_Trigger_Executions__c();
            execution2.Name = 'Core_MDF_Bypass_Manual_Share';
            execution2.Core_Active__c = TRUE;
            execution2.Core_Class_Name__c = 'Core_MDF_PNUMappingTriggerHandler';
            execution2.Core_Description__c = 'Switch ON/OFF the Manual Share';
            execution2.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
            execution2.Core_Trigger_Events__c = 'After Insert';
            insert execution2;
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('BypassCampaignBenefitValidation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            List<Account> accountList = new List<Account>();
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', false);
            ChannelProgram ccpCP = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, 'Client CoMarketing Fund', false);
            ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram ('Co-GTM','CoGTM', true);
            cpList.add(ipaCP); cpList.add(ccpCP); 
            Database.insert(cpList);
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccount.BillingStateCode = '';
            insert ipaUltimateAccount;
            ipaUltimateAccount.Core_Unified_Global_Customer_BP_Id__c ='primeId1';
            ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            update ipaUltimateAccount;
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);   
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCF Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ccpIntelAccount.BillingStateCode = '';
            insert ccpIntelAccount;
            Account ccpCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CCF Co-Marketing Account', ccpCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            //Account cmdfCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CMDF Co-Marketing Account', cmdfCp.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ccpIntelAccount.id, true); 
            Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
            insert coGTMCoMarketingAccount;
            
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (ccpIntelAccount.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            /*User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
      usr2.LastName = 'User Test2';
      usr2.ProfileId = partnerProfile.Id;
      usr2.ContactId = con.Id;
      usr2.Email='UserTest2@mailinator.com';
      Database.insert(usr2);*/
            
            ipaCoMarketingAccount.Core_Geo__c = '';
            ipaCoMarketingAccount.Core_Sub_Geo__c ='';
            ccpCoMarketingAccount.Core_Geo__c = '';
            ccpCoMarketingAccount.Core_Sub_Geo__c ='';
            accountList.add(ipaCoMarketingAccount);accountList.add(ccpCoMarketingAccount);
            Database.insert(accountList);
            
            Core_Trigger_Executions__c coreTriggerExecution = new Core_Trigger_Executions__c();
            coreTriggerExecution.name='Bypass_MDF_Budget_Access';
            coreTriggerExecution.Core_Active__c = true;
            coreTriggerExecution.Core_Class_Name__c = 'Core_MDF_PMBTriggerHandler';
            coreTriggerExecution.Core_Description__c = 'To check whether budget creation access is bypassed or not';
            coreTriggerExecution.Core_Object__c = 'PartnerMarketingBudget';
            coreTriggerExecution.Core_Trigger_Events__c = 'Before Update,Before Insert';
            insert coreTriggerExecution;
            
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget MDF', Core_MDF_CCP_TestDataUtility.budget_Record_Type, ccpCoMarketingAccount.Id, ccpCP.Id, 30000, System.today().addDays(-5), System.today().addDays(50), false);
            pbm.IsIgnoreValidation=true;
            pbm.Core_MDF_Budget_Status__c = 'Released';
            pbm.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pmbList.add(pbm);
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget OEM CMP', Core_MDF_CCP_TestDataUtility.budget_Record_Type, ccpCoMarketingAccount.Id, ccpCP.Id, 30000, System.today().addDays(-5), System.today().addDays(50), false);
            pmb.IsIgnoreValidation=true;
            pmb.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            pmb.Core_MDF_Budget_Status__c = 'Released';
            pmbList.add(pmb);
            Database.insert(pmbList);
            
            
            
            // Creating User with utility class 
            List<User> usrList = new List<User>();
            User extUsr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr1.LastName = 'User Test1';
            extUsr1.ProfileId = partnerProfile.Id;
            extUsr1.ContactId = con.Id;
            extUsr1.IsActive = TRUE;
            usrList.add(extUsr1);
            Database.insert(usrList);
            
            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Proposal_Manager'];
            
            List<PermissionSetAssignment>permissionSetAssignmentList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr1.Id);
            permissionSetAssignmentList.add(psa1);
            Database.insert(permissionSetAssignmentList);
            
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            
            Database.insert(grpList);
            
            // Creating Group Member
            List<GroupMember> grpMemList = new List<GroupMember>();
            GroupMember ipaExtGrpMem1 = new GroupMember();
            ipaExtGrpMem1.UserOrGroupId = extUsr1.Id;
            ipaExtGrpMem1.GroupId = ipaExtGrp.Id;
            grpMemList.add(ipaExtGrpMem1);
            Database.insert(grpMemList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgmExt = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgmExt.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgmExt.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt.Core_MDF_Group_Id__c = ipaExtGrp.Id;                
            pgmExt.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmExt.Core_MDF_Source_Txt__c = 'Test';
            pgmExt.Core_MDF_Region_cd__C = 'APJ';
            pgmExt.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External1';
            pgmExt.Core_MDF_Virtual_Corp_nm__c = ipaCoMarketingAccount.id;
            pgmList.add(pgmExt);
            
            Database.insert(pgmList);
            
            Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
            Set<Id> accIdSet = new Set<Id>();
            accIdSet.add(ipaCoMarketingAccount.Id);
            userIdCorpAcctIdSet.put(extUsr1.Id, accIdSet);
            //Core_MDF_IPA_AccountUserMapping.createPnumRecords(userIdCorpAcctIdSet);
            
            String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign IPA',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Proposal I MDF';
            ipaCampaignForAP.Core_MDF_Partner_Mapping_Txt__c = extUsr1.Id;
            ipaCampaignForAP.Core_MDF_Market__c = 'UNITED STATES';
            ipaCampaignForAP.Core_MDF_Approval_Stage_nm__c = 'L1 approval';
            ipaCampaignForAP.Core_MDF_CampOutcomeOpt_In_Ind__c = true;
            ipaCampaignForAP.Core_MDF_Outcomes_nm__c = 'Revenue - Billings';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
            insert ipaCampaignForAP;
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccount.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
            bank.Core_MDF_Intel_Company_Code__c = '650';
            bank.Core_MDF_Currency_cd__c = 'USD';
            bank.Core_MDF_Tax_codes_cd__c = 'UB';
            bank.Core_MDF_Bank_Status__c = 'Active';
            bank.Core_MDF_VAT_pct__c= '20';
            bank.Core_MDF_Bank_Location__c = 'US';
            bank.Core_MDF_Supplier_City_txt__c = 'New York';
            bank.Core_MDF_Supplier_Country_txt__c = 'US';
            bank.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
            bank.Core_MDF_Supplier_Region_txt__c = 'USA'; 
            bankList.add(bank); 
            Core_MDF_Bank__c bank2 = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231231');
            bank2.Core_MDF_Intel_Company_Code__c = '100';
            bank2.Core_MDF_Currency_cd__c = 'USD';
            bank2.Core_MDF_Bank_Status__c = 'Active';
            bank2.Core_MDF_Bank_Location__c = 'US';
            bank2.Core_MDF_Supplier_City_txt__c = 'New York';
            bank2.Core_MDF_Supplier_Country_txt__c = 'US';
            bank2.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
            bank2.Core_MDF_Supplier_Region_txt__c = 'USA'; 
            bankList.add(bank2); 
            Database.insert(bankList);
            //creating ABM for indiaBank
            List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();   
            
            Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ipaCoMarketingAccount.Id,bank.Id,false); 
            abmlist.add(abm);
            
            Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ccpCoMarketingAccount.Id,bank2.Id,false); 
            abmlist.add(abm2);
            Database.insert(abmlist);     
            
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Category__c = 'Bank Document Hold Logic';
            config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            insert config;
            
            //Co-GTM Campaign    
            Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            
            Campaign coGTMCampaign = new Campaign();
            coGTMCampaign.Name = 'Test CoGTM Camp';
            coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
            coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
            coGTMCampaign.Status = 'Draft';
            coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
            coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
            coGTMCampaign.StartDate = System.today().addDays(-1);
            coGTMCampaign.EndDate = System.today().addDays(15);
            coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
            coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
            insert coGTMCampaign;
            
            Core_MDF_Contract_Line_Item__c contractLineItem = new Core_MDF_Contract_Line_Item__c();
            contractLineItem.Core_MDF_Contract_Section_Details_txt__c  = 'test';
            contractLineItem.Core_MDF_Campaign_Id__c = coGTMCampaign.Id;
            insert contractLineItem;
            
        }
    }
    @isTest
    static void getBudgetTypeTest(){
         Test.startTest();
        
        
        Account ipaCoMarketingAccount = [select Id,Name from Account Where Name = 'IPA Co-Marketing Account' limit 1];
        
        Id campaign_RecordType_ipa = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        Campaign Campipa = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp Share1','Commercial','Intel® Core™ i3 Processor','MDF or both CMP & MDF', 
                                                                              campaign_RecordType_ipa, 'Intel Partner Alliance', System.today()-25,System.today()+30, 5000, 'Consumer Chromebook',ipaCoMarketingAccount.Id,'',false);
        Campipa.Core_MDF_Market__c = 'AFGHANISTAN';
        Campipa.Core_MDF_Opal_Budget_Type_Txt__c = 'Proposal I MDF';
        Campipa.Core_MDF_Proposal_Based_Ind__c = true;
        Campipa.Core_MDF_Region_cd__c ='APJ';
        Database.insert (Campipa);
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest( Campipa.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
        //mdfPFR.Core_MDF_Focus_Area_nm__c ='Client Computing';
        insert ipaPFR;
        Core_MDF_PartnerFundRequestCreatePage.getBudgetType(ipaCoMarketingAccount.Id,'edit','false', 'Intel Partner Alliance');
        User usr2=[select Id,ProfileId from User where LastName = 'User Test1'];
        
        System.runAs(usr2){
            Core_MDF_PartnerFundRequestCreatePage.getBudgetType(ipaCoMarketingAccount.Id,'create','false', 'Intel Partner Alliance');
            Core_MDF_PartnerFundRequestCreatePage.getBudgetType(ipaCoMarketingAccount.Id,'edit','false', 'Intel Partner Alliance');
            
        }
         Assert.areNotEqual(ipaPFR,null);
         Test.stopTest();
    }
}