@isTest(SeeAllData=false)
private class Core_MDF_Test_ProcessCCP{
    
    /****************************************************************************************************************************************
    Method Name:                                   createTestData
    Description:                                   Creating test data to test approval process
    Added By:                                      Accenture – Harika P  -  8/27/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        8/27/2018           Created.
    Accenture – Shridhar K        12/24/2018       Added Allocation and budget parameters createPartnerFundRequest method to fix null pointer exception 
    Intel - Narayani Perachi    02/11/2019         Added user and PFR record to test the functionality of Auto approver if created/modified by Account Manager
    *****************************************************************************************************************************************/    
    @TestSetup static void createTestData(){
        //Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_DCF_Acct_Mgr']; //Core_MDF_CCP_Internal_DCF_Account_Manager
        
        Map<String, Id> psetMap = new Map<String, Id>();
        List<PermissionSet> prmsetlst = [select Id, Name from PermissionSet Where Name IN ('Core_MDF_CCP_Internal_DCF_Acct_Mgr', 'Core_MDF_CCP_Internal_Retail_Account_Manager', 'Core_MDF_CCP_External_Activity_Approver')];
        for(PermissionSet pset : prmsetlst) {
            psetMap.put(pset.Name, pset.Id);
        }
        
        //System.debug('prmsetMap '+prmsetMap);
    
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            // Creating channel program with utility class
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(cp);
            cpList.add(cpRetail);
            cpList.add(ipaCP);
            insert cpList;
            
            // Creating IntelAccount with utility class
            List<Account> accIntelList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';            
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            accIntelList.add(acc1);
            
            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'APJ';            
            accIntelList.add(acc1Retail);
            
            Account ipaUltimateAccountPFR = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account PFR',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccountPFR.Core_MDF_Channel_Program__c = ipaCP.Id;
            ipaUltimateAccountPFR.Core_Account_Type__c = 'Reseller';            
            ipaUltimateAccountPFR.Industry = 'Food & Beverage';
            accIntelList.add(ipaUltimateAccountPFR);
            Database.insert(accIntelList);
            
            
            // Creating Co-marketing Account with utility class
            List<Account> accCoMarketingList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCoMarketingList.add(acc);
            
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accCoMarketingList.add(accRetail);

            Account accRetail2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail2', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail2.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail2.Core_Geo__c = 'APJ';
            accCoMarketingList.add(accRetail2);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);           
            Account ipaCoMarketingAccount1 = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR2', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount1.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            accCoMarketingList.add(ipaCoMarketingAccount);
            accCoMarketingList.add(ipaCoMarketingAccount1);
      
            // Creating Group
            List<Group> groupList = new List<Group>();
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
            groupList.add(ccfgrp);
            
            Group ccfAPJGrp = new Group();
            ccfAPJGrp.Name = 'Core_MDF_Int_CCF_APJ';
            ccfAPJGrp.DeveloperName = 'Core_MDF_Int_CCFAPJ';
            groupList.add(ccfAPJGrp);
            
            Group ccfAPJGrp1 = new Group();
            ccfAPJGrp1.Name = 'Core_MDF_Ext_CCF_APJ';
            ccfAPJGrp1.DeveloperName = 'Core_MDF_Ext_CCF_APJ';
            groupList.add(ccfAPJGrp1);
      
            Group accNodeGroup = new Group(Name = 'Core_MDF_Retail_Acc_Node_Group', DeveloperName = 'Core_MDF_Retail_Acc_Node_Group');
            groupList.add(accNodeGroup);
            insert groupList;
      
            accCoMarketingList[1].Core_MDF_Group_Id__c = accNodeGroup.Id;
            accCoMarketingList[2].Core_MDF_Group_Id__c = accNodeGroup.Id;
            
            Database.insert(accCoMarketingList);
            
