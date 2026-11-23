/****************************************************************************************************************************************
* Class Name  : Core_MDF_GenericApprovalProcess_Test 
* Version     : 1.0 
* Created Date: 8-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        8/27/2018                    Created to test Approvers based on criteria. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_GenericApprovalProcess_Test
{
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data for Generic Approval Process.
    Added By:                                                Accenture – Harika P  -  8/27/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          8/27/2018                  Created.
*****************************************************************************************************************************************/    
    @TestSetup static void createTestData() 
    {
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        List<User> usrLst = new List<User>();
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        usrLst.add(usr);
        //Database.insert(usr);
        
        User cmpaignUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        cmpaignUser.LastName = 'Campaign User';
        cmpaignUser.UserRoleId = usRole.Id;
        cmpaignUser.ManagerId = usr.Id;
        usrLst.add(cmpaignUser);
        Database.insert(usrLst); 
        
        System.runAs(usr){
            List<User> usrList = new List<User>();
            // Creating Users with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.IsActive = true;
            usrList.add(usr1);
        
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.IsActive = true;
            usrList.add(usr2);
        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.IsActive = true;
            usrList.add(usr3);
        
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test4';
            usr4.IsActive = true;
            usrList.add(usr4);
        
            User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr5.LastName = 'User Test5';
            usr5.IsActive = true;
            usrList.add(usr5);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test6';
            usr6.IsActive = true;
            usrList.add(usr6);
            
            User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr7.LastName = 'User Test7';
            usr7.IsActive = true;
            usrList.add(usr7);
            
            User usr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr8.LastName = 'User Test8';
            usr8.IsActive = true;
            usrList.add(usr8);
            
            User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr9.LastName = 'User Test9';
            usr9.IsActive = true;
            usrList.add(usr9);
            
            User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr10.LastName = 'User Test10';
            usr10.IsActive = true;
            usrList.add(usr10);
            
            User usr11 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr11.LastName = 'User Test11';
            usr11.IsActive = true;
            usrList.add(usr11);
            
            User usr12 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr12.LastName = 'User Test12';
            usr12.IsActive = true;
            usrList.add(usr12);
            
            User usr13 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr13.LastName = 'User Test13';
            usr13.IsActive = true;
            usrList.add(usr13);
            
            User usr14 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr14.LastName = 'User Test14';
            usr14.IsActive = true;
            usrList.add(usr14);
            
            User usr15 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr15.LastName = 'User Test15';
            usr15.IsActive = true;
            usrList.add(usr15);
            
            User usr16 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr16.LastName = 'User Test16';
            usr16.IsActive = true;
            usrList.add(usr16);
            
            User usr17 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr17.LastName = 'User Test17';
            usr17.IsActive = true;
            usrList.add(usr17);
            
            User usr18 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr18.LastName = 'User Test18';
            usr18.IsActive = true;
            usrList.add(usr18);
            
            Database.insert(usrList);
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(cp); 
            cpList.add(ipaCP);
            Database.insert(cpList);
            
            List<Account> ultAccList = new List<Account>();
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                            Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ultAccList.add(acc1);
            ultAccList.add(ipaUltimateAccount); 
            Database.insert(ultAccList);
            
            List<Account> coMarketingAccList = new List<Account>();
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', 
                                                                      cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, 
                                                                                                  Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
            
            coMarketingAccList.add(acc);
            coMarketingAccList.add(ipaCoMarketingAccount);            
            Database.insert(coMarketingAccList);
        
            String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
            Test.startTest();
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
     
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            system.runAs(usr){
                Database.insert(ipaGrpMem);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_Internal';
            Database.insert(pgm1);


            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Consumer', 'Apollo Lake', 'Pending Approval', true);

            // Creating Criterias for approval required
            List<Core_MDF_Criteria__c> cList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_Region_nm__c','Equal', 'APJ',
                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_6__c = 'Equal';
            cr.Core_MDF_Value_6__c = 'APJ';
            cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_7__c = 'Equal';
            cr.Core_MDF_Value_7__c = 'APJ';
            cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_8__c = 'Equal';
            cr.Core_MDF_Value_8__c = 'APJ';
            cr.Core_MDF_Field_Name_9__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_9__c = 'Equal';
            cr.Core_MDF_Value_9__c = 'APJ';
            cr.Core_MDF_Field_Name_10__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_10__c = 'Equal';
            cr.Core_MDF_Value_10__c = 'APJ';
            
            Core_MDF_Criteria__c cr1 = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                  'Core_MDF_Channel_Partner_Led__c','Equal','False','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                  'Core_MDF_Country_nm__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            cr1.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
            cr1.Core_MDF_Operator_6__c = 'Equal';
            cr1.Core_MDF_Value_6__c = 'APJ';
            cr1.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
            cr1.Core_MDF_Operator_7__c = 'Equal';
            cr1.Core_MDF_Value_7__c = 'APJ';
            cr1.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
            cr1.Core_MDF_Operator_8__c = 'Equal';
            cr1.Core_MDF_Value_8__c = 'APJ';
            cr1.Core_MDF_Field_Name_9__c = 'Core_MDF_Region_nm__c';
            cr1.Core_MDF_Operator_9__c = 'Equal';
            cr1.Core_MDF_Value_9__c = 'APJ';
            cr1.Core_MDF_Field_Name_10__c = 'Core_MDF_Region_nm__c';
            cr1.Core_MDF_Operator_10__c = 'Equal';
            cr1.Core_MDF_Value_10__c = 'APJ';
            
            Core_MDF_Criteria__c cr2 = Core_MDF_CCP_TestDataUtility.createCriteria('Campaign','Core_MDF_IPA_Proposal_AP',
                                                                                  'Core_MDF_Program__c','Equal','Intel Partner Alliance','','', '',
                                                                                  '','','','','','','','','',false);
            Core_MDF_Criteria__c cr3 = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                  'Core_MDF_End_Date__c','Greater Than or Equal',String.valueOf(System.today()),'Core_MDF_ActivityCategory__c','Equal','Digital Media',
                  'RequestedAmount','Greater Than','100','Core_MDF_Activity_Types__c','Equal','Podcast','Core_MDF_TargetAudience__c','Equal','Consumer',false);
            
            Core_MDF_Criteria__c cr4 = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_Region_nm__c','Equal', 'APJ',
                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_Region_nm__c','Equal','WW','Core_MDF_Region_nm__c','Equal','APJ',false);
            
            cList.add(cr);
            cList.add(cr1);
            cList.add(cr2);
            cList.add(cr3);
            cList.add(cr4);
            Database.insert(cList);
            
            List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
            // Creating 6 approvers for activity which are not qualified for auto approval
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            ap1.Core_MDF_Approver_2__c = usr2.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr7.Id;
            ap1.Core_MDF_Approver_5__c = usr8.Id;
            ap1.Core_MDF_Approver_6__c = usr14.Id;
            ap1.Core_MDF_Approver_7__c = usr15.Id;
            ap1.Core_MDF_Approver_8__c = usr16.Id;
            ap1.Core_MDF_Approver_9__c = usr17.Id;
            ap1.Core_MDF_Approver_10__c = usr18.Id;
            appList.add(ap1);
            //Database.insert(ap1);
        
            Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr3.Id, false);
            ap2.Core_MDF_Approver_Type__c = 'Internal';
            ap2.Core_MDF_Approver_2__c = usr2.Id;
            ap2.Core_MDF_Approver_3__c = usr6.Id;
            ap2.Core_MDF_Approver_4__c = usr7.Id;
            ap2.Core_MDF_Approver_5__c = usr8.Id;
            ap2.Core_MDF_Approver_6__c = usr14.Id;
            ap2.Core_MDF_Approver_7__c = usr15.Id;
            ap2.Core_MDF_Approver_8__c = usr16.Id;
            ap2.Core_MDF_Approver_9__c = usr17.Id;
            ap2.Core_MDF_Approver_10__c = usr18.Id;
            appList.add(ap2);  
            
            Core_MDF_Approver__c ap3 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr4.Id, false);
            ap3.Core_MDF_Approver_Type__c = 'Internal';
            ap3.Core_MDF_Approver_2__c = usr5.Id;
            ap3.Core_MDF_Approver_3__c = usr6.Id;
            ap3.Core_MDF_Approver_4__c = usr7.Id;
            ap3.Core_MDF_Approver_5__c = usr8.Id;
            ap3.Core_MDF_Approver_6__c = usr14.Id;
            ap3.Core_MDF_Approver_7__c = usr15.Id;
            ap3.Core_MDF_Approver_8__c = usr16.Id;
            ap3.Core_MDF_Approver_9__c = usr17.Id;
            ap3.Core_MDF_Approver_10__c = usr18.Id;
            appList.add(ap3);
            //Database.insert(ap3);
            
            Core_MDF_Approver__c ap4 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,usr9.Id, false);
            ap4.Core_MDF_Approver_Type__c = 'Internal';
            ap4.Core_MDF_Approver_2__c = usr10.Id;
            ap4.Core_MDF_Approver_3__c = usr6.Id;
            ap4.Core_MDF_Approver_4__c = usr7.Id;
            ap4.Core_MDF_Approver_5__c = usr8.Id;
            ap4.Core_MDF_Approver_6__c = usr14.Id;
            ap4.Core_MDF_Approver_7__c = usr15.Id;
            ap4.Core_MDF_Approver_8__c = usr16.Id;
            ap4.Core_MDF_Approver_9__c = usr17.Id;
            ap4.Core_MDF_Approver_10__c = usr18.Id;
            appList.add(ap4);
            //Database.insert(ap4);
            
            Core_MDF_Approver__c ap5 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,usr11.Id, false);
            ap5.Core_MDF_Approver_Type__c = 'Internal';
            ap5.Core_MDF_Approver_2__c = usr10.Id;
            ap5.Core_MDF_Approver_3__c = usr6.Id;
            ap5.Core_MDF_Approver_4__c = usr7.Id;
            ap5.Core_MDF_Approver_5__c = usr8.Id;
            ap5.Core_MDF_Approver_6__c = usr14.Id;
            ap5.Core_MDF_Approver_7__c = usr15.Id;
            ap5.Core_MDF_Approver_8__c = usr16.Id;
            ap5.Core_MDF_Approver_9__c = usr17.Id;
            ap5.Core_MDF_Approver_10__c = usr18.Id;
            appList.add(ap5);
            
            Core_MDF_Approver__c ap6 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,usr12.Id, false);
            ap6.Core_MDF_Approver_Type__c = 'Internal';
            ap6.Core_MDF_Approver_2__c = usr10.Id;
            ap6.Core_MDF_Approver_3__c = usr6.Id;
            ap6.Core_MDF_Approver_4__c = usr7.Id;
            ap6.Core_MDF_Approver_5__c = usr8.Id;
            ap6.Core_MDF_Approver_6__c = usr14.Id;
            ap6.Core_MDF_Approver_7__c = usr15.Id;
            ap6.Core_MDF_Approver_8__c = usr16.Id;
            ap6.Core_MDF_Approver_9__c = usr17.Id;
            ap6.Core_MDF_Approver_10__c = usr18.Id;
            //ap6.Core_MDF_Approver_2__c = usr13.Id;
            appList.add(ap6);
            
            Core_MDF_Approver__c ap7 = Core_MDF_CCP_TestDataUtility.createApprover(cr2.Id,usr1.Id, false);
            ap7.Core_MDF_Approver_Type__c = 'Internal';
            appList.add(ap7);
            
            Core_MDF_Approver__c ap8 = Core_MDF_CCP_TestDataUtility.createApprover(cr3.Id,usr1.Id, false);
            ap8.Core_MDF_Approver_Type__c = 'Internal';
            ap8.Core_MDF_Approver_2__c = usr2.Id;
            ap8.Core_MDF_Approver_3__c = usr6.Id;
            ap8.Core_MDF_Approver_4__c = usr7.Id;
            ap8.Core_MDF_Approver_5__c = usr8.Id;
            ap8.Core_MDF_Approver_6__c = usr14.Id;
            ap8.Core_MDF_Approver_7__c = usr15.Id;
            ap8.Core_MDF_Approver_8__c = usr16.Id;
            ap8.Core_MDF_Approver_9__c = usr17.Id;
            ap8.Core_MDF_Approver_10__c = usr18.Id;
            appList.add(ap8);
            
            Core_MDF_Approver__c ap10 = Core_MDF_CCP_TestDataUtility.createApprover(cr4.Id,usr1.Id, false);
            ap10.Core_MDF_Approver_Type__c = 'Internal';
            ap10.Core_MDF_Approver_2__c = usr2.Id;

            appList.add(ap10);
            
            Group apjGroup = new Group();
            apjGroup.Name = 'APJ Group';
            apjGroup.DeveloperName = 'Core_MDF_APJ_Group';
            database.insert(apjGroup);
            
            GroupMember gm = new GroupMember();
            gm.GroupId = apjGroup.Id;
            gm.UserOrGroupId = usr2.Id;
            database.insert(gm);
            
            Core_MDF_Approver__c ap9 = Core_MDF_CCP_TestDataUtility.createApprover(cr3.Id,usr1.Id, false);
            ap9.Core_MDF_Group_Name_txt__c = 'Core_MDF_APJ_Group';
            ap9.Core_MDF_Approver_Type__c = 'Internal';
            ap9.Core_MDF_Is_Approver_From_Group_ind__c = TRUE;
            appList.add(ap9);
            
            Database.insert(appList);
            
            List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
            // Creating Criteria rules for approvers
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_End_Date__c','Less Than',
                                                                                               String.valueOf(System.today().addDays(2)),false);
        
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'RequestedAmount','Less Than or Equal',
                                                                                               '8000',false);
        
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',false);
            Core_MDF_Criteria_Rule__c cruleWW = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Region_nm__c','Equal',
                                                                                               'APJ',false);
        
            Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',false);
            
            Core_MDF_Criteria_Rule__c crule5 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'RequestedAmount','Equal','9000',false);
            
            Core_MDF_Criteria_Rule__c crule6 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Creator',false);
            
            Core_MDF_Criteria_Rule__c crule7 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'RequestedAmount','Equal','16000',false);
        
            Core_MDF_Criteria_Rule__c crule8 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i9 Processor',false);
        
            Core_MDF_Criteria_Rule__c crule9 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Consumer',false);
            
            Core_MDF_Criteria_Rule__c crule10 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap4.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                                'Consumer',false);
            
            Core_MDF_Criteria_Rule__c crule11 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap4.Id,'RequestedAmount','Equal','10000',false);
            
            Core_MDF_Criteria_Rule__c crule12 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap4.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                                'Broadcast',false);
            
            Core_MDF_Criteria_Rule__c crule13 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap5.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                                'Print Media',false);
            
            Core_MDF_Criteria_Rule__c crule14 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap5.Id,'Core_MDF_Activity_Types__c','Equal',
                                                                                                'Direct Mail',false);
            
            Core_MDF_Criteria_Rule__c crule15 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap5.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                                'Mid Market / Large Enterprise',false);
            
            Core_MDF_Criteria_Rule__c crule16 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap6.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                                'Out of Home Media',false);
        
            Core_MDF_Criteria_Rule__c crule17 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap6.Id,'Core_MDF_Activity_Types__c','Equal',
                                                                                                'Cinema',false);
            
            Core_MDF_Criteria_Rule__c crule18 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap6.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                                'Consumer',false);
            
            Core_MDF_Criteria_Rule__c crule19 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap7.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Greater Than or Equal',
                                                                                               '1',false);
            
            Core_MDF_Criteria_Rule__c crule20 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap8.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                               'Digital Media',false);
            
            Core_MDF_Criteria_Rule__c crule21 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap9.Id,'Core_MDF_ActivityCategory__c','Not Equal',
                                                                                               'Digital Media',false);
            Core_MDF_Criteria_Rule__c crule22 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap10.Id,'Core_MDF_Region_nm__c','Equal',
                                                                                               'WW',false);
            
            crList.add(crule1);
            crList.add(crule2);
            crList.add(crule3);
            crList.add(crule4);
            crList.add(crule5);
            crList.add(crule6);
            crList.add(crule7);
            crList.add(crule8);
            crList.add(crule9);
            crList.add(crule10);
            crList.add(crule11);
            crList.add(crule12);
            crList.add(crule13);
            crList.add(crule14);
            crList.add(crule15);
            crList.add(crule16);
            crList.add(crule17);
            crList.add(crule18);
            crList.add(crule19);
            crList.add(crule20);
            crList.add(crule21);
            crList.add(cruleWW);
            crList.add(crule22);
            Database.insert(crList);
            
            List<Core_MDF_Approver__c> apUpdateList = new List<Core_MDF_Approver__c>();
            //Activating Approvers
            ap1.Core_MDF_Active__c = True;
            apUpdateList.add(ap1);
            ap2.Core_MDF_Active__c = True;
            apUpdateList.add(ap2);
            ap3.Core_MDF_Active__c = True;
            apUpdateList.add(ap3);
            ap4.Core_MDF_Active__c = True;
            apUpdateList.add(ap4);
            ap5.Core_MDF_Active__c = True;
            apUpdateList.add(ap5);
            ap6.Core_MDF_Active__c = True;
            apUpdateList.add(ap6);
            ap7.Core_MDF_Active__c = True;            
            apUpdateList.add(ap7);
            ap8.Core_MDF_Active__c = True;            
            apUpdateList.add(ap8);
            ap9.Core_MDF_Active__c = True;            
            apUpdateList.add(ap9);
            ap10.Core_MDF_Active__c = True;            
            apUpdateList.add(ap10);             
            Database.update(apUpdateList);
            
            List<Core_MDF_Criteria__c> cUpdateList = new List<Core_MDF_Criteria__c>();
            //Activating Approval Criteria
            cr.Core_MDF_Active__c = True;
            cUpdateList.add(cr);
            cr1.Core_MDF_Active__c = True;
            cUpdateList.add(cr1);
            cr2.Core_MDF_Active__c = True;
            cUpdateList.add(cr2);
            cr3.Core_MDF_Active__c = True;
            cUpdateList.add(cr3);
            cr4.Core_MDF_Active__c = True;
            cUpdateList.add(cr4);            
            Database.update(cUpdateList);
            
            //Activating Approval Criteria
            
        
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Core™ i7+ Processor', 'Yes',
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                  System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', false);
            camp.Core_MDF_Activity_Category_Type__c = null;
            insert camp;

            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);

            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            // Create PMB for the above Account 
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',recordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
            pmbRecord.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            //pmbRecord.IsIgnoreValidation = true;
            insert pmbRecord;
            
            // Create PFA records for the above accounts :
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 1234,true);        

            //Test.startTest();

            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today().addDays(1);
            pfr.RequestedAmount = 6000;
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            pfrList.add(pfr);
    
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Creator','Desktop',
                  'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr1.Title = 'Test Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Activity1';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr1.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr1.RequestedAmount = 9000;
            pfr1.Core_MDF_Channel_Partner_Led__c = True;
            pfrList.add(pfr1);
        
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i9 Processor','Broadcast','Radio','Draft',false);
            pfr2.Title = 'Test Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
            pfr2.Core_MDF_Start_Date__c = System.today();
            pfr2.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfrList.add(pfr2);
        
            PartnerFundRequest pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr3.Title = 'Test Activity3';
            pfr3.Core_MDF_Activity_Description__c = 'Test Activity3';
            pfr3.Core_MDF_Start_Date__c = System.today();
            pfr3.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr3.RequestedAmount = 10000;
            pfr3.Core_MDF_Channel_Partner_Led__c = False;
            pfrList.add(pfr3);
            
            PartnerFundRequest pfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer',
                  'Desktop','Intel® Core™ i7 Processor','Print Media','Direct Mail','Draft',false);
            pfr4.Title = 'Test Activity4';
            pfr4.Core_MDF_Activity_Description__c = 'Test Activity4';
            pfr4.Core_MDF_Start_Date__c = System.today();
            pfr4.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr4.Core_MDF_Channel_Partner_Led__c = False;
            pfr4.Core_MDF_ofPagesEligible__c  = 10;
            pfr4.Core_MDF_pagespayingfor__c = 10;
            pfr4.RequestedAmount = 1000;
            pfrList.add(pfr4);
            
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr5.Title = 'Test Activity5';
            pfr5.Core_MDF_Activity_Description__c = 'Test Activity5';
            pfr5.Core_MDF_Start_Date__c = System.today();
            pfr5.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr5.Core_MDF_Channel_Partner_Led__c = False;
            pfr5.RequestedAmount = 1000;
            pfrList.add(pfr5);
            
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'ANGOLA','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr6.Title = 'Test Activity6';
            pfr6.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr6.Core_MDF_Start_Date__c = System.today();
            pfr6.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr6.Core_MDF_Channel_Partner_Led__c = False;
            pfr6.RequestedAmount = 1000;
            pfrList.add(pfr6);

            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'AFGHANISTAN','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr7.Title = 'Test Activity7';
            pfr7.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr7.Core_MDF_Start_Date__c = System.today();
            pfr7.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr7.Core_MDF_Channel_Partner_Led__c = False;
            pfr7.RequestedAmount = 1000;
            pfrList.add(pfr7);
            
            PartnerFundRequest pfr8 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'AFGHANISTAN','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr8.Title = 'Test Activity8';
            pfr8.Core_MDF_Activity_Description__c = 'Test Activity7';
            pfr8.Core_MDF_Start_Date__c = System.today();
            pfr8.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr8.Core_MDF_Channel_Partner_Led__c = False;
            pfr8.RequestedAmount = 1000;
            pfrList.add(pfr8);
            
            PartnerFundRequest pfr9 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr9.Title = 'Test Activity';
            pfr9.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr9.Core_MDF_Start_Date__c = System.today();
            pfr9.Core_MDF_End_Date__c = System.today().addDays(1);
            pfr9.RequestedAmount = 6000;
            pfr9.Core_MDF_Channel_Partner_Led__c = True;
            pfrList.add(pfr9);
            Database.insert(pfrList);

            Test.stopTest();
        }
    }  
