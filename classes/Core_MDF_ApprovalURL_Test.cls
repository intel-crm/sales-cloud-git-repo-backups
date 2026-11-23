@isTest
public class Core_MDF_ApprovalURL_Test {
    /*Core_MDF_ApprovalURL.actrID ='';
Core_MDF_ApprovalURL.recID = '';
Core_MDF_ApprovalURL.*/
    public static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    @testSetup
    static void setup()
    {
        
        List<Account> accList = new List<Account>();
        
        //Setting up profile and permission set for User
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet aacntRMFMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        
        //Create CCF Channel Program
        ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        // Creating Intel Account for retail program
        Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                              false);
        Database.insert(acc1Retail);
        //adding bypass feature to bypass access validation
      List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        // Creating Retail Account with utility class
        Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail.Core_Geo__c = 'APJ';
        Database.insert(accRetail);
        
        PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
        Test.startTest();
        PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                       accRetail.id, cpRetail.Id , 10000 , System.today()-60 , System.today() + 30 , 
                                                                                       false);
        
        testBudget1.IsIgnoreValidation = true;
        insert testBudget1;
        testBudget1.Core_MDF_Budget_Status__c = 'Released';
        update testBudget1;
        
        List<User> lstUser = new List<user>();
        
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
        
        // Create IUPGM Data
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = accRetail.Id;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
        iupgm.RecordTypeId = RMF_RecordType;
        iupgm.Core_MDF_Region_cd__c = 'APJ';
        iupgm.Core_MDF_User_id__c = rmfaccntmngr.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
        iupgmList.add(iupgm);
        insert iupgmList;
        
        system.assert(iupgmList[0].Core_MDF_Account_id__c == accRetail.Id);
        
        //Create Campaign
        List<Campaign> campList = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes',
                                                                    Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                    System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
        campList.add(camp);
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
        
        Test.stopTest();
    }
    @isTest static void approvalURL(){
        Account accRetail = [SELECT id FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1 ];
        Campaign camp = [SELECT Id,Name FROM Campaign WHERE Name = 'TestRetailCamp' LIMIT 1];
        User usr = [select id,email from User where email='rmfaccntmngr@example.com'];
        Test.startTest();
        System.runAs(usr) {
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accRetail.id),System.today().addDays(17),System.today().addDays(18),false); 
            
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            Database.insert(pfr);
            
            System.assert(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review');
                        /*Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(pfr.id);
            Approval.ProcessResult result = Approval.process(app);
          */
            List<ProcessInstanceWorkitem> workItemLst = [ SELECT id, ActorId 
                                                         FROM ProcessInstanceWorkitem 
                                                         WHERE processInstance.TargetObjectId=:pfr.id ];
            
            
           
            Core_MDF_ApprovalURL apprURL = new Core_MDF_ApprovalURL();
            apprURL.recID = pfr.Id;
            apprURL.actrID =usr.Id;
            apprURL.urlStr = 'Test';
            Core_MDF_ApprovalURL.generateApprovalURL(pfr.Id, usr.Id);
            
            //Core_MDF_ApprovalURL.generateApprovalURL(pfr.Id, usr.Id);
            
        }
        Test.stopTest();
    }     
    @isTest static void approvalURLPCT(){
        Account accRetail = [SELECT id FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1 ];
        Campaign camp = [SELECT Id,Name FROM Campaign WHERE Name = 'TestRetailCamp' LIMIT 1];
        User usr = [select id,email from User where email='rmfaccntmngr@example.com'];
        Test.startTest();
        System.runAs(usr) {
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accRetail.id),System.today().addDays(17),System.today().addDays(18),false); 
            
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_Price_reviewer_check_ind__c = false;
            
            Database.insert(pfr);
            
            System.assert(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review');
                        /*Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(pfr.id);
            Approval.ProcessResult result = Approval.process(app);
            */
            List<ProcessInstanceWorkitem> workItemLst = [ SELECT id, ActorId 
                                                         FROM ProcessInstanceWorkitem 
                                                         WHERE processInstance.TargetObjectId=:pfr.id ];
           
            
           
            Core_MDF_ApprovalURL apprURL = new Core_MDF_ApprovalURL();
            apprURL.recID = pfr.Id;
            apprURL.actrID =usr.Id;
            apprURL.urlStr = 'Test';
            Core_MDF_ApprovalURL.generateApprovalURL(pfr.Id, usr.Id);
            
            //Core_MDF_ApprovalURL.generateApprovalURL(pfr.Id, usr.Id);
            
        }
        Test.stopTest();
    } 
}