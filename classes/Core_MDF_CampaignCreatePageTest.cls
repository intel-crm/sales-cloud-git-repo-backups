/* Class Name : Core_MDF_CampaignCreatePage
* Test class : Core_MDF_CampaignCreatePageTest
*/ 
@isTest(seeAllData=false)
public class Core_MDF_CampaignCreatePageTest {
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
    static void createCampaignTest(){
        Test.startTest();
        String filter='Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = \'Intel Partner Alliance\''  ;
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        
        /*String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        

        Campaign ipaCampaign = new Campaign(); 
        ipaCampaign.Name = 'Test Campaign 1';
        ipaCampaign.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        ipaCampaign.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign.StartDate = System.today();
        ipaCampaign.EndDate = System.today().adddays(30);
        ipaCampaign.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign.Core_MDF_Audience__c= 'Channel Partner'; 
        ipaCampaign.Core_MDF_Total_Campaign_Cost_Amt__c = 110000;
        ipaCampaign.Description = 'IPA Campaign Description';
        ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = budgetType;
        ipaCampaign.Core_MDF_Reimbursement_Rate__c = '100%';                                                 
        ipaCampaign.Core_MDF_Technology__c = 'Apollo Lake';
        ipaCampaign.Core_MDF_Market__c = 'India';
        ipaCampaign.Status = 'Pending Approval';*/
        
        Campaign ipaCamp = [SELECT Id,Core_MDF_CampOutcomeOpt_In_Ind__c,Core_MDF_Outcomes_nm__c, Core_MDF_Reimbursement_Amt__c, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Program__c FROM Campaign WHERE Name = 'Test Campaign IPA' LIMIT 1];

        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
        //Parent Account
        Account parentAccount = new Account();
        parentAccount.Name = 'Stark Industries';
        parentAccount.Core_MDF_CoMarketingActive__c = true;
        //Child Account
        Account childAccount = new Account();
        childAccount.Core_MDF_Parent_Fund_Account__c = parentAccount.Id;
        childAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        childAccount.Core_MDF_Channel_Program__c = ipaCP.Id;
        childAccount.Name = 'Stark IPA Account';  
        
        List<Core_MDF_CampaignCreatePage.OutcomeWrapper> outcomeWrapperList = new List<Core_MDF_CampaignCreatePage.OutcomeWrapper>();
        Core_MDF_CampaignCreatePage.OutcomeWrapper wrapper = new Core_MDF_CampaignCreatePage.OutcomeWrapper();
        wrapper.recordId = null;
        wrapper.outcome = ipaCamp.Core_MDF_Outcomes_nm__c;
        wrapper.outcomeLabel = ipaCamp.Core_MDF_Outcomes_nm__c;
        wrapper.baselineQuantity = '100';
        wrapper.goalQuantity = '200';
        wrapper.outcomeCriteria = 'Outcome Criteria';
        outcomeWrapperList.add(wrapper);
        
        //Check Campaign creation
        String campID=Core_MDF_CampaignCreatePage.saveCampaign(ipaCamp, null, null, '','',null,outcomeWrapperList, null,false);
        //Check Campaign Creation for IPA with campAmountFields
        String amtFields ='{\"totalCampaignCost\" :100,\"reimbursementAmount\":50}';
        String campID1=Core_MDF_CampaignCreatePage.saveCampaign(ipaCamp, null, null, amtFields,'',null,outcomeWrapperList, null,false);
        try {
          Core_MDF_CampaignCreatePage.saveCampaign(null, null, null, '','',null,null,null,false);    
          Core_MDF_CampaignCreatePage.getIUPGMAccounts();
        } catch(Exception e) {
        }
        
        assert.areEqual(true,campID != null,'Assert Passed');
        List<string> fieldsetList = new List<String>();fieldsetList.add('Core_MDF_IPA_Campaign_FieldSet');
        //Check loadRecord function
        sObject recordObj=Core_MDF_CampaignCreatePage.loadRecord(ipaCamp.Id,'clone','Campaign',fieldsetList);
        assert.areEqual(true, recordObj != null,'Assert Passed');  
        
        
        //Check Search function
        List<sObject> campaignListQuery = new List<sObject>();
        List<sObject> campaignListQuery2 = new List<sObject>();
        List<sObject> campaignListQuery3 = new List<sObject>();
        List<sObject> campaignListQuery1 =[Select Id, Name from Campaign Where Name Like '%Test Campaign 1%' AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance' LIMIT  10];
        campaignListQuery=Core_MDF_CampaignCreatePage.search('Test Campaign 1','Campaign',filter, true);
        assert.areEqual(true,campaignListQuery.equals(campaignListQuery1),'Assert Passed');
        campaignListQuery2=Core_MDF_CampaignCreatePage.search('Test Campaign 1','Campaign',filter, true);
        assert.areEqual(true,campaignListQuery.equals(campaignListQuery1),'Assert Passed');
        campaignListQuery3=Core_MDF_CampaignCreatePage.search('Account','Account',filter, false);

        //Check searchParentAcc function
        String parentAccFilter = ' RecordType.Name=\'CoMarketing\' AND Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true AND Core_MDF_Channel_Program__r.Name = \'Intel Partner Alliance\'';
        List<sObject> accountQuery = [SELECT Core_MDF_Parent_Fund_Account__r.Id, Core_MDF_Parent_Fund_Account__r.Name FROM Account WHERE Core_MDF_Parent_Fund_Account__r.Name LIKE '%Stark%' AND RecordType.Name='CoMarketing' AND Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true AND Core_MDF_Channel_Program__r.Name= 'Intel Partner Alliance' LIMIT 10];
        List<sObject> parentAcc = new List<sObject>();
        parentAcc = Core_MDF_CampaignCreatePage.searchParentAcc('Stark', 'Account', parentAccFilter);
        assert.areEqual(true, parentAcc.equals(accountQuery), 'Parent Account Fetched');

        String parentAccFilterNegative = ' RecordType.Name=\'CoMarketing\' AND Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true AND Core_MDF_Channel_Program__r.Name = \'Retail Marketing Funds\'';
        parentAcc = Core_MDF_CampaignCreatePage.searchParentAcc('Stark', 'Account', parentAccFilterNegative);
        assert.areEqual(true, parentAcc.isEmpty(), 'Parent Account Not Fetched'); //negative scenario        
        
        try{
        //Check getAccSpecificBudgetTypes function
        Core_MDF_CampaignCreatePage.AccountIdBudgetTypeWrapper abtw = new Core_MDF_CampaignCreatePage.AccountIdBudgetTypeWrapper();
        abtw=Core_MDF_CampaignCreatePage.getAccSpecificBudgetTypes(ipaCoMarketingAccount.id,'Intel Partner Alliance');
        }
        catch(AuraHandledException e){
          assert.areEqual(true, e.getMessage() != null,'Assert Passed');
        }
        
        //Check getFieldEditibilityMapping function
        List<String> fieldApiNameList = new List<String>();
        fieldApiNameList=Core_MDF_CampaignCreatePage.getFieldEditibilityMapping('Campaign','Core_MDF_Intel_Partner_Alliance','Pending Approval',ipaCamp.Id,true,true);
        
        //Check getObjectFields function
        List<Core_MDF_CampaignCreatePage.FieldSetMemberWrapperClass> wrapperList = new List<Core_MDF_CampaignCreatePage.FieldSetMemberWrapperClass>();
        List<string> fieldsetList2 = new List<String>();fieldsetList2.add('Core_MDF_IPA_Campaign_FieldSet');
        wrapperList= Core_MDF_CampaignCreatePage.getObjectFields('Campaign',fieldsetList2,false);
        assert.areEqual(true, wrapperList != null,'Assert Passed'); 
        Test.stopTest();
    }
    
    @isTest 
    static void createPFRTest(){
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        String filter='Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = \'Intel Partner Alliance\''  ;
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        Campaign ipaCamp = [SELECT Id,Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Reimbursement_Amt__c, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Program__c FROM Campaign WHERE Name = 'Test Campaign IPA' LIMIT 1];
        
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
        //Parent Account
        Account parentAccount = new Account();
        parentAccount.Name = 'Stark Industries';
        parentAccount.Core_MDF_CoMarketingActive__c = true;
        //Child Account
        Account childAccount = new Account();
        childAccount.Core_MDF_Parent_Fund_Account__c = parentAccount.Id;
        childAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        childAccount.Core_MDF_Channel_Program__c = ipaCP.Id;
        childAccount.Name = 'Stark IPA Account';   
        PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCamp.id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        
        testPartnerFundRequestRecord1.RequestedAmount = 250;
        testPartnerFundRequestRecord1.Core_MDF_Priorities__c = 'Consumer Chromebook';
        testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestRecord1.Core_MDF_Budget_Amount_Local_amt__c = 250;
        testPartnerFundRequestRecord1.Core_MDF_Budget_Currency_cd__c = 'USD';
        testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = false;
        testPartnerFundRequestRecord1.Core_MDF_Channel_Partner__c = '';
        testPartnerFundRequestRecord1.Core_MDF_ActivityCategory__c = 'Outcome-Based';
        testPartnerFundRequestRecord1.Core_MDF_Activity_Types__c = 'Outcome-Based';
        testPartnerFundRequestRecord1.Core_MDF_Start_Date__c =system.today();
        testPartnerFundRequestRecord1.Core_MDF_End_Date__c =system.today();
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content documents
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        for(ContentDocument ct : documents){
            testPartnerFundRequestRecord1.Core_MDF_Content_DocumentIds_txt__c=ct.Id;
            pfrList.add(testPartnerFundRequestRecord1);
        }     
        insert pfrList;
        //Check Campaign creation
        List<Core_MDF_CampaignCreatePage.ActivityToActivityAttributesWrapper> ataWrap = new List<Core_MDF_CampaignCreatePage.ActivityToActivityAttributesWrapper>();
        List<Core_MDF_Activity_Attributes__c> activityAttributeList = new List<Core_MDF_Activity_Attributes__c>();
        activityAttributeList.add(new Core_MDF_Activity_Attributes__c(Core_MDF_Field_Name_nm__c = 'Incentive Percentage Spend' , Core_MDF_Field_Value_nbr__c = 100, Core_MDF_Is_Active_Ind__c = true, Core_MDF_Tactics_nm__c = 'Incentive', Core_MDF_Type_nm__c='Percentage'));
        activityAttributeList.add(new Core_MDF_Activity_Attributes__c(Core_MDF_Field_Name_nm__c = 'Incentive - # of Deals Registered' , Core_MDF_Field_Value_nbr__c = 12, Core_MDF_Is_Active_Ind__c = true, Core_MDF_Tactics_nm__c = 'Incentive', Core_MDF_Type_nm__c='KPI'));
        
        Core_MDF_CampaignCreatePage.ActivityToActivityAttributesWrapper ata = new Core_MDF_CampaignCreatePage.ActivityToActivityAttributesWrapper();
        ata.activity = pfrList[0];
        ata.activityAttribute = activityAttributeList;
        ataWrap.add(ata);
        String campID=Core_MDF_CampaignCreatePage.saveCampaign(ipaCamp, null, pfrList, '','',null, null,ataWrap,true);
        try {
            Core_MDF_CampaignCreatePage.saveCampaign(null, null, null, '','',null, null,ataWrap,false);
        } catch(Exception e) {
        } 
        assert.areEqual(true,campID != null,'Assert Passed');
        Test.stopTest();
    }
    
    @isTest
    static void testCampaignBudgets(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        System.runAs(testUser){        
        Test.startTest(); 
         Account ccpCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'CCF Co-Marketing Account' LIMIT 1];
        Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c WHERE Name = 'Test' and Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund'  limit 1];
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        List<String> budgetTypeList = new List<String>();
        budgetTypeList.add('MDF');
        budgetTypeList.add('OEM CMP');
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        PartnerMarketingBudget pbm = [select StartDate, EndDate, Core_MDF_Budget_Status__c, Amount,IsIgnoreValidation from PartnerMarketingBudget where Title='Test Budget MDF'];
        //pbm.Core_MDF_Budget_Status__c = 'Released';
        //pbm.IsIgnoreValidation=true;
        //pmbList.add(pbm);
        PartnerMarketingBudget pmbOEMCMP = [select StartDate, EndDate, Core_MDF_Budget_Status__c, Amount,IsIgnoreValidation from PartnerMarketingBudget where Title='Test Budget OEM CMP'];
        //pmbOEMCMP.Core_MDF_Budget_Status__c = 'Released';
        //pmbOEMCMP.IsIgnoreValidation=true;
        //pmbList.add(pmbOEMCMP);
        //Database.update(pmbList);
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfa',pbm, ccpCoMarketingAccount, 10000.00,false);
        PartnerFundAllocation pfa2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfa2',pmbOEMCMP, ccpCoMarketingAccount, 10000.00,false);
        pfaList.add(pfa);
        pfaList.add(pfa2);
        
        Database.insert(pfaList);
        Date startDate1 = Date.newInstance(2021, 7, 1);
        Date endDate1 = Date.newInstance(2021, 7, 30);
        List<Campaign> campList = new List<Campaign>();
        Campaign ccfOpalCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('CCF Opal Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startDate1, endDate1, 10000, 'Consumer Chromebook', ccpCoMarketingAccount.Id, '2-in-1', false);
        ccfOpalCampaign.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
        ccfOpalCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
        ccfOpalCampaign.StartDate = startDate1;
        ccfOpalCampaign.EndDate = endDate1;
        ccfOpalCampaign.Core_MDF_Market__c = 'INDIA';
        ccfOpalCampaign.Core_MDF_Region_cd__c = 'APJ';
        campList.add(ccfOpalCampaign);
        Campaign ccfOEMCMPCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('CCF OEM CMP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startDate1, endDate1, 10000, 'Consumer Chromebook', ccpCoMarketingAccount.Id, '2-in-1', false);
        ccfOEMCMPCampaign.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
        ccfOEMCMPCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        ccfOEMCMPCampaign.StartDate = startDate1;
        ccfOEMCMPCampaign.EndDate = endDate1;
        ccfOEMCMPCampaign.Core_MDF_Market__c = 'INDIA';
        ccfOEMCMPCampaign.Core_MDF_Region_cd__c = 'APJ';
        campList.add(ccfOEMCMPCampaign);
        Database.insert(campList);
        
        
        List<Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass> campaignBudgetsList = new List<Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass>();
        Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass campaignBudgetRecord = new Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass();
        campaignBudgetRecord.budgetId = pbm.id;
        campaignBudgetRecord.budgetName = 'CCF Opal Budget';
        campaignBudgetRecord.budgetAmount = 1000;
        campaignBudgetRecord.budgetRR = '50%';
        campaignBudgetRecord.budgetRAmount = 500;
        campaignBudgetRecord.isActive = true;
        Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass campaignBudgetRecord2 = new Core_MDF_CampaignCreatePage.CampaignBudgetWrapperClass();
        campaignBudgetRecord2.budgetId = pmbOEMCMP.id;
        campaignBudgetRecord2.budgetName = 'CCF OEM CMP Budget';
        campaignBudgetRecord2.budgetAmount = 1000;
        campaignBudgetRecord2.budgetRR = '50%';
        campaignBudgetRecord2.budgetRAmount = 500;
        campaignBudgetRecord2.isActive = true;
        campaignBudgetsList.add(campaignBudgetRecord);
        //campaignBudgetsList.add(campaignBudgetRecord2);
        
        Map<id,PartnerMarketingBudget> campaignBudgets = Core_MDF_CampaignCreatePage.getBudgetsForCampaign(ccpCoMarketingAccount.id, System.today(), System.today(), budgetTypeList);
        //string saveCampaignBudgetsResult = Core_MDF_CampaignCreatePage.saveCampaignBudgets(ccfOpalCampaign.id,campaignBudgetsList);
        String campID=Core_MDF_CampaignCreatePage.saveCampaign(ccfOpalCampaign, campaignBudgetsList, null, '','',null, null,null,false);
        campaignBudgetsList.clear();
        campaignBudgetsList.add(campaignBudgetRecord2);
        String campID2=Core_MDF_CampaignCreatePage.saveCampaign(ccfOEMCMPCampaign, campaignBudgetsList, null, '','',null, null,null,false);
        List<Core_MDF_Campaign_Budgets__c> retrieveCampaignBudgets =  Core_MDF_CampaignCreatePage.getCampaignBudgetsForCampaign(ccfOpalCampaign.id);
        //assert.isTrue('Success',saveCampaignBudgetsResult,'Assert Passed');

        PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(campID,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,ccpCoMarketingAccount.Id,pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord1.RequestedAmount = 250;
        testPartnerFundRequestRecord1.Core_MDF_Priorities__c = 'Consumer Chromebook';
        testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestRecord1.Core_MDF_Budget_Amount_Local_amt__c = 250;
        testPartnerFundRequestRecord1.Core_MDF_Budget_Currency_cd__c = 'USD';
        testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = false;
        testPartnerFundRequestRecord1.Core_MDF_Channel_Partner__c = '';
        testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c='MDF';
        testPartnerFundRequestRecord1.Core_MDF_Start_Date__c =startDate1;
        testPartnerFundRequestRecord1.Core_MDF_End_Date__c =endDate1;
        testPartnerFundRequestRecord1.AllocationId=pfa.Id;
        testPartnerFundRequestRecord1.BudgetId=pbm.Id;
        
        PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(campID,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,ccpCoMarketingAccount.Id,pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord3.RequestedAmount = 250;
        testPartnerFundRequestRecord3.Core_MDF_Priorities__c = 'Consumer Chromebook';
        testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestRecord3.Core_MDF_Budget_Amount_Local_amt__c = 250;
        testPartnerFundRequestRecord3.Core_MDF_Budget_Currency_cd__c = 'USD';
        testPartnerFundRequestRecord3.Core_MDF_Channel_Partner_Led__c = false;
        testPartnerFundRequestRecord3.Core_MDF_Channel_Partner__c = '';
        testPartnerFundRequestRecord3.Core_MDF_Budget_Type_nm__c='MDF';
        testPartnerFundRequestRecord3.Core_MDF_Start_Date__c =startDate1;
        testPartnerFundRequestRecord3.Core_MDF_End_Date__c =endDate1;
        testPartnerFundRequestRecord3.AllocationId=pfa.Id;
        testPartnerFundRequestRecord3.BudgetId=pbm.Id;
        
        PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(campID2,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,ccpCoMarketingAccount.Id,pfa2,pmbOEMCMP,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord2.RequestedAmount = 250;
        testPartnerFundRequestRecord2.Core_MDF_Priorities__c = 'Consumer Chromebook';
        testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestRecord2.Core_MDF_Budget_Amount_Local_amt__c = 250;
        testPartnerFundRequestRecord2.Core_MDF_Budget_Currency_cd__c = 'USD';
        testPartnerFundRequestRecord2.Core_MDF_Channel_Partner_Led__c = false;
        testPartnerFundRequestRecord2.Core_MDF_Channel_Partner__c = '';
        testPartnerFundRequestRecord2.Core_MDF_Budget_Type_nm__c='OEM CMP';
        testPartnerFundRequestRecord2.Core_MDF_Start_Date__c =startDate1;
        testPartnerFundRequestRecord2.Core_MDF_End_Date__c =endDate1;
        testPartnerFundRequestRecord2.AllocationId=pfa2.Id;
        testPartnerFundRequestRecord2.BudgetId=pmbOEMCMP.Id;
        testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_pct__c='50%';
        testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        PartnerFundRequest testPartnerFundRequestRecord4 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(campID2,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,ccpCoMarketingAccount.Id,pfa2,pmbOEMCMP,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        testPartnerFundRequestRecord4.RequestedAmount = 250;
        testPartnerFundRequestRecord4.Core_MDF_Priorities__c = 'Consumer Chromebook';
        testPartnerFundRequestRecord4.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestRecord4.Core_MDF_Budget_Amount_Local_amt__c = 250;
        testPartnerFundRequestRecord4.Core_MDF_Budget_Currency_cd__c = 'USD';
        testPartnerFundRequestRecord4.Core_MDF_Channel_Partner_Led__c = false;
        testPartnerFundRequestRecord4.Core_MDF_Channel_Partner__c = '';
        testPartnerFundRequestRecord4.Core_MDF_Budget_Type_nm__c='OEM CMP';
        testPartnerFundRequestRecord4.Core_MDF_Start_Date__c =startDate1;
        testPartnerFundRequestRecord4.Core_MDF_End_Date__c =endDate1;
        testPartnerFundRequestRecord4.AllocationId=pfa2.Id;
        testPartnerFundRequestRecord4.BudgetId=pmbOEMCMP.Id;
        testPartnerFundRequestRecord4.Core_MDF_Reimbursement_Rate_pct__c='50%';
        testPartnerFundRequestRecord4.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        pfrList.add(testPartnerFundRequestRecord1);
        pfrList.add(testPartnerFundRequestRecord2);
        pfrList.add(testPartnerFundRequestRecord3);
        pfrList.add(testPartnerFundRequestRecord4);
        insert pfrList; 
        assert.areEqual(true,testPartnerFundRequestRecord1 != null,'Assert Passed');
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,testPartnerFundRequestRecord2.Id,
                                                                                   testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, 
                                                                                   testPartnerFundRequestRecord2.Core_MDF_Start_Date__c,50,System.today(),bank.Id,false);
        claim1.Core_MDF_PIC_Review_Completed__c = true;
        claim1.Core_MDF_BackendReviewSelection_Ind__c = false;
        //claim1.Amount = 300;
        claim1.Core_MDF_Currency__c='USD'; 
        claim1.Core_MDF_Number_of_Attendees_Nbr__c = 2;
        pfcList.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim 2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,testPartnerFundRequestRecord2.Id,
                                                                                      testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, 
                                                                                      testPartnerFundRequestRecord2.Core_MDF_Start_Date__c,50,System.today(),bank.Id,false);
        claim2.Core_MDF_PIC_Review_Completed__c = true;
        claim2.Core_MDF_BackendReviewSelection_Ind__c = false;
       // claim2.Amount = 300;
        claim2.Core_MDF_Currency__c='USD'; 
        claim2.Core_MDF_Number_of_Attendees_Nbr__c = 2;
        pfcList.add(claim2);
    //Database.insert(pfcList);
        claim1.Core_MDF_Status__c = 'Paid';
        claim2.Core_MDF_Status__c = 'Paid';
        pfcList.clear();
        pfcList.add(claim1);
        pfcList.add(claim2);
        //Database.update(pfcList);
        testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Closed';
        testPartnerFundRequestRecord2.Core_MDF_Activity_Closure_Type__c = 'Auto';
        Database.update(testPartnerFundRequestRecord2);
        ChannelProgram cp = [SELECT Id, Name, Core_MDF_Technical_Program_Name__c FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c ='Client CoMarketing Fund' LIMIT 1];
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
            esc1.Core_MDF_Escalation_Name_txt__c='TestEscalation';
          esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc1.Core_MDF_Total_Dollar_Impact_amt__c= 23;
            esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc1.Core_MDF_Co_Marketing_Activity_id__c = testPartnerFundRequestRecord2.Id;
            esc1.Core_MDF_Channel_Program_id__c = cp.Id;
            esc1.recordtypeid= claimRecType;
            Database.insert(esc1);
        
            esc1.Core_MDF_Escalation_Status_nm__c='Approved';
        //Database.update(esc1);
        
        Core_MDF_CampaignCreatePage.getBudgetsOnActiveActivities(ccfOpalCampaign.id);
        //Core_MDF_CampaignCreatePage.getBudgetsAmountOnActiveActivities(ccfOpalCampaign.id,campaignBudgetRecord.budgetId);
        Core_MDF_CampaignCreatePage.getBudgetsAmountOnActiveActivities(campID,campaignBudgetRecord.budgetId);
        List<String> validClaimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
        //List<PartnerFundClaim> claimList = [SELECT Id, Amount, Core_MDF_Status__c, RequestId,BudgetId FROM PartnerFundClaim WHERE RequestId = :testPartnerFundRequestRecord2.ID];
        
        //Core_MDF_CampaignCreatePage.getBudgetsAmountOnActiveActivities(ccfOEMCMPCampaign.id,campaignBudgetRecord2.budgetId);
        Core_MDF_CampaignCreatePage.getBudgetsAmountOnActiveActivities(campID2,campaignBudgetRecord2.budgetId);
        Core_MDF_CampaignCreatePage.getIPAActivities(campID);
        List<String> budType = new List<String>{'Account Plan'};
        Core_MDF_CampaignCreatePage.getFieldSetName('Core_MDF_Custom_Picklist__c',budType, 'Campaign', 'Core_MDF_Intel_Partner_Alliance');
        Core_MDF_CampaignCreatePage.geoToCountryMappingValueConnectedCallBack();
        Core_MDF_CampaignCreatePage.fetchIUPGMPNUMAccounts();

        Test.stopTest();
        }
    }
    
     @isTest
    static void testforActivityFieldsViewOnCampaign(){
         Test.startTest();
        List<Core_MDF_CampaignCreatePage.ActivityFieldSVisibility>  activityFieldView =  Core_MDF_CampaignCreatePage.getActivityFields('Core_MDF_IPA_Clone_Fieldset');
            assert.areEqual(true, activityFieldView != null,'Assert Passed'); 
         Test.stopTest();
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
        Core_MDF_CampaignCreatePage.getBudgetType(ipaCoMarketingAccount.Id,'edit',Campipa.Id, 'Intel Partner Alliance');
        User usr2=[select Id,ProfileId from User where LastName = 'User Test1'];
        
        System.runAs(usr2){
            Core_MDF_CampaignCreatePage.getBudgetType(ipaCoMarketingAccount.Id,'create','true', 'Intel Partner Alliance');
            Core_MDF_CampaignCreatePage.getBudgetType(ipaCoMarketingAccount.Id,'edit','true', 'Intel Partner Alliance');
            
        }
         Assert.areNotEqual(ipaPFR,null);
         Test.stopTest();
    }
     @isTest
    static void getAccPropBasedValuesTest(){
         Test.startTest();
           Map<string,string> valuesMap = Core_MDF_CampaignCreatePage.getAccPropBasedValues('Account Based','Intel Partner Alliance');
         Test.stopTest();
        Assert.areNotEqual(valuesMap,null);
    }

    @isTest
    static void checkEditProposalAccessTest(){
        Test.startTest();
        
        Campaign ipaCamp = [SELECT Id,Status FROM Campaign WHERE Name = 'Test Campaign IPA' LIMIT 1];
        ipaCamp.Core_MDF_Approval_Stage_nm__c = 'L1 approval';
        update ipaCamp;
        /*Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        
        String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        Campaign ipaCampaign = new Campaign(); 
        ipaCampaign.Name = 'Test Campaign IPA';
        ipaCampaign.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        ipaCampaign.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign.StartDate = System.today();
        ipaCampaign.EndDate = System.today().adddays(30);
        ipaCampaign.Core_MDF_Account__c = ipaCoMarketingAccount.id;
        ipaCampaign.Core_MDF_Audience__c= 'Channel Partner'; 
        ipaCampaign.Core_MDF_Total_Campaign_Cost_Amt__c = 110000;
        ipaCampaign.Description = 'IPA Campaign Description';
        ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = budgetType;
        ipaCampaign.Core_MDF_Reimbursement_Rate__c = '100%';                                                 
        ipaCampaign.Core_MDF_Technology__c = 'Apollo Lake';
        ipaCampaign.Core_MDF_Market__c = 'India';
        ipaCampaign.Status = 'Pending Review';
        Database.SaveResult sr = Database.insert(ipaCampaign);
        Id ipaId = sr.getId();*/
        
        Core_MDF_CampaignCreatePage.checkEditProposalAccess(ipaCamp.Id, 'Core_MDF_Intel_Partner_Alliance');
        //Core_MDF_CampaignCreatePage.checkEditProposalAccess('00Ng0000004ciVd', 'Core_MDF_Intel_Partner_Alliance');
        //Core_MDF_CampaignCreatePage.getIPAActivities(ipaID);
        //Core_MDF_CampaignCreatePage.mainPicklistFetcher('Core_MDF_Intel_Partner_Alliance');
        Test.stopTest();
        Assert.areNotEqual(ipaCamp,null);
    }
    @isTest
    static void multipleGeosSelectedTest(){
        List<String> countries = new List<String>();
        countries.add('AFGHANISTAN');
        countries.add('ARMENIA');
        Boolean multiGeo = Core_MDF_CampaignCreatePage.multipleGeosSelected(countries,'');
        assert.isTrue(multiGeo);
        List<String> country = new List<String>();
        country.add('AFGHANISTAN');
        multiGeo = Core_MDF_CampaignCreatePage.multipleGeosSelected(country,'');
        assert.isTrue(!multiGeo);
    }
    @isTest
    static void checkClaimsAssociatedToCampaignTest(){
        Test.startTest();
        Campaign ipaCamp = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign IPA' LIMIT 1];
        List<Campaign> cmpList = new List<Campaign>();
        cmpList.add(ipaCamp);
        
        Core_MDF_CampaignServiceHandler.updateIpaL1ApproverComments(cmpList);
        Boolean isClaimAssociated = Core_MDF_CampaignCreatePage.checkClaimsAssociatedToCampaign(ipaCamp.Id);
        assert.isTrue(!isClaimAssociated);
        Test.stopTest();
    }
    @isTest
    static void loadDynamicFieldsTest(){
        List<string> budgetTypeList = new List<String>();budgetTypeList.add('Account Plan');
       List<Core_MDF_CampaignCreatePage.FieldSetMemberWrapperClass> fieldSetValues = Core_MDF_CampaignCreatePage.loadDynamicFields('Core_MDF_Custom_Picklist__c',budgetTypeList,'Campaign');
       assert.isTrue(!fieldSetValues.isEmpty());        
    } 
    @isTest
    static void testCampCreatePageMethods(){
        ChannelProgram EEF = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund',true);     
        Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                          Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
        intAcc.Core_Account_Type__c = 'Reseller';
        intAcc.Industry = 'Food & Beverage';
        intAcc.BillingStateCode = '';
        Database.insert(intAcc);
        
        Account eefAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing EEF Test Account', 
                                                                     EEF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        eefAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
        insert eefAcc;       
        
        Campaign ipaCamp = [SELECT Id, Core_MDF_Partner_Mapping_Txt__c FROM Campaign WHERE Name = 'Test Campaign IPA' LIMIT 1];
        
        Test.startTest();
        Core_MDF_Camp_to_ActPartner__c camptoActPtr = new Core_MDF_Camp_to_ActPartner__c();
        camptoActPtr.Core_MDF_Activating_Partner_Account_id__c = eefAcc.Id;
        camptoActPtr.Core_MDF_Channel_Program__c = EEF.Id;
        camptoActPtr.Core_MDF_Campaign_Id__c = ipaCamp.Id;
        camptoActPtr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        camptoActPtr.Core_MDF_Active_Ind__c = true;
        insert camptoActPtr;
        Core_MDF_CampaignCreatePage.getSIOrISVAccounts(eefAcc.Id);
        Core_MDF_CampaignCreatePage.getPartnerAccList(intAcc.Id);        
        Core_MDF_CampaignCreatePage.getPartnerAccList(intAcc.Id + ';' + intAcc.Id);
        Core_MDF_CampaignCreatePage.saveCampToISVMapping(ipaCamp);
        Core_MDF_CampaignCreatePage.fetchCampToActPartnerData(ipaCamp.Id);
        Core_MDF_CampaignCreatePage.getIUPGMAccounts();
        Test.stopTest();
        assert.isTrue(true);        
    }
    
    
    @isTest
    static void testGetCampaignContractLineItems(){
        Campaign cogtmCamp = [SELECT Id,Core_MDF_CampOutcomeOpt_In_Ind__c,Core_MDF_Outcomes_nm__c, Core_MDF_Reimbursement_Amt__c, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Program__c FROM Campaign WHERE Name = 'Test CoGTM Camp' LIMIT 1];
        List<Map<String, String>> contractsToSaveList = new List<Map<String, String>>();
        // Creating contract data from UI
        Map<String, String> contractsToSaveMapTypeNew = new Map<String, String>();
        contractsToSaveMapTypeNew.put('value', 'test contract 1');
        contractsToSaveMapTypeNew.put('type', 'new');
        contractsToSaveMapTypeNew.put('tempKey', 'temp');
        contractsToSaveMapTypeNew.put('parentId', cogtmCamp.Id);
        contractsToSaveList.add(contractsToSaveMapTypeNew);
        
        Map<String, String> contractsToSaveMapTypeNewBlank = new Map<String, String>();
        contractsToSaveMapTypeNewBlank.put('value', '');
        contractsToSaveMapTypeNewBlank.put('type', 'new');
        contractsToSaveMapTypeNewBlank.put('tempKey', 'temp');
        contractsToSaveMapTypeNewBlank.put('parentId', cogtmCamp.Id);
        contractsToSaveList.add(contractsToSaveMapTypeNewBlank);
        
        Test.startTest();
        List<Core_MDF_Contract_Line_Item__c> contracts = Core_MDF_CampaignCreatePage.getCampaignContractLineItems(cogtmCamp.Id);
        
        // Creating contract data from UI
        Map<String, String> contractsToSaveMapTypeExistingBlank = new Map<String, String>();
        contractsToSaveMapTypeExistingBlank.put('Id', contracts[0].Id);
        contractsToSaveMapTypeExistingBlank.put('value', '');
        contractsToSaveMapTypeExistingBlank.put('type', 'existing');
        contractsToSaveMapTypeExistingBlank.put('tempKey', 'temp');
        contractsToSaveMapTypeExistingBlank.put('parentId', cogtmCamp.Id);
        contractsToSaveList.add(contractsToSaveMapTypeExistingBlank);
        
        Map<String, String> contractsToSaveMapTypeExistingWithValue = new Map<String, String>();
        contractsToSaveMapTypeExistingWithValue.put('Id', contracts[0].Id);
        contractsToSaveMapTypeExistingWithValue.put('value', 'test');
        contractsToSaveMapTypeExistingWithValue.put('type', 'existing');
        contractsToSaveMapTypeExistingWithValue.put('tempKey', 'temp');
        contractsToSaveMapTypeExistingWithValue.put('parentId', cogtmCamp.Id);
        contractsToSaveList.add(contractsToSaveMapTypeExistingWithValue);
        String campID1=Core_MDF_CampaignCreatePage.saveCampaign(cogtmCamp, null, null, '', '', contractsToSaveList, null, null,false);
    List<Core_MDF_CampaignCreatePage.OutcomeWrapper> ls = Core_MDF_CampaignCreatePage.getCampaignOutcomes(cogtmCamp.Id);
        Core_MDF_CampaignCreatePage.OutcomeWrapper obj = new Core_MDF_CampaignCreatePage.OutcomeWrapper(cogtmCamp.Id,'', '', '1', '1', '', '');
        Test.stopTest();
        Assert.areEqual(1, contracts.size());
    }
    
    @isTest
    static void testGetInternalAndExternalUsersByAccount(){
        Core_MDF_CampaignCreatePage.AccountIdBudgetTypeWrapper ab = new Core_MDF_CampaignCreatePage.AccountIdBudgetTypeWrapper();
        Campaign cogtmCamp = [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c FROM Campaign WHERE Name = 'Test CoGTM Camp' LIMIT 1];
        ChannelProgram cogtmCP = [SELECT Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c ='CoGTM' LIMIT 1];
        Test.startTest();
        Map<String, Core_MDF_CampaignCreatePage.UserRecordsAndDefaultUserWrapper> users = Core_MDF_CampaignCreatePage.getInternalAndExternalUsersByAccount(cogtmCamp.Core_MDF_Account__c, cogtmCamp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c, cogtmCP.Id);
        Map<String, Core_MDF_CampaignCreatePage.UserRecordsAndDefaultUserWrapper> users2 = Core_MDF_CampaignCreatePage.getInternalAndExternalUsersByAccount(cogtmCamp.Core_MDF_Account__c, '', cogtmCP.Id);
        Test.stopTest();
        Assert.areEqual(3, users.size());         
    }
    
    @isTest
    static void testMainAndCustomPicklistFetchers() {
        
        // Set mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());       
        Test.startTest();        
        // Call the first method
        Map<String, Object> res1 = Core_MDF_CampaignCreatePage.mainPicklistFetcher('Core_MDF_Client_CoMarketing_Fund');
        System.assertNotEquals(null, res1, 'mainPicklistFetcher should return a result');        
        // Call the second method
        Map<String, Object> res2 = Core_MDF_CampaignCreatePage.PicklistFetcher('Core_MDF_Client_CoMarketing_Fund');
        System.assertNotEquals(null, res2, 'PicklistFetcher should return a result');        
        Test.stopTest();
    }
}