            List<Contact> listContact = new List<Contact>();
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id,false);
            conRecord1.Core_Audience_List__c= 'RMF User';
            
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id,false);
            
            listContact.add(conRecord1);
            listContact.add(conRecord2);
            Database.insert(listContact);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name ='RPS_Retailer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='RPS_Retailer');
            insert cee;
            
            List< Core_Entitlement__c> entListVal = new List< Core_Entitlement__c>();
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='RMF User', Core_Category__c='Consolidated Co-marketing Platform',Core_Sub_Category__c='Retail Marketing Funds (RMF)',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true, Core_Permission_Set_API_Nm__c='Core_MDF_Retail_USER');
            entListVal.add(entitle);
            insert entListVal;
                        
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=conRecord1.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=false);
            ceList.add(ce);       
            Database.insert(ceList);
                       
            List<User> userList = new List<User>();
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            userList.add(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            userList.add(usr2);
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            userList.add(usr3);
            
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test4';
            userList.add(usr4);
            
            User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr5.LastName = 'User Test5';
            userList.add(usr5);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test6';
            userList.add(usr6);
            
            User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr7.LastName = 'User Test7';
            userList.add(usr7);
            
            User usr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr8.LastName = 'User Test8';
            userList.add(usr8);
            
            User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr10.LastName = 'User Test10';
            userList.add(usr10);
            
            User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr9.LastName = 'User Test9';
            userList.add(usr9);
                        
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
            
            User usr11 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr11.Email='test1@example.com';
            usr11.ContactId = listContact[0].Id;
            usr11.ProfileId = profileId;
            usr11.isActive = true;
            userList.add(usr11);
            
            User usr12 = Core_MDF_CCP_TestDataUtility.createUser(false);   
            usr12.LastName = 'User Test12';
            
            usr12.isActive = true;
            userList.add(usr12);
                       
            insert userList;
            
            usr2.DelegatedApproverId = usr4.Id;
            usr2.ManagerId = usr6.Id;
            usr12.ManagerId = usr2.Id;
            
            update usr2;            
            update usr12;            
            
            //PermissionSet retailaccMngrPerSet = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
            //PermissionSet retailaccMngrPerSet1 = [select id from PermissionSet where name='Core_MDF_CCP_External_Activity_Approver'];
            //Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr10.id,accountManager.id,true);
            //Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr12.id,retailaccMngrPerSet.id,true);
            //Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr11.id,retailaccMngrPerSet1.id,true);
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr10.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Acct_Mgr'),true);
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr12.id,psetMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager'),true);
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr11.id,psetMap.get('Core_MDF_CCP_External_Activity_Approver'),true);
            //Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr11.id,psetMap.get('Core_MDF_CCP_External_RMF_Activity_Approver'),true);
                        
            // Creating Group Member
            List<GroupMember> grpMemList = new List<GroupMember>();
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr9.Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            grpMemList.add(ccfGrpMem);
            
            GroupMember ccfGrpMem1 = new GroupMember();
            ccfGrpMem1.UserOrGroupId = usr11.Id;
            ccfGrpMem1.GroupId = ccfAPJGrp1.Id;
            grpMemList.add(ccfGrpMem1);
            insert grpMemList;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_MDF_Ext_CCF_APJ';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = ccfAPJGrp1.Id;                
            pgm.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgm.Core_MDF_Source_Txt__c = 'Test';
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'_Core_MDF_Ext_CCF_APJ';
            pgmList.add(pgm); 
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'Internal';
            pgm1.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_CCP_CCF_Internal';
            pgmList.add(pgm1);
            //Database.insert(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc1Retail.Id;
            pgm2.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm2.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            pgm2.Core_MDF_AccountIdGroupName__c = acc1Retail.Id+'Core_CCP_Retail_Internal';
            pgmList.add(pgm2);
            
            Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1Retail.Id,'Internal',accRetail.Id,cpRetail.Id,'PGM_Retail_TEST',true);

            
            //Manasa
            Test.startTest();
      
            System.debug('SB - SOQL Before PGM Insert: ' + Limits.getQueries());
            Database.insert(pgmList);
            System.debug('SB - SOQL After PGM Insert: ' + Limits.getQueries());
            
            // Creating Criterias for approval required
            List<Core_MDF_Criteria__c> criteriaList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                                  'Core_MDF_Channel_Partner_Led__c','Equal','true','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                                                                                  'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            
            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLevel',
                                                                                       'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                                                                                       'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','2-in-1','RequestedAmount','Greater Than','0',false);
            criteriaList.add(cr);
            criteriaList.add(crMulti);
            System.debug('SB - SOQL Before Criteria List Insert: ' + Limits.getQueries());
            insert criteriaList;
            System.debug('SB - SOQL After Criteria List Insert: ' + Limits.getQueries());
            
            // Creating 6 approvers for activity which are not qualified for auto approval
            List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_2__c = usr2.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr7.Id;
            ap1.Core_MDF_Approver_5__c = usr8.Id;
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap1);
            
            Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usr1.Id, false);
            ap1Retail.Core_MDF_Approver_2__c = usr2.Id;
            ap1Retail.Core_MDF_Approver_3__c = usr6.Id;
            ap1Retail.Core_MDF_Approver_4__c = usr7.Id;
            ap1Retail.Core_MDF_Approver_5__c = usr8.Id;
            ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap1Retail);
            
            Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr3.Id, false);
            ap2.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap2);
            
            Core_MDF_Approver__c ap3 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr4.Id, false);
            ap3.Core_MDF_Approver_2__c = usr5.Id;
            ap3.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap3);
            System.debug('SB - SOQL Before Approver Insert: ' + Limits.getQueries());
            insert approverList;
            System.debug('SB - SOQL After Approver List Insert: ' + Limits.getQueries());
            
            List<Core_MDF_Approver__c>  apprList = new List<Core_MDF_Approver__c>();
            // Creating Criteria rules for approvers
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_End_Date__c','Less Than',
                                                                                               String.valueOf(System.today().addDays(2)),true);
            
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'RequestedAmount','Less Than or Equal',
                                                                                               '8000',true);
            
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Brand__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',true);
            
            Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Brand__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',true);
            
            Core_MDF_Criteria_Rule__c crule5 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'RequestedAmount','Equal','9000',true);
            
            Core_MDF_Criteria_Rule__c crule6 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Creator',true);
            
            Core_MDF_Criteria_Rule__c crule7 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'RequestedAmount','Equal','16000',true);
            
            Core_MDF_Criteria_Rule__c crule8 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_Brand__c','Equal',
                                                                                               'Intel® Core™ i9 Processor',true);
            
            Core_MDF_Criteria_Rule__c crule9 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Small Business',true);
            System.debug('SB - SOQL After Criteria Rule Insert: ' + Limits.getQueries());
            
            //Manasa            
            ap1.Core_MDF_Active__c = True;
            //Database.update(ap1);
            ap2.Core_MDF_Active__c = True;
            //Database.update(ap2);
            ap3.Core_MDF_Active__c = True;
            //Database.update(ap3);
            
            apprList.add(ap1);
            apprList.add(ap2);
            apprList.add(ap3);
            Database.update(apprList);
            
            
            cr.Core_MDF_Active__c = True;
            Database.update(cr);           
            
            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                                'Retail Marketing Funds',true);
            
            Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than',
                                                                                                '0',true);
            
            Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                                'Pending Review',true);
            ap1Retail.Core_MDF_Active__c = True;
            Database.update(ap1Retail);
            crMulti.Core_MDF_Active__c = True;
            Database.update(crMulti);
            System.debug('SB - SOQL After Criteria Rule 398 Insert: ' + Limits.getQueries());
            
            // Creating campaigns using utility class
            //opal camp
           
            
            List<Campaign> campList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                                                                        System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', false);
            //camp.Core_MDF_Supports_legacy_program__c = 'Yes';            
            campList.add(camp);
            
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                                                                        System.today().addYears(1), 2000000000, 'Unite', acc.Id,'2-in-1', false);
            //MDFcamp.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            MDFcamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            MDFcamp.Core_MDF_Flexible_Budget__c = 10;
            MDFcamp.Core_MDF_Flexible_Reimbursement_Rate_Pct__c = '50%';  
            campList.add(MDFcamp);
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today(), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            //camp1.Core_MDF_Supports_legacy_program__c = 'Yes';
            campList.add(camp1);
            
            
             /*Campaign camp2 = Core_MDF_CCP_TestDataUtility.createOpalCampaign('TestOpalCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                                                                        System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', false);
            campList.add(camp2);*/
            
            Campaign camp3 = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','Intel® 11ᵗʰ Gen', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                         'Retail Marketing Funds', System.today(), System.today().addDays(2), 
                                                                         10000, 'Instore innovation', accRetail.Id,'Desktop', false);
            //camp3.Core_MDF_Supports_legacy_program__c = 'Yes'; 
            camp3.Core_MDF_Budget_Type_txt__c ='RSA MD';
            camp3.Core_MDF_Activity_Category_Type__c =null;
            camp3.Core_MDF_Reimbursement_Rate__c='100%';
            camp3.Core_MDF_Technology__c = 'ACPC';
            campList.add(camp3);
            
            
            insert campList;  
            
      System.debug('SB - SOQL After Campaign Insert: ' + Limits.getQueries());
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            // Create PMB for the above Account 
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            String retailBudgetRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
            PartnerMarketingBudget retailbudget = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget retailbudgetMD = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget MD',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
            PartnerMarketingBudget opalbudgetMDF1 = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB1',recordTypeIdPMB,acc.Id,cp.Id,1000,System.today().addDays(16),System.today().addDays(30),false);

            //pmbRecord.IsIgnoreValidation = true;
            opalbudgetMDF.Core_MDF_Budget_Type__c='MDF';
            opalbudgetMDF1.Core_MDF_Budget_Type__c='MDF';
            pmbRecord.Core_MDF_Budget_Type__c='CCF 1.0';
            retailBudget.Core_MDF_Budget_Type__c = 'Retail MDF';
            retailbudgetMD.Core_MDF_Budget_Type__c = 'RSA MD';

            budgetList.add(pmbRecord);
            budgetList.add(retailbudget);
            budgetList.add(retailbudgetMD);
            budgetList.add(opalbudgetMDF);
            budgetList.add(opalbudgetMDF1);
            insert budgetList;
            
            List<Core_MDF_Campaign_Budgets__c> campBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
            Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Budget_Name_Id__c = opalbudgetMDF.id;
            campBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
            campBudget.Core_MDF_Budget_Amt__c=363636;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget.Core_MDF_Reimbursement_Amt__c= 200000;
            campBudget.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget);
            
            Core_MDF_Campaign_Budgets__c campBudget1 = new Core_MDF_Campaign_Budgets__c();
            campBudget1.Core_MDF_Budget_Name_Id__c = opalbudgetMDF1.id;
            campBudget1.Core_MDF_Campaign_Id__c=MDFcamp.id;
            campBudget1.Core_MDF_Budget_Amt__c=2000;
            campBudget1.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget1.Core_MDF_Reimbursement_Amt__c= 2000;
            campBudget.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget1);
            
            insert campBudgetList;
                            
      System.debug('SB - SOQL After Budget Insert: ' + Limits.getQueries());
            
            // Create PFA records for the above accounts :
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 1234,false);        
            PartnerFundAllocation pfaRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA1',pmbRecord, acc, 12345, false);
            PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, acc, 12345, false);   
            PartnerFundAllocation pfaRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudgetMDF, acc, 12345, false);
            
            pfaList.add(pfaRecord);
            pfaList.add(pfaRecord1);
            pfaList.add(pfaRecord2);
            pfaList.add(pfaRecord3);
            insert pfaList;
      System.debug('SB - SOQL After PFA Insert: ' + Limits.getQueries());
            
            list<PartnerFundRequest> listPRFToBeInserted = new list<PartnerFundRequest>();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.RequestedAmount = 6000;
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            //Database.insert(pfr);

           
            //Creating partner fund request
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord1,pmbRecord,'INDIA','Creator','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr1.Title = 'Test Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Activity1';
            pfr1.Core_MDF_Start_Date__c = System.today();
            pfr1.Core_MDF_End_Date__c = System.today();
            pfr1.RequestedAmount = 9000;
            pfr1.Core_MDF_Channel_Partner_Led__c = True;
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr1);
            
            //Creating partner fund request
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                            'Intel® Core™ i9 Processor','Broadcast','Radio','Draft',false);
            pfr2.Title = 'Test Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
            pfr2.Core_MDF_Start_Date__c = System.today();
            pfr2.Core_MDF_End_Date__c = System.today();
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr2);
            
            //Creating partner fund request
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr5.Title = 'Test Activity5';
            pfr5.Core_MDF_Activity_Description__c = 'Test Activity5';
            pfr5.Core_MDF_Start_Date__c = System.today();
            pfr5.Core_MDF_End_Date__c = System.today();
            pfr5.RequestedAmount = 16000;
            pfr5.Core_MDF_Channel_Partner_Led__c = True;
            pfr5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr5);
            
            //Creating partner fund request
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr6.Title = 'Test Activity6';
            pfr6.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr6.Core_MDF_Start_Date__c = System.today();
            pfr6.Core_MDF_End_Date__c = System.today();
            pfr6.RequestedAmount = 16000;
            pfr6.Core_MDF_Channel_Partner_Led__c = False;
            pfr6.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr6);
            
            //Creating partner fund request with Modified by Account Manager
            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr7.Title = 'Test Activity7';
            pfr7.Core_MDF_Activity_Description__c = 'Test Activity7';
            pfr7.Core_MDF_Start_Date__c = System.today();
            pfr7.Core_MDF_End_Date__c = System.today();
            pfr7.RequestedAmount = 16000;
            pfr7.Core_MDF_Channel_Partner_Led__c = False;
            pfr7.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr7.LastModifiedById = usr10.id; 
            
            //Creating partner fund request
            PartnerFundRequest pfr8 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord1,pmbRecord,'INDIA','Creator','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr8.Title = 'Test Activity8';
            pfr8.Core_MDF_Activity_Description__c = 'Test Activity8';
            pfr8.Core_MDF_Start_Date__c = System.today();
            pfr8.Core_MDF_End_Date__c = System.today();
            pfr8.RequestedAmount = 9000;
            pfr8.OwnerId = usr1.Id;
            pfr8.Core_MDF_Channel_Partner_Led__c = True;
            pfr8.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
           /* PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false);      */
            
            PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            testPartnerFundRequest.Title ='Retail RSA MD Activity';
            testPartnerFundRequest.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
            testPartnerFundRequest.Core_MDF_Budget_Type_nm__c ='RSA MD';
            testPartnerFundRequest.RequestedAmount =1000;
            testPartnerFundRequest.Amount=1000;
            testPartnerFundRequest.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            testPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest.Core_MDF_Budget_Currency_cd__c ='USD';
            testPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c='100%';
            
            /*PartnerFundRequest testPartnerFundRequest1 =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'United Kingdom','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false);
            */
            PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            testPartnerFundRequest1.RequestedAmount =1000;
            testPartnerFundRequest1.Amount=1000;
            //testPartnerFundRequest1.Core_MDF_Country__c ='United Kingdom';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'United Kingdom';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            
            
             // Creating activities using utility class
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr.Title = 'Test Activity';
            MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr.Core_MDF_Start_Date__c = System.today();
            MDFpfr.Core_MDF_End_Date__c = System.today();
            MDFpfr.RequestedAmount = 6000;
            MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
            MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            // Creating activities using utility class
            PartnerFundRequest MDFpfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr1.Title = 'Test Activity';
            MDFpfr1.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr1.Core_MDF_Start_Date__c = System.today();
            MDFpfr1.Core_MDF_End_Date__c = System.today();
            MDFpfr1.RequestedAmount = 6000;
            MDFpfr1.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr1.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr1.Core_MDF_Approval_Step_Completed__c = 2;
            MDFpfr1.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr1.Core_MDF_Program_Office_Check_ind__c = True;
            MDFpfr1.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr1.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            // Creating activities using utility class
            PartnerFundRequest MDFpfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr2.Title = 'Test Activity';
            MDFpfr2.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr2.Core_MDF_Start_Date__c = System.today();
            MDFpfr2.Core_MDF_End_Date__c = System.today();
            MDFpfr2.RequestedAmount = 6000;
            MDFpfr2.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr2.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr2.Core_MDF_Approval_Step_Completed__c = 3;
            MDFpfr2.Core_MDF_Price_reviewer_check_ind__c = True; 
            //MDFpfr2.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr2.Core_MDF_Require_Additional_Review_ind__c = True;
        	MDFpfr2.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            // Creating activities using utility class
            PartnerFundRequest MDFpfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr3.Title = 'Test Activity';
            MDFpfr3.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr3.Core_MDF_Start_Date__c = System.today();
            MDFpfr3.Core_MDF_End_Date__c = System.today();
            MDFpfr3.RequestedAmount = 6000;
            MDFpfr3.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr3.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr3.Core_MDF_Approval_Step_Completed__c = 5;
            MDFpfr3.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr3.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr3.Core_MDF_Require_Additional_Review_ind__c = True;
			MDFpfr3.Core_MDF_Reimbursement_Rate_txt__c = '55%';

            
            // Creating activities using utility class
            PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr4.Title = 'Test Activity';
            MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr4.Core_MDF_Start_Date__c = System.today();
            MDFpfr4.Core_MDF_End_Date__c = System.today();
            MDFpfr4.RequestedAmount = 6000;
            MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
            MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False;
        	MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
             PartnerFundRequest MDFpfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr5.Title = 'Test Activity';
            MDFpfr5.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr5.Core_MDF_Start_Date__c = System.today().addDays(17);
            MDFpfr5.Core_MDF_End_Date__c = System.today().addDays(17);
            MDFpfr5.RequestedAmount = 60000;
            MDFpfr5.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr5.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr5.Core_MDF_Approval_Step_Completed__c = 0;
            MDFpfr5.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr5.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr5.Core_MDF_Require_Additional_Review_ind__c = False;
        	MDFpfr5.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            
            
            listPRFToBeInserted.add(MDFpfr); 
            listPRFToBeInserted.add(MDFpfr1); 
            listPRFToBeInserted.add(MDFpfr2); 
            listPRFToBeInserted.add(MDFpfr3);
            listPRFToBeInserted.add(MDFpfr5);
            listPRFToBeInserted.add(MDFpfr4); 
            
            listPRFToBeInserted.add(pfr);            
            listPRFToBeInserted.add(pfr1);
            listPRFToBeInserted.add(pfr2);
            listPRFToBeInserted.add(pfr5);
            listPRFToBeInserted.add(pfr6);
            listPRFToBeInserted.add(pfr7);
            listPRFToBeInserted.add(pfr8);
            listPRFToBeInserted.add(testPartnerFundRequest);
            listPRFToBeInserted.add(testPartnerFundRequest1);
            System.debug('SB - SOQL Before PFR Insert: ' + Limits.getQueries());
            Database.insert(listPRFToBeInserted);
      System.debug('SB - SOQL After PFR Insert: ' + Limits.getQueries());
            
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
      System.debug('SB - SOQL After Currency Exchange Rate Insert: ' + Limits.getQueries());
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1Retail.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active'; 
            bank.Core_MDF_Intel_Company_Code__c = '150';
            bank.Core_MDF_Tax_codes_cd__c = 'I0';
            system.debug('bank' +bank);
            Database.insert(bank);  
      System.debug('SB - SOQL After Bank Insert: ' + Limits.getQueries());
            
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accRetail.Id,bank.Id,true);
      System.debug('SB - SOQL After ABM Insert: ' + Limits.getQueries());
            //Manasa - putting on top
            //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1Retail.Id,'Internal',accRetail.Id,cpRetail.Id,'PGM_Retail_TEST',true);
            
            
            Test.stopTest();
            
      System.debug('SB - SOQL After PGM Insert: ' + Limits.getQueries());
      
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRetail.Id, usr11.Id, true);
            System.debug('SB - SOQL After PNUM Insert: ' + Limits.getQueries());
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            // Assigning internal ccf acc mgr permission set to usr1
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = usr1.Id);
            Database.insert(psa1);
            
            //pfr8.OwnerId = usr2.Id;
            //Database.update(pfr8);
            
          //  Test.stopTest();
          
            
            Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
            
            List<Core_Trigger_Executions__c> customSetting= new List<Core_Trigger_Executions__c>();
            
            List<Core_Trigger_Executions__c> executionAdjRequest = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c adjustmentRequestClaimTriggerExecution = new Core_Trigger_Executions__c();
            adjustmentRequestClaimTriggerExecution.Core_Active__c = true;
            adjustmentRequestClaimTriggerExecution.Core_Class_Name__c = 'Core_MDF_AdjustmentReq_ServiceHandler';
            adjustmentRequestClaimTriggerExecution.Core_Trigger_Events__c = 'before insert';
            adjustmentRequestClaimTriggerExecution.Core_Object__c = 'Core_MDF_Adjustment_Request__c';
            adjustmentRequestClaimTriggerExecution.Name = 'createAdjustment';
            adjustmentRequestClaimTriggerExecution.Core_Description__c = 'Negative claim is getting created from Adustemt Request';
            
            //executionAdjRequest.add(adjustmentRequestClaimTriggerExecution);
            
            
            //Manasa
            
            customSetting.add(adjustmentRequestClaimTriggerExecution);
            //Database.insert(executionAdjRequest);
            
            
            
            System.debug('SB - SOQL After PGM Insert: ' + Limits.getQueries());
            
            Core_Trigger_Executions__c setting1 = new Core_Trigger_Executions__c();
            setting1.Core_Active__c = True;
            setting1.Core_Class_Name__c = 'Core_MDF_PFR_TriggerServiceHandler';
            setting1.Core_Description__c = 'Validate Activity against active claims';
            setting1.Core_Object__c = 'PartnerFundRequest';
            setting1.Core_Trigger_Events__c = 'Before Update';
            setting1.name = 'Core_MDF_ActivityClaimsValidation';
            
            Core_Trigger_Executions__c setting2 = new Core_Trigger_Executions__c();
            setting2.Core_Active__c = True;
            setting2.Core_Class_Name__c = 'Core_MDF_PFR_TriggerServiceHandler';
            setting2.Core_Description__c = 'Validates Activity Amount with claim';
            setting2.Core_Object__c = 'PartnerFundRequest';
            setting2.Core_Trigger_Events__c = 'Before Update';
            setting2.name = 'Core_MDF_ActivityAmountValidation';
            
            Core_Trigger_Executions__c setting3 = new Core_Trigger_Executions__c();
            setting3.Core_Active__c = True;
            setting3.Core_Class_Name__c = 'Core_MDF_PFR_TriggerServiceHandler';
            setting3.Core_Description__c = 'Activity Date Range must comply with claims date range';
            setting3.Core_Object__c = 'PartnerFundRequest';
            setting3.Core_Trigger_Events__c = 'Before Update';
            setting3.name = 'Core_MDF_ActivityDateValidation';
            
            customSetting.add(setting1);
            customSetting.add(setting2);
            customSetting.add(setting3);
            
            insert customSetting;
      System.debug('SB - SOQL After Setup: ' + Limits.getQueries());
            //ProcessInstance pi = [SELECT Id, TargetObjectId,(SELECT Id FROM Workitems) FROM ProcessInstance where TargetObjectId =: pfr1.Id];      
            //System.debug('pi Workitems: '+pi.Workitems);
            
            
            //IPA Data
        /*    ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);    
            Account ipaUltimateAccountPFR = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account PFR',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccountPFR.Core_MDF_Channel_Program__c = ipaCP.Id;
            insert(ipaUltimateAccountPFR);
           // Id PAG_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();    
            List<Account> accList = new List<Account>();
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);           
            Account ipaCoMarketingAccount1 = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR2', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
        ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount1.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccountPFR.Id;
            //create PAG Acct and link to intel acct:ipaUltimateAccountPFR
           //Account pagAccount = new Account(Name='IPA PAG Account PFR', RecordTypeId=PAG_Account_Record_Type,Core_IPA_One_Partner_Id__c=ipaUltimateAccountPFR.id);           
            accList.add(ipaCoMarketingAccount);
            accList.add(ipaCoMarketingAccount1);
           //accList.add(pagAccount);
            Database.insert(accList);
           Test.stopTest();*/
            /*
          List<Contact> conList = new List<Contact>();
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccountPFR.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (ipaUltimateAccountPFR.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            Database.insert(conList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            List<User> usrList = new List<User>();
            User extUsr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr1.LastName = 'User Test1';
            extUsr1.ProfileId = partnerProfile.Id;
            extUsr1.ContactId = con.Id;
            extUsr1.IsActive = TRUE;
            usrList.add(extUsr1);
            User extUsr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr2.LastName = 'User Test2';
            extUsr2.ProfileId = partnerProfile.Id;
            extUsr2.ContactId = con1.Id;
            extUsr2.IsActive = TRUE;
            usrList.add(extUsr2);
            Database.insert(usrList);
            
            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_MDF_CCP_External_IPA_Proposal_Manager'];
            //insert new PermissionSetAssignment(AssigneeId = extUsr1.Id, PermissionSetId = pSet.id);
            
            List<PermissionSetAssignment>permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            PermissionSetAssignment psaIPA1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr1.Id);
            permissionSetAssignmentList.add(psaIPA1);
            PermissionSetAssignment psaIPA2 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = extUsr2.Id);
            permissionSetAssignmentList.add(psaIPA2);            
            insert permissionSetAssignmentList;
            
            
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            
            Core_AGS_Role__c agsRoleIPA = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_USER', 'Co-Marketing(Salesforce)-IPA USER', true, true);
            
            Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('Intel Partner Alliance', 'IPA', '', '', true, true);
            
            Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleIPA.Id ,'Intel Partner Alliance (IPA)','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',true);
            
            List<Core_Contact_Entitlement__c> conEntList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c contactEntitlementIPA1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA1);
            Core_Contact_Entitlement__c contactEntitlementIPA2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con1.Id,entitlementIPA.Id ,true,'Complete', false);            
            conEntList.add(contactEntitlementIPA2);
            Database.insert(conEntList);
            
            // Creating Group
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            Group ipaExtGrp1 = new Group();
            ipaExtGrp1.Name = 'Core CCP IPA External1';
            ipaExtGrp1.DeveloperName = 'Core_MDF_CCP_IPA_External1';
            grpList.add(ipaExtGrp1);
            Database.insert(grpList);
            
            // Creating Group Member
            List<GroupMember> ipaGrpMemList = new List<GroupMember>();
            GroupMember ipaExtGrpMem1 = new GroupMember();
            ipaExtGrpMem1.UserOrGroupId = extUsr1.Id;
            ipaExtGrpMem1.GroupId = ipaExtGrp.Id;
            ipaGrpMemList.add(ipaExtGrpMem1);
            
            GroupMember ipaExtGrpMem2 = new GroupMember();
            ipaExtGrpMem2.UserOrGroupId = extUsr2.Id;
            ipaExtGrpMem2.GroupId = ipaExtGrp.Id;
            ipaGrpMemList.add(ipaExtGrpMem2);
            Database.insert(ipaGrpMemList);
            
            List<Core_MDF_Partner_Group_Mapping__c> ipaPgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgmExt = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt.Core_MDF_Account__c = ipaUltimateAccountPFR.Id;
            pgmExt.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgmExt.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt.Core_MDF_Group_Id__c = ipaExtGrp.Id;                
            pgmExt.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmExt.Core_MDF_Source_Txt__c = 'Test';
            pgmExt.Core_MDF_Region_cd__C = 'APJ';
            pgmExt.Core_MDF_AccountIdGroupName__c = ipaUltimateAccountPFR.Id+'Core_MDF_CCP_IPA_External';
            ipaPgmList.add(pgmExt);
            Core_MDF_Partner_Group_Mapping__c pgmExt1 = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt1.Core_MDF_Account__c = ipaUltimateAccountPFR.Id;
            pgmExt1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External1';
            pgmExt1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt1.Core_MDF_Group_Id__c = ipaExtGrp1.Id;                
            pgmExt1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgmExt1.Core_MDF_Source_Txt__c = 'Test';
            pgmExt1.Core_MDF_Region_cd__C = 'APJ';
            pgmExt1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccountPFR.Id+'Core_MDF_CCP_IPA_External1';
            ipaPgmList.add(pgmExt1);
            Database.insert(ipaPgmList);
            
            
            Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> accIdSet1 = new Set<Id>();
            accIdSet.add(ipaCoMarketingAccount.Id);
            accIdSet1.add(ipaCoMarketingAccount1.Id);
            userIdCorpAcctIdSet.put(extUsr1.Id, accIdSet);
            userIdCorpAcctIdSet.put(extUsr2.Id, accIdSet);
            Core_MDF_IPA_AccountUserMapping.createPnumRecords(userIdCorpAcctIdSet);
            
            //Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ipaCoMarketingAccount.Id,extUsr1.Id,true);
            
            List<User> ipaUserList = new List<User>();            
            // Creating Users with utility class 
            User ipaUsr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaUsr1.LastName = 'User Test1';
            ipaUserList.add(ipaUsr1);
            
            User ipaUsr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaUsr2.LastName = 'User Test2';
            ipaUserList.add(ipaUsr2);

            Database.insert(ipaUserList);
            
            // Creating Group
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
            
            // Creating Group Member
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = ipaUsr1.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            Database.insert(ipaGrpMem);
            
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c ipaPgm1 = new Core_MDF_Partner_Group_Mapping__c();
            ipaPgm1.Core_MDF_Account__c = ipaUltimateAccountPFR.Id;
            ipaPgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            ipaPgm1.Core_MDF_Type_of_Access__c = 'INTERNAL';
            ipaPgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            ipaPgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            ipaPgm1.Core_MDF_Source_Txt__c = 'Test';
            ipaPgm1.Core_MDF_Region_cd__C = 'APJ';
            ipaPgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccountPFR.Id+'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaPgm1);
            //Test.stopTest();            
            
            // Creating Criterias for approval required
            Core_MDF_Criteria__c ipaCr = Core_MDF_CCP_TestDataUtility.createCriteria('Campaign','Core_MDF_IPA_Proposal_AP',
                                                                                  'Core_MDF_Program__c','Equal','Intel Partner Alliance','','', '',
                                                                                  '','','','','','','','','',true);
            
            // Creating Approvers
            List<Core_MDF_Approver__c> ipaapproverList = new List<Core_MDF_Approver__c>();
            Core_MDF_Approver__c ipaAp1 = Core_MDF_CCP_TestDataUtility.createApprover(ipaCr.Id,ipaUsr1.Id, false);
            ipaAp1.Core_MDF_Approver_Type__c = 'Internal';
            ipaapproverList.add(ipaAp1);
            Core_MDF_Approver__c ipaAp2 = Core_MDF_CCP_TestDataUtility.createApprover(ipaCr.Id,ipaUsr2.Id, false);
            ipaAp2.Core_MDF_Approver_Type__c = 'Internal';
            ipaapproverList.add(ipaAp2);
            Database.insert(ipaapproverList);
            
            List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
            // Creating Criteria rules for approvers
            Core_MDF_Criteria_Rule__c ipaCrule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ipaAp1.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Equal',
                                                                                               '0',false);
            
            Core_MDF_Criteria_Rule__c ipaCrule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ipaAp2.Id,'Core_MDF_Approval_Step_Counter_nbr__c','Greater Than or Equal',
                                                                                               '1',false);
            
            Core_MDF_Criteria_Rule__c ipaCrule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ipaAp2.Id,'Core_MDF_Brand__c','Less Than or Equal',
                                                                                               '2',false);
            
            crList.add(ipaCrule1); crList.add(ipaCrule1); crList.add(ipaCrule1);
            Database.insert(crList);
            
            List<Core_MDF_Approver__c> toBeUpdatedAP = new List <Core_MDF_Approver__c>();
            ipaAp1.Core_MDF_Active__c = True;
            toBeUpdatedAP.add(ipaAp1);
            ipaAp2.Core_MDF_Active__c = True;
            toBeUpdatedAP.add(ipaAp2);
            Database.update(toBeUpdatedAP);
            
            ipaCr.Core_MDF_Active__c = True;
            Database.update(ipaCr); */
            
            
            
        }
    }  
    /****************************************************************************************************************************************
Method Name:                                   testSharingForClosedActivity
Description:                                   Created for testing custom approval process for PartnerFundRequest Object
Added By:                                      Accenture – NZ
Modified By:                  Date:            Changes: 
Accenture – NZ                Created.
*****************************************************************************************************************************************/
    @isTest static void testSharingForClosedActivity(){
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        System.runAs(user){
            Test.startTest();
            
            
            // 1. Create an UK Activity.
            PartnerFundRequest pfr = [SELECT id,Title,Core_MDF_Country_nm__c FROM PartnerFundRequest where Title = 'Retail MDF Activity' LIMIT 1];
            List<PartnerFundRequestShare> pfrShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                          FROM PartnerFundRequestShare 
                                                          WHERE parentId = :pfr.Id];
            Boolean apjGrpShare = false;
            // 2. Put an Assert statement to check on the sharing for EMEA Group.
            for(PartnerFundRequestShare shareRec : pfrShareList)
            {
                if(shareRec.UserOrGroup.Name == 'Core_MDF_Retail_Grp'){
                    apjGrpShare = true;
                }
            }
            if(apjGrpShare){
                System.assert(apjGrpShare);
            }
            // 3. Close that Activity.
            pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfr.Core_MDF_Activity_Closure_Type__c = 'No Internal Approval';
            update pfr;
            for(PartnerFundRequestShare shareRec : pfrShareList)
            {
                if(shareRec.UserOrGroup.Name == 'Core_MDF_Retail_Grp'){
                    apjGrpShare = true;
                }
            }
            if(apjGrpShare){
                System.assert(apjGrpShare);
            }
            // 4. Put an Assert statement to check on the sharing for EMEA Group.
            pfrShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                            FROM PartnerFundRequestShare 
                            WHERE parentId = :pfr.Id];
            
            // 5. Update the Country for that Activity to US. UserOrGroup.Name LIKE '%EMEA%'
            pfr.Core_MDF_Country_nm__c = 'United States';
            // 6. Put an Assert statement to check on the sharing for ASMO Group.
            pfrShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                            FROM PartnerFundRequestShare 
                            WHERE parentId = :pfr.Id];
            for(PartnerFundRequestShare shareRec : pfrShareList)
            {
                if(shareRec.UserOrGroup.Name == 'Core_MDF_Retail_Grp'){
                    apjGrpShare = true;
                }
            }
            if(apjGrpShare){
                System.assert(apjGrpShare);
            }
            Test.stopTest();
        }
    }
    @isTest
    static void OpalActivityTest(){
    Test.startTest();
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
    
    Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        //pfaRecord3,opalbudgetMDF
    PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
    PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        // Creating activities using utility class
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = System.today();
        MDFpfr4.Core_MDF_End_Date__c = System.today();
        MDFpfr4.RequestedAmount = 60000;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        //MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Approval_Step_Completed__c = 5;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = false;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = false;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = false;
       // MDFpfr4.Core_MDF_Activity_Reimbursement_Amt_nbr__c = 1000;
        //MDFpfr4.Core_MDF_Ultimate_Account_Name__c ='Test Account 1';
        database.insert(MDFpfr4);
        //Core_MDF_ProcessCCP_PartnerFundRequest.updateApprovers(null, null);
       
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.update(MDFpfr4);
        
       
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
		//Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess(pfrMap,pfrList,sObjectList,emeaSubmission);
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.update(MDFpfr4);
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        Set<String> accStrSet = new Set<String>();
        Set<String> perSetStr = new Set<String>();
        accStrSet.add('Test Account 1');
        perSetStr.add(Label.Core_MDF_CCF_Marketing_Owner);
        //Core_MDF_ProcessCCP_PartnerFundRequest.notifyInternalApprovers(pfrList,accStrSet,perSetStr);
        sObjectList.add(pfr);
		//Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess(pfrMap,pfrList,sObjectList,emeaSubmission);
    Test.stopTest();
        System.assertEquals(true, MDFpfr4!=null);
    }
    
    /*
     @isTest
    static void OpalActivityTest2(){
    Test.startTest();
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
    
    Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
    PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestPMB'];
    PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA'];
        // Creating activities using utility class
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = System.today();
        MDFpfr4.Core_MDF_End_Date__c = System.today();
        MDFpfr4.RequestedAmount = 6000;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False;    
        database.insert(MDFpfr4);
        
        Map<Id, Id> pfrIdAccountIdMap = new Map<Id, Id>();
        pfrIdAccountIdMap.put(MDFpfr4.Id,acc.Id);
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.put(MDFpfr4.Id,acc);
        
        Core_MDF_ProcessCCP_PartnerFundRequest.deletePFRShare(pfrIdAccountIdMap,accountMap);
    Test.stopTest();
        System.assertEquals(true, MDFpfr4!=null);
    }*/
    
    
}