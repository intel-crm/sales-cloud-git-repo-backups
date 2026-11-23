@isTest
public class Core_MDF_CloseActivity_AmtUpdBatch_test {
	@TestSetup
    static void createTestData(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        System.runAs(usr){
            permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
           insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        }
        ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', True);

         Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                              false);
        acc1Retail.Core_Account_Type__c = 'Reseller';
        acc1Retail.Industry = 'Food & Beverage';
        acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
        acc1Retail.Core_Geo__c = 'APJ';            
        acc1Retail.Core_Sub_Geo__c = 'IJKK';
        insert acc1Retail;
        Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail.Core_Geo__c = 'APJ';
        accRetail.Core_Sub_Geo__c = 'IJKK';
        insert accRetail;
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
                                                                     System.today().addYears(1), 20000, 'Instore innovation', accRetail.Id,'2-in-1', true);
        List<PartnerFundRequest> pfrList=new List<PartnerFundRequest>();
       /* PartnerFundRequest RetailPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()-10,false); 
        RetailPfr.Title ='Retail RSA MD Activity';
        RetailPfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        RetailPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        RetailPfr.RequestedAmount =1000;
        RetailPfr.Amount=1000;
        RetailPfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        RetailPfr.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        RetailPfr.Core_MDF_Activity_Closure_Type__c='No Internal Approval';
        RetailPfr.Core_MDF_ToBeClosedDate__c=system.today()-2;
        pfrList.add(RetailPfr);*/
         PartnerFundRequest RetailPfr2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()+10,false); 
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
        PartnerFundRequest RetailPfr3 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()+10,false); 
        RetailPfr3.Title ='Retail RSA MD Activity';
        RetailPfr3.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        RetailPfr3.Core_MDF_Budget_Type_nm__c ='Retail MDF';
        RetailPfr3.RequestedAmount =1000;
        RetailPfr3.Amount=1000;
        RetailPfr3.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        RetailPfr3.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        RetailPfr3.Core_MDF_Budget_Currency_cd__c ='USD';
        RetailPfr3.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        RetailPfr3.AllocationId=retailAlloc.id;
        
        pfrList.add(RetailPfr3);
        upsert pfrList;
        List<PartnerFundRequest> pfr=[SELECT Id,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,Core_MDF_ATF_Flag_nm__c,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest
						   limit 100];
        System.debug('PFrList-->'+pfr);
        
        
       
    }
    @istest
    static void test(){
        test.startTest();
        Core_MDF_ATFFlagUpdateBatch obj =new Core_MDF_ATFFlagUpdateBatch();
        Id batchId = Database.executeBatch(obj);
        test.stopTest();
    }
}