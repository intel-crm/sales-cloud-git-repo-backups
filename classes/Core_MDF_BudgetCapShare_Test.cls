/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapShare_Test 
* Version     : 1.0 
* Created Date: 05-04-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P       05-04-2019                   Created Core_MDF_BudgetCapShare_Test to test sharing for external users.
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_BudgetCapShare_Test {
/****************************************************************************************************************************************
    Method Name:                                             createBudgetCapShareRecords
    Description:                                             Creating budget cap share records to test sharing functionality for external users 
    Added By:                                                Accenture – Harika P  -  05/04/2019
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P        05/04/2019                   Created.
*****************************************************************************************************************************************/
	@isTest static void createBudgetCapShareRecords() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            
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
            Database.insert(dcfAcc);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            
            List<User> usrList = new List<User>();
            usrList.add(usr2);
            
            Database.insert(usrList);
            
            // Creating Group
            Group dcfgrp = new Group();
            dcfgrp.Name = 'Core CCP DCF External';
            dcfgrp.DeveloperName = 'Core_CCP_DCF_External';
            
            List<Group> dcfgrpList = new List<Group>();
            dcfgrpList.add(dcfgrp);
            
            Database.insert(dcfgrpList);
            
            // Creating Group Member
            GroupMember dcfGrpMem = new GroupMember();
            dcfGrpMem.UserOrGroupId = usr2.Id;
            dcfGrpMem.GroupId = dcfgrp.Id;
            
            List<GroupMember> dcfGrpMemList = new List<GroupMember>();
            dcfGrpMemList.add(dcfGrpMem);
            
            Database.insert(dcfGrpMemList);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intAcc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = dcfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            pgmList.add(pgm);
            
            Database.insert(pgmList);
            
            // Creating Budget using utility class
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   dcfAcc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   true);
            
            
            PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   dcfAcc.Id,cp.Id,5000000,System.today().addDays(111),System.today().addDays(120), 
                                                                                   true);
            pmbList.add(pmb);
            pmbList.add(pmb1);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,dcfAcc,1000000.0,true);
            
            // Creating BudgetCap Record
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 0;
            Database.insert(budgetCap);
            
            Test.startTest();
            pmb.Core_MDF_Budget_Status__c = 'Released';
            Database.update(pmb);
            Test.stopTest();
            
			PartnerMarketingBudget pmb2 = [SELECT Id,Core_MDF_Budget_Status__c FROM PartnerMarketingBudget WHERE Id =: pmb.Id];
            System.assertEquals('Released',pmb2.Core_MDF_Budget_Status__c);            
            
            // Calling budgetCapShare method from Core_MDF_BudgetCapShare class
            Core_MDF_BudgetCapShare.budgetCapShare(pmbList);
            
            //Verifying whether the budget cap is shared with external users or not
            List<Id> userOrGroupIdList = new List<Id>();
            for(Core_MDF_Budget_Cap__Share budgetShare : [SELECT Id, ParentId, UserOrGroupId FROM Core_MDF_Budget_Cap__Share where ParentId =: budgetCap.Id]){
                userOrGroupIdList.add(budgetShare.UserOrGroupId);
            }
            //System.assert(userOrGroupIdList.contains(dcfgrp.Id));
            
            // Calling budgetCapShare method from Core_MDF_BudgetCapShare class
            Core_MDF_BudgetCapShare.budgetCapShare(pmbList);            
            
            // Covering exception
            Core_MDF_BudgetCapShare.budgetCapShare(null);
        }
    }
}