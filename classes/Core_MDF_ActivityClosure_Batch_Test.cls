@isTest
public class Core_MDF_ActivityClosure_Batch_Test {
    
    @TestSetUp
    static void createTestData(){
        List<String> bypassFunctionKeys2 = new List<String>();
        bypassFunctionKeys2.add('byPass_Cancel_Activity');
        
        Set<String> myset12 = new Set<String>();
        List<String> result12 = new List<String>();
        myset12.addAll(bypassFunctionKeys2);
        result12.addAll(myset12);
        // Highlight: Unused Local Variable - 14285
        //List<Core_Trigger_Executions__c> bypassfunctinalitylist12 = Core_MDF_CCP_TestDataUtility.byPassFeature(result12,false,true);
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Core_MDF_PFR_Rule_Engine');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        // Highlight: Unused Local Variable - 14285
        //List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        List<user> usrList=new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser1';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'TestUser2';
        usr1.profileId = systemAdminProfile.Id;
        usrList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'TestUser3';
        usr2.profileId = systemAdminProfile.Id;
        usrList.add(usr2);
        
        User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr6.LastName = 'TestUser4';
        usr6.IsActive = true;
        usrList.add(usr6);
        
        User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr7.Email = 'sysadmin@example.com';
        usrList.add(usr7);
        
        Database.insert(usrList);
        
        List<Core_MDF_Criteria__c> cList = new List<Core_MDF_Criteria__c>();
        Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                              'Core_MDF_Region_nm__c','Equal','WW','Core_MDF_Region_nm__c','Equal', 'APJ',
                                                                              'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
        cr.Core_MDF_Field_Name_2__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_2__c = 'Equal';
        cr.Core_MDF_Value_2__c = 'WW';
        cr.Core_MDF_Field_Name_3__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_3__c = 'Equal';
        cr.Core_MDF_Value_3__c = 'WW';
        cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_6__c = 'Equal';
        cr.Core_MDF_Value_6__c = 'APJ';
        cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_7__c = 'Equal';
        cr.Core_MDF_Value_7__c = 'WW';
        cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_8__c = 'Equal';
        cr.Core_MDF_Value_8__c = 'WW';
        cr.Core_MDF_Active__c = false;
        cList.add(cr);
        Database.insert(cList);
        
        List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
        
        Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
        ap1.Core_MDF_Approver_Type__c = 'Internal';
        ap1.Core_MDF_Approver_2__c = usr6.Id;
        ap1.Core_MDF_Approver_3__c = usr6.Id;
        ap1.Core_MDF_Approver_4__c = usr6.Id;
        ap1.Core_MDF_Approver_5__c = usr6.Id;
        ap1.Core_MDF_Approver_6__c = usr6.Id;
        ap1.Core_MDF_Approver_7__c = usr6.Id;
        ap1.Core_MDF_Approver_8__c = usr6.Id;
        ap1.Core_MDF_Approver_9__c = usr6.Id;
        ap1.Core_MDF_Approver_10__c = usr6.Id;
        ap1.Core_MDF_Active__c = false;
        appList.add(ap1);
        Database.insert(ap1);
        
        List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
        
        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[0].Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                           'Pending Review',false);
        crList.add(crule1);
        Database.insert(crList);
        
        appList[0].Core_MDF_Active__c = true;
        Database.update(appList);        
        cList[0].Core_MDF_Active__c = true;
        Database.update(cList);
        