/****************************************************************************************************************************************
    Method Name:                                             testCustomApprovalProcessMethod
    Description:                                             Created to test Custom Approval Process
    Added By:                                                Accenture – Harika P  -  8/27/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          8/27/2018                  Created.
*****************************************************************************************************************************************/      
   /* @isTest static void testCustomApprovalProcessMethod(){ 
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        System.runAs(user){
            Test.startTest();
            list<User> usrList = [SELECT Id, LastName FROM User WHERE LastName LIKE 'usr%' LIMIT 10000 ];
            
            list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,RequestedAmount,  Core_MDF_Start_Date__c, 
                   Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c,  Core_MDF_Brand_nm__c, Core_MDF_Approver_1__c, 
                   Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c,Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                   Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                   Core_MDF_ActivityCategory__c,Core_MDF_Country_nm__c ,Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c,
                   Core_MDF_Approver_6__c, Core_MDF_Approver_7__c  ,Core_MDF_Approver_8__c ,  Core_MDF_Approver_9__c  ,Core_MDF_Approver_10__c ,                        
                   Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_nm__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity1' LIMIT 1];
            //Test.stopTest();
            Map<String,Map<String, list<Id>>> setApproverResultMap1 = Core_MDF_GenericApprovalProcess.setApprovers((List<SObject>) pfrList);
 
            // Testing auto approval records 
            if(setApproverResultMap1.containsKey('autoApproved')){
                Map<String, list<Id>> autoApprovedSObjects = setApproverResultMap1.get('autoApproved');
                PartnerFundRequest autoApprovedActivity = [SELECT Id,  Title,Core_MDF_Brand_nm__c FROM PartnerFundRequest WHERE Title ='Test Activity1' LIMIT 1];
                System.assert(autoApprovedSObjects.keySet().contains(String.valueOf(autoApprovedActivity.Id)));
                
            }
            
            // Testing approval required records 
            if(setApproverResultMap1.containsKey('approvalRequired')){
                Map<String, list<Id>> nonAutoApprovedSObjects = setApproverResultMap1.get('approvalRequired');
                for(PartnerFundRequest pfr:pfrList){
                    if(nonAutoApprovedSObjects.keySet().contains(pfr.Id)){
                        for(User usr : usrList){
                            if(pfr.Title == 'Test Activity'){
                                if(usr.LastName == 'User Test1'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test2'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test6'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }                                   
                                if(usr.LastName == 'User Test7'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test8'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }                               
    
                            }
                        
                            if(pfr.Title == 'Test Activity1'){
                                if(usr.LastName == 'User Test3'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                
                            }
                        
                            if(pfr.Title == 'Test Activity2'){
                                if(usr.LastName == 'User Test4'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test5'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                            }
                        
                            if(pfr.Title == 'Test Activity3'){
                                if(usr.LastName == 'User Test9'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test10'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                            }
                        
                            if(pfr.Title == 'Test Activity4'){
                                if(usr.LastName == 'User Test11'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }                               
                            }
                            
                            if(pfr.Title == 'Test Activity7'){
                                if(usr.LastName == 'User Test14'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                            }
                        
                            if(pfr.Title == 'Test Activity5'){
                                if(usr.LastName == 'User Test12'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test13'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                            }
                        }
                    }
                }
            }
        Test.stopTest();
        }
    }*/
    
    @isTest 
    static void validateApprovalFlow(){
        
        User user = [SELECT Id, LastName FROM User WHERE LastName ='Campaign User'  LIMIT 1];
        
        System.runAs(user){           
       
            Test.startTest(); 
            
            Campaign ipaCampaign = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                         Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Core_MDF_Activity_Category_Type__c, Core_MDF_Budget_Type_txt__c,
                                         StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c  
                                         FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
            try{
                
            ipaCampaign.Core_MDF_Approval_Step_Counter_nbr__c = 1;
            ipaCampaign.Core_MDF_Activity_Category_Type__c = 'Broadcast->Other (Broadcast)';
            database.update(ipaCampaign);
                
            List<Campaign> cmpUpd = new List<Campaign>();
            cmpUpd.add(ipaCampaign); 
            
            Map<Id,Campaign> campOldMap = new Map<Id,Campaign>();
            campOldMap.put(ipaCampaign.Id, ipaCampaign);
            Core_MDF_Proposal_Based_Campaign_Process.onSubmitForApproval(cmpUpd,campOldMap);
            
            }catch(exception e){ 
                // Highlight: Unused Local Variable - Indira
              //  String message = e.getMessage();
            }

            
            System.assertEquals('Broadcast->Other (Broadcast)',ipaCampaign.Core_MDF_Activity_Category_Type__c);
            Test.stopTest();
        }
    }
    
   
    
    
