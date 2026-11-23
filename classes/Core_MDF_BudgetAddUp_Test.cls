@isTest
private class Core_MDF_BudgetAddUp_Test {
    @testSetup static void setup()
        {
            Test.startTest();
            List<Account> accList = new List<Account>();
            //Setting up profile and permission set for User
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            //Creating Client Co-Marketing Fund program using Data Utility                
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            //Creating Test Acc New 1-  Intel Account using Data Utility  
            Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            // Creating Co-marketing Account with utility class        
            Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            accCoMarketing.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
            accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = accIntel.Id;
            Database.insert(accCoMarketing);
            accCoMarketing.IsPartner = true;
            accList.add(accCoMarketing);
            Database.update(accList);
            List<User> lstUser = new List<user>();
                
            //System Admin        
            User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
            systemadm.Email = 'systemadm@example.com';
            lstUser.add(systemAdm);
            //CCF Account Manager  
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            lstUser.add(ccfaccntmngr);
            Database.insert(lstUser);
            //Assign permission Sets
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            System.runAs(systemAdm){
                Database.insert(assignPermissionSetObj);
            }
            Test.stopTest();
            // Create IUPGM Data
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = accIntel.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA;APJ;PRC';
            iupgm.Core_MDF_Region_cd__c = 'EMEA;APJ;PRC';
            iupgm.Core_MDF_User_id__c = ccfaccntmngr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgm.Core_MDF_All_Accounts_cd__c ='No';
            iupgmList.add(iupgm);
            insert iupgmList;
            system.assert(iupgmList[0].Core_MDF_Account_id__c == accIntel.Id);
            //Create Budget
            PartnerMarketingBudget bdgt = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type, accCoMarketing.Id, cp.Id,1000000000, System.today()-150, System.today()+150, true);
            //Create Campaign
            List<Campaign> campList = new List<Campaign>();
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);         
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 2','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-10, System.today()+10, 100000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);         
           	campList.add(camp1); 
            campList.add(camp2);
            insert campList;
        }   
           
    
    @isTest static void budgetAddUp(){
        User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
        Test.startTest();
            System.runAs(usr){
                
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 1' LIMIT 1];
            PartnerMarketingBudget bdgt =  [select id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2' LIMIT 1];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            insert pfr;
                        
            PartnerFundRequest  result = new PartnerFundRequest(); 
            result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(pfr.Id);
            System.assert(result  != null);
            Core_MDF_BudgetAddUp.fetchBudgetCampaignPFRDetails(pfr.Id);
            }
        
        
        Test.stopTest(); 
    }
     @isTest static void budgetAddUpMultiplePFR(){
        User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
        Test.startTest();
            System.runAs(usr){
                
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 1' LIMIT 1];
            PartnerMarketingBudget bdgt =  [select id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2' LIMIT 1];
           	List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr1.Title = 'Test Activity 1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Activity 1';
            pfr1.Core_MDF_Channel_Partner_Led__c = True;
            pfr1.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr1.Core_MDF_Budget_Currency_cd__c='USD';
            
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr2.Title = 'Test Activity 2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity 2';
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfr2.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr2.Core_MDF_Budget_Currency_cd__c='INR';
            
            pfrList.add(pfr1);
            pfrList.add(pfr2);
            
            insert pfrList;
                
            Core_MDF_BudgetAddUp.fetchBudgetCampaignPFRDetails(pfr1.Id);
            }
        
        
        Test.stopTest(); 
    }
     @isTest static void budgetAddUpThroughCampaign(){
        User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
        Test.startTest();
            System.runAs(usr){
                
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 1' LIMIT 1];
            PartnerMarketingBudget bdgt =  [select id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2' LIMIT 1];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            insert pfr;
                
            Core_MDF_BudgetAddUp.fetchBudgetCampaignPFRDetails(camp.Id);
            }
        
        
        Test.stopTest(); 
    }
    @isTest static void budgetAddUpMultipleCamp(){
        User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
        Test.startTest();
            System.runAs(usr){
                
            Campaign camp1 = [select id,Name from Campaign WHERE Name = 'Test Camp 1' LIMIT 1];
            Campaign camp2 = [select id,Name from Campaign WHERE Name = 'Test Camp 2' LIMIT 1];
            
            PartnerMarketingBudget bdgt =  [select id from PartnerMarketingBudget WHERE Title = 'Test Budget' LIMIT 1];
                
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2' LIMIT 1];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp1.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            insert pfr;
                        
            PartnerFundRequest  result = new PartnerFundRequest(); 
            result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(pfr.Id);
            System.assert(result  != null);
            Core_MDF_BudgetAddUp.fetchBudgetCampaignPFRDetails(pfr.Id);
            }
        
        
        Test.stopTest(); 
    }
}