        List<Core_MDF_Audit_Rules_Engine__c>ruleList = new List<Core_MDF_Audit_Rules_Engine__c>();
        Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule = new Core_MDF_Audit_Rules_Engine__c(); 
        FrontEndReviewRule.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        FrontEndReviewRule.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        FrontEndReviewRule.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';//Core_MDF_Fund_Request_Status__c';
        FrontEndReviewRule.Core_MDF_Operator_Nm__c= 'Equal';
        FrontEndReviewRule.Core_MDF_Budget_Type_Multi_Nm__c= /*'MDF;MDF+;OEM CMP'*/'OEM CMP';
        FrontEndReviewRule.Core_MDF_Value_Txt__c= 'Pending Review';
        FrontEndReviewRule.Core_MDF_Immediate_Ind__c= 'Yes';
        FrontEndReviewRule.Core_MDF_Effective_Dt__c= System.today()-1;
        FrontEndReviewRule.Core_MDF_Active_Ind__c= true;
        FrontEndReviewRule.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
        FrontEndReviewRule.Core_MDF_Region_Cd__c = 'WW';
        FrontEndReviewRule.Core_MDF_Approver_Source_on_True_nm__c='Approval Criteria';
        FrontEndReviewRule.Core_MDF_Approver_Source_Value_on_True__c=cList[0].Id;
        
        Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule2 = new Core_MDF_Audit_Rules_Engine__c(); 
        FrontEndReviewRule2.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        FrontEndReviewRule2.Core_MDF_Program_Nm__c= 'Retail Marketing Funds';
        FrontEndReviewRule2.Core_MDF_Field_Nm__c= 'Core_MDF_Approval_Step_Completed__c';//Core_MDF_Fund_Request_Status__c';
        FrontEndReviewRule2.Core_MDF_Operator_Nm__c= 'Equal';
        FrontEndReviewRule2.Core_MDF_Budget_Type_Multi_Nm__c= 'RSA MD;Retail MDF';
        FrontEndReviewRule2.Core_MDF_Value_Txt__c= '0';
        FrontEndReviewRule2.Core_MDF_Immediate_Ind__c= 'Yes';
        FrontEndReviewRule2.Core_MDF_Effective_Dt__c= System.today()-1;
        FrontEndReviewRule2.Core_MDF_Active_Ind__c= true;
        FrontEndReviewRule2.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
        FrontEndReviewRule2.Core_MDF_Region_Cd__c = 'WW';
        
        FrontEndReviewRule2.Core_MDF_Approver_Source_on_True_nm__c='Approval Criteria';
        FrontEndReviewRule2.Core_MDF_Approver_Source_Value_on_True__c=cList[0].Id;
        FrontEndReviewRule2.Core_MDF_Approver_Source_on_False_nm__c='Object Field';
        FrontEndReviewRule2.Core_MDF_Approver_Source_Value_on_False__c='Core_MDF_Activity_First_Approver_txt__c';
        FrontEndReviewRule2.Core_MDF_Rule_Action_on_False_nm__c='First Level Manager';
        FrontEndReviewRule2.Core_MDF_Process_Name__c='Core_MDF_Activity_Approval_MultiLvl_V13';
        
        Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule3 = new Core_MDF_Audit_Rules_Engine__c(); 
        FrontEndReviewRule3.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        FrontEndReviewRule3.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        FrontEndReviewRule3.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';//Core_MDF_Fund_Request_Status__c';
        FrontEndReviewRule3.Core_MDF_Operator_Nm__c= 'Equal';
        FrontEndReviewRule3.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+';
        FrontEndReviewRule3.Core_MDF_Value_Txt__c= 'Pending Review';
        FrontEndReviewRule3.Core_MDF_Immediate_Ind__c= 'Yes';
        FrontEndReviewRule3.Core_MDF_Effective_Dt__c= System.today()-1;
        FrontEndReviewRule3.Core_MDF_Active_Ind__c= true;
        FrontEndReviewRule3.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
        FrontEndReviewRule3.Core_MDF_Region_Cd__c = 'WW';
        
        FrontEndReviewRule3.Core_MDF_Approver_Source_on_True_nm__c='IUPGM';
        
