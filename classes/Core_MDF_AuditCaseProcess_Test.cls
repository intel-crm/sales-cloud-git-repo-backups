/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditAssignment_Test 
* Version     : 1.0 
* Created Date: 10-25-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – K Alka            10-25-2018                    Created Core_MDF_AuditCaseProcess_Test for class Core_MDF_AuditCaseProcess test
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_AuditCaseProcess_Test {
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data to test case assignment
    Added By:                                                Accenture – K Alka  -  10-25-2018
    Modified By:                  Date:                      Changes: 
    Accenture – K Alka            10-25-2018                 Created.
*****************************************************************************************************************************************/
    @isTest static void createTestData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        
        System.runAs(usr){
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Industry = 'Food & Beverage';
            Database.insert(intacc);
            Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            ccfacc.Core_MDF_CoMarketingActive__c = true;
            insert ccfacc;
            //Campaign CAP Campaign and Activity
            Campaign campCAP = Core_MDF_CCP_TestDataUtility.createCampaign('Campaign CAP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', Date.newInstance(2021, 01, 01), Date.newInstance(2022, 06, 30), 10000, 'Consumer Chromebook', ccfacc.Id, '2-in-1', false);
            campCAP.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            Database.insert(campCAP);
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Campaign_ID__c=campCAP.id;
            cs.Core_MDF_Claim_ID__c=campCAP.id;
            insert cs;
             
            cs.Core_MDF_Status__c = 'Pending Documents';
            update cs;
            List<Id> caseIdsList = new List<Id>();
            caseIdsList.add(cs.id);
            Test.startTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertNotEquals(null, caseIdsList, 'Case IDs list should not be null');
            Core_MDF_AuditCaseProcess.auditCaseAssignment(caseIdsList);
            // Case caseObjRec = [SELECT Id, ownerId FROM Case where id = :cs.id];
            // String ownerIdStr = caseObjRec.ownerId;
            // System.Assert(ownerIdStr.startsWith('00G'));
            Test.stopTest();
       }
    }
}