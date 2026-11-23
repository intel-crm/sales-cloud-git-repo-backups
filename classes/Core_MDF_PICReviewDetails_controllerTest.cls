/****************************************************************************************************************************************
* Class Name  : Core_MDF_PICReviewDetails_controllerTest 
* Version     : 1.0 
* Created Date: 07-07-2022 
* Main Class : Core_MDF_PicReviewDetailTreeGrid
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sandesh Hase     12-07-2022                   Created Core_MDF_PicReviewDetailTreeGrid_Test to test the PIC Review Detail Tree.
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_PICReviewDetails_controllerTest {
/****************************************************************************************************** 
Method Name:        setUpData       
Description:        Test data setup
Added By:           Accenture - Sandesh H - 18/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/    
	@TestSetup 
    static void setUpData(){
         List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('checkAndSendClaimsForPIC');
        bypassFunctionKeys.add('duplicateClaimCheck');
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
         
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        List<Account> accList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        insert acc1;
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
		acc2.Core_MDF_Parent_Fund_Account__c = acc1.id;
        accList.add(acc2);
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, false);
        acc3.Core_MDF_Parent_Fund_Account__c = acc1.id;
        accList.add(acc3);
    
        Database.insert(accList);
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        Database.insert(usr);
        
        System.runAs(usr){
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 200000, System.today(),System.today(), false);
        //pbm.IsIgnoreValidation = true;
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pbm;
        
        //pbm.IsIgnoreValidation = true;
       // update pbm;
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
            
            PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 20000, 'Always Connected PC', acc2.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            database.insert(camp);
            
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,String.valueof(acc2.Id),pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Podcast','Draft',false);
            testPartnerFundRequestRecord.Title = 'indiaActivity';
            testPartnerFundRequestRecord.Core_MDF_Activity_Description__c = 'indiaActivity';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today();
            testPartnerFundRequestRecord.RequestedAmount = 10000;
            testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = True;
            testPartnerFundRequestRecord.Amount=10000;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_pct__c = '50%';
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            insert testPartnerFundRequestRecord;
            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
			insert bank;
            List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();            
            
            List <PartnerFundClaim> claimList = new List <PartnerFundClaim>();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Status = Label.Core_MDF_Status_Submitted;
        	claim1.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimList.add(claim1);
            Test.startTest();
            database.insert(claimList);

            Test.stopTest();
            
        }
    }

/****************************************************************************************************** 
Method Name:        testgetPICResults       
Added By:           Accenture - Sandesh H - 18/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/      
    
    @isTest 
    static void testgetPICResults(){
        
        Core_MDF_PICReviewQuestion__c question1 = Core_MDF_CCP_TestDataUtility.createPICReviewQuestion('Does POC document show cost?','POC document does not show cost',10);
        Core_MDF_PICReviewQuestion__c question2 = Core_MDF_CCP_TestDataUtility.createPICReviewQuestion('Does POE document show execution?','POE document does not show execution',20);
    	
        PartnerFundClaim claim1 = [Select id from PartnerFundClaim where Title =: 'Test Claim1'];
        
        
        
        //PIC Review
        List<Core_MDF_PIC_Review__c> reviewList = new List<Core_MDF_PIC_Review__c>();
        Core_MDF_PIC_Review__c review1 = new Core_MDF_PIC_Review__c();
        review1.Core_MDF_Claim_ID_id__c = claim1.Id;
        review1.Core_MDF_CycleNumber_nbr__c = 1;
        review1.Core_MDF_Review_Status_nm__c = 'Failed';
        review1.Core_MDF_StartTime_dtm__c = system.now();
        review1.Core_MDF_EndTime_dtm__c = system.now().addMinutes(2);
        reviewList.add(review1);
        
        Core_MDF_PIC_Review__c review2 = new Core_MDF_PIC_Review__c();
        review2.Core_MDF_Claim_ID_id__c = claim1.Id;
        review2.Core_MDF_CycleNumber_nbr__c = 1;
        review2.Core_MDF_Review_Status_nm__c = 'Completed';
        review2.Core_MDF_StartTime_dtm__c = system.now();
        review2.Core_MDF_EndTime_dtm__c = system.now().addMinutes(2);
        reviewList.add(review2);
        
        database.insert(reviewList);
        
        List <Core_MDF_PICReviewResult__c> picResultList = new List <Core_MDF_PICReviewResult__c>();
        
        Core_MDF_PICReviewResult__c reviewResult1 = new Core_MDF_PICReviewResult__c();
        reviewResult1.Core_MDF_Question_id__c = question1.id;
        reviewResult1.Core_MDF_Response_txt__c = 'No';
        reviewResult1.Core_MDF_PIC_Review_id__c = review1.Id;
        picResultList.add(reviewResult1);
        
        Core_MDF_PICReviewResult__c reviewResult2 = new Core_MDF_PICReviewResult__c();
        reviewResult2.Core_MDF_Question_id__c = question2.id;
        reviewResult2.Core_MDF_Response_txt__c = 'No';
        reviewResult2.Core_MDF_PIC_Review_id__c = review1.Id;
        picResultList.add(reviewResult2);
        
         Core_MDF_PICReviewResult__c reviewResult3 = new Core_MDF_PICReviewResult__c();
        reviewResult3.Core_MDF_Question_id__c = question1.id;
        reviewResult3.Core_MDF_Response_txt__c = 'Yes';
        reviewResult3.Core_MDF_PIC_Review_id__c = review2.Id;
        picResultList.add(reviewResult3);
        
        database.insert(picResultList);
        
        String languagekey1 = 'fr';
        String languagekey2 = 'az';
         
        User usr = [SELECT Id,Email from User where LastName = 'SysAdmUser' limit 1];
        System.runAs(usr){
            Test.startTest(); 
            	String localizedField1 = Core_MDF_PICReviewDetails_controller.getPICReviewLocalizedFieldAPIName(languagekey1);
                Core_MDF_PICReviewDetails_controller.getUserAndPICReviewResultDetails(claim1.Id);	
                Core_MDF_PICReviewDetails_controller.getObjectAccess();
            	Core_MDF_PICReviewDetails_controller.getUserDetails();
                Core_MDF_PICReviewDetails_controller.getPICReviewDetails(claim1.Id, true);
                Core_MDF_PICReviewDetails_controller.getPICReviewDetails(claim1.Id, false);
            Test.stopTest();
        }
        
    }
}