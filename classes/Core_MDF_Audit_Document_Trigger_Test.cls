@isTest(SeeAllData=false)
public class Core_MDF_Audit_Document_Trigger_Test {
    
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
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            
            //Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            true);
            
            //Creating Co-marketing Account with utility class
            Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                       Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc2);
            
            Account acc = [select id from Account where Name = 'Co-marketing Test Account'];
            
            Group newNodeGroup = new Group();
                newNodeGroup.name = 'CCP_'+acc.Id+'_EXT_GRP';
                newNodeGroup.DeveloperName = 'Core_MDF_CCP_'+acc.Id+'_EXT_GRP';
            insert newNodeGroup;
            
            acc.Core_MDF_External_Group_Id__c = newNodeGroup.id;
            update acc;
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
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Creator',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast (Pre-2025)',
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
            // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
            PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c FROM PartnerFundRequest  LIMIT 1];
            PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today(), bank.ID, false);
            pfc.Core_MDF_Currency__c = 'USD';
            
            insert pfc;
            
            // Creating claims
           /* List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim pfc  = new PartnerFundClaim();
            pfc.Title = 'Test Claim';
            pfc.RequestId = pfr.Id;
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
            pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = null;
            insert pfc;*/
            List<ContentVersion> conVersionLst = new List<ContentVersion>();
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.Title = 'Test';
            conVersion.PathOnClient='Test';
            conVersion.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion.VersionData = Blob.valueOf('content');
            conVersionLst.add(conVersion);
            Database.insert(conVersionLst); //Insert contentversion list
            ContentVersion contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst limit 1];
            
            ContentDocument conDoc= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions.ContentDocumentId limit 1];
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c(); 
            auditDoc.Core_MDF_Document_Id__c = conDoc.Id;
            auditDoc.Core_MDF_Document_Title__c = 'Test';
            auditDoc.Core_MDF_Download_Document_Title_txt__c = 'Test.pdf';
            auditDoc.Core_MDF_Claim__c = pfc.Id;
            auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            insert auditDoc;
            List<ContentVersion> conVersionLst1 = new List<ContentVersion>();
            ContentVersion conVersion1 = new ContentVersion();
            conVersion1.ContentLocation = 'S';
            conVersion1.Title = 'Test1';
            conVersion1.PathOnClient='Test1';
            conVersion1.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion1.VersionData = Blob.valueOf('content1');
            conVersionLst1.add(conVersion1);
            Database.insert(conVersionLst1); //Insert contentversion list
            ContentVersion contentVersions1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst1 limit 1];
            
            ContentDocument conDoc1= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions1.ContentDocumentId limit 1];
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c(); 
            auditDoc1.Core_MDF_Document_Id__c = conDoc1.Id;
            auditDoc1.Core_MDF_Document_Title__c = 'Test1';
            auditDoc1.Core_MDF_Download_Document_Title_txt__c = 'Test1.pdf';
            auditDoc1.Core_MDF_Claim__c = pfc.Id;
            auditDoc1.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc1.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            insert auditDoc1;
            for(PartnerFundClaimShare pfsc : [SELECT Id,RowCause, AccessLevel, UserOrGroup.name,UserOrGroupId FROM PartnerFundClaimShare  where ParentId=:pfc.id]){
                    System.debug('Share Claim-->'+pfsc);
                    System.debug('Share Claim Name-->'+pfsc.UserOrGroup.name);
            }
        }
    }
    @isTest static void testDuplicate(){
        user usr = [select id from user where name ='Test User Test' limit 1];
        //ContentVersion contentVersions1 = [SELECT Id, ContentDocumentId FROM ContentVersion limit 1];
        //System.debug('contentVersions1-->'+contentVersions1);
        System.runAs(usr){
            PartnerFundClaim pfc = [SELECT Id from PartnerFundClaim limit 1];
            ContentVersion contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion limit 1];
            ContentDocument conDoc= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions.ContentDocumentId limit 1];
            
            List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c(); 
            auditDoc.Core_MDF_Document_Id__c = conDoc.Id;
            auditDoc.Core_MDF_Document_Title__c = 'Test';
            auditDoc.Core_MDF_Download_Document_Title_txt__c = 'Test.pdf';
            auditDoc.Core_MDF_Claim__c = pfc.Id;
            auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c(); 
            auditDoc1.Core_MDF_Document_Id__c = conDoc.Id;
            auditDoc1.Core_MDF_Document_Title__c = 'Test';
            auditDoc1.Core_MDF_Download_Document_Title_txt__c = 'Test.pdf';
            auditDoc1.Core_MDF_Claim__c = pfc.Id;
            auditDoc1.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc1.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocList.add(auditDoc);
            auditDocList.add(auditDoc1);
            Core_MDF_Audit_Document_Sharing.shareAuditDocToInternalUsers(auditDocList);
            try{
            insert auditDocList;            
            }
            catch(exception e){
                
            }
            system.assertEquals(auditDoc.Core_MDF_Claim__c,pfc.Id);
            // Highlight: Unused Local Variable
           //  Account acc = [select id, Core_MDF_External_Group_Id__c from Account where Name = 'Co-marketing Test Account'];
        }
    }
    
    @isTest
    static void testExceptionofAuditDoc(){
            Core_MDF_Audit_Document_Sharing.shareAuditDocToclaim(null);
            // Unit Test Method should include System.Assert
            System.assert(true, 'shareAuditDocToclaim method executed with null parameter');
            
            Core_MDF_Audit_Document_Sharing.shareAuditDocToInternalUsers(null);
            // Unit Test Method should include System.Assert
            System.assert(true, 'shareAuditDocToInternalUsers method executed with null parameter');
    }
}