/****************************************************************************************************************************************
    Method Name:                                             testValidateRuleMethod
    Description:                                             Created for Validating Rules
    Added By:                                                Accenture – Harika P  -  8/27/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          8/27/2018                  Created.
*****************************************************************************************************************************************/        
    @isTest static void testValidateRuleMethod()
    { 
        User usr = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        System.runAs(usr){
            Boolean ruleResult;
            Test.startTest();
            //testing validateRule method for data type DOUBLE with appropriate operators
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('10','10','Equal','DOUBLE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('10','20','Not Equal','DOUBLE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('10','40','Equal','DOUBLE');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('20','20','Not Equal','DOUBLE');
            System.assertEquals(false,ruleResult);  

            //testing validateRule method for data type PICKLIST with appropriate operators         
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('50%','50%','Equal','PICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('50%','30%','Not Equal','PICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('50%','30%','Greater Than','PICKLIST');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type CURRENCY with appropriate operators             
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('5000','2000','Not Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('5000','5000','Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('5000','2000','Greater Than','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('2000','5000','Less Than','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('5000','4000','Greater Than or Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('4000','5000','Less Than or Equal','CURRENCY');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type DATE with appropriate operators  
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(String.valueOf(System.today().addDays(5)),String.valueOf(System.today()),
                                                                      'Greater Than','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(String.valueOf(System.today()),String.valueOf(System.today().addDays(5)),
                                                                      'Less Than','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(String.valueOf(System.today()),String.valueOf(System.today()),'Equal','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(String.valueOf(System.today()),String.valueOf(System.today()),'Not Equal',
                                                                      'DATE');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(String.valueOf(System.today()),String.valueOf(System.today()),
                                                                      'Greater Than or Equal','DATE');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(String.valueOf(System.today()),String.valueOf(System.today().addDays(1)),
                                                                      'Less Than or Equal','DATE');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type MULTIPICKLIST with appropriate operators    
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Greater Than','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Any','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            
            //testing validateRule method for data type TEXTAREA with appropriate operators
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('Tset','Test','Equal','TEXTAREA');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('Test','Test','Equal','TEXTAREA');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('Test1','Test','Not Equal','TEXTAREA');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('Test1','Test','Not Equal','TESTFIELDTYPE');
            System.assertEquals(false,ruleResult);
            
            //testing validateRule method for data type all with appropriate IN,NOT In, Equla and Not Equal operators
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;INDIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);  
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA;INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('10','10','In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('10;20','10','In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,NULL,'In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,'ALBANIA;AUSTRALIA','In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,'ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA','ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(false,ruleResult);      
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('INDIA','ALBANIA;AUSTRALIA','Not In','STRING');
            System.assertEquals(true,ruleResult);       
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,NULL,'Not In','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA',NULL,'In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,'ALBANIA','In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,NULL,'In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,NULL,'Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);      
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,'ALBANIA','Not In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,NULL,'Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA',NULL,'Equal','STRING');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,'ALBANIA','Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,NULL,'Not Equal','MULTIPICKLIST');
            System.assertEquals(false,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('ALBANIA',NULL,'Not Equal','STRING');
            System.assertEquals(true,ruleResult);
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule(NULL,'ALBANIA','Not Equal','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            System.assertEquals(true,ruleResult); 
            ruleResult = Core_MDF_GenericApprovalProcess.validateRule('true','true','Equal','CHECKBOX');
            Test.stopTest();
        }
    }
   /* @isTesT static void setWWApproversTest(){
        Test.startTest();
        list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c, 
                   Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c, Core_MDF_Brand_nm__c, Core_MDF_Approver_1__c, 
                   Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c,Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                   Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                   Core_MDF_ActivityCategory__c,Core_MDF_Country_nm__c ,Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c,
                   Core_MDF_Approver_6__c, Core_MDF_Approver_7__c  ,Core_MDF_Approver_8__c ,Core_MDF_Approver_9__c  ,Core_MDF_Approver_10__c ,                        
                   Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_nm__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity'];
        system.debug('pfrList1:' + pfrList);
        Core_MDF_GenericApprovalProcess.setApprovers(pfrList);
        Test.stopTest();
    }*/
    
   /* @isTesT static void setDefaultApproversTest(){
        Test.startTest();
        User usr = [SELECT Id FROM User WHERE LastName = 'User Test1' LIMIT 1];
        Core_MDF_Criteria__c approvalCriteriaRec = [SELECT Id FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerFundRequest' AND Core_MDF_Field_Name_1__c = 'Core_MDF_Region_nm__c' AND Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c' LIMIT 1];
        
        List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
        for(Core_MDF_Approver__c appr : [SELECT Id FROM Core_MDF_Approver__c WHERE Core_MDF_Criteria__c =: approvalCriteriaRec.Id AND Core_MDF_Approver_1__c =: usr.Id]){
            appr.Core_MDF_Approver_2__c = null;
            appr.Core_MDF_Approver_3__c = null;
            appr.Core_MDF_Approver_4__c = null;
            appr.Core_MDF_Approver_5__c = null;
            appr.Core_MDF_Approver_6__c = null;
            appr.Core_MDF_Approver_7__c = null;
            appr.Core_MDF_Approver_8__c = null;
            appr.Core_MDF_Approver_9__c = null;
            appr.Core_MDF_Approver_10__c = null;
            approverList.add(appr);
        }
        
        Database.update(approverList);
        
        list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c, 
                   Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c, Core_MDF_Brand_nm__c, Core_MDF_Approver_1__c, 
                   Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c,Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                   Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                   Core_MDF_ActivityCategory__c,Core_MDF_Country_nm__c ,Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c,
                   Core_MDF_Approver_6__c, Core_MDF_Approver_7__c  ,Core_MDF_Approver_8__c ,Core_MDF_Approver_9__c  ,Core_MDF_Approver_10__c ,                        
                   Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_nm__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity'];
        system.debug('pfrList2:' + pfrList);
        Core_MDF_GenericApprovalProcess.setApprovers(pfrList);
        Test.stopTest();
    }*/
    
    /*@isTesT static void setApproversTest(){
        Test.startTest();
        list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c, 
                   Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c,Core_MDF_Channel_Partner__c, Core_MDF_Brand_nm__c, Core_MDF_Approver_1__c, 
                   Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c,Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                   Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                   Core_MDF_ActivityCategory__c,Core_MDF_Country_nm__c ,Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c,
                   Core_MDF_Approver_6__c, Core_MDF_Approver_7__c  ,Core_MDF_Approver_8__c ,  Core_MDF_Approver_9__c  ,Core_MDF_Approver_10__c ,                        
                   Core_MDF_Reimbursement_Rate__c,Core_MDF_Region_nm__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity'];
        system.debug('pfrList3:' + pfrList);
        Core_MDF_GenericApprovalProcess.setApproversFromMultipleRecords(pfrList);
        Test.stopTest();
    }*/
    
    /*@isTesT static void setDefaultApproversTestMultipleRecords(){
        Test.startTest();
        User usr = [SELECT Id FROM User WHERE LastName = 'User Test1' LIMIT 1];
        Core_MDF_Criteria__c approvalCriteriaRec = [SELECT Id FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerFundRequest' AND Core_MDF_Field_Name_1__c = 'Core_MDF_Region_nm__c' AND Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c' LIMIT 1];
        
        List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
        for(Core_MDF_Approver__c appr : [SELECT Id FROM Core_MDF_Approver__c WHERE Core_MDF_Criteria__c =: approvalCriteriaRec.Id AND Core_MDF_Approver_1__c =: usr.Id]){
            appr.Core_MDF_Approver_2__c = null;
            appr.Core_MDF_Approver_3__c = null;
            appr.Core_MDF_Approver_4__c = null;
            appr.Core_MDF_Approver_5__c = null;
            appr.Core_MDF_Approver_6__c = null;
            appr.Core_MDF_Approver_7__c = null;
            appr.Core_MDF_Approver_8__c = null;
            appr.Core_MDF_Approver_9__c = null;
            appr.Core_MDF_Approver_10__c = null;
            approverList.add(appr);
        }
        
        Database.update(approverList);
        
        list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c, 
                   Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c, Core_MDF_Brand_nm__c, Core_MDF_Approver_1__c, 
                   Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c,Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                   Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                   Core_MDF_ActivityCategory__c,Core_MDF_Country_nm__c ,Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c,
                   Core_MDF_Approver_6__c, Core_MDF_Approver_7__c  ,Core_MDF_Approver_8__c ,Core_MDF_Approver_9__c  ,Core_MDF_Approver_10__c ,                        
                   Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_nm__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity'];
        system.debug('pfrList4:' + pfrList);
        Core_MDF_GenericApprovalProcess.setApproversFromMultipleRecords(pfrList);
        Test.stopTest();
    }*/
}