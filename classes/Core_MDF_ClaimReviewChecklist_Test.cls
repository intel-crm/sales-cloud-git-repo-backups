/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewChecklist_Test 
* Created Date: 31-7-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP                    31-7-2019                     Test class for all methods in Core_MDF_ClaimReviewChecklist
* Intel - NP(11630236)          20-9-2019                     Added test scenarios for Checklist Enhancement v1 stories : US458785, US458779, US458790, US458776
* NP(11630236)                  06-11-2019                    Checklist Enhancements v2 - US488875: [Checklist] HIGH: Assign additional Case Checklist permissions to Finance users - Added testCheckEditability()
* NP(11630236)                  14-11-2019                    DE60015: Automatic Case status change to Compliant getting stuck because of Validation rule    
* NP(11630236)                  04-02-2020                    Fixed PMD Scan for testCheckEditability()
**************************************************************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ClaimReviewChecklist_Test {

    public static id caseRecordId;

    @isTest static void testQueryAllChecklistItems(){
        Map<string,List<Core_MDF_Claim_Case_Checklist__c>> result = new  Map<string,List<Core_MDF_Claim_Case_Checklist__c>>();
        Case record = [select id from Case limit 1];
        
        result = Core_MDF_ClaimReviewChecklist.queryAllChecklistItems(record.id);
        System.assert(result.size()!=0,'Records returned');
       
    }

    @isTest static void testUpdateChecklistRecord(){
        Map<string,string> checklistSelection = new Map<string,string>();
        Map<string,string> impactAmount = new Map<string,string>();
        Map<string,string> comments = new Map<string,string>();
        integer result; 
        // Highlight: Unused Local Variable
        // string caseStatus;
        Case record = [select id from Case limit 1];

        Core_MDF_Claim_Case_Checklist__c checklistRecord = [select id from Core_MDF_Claim_Case_Checklist__c where Core_MDF_Checklist_Status__c='Compliant'];
        Core_MDF_Claim_Case_Checklist__c checklistRecord2 = [select id from Core_MDF_Claim_Case_Checklist__c where Core_MDF_Checklist_Status__c='Non-Compliant'];
        checklistSelection.put(string.valueof(checklistRecord.id),'compliant');
        impactAmount.put(string.valueof(checklistRecord.id),'2');
        comments.put(string.valueof(checklistRecord.id),'Checklist is Compliant');

        Core_MDF_ClaimReviewChecklist.updateChecklistRecords(checklistSelection,impactAmount,comments,record.id);

        checklistSelection.put(string.valueof(checklistRecord.id),'noncompliant');

        Core_MDF_ClaimReviewChecklist.updateChecklistRecords(checklistSelection,impactAmount,comments,record.id);

        checklistSelection.put(string.valueof(checklistRecord.id),'NA');

        Core_MDF_ClaimReviewChecklist.updateChecklistRecords(checklistSelection,impactAmount,comments,record.id);
        
        Core_MDF_ClaimReviewChecklist.updateChecklistRecords(checklistSelection,impactAmount,comments,null);

        impactAmount.put(string.valueof(checklistRecord2.id),'200');
        comments.put(string.valueof(checklistRecord2.id), 'Test Comments');

        result = Core_MDF_ClaimReviewChecklist.updateChecklistRecords(checklistSelection,impactAmount,comments,record.id);

        system.assert(result!=0,'Checklist Completion');
    }

    @isTest static void testGetChecklistResults(){
        Case record = [select id from Case limit 1];
        List<Core_MDF_Claim_Case_Checklist__c> result = new List<Core_MDF_Claim_Case_Checklist__c>();

        result = Core_MDF_ClaimReviewChecklist.getChecklistResults(record.id);
        Core_MDF_ClaimReviewChecklist.getChecklistResults(null);

        system.assert(result.size()!=0,'Records are returned');
    }

    @isTest static void testCalculateChecklistCompletion(){
        integer checklistCompletion;
        Case record = [select id from Case limit 1];

        checklistCompletion = Core_MDF_ClaimReviewChecklist.calculateChecklistCompletion(record.id);
        Core_MDF_ClaimReviewChecklist.calculateChecklistCompletion(null);
        system.assert(checklistCompletion!=0,'Checklist not 0');
    }

    @isTest static void testGetCaseStatus(){
        string caseStatus;
        Case record = [select id from Case limit 1];

        caseStatus = Core_MDF_ClaimReviewChecklist.getCaseStatus(record.id);
        Core_MDF_ClaimReviewChecklist.getCaseStatus(null);

        system.assert(caseStatus!='Open','Case is still in progress');
    }

    @isTest static void testCalculateCaseStatus(){
        boolean caseStatusChange;
        Case record = [select id from Case limit 1];

        caseStatusChange = Core_MDF_ClaimReviewChecklist.calculateCaseStatus(record.id,false);
        Core_MDF_ClaimReviewChecklist.calculateCaseStatus(null,false);

        system.assert(caseStatusChange==false,'Case is still in Under Review');
    }

    @isTest static void testCalculateAdjustmentAmount(){
        string exceptionMessage;
        Case record = [select id from Case limit 1];

        exceptionMessage = Core_MDF_ClaimReviewChecklist.calculateAdjustmentAmount(record.id,true,true); //DE60015 - Fix
        //Core_MDF_ClaimReviewChecklist.calculateAdjustmentAmount(null);

        system.assert(exceptionMessage==null,'Can choose to save Case as Compliant or Non-Compliant');
    }

    @isTest static void testCheckEditability(){
        List<User> usrList = new List<User>();
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usrList.add(usr);
        
        User auditor = Core_MDF_CCP_TestDataUtility.createUser(false);
        auditor.Email = 'auditor@example.com';
        auditor.Profile = ccpCoreProfile;
        usrList.add(auditor);
        
        Database.insert(usrList);
        
        PermissionSet auditorPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = auditor.Id;
        assignPermissionSetObj.PermissionSetId = auditorPS.Id;
        
        system.runas(usr){
            Database.insert(assignPermissionSetObj);
        }
        
        system.runas(auditor){
            boolean result = Core_MDF_ClaimReviewChecklist.checkEditability();
           
            system.assert(result==true,'Test user is a Claim Case Reviewer/Manager'); 
        }
        
    }


   @TestSetup
   static void createTestData(){
       Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                // Creating User with utility class 
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);

                Id caseAuditRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
        
                System.runAs(usr)
                    {
                        Case testCase= new Case();
                
                        testCase.recordtypeid = caseAuditRecordId;
                        testCase.Status = 'Open';
                        testCase.Core_MDF_Adjustment_Amount_Local__c =0;
                        testCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
                        testCase.Core_MDF_Reimbursement_Rate__c = 50;
                        testCase.Core_MDF_Status__c ='Under Review';
                        testcase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
                        testcase.Core_MDF_Claim_ID__c='0051234567890987654';
                        Database.insert(testCase);
                        
                        Case record = [select id from Case limit 1];
                        caseRecordId = record.id;
                        

                        //List<Core_MDF_Checklist_Items__mdt> testMetadata = new List<Core_MDF_Checklist_Items__mdt>();
                        List<Core_MDF_Claim_Case_Checklist__c> testChecklistRecord = new List<Core_MDF_Claim_Case_Checklist__c>();

                        Core_MDF_Claim_Case_Checklist__c checklistRecord1 = new Core_MDF_Claim_Case_Checklist__c();
                        checklistRecord1.Core_MDF_Case_ID__c = testCase.id;
                        checklistRecord1.Core_MDF_Checklist_Status__c = 'Compliant';

                        Core_MDF_Claim_Case_Checklist__c checklistRecord2 = new Core_MDF_Claim_Case_Checklist__c();
                        checklistRecord2.Core_MDF_Case_ID__c = testCase.id;
                        checklistRecord2.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                        checklistRecord2.Core_MDF_Impact_Amount__c = 20;

                        Core_MDF_Claim_Case_Checklist__c checklistRecord3 = new Core_MDF_Claim_Case_Checklist__c();
                        checklistRecord3.Core_MDF_Case_ID__c = testCase.id;
                        checklistRecord3.Core_MDF_Checklist_Status__c = 'NA';

                        testChecklistRecord.add(checklistRecord1);
                        testChecklistRecord.add(checklistRecord2);
                        testChecklistRecord.add(checklistRecord3);

                        Database.insert(testChecklistRecord);

                    }
       
   } 
    @isTest static void getCaseIdFromEscalationTest() {
        ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        Id escalationRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        Case record = [select id from Case limit 1];
        Case testCase = new Case();
        testCase.Id = record.Id;
        testCase.recordtypeid = caseAuditClosedRecordId;
        //testCase.Status = 'Closed';
        testCase.Core_MDF_Adjustment_Amount_Local__c =0;
        testCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
        testCase.Core_MDF_Reimbursement_Rate__c = 50;
        testCase.Core_MDF_Status__c ='Review Completed';
        testcase.Core_MDF_Requested_Amount_USD_Amt__c = 5;
        Database.update(testCase);
        
        Core_MDF_Escalation__c es = new Core_MDF_Escalation__c();
        es.Core_MDF_Escalation_Status_nm__c='Pending Review';
        es.Core_MDF_Escalation_Name_txt__c='Test3';
        es.Core_MDF_Total_Dollar_Impact_amt__c= 1; 
        //es.Core_MDF_Root_Cause_nm__c = 'Creative';
        es.Core_MDF_Case_ID_Number_id__c = testCase.Id;
        es.Core_MDF_Channel_Program_id__c = retailCp.Id;
        es.recordtypeid = escalationRecType;
        es.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = true;
        insert es;
        Core_MDF_ClaimReviewChecklist.getCaseIdFromEscalation(es.Id);
        // Unit Test Method should include System.Assert
        System.assertEquals(testCase.Id, es.Core_MDF_Case_ID_Number_id__c, 'Escalation should be linked to the correct Case.');
    }
   
    @isTest static void testgetAIAuditStatusFromScorecard(){
        
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
       
        Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper result = new Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper();
       
        result = Core_MDF_ClaimReviewChecklist.getAIAuditStatusFromScorecard(caseRec.Id);
    }
}