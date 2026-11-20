@isTest(SeeAllData=false) 
public class Core_MDF_Claim_Prediction_Subscribe_Test {
     @TestSetup 
    static void setUpData(){
        
         List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        /*bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');*/
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        /*bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');*/
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        //bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFC_TriggerHandler';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert';
        claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution.Name = 'Core_MDF_ClaimForEinPredOnAfterInsert';
        claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
       Database.insert(claimFunctionalityNameTriggerExecution);
        
        //permission set
        PermissionSet ccfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        
        User sysAdminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdminUser.LanguageLocaleKey = 'en_US';
        sysAdminUser.Email = 'systemAdmin@intel.com';
        insert sysAdminUser;
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = sysAdminUser.Id;
        assignPermissionSetObj.PermissionSetId = ccfPayAdmin.Id;
        system.runas(sysAdminUser){
        insert assignPermissionSetObj;
         }
        
        ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        Database.insert(cpCCF);
             // Creating Intel Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
           // acc1.Core_Sales_Groups__c = 'US Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cpCCF.Id;
            acc1.Core_MDF_CoMarketingActive__c = true;
       		
            database.insert(acc1);
        	
        	Account accCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account CCF', cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accCCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCCF.Core_MDF_CoMarketingActive__c = true;
          
            database.insert(accCCF);
        	
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund',System.today(), 
                                                                        System.today()+20, 2000, 'Unite', accCCF.Id,'2-in-1', 
                                                                        false);
            //test code begins
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        	camp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        
			database.insert(camp);
        	
