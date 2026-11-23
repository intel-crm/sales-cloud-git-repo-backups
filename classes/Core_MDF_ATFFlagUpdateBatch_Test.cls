@isTest
public class Core_MDF_ATFFlagUpdateBatch_Test {
  @TestSetup
    static void createTestData(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<User> usrList=new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser123';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'TestUser1234';
        usr1.profileId = systemAdminProfile.Id;
        usrList.add(usr1);
        Database.insert(usrList);
        System.runAs(usr){
            List<String> bypassFunctionKeys = new List<String>();
            //adding bypass feature to bypass access validation
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
           bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
              
            permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
            
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', True);
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', True);
            List<Account> accList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';            
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            accList.add(acc1);
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'APJ';            
            acc1Retail.Core_Sub_Geo__c = 'IJKK';
            accList.add(acc1Retail);
            insert accList;
            test.startTest();
            List<Account> accCoMarketingList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCoMarketingList.add(acc);
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accRetail.Core_Sub_Geo__c = 'IJKK';
            accCoMarketingList.add(accRetail);
            insert accCoMarketingList;
            String retailBudgetRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            PartnerMarketingBudget retailbudget = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget',retailBudgetRT,accRetail.Id,cpRetail.Id,2000000,System.today(),System.today(), false);
            retailBudget.Core_MDF_Budget_Type__c = 'Retail MDF';
            retailBudget.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            System.runAs(usr){
                insert retailBudget;
            }
            PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',retailbudget,accRetail,200000.0,True);
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today()-90, 
                                                                         System.today().addYears(1), 20000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            camp1.Core_MDF_Activity_Category_Type__c = null;
            camp1.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
            insert camp1;
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-250 , 
                                                                           System.today()+90, 2000, 'Unite', acc.Id,'2-in-1', false);
            MDFcamp.Core_MDF_Activity_Category_Type__c = null;
            insert MDFcamp;
        system.runAs(usr1)
        {
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psbudLoader.Id);
        }
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
        opalbudget.Core_MDF_Budget_Type__c='MDF';
        opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
        system.runAs(usr1){
             insert opalbudget;
        }
        PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, acc, 199999, false);
        insert pfaRecordOpal;
        test.stopTest();
        List<PartnerFundRequest> pfrList=new List<PartnerFundRequest>();
         PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecordOpal,opalbudget,'INDIA','Small Business','Desktop',
                                                                                          'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        MDFpfr.Title = 'Test Activity';
        MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr.Core_MDF_Start_Date__c = system.today()-90;
        MDFpfr.Core_MDF_End_Date__c =  system.today()-30;
        MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr.Core_MDF_Activity_Closure_Type__c='Manual';
        MDFpfr.Core_MDF_PriorValueOfStatus__c='Pending Review';
        MDFpfr.RequestedAmount = 1001;
        pfrList.add(MDFpfr);
        PartnerFundRequest RetailPfr2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()-1,false); 
        RetailPfr2.Title ='Retail RSA MD Activity';
        RetailPfr2.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        RetailPfr2.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfr2.RequestedAmount =100000;
        RetailPfr2.Amount=100000;
        RetailPfr2.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        RetailPfr2.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr2.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        RetailPfr2.AllocationId=retailAlloc.id;
       
        pfrList.add(RetailPfr2);
        
        PartnerFundRequest RetailPfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()-1,false); 
        RetailPfr1.Title ='Retail RSA MD Activity';
        RetailPfr1.Core_MDF_Activity_Description__c ='Retail RSA MD Activity2';
        RetailPfr1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfr1.RequestedAmount =100000;
        RetailPfr1.Amount=100000;
        RetailPfr1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        RetailPfr1.Core_MDF_ATF_Flag_nm__c='ATF Date';
        RetailPfr1.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        RetailPfr1.AllocationId=retailAlloc.id;
       
        pfrList.add(RetailPfr1);
        PartnerFundRequest RetailPfr3 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()-1,false); 
        RetailPfr3.Title ='Retail RSA MD Activity';
        RetailPfr3.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        RetailPfr3.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfr3.RequestedAmount =1000;
        RetailPfr3.Amount=1000;
        RetailPfr3.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr3.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        RetailPfr3.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr3.Core_MDF_Reimbursement_Rate_pct__c='100%';
        //RetailPfr3.Core_MDF_ATF_Flag_nm__c='ATF Date';
        RetailPfr3.AllocationId=retailAlloc.id;
        
        pfrList.add(RetailPfr3);
        
        PartnerFundRequest RetailPfr4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()-1,false); 
        RetailPfr4.Title ='Retail RSA MD Activity';
        RetailPfr4.Core_MDF_Activity_Description__c ='Retail RSA MD Activity4';
        RetailPfr4.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfr4.RequestedAmount =1000;
        RetailPfr4.Amount=1000;
        RetailPfr4.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr4.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        RetailPfr4.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr4.Core_MDF_Reimbursement_Rate_pct__c='100%';
        RetailPfr4.Core_MDF_ATF_Flag_nm__c='ATF Date';
        RetailPfr4.AllocationId=retailAlloc.id;
        
        pfrList.add(RetailPfr4);
        insert pfrList;
        }
  }
    
    @istest
    static void test(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser123';
        usr.profileId = systemAdminProfile.Id;
        System.runAs(usr){
            test.startTest();
            List<PartnerFundRequest> pfrList = [SELECT Id,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,Core_MDF_ATF_Flag_nm__c,Core_MDF_Fund_Request_Status__c,CreatedDate FROM PartnerFundRequest];
            Core_MDF_ATFFlagUpdateBatch obj =new Core_MDF_ATFFlagUpdateBatch();
            Id batchId = Database.executeBatch(obj);
            Assert.isNotNull(pfrList);
            test.stopTest();
        }
    }
}