/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewCaseShare_Test 
* Version     : 1.0 
* Created Date: 11-21-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P         11/23/2018                   Created Core_MDF_ClaimReviewCaseShare_Test to test case sharing for external users
* Accenture – Shridhar K       01/08/2019                   Updated testCaseShare method to check whether case is shared with only claim submitter 
* Accenture – Shridhar K       02/18/2019                   Case is shared with account manager based on PGM records
* Intel - NP(11630236)		   27/08/2019                   Created list to update common objects instead of individual inserts
* NP(11630236)				   28/2/2020					Added source for PGM insert
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ClaimReviewCaseShare_Test {
    
/****************************************************************************************************************************************
Method Name:                                             testCaseShare
@return  :                                               Void
@parameters:                                             --
Description:                                             This method is created to check case sharing with external user
Added By:                                                Accenture – Harika P  -  11/23/2018
Modified By:                  Date:                      Changes: 
Accenture – Harika P        11/21/2018                   Created. 
Accenture – Shridhar K      01/08/2019                   Updated testCaseShare method to check whether case is shared with only claim submitter 
* Accenture – Shridhar K       02/18/2019                   Case is shared with account manager based on PGM records
*****************************************************************************************************************************************/  
    @isTest static void testCaseShare() {        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        List<Account> accList = new List<Account>(); List<Contact> conList = new List<Contact>();List<User> userList= new List<User>();
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
            //intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intAcc.Industry = 'Food & Beverage';
            Database.insert(intAcc);
            
            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(dcfAcc);
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
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 50000];
            
            // Creating User with utility class 
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            userList.add(usr2);        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            userList.add(usr3);
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test3';
            usr4.ProfileId = partnerProfile.Id;
            usr4.ContactId = con2.Id;
            userList.add(usr4);
            Database.insert(userList);
            
            //Below lines of code added by Shridhar 01/08/2019
            //Assign claim submitter permissio set
            PermissionSet claimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
            list<PermissionSetAssignment> psaList = new list<PermissionSetAssignment>(); 
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr2.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr3.Id);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr4.Id);
            psaList.add(psa1);
            psaList.add(psa2);
            psaList.add(psa3);
            Database.insert(psaList); 

            //Creating Groups
            Group grp = new Group();
            grp.Name = 'CCP INTERNAL DCF APJ TEST ACCOUNT';
            grp.DeveloperName = 'Core_MDF_CCP_INTERNAL_APJ_DCF_TEST';
            
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';   

            Group grp2 = new Group();
            grp2.Name = 'CCP INTERNAL DCF WW TEST ACCOUNT';
            grp2.DeveloperName = 'Core_MDF_CCP_INTERNAL_WW_DCF_TEST';
            
            Group grp3 = new Group();
            grp3.Name = 'CCP INTERNAL CCF WW TEST ACCOUNT';
            grp3.DeveloperName = 'Core_MDF_CCP_INTERNAL_WW_CCF_TEST';          
            
            List<Group> lstGroup = new List<Group>();
            lstGroup.add(grp);
            lstGroup.add(grp1);
            lstGroup.add(grp2);
            lstGroup.add(grp3);
            Database.insert(lstGroup);
                        
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp1.Id;
                        
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = usr3.Id;
            grpMember1.GroupId = grp1.Id;
            
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = usr4.Id;
            grpMember2.GroupId = grp1.Id;           
            
            GroupMember grpMember3 = new GroupMember();
            grpMember3.UserOrGroupId = usr4.Id;
            grpMember3.GroupId = grp1.Id;
            
            List<GroupMember> lstGrpMember = new List<GroupMember>();
            lstGrpMember.add(grpMember);
            lstGrpMember.add(grpMember1);
            lstGrpMember.add(grpMember2);
            lstGrpMember.add(grpMember3);
            
            Database.insert(lstGrpMember);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intacc.Id;
            pgm.Core_MDF_Group_Name__c = 'CCP INTERNAL DCF APJ TEST ACCOUNT';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c = 'APJ';
            pgm.Core_MDF_AccountIdGroupName__c = pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Group_Name__c;
            pgm.Core_MDF_Source_Txt__c = 'Test';
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intacc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = pgm1.Core_MDF_Account__c + '_' + pgm1.Core_MDF_Group_Name__c;
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = intacc.Id;
            pgm2.Core_MDF_Group_Name__c = 'CCP INTERNAL DCF WW TEST ACCOUNT';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = grp2.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c = 'WW';
            pgm2.Core_MDF_AccountIdGroupName__c = pgm2.Core_MDF_Account__c + '_' + pgm2.Core_MDF_Group_Name__c;
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            
            Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
            pgm3.Core_MDF_Account__c = intacc.Id;
            pgm3.Core_MDF_Group_Name__c = 'CCP INTERNAL CCF WW TEST ACCOUNT';
            pgm3.Core_MDF_Type_of_Access__c = 'Internal';
            pgm3.Core_MDF_Group_Id__c = grp3.Id;                
            pgm3.Core_MDF_Channel_Program__c = cp1.Id;          
            pgm3.Core_MDF_Region_cd__c = 'WW';
            pgm3.Core_MDF_AccountIdGroupName__c = pgm3.Core_MDF_Account__c + '_' + pgm3.Core_MDF_Group_Name__c;
            pgm3.Core_MDF_Source_Txt__c = 'Test';
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            pgmList.add(pgm);pgmList.add(pgm1);pgmList.add(pgm2);pgmList.add(pgm3);
            
            Database.insert(pgmList);
            Test.startTest();
                                                                                          
            // Creating Partner Node User Mapping
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dcfAcc.Id,usr2.Id,true);
            Core_MDF_Partner_Node_User_Mapping__c pnum1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ccfAcc.Id,usr3.Id,true);
            System.debug('pnum :'+ pnum);
            System.debug('pnum1 :'+ pnum1);
            
            Test.stopTest();  
            
            // Creating Case
            List<Case> lstCases = new List<Case>();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = dcfAcc.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APJ-SA';
            cs.Core_MDF_Channel_Program_txt__c = 'Data Center Co-Marketing Fund';
            lstCases.add(cs);
            Database.insert(cs);
            
                                                        
            //Verifying whether the case is shared with account manager or not
            List<Id> userOrGroupIdList = new List<Id>();
            for(CaseShare csShare : [SELECT Id, CaseId, UserOrGroupId FROM CaseShare where CaseId =: cs.Id]){
                userOrGroupIdList.add(csShare.UserOrGroupId);
            }
                        
            System.debug('userOrGroupIdList: '+userOrGroupIdList);
            System.debug('grp.Id: '+grp.Id);
            System.debug('grp1.Id: '+grp1.Id); 
            System.debug('usr2.Id: '+usr2.Id);
            System.assert(userOrGroupIdList.contains(grp.Id));
            System.assert(userOrGroupIdList.contains(grp2.Id));
            System.assert(!userOrGroupIdList.contains(grp1.Id));            
            System.assert(!userOrGroupIdList.contains(grp3.Id));
            
            //Validating whether case is shared with only claim Submitter or not 
            System.assert(userOrGroupIdList.contains(usr2.Id));
            
            //Covering Exception
            List<Case> caseList = [SELECT id FROM Case WHERE Id=:cs.Id LIMIT 1];
            Core_MDF_ClaimReviewCaseShare.claimReviewCaseShare(caseList);
        }
    }  
}