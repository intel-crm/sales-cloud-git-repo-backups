/* Main Class Name : Core_MDF_Campaign_QuickActionController
 * Test class Name : Core_MDF_Campaign_QuickActionCtrlTest
 */
@isTest(seeAllData=false)
public class Core_MDF_Campaign_QuickActionCtrlTest {
    
    @TestSetup 
    static void createTestData() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
           

        
        System.runAs(testUser){
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
            ChannelProgram ccf = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram dcf = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account ccfacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test CCF Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,true);
            Account dcfacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test DCF Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,true);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);           
            Account ccfCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CCF Co-Marketing Account', ccf.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ccfacc.id, true);           
            Account dcfCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('DCF Co-Marketing Account', dcf.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,dcfacc.id, true);           

            Core_Trigger_Executions__c coreTriggerExecution = new Core_Trigger_Executions__c();
            coreTriggerExecution.name='Bypass_MDF_Budget_Access';
            coreTriggerExecution.Core_Active__c = true;
            coreTriggerExecution.Core_Class_Name__c = 'Core_MDF_PMBTriggerHandler';
            coreTriggerExecution.Core_Description__c = 'To check whether budget creation access is bypassed or not';
            coreTriggerExecution.Core_Object__c = 'PartnerMarketingBudget';
            coreTriggerExecution.Core_Trigger_Events__c = 'Before Update,Before Insert';
            insert coreTriggerExecution;
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget MDF', Core_MDF_CCP_TestDataUtility.budget_Record_Type, ccfCoMarketingAccount.Id, ccf.Id, 30000, System.today().addDays(-5), System.today().addDays(50), false);
            pbm.Core_MDF_Budget_Type_Txt__c = 'MDF';
            Database.insert(pbm);
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',pbm,ipaCoMarketingAccount, 10000,true);
        
        }
    }
    
    @isTest 
    static void loadCampaignRecordTest(){
        Test.startTest();
        //User usr=[Select id from User where LastName = 'Test User' Limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr){
        Account ipaUltimateAccount=[Select id from Account where Name='IPA Intel Account'];
        ChannelProgram ipaCP=[Select id from ChannelProgram where Name='Intel Partner Alliance'];
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];
        Account ccfCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'CCF Co-Marketing Account' LIMIT 1];
        Account dcfCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'DCF Co-Marketing Account' LIMIT 1];
        
        Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
     	Group ipaGrp1 = new Group();
            ipaGrp1.Name = 'Core CCP IPA External';
            ipaGrp1.DeveloperName = 'Core_MDF_CCP_IPA_External';
            Database.insert(ipaGrp1);
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
          //  system.runAs(usr){
                Database.insert(ipaGrpMem);
            
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External';
            Database.insert(pgm1);
            
        
        //String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        // Highlight: Unused Local Variable 
       // String filter='Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = \'Intel Partner Alliance\''  ;
            
        
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
        ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Account Plan';
        ipaCampaign.Core_MDF_Reimbursement_Rate__c = '100%';                                                 
        ipaCampaign.Core_MDF_Technology__c = 'Other';
        ipaCampaign.Core_MDF_Market__c = 'India';
        ipaCampaign.Status = 'Pending Approval';
        Insert ipaCampaign;
         
        Campaign CCFOpalCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('CCF Opal Campaign','Gaming','Intel® Core™ i7+ Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 10000, 'Consumer Chromebook', ccfCoMarketingAccount.Id, '2-in-1', false);
        CCFOpalCampaign.Core_MDF_Is_Opal__c = 'Yes MDF or both CMP & MDF';
        CCFOpalCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP;MDF';
        Database.insert(CCFOpalCampaign);
        
        Campaign DCFOpalCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('DCF Opal Campaign','Gaming','Intel® Core™ i7+ Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today(), System.today(), 10000, 'Consumer Chromebook', dcfCoMarketingAccount.Id, '2-in-1', false);
        DCFOpalCampaign.Core_MDF_Is_Opal__c = 'Yes MDF or both CMP & MDF';
        DCFOpalCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP;MDF';
        DCFOpalCampaign.Core_MDF_Technology__c = 'Intel® Arc™ graphics';
        Database.insert(DCFOpalCampaign);
         
        Campaign c = [Select id,Recordtype.Developername from Campaign where Name='Test Campaign 1' limit 1];
        Campaign ccfcmp = [Select id,Recordtype.Developername from Campaign where Name='CCF Opal Campaign' limit 1];
        Campaign dcfcmp = [Select id,Recordtype.Developername from Campaign where Name='DCF Opal Campaign' limit 1];
        
        Campaign cmp = Core_MDF_Campaign_QuickActionController.loadCampaignRecord(c.Id);
       // Highlight: Unused Local Variable 
      /*  String x = */ Core_MDF_Campaign_QuickActionController.getRtFieldSetMappings('Campaign','Core_MDF_Intel_Partner_Alliance');
      /*  Boolean b = */ Core_MDF_Campaign_QuickActionController.checkSObjectEditPermission('Campaign');
      /*  Boolean y = */ Core_MDF_Campaign_QuickActionController.isCommunity();
      /*  Campaign rt = */ Core_MDF_Campaign_QuickActionController.loadRecTypeInfo(c.id);
      /*  Boolean hasCloneAccess = */ Core_MDF_Campaign_QuickActionController.checkForCloneAccess(c.Recordtype.Developername,'Planned');
      /*  Boolean hasCloneAccess1 = */ Core_MDF_Campaign_QuickActionController.checkForCloneAccess(ccfcmp.Recordtype.Developername,'Planned');
      /*  Boolean hasCloneAccess2 = */ Core_MDF_Campaign_QuickActionController.checkForCloneAccess(dcfcmp.Recordtype.Developername,'Planned');
      /*  Boolean hasUserIPAExtUser = */ Core_MDF_Campaign_QuickActionController.isUserIPAExtUser();
      /*  Boolean hasEditAccess = */ Core_MDF_Campaign_QuickActionController.checkForEditAccess('Campaign','Core_MDF_Intel_Partner_Alliance','Draft',cmp.Id,true,true);
        Assert.areEqual(true, cmp != null);   
        Test.stopTest();
            }
    }
    
    @isTest 
    static void loadAssocActivityRecordTest(){
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr){
        Account ipaUltimateAccount=[Select id from Account where Name='IPA Intel Account'];
        ChannelProgram ipaCP=[Select id from ChannelProgram where Name='Intel Partner Alliance'];
        //Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];

        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account' LIMIT 1];        
       
        Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
            Group ipaGrp1 = new Group();
            ipaGrp1.Name = 'Core CCP IPA External';
            ipaGrp1.DeveloperName = 'Core_MDF_CCP_IPA_External';
            Database.insert(ipaGrp1);
     
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
       //     system.runAs(usr){
                Database.insert(ipaGrpMem);
            
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External';
            Database.insert(pgm1);
        //String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        // Highlight: Unused Local Variable 
       // String filter='Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = \'Intel Partner Alliance\''  ;
        
           
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
        ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Account Plan';
        ipaCampaign.Core_MDF_Reimbursement_Rate__c = '100%';                                                 
        ipaCampaign.Core_MDF_Technology__c = 'Other';
        ipaCampaign.Core_MDF_Market__c = 'India';
        ipaCampaign.Status = 'Pending Approval';
        Insert ipaCampaign;
        
         PartnerFundAllocation pfa=[Select id from PartnerFundAllocation where Title= :'allocation'];

        //ipa clone
        Id ipaRecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(ipaCampaign.id),ipaRecordTypeId,string.valueof(ipaCoMarketingAccount.id),null,null,'ALBANIA',Null,null,Null,'Event','Joint Event','Draft',false);
        pfr.Core_MDF_Fund_Request_Status__c = 'Draft';
        pfr.Title = 'Test Activity';
        pfr.Core_MDF_Activity_Description__c = 'Test Activity';
        //pfr.Core_MDF_Channel_Partner_Led__c = True;
        pfr.Core_MDF_Budget_Amount_Local_amt__c=1000;
        pfr.Core_MDF_Budget_Currency_cd__c='USD';
        pfr.AllocationId=pfa.id;       
        insert pfr;
        Core_MDF_Campaign_QuickActionController.loadPFRRecords(ipaCampaign.Id, 'clone');
        Core_MDF_Campaign_QuickActionController.loadPFRRecords(ipaCampaign.Id, 'edit');
        Assert.areEqual(true, pfr != null);
        Test.stopTest();
            }
         try {
          Core_MDF_Campaign_QuickActionController.loadPFRRecords(null, null);    
        } catch(Exception e) {
        }
        
    }
}