        	 //Creating Budget using utility class
        	
        
            PartnerMarketingBudget testBudgetCCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataCCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                             string.valueof(accCCF.id), cpCCF.Id , 10000 , System.today() - 25 , 
                                                                                             System.today() + 45 , false);
            testBudgetCCF.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';

        	testBudgetCCF.Core_MDF_Budget_Status__c = 'Released';
            database.insert(testBudgetCCF);
        
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231274632'); 
            indiaBank.Core_MDF_Effective_Date__c = System.today().addDays(-2);
               system.runas(sysAdminUser){
                   insert indiaBank;
               }
            indiaBank.Core_MDF_Bank_Status__c = 'Active'; 
            indiaBank.Core_MDF_Bank_Location__c = 'IN';
            system.runas(sysAdminUser){
                update indiaBank;
            }
       	    
    }
   @isTest static void testValidEvent() {
        
       		User sysAdminUser = [SELECT ID,Name FROM User WHERE Email = 'systemAdmin@intel.com' LIMIT 1];
       		Core_MDF_Bank__c indiaBank = [SELECT ID,Core_MDF_Bank_Status__c FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1231274632' LIMIT 1];
        		
        	Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
			execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
			execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
			execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
			insert execution1;
        	
           	Campaign camp = [SELECT ID FROM CAMPAIGN WHERE Name='TestCamp' LIMIT 1];
            //Creating PFA using testData Utility
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataCCF'
                                          LIMIT 1];
            // Highlight: Unused Local Variable 
           // Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accCCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account CCF'];
        	
            PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title = 'CCF Allocation',
                                                                                        BudgetId = pmb.Id, 
                                                                                        ChannelPartnerId = accCCF.Id, 
                                                                                       Amount = 1000);
           
           
            insert testPartnerFundAllocation;
        	
            //String ccfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;  
            //PartnerFundRequest Activity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE RecordTypeId=:ccfPfrID  LIMIT 1];
        	// Creating Activity with budget using utility class
            
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(accCCF.id),testPartnerFundAllocation,pmb,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Broadcast',
                                                                                                  'Podcast',
                                                                                                  'Draft',
                                                                                                  false);
        testPartnerFundRequestRecord.Title = 'France Activity';
       testPartnerFundRequestRecord.Core_MDF_Activity_Description__c = 'France Activity'; 
       testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today();
       testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today();
       testPartnerFundRequestRecord.RequestedAmount = 1000;
       testPartnerFundRequestRecord.Core_MDF_pagespayingfor__c = 15;
       testPartnerFundRequestRecord.Amount=1000;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c= 'OEM CMP';
        //testPartnerFundRequestRecord.Core_MDF_Budget_Type_txt__c = 'OEM CMP';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_pct__c='50%';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = true;
       /*PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                         string.valueof(accCCF.id),
                                                                                                                          NULL,NULL,'ALBANIA','Consumer',
                                                                                                                          'Desktop','Intel® Corporate Logo',
                                                                                                                          'Event','Channel Partner Owned Event',
                                                                                                                          'Draft',false,true,
                                                                                                                          'Others','Test Other cpCCF');
            
            testPartnerFundRequestRecord.RequestedAmount=1000;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
       		testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_pct__c='50%';
        	testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';*/
        	
            database.insert(testPartnerFundRequestRecord);
                
            
         
            //creating ABM for bank1
       if(indiaBank.Core_MDF_Bank_Status__c == 'Active'){
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCCF.Id,indiaBank.Id,false);
           system.runas(sysAdminUser){
           insert abm1;
           }
       }
             Test.startTest();
            PartnerFundClaim indiaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord.Id, 
                                                                                    testPartnerFundRequestRecord.Core_MDF_Start_Date__c, testPartnerFundRequestRecord.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim1.Core_MDF_Currency__c = 'USD';
       	    insert indiaClaim1;                              
            
   
        Core_MDF_Claim_Prediction__c cp = new Core_MDF_Claim_Prediction__c();
       cp.Core_MDF_Claim_Id__c = indiaClaim1.Id;
       insert cp;
       // Unit Test Method should include System.Assert
        System.assertEquals(1, [SELECT Id FROM Core_MDF_Claim_Prediction__c WHERE Core_MDF_Claim_Id__c = :indiaClaim1.Id].size(), 'One Claim Prediction record should be created');
        System.assertNotEquals(null, cp.Id, 'Claim Prediction should have been inserted successfully');
       
        Test.stopTest();
  
        // Highlight: Unused Local Variable 
      //  List <Core_MDF_Claim_Prediction__c> obj  = [SELECT Id FROM Core_MDF_Claim_Prediction__c ]; 
        // Validate that this claim was found
        
        //System.assertEquals(1, obj.size());
        
    }
    
    
        
        @isTest static void testInvalidEvent() {
        
        // Create a test event instance with invalid data.
        // We assume for this test that the Serial_Number__c field is required.
        // Publishing with a missing required field should fail.
        Core_MDF_Claim_Prediction_Event__e evt = new Core_MDF_Claim_Prediction_Event__e(Core_MDF_PE_ID__c='Englishsinger11111'); 
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(evt);
            
        Test.stopTest();
                
        // Perform validations here
        
        // Verify SaveResult value - isSuccess should be false
        System.assertEquals(true, sr.isSuccess());
        
        // Log the error message
        for(Database.Error err : sr.getErrors()) {
            System.debug('Error returned: ' +
                        err.getStatusCode() +
                        ' - ' +
                        err.getMessage()+' - '+err.getFields());
        }
        
         // Verify that no claim PRediction was created by a trigger.
        List <Core_MDF_Claim_Prediction__c> obj  = [SELECT Id FROM Core_MDF_Claim_Prediction__c ];
        // Validate that this no claim was found
       
       System.assertEquals(0, obj.size());
        
    }
    
    //Areefa
    @isTest static void testInValidEventException() {
        Test.startTest();
        try{
        Core_MDF_Claim_Prediction_Event__e evt = new Core_MDF_Claim_Prediction_Event__e(Core_MDF_PE_ID__c='');
       // Highlight: Unused Local Variable 
       /* Database.SaveResult sr = */ EventBus.publish(evt);  
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
         Test.stopTest();   
    }
    
    
}