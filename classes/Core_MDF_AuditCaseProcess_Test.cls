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
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            cs.recordTypeId = caseAuditRecType;
            insert cs;
            System.debug('Case Id:'+cs.Id); 
            cs.Core_MDF_Status__c = 'Pending Documents';
            update cs;
            List<Id> caseIdsList = new List<Id>();
            caseIdsList.add(cs.id);
            Test.startTest();
            Core_MDF_AuditCaseProcess.auditCaseAssignment(caseIdsList);
            //Case caseObjRec = [SELECT Id, ownerId FROM Case where id = :cs.id];
            //String ownerIdStr = caseObjRec.ownerId;
            //System.Assert(ownerIdStr.startsWith('00G'));
            Test.stopTest();
       }
    }
}