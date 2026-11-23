/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Case_Test 
* Version     : 1.0 
* Created Date: 04-02-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K      04/02/2019                   Created Core_MDF_ProcessCCP_Case_Test to test Core_MDF_ProcessCCP_Case
* Intel - NP(11630236)		  01/08/2019				   Added code to increase coverage for preventing Case status change if Checklist is incomplete
* Intel - NP(11630236)		  27/08/2019                   Created list to update common objects instead of individual inserts				  
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_Case_Test {
    /****************************************************************************************************************************************
Method Name:                                             testCaseReviewCheck
@return  :                                               Void
@parameters:                                             --
Description:                                             This method is created to check case review check
Added By:                                                Accenture – Shridhar K -  04/02/2019
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K        04/02/2019                 Created. 
*****************************************************************************************************************************************/  
    @isTest static void testCaseReviewCheck() { 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        List<Account> accList = new List<Account>(); List<Contact> conList = new List<Contact>(); List<Case> caseList = new List<Case>();
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
            intAcc.Core_Account_Type__c = 'Reseller';
            intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intAcc.Industry = 'Food & Beverage';
            
            Database.insert(intAcc);
            
            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(dcfAcc);
            //Database.insert(dcfAcc);
            Account ccfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(ccfAcc);
            Database.insert(accList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            Contact con2 = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con2);
            Database.insert(conList);
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            Profile coreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            
            // Creating User with utility class 
            
            List<User> usrList = new List<User>();
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usrList.add(usr2);
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            usrList.add(usr3);
            
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test3';
            usr4.ProfileId = partnerProfile.Id;
            usr4.ContactId = con2.Id;
            usrList.add(usr4);
            
            User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr5.LastName = 'User Test4';
            usr5.ProfileId = coreAccessProfile.Id;
            usrList.add(usr5);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test4';
            usr6.ProfileId = coreAccessProfile.Id;
            usrList.add(usr6);
            
            User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr7.LastName = 'User Test4';
            usr7.ProfileId = coreAccessProfile.Id;
            usrList.add(usr7);  
            
            Database.insert(usrList);
            
            PermissionSet reviewerPer = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
            PermissionSet reviewerManagerPer = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1]; 
            
            //Below lines of code added by Shridhar 01/08/2019
            //Assign claim submitter permissio set
            PermissionSet claimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
            list<PermissionSetAssignment> psaList = new list<PermissionSetAssignment>(); 
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr2.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr3.Id);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr4.Id);
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = reviewerPer.Id, AssigneeId = usr5.Id);
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = reviewerManagerPer.Id, AssigneeId = usr6.Id);

            psaList.add(psa1);
            psaList.add(psa2);
            psaList.add(psa3);
            psaList.add(psa4);
            psaList.add(psa5);          
            Database.insert(psaList);
            
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = dcfAcc.Id;
            cs.OwnerId = usr2.Id;
            caseList.add(cs);
            System.debug('cs' + cs);
            
            Case cs1 = new Case();
            cs1.recordTypeId = caseAuditRecType;
            cs1.AccountId = ccfAcc.Id;
            cs1.OwnerId = usr3.Id;
            caseList.add(cs1);
            Database.insert(caseList);
            System.debug('cs1' + cs1);
            
            //Populating Reviewer as Core_MDF_Claim_Case_Reviewer_Lookup__c
            cs1.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr5.Id;
            Database.SaveResult srRes = Database.update(cs1,false);
            System.assertEquals(true,srRes.isSuccess());
            
            //Populating Reviewer Manager as Core_MDF_Claim_Case_Reviewer_Lookup__c
            cs1.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr6.Id;
            Database.saveResult srRes1 = Database.update(cs1,false);
            System.assertEquals(true,srRes1.isSuccess());
            
            //Populating other than Reviewer and Reviewer Manager Core_MDF_Claim_Case_Reviewer_Lookup__c
            cs1.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr7.Id;
            Database.saveResult srRes2 = Database.update(cs1,false);
            System.assertEquals(false,srRes2.isSuccess());
            
            //Updating Case as Compliant
            cs1.Core_MDF_Review_Case_Status__c = 'Compliant';
            Database.saveResult srRes3 = Database.update(cs1,false);
            
            //Covering exception
            Core_MDF_ProcessCCP_Case.caseReviewerCheck(null,null,true,false); 
            
            //covering for data entry correction changes:US526998,US527005:Added by Ealisha
            cs.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr6.Id;
            cs.Core_MDF_Data_Entry_Correction__c = true;
            cs.Core_MDF_Data_Entry_Correction_Cd__c = 'Media Vehicle';
            cs.Core_MDF_Data_Correction_Note_Txt__c = 'test';
            Database.update(cs);
            Case csAfterUpdate = [Select Core_MDF_Data_Entry_CorrectionReason_Txt__c from Case where
                                 Core_MDF_Data_Entry_Correction__c = true and 
                                 Core_MDF_Data_Entry_Correction_Cd__c = 'Media Vehicle' and
                                 Core_MDF_Data_Correction_Note_Txt__c = 'test' limit 1];
                system.debug('csAfterUpdate:'+csAfterUpdate);
            System.assertEquals('Media Vehicle^ test',csAfterUpdate.Core_MDF_Data_Entry_CorrectionReason_Txt__c);
        }
    }
}