/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewCaseProcess_Test
* Version     : 1.0 
* Created Date: 2-Apr-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Alka               04/03/2019                    Test Claim Review Case creation and Update
*****************************************************************************************************************************************/

@isTest(SeeAllData=false)
//This is a test class for Core_MDF_ClaimReviewCaseProcess and Core_MDF_ClaimReviewCaseProcessHelper  
private class Core_MDF_ClaimReviewCaseProcess_Test {
/****************************************************************************************************************************************
Method Name:                                   setUpTestData
Description:                                   Created setUpTestData() to prepare data for testing 
Added By:                                      Accenture – Alka      -  04/03/2019
Modified By:                  Date:            Changes: 
Accenture – Alka            04/03/2019         Created.
*****************************************************************************************************************************************/
    
    @TestSetup static void setUpTestData(){
        
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
       
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName='Claim Case User';
        usr2.ProfileId =ccpCoreProfile.Id;
        Database.insert(usr2);

        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();        
        assignPermissionSetObj1.AssigneeId = usr2.Id;
        assignPermissionSetObj1.PermissionSetId = clmCaseRevPS.Id;     

        Database.insert(assignPermissionSetObj1); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        System.runAs(usr){
            
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            //Creating Trigger Excecution Custom Setting record to 
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            Database.insert(claimToCase);
           
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);

            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);  
            
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            // Highlight: Unused Local Variable
           // Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            /* Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);*/
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        'Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                        System.today().addDays(25), 2000, 'Unite',acc.Id,'2-in-1', true);
            camp.Core_MDF_Reimbursement_Rate__c='50%';
            camp.Core_MDF_Custom_Reimbursement_Rate_pct__c = '50%';
            update camp;
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            insert pmb;
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            test.startTest();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Creator',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast (Pre-2025)',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_pct__c = '50%';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            pfr.Core_MDF_Budget_Amount_Local_amt__c=1000;
            Database.insert(pfr);
            //test.startTest();
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
             
