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
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
                
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        System.runAs(usr){          
            //Creating Trigger Excecution Custom Setting record to 
            Core_Trigger_Executions__c claimToCase = new Core_Trigger_Executions__c();
            claimToCase.Core_Active__c = true;
            claimToCase.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimToCase.Core_Description__c = 'This Custom Setting is used to turn on/off claim to case functionality.';
            claimToCase.Core_Object__c = 'PartnerFundClaim';
            claimToCase.Core_Trigger_Events__c = 'after update';
            claimToCase.Name='Core_MDF_ClaimToCase';        
            Database.insert(claimToCase);
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            //cs.Core_MDF_Status__c = 'Pending Documents';
            cs.recordTypeId = caseAuditRecType;
            insert cs;
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
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
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            /* Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);*/
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', true);
            test.startTest();
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                   true);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
            pfr.Core_MDF_End_Date__c = System.today();
            Database.insert(pfr);
            //test.startTest();
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
             
            //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
        //test.startTest();
            // Creating claims
            for(Integer i = 0; i < 10; i++) {                
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = pfr.Id;
                
                if(i>=3 && i<=8){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
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
                //pfc.Core_MDF_Claim_Review_Case__c= cs.Id;
                newClmList.add(pfc);
            }
            
        //User partnerUser = [SELECT Id, LastName FROM User WHERE LastName='User Test1'];
        //Creating claims as partner user
        //System.runAs(partnerUser){
        
            Database.insert(newClmList);
        //}
        Test.stopTest();
        System.debug('newClmList'+newClmList);
        }
    }
    
    
    @isTest static void testMethod1() {
        //
        Test.StartTest();
        Case cs = [Select Id from Case limit 1];
        //List<Case> cslst =[Select ID, Core_MDF_Status__c from Case where Core_MDF_Status__c = 'Pending Documents' limit 1];
        List<Case> cslst =[Select ID, Core_MDF_Status__c from Case limit 5];
        system.debug('cslst@@@'+cslst);
        /*cslst[0].Core_MDF_Status__c = 'Under Review';
        update cslst;*/
        PartnerFundClaim pfc1 = [Select Id from PartnerFundClaim limit 1];
        list<PartnerFundClaim> pfcList = [SELECT Id, OwnerId, Core_MDF_FlaggedForAudit__c,Core_MDF_Claim_Review_Case__c,Core_MDF_Status__c,Title, Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                            CreatedById,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                            Core_MDF_Activity_Category__c,Amount,Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,
                                            Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 2];

        PartnerFundClaim pfcRec;
        
        
        List<PartnerFundClaim> pfcListToCreateCases = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToUpdate = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToUpdateAmount = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToUpdateOwner = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfc: pfcList){
            pfcRec = pfc;
            pfcRec.Core_MDF_FlaggedForAudit__c = true;
            pfcRec.Core_MDF_Status__c = 'Hold';
            pfcListToCreateCases.add(pfcRec);
        }
        update pfcListToCreateCases;
        System.debug('pfcListToCreateCases***1'+pfcListToCreateCases);
        
        //pfcListToCreateCases.clear();
        System.debug('pfcListToCreateCases***2'+pfcListToCreateCases);
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        for(PartnerFundClaim pfc: pfcListToCreateCases){
            pfcRec = pfc;
            //pfcRec.OwnerId = usr.Id;
            System.debug('pfcRec.OwnerId***'+pfcRec.OwnerId);
            System.debug('usr.Id***'+usr.Id);
            System.debug('pfc.Core_MDF_Claim_Review_Case__c***'+pfc.Core_MDF_Claim_Review_Case__c);
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
        System.debug('pfcListToUpdateAmount***'+pfcListToUpdateAmount);
        update pfcListToUpdateAmount;  
        system.debug('pfcListToUpdateAmount@@@'+pfcListToUpdateAmount);
        for(PartnerFundClaim pfc: pfcListToUpdateAmount){
            pfcRec = pfc;
            pfcRec.OwnerId = usr.Id;
            pfcListToUpdateOwner.add(pfcRec);
        }
        System.debug('pfcListToUpdateOwner***'+pfcListToUpdateOwner);
        //update pfcListToUpdateOwner;
        pfcListToUpdateOwner[0].Core_MDF_Claim_Review_Case__c = null;
        pfcListToUpdateOwner[0].Core_MDF_Taxes_Local__c =10;
        pfcListToUpdateOwner[0].Id =null;
        Database.SaveResult[] srList = Database.update(pfcListToUpdateOwner, false);
        System.debug('srList@@@'+srList);
        //Calling insertLogEntryRecord method to insert log entry for failed record
        Core_MDF_ClaimReviewCaseProcessHelper.insertLogEntryRecord(srList); 
        String outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('Manual');
        System.AssertEquals('Manual Selection',outputResult);
        outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('Random');
        System.AssertEquals('Random Selection',outputResult);
        outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('CAP');
        System.AssertEquals('Predictive Selection',outputResult);
        outputResult = Core_MDF_ClaimReviewCaseProcessHelper.getCaseOrigin('Other Selection type');
        System.AssertEquals(null,outputResult);
        Core_MDF_ClaimReviewCaseProcessHelper.insertLogEntryRecord(NULL); 
        Core_MDF_ClaimReviewCaseProcessHelper.validateAuditDocuments(cslst,null,'CreateCases');
        Core_MDF_Audit_Document__c aDoc =  new Core_MDF_Audit_Document__c();
                aDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                aDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                //aDoc.Core_MDF_Proof_of_Cost__c = true;
                //aDoc.Core_MDF_Proof_of_Execution__c = true;
                aDoc.Core_MDF_Audit__c = cs.Id;
                aDoc.Core_MDF_Claim__c = pfc1.Id;
                insert aDoc;
        List<Core_MDF_Audit_Document__c> doclst = new List<Core_MDF_Audit_Document__c>();
        doclst.add(aDoc);
        /*List<PartnerFundClaim> pfc2 = [Select Id, Core_MDF_Status__c from PartnerFundClaim where Title like 'Test Claim%'];
        Map<Id,List<Core_MDF_Audit_Document__c>> claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c>>();
        claimIdWithConDocId.put(pfc1.Id,doclst);
        Core_MDF_ClaimReviewCaseProcessHelper.validateAuditDocuments(cslst,claimIdWithConDocId);*/
        Core_MDF_ClaimReviewCaseProcessHelper.insertAuditDocuments(cslst,null);
        //pfc2[0].Core_MDF_Status__c = 'Cancelled';
        //update pfc2;
        
        Core_MDF_ClaimReviewCaseProcessHelper be = new Core_MDF_ClaimReviewCaseProcessHelper(pfcListToCreateCases, 'CreateCases');
        Database.executeBatch(be);
        
        PartnerFundRequest pfr = [select id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, Title from PartnerFundRequest limit 1];
        
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-4);
        pfr.Title = 'PFR Updated';
        
        update pfr;
        //List<Id> claimOwnerIdLst = [Select Id from User where Id IN pfcRec.OwnerId];
        Core_MDF_ClaimReviewCaseProcessHelper be1 = new Core_MDF_ClaimReviewCaseProcessHelper(pfcListToUpdate, 'UpdateCases',null);
        Database.executeBatch(be1);   
        
     Test.StopTest();       
    }
}