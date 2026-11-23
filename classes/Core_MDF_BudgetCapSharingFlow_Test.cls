/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapSharingFlow_Test 
* Version     : 1.0 
* Created Date: 05-02-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P       05-02-2019                   Created Core_MDF_BudgetCapSharingFlow_Test to test the flow functionality.
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_BudgetCapSharingFlow_Test {
/****************************************************************************************************************************************
    Method Name:                                             createBudgetCapRecords
    Description:                                             Creating budget cap records to test sharing functionality 
    Added By:                                                Accenture – Harika P  -  05/02/2019
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P        05/02/2019                    Created.
*****************************************************************************************************************************************/
	@isTest static void createBudgetCapRecords() {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-marketing Fund','Data Center CoMarketing Fund', true);
            
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
            Profile coreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            
            // Creating User with utility class
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = coreAccessProfile.Id;
            
            List<User> usrList = new List<User>();
            usrList.add(usr2);
            usrList.add(usr3);
            
            Database.insert(usrList);
            
            // Creating Group
            Group dcfgrp = new Group();
            dcfgrp.Name = 'Core CCP DCF External';
            dcfgrp.DeveloperName = 'Core_CCP_DCF_External';
            
            Group dcfgrp1 = new Group();
            dcfgrp1.Name = 'Core CCP DCF Internal';
            dcfgrp1.DeveloperName = 'Core_CCP_DCF_Internal';
            
            List<Group> dcfgrpList = new List<Group>();
            dcfgrpList.add(dcfgrp);
            dcfgrpList.add(dcfgrp1);
            
            Database.insert(dcfgrpList);
            
            // Creating Group Member
            
            GroupMember dcfGrpMem = new GroupMember();
            dcfGrpMem.UserOrGroupId = usr2.Id;
            dcfGrpMem.GroupId = dcfgrp.Id;
            
            GroupMember dcfGrpMem1 = new GroupMember();
            dcfGrpMem1.UserOrGroupId = usr3.Id;
            dcfGrpMem1.GroupId = dcfgrp1.Id;
            
            List<GroupMember> dcfGrpMemList = new List<GroupMember>();
            dcfGrpMemList.add(dcfGrpMem);
            dcfGrpMemList.add(dcfGrpMem1);
            
            Database.insert(dcfGrpMemList);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intAcc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = dcfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intAcc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_DCF_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'Internal';
            pgm1.Core_MDF_Group_Id__c = dcfgrp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            pgmList.add(pgm);
            pgmList.add(pgm1);
            
            Database.insert(pgmList);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   dcfAcc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   true);
            pmb.Core_MDF_Budget_Status__c = 'Released';
            Database.update(pmb);
            
            /*PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   dcfAcc.Id,cp.Id,5000000,System.today().addDays(111),System.today().addDays(120), 
                                                                                   true);*/
            
            // Creating Allocation using utility class
            //PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,dcfAcc,1000000.0,true);
            
            // Creating BudgetCap Record
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmb.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 0;
            Database.insert(budgetCap);
            
            Core_MDF_Budget_Cap__c bc = [SELECT Id,Core_MDF_Budget_Status_txt__c FROM Core_MDF_Budget_Cap__c WHERE Core_MDF_Cap_Type_nm__c = 'Channel Led Activity'];
            
            System.assertEquals('Released',bc.Core_MDF_Budget_Status_txt__c);
            
        }
    }
}