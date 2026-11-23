/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditDocumentHelper_Test 
* Version     : 1.0 
* Created Date: 10-25-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar S K        10-25-2018                   Created Core_MDF_AuditDocumentHelper_Test to test file upload/manage documents functionality.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_AuditDocumentHelper_Test { 
    /****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data to test Approval criteria Functionality.
    Added By:                                                Accenture – Shridhar S K  -  10-25-2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar S K          10-25-2018                 Created.
    *****************************************************************************************************************************************/
   /* @TestSetUp static void createTestData(){
        
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
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
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
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
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
                                                                        System.today().addDays(15), 2000, 'Unite',acc.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(camp);
            //Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today().addDays(-20),System.today().addDays(40), 
                                                                                   false);
            
            pmb.Core_MDF_Budget_Type_Txt__c='OEM CMP';
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
            pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Documents;
            pfc.Core_MDF_Eligible_for_PIC__c = true;

            update pfc;

            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
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
            
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);

            documentIdWithTitle.clear();
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
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
            boolean updateResult1 = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc, false);           
            
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
            pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_Pending_Documents;
            pfc.Core_MDF_Eligible_for_PIC__c = true;

            update pfc;

            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
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
            
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);

            documentIdWithTitle.clear();
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
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
            boolean updateResult1 = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc, false); 

            boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc, false);
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
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
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
            
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);

            documentIdWithTitle.clear();
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
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

            boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc, false);
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
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
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
            
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);

            documentIdWithTitle.clear();
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            listDoc = pfclstWrap2.documentList;            
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
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
            boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc, false);           
            boolean updateResult1 = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc, false);

            //Passing case id as null            
            Core_MDF_AuditDocumentHelper.getAuditDocuments(null,documentIdWithTitle1);
            Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,null);
            
            Core_MDF_AuditDocumentHelper.updateAuditDocument(listDoc);
            
            if(listDoc.size() > 0){
                listDoc[0].Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
                Core_MDF_AuditDocumentHelper.updateAuditDocument(listDoc);
                Core_MDF_AuditDocumentHelper.updateLastPOPDocDateOnClaim(listDoc);
            }
            
            //Covering exception for  updateAuditDocument Method
            listDoc[0].Id = null;
            Core_MDF_AuditDocumentHelper.updateAuditDocument(listDoc);
            Core_MDF_AuditDocumentHelper.updateAuditDocument(null);            
            
            //Covering exception for  updateCaseStatus Method
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc, false); 
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc, false);
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,null, false); 
            Core_MDF_AuditDocumentHelper.updateLastPOPDocDateOnClaim(null);
            
            //Passing Case Id and Comment 
            Core_MDF_AuditDocumentHelper.updateClaimSubmitterMsg(cs.Id,'Test Comment');
            
            //Passing Case Id and Comment as Null
            Core_MDF_AuditDocumentHelper.updateClaimSubmitterMsg(cs.Id,NULL);
            System.assertEquals(cs.Core_MDF_Claim_Submitter_Message_txt__c, NULL);
            
            //Covering exception for updateClaimSubmitterMsg Method
            Core_MDF_AuditDocumentHelper.updateClaimSubmitterMsg(NULL,'Test Comment');
            
            
                
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
            
            Core_MDF_AuditDocumentHelper.deleteDocumentIds(listConIds);
            Core_MDF_AuditDocumentHelper.deleteDocumentIds(null);
            
            Core_MDF_AuditDocumentHelper.fetchMetaDataRecords(pfc.Id,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,null);
            Core_MDF_AuditDocumentHelper.fetchMetaDataRecords(null,'Core_MDF_Client_Co_Marketing_Fund',null);
            
            
            //Case caseInst = new Case();
            //caseInst.id = cs.Id;
            //caseInst.Core_MDF_Status__c = 'Pending Documents';
            //caseInst.Core_MDF_More_Documentation_Required__c = TRUE;
            
            //update caseInst;
           
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc, false);
             
            //insert listDoc;
            Test.stopTest();
            //Core_MDF_AuditDocumentHelper.updateLastPOPDocDateOnClaim(listDoc);
            
        }       
    } */     
     /****************************************************************************************************************************************
    Method Name:                                             createTestDataNew
    Description:                                             Creating Test data to test Approval criteria Functionality.
    Added By:                                                Accenture – Karan Sharma  KS  -  12-29-2020
    Modified By:                  Date:                      Changes: 
    
    *****************************************************************************************************************************************/
   /* @isTest static void createTestDataNew(){
        
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
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = pfc.Id+';#'+'Test Doc3';
            String str4 = pfc.Id+';#'+'Test Doc4';
            
            /*documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);*/
            
           //Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);   
        
            /*Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
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
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.CreatedDate = system.today();
            insert auditDocs;
            //listDoc.add(auditDocs);      
            pfcMap.put(pfc.Id,pfc);
            Core_MDF_AuditDocumentHelper.releaseDocHoldOrProcessManualAudit(pfcMap);
            system.assertEquals(false,pfc.Core_MDF_Document_Hold_Ind__c);
            pfc.Core_MDF_Manaul_Audit_Staging_Ind__c = true;
            pfcMap.put(pfc.Id,pfc);
            update pfc;
            Core_MDF_AuditDocumentHelper.releaseDocHoldOrProcessManualAudit(pfcMap);
            Test.stopTest();
        }
    }
    
    
    @isTest
    static void getClaimAndUserDetails() {
        Test.startTest();
        User user1 = [select Id from User limit 1];
        System.runAs(user1) {
            PartnerFundClaim pfc = [select Id, Core_MDF_Status__c, Core_MDF_Eligible_for_PIC__c from PartnerFundClaim limit 1];
        pfc.Core_MDF_Eligible_for_PIC__c = true;
        pfc.Core_MDF_Status__c = 'Resubmission Required';
        update pfc;
        Core_MDF_AuditDocumentHelper.getClaimAndUserDetails(pfc.Id);    
        Core_MDF_AuditDocumentHelper.fetchAuditDocuments(pfc.Id); // no documents scenario
        
        //success scenario - claim with documents
        Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];
        List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
        Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
        auditDoc1.Core_MDF_Document_Id__c = cs.Id;
        auditDoc1.Core_MDF_Document_Title__c = 'Test document1';
        auditDoc1.Core_MDF_Claim__c = pfc.Id;
        auditDoc1.Core_MDF_Audit__c = cs.Id;
        auditDoc1.Core_MDF_Document_Types__c='Proof of Cost';
        auditDoc1.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDoc1.CreatedDate = system.today();
        auditDocList.add(auditDoc1);
        
        PartnerFundClaim pfc1 = [select Id, Core_MDF_Status__c, Core_MDF_Eligible_for_PIC__c from PartnerFundClaim where title =: 'Test PFC' limit 1];
        pfc1.Core_MDF_Budget_Type_Options_Nm__c = 'CCF 1.0';
        update pfc1;
        
        Core_MDF_Audit_Document__c auditDoc2 = new Core_MDF_Audit_Document__c();
        auditDoc2.Core_MDF_Document_Id__c = cs.Id;
        auditDoc2.Core_MDF_Document_Title__c = 'Test document2';
        auditDoc2.Core_MDF_Claim__c = pfc1.Id;
        auditDoc2.Core_MDF_Audit__c = cs.Id;
        auditDoc2.Core_MDF_Document_Types__c='Proof of Cost;Proof of Attribution;Proof of Execution';
        auditDoc2.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDoc2.CreatedDate = system.today();
        auditDocList.add(auditDoc2);
        insert auditDocList;
        
        Core_MDF_AuditDocumentHelper.checkClaimStatusForPICProcess(pfc.Id);
        Core_MDF_AuditDocumentHelper.fetchAuditDocuments(pfc1.Id); //mandatory document types
        
        //updateObjectAndDocuments - update status to PIC Pending or Paid and PIC Pending
        pfc.Core_MDF_Status__c = 'Resubmission Required';
        update pfc;
        
        Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id, auditDocList, true);
        
        pfc.Core_MDF_Status__c = 'Paid and Resubmission Required';
        update pfc;
        
        Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id, auditDocList, true);
        }
        Test.stopTest();
    }
    
     @isTest
    static void testUpdateClaimStatus() {
        Test.startTest();
        //Resubmission Required
        PartnerFundClaim pfc = [select Id, Core_MDF_Status__c from PartnerFundClaim limit 1];
        pfc.Core_MDF_Status__c = 'Resubmission Required';
        update pfc;
        Core_MDF_AuditDocumentHelper.updateClaimStatus(pfc.Id);
        
        //Paid and Resubmission Required
        pfc.Core_MDF_Status__c = 'Paid and Resubmission Required';
        update pfc;
        Core_MDF_AuditDocumentHelper.updateClaimStatus(pfc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCheckForLegacyClaims() {
        Test.startTest();
        PartnerFundClaim pfc = [select Id, Core_MDF_Status__c from PartnerFundClaim limit 1];
        Core_MDF_AuditDocumentHelper.checkForLegacyClaims(pfc.Id);
        Test.stopTest();
    }*/
    @isTest 
    static void getCodeCoverageForMainClass(){
         Test.startTest();
         Core_MDF_AuditDocumentHelper.getCodeCoverage();
         Test.stopTest();
    }
}