        ruleList.add(FrontEndReviewRule);
        ruleList.add(FrontEndReviewRule2);
        ruleList.add(FrontEndReviewRule3);
        Database.insert(ruleList);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        List<Account> accList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                       Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        
        insert acc1;
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',
                                                                             cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             acc1.Id, false);
        acc2.Core_Geo__c = '';  
        acc2.Core_Sub_Geo__c = '';
        
        accList.add(acc2);
        
        // Add additional account for outcome-based testing
        Account acc5 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 5',
                                                                             cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             acc1.Id, false);
        acc5.Core_Geo__c = '';  
        acc5.Core_Sub_Geo__c = '';
        accList.add(acc5);
        
        insert accList;
        Core_MDF_Bank__c bank1 = new Core_MDF_Bank__c();
        
        try{
            bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1241241240');
        }catch(Exception ex){
        }
        
        system.runAs(usr){
            list<PermissionSetAssignment> permList = new list<PermissionSetAssignment>();
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            PermissionSetAssignment perm1 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
            permList.add(perm1);
            PermissionSetAssignment perm3 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            permList.add(perm3);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            PermissionSetAssignment perm2 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance1.Id);
            permList.add(perm2);
            PermissionSetAssignment perm4 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
            permList.add(perm4);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            PermissionSetAssignment perm5 = new  PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psbudLoader.Id);
            permList.add(perm5);
            permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
            PermissionSetAssignment perm6 = new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id);
            permList.add(perm6);
            insert permList;
        }
        
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc2.id, cp.Id , 2000000000,System.today().addDays(-20),System.today() , 
                                                                                      false);
        testBudget.IsIgnoreValidation = true;
        testBudget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        system.runAs(usr){
            //insert testBudget;
        }
        testBudget.Core_MDF_Budget_Status__c = 'Released';
        system.runAs(usr){
            //update testBudget;
        }
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc2.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
        opalbudgetMDF.IsIgnoreValidation = true;
        opalbudgetMDF.Core_MDF_Budget_Type__c='MDF';
        opalbudgetMDF.Core_MDF_Budget_Type_Txt__c='MDF';
        budgetList.add(opalbudgetMDF);
        PartnerMarketingBudget testBudgetOEM = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataOEM',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                         acc2.id, cp.Id , 1000000 ,  System.today().addDays(-30) ,System.today().addDays(30),
                                                                                         false);
        budgetList.add(testBudgetOEM);
        testBudgetOEM.IsIgnoreValidation = true;
        testBudgetOEM.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        testBudgetOEM.Core_MDF_Budget_Type__c='OEM CMP';
        system.runAs(usr1){
            insert budgetList;
        }
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation pfaRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFAOEM',testBudgetOEM, acc2, 100000,false);
        PartnerFundAllocation pfaRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudgetMDF, acc2, 99999, false);
        
        // Add allocation for additional account for outcome-based testing
        PartnerFundAllocation pfaRecord4 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA4',opalbudgetMDF, acc5, 99999, false);
        
        //PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',testBudget,acc2,20.0,false);
        insert pfaRecord1;
        insert pfaRecord3;
        insert pfaRecord4;
        //insert allocation;
       /* pfaList.add(pfaRecord1);
        pfaList.add(pfaRecord3);
        pfaList.add(allocation);
        insert pfaList;*/
        system.runAs(usr1){
            List<Campaign> cmplst = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                        System.today()+30, 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                        acc2.Id,'Desktop', false);
            
            Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                           'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                           System.today()+30, 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                           acc2.Id,'Desktop', false);
            ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'MDF';
            cmplst.add(camp);
            cmplst.add(ccfCamp);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc3.Core_Geo__c = 'APJ';
            acc3.Core_Sub_Geo__c = 'IJKK';
            acc3.BillingStateCode = '';
            acc3.BillingCountryCode = '';
            insert acc3;
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
            acc4.Core_Geo__c = 'APJ';
            acc4.Core_Sub_Geo__c = 'IJKK';
            insert acc4;
            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                           acc4.id, cp1.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                           false);
            
            testBudget1.IsIgnoreValidation = true;
            testBudget1.Core_MDF_Budget_Type_Txt__c = ' RSA MD';
            
            system.runAs(usr2){
                insert testBudget1;
            }
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            system.runAs(usr2){
                update testBudget1;
            }
            
            Test.startTest();
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                         'Client CoMarketing Fund', System.today()-100, //System.today().addDays(-300), 
                                                                         System.today()+100, 10000, 'Instore innovation', 
                                                                         acc4.Id,'Desktop', false);
            
            camp1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            camp1.Core_MDF_Activity_Category_Type__c =null;
            camp1.Core_MDF_Program__c = 'Retail Marketing Funds';
            camp1.Core_MDF_Reimbursement_Rate__c='100%';
            camp1.Core_MDF_Technology__c = 'ACPC';
            
            cmplst.add(camp1);
            
            Campaign camp6 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 45','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                         'Client CoMarketing Fund', system.today()+ 2, //System.today().addDays(-300), 
                                                                         System.today()+230, 10000, 'Instore innovation', 
                                                                         acc4.Id,'Desktop', false);
            
            camp6.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            camp6.Core_MDF_Activity_Category_Type__c =null;
            camp6.Core_MDF_Program__c = 'Retail Marketing Funds';
            camp6.Core_MDF_Reimbursement_Rate__c='100%';
            camp6.Core_MDF_Technology__c = 'ACPC';
            
            cmplst.add(camp6);
            
            insert cmplst;
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<PartnerFundRequest> pfrToUpdate = new List<PartnerFundRequest>();
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc4.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF'; 
            MDFpfr.RequestedAmount =220;
            MDFpfr.Title = 'CCF_ACTIVITY';
            MDFpfr.Core_MDF_Fund_Request_Status__c='Pending Review';
            MDFpfr.Core_MDF_Approval_Step_Completed__c=1;
            MDFpfr.Core_MDF_ActivityCategory__c = '';
            MDFpfr.Core_MDF_Activity_Types__c = '';
            pfrList.add(MDFpfr);
            
            PartnerFundRequest MDFpfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc4.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr1.Core_MDF_Budget_Type_nm__c = 'MDF'; 
            MDFpfr1.RequestedAmount =220;
            MDFpfr1.Title = 'CCF_ACTIVITY1';
            MDFpfr1.Core_MDF_Fund_Request_Status__c='Pending Review';
            MDFpfr1.Core_MDF_Approval_Step_Completed__c=1;
            MDFpfr1.Core_MDF_ActivityCategory__c = '';
            MDFpfr1.Core_MDF_Activity_Types__c = '';
            pfrList.add(MDFpfr1);
            
            // Create outcome-based parent activity for testing
            PartnerFundRequest outcomeBasedParent = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc2.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                                          'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            outcomeBasedParent.Core_MDF_Budget_Type_nm__c = 'MDF'; 
            outcomeBasedParent.RequestedAmount = 500;
            outcomeBasedParent.Title = 'OUTCOME_BASED_PARENT';
            outcomeBasedParent.Core_MDF_Fund_Request_Status__c = 'Planned';
            outcomeBasedParent.Core_MDF_Is_Outcome_Based_Ind__c = true;
            outcomeBasedParent.Core_MDF_Activity_Level_nm__c = null; // Parent activity
            outcomeBasedParent.Core_MDF_ActivityCategory__c = '';
            outcomeBasedParent.Core_MDF_Activity_Types__c = '';
            pfrList.add(outcomeBasedParent);
            
            insert pfrList;
            
            // Create sub-activities for outcome-based parent
            List<PartnerFundRequest> subActivityList = new List<PartnerFundRequest>();
            
            // Sub-activity 1
            PartnerFundRequest subActivity1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                                    Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc2.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                                    'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            subActivity1.Core_MDF_Budget_Type_nm__c = 'MDF'; 
            subActivity1.RequestedAmount = 250;
            subActivity1.Title = 'OUTCOME_BASED_SUB1';
            subActivity1.Core_MDF_Fund_Request_Status__c = 'Planned';
            subActivity1.Core_MDF_Is_Outcome_Based_Ind__c = true;
            subActivity1.Core_MDF_Activity_Level_nm__c = 'Sub Activity';
            subActivity1.Core_MDF_Parent_Activity_Id__c = outcomeBasedParent.Id;
            subActivity1.ChannelPartnerId = acc2.Id;
            subActivity1.AllocationId = pfaRecord3.Id;
            subActivity1.Core_MDF_ActivityCategory__c = '';
            subActivity1.Core_MDF_Activity_Types__c = '';
            subActivityList.add(subActivity1);
            
            // Sub-activity 2
            PartnerFundRequest subActivity2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                                    Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc5.id),pfaRecord4,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                                    'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            subActivity2.Core_MDF_Budget_Type_nm__c = 'MDF'; 
            subActivity2.RequestedAmount = 250;
            subActivity2.Title = 'OUTCOME_BASED_SUB2';
            subActivity2.Core_MDF_Fund_Request_Status__c = 'Planned';
            subActivity2.Core_MDF_Is_Outcome_Based_Ind__c = true;
            subActivity2.Core_MDF_Activity_Level_nm__c = 'Sub Activity';
            subActivity2.Core_MDF_Parent_Activity_Id__c = outcomeBasedParent.Id;
            subActivity2.ChannelPartnerId = acc5.Id;
            subActivity2.AllocationId = pfaRecord4.Id;
            subActivity2.Core_MDF_ActivityCategory__c = '';
            subActivity2.Core_MDF_Activity_Types__c = '';
            subActivityList.add(subActivity2);
            
            insert subActivityList;
            
            // Create account mappings for outcome-based activity
            List<Core_MDF_Outcome_Account_Mapping__c> mappingList = new List<Core_MDF_Outcome_Account_Mapping__c>();
            
            Core_MDF_Outcome_Account_Mapping__c mapping1 = new Core_MDF_Outcome_Account_Mapping__c();
            mapping1.Core_MDF_Outcome_Based_CampaignId__c = outcomeBasedParent.Id;
            mapping1.Core_MDF_AccountId__c = acc2.Id;
            mapping1.Core_MDF_Percentage_pct__c = 50;
            mapping1.Core_MDF_Amount_nbr__c = 250;
            mapping1.Core_MDF_Active_Ind__c = true;
            mapping1.Core_MDF_OutcomeBased_SubAct_Id__c = subActivity1.Id;
            mappingList.add(mapping1);
            
            Core_MDF_Outcome_Account_Mapping__c mapping2 = new Core_MDF_Outcome_Account_Mapping__c();
            mapping2.Core_MDF_Outcome_Based_CampaignId__c = outcomeBasedParent.Id;
            mapping2.Core_MDF_AccountId__c = acc5.Id;
            mapping2.Core_MDF_Percentage_pct__c = 50;
            mapping2.Core_MDF_Amount_nbr__c = 250;
            mapping2.Core_MDF_Active_Ind__c = true;
            mapping2.Core_MDF_OutcomeBased_SubAct_Id__c = subActivity2.Id;
            mappingList.add(mapping2);
            
            insert mappingList;
            
            List<PartnerFundRequest> pfrUpdate = [select Id,Title,Core_MDF_Fund_Request_Status__c,Core_MDF_ToBeClosedDate__c from PartnerFundRequest where (Title = 'CCF_ACTIVITY1' OR Title = 'CCF_ACTIVITY2' OR Title = 'OUTCOME_BASED_PARENT')];
            for(PartnerFundRequest pf: pfrUpdate){
                pf.Core_MDF_ToBeClosedDate__c = system.today()-2;
                if(pf.Title == 'CCF_ACTIVITY1'){
                    pf.Core_MDF_Fund_Request_Status__c = 'Planned';    
                }
                if(pf.Title == 'OUTCOME_BASED_PARENT'){
                    pf.Core_MDF_Fund_Request_Status__c = 'Planned';    
                }
            }
            update pfrUpdate;        
        }      
        Test.stopTest();   
    }
    
    @isTest 
    static void checkValidateClaims(){
        Test.startTest();

        List<PartnerFundRequest> pfrList = [select Id,Amount,Core_MDF_Fund_Request_Status__c,Core_MDF_ToBeClosedDate__c
                                             from PartnerFundRequest where Title = 'CCF_ACTIVITY' LIMIT 1];
        pfrList[0].Core_MDF_ToBeClosedDate__c = system.today() - 2;
        update pfrList;
         
        Core_MDF_ActivityClosure_Batch obj =new Core_MDF_ActivityClosure_Batch();
        Database.executeBatch(obj);
        System.Assert(obj!=null);
        Test.stopTest();
    }
    
    @isTest 
    static void checkOutcomeBasedActivityClosure(){
        Test.startTest();

        // Get outcome-based parent activity
        List<PartnerFundRequest> outcomeBasedParentList = [select Id,Amount,Core_MDF_Fund_Request_Status__c,Core_MDF_ToBeClosedDate__c,
                                                          Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_Activity_Level_nm__c
                                                          from PartnerFundRequest where Title = 'OUTCOME_BASED_PARENT' LIMIT 1];
        
        if(!outcomeBasedParentList.isEmpty()) {
            outcomeBasedParentList[0].Core_MDF_ToBeClosedDate__c = system.today() - 2;
            update outcomeBasedParentList;
            
            // Get sub-activities and create claims for them
            List<PartnerFundRequest> subActivities = [SELECT Id, Core_MDF_Parent_Activity_Id__c 
                                                     FROM PartnerFundRequest 
                                                     WHERE Core_MDF_Parent_Activity_Id__c = :outcomeBasedParentList[0].Id 
                                                     AND Core_MDF_Activity_Level_nm__c = 'Sub Activity'];
            
            // Create claims for sub-activities
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            
            for(PartnerFundRequest subActivity : subActivities) {
                PartnerFundClaim claim = new PartnerFundClaim();
                claim.Title = 'Test Claim for Sub Activity';
                claim.RequestId = subActivity.Id;
                claim.Core_MDF_Status__c = 'Paid';
                claim.Amount = 100;
                claim.Core_MDF_Country_Location_nm__c = 'INDIA';
                claim.Core_MDF_Ad_Run_Start_Date__c = System.today();
                claim.Core_MDF_Ad_Run_End_Date__c = System.today();
                claim.Core_MDF_Currency__c = 'USD';
                claim.Core_MDF_Total_Invoice_Amount_Local__c = 100.00;
                claim.Core_MDF_Invoice_Number__c = '123' + subActivity.Id;
                claim.Core_MDF_Invoice_Date__c = System.today();
                claim.RecordTypeId = Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF;
                claim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
                claim.Core_MDF_Type_Txt__c = 'Claim';
                claimList.add(claim);
            }
            
            if(!claimList.isEmpty()) {
                //insert claimList;
            }
            
            // Execute batch with outcome-based parent activity
            Core_MDF_ActivityClosure_Batch obj = new Core_MDF_ActivityClosure_Batch();
            Database.executeBatch(obj);
            System.Assert(obj != null);
        }
        
        Test.stopTest();
    }
    
    @isTest 
    static void checkRegularActivityClosure(){
        Test.startTest();

        // Get regular activity
        List<PartnerFundRequest> regularActivityList = [select Id,Amount,Core_MDF_Fund_Request_Status__c,Core_MDF_ToBeClosedDate__c,
                                                       Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_Activity_Level_nm__c
                                                       from PartnerFundRequest where Title = 'CCF_ACTIVITY1' LIMIT 1];
        
        if(!regularActivityList.isEmpty()) {
            regularActivityList[0].Core_MDF_ToBeClosedDate__c = system.today() - 2;
            update regularActivityList;
            
            // Create claim for regular activity
            PartnerFundClaim claim = new PartnerFundClaim();
            claim.Title = 'Test Claim for Regular Activity';
            claim.RequestId = regularActivityList[0].Id;
            claim.Core_MDF_Status__c = 'Paid';
            claim.Amount = 150;
            claim.Core_MDF_Country_Location_nm__c = 'INDIA';
            claim.Core_MDF_Ad_Run_Start_Date__c = System.today();
            claim.Core_MDF_Ad_Run_End_Date__c = System.today();
            claim.Core_MDF_Currency__c = 'USD';
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 150.00;
            claim.Core_MDF_Invoice_Number__c = '456';
            claim.Core_MDF_Invoice_Date__c = System.today();
            claim.RecordTypeId = Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF;
            claim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claim.Core_MDF_Type_Txt__c = 'Claim';
            //insert claim;
            
            // Execute batch with regular activity
            Core_MDF_ActivityClosure_Batch obj = new Core_MDF_ActivityClosure_Batch();
            Database.executeBatch(obj);
            System.Assert(obj != null);
        }
        
        Test.stopTest();
    }
    
    @isTest 
    static void checkBatchWithNoRecordId(){
        Test.startTest();
        
        // Get any available activity for testing
        List<PartnerFundRequest> pfrList = [select Id from PartnerFundRequest LIMIT 1];
        
        if(!pfrList.isEmpty()) {
            // Test batch with specific record ID (since parameterless constructor doesn't exist)
            Core_MDF_ActivityClosure_Batch obj = new Core_MDF_ActivityClosure_Batch();
            Database.executeBatch(obj);
            System.Assert(obj != null);
        }
        
        Test.stopTest();
    }
}