/****************************************************************************************************************************************
* Class Name  : Core_MDF_ReverseAuditDecisionTest 
* Version     : 1.0 
* Created Date: 06-08-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Bikram Bebarta         06/08/2020               Test class for Core_MDF_ReverseAuditDecision
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_ReverseAuditDecisionTest{
    @TestSetup static void setUpData(){
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Geo__c = 'APJ';
        acc1.Core_Sub_Geo__c = 'SA';
        Database.insert(acc1);
        
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
        Database.insert(acc);
        
        // Creating campaigns using utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                    'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                    System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', true);
        // Creating Budget using utility class
        PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                               acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                               true);
        
        // Creating Allocation using utility class
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
        
        Test.startTest();
        
        // Creating activities using utility class
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(acc.id),pfa,pmb,'INDIA','Gaming',
                                                                                       'Desktop','Intel® Corporate Logo','Broadcast',
                                                                                       'Podcast','Draft',false);
        pfr.RequestedAmount = 900000;
        pfr.Amount = 900000;
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
        pfr.Core_MDF_End_Date__c = System.today();
        System.debug('getQueries----- ' + Limits.getQueries());
        Database.insert(pfr);
        
        //Creating Bank
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
        bank.Core_MDF_Bank_Status__c = 'Active';            
        insert bank;
        
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,false);
        abm1.Core_MDF_Active_ind__c = true;
        insert abm1;
        
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        Case cs = new Case();
        cs.Core_MDF_Status__c = 'Compliant';
        cs.recordTypeId = caseAuditRecType;
        cs.AccountId = acc.Id;
        insert cs;
        
        PartnerFundClaim pfc1  = new PartnerFundClaim();
        pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        pfc1.Title = 'Test Claim 1';
        pfc1.RequestId = pfr.Id;
        pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 200;        
        pfc1.Core_MDF_Audit_Hold__c = false;                 
        pfc1.Core_MDF_Status__c = 'Pending Available Fund';
        pfc1.Description = 'Test PFC ';            
        pfc1.Core_MDF_Ad_Run_Start_Date__c = System.today();
        pfc1.Core_MDF_Ad_Run_End_Date__c = System.today();
        pfc1.Core_MDF_Invoice_Date__c = System.today();
        pfc1.Core_MDF_Invoice_Number__c = '1121';
        pfc1.Core_MDF_Media_Vehicle__c = 'test1';
        pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfc1.Core_MDF_Taxes_Local__c = 0;
        pfc1.Core_MDF_Currency__c = 'USD';
        pfc1.Core_MDF_Exchange_rate__c = 1;
        pfc1.Core_MDF_Bank__c = bank.Id;
        pfc1.Core_MDF_Country_Location_nm__c = 'INDIA';
        pfc1.Core_MDF_Claim_Review_Case__c = cs.id;
        insert pfc1;
         
        Test.stopTest();
    }
    @isTest static void unitTest(){
        case cs = [select id from case limit 1];
        system.assert(cs.id != null);
		//Core_MDF_ReverseAuditDecision.checkReverseAuditCondition(cs.id);
        Core_MDF_ReverseAuditDecision.processAuditReverse(cs.id);
        
		//Core_MDF_ReverseAuditDecision.checkReverseAuditCondition(cs.id);
        Core_MDF_ReverseAuditDecision.processAuditReverse(cs.id);
    }
}