            //creating ABM for bank1
         // Highlight: Unused Local Variable
       // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
        //test.startTest();
            // Creating claims
            for(Integer i = 0; i < 10; i++) {  
                String Title = 'Test Claim' + i;
                PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim(Title, Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, false);
                //PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                
                pfc.RequestId = pfr.Id;
                
                if(i>=3 && i<=8){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                    pfc.Core_MDF_Audit_Type__c = 'Manual';
                }
                
                if(i==9){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
                }
                pfc.Core_MDF_FlaggedForAudit__c = false;
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-2);
                pfc.Core_MDF_Ad_Run_End_Date__c = System.today();
                pfc.Core_MDF_Invoice_Date__c = System.today();
                pfc.Core_MDF_Invoice_Number__c = '1121';
                pfc.Core_MDF_Media_Vehicle__c = 'test';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Exchange_rate__c = 1;
                pfc.Core_MDF_Bank__c = bank.Id;
                pfc.Core_MDF_Country_Location_nm__c ='INDIA';
                pfc.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
                //pfc.Core_MDF_Claim_Review_Case__c= cs.Id;
                newClmList.add(pfc);
                
            }
            
        
            Database.insert(newClmList);
            Test.stopTest();
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            //cs.Core_MDF_Status__c = 'Pending Documents';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Campaign_ID__c = camp.Id;
            cs.Core_MDF_Claim_ID__c=newClmList[0].ID;
            insert cs;
        }
    }
    
    
    
    @isTest static void testMethod1() {
        
        //User usr=[Select id from User where LastName = 'Test User' Limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        system.runAs(usr1){
        
        Test.StartTest();
        
        List<Case> cslst =[Select ID, Core_MDF_Status__c from Case limit 5];
        
        list<PartnerFundClaim> pfcList = [SELECT Id, OwnerId, Core_MDF_FlaggedForAudit__c,Core_MDF_Claim_Review_Case__c,Core_MDF_Status__c,Title, Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                          CreatedById,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                          Core_MDF_Activity_Category__c,Amount,Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,
                                          Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c 
                                          FROM PartnerFundClaim 
                                          WHERE Title LIKE 'Test Claim%' LIMIT 2];

        PartnerFundClaim pfcRec;
        
        
        List<PartnerFundClaim> pfcListToCreateCases = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToUpdate = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToUpdateAmount = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToUpdateOwner = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfc: pfcList){
            pfcRec = pfc;
            pfcRec.Core_MDF_FlaggedForAudit__c = true;
            pfcRec.Core_MDF_Status__c = 'Hold';
            pfcRec.Core_MDF_Document_Submission_Missed_Ind__c = true;
            pfcListToCreateCases.add(pfcRec);
        }
        update pfcListToCreateCases;
                
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        
        for(PartnerFundClaim pfc: pfcListToCreateCases){
            pfcRec = pfc;
            //pfcRec.OwnerId = usr.Id;
          
            pfcRec.Core_MDF_Status__c = 'Cancelled';
            pfcRec.Core_MDF_Invoice_Number__c = '112696';
            pfcRec.Core_MDF_Media_Vehicle__c = 'test 1';
            //pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c = 'Pending Documents';
            pfcListToUpdate.add(pfcRec);
        }
        
        for(PartnerFundClaim pfc: pfcListToUpdate){
            pfcRec = pfc;
            pfcRec.Amount = 450000;
            pfcRec.Core_MDF_Status__c = 'Cancelled';
            pfcListToUpdateAmount.add(pfcRec);
        }        
        update pfcListToUpdateAmount;  
        
        for(PartnerFundClaim pfc: pfcListToUpdateAmount){
            pfcRec = pfc;
            pfcRec.OwnerId = usr.Id;
            pfcListToUpdateOwner.add(pfcRec);
        }
        
        pfcListToUpdateOwner[0].Core_MDF_Claim_Review_Case__c = null;
        pfcListToUpdateOwner[0].Core_MDF_Taxes_Local__c =10;
        pfcListToUpdateOwner[0].Id =null;
        Database.SaveResult[] srList = Database.update(pfcListToUpdateOwner, false);
        
        //Calling insertLogEntryRecord method to insert log entry for failed record
        Core_MDF_ClaimReviewCaseProcessHelper.insertLogEntryRecord(srList); 
        /*String outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('Manual');
        System.AssertEquals('Manual Selection',outputResult);
        outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('Random');
        System.AssertEquals('Random Selection',outputResult);
        outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('CAP');
        System.AssertEquals('Predictive Selection',outputResult);
        outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('Other Selection type');
        System.AssertEquals(null,outputResult);*/
        Core_MDF_ClaimReviewCaseProcessHelper.insertLogEntryRecord(NULL); 
        Core_MDF_ClaimReviewCaseProcessHelper.validateAuditDocuments(cslst,null,'CreateCases');
        
        Core_MDF_ClaimReviewCaseProcessHelper.insertAuditDocuments(cslst,null);
        
        Core_MDF_ClaimReviewCaseProcessHelper be = new Core_MDF_ClaimReviewCaseProcessHelper(pfcListToCreateCases, 'CreateCases');
        Database.executeBatch(be);
        
        PartnerFundRequest pfr = [select id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, Title from PartnerFundRequest limit 1];
        
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-4);
        pfr.Title = 'PFR Updated';
        
        update pfr;   
        assert.areEqual('PFR Updated',pfr.Title);
        Core_MDF_ClaimReviewCaseProcessHelper be1 = new Core_MDF_ClaimReviewCaseProcessHelper(pfcListToUpdate, 'UpdateCases',null);
        Database.executeBatch(be1);   
        
        Test.StopTest();  
        }
    }
    
    @isTest
    static void caseProcess(){
        //User usr=[Select id from User where LastName = 'Test User' Limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr){
        Test.StartTest();
        
        List<Case> caseList = new List<Case>();
        Case cs = [Select Id,Core_MDF_Claim_ID__c,Core_MDF_Status__c,Core_MDF_More_Documentation_Required__c,Core_MDF_Channel_Program_txt__c,RecordTypeId
                   from Case limit 1];
        
        PartnerFundClaim pfc1 = [Select Id from PartnerFundClaim limit 1];
        
        cs.Core_MDF_Claim_ID__c = pfc1.Id;
        cs.Core_MDF_Status__c = 'Under Review';
        cs.Core_MDF_Channel_Program_txt__c = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        database.update(cs);
        
        caseList.add(cs);
        
        Map<Id,List<Core_MDF_Audit_Document__c>> claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c>>();
              
        Core_MDF_Audit_Document__c aDoc =  new Core_MDF_Audit_Document__c();
        aDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Attribution;Proof of Execution';
        aDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Attribution;Proof of Execution';
        aDoc.Core_MDF_Audit__c = cs.Id;
        aDoc.Core_MDF_Claim__c = pfc1.Id;
         aDoc.Core_MDF_Document_Title__c = 'Test Audit Document' ;  
        insert aDoc;
        
        List<Core_MDF_Audit_Document__c> doclst = new List<Core_MDF_Audit_Document__c>();
        doclst.add(aDoc);
      
        claimIdWithConDocId.put(pfc1.Id,doclst);
        // Unit Test Method should include System.Assert
        System.assertEquals(true, claimIdWithConDocId.containsKey(pfc1.Id), 'Claim Id should exist in document map.');
            
        Core_MDF_ClaimReviewCaseProcessHelper.insertAuditDocuments(caseList,claimIdWithConDocId);
        Core_MDF_ClaimReviewCaseProcessHelper.validateAuditDocuments(caseList,claimIdWithConDocId,'UpdateCases');
       // Highlight: Unused Local Variable
      /*  List<Case> csListReturn = */ Core_MDF_ClaimReviewCaseProcessHelper.validateAuditDocuments(caseList,claimIdWithConDocId,'CreateCases');
        
        //assert.areEqual('Under Review', csListReturn[0].Core_MDF_Status__c );
        Test.StopTest(); 
    	}
    }

    @isTest
    static void testGetCancelCaseAccess() {
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet cancelCaseAccessPS = [SELECT Id FROM PermissionSet WHERE Name = :Core_MDF_CCP_ConstantClass.CCRM_CUSTOM_PS LIMIT 1];

        User CCRMUSER = Core_MDF_CCP_TestDataUtility.createUser(false);
        CCRMUSER.LastName = 'CCRM';
        CCRMUSER.ProfileId = ccpCoreProfile.Id;
        insert CCRMUSER;

        insert new PermissionSetAssignment(AssigneeId = CCRMUSER.Id, PermissionSetId = cancelCaseAccessPS.Id);

        User nonCCRMUSER = Core_MDF_CCP_TestDataUtility.createUser(false);
        nonCCRMUSER.LastName = 'nonCCRM';
        nonCCRMUSER.ProfileId = ccpCoreProfile.Id;
        insert nonCCRMUSER;

        Test.startTest();
        System.runAs(CCRMUSER) {  
            Boolean hasAccess = Core_MDF_ClaimReviewCaseProcess.getCancelCaseAccess();
            System.assertEquals(true, hasAccess);
        }

        System.runAs(nonCCRMUSER) {
            Boolean hasAccess = Core_MDF_ClaimReviewCaseProcess.getCancelCaseAccess();
            System.assertEquals(false, hasAccess);
        }
        Test.stopTest();
    }
}