/***************************************************************************************************************************************
* Class Name  : Core_MDF_RecallApprovalHandler_Test
* Version     : 1.0 
* Created Date: 04-26-2021
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_RecallApprovalHandler_Test {
    //setup method to create test data
    public static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    @testSetup static void setUpData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test Recall';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
         List<User> lstUser = new List<user>();
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet aacntRMFMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        
        //Create CCF Channel Program
        
        //System Admin
        User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        systemadm.Email = 'systemadm@example.com';
        lstUser.add(systemAdm);
        
        //RMF Account Manager
        User rmfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        rmfaccntmngr.Email = 'rmfaccntmngr@example.com';
        rmfaccntmngr.Profile = ccpCoreAccessProfile;
        lstUser.add(rmfaccntmngr);
        Database.insert(lstUser);
        
        //Assign permission Sets
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = rmfaccntmngr.Id;
        assignPermissionSetObj.PermissionSetId = aacntRMFMngrPS.Id;
        System.runAs(systemAdm){
            Database.insert(assignPermissionSetObj);
        }
        System.runAs(rmfaccntmngr){
            // Creating channel program with utility class
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            cpList.add(cpRetail);
            insert cpList;
            // Creating Intel Account for retail program
            List<Account> accIntelList = new List<Account>();
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'APJ';            
            accIntelList.add(acc1Retail);
            Database.insert(accIntelList);
            
            List<Campaign> campList = new List<Campaign>();
            // Creating Co-marketing Account with utility class
            List<Account> accCoMarketingList = new List<Account>();
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accCoMarketingList.add(accRetail);
            // Creating Group
            List<Group> groupList = new List<Group>();
            Group accNodeGroup = new Group(Name = 'Core_MDF_Retail_Acc_Node_Group', DeveloperName = 'Core_MDF_Retail_Acc_Node_Group');
            groupList.add(accNodeGroup);
            insert groupList;
            accCoMarketingList[0].Core_MDF_Group_Id__c = accNodeGroup.Id;
            
            Database.insert(accCoMarketingList);
             List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = accRetail.Id;
            iupgm.Core_MDF_All_Accounts_cd__c ='No';
            iupgm.RecordTypeId = RMF_RecordType;
            iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            iupgm.Core_MDF_Region_cd__c = 'APJ';
            iupgm.Core_MDF_User_id__c = rmfaccntmngr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            iupgmList.add(iupgm);
            insert iupgmList;
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today()-2, 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            //camp1.Core_MDF_Supports_legacy_program__c = 'Yes';
            campList.add(camp1);
            insert campList;  
            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLvl_V5',
                 'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                 'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than','0','RequestedAmount','Greater Than','0',false);
            crMulti.Core_MDF_Number_Of_Steps__c = '4';
            Database.insert(crMulti);
            
            Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,rmfaccntmngr.Id, false);
            ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
            ap1Retail.Core_MDF_Step_Number__c = 1;
            Database.insert(ap1Retail);

            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                               'Retail Marketing Funds',true);
        
            Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than',
                                                                                               '0',true);
        
            Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                               'Pending Review',true);
            Core_MDF_Criteria_Rule__c cruleR4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Approval_Step_Completed__c','Equal',
                                                                                               '0',true);

            ap1Retail.Core_MDF_Active__c = true;
            Database.update(ap1Retail);
            crMulti.Core_MDF_Active__c = true;
            Database.update(crMulti);

            Core_MDF_Approver__c ap2Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,rmfaccntmngr.Id, false);
            ap2Retail.Core_MDF_Approver_Type__c = 'Internal';
            ap2Retail.Core_MDF_Step_Number__c = 2;
            Database.insert(ap2Retail);
            /*Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
             PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit1',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,false);
            testBudget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            insert testBudget;
            PartnerFundAllocation pfaTestAccount3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Account 3 Allocation',BudgetRecord1, acc3, 100,true);
                    BudgetRecord1.Core_MDF_Budget_Status__c = 'Approved';
                    Database.update(BudgetRecord1);*/
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');

            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);

            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,accRetail.Id,cpRetail.Id,100000000,System.today().addDays(-15),System.today().addDays(15),false, 'Retail MDF');
        	pmbRecord1.IsIgnoreValidation = true;
        	pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
        	insert pmbRecord1;
            PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,accRetail,20000.0,true);
            
            list<PartnerFundRequest> listPRFToBeInserted = new list<PartnerFundRequest>();
            PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            testPartnerFundRequest1.RequestedAmount =10;
            testPartnerFundRequest1.Amount=1000;
            //testPartnerFundRequest1.Core_MDF_Country__c ='ALBANIA';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'ALBANIA';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequest1.AllocationId=retailAlloc.id;
            
            listPRFToBeInserted.add(testPartnerFundRequest1);
            PartnerFundRequest testPartnerFundRequest2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()+2,System.today()+2,false); 
            
            testPartnerFundRequest2.Title ='Retail MDF Activity NON EMEA';
            testPartnerFundRequest2.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest2.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            testPartnerFundRequest2.RequestedAmount =260;
            testPartnerFundRequest2.Amount=26000;
            //testPartnerFundRequest2.Core_MDF_Country__c ='INDIA';
            testPartnerFundRequest2.Core_MDF_Country_nm__c = 'INDIA';
            testPartnerFundRequest2.Core_MDF_Fund_Request_Status__c ='Closed';
            //testPartnerFundRequest2.Core_MDF_After_the_Fact_Approved_ind__c = false;
            //testPartnerFundRequest2.Core_MDF_ATF_Approval_Reqd_ind__c = false;
            testPartnerFundRequest2.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest2.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequest2.Core_MDF_Activity_Closure_Type__c = 'No Internal Approval';
            listPRFToBeInserted.add(testPartnerFundRequest2);
            Database.insert(listPRFToBeInserted);
        }
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test Recall'  LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
    }
    /**********************************************************************************************************************************
    Method Name:                                   recallApprovalProcessTest
    Description:                                   Created for testing custom approval process for PartnerFundRequest Object
    ***********************************************************************************************************************************/
    @isTest  static void recallApprovalProcessTestEMEA(){
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test Recall'  LIMIT 1];
           PartnerFundRequest pfr = [SELECT id,Title,Core_MDF_Country_nm__c FROM PartnerFundRequest where Title = 'Retail MDF Activity' LIMIT 1];
          System.runAs(user){
            Test.startTest();            
            
            // 1. Create an UK Activity.
         
            // Close that Activity.
            pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfr.Core_MDF_Activity_Closure_Type__c = 'No Internal Approval';
            update pfr;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(pfr.Id);
            Approval.ProcessResult resu = Approval.process(req);     
          
        }
            Test.stopTest();
    }
    @isTest  static void recallApprovalProcessTestNonEMEA(){
        
        PartnerFundRequest pfr = [SELECT id,Title,Core_MDF_Program__c,Core_MDF_Activity_Closure_Type__c,Core_MDF_Country_nm__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c
                                  FROM PartnerFundRequest where Title = 'Retail MDF Activity NON EMEA' LIMIT 1];
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test Recall'  LIMIT 1];
       /* PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);  */
         // pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
                 //  pfr.Core_MDF_Activity_Closure_Type__c = 'No Internal Approval';
          // update pfr;
        System.runAs(user){
           Test.startTest(); 
       
           pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
           pfr.Core_MDF_Start_Date__c = System.today()+5;
           pfr.Core_MDF_End_Date__c = System.today()+5;
          update pfr;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(pfr.Id);
            Approval.ProcessResult resu = Approval.process(req);     
           
                  List<Core_MDF_Recall_Approval__e> approvalRecallList = new  List<Core_MDF_Recall_Approval__e>();
                 Core_MDF_Recall_Approval__e evtObj = new Core_MDF_Recall_Approval__e();
                  evtObj.Core_MDF_Target_Object_Id__c = pfr.Id;
                  evtObj.Core_MDF_Program_nm__c    = pfr.Core_MDF_Program__c ;
                  evtObj.Core_MDF_Request_Status_nm__c = pfr.Core_MDF_Fund_Request_Status__c;
                  evtObj.Core_MDF_Activity_Editor_txt__c = 'Geo Lead';
                  evtObj.Core_MDF_Closure_Type_nm__c = pfr.Core_MDF_Activity_Closure_Type__c;
                  approvalRecallList.add(evtObj);   
                    if(!approvalRecallList.isEmpty()){
                        Eventbus.publish(approvalRecallList);
                    }
          
            Test.stopTest();
        }
        
    }
    
}