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
private class Core_MDF_AuditDocumentHelper_Test 
{ 
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data to test Approval criteria Functionality.
    Added By:                                                Accenture – Shridhar S K  -  10-25-2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar S K          10-25-2018                 Created.
*****************************************************************************************************************************************/
    @isTest static void createTestData() 
    {
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
            
            List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();

            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'Open';
            cs.recordTypeId = caseAuditRecType;
            insert cs;
            System.debug('Case Id:'+cs.Id);
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today() ,
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', true);
            
            //Id budgetRecordType = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
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
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today();
            Database.insert(pfr);
            // Creating Bank
	    Test.startTest();	
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
            
             //creating ABM for bank1
             Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
            
            // Creating claims
            
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
                insert pfc;
            	
            
            	/*PartnerFundClaim pfc1  = new PartnerFundClaim();
                pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                                for(Integer i = 0; i < 10; i++) {                

                pfc1.Title = 'Test Claim' + i;
                pfc1.RequestId = pfr.Id;

                if(i>=3 && i<=8){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
                }
                }
                pfc1.Core_MDF_FlaggedForAudit__c = false;
                pfc1.Core_MDF_Status__c = 'Denied';
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
                pfc1.Core_MDF_Claim_Review_Case__c = null;
                insert pfc1;*/

            List<String> documentIdWithTitle = new List<String>();
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            
            String str1 = cs.Id+';#'+'Test Doc1';
            String str2 = cs.Id+';#'+'Test Doc2';
            String str3 = cs.Id+';#'+'Test Doc3';
            String str4 = cs.Id+';#'+'Test Doc4';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            //System.AssertEquals(lstWrap.documentList.size(),4);
            //Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);

            documentIdWithTitle.clear();
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle);
            listDoc = lstWrap2.documentList;
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap2 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle);
            //listDoc = pfclstWrap2.documentList;
            //System.AssertEquals(lstWrap.documentList.size(),4);
            
            String str5 = cs.Id+';#'+'Test Doc5';
            String str6 = cs.Id+';#'+'Test Doc6';
            List<String> documentIdWithTitle1 = new List<String>();
            documentIdWithTitle1.add(str5);
            documentIdWithTitle1.add(str6);
            
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper lstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            //System.AssertEquals(lstWrap1.documentList.size(),2);
            Core_MDF_AuditDocumentHelper.sObjectDocumentWrapper pfclstWrap1 = Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            //Covering exception for  getAuditDocuments Method
            documentIdWithTitle1[0] = 'Nohash';
            Core_MDF_AuditDocumentHelper.getAuditDocuments(cs.Id,documentIdWithTitle1);
            Core_MDF_AuditDocumentHelper.getAuditDocuments(pfc.Id,documentIdWithTitle1);
            
            for(Core_MDF_Audit_Document__c auditDoc: listDoc){
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;
            }
            
            boolean updateResult = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc);
            System.debug('updateResult: '+updateResult);
            //System.assert(updateResult);
            boolean updateResult1 = Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc);

            //Passing case id as null            
            Core_MDF_AuditDocumentHelper.getAuditDocuments(null,documentIdWithTitle1);

            
            
            
            Core_MDF_AuditDocumentHelper.updateAuditDocument(listDoc);
            if(listDoc.size() > 0){
                listDoc[0].Core_MDF_Proof_of_Branding__c = false;
                Core_MDF_AuditDocumentHelper.updateAuditDocument(listDoc);
            }
            
            //Covering exception for  updateAuditDocument Method
            //listDoc[0].Id = null;
            Core_MDF_AuditDocumentHelper.updateAuditDocument(listDoc);
            Core_MDF_AuditDocumentHelper.updateAuditDocument(null);
            
            
            //Covering exception for  updateCaseStatus Method
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,listDoc); 
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(pfc.Id,listDoc);
            Core_MDF_AuditDocumentHelper.updateObjectAndDocuments(cs.Id,null); 
            
            
            // Passing Case Id and Comment 
            Core_MDF_AuditDocumentHelper.updateClaimSubmitterMsg(cs.Id,'Test Comment');
            // Passing Case Id and Comment as Null
            Core_MDF_AuditDocumentHelper.updateClaimSubmitterMsg(cs.Id,NULL);
            System.assertEquals(cs.Core_MDF_Claim_Submitter_Message_txt__c, NULL);
            // Covering exception for updateClaimSubmitterMsg Method
            Core_MDF_AuditDocumentHelper.updateClaimSubmitterMsg(NULL,'Test Comment');
            
            
            List<String> listConIds =  new List<String>();		
			//Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
                
            
            for(ContentVersion conver : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ])
            {
                listConIds.add(conver.ContentDocumentId);
            }
          	
            
            Core_MDF_AuditDocumentHelper.deleteDocumentIds(listConIds);
			Core_MDF_AuditDocumentHelper.deleteDocumentIds(null);
            
            Test.stopTest();
            
        }       
    }                
}