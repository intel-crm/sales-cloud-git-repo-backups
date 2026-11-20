@isTest
public class Core_MDF_FileAuthorization_Test {
     @TestSetUp private static void createTestData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Profile usrProfile = [select id , Name from Profile where name = 'CCP - Core Access' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
         usr.Email = 'ccp_internal_claim_case_reviewer@intel.com';
         usr.profileId = usrProfile.id;
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
                                                                        System.today().addDays(15), 2000, 'Unite',acc.Id,'2-in-1', true);
            
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
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Consumer',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Digital',
                                                                                           'Web Content','Draft',false);
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
            // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
            
            
            
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
            pfc.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
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
            pfc1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            pfcList.add(pfc1);

            
            insert(pfcList);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test2';
        usr2.UserRoleId = usRole.Id;
         usr2.Email = 'ccp_internal_claim_case_reviewer@intel.com';
         //usr2.profileId = usrProfile.id;
        //Database.insert(usr2);
        
        
        //Assigning Claim Case Reviewer Permission Set to user
        // Highlight: Unused Local Variable 
      //  PermissionSet pSet2 = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Generic_Access'];
        //insert new PermissionSetAssignment(AssigneeId=usr2.Id, PermissionSetId = pSet2.id);
            
            //insert pfc;  
            //cs.OwnerId = usr.id;       
            //p//fc.OwnerId = usr.id;
         	//database.update(pfc);  
            
            Test.stopTest();
        }
         
         
         
    }
    
    public static testMethod void getPhoneUser3() {
        Core_MDF_FileAuthorization.AuthResp results;
         Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Profile usrProfile = [select id , Name from Profile where name = 'System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        usr.ProfileId = usrProfile.id;
        usr.Email = 'ccp_internal_genericUser@intel.com';
        Database.insert(usr);
       
        //user u = [Select id from user where LastName = 'User Test' limit 1];
        //List<PermissionSetAssignment> p = [SELECT Id FROM PermissionSetAssignment where AssigneeId=: u.Id];
        //delete p;
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        //Assigning Claim Case Reviewer Permission Set to user
        //PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        //insert new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetId = pSet.id);
        // Highlight: Unused Local Variable 
       // String docId = '';
        String csId = '';
        System.runAs(usr){
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Status__c = 'Pending Documents';
            cs.Origin = 'Manual Selection';
            cs.Core_MDF_Claim_ID__c = 'ClaimID';
            cs.Core_MDF_More_Documentation_Required__c = TRUE;
            insert cs; 
            //Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];            
            //Creating activities using utility class
            //PartnerFundRequest pfr = [select id from PartnerFundRequest limit 1];
            
            //Creating Bank
            //Core_MDF_Bank__c bank = [select id from Core_MDF_Bank__c limit 1];
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c != null limit 1];
            pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Documents;
            pfc.Core_MDF_Eligible_for_PIC__c = true;

            //update pfc;
           // Highlight: Unused Local Variable
          //  List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            csId = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            
            //Core_MDF_Audit_Document__Share Share_Record = new Core_MDF_Audit_Document__Share();
            //Share_Record.ParentId = auditDocs.id;
            //Share_Record.UserOrGroupId = usr.id;
            //Share_Record.AccessLevel = 'Read';
            
            // Highlight: Unused Local Variable  
          /*  List<Core_MDF_Audit_Document__Share> sgare_rec = [select id,AccessLevel,UserOrGroupId  from Core_MDF_Audit_Document__Share where Parent.id =: auditDocs.id and UserOrGroupId =: usr.id];
          
            
            List<UserRecordAccess> recAccess = [Select u.RecordId, u.HasReadAccess From UserRecordAccess u
                                                      where UserId =: usr.id and RecordId =:auditDocs.id];  */
            // Highlight: Unused Local Variable 
            
            //insert Share_Record;
            
        
        //String docId=cs.Id.toString();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/mdf/sft/fileAuthorization'; 
        req.params.put('appFileId', csId);
        req.params.put('action', 'download');
        //req.params.put('userName', '');
        req.params.put('userName', 'ccp_internal_genericUser@intel.com');
        
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application'); 
        RestContext.request = req;
        RestContext.response = res;
        //User usr1 = UserClaimApi.getClaimUser();
        //System.debug(usr1);
        results = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results.isAuthorized,false);

   		Test.stopTest(); 
        }
        //NullPointerException nullPointer = new NullPointerException();
      	//throw nullPointer;
    }
    public static testMethod void getPhoneUser4() {
        Core_MDF_FileAuthorization.AuthResp results;
         Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Profile usrProfile = [select id , Name from Profile where name = 'System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        usr.ProfileId = usrProfile.id;
        usr.Email = 'ccp_internal_genericUser@intel.com';
        usr.FederationIdentifier ='12000000';
        Database.insert(usr);
       
        //user u = [Select id from user where LastName = 'User Test' limit 1];
        //List<PermissionSetAssignment> p = [SELECT Id FROM PermissionSetAssignment where AssigneeId=: u.Id];
        //delete p;
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        //Assigning Claim Case Reviewer Permission Set to user
        //PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        //insert new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetId = pSet.id);
        // Highlight: Unused Local Variable 
       // String docId = '';
        String csId = '';
        System.runAs(usr){
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Status__c = 'Pending Documents';
            cs.Origin = 'Manual Selection';
            cs.Core_MDF_Claim_ID__c = 'ClaimID';
            cs.Core_MDF_More_Documentation_Required__c = TRUE;
            insert cs; 
            //Case cs = [select id, Core_MDF_Status__c,Core_MDF_Claim_Submitter_Message_txt__c from Case limit 1];            
            //Creating activities using utility class
            //PartnerFundRequest pfr = [select id from PartnerFundRequest limit 1];
            
            //Creating Bank
            //Core_MDF_Bank__c bank = [select id from Core_MDF_Bank__c limit 1];
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c != null limit 1];
            pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Documents;
            pfc.Core_MDF_Eligible_for_PIC__c = true;

            //update pfc;
            // Highlight: Unused Local Variable
           // List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            csId = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            
            //Core_MDF_Audit_Document__Share Share_Record = new Core_MDF_Audit_Document__Share();
            //Share_Record.ParentId = auditDocs.id;
            //Share_Record.UserOrGroupId = usr.id;
            //Share_Record.AccessLevel = 'Read';
            
            // Highlight: Unused Local Variable 
         /*   List<Core_MDF_Audit_Document__Share> sgare_rec = [select id,AccessLevel,UserOrGroupId  from Core_MDF_Audit_Document__Share where Parent.id =: auditDocs.id and UserOrGroupId =: usr.id];
            
            
            List<UserRecordAccess> recAccess = [Select u.RecordId, u.HasReadAccess From UserRecordAccess u
                                                      where UserId =: usr.id and RecordId =:auditDocs.id];  */
            // Highlight: Unused Local Variable 
            
            //insert Share_Record;
            /*User usr1 = [Select id,FederationIdentifier from User where email ='ccp_internal_genericUser@intel.com' LIMIT 1];
            Boolean hasUserAccess = Core_MDF_FileAuthorization.CheckUserRecordAccess(auditDocs.Id, usr1.FederationIdentifier);
            Assert.areEqual(hasUserAccess,true);*/
            
        
        //String docId=cs.Id.toString();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/mdf/sft/fileAuthorization'; 
        //req.params.put('appFileId', csId);
        //req.params.put('action', 'download');
        //req.params.put('userName', 'ccp_internal_genericUser@intel.com');
        
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application'); 
        RestContext.request = null;
        RestContext.response = res;
        //User usr1 = UserClaimApi.getClaimUser();
        //System.debug(usr1);
        //AuthResp AuResp = new AuthResp();
        
        results = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results.isAuthorized,false);
        test.stopTest();
        }
        //NullPointerException nullPointer = new NullPointerException();
      	//throw nullPointer;
    }
    
    public static testMethod void testFileAuthorizationContentCheck() {
        Core_MDF_FileAuthorization.AuthResp results;
         Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Profile usrProfile = [select id , Name from Profile where name = 'System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        usr.ProfileId = usrProfile.id;
        usr.Email = 'ccp_internal_genericUser@intel.com';
        Database.insert(usr);
       
        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];
        insert new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId = pSet.id);
        
        String docId = '';
        String csId = '';
        System.runAs(usr){
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Status__c = 'Pending Documents';
            cs.Origin = 'Manual Selection';
            cs.Core_MDF_Claim_ID__c = 'ClaimID';
            cs.Core_MDF_More_Documentation_Required__c = TRUE;
            insert cs; 
            
            PartnerFundClaim pfc  = [select id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_RMF_Last_POP_Submission_Dt__c from PartnerFundClaim where Core_MDF_Claim_Review_Case__c != null limit 1];
            pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Pending_Documents;
            pfc.Core_MDF_Eligible_for_PIC__c = true;

            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDocs = new Core_MDF_Audit_Document__c();
            auditDocs.Core_MDF_Document_Id__c = cs.Id;
            csId = cs.Id;
            auditDocs.Core_MDF_Document_Title__c = 'Test Docs';
            auditDocs.Core_MDF_Claim__c = pfc.Id;
            auditDocs.Core_MDF_Audit__c = cs.Id;
            auditDocs.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocs.CreatedDate = system.today();
            listDoc.add(auditDocs);
            insert listDoc;
            
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/mdf/sft/fileAuthorization'; 
        req.params.put('appFileId', pfc.Id);
        req.params.put('action', 'checkContentAccess');
        req.params.put('userName', 'ccp_internal_genericUser@intel.com');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application'); 
        RestContext.request = req;
        RestContext.response = res;
        results = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results.isAuthorized,false);
   		Test.stopTest(); 
		
        //CDB-SFT use case
        Core_MDF_FileAuthorization.AuthResp results1;
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        String appDataForClaim = 'claimId-'+pfc.Id;
        String appDataForCase = 'caseId-'+cs.Id;
        req1.requestURI = '/mdf/sft/fileAuthorization'; 
        req1.httpMethod = 'GET';
        req1.params.put('appFileId', '765875');
        req1.params.put('action', 'download');
        req1.params.put('userName', 'AMR_sys_comkt_cdb_sft');
        req1.params.put('appData', appDataForClaim);
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        results1 = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results1.isAuthorized,false);
        req1.params.put('appData', appDataForCase);
        results1 = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results1.isAuthorized,false);
        }
    }
   
    public static testMethod void getException2() {
        Core_MDF_FileAuthorization.AuthResp results;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/mdf/sft/fileAuthorization'; 
        req.params.put('appFileId', '');
        req.params.put('action', 'download');
        req.params.put('userName', '');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;
        //User usr1 = UserClaimApi.getClaimUser();
        //System.debug(usr1);
        test.startTest();
        results = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results.isAuthorized,false);
        test.stopTest();
        
    }
    
    public static testMethod void testSysUserBypass() {
        Core_MDF_FileAuthorization.AuthResp results;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/mdf/sft/fileAuthorization'; 
        req.httpMethod = 'GET';
        req.params.put('appFileId', '765875');
        req.params.put('action', 'download');
        req.params.put('userName', 'sys_comkt_sftuser');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        test.startTest();
        results = Core_MDF_FileAuthorization.CheckFileAuthorization();
        Assert.areEqual(results.isAuthorized,true);
        test.stopTest();
        
    }
}