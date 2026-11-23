/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClmBatchStgAuditDocHelper_Test 
* Version     : 1.0 
* Created Date: 11-11-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Vinodhini Baskar       11-11-2021                   Created Core_MDF_ClmBatchStgAuditDocHelper_Test to test file upload/manage documents functionality.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_ClmBatchStgAuditDocHelper_Test {
    @TestSetUp static void createTestData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        
        System.runAs(usr){
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Status__c = 'Pending Documents';
            cs.Origin = 'Manual Selection';
            cs.Core_MDF_Claim_ID__c = 'ClaimID';
            cs.Core_MDF_More_Documentation_Required__c = TRUE;
            insert cs;            
            //Core_MDF_CCP_TestDataUtility.createMDFConfigurationData(); 
            //Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            //Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);
            
            //Creating Co-marketing Account with utility class
            Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                       Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc2);
            
            Account acc = [select id from Account where Name = 'Co-marketing Test Account'];
            
            //Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        'Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(-15), 
                                                                        System.today().addDays(15), 2000, 'Unite',acc.Id,'2-in-1', true);
            
            //Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-20),System.today().addDays(40), 
                                                                                   false);
            
            pmb.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            insert pmb;
            //Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            //Creating activities using utility class
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
            pfr.Core_MDF_Start_Date__c = system.today().addDays(-1);
            pfr.Core_MDF_End_Date__c = system.today().addDays(1);
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            Database.insert(pfr);
            
            Test.startTest();
            
            //Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
            bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
            bank.Core_MDF_Bank_Status__c = 'Active';
            Database.insert(bank);  
            
            //creating ABM for bank
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
            
            
            
            // Creating claims
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim pfc  = new PartnerFundClaim();
            pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            for(Integer i = 0; i < 10; i++) {                
                
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
            }
            pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
            pfc.Core_MDF_FlaggedForAudit__c = false;
            pfc.Core_MDF_Status__c = 'Submitted';
            pfc.Description = 'Test PFC ';
            pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
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
            pfc.Core_MDF_Claim_Review_Case__c = cs.Id; 
            pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = null;          
            //pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = System.today().addDays(-1);
            
            pfcList.add(pfc);
            
            PartnerFundClaim pfc1  = new PartnerFundClaim();
            pfc1.Title = 'Test PFC';
            pfc1.RequestId = pfr.Id;
            pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
            pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 200;
            pfc1.Core_MDF_FlaggedForAudit__c = false;
            pfc1.Core_MDF_Status__c = 'Submitted';
            pfc1.Description = 'Test PFC ';
            pfc1.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfc1.Core_MDF_Ad_Run_End_Date__c = System.today();
            pfc1.Core_MDF_Invoice_Date__c = System.today();
            pfc1.Core_MDF_Invoice_Number__c = '1121';
            pfc1.Core_MDF_Media_Vehicle__c = 'test';
            pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            pfc1.Core_MDF_Taxes_Local__c = 0;
            pfc1.Core_MDF_Currency__c = 'USD';
            pfc1.Core_MDF_Exchange_rate__c = 1;
            pfc1.Core_MDF_Bank__c = bank.Id;
            pfc1.Core_MDF_Country_Location_nm__c ='INDIA';
            pfc1.Core_MDF_RMF_Last_POP_Submission_Dt__c = System.today().addDays(-1);
            pfcList.add(pfc1);
            
            
            insert(pfcList);
            
            
            
            //insert pfc;           
            
            Test.stopTest();
        }
    }
    @isTest static void createTestData23(){
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        System.runAs(usr){
            
            Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];            
            //Creating activities using utility class
            //PartnerFundRequest pfr = [select id from PartnerFundRequest limit 1];
            
            //Creating Bank
            //Core_MDF_Bank__c bank = [select id from Core_MDF_Bank__c limit 1];
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c != null limit 1];
            
            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='';
            auditDocs.Core_MDF_App_Document_Types_nm__c='';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = pfc.Id+';#'+'Test Doc3';
            String str4 = pfc.Id+';#'+'Test Doc4';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);
            
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            
            documentIdWithTitle.clear();
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            List<String> tempString = str1.split(';#');
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
            auditDoc1.Core_MDF_Document_Id__c = tempString[0];
            auditDoc1.Core_MDF_Document_Title__c = tempString[1];
            auditDoc1.Core_MDF_Claim__c = pfc.Id;
            auditDoc1.Core_MDF_Audit__c = cs.Id;
            auditDoc1.Core_MDF_Document_Types__c='';
            auditDoc1.Core_MDF_App_Document_Types_nm__c='';
            auditDoc1.CreatedDate = system.today();
            listDoc.add(auditDoc1);
            
            for(Core_MDF_Audit_Document__c auditDoc: listDoc){
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            }   
            //boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc);           
            boolean updateResult1 = Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(pfc.Id,listDoc);           
            
        }
    }
    
    @isTest static void createTestData234(){
        Test.startTest();           
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        System.runAs(usr){
            
            Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];            
            //Creating activities using utility class
            //PartnerFundRequest pfr = [select id from PartnerFundRequest limit 1];
            
            //Creating Bank
            //Core_MDF_Bank__c bank = [select id from Core_MDF_Bank__c limit 1];
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c = null limit 1];
            
            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='';
            auditDocs.Core_MDF_App_Document_Types_nm__c='';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = pfc.Id+';#'+'Test Doc3';
            String str4 = pfc.Id+';#'+'Test Doc4';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);
            
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            
            documentIdWithTitle.clear();
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            List<String> tempString = str1.split(';#');
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
            auditDoc1.Core_MDF_Document_Id__c = tempString[0];
            auditDoc1.Core_MDF_Document_Title__c = tempString[1];
            auditDoc1.Core_MDF_Claim__c = pfc.Id;
            auditDoc1.Core_MDF_Audit__c = cs.Id;
            auditDoc1.Core_MDF_Document_Types__c='';
            auditDoc1.Core_MDF_App_Document_Types_nm__c='';
            auditDoc1.CreatedDate = system.today();
            listDoc.add(auditDoc1);
            
            for(Core_MDF_Audit_Document__c auditDoc: listDoc){
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            }   
            //boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc);           
            boolean updateResult1 = Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(pfc.Id,listDoc); 
            
            boolean updateResult = Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(cs.Id,listDoc);
            Test.stopTest();             
        }
    }
    @isTest static void createTestData2345(){
        Test.startTest();           
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        System.runAs(usr){
            
            Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];            
            //Creating activities using utility class
            //PartnerFundRequest pfr = [select id from PartnerFundRequest limit 1];
            
            //Creating Bank
            //Core_MDF_Bank__c bank = [select id from Core_MDF_Bank__c limit 1];
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c = null limit 1];
            
            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='';
            auditDocs.Core_MDF_App_Document_Types_nm__c='';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = pfc.Id+';#'+'Test Doc3';
            String str4 = pfc.Id+';#'+'Test Doc4';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);
            
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            
            documentIdWithTitle.clear();
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            //Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            List<String> tempString = str1.split(';#');
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
            auditDoc1.Core_MDF_Document_Id__c = tempString[0];
            auditDoc1.Core_MDF_Document_Title__c = tempString[1];
            auditDoc1.Core_MDF_Claim__c = pfc.Id;
            auditDoc1.Core_MDF_Audit__c = cs.Id;
            auditDoc1.Core_MDF_Document_Types__c='';
            auditDoc1.Core_MDF_App_Document_Types_nm__c='';
            auditDoc1.CreatedDate = system.today();
            listDoc.add(auditDoc1);
            
            for(Core_MDF_Audit_Document__c auditDoc: listDoc){
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            }   
            //boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc);           
            //boolean updateResult1 = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc); 
            
            boolean updateResult = Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(cs.Id,listDoc);
            Test.stopTest();             
        }
    }
    
    @isTest static void createTestData2(){
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        System.runAs(usr){
            
            Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];            
            //Creating activities using utility class
            //PartnerFundRequest pfr = [select id from PartnerFundRequest limit 1];
            
            //Creating Bank
            //Core_MDF_Bank__c bank = [select id from Core_MDF_Bank__c limit 1];
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c != null limit 1];
            
            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='';
            auditDocs.Core_MDF_App_Document_Types_nm__c='';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = pfc.Id+';#'+'Test Doc3';
            String str4 = pfc.Id+';#'+'Test Doc4';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);
            
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            
            documentIdWithTitle.clear();
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            List<String> tempString = str1.split(';#');
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
            auditDoc1.Core_MDF_Document_Id__c = tempString[0];
            auditDoc1.Core_MDF_Document_Title__c = tempString[1];
            auditDoc1.Core_MDF_Claim__c = pfc.Id;
            auditDoc1.Core_MDF_Audit__c = cs.Id;
            auditDoc1.Core_MDF_Document_Types__c='';
            auditDoc1.Core_MDF_App_Document_Types_nm__c='';
            auditDoc1.CreatedDate = system.today();
            listDoc.add(auditDoc1);
            
            for(Core_MDF_Audit_Document__c auditDoc: listDoc){
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            }   
            boolean updateResult = Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(cs.Id,listDoc);           
            boolean updateResult1 = Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(pfc.Id,listDoc);
            
            //Passing case id as null            
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(null,documentIdWithTitle1);
            Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(cs.Id,null);
            
            Core_MDF_ClmBatchStgAuditDocHelper.updateAuditDocument(listDoc);
            
            if(listDoc.size() > 0){
                listDoc[0].Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
                Core_MDF_ClmBatchStgAuditDocHelper.updateAuditDocument(listDoc);
                Core_MDF_ClmBatchStgAuditDocHelper.updateLastPOPDocDateOnClaim(listDoc);
            }
            
            //Covering exception for  updateAuditDocument Method
            listDoc[0].Id = null;
            Core_MDF_ClmBatchStgAuditDocHelper.updateAuditDocument(listDoc);
            Core_MDF_ClmBatchStgAuditDocHelper.updateAuditDocument(null);            
            
            //Covering exception for  updateCaseStatus Method
            Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(cs.Id,listDoc); 
            Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(pfc.Id,listDoc);
            Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(cs.Id,null); 
            Core_MDF_ClmBatchStgAuditDocHelper.updateLastPOPDocDateOnClaim(null);
            
            //Passing Case Id and Comment 
            Core_MDF_ClmBatchStgAuditDocHelper.updateClaimSubmitterMsg(cs.Id,'Test Comment');
            
            //Passing Case Id and Comment as Null
            Core_MDF_ClmBatchStgAuditDocHelper.updateClaimSubmitterMsg(cs.Id,NULL);
            System.assertEquals(cs.Core_MDF_Claim_Submitter_Message_txt__c, NULL);
            
            //Covering exception for updateClaimSubmitterMsg Method
            Core_MDF_ClmBatchStgAuditDocHelper.updateClaimSubmitterMsg(NULL,'Test Comment');
            
            
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            List<String> listConIds =  new List<String>();  
            for(ContentVersion conver : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ]){
                listConIds.add(conver.ContentDocumentId);
            }
            
            Core_MDF_ClmBatchStgAuditDocHelper.deleteDocumentIds(listConIds);
            Core_MDF_ClmBatchStgAuditDocHelper.deleteDocumentIds(null);
            
            Core_MDF_ClmBatchStgAuditDocHelper.fetchMetaDataRecords(pfc.Id,'Client Co-Marketing Fund',null, null);
            Core_MDF_ClmBatchStgAuditDocHelper.fetchMetaDataRecords(null,'Core_MDF_Client_Co_Marketing_Fund',null, null);
            Core_MDF_ClmBatchStgAuditDocHelper.fetchMetaDataRecords(pfc.Id,'Client Co-Marketing Fund',null, 'Core_MDF_Claim_Batch_Stage__c');
            
            
            //Case caseInst = new Case();
            //caseInst.id = cs.Id;
            //caseInst.Core_MDF_Status__c = 'Pending Documents';
            //caseInst.Core_MDF_More_Documentation_Required__c = TRUE;
            
            //update caseInst;
            
            Core_MDF_ClmBatchStgAuditDocHelper.updateObjectAndDocuments(pfc.Id,listDoc);
            
            insert listDoc;
            Test.stopTest();
            //Core_MDF_AuditDocumentHelper.updateLastPOPDocDateOnClaim(listDoc);
            
        }       
    }      
    
    @isTest static void createTestDataNew(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        System.runAs(usr){
            Test.startTest(); 
            Case cs = [select id from Case limit 1];
            
            PartnerFundClaim pfc  = [select id from PartnerFundClaim limit 1];
            
            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            // auditDocs.Core_MDF_Claim__c = pfc.Id;
            //auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='';
            auditDocs.Core_MDF_App_Document_Types_nm__c='';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = pfc.Id+';#'+'Test Doc3';
            String str4 = pfc.Id+';#'+'Test Doc4';
            
            //Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);   
            
            Core_MDF_ClmBatchStgAuditDocHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_ClmBatchStgAuditDocHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            System.debug('Document List 1->'+documentIdWithTitle);
            documentIdWithTitle.clear();
            
            
            Test.stopTest();
        }       
    } 
    
    @isTest static void releaseHoldClaims(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        //Assigning Claim Case Reviewer Permission Set to user
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        Map<Id,PartnerFundClaim> pfcMap = new Map<Id,PartnerFundClaim>();
        System.runAs(usr){
            Test.startTest();
            PartnerFundClaim pfc  = [SELECT Id,Core_MDF_Claim_Review_Case__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c, 
                                     Core_MDF_Audit_Hold__c, Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Status__c,
                                     Core_MDF_Document_Hold_Ind__c,Core_MDF_Document_Hold_Eligibility_Ind__c,
                                     Core_MDF_Manaul_Audit_Staging_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c, 
                                     Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c, 
                                     Core_MDF_VAT_Hold_Ind__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Bank_Doc_Hold_Ind__c
                                     FROM PartnerFundClaim where Core_MDF_Claim_Review_Case__c != null];
            pfc.Core_MDF_Document_Hold_Ind__c = true;
            update pfc;      
            //List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = pfc.Core_MDF_Claim_Review_Case__c;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            //auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='';
            auditDocs.Core_MDF_App_Document_Types_nm__c='';
            auditDocs.CreatedDate = system.today();
            insert auditDocs;
            //listDoc.add(auditDocs);      
            pfcMap.put(pfc.Id,pfc);
            Core_MDF_ClmBatchStgAuditDocHelper.releaseDocHoldOrProcessManualAudit(pfcMap);
            system.assertEquals(false,pfc.Core_MDF_Document_Hold_Ind__c);
            pfc.Core_MDF_Manaul_Audit_Staging_Ind__c = true;
            pfcMap.put(pfc.Id,pfc);
            update pfc;
            Core_MDF_ClmBatchStgAuditDocHelper.releaseDocHoldOrProcessManualAudit(pfcMap);
            Core_MDF_ClmBatchStgAuditDocHelper.isClmReleasedFromDocHold(pfc);
            Test.stopTest();
        }
    }
}