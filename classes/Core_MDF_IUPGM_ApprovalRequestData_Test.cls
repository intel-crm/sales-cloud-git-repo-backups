@IsTest(SeeAllData=false)
public class Core_MDF_IUPGM_ApprovalRequestData_Test {
    
    @TestSetup
    static void createTestData(){

        User user2 = Core_MDF_CCP_TestDataUtility.createUser(false);       
        user2.LastName = 'Test Budget User';
        insert user2; 
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        User systemAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);      
        systemAdmin.LastName = 'SystemAdmin';
        systemAdmin.UserRoleId = userRole_1.Id;
        insert systemAdmin; 
        
        List<ChannelProgram> cpList=new List<ChannelProgram>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        cpList.add(cp);
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
        cpList.add(ipaCP);
        system.runAs(systemAdmin){
           database.insert(cpList);
        }
        
        List<Account> intelAccList = new List<Account>();
        List<Account> accList = new List<Account>();
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCPTestAccountTemp1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelAccList.add(intelAccount);
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Account_Type__c = 'Reseller';            
        acc1.Industry = 'Food & Beverage';
        acc1.Core_MDF_Channel_Program__c = cp.Id;
        accList.add(acc1);
        
        system.runAs(systemAdmin){
            database.insert(intelAccList);
            database.insert(accList);
        }
        
        List<Account> accCoMarketingList = new List<Account>();
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                  Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
        accCoMarketingList.add(acc);
        Account ipaAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', ipaCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
        accCoMarketingList.add(ipaAcc);
        system.runAs(systemAdmin){
            database.insert(accCoMarketingList);
        }
        
        List<Campaign> campList = new List<Campaign>();
        Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                       Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-250 , 
                                                                       System.today()+90, 200000, 'Unite', acc.Id,'2-in-1', false);
        MDFcamp.Core_MDF_Activity_Category_Type__c = null;
        
        campList.add(MDFcamp);
        system.runAs(systemAdmin){
            database.insert(campList);
        }
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();  
         system.runAs(user2){
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            psaList.add(new PermissionSetAssignment(AssigneeId = user2.id, PermissionSetId = psFinance.Id));
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            psaList.add(new PermissionSetAssignment(AssigneeId = user2.id, PermissionSetId = psFinance1.Id));
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            psaList.add(new PermissionSetAssignment(AssigneeId = user2.id, PermissionSetId = psbudLoader.Id));
            insert psaList;
        }
        
        PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
        opalbudget.Core_MDF_Budget_Type__c='MDF';
        opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
        
        PartnerMarketingBudget cmpbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOEMCMP',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
        cmpbudget.Core_MDF_Budget_Type__c='OEM CMP';
        cmpbudget.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        
        system.runAs(user2){
            insert opalbudget;
            insert cmpbudget;
        }
        test.startTest();
        PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, acc, 199999, false);
        system.runAs(user2){
            insert pfaRecordOpal;
        }
        
        PartnerFundAllocation pfaRecordCmp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',cmpbudget, acc, 199999, false);
        system.runAs(user2){
            insert pfaRecordCmp;
        }
        List<Core_MDF_Campaign_Budgets__c>  cmpBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
        Core_MDF_Campaign_Budgets__c cmpCamBudget = new Core_MDF_Campaign_Budgets__c();
        cmpCamBudget.Core_MDF_Budget_Name_Id__c = cmpbudget.id;
        cmpCamBudget.Core_MDF_Campaign_Id__c = MDFcamp.id;
        cmpCamBudget.Core_MDF_Budget_Amt__c = 363636;
        cmpCamBudget.Core_MDF_Reimbursement_Rate_Pct__c = '100%';
        cmpCamBudget.Core_MDF_Reimbursement_Amt__c = 200000;
        cmpCamBudget.Core_MDF_Active_ind__c = true;
        cmpBudgetList.add(cmpCamBudget);
        system.runAs(systemAdmin){
            database.insert(cmpBudgetList);
        }
        PartnerFundRequest OemCmpPfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        OemCmpPfr1.Title = 'Test Activity OEMCMP1';
        OemCmpPfr1.Core_MDF_Activity_Description__c = 'Test Activity';
        OemCmpPfr1.Core_MDF_Start_Date__c = system.today()-90;
        OemCmpPfr1.BudgetId = cmpbudget.Id;
        OemCmpPfr1.AllocationId = pfaRecordCmp.Id;
        OemCmpPfr1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        OemCmpPfr1.Core_MDF_End_Date__c =  system.today()-30;
        OemCmpPfr1.Core_MDF_Channel_Partner_Led__c = True;
        OemCmpPfr1.Core_MDF_Approval_Step_Completed__c = 0;
        //US - TWC702-14285: Worked on this test class (no logic/structure change)
        OemCmpPfr1.Core_MDF_ActivityCategory__c = ''; //by sumalatha
        //US - TWC702-14285: Worked on this test class (no logic/structure change)
        OemCmpPfr1.Core_MDF_Activity_Types__c = ''; //by sumalatha
        OemCmpPfr1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        OemCmpPfr1.Core_MDF_Reimbursement_Rate_pct__c='100%'; 
        OemCmpPfr1.RequestedAmount = 1001;
        OemCmpPfr1.Core_MDF_Region_nm__c = 'APJ';
        
        System.runAs(systemAdmin){
            insert OemCmpPfr1;
            PartnerFundRequest pfr = [select Id, OwnerId from PartnerFundRequest where Title ='Test Activity OEMCMP1' limit 1];
            pfr.Core_MDF_Approval_Stage__c = 'Price Reviewer';
            update pfr;
            
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
            app.setObjectId(pfr.id);
            app.setSubmitterId(pfr.OwnerId);
            app.setProcessDefinitionNameOrId('Core_MDF_OPAL_Approval_Process_V9'); 
            app.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(app);
            
        }
        
        test.stopTest();
        
        //Insert IPA Campaign
        system.runAs(systemAdmin){
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            update ipaUltimateAccount;
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            ipaCoMarketingAccount.Core_Geo__c = 'APJ';
            insert ipaCoMarketingAccount;
            string budgetType = Core_MDF_CCP_ConstantClass.PR_MDF_BUDGET_TYPE;
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = true;
            ipaCampaignForAP.Status = 'Pending Review';
            ipaCampaignForAP.Core_Approval_Status__c = 'Price Reviewer';
            ipaCampaignForAP.Core_MDF_Technology__c='';//US - TWC702-14285: Worked on this test class (no logic/structure change)
            database.insert(ipaCampaignForAP);
            
            //PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),true);//14285 suma
        }
    }
    
    @isTest
    static void getPfrRecordDataTest(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            List<string> objectList = new List<string>();
            Set<string> programNameSet = new Set<string>{'Client'};
            Set<string> approvalStageSet = new Set<string>{'Price Reviewer'};
                    
            Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap = new Core_MDF_IUPGM_ApprovalRequest.ParamWrapper();
            paramWrap.programNameSet = programNameSet;
            paramWrap.approvalStageSet = approvalStageSet;
            paramWrap.fieldApiNames = 'Title';
            
            Test.startTest();
            List<PartnerFundRequest> pfrList = Core_MDF_IUPGM_ApprovalRequestData.getPfrRecordData(paramWrap);
            Test.stopTest();
            //Assert.areEqual('Test Activity OEMCMP1',pfrList[0].Title);
           
            // US - TWC702-14285: Unit Test Method should include System.Assert   
            System.assertEquals(1, pfrList.size(), 'Should return 1 PartnerFundRequest record');
            System.assertEquals('Test Activity OEMCMP1', pfrList[0].Title, 'Title should match expected value');
        }
    }
    
    @isTest
    static void getCampaignRecordDataTest(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            List<string> objectList = new List<string>();
            Set<string> programNameSet = new Set<string>{'Intel Partner Alliance'};
            Set<string> approvalStageSet = new Set<string>{'Price Reviewer'};
                    
            Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap = new Core_MDF_IUPGM_ApprovalRequest.ParamWrapper();
            paramWrap.programNameSet = programNameSet;
            paramWrap.approvalStageSet = approvalStageSet;
            paramWrap.fieldApiNames = 'Name';
            
            Test.startTest();
            List<Campaign> campList = Core_MDF_IUPGM_ApprovalRequestData.getCampaignRecordData(paramWrap);
            Test.stopTest();
         
            Assert.areEqual(0,campList.size());
        }
    }
    
    @isTest
    static void getPIRecordDataTest(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){

            Set<string> objRecIds = new Set<string>();
            List<PartnerFundRequest> pfrList = [select Id,Title from PartnerFundRequest];
            
            if(!pfrList.isEmpty()){
                for(PartnerFundRequest pfr: pfrList){
                    objRecIds.add(pfr.Id); 
                }
            }
            Set<string> approvalStageSet = new Set<string>{'Price Reviewer'};
                Core_MDF_IUPGM_ApprovalRequest.ParamWrapper paramWrap = new Core_MDF_IUPGM_ApprovalRequest.ParamWrapper();
            paramWrap.objRecIds = objRecIds;
            paramWrap.objName = 'Campaign';
            paramWrap.fieldApiNames = 'Name';
            
            Test.startTest();
            List<SObject> sObjList = Core_MDF_IUPGM_ApprovalRequestData.getPIRecordData(paramWrap);
            Test.stopTest();
          
            Assert.areEqual(0,sObjList.size());
        }
    }
    
}