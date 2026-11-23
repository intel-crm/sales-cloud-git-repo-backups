@isTest(SeeAllData=false)
public class test_HT {

     @TestSetup static void createTestData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_DCF_Acct_Mgr']; //Core_MDF_CCP_Internal_DCF_Account_Manager
        
        Map<String, Id> psetMap = new Map<String, Id>();
        List<PermissionSet> prmsetlst = [select Id, Name from PermissionSet Where Name IN ('Core_MDF_CCP_Internal_DCF_Acct_Mgr', 'Core_MDF_CCP_Internal_Retail_Account_Manager', 'Core_MDF_CCP_External_Activity_Approver','Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr','Core_MDF_CCP_RMF_PRC_Claim_Operations')];
        for(PermissionSet pset : prmsetlst) {
            psetMap.put(pset.Name, pset.Id);
        }
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        User usrn1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrn1.LastName = 'User Testn1';
        usrn1.UserRoleId = usRole.Id;
        Database.insert(usrn1);
        
        User usrn2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrn2.LastName = 'User Testn2';
        usrn2.UserRoleId = usRole.Id;
        Database.insert(usrn2);
        
        System.runAs(usr){
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
             List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
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
            acc1Retail.Core_Sub_Geo__c = 'IJKK';
            accIntelList.add(acc1Retail);
            
            Account ipaUltimateAccountPFR = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account PFR',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
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
            accRetail.Core_Sub_Geo__c = 'IJKK';
            accCoMarketingList.add(accRetail);
            
            Account accRetail2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail2', cpRetail.Id,
                                                                             Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail2.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail2.Core_Geo__c = 'APJ';
            accRetail2.Core_Sub_Geo__c = 'IJKK';
            accCoMarketingList.add(accRetail2);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR', ipaCP.id, Core_MDF_CCP_TestDataUtility.account_Record_Type,false); 
            Account ipaCoMarketingAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccountPFR.id, true);           
            Account ipaCoMarketingAccount1 = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR2', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            //ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccountPFR.Id;
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
            conRecord1.MailingCountry = 'KOR';
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id,false);
            conRecord2.MailingCountry = 'KOR';
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
            
            User usr14 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr14.LastName = 'Test Opal User';
            userList.add(usr14);
            
            User usr15 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr15.LastName = 'Test PRC MS User';
            userList.add(usr15);
            
            insert userList;
            List<User> updateUser = new List<User>();
            usr2.DelegatedApproverId = usr4.Id;
            usr2.ManagerId = usr6.Id;
            usr12.ManagerId = usr2.Id;
            
            updateUser.add(usr2);
            updateUser.add(usr12);
            update updateUser;            
            
            
            List <PermissionSetAssignment> assignPermissionSetList = new List <PermissionSetAssignment>();
            PermissionSetAssignment assignPermissionSetObj1 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr15.id,psetMap.get('Core_MDF_CCP_RMF_PRC_Claim_Operations'),false);
            assignPermissionSetList.add(assignPermissionSetObj1);
            PermissionSetAssignment assignPermissionSetObj2 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr10.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Acct_Mgr'),false);
            assignPermissionSetList.add(assignPermissionSetObj2);
            PermissionSetAssignment assignPermissionSetObj3 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr12.id,psetMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager'),false);
            assignPermissionSetList.add(assignPermissionSetObj3);
            PermissionSetAssignment assignPermissionSetObj4 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr11.id,psetMap.get('Core_MDF_CCP_External_Activity_Approver'),false);
            assignPermissionSetList.add(assignPermissionSetObj4);
            PermissionSetAssignment assignPermissionSetObj5 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr14.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr'),false);
            assignPermissionSetList.add(assignPermissionSetObj5);
            PermissionSetAssignment assignPermissionSetObj6 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr14.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Acct_Mgr'),false);
            assignPermissionSetList.add(assignPermissionSetObj6);
            database.insert(assignPermissionSetList);
            
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
            
            System.debug('SB - SOQL Before PGM Insert: ' + Limits.getQueries());
            Database.insert(pgmList);
            System.debug('SB - SOQL After PGM Insert: ' + Limits.getQueries());
            
            // Creating Criterias for approval required
            List<Core_MDF_Criteria__c> criteriaList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                                  'Core_MDF_Channel_Partner_Led__c','Equal','true','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                                                                                  'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            
            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLvl_V5',
                                                                                       'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                                                                                       'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','2-in-1','RequestedAmount','Greater Than','0',false);
            criteriaList.add(cr);
            criteriaList.add(crMulti);
            System.debug('SB - SOQL Before Criteria List Insert: ' + Limits.getQueries());
            insert criteriaList;
            System.debug('SB - SOQL After Criteria List Insert: ' + Limits.getQueries());
            
            
            List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_2__c = usr2.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr7.Id;
            ap1.Core_MDF_Approver_5__c = usr8.Id;
            ap1.Core_MDF_Active__c=false;
            
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
            ap2.Core_MDF_Active__c=false;
            approverList.add(ap2);
            
            Core_MDF_Approver__c ap3 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr4.Id, false);
            ap3.Core_MDF_Approver_2__c = usr5.Id;
            ap3.Core_MDF_Active__c=false;
            ap3.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap3);
            System.debug('SB - SOQL Before Approver Insert: ' + Limits.getQueries());
            insert approverList;
            System.debug('SB - SOQL After Approver List Insert: ' + Limits.getQueries());
            
            List<Core_MDF_Approver__c>  apprList = new List<Core_MDF_Approver__c>();
            List <Core_MDF_Criteria_Rule__c> criteriaRuleList =  new List <Core_MDF_Criteria_Rule__c>();
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_End_Date__c','Less Than',
                                                                                               String.valueOf(System.today().addDays(2)),true);
            criteriaRuleList.add(crule1);
            
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'RequestedAmount','Less Than or Equal',
                                                                                               '8000',true);
            criteriaRuleList.add(crule2);
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Brand__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',true);
            criteriaRuleList.add(crule3);
            Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',true);
            criteriaRuleList.add(crule4);
            Core_MDF_Criteria_Rule__c crule5 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'RequestedAmount','Equal','9000',true);
            criteriaRuleList.add(crule5);
            Core_MDF_Criteria_Rule__c crule6 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Creator',true);
            criteriaRuleList.add(crule6);
            Core_MDF_Criteria_Rule__c crule7 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'RequestedAmount','Equal','16000',true);
            criteriaRuleList.add(crule7);
            Core_MDF_Criteria_Rule__c crule8 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i9 Processor',true);
            criteriaRuleList.add(crule8);
            Core_MDF_Criteria_Rule__c crule9 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Small Business',true);
            criteriaRuleList.add(crule9);
            System.debug('SB - SOQL After Criteria Rule Insert: ' + Limits.getQueries());
            
            
            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                                'Retail Marketing Funds',true);
            criteriaRuleList.add(cruleR1);
            Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than',
                                                                                                '0',true);
            criteriaRuleList.add(cruleR2);
            Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                                'Pending Review',true);
            criteriaRuleList.add(cruleR3);
            
            ap1.Core_MDF_Active__c = True;
            ap2.Core_MDF_Active__c = True;
            ap3.Core_MDF_Active__c = True;
            apprList.add(ap1);
            apprList.add(ap2);
            apprList.add(ap3);
            Database.update(apprList);
            
            cr.Core_MDF_Active__c = True;
            //Database.update(cr);    
            
            ap1Retail.Core_MDF_Active__c = True;
            Database.update(ap1Retail);
            crMulti.Core_MDF_Active__c = True;
            // Database.update(crMulti);
            
            List<Campaign> campList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',Date.newInstance(2021, 01, 01) , 
                                                                        Date.newInstance(2021, 06, 29), 2000, 'Unite', acc.Id,'2-in-1', false); 
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'CCF 1.0'; 
            campList.add(camp);
            
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',Date.newInstance(2022, 01, 01) , 
                                                                           Date.newInstance(2022, 06, 06), 2000, 'Unite', acc.Id,'2-in-1', false); 
            campList.add(MDFcamp);
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-3), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            campList.add(camp1);
            
            Campaign camp3 = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','Intel® 11ᵗʰ Gen', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                         'Retail Marketing Funds', System.today(), System.today().addDays(2), 
                                                                         10000, 'Instore innovation', accRetail.Id,'Desktop', false);
            
            camp3.Core_MDF_Activity_Category_Type__c =null;
            camp3.Core_MDF_Reimbursement_Rate__c='100%';
            camp3.Core_MDF_Technology__c = 'ACPC';
            campList.add(camp3);
            
            
            insert campList;  
            
            System.debug('SB - SOQL After Campaign Insert: ' + Limits.getQueries());
            Core_Trigger_Executions__c coreTriggerExecution = new Core_Trigger_Executions__c();
            coreTriggerExecution.name='Bypass_MDF_Budget_Access';
            coreTriggerExecution.Core_Active__c = true;
            coreTriggerExecution.Core_Class_Name__c = 'Core_MDF_PMBTriggerHandler';
            coreTriggerExecution.Core_Description__c = 'To check whether budget creation access is bypassed or not';
            coreTriggerExecution.Core_Object__c = 'PartnerMarketingBudget';
            coreTriggerExecution.Core_Trigger_Events__c = 'Before Update,Before Insert';
            insert coreTriggerExecution;
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            Test.startTest();
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            String retailBudgetRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            PartnerMarketingBudget retailbudget = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget retailbudgetMD = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget MD',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            PartnerMarketingBudget opalbudgetMDF1 = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB1',recordTypeIdPMB,acc.Id,cp.Id,100000,System.today().addDays(16),System.today().addDays(30),false);
            PartnerMarketingBudget OEMPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestoemcmpPMB',recordTypeIdPMB,acc.Id,cp.Id,100000,System.today().addDays(16),System.today().addDays(30),false);
            
            
            OEMPMB.Core_MDF_Budget_Type__c='OEM CMP';
            opalbudgetMDF.Core_MDF_Budget_Type__c='MDF';
            opalbudgetMDF1.Core_MDF_Budget_Type__c='MDF';
            pmbRecord.Core_MDF_Budget_Type__c='CCF 1.0';
            retailBudget.Core_MDF_Budget_Type__c = 'Retail MDF';
            retailbudgetMD.Core_MDF_Budget_Type__c = 'RSA MD';
            
            OEMPMB.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            opalbudgetMDF.Core_MDF_Budget_Type_Txt__c='MDF';
            opalbudgetMDF1.Core_MDF_Budget_Type_Txt__c='MDF';
            pmbRecord.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            retailBudget.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            retailbudgetMD.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            
            budgetList.add(pmbRecord);
            budgetList.add(retailbudget);
            budgetList.add(retailbudgetMD);
            budgetList.add(opalbudgetMDF);
            budgetList.add(opalbudgetMDF1);
            budgetList.add(OEMPMB);
            
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
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 99999,false);        
            PartnerFundAllocation pfaRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA1',pmbRecord, acc, 99999, false);
            PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, acc, 99999, false);   
            PartnerFundAllocation pfaRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudgetMDF, acc, 99999, false);
            PartnerFundAllocation pfaRecord4 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA4',retailBudget, acc, 99999, false);
            
            pfaList.add(pfaRecord);
            pfaList.add(pfaRecord1);
            pfaList.add(pfaRecord2);
            pfaList.add(pfaRecord3);
            pfaList.add(pfaRecord4);
            insert pfaList;
            System.debug('SB - SOQL After PFA Insert: ' + Limits.getQueries());
            
            
            list<PartnerFundRequest> listPRFToBeInserted = new list<PartnerFundRequest>();
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr.RequestedAmount = 6000;
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord1,pmbRecord,'INDIA','Creator','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr1.Title = 'Test Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Activity1';
            pfr1.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr1.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr1.RequestedAmount = 9000;
            pfr1.Core_MDF_Channel_Partner_Led__c = True;
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                            'Intel® Core™ i9 Processor','Broadcast','Radio','Draft',false);
            pfr2.Title = 'Test Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
            pfr2.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr2.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr5.Title = 'Test Activity5';
            pfr5.Core_MDF_Activity_Description__c = 'Test Activity5';
            pfr5.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr5.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr5.RequestedAmount = 16000;
            pfr5.Core_MDF_Channel_Partner_Led__c = True;
            pfr5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr6.Title = 'Test Activity6';
            pfr6.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr6.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr6.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr6.RequestedAmount = 16000;
            pfr6.Core_MDF_Channel_Partner_Led__c = False;
            pfr6.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media','Cinema','Draft',false);
            pfr7.Title = 'Test Activity7';
            pfr7.Core_MDF_Activity_Description__c = 'Test Activity7';
            pfr7.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr7.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr7.RequestedAmount = 16000;
            pfr7.Core_MDF_Channel_Partner_Led__c = False;
            pfr7.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr7.LastModifiedById = usr10.id; 
            
            PartnerFundRequest pfr8 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord1,pmbRecord,'INDIA','Creator','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr8.Title = 'Test Activity8';
            pfr8.Core_MDF_Activity_Description__c = 'Test Activity8';
            pfr8.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr8.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr8.RequestedAmount = 9000;
            pfr8.OwnerId = usr1.Id;
            pfr8.Core_MDF_Channel_Partner_Led__c = True;
            pfr8.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
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
            testPartnerFundRequest1.AllocationId = pfaRecord4.Id;
            
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr.Title = 'Test Activity';
            MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr.RequestedAmount = 6000;
            MDFpfr.Amount = 6000;
            MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
            MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            PartnerFundRequest MDFpfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr1.Title = 'Test Activity';
            MDFpfr1.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr1.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr1.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr1.RequestedAmount = 6000;
            MDFpfr1.Amount = 6000;
            MDFpfr1.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr1.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr1.Core_MDF_Approval_Step_Completed__c = 2;
            MDFpfr1.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr1.Core_MDF_Program_Office_Check_ind__c = True;
            MDFpfr1.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr1.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            PartnerFundRequest MDFpfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr2.Title = 'Test Activity';
            MDFpfr2.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr2.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr2.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr2.RequestedAmount = 6000;
            MDFpfr2.Amount = 6000;
            MDFpfr2.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr2.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr2.Core_MDF_Approval_Step_Completed__c = 3;
            MDFpfr2.Core_MDF_Price_reviewer_check_ind__c = True; 
            MDFpfr2.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr2.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            
            PartnerFundRequest MDFpfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr3.Title = 'Test Activity';
            MDFpfr3.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr3.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr3.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr3.RequestedAmount = 6000;
            MDFpfr3.Amount = 6000;
            MDFpfr3.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr3.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr3.Core_MDF_Approval_Step_Completed__c = 5;
            MDFpfr3.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr3.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr3.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr3.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            
            
            PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr4.Title = 'Test Activity';
            MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr4.RequestedAmount = 6000;
            MDFpfr4.Amount = 6000;
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
            MDFpfr5.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr5.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr5.RequestedAmount = 60000;
            MDFpfr5.Amount = 6000;
            MDFpfr5.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr5.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr5.Core_MDF_Approval_Step_Completed__c = 0;
            MDFpfr5.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr5.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr5.Core_MDF_Require_Additional_Review_ind__c = False;
            MDFpfr5.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            MDFpfr5.AllocationId = pfaRecord.Id;
            
            
            listPRFToBeInserted.add(MDFpfr); 
            //listPRFToBeInserted.add(MDFpfr1); 
            //listPRFToBeInserted.add(MDFpfr2); 
            //listPRFToBeInserted.add(MDFpfr3);
            //listPRFToBeInserted.add(MDFpfr5);
            //listPRFToBeInserted.add(MDFpfr4); 
            
            listPRFToBeInserted.add(pfr);            
            listPRFToBeInserted.add(pfr1);
            //listPRFToBeInserted.add(pfr2);
            //listPRFToBeInserted.add(pfr5);
            listPRFToBeInserted.add(pfr6);
            //listPRFToBeInserted.add(pfr7);
            //listPRFToBeInserted.add(pfr8);
            listPRFToBeInserted.add(testPartnerFundRequest);
            listPRFToBeInserted.add(testPartnerFundRequest1);
            
            
            System.debug('SB - SOQL Before PFR Insert: ' + Limits.getQueries());
            System.runAs(usr){
            Database.insert(listPRFToBeInserted);
            }
            System.debug('SB - SOQL After PFR Insert: ' + Limits.getQueries());
            
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            System.debug('SB - SOQL After Currency Exchange Rate Insert: ' + Limits.getQueries());
            
            System.debug('SB - SOQL After PGM Insert: ' + Limits.getQueries());
            
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRetail.Id, usr11.Id, true);
            System.debug('SB - SOQL After PNUM Insert: ' + Limits.getQueries());
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            // Assigning internal ccf acc mgr permission set to usr1
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = usr1.Id);
            Database.insert(psa1);
            
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
            
            customSetting.add(adjustmentRequestClaimTriggerExecution);
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
            
            Core_Trigger_Executions__c setting4 = new Core_Trigger_Executions__c();
            setting4.Core_Active__c = True;
            setting4.Core_Class_Name__c = 'Core_MDF_ProcessCCP_PartnerFundRequest';
            setting4.Core_Description__c = 'Validate RMF Notifications';
            setting4.Core_Object__c = 'PartnerFundRequest';
            setting4.Core_Trigger_Events__c = 'After Update, After Insert';
            setting4.name = 'Core_MDF_RMFActivityEmailValidation';
            
            customSetting.add(setting1);
            customSetting.add(setting2);
            customSetting.add(setting3);
            customSetting.add(setting4);
            
            insert customSetting;
            test.stopTest();
            System.debug('SB - SOQL After Setup: ' + Limits.getQueries());
            
        }
    }  
    
     @isTest
    static void retailNotificatonTest(){
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList2 = new List<PartnerFundRequest>();
		List<PartnerFundRequest> pfrList3 = new List<PartnerFundRequest>();
        Set<ID> accIDSet = new Set<ID>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1];
        User user = [SELECT Id FROM User WHERE LastName = 'Test PRC MS User'];
        Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'TestRetailCamp'];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
        
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_RMF_PRC_Claim_Operations';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        Database.insert(iupgm);    
        
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(cmp.Id),string.valueof(acc.id),System.today(),System.today(),false); 
        pfr.Title ='Retail RSA MD Activity';
        pfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        pfr.RequestedAmount =1000;
        pfr.Amount=1000;
        pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Core_MDF_Budget_Currency_cd__c ='USD';
        pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        database.insert(pfr);
        pfrList.add(pfr);
        accIDSet.add(acc.id);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList,accIDSet);
         /*Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        pfrMap.put(pfr.id,pfr);
         PartnerFundRequest pfr1  = new PartnerFundRequest();
        List<SObject> sObjectList = new List<Sobject>();
        sObjectList.add(pfr1);
        Boolean emeaSubmission =false;*/
        //Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess(pfrMap,pfrList,sObjectList,emeaSubmission);
        
        pfr.Core_MDF_Approval_Step_Completed__c = 1;
        pfr.Core_MDF_Program_Office_Check_ind__c =false;
        pfr.Core_MDF_Price_reviewer_check_ind__c=false;
        pfr.Core_MDF_Require_Additional_Review_ind__c=false;  
        
        database.update(pfr);
        pfrList2.add(pfr);
        //accIDSet.add(acc.id);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList2,accIDSet);
        // Map<id,PartnerFundRequest> pfrMap2 = new Map<id,PartnerFundRequest>();
        //pfrMap2.put(pfr.id,pfr);
         
        PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(cmp.Id),string.valueof(acc.id),System.today(),System.today(),false); 
        pfr1.Title ='Retail RSA MD Activity';
        pfr1.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        pfr1.RequestedAmount =1000;
        pfr1.Amount=1000;
        pfr1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        pfr1.Core_MDF_Budget_Currency_cd__c ='USD';
        pfr1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        database.insert(pfr1);
        pfrList3.add(pfr1);
        accIDSet.add(acc.id);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList3,accIDSet);
        //List<SObject> sObjectList2 = new List<Sobject>();
        //sObjectList2.add(pfr3);
        //Boolean emeaSubmission2 =false;
        //Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess(pfrMap2,pfrList2,sObjectList2,emeaSubmission2);
        Account ipaUltimateAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Intel Account PFR'];
         Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Co-Marketing Account'];
        string bType = 'Global Nokia Acceleration - MDF';
        ChannelProgram ipaCP = [select Id from ChannelProgram where Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'];
        
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  coMarketingIPA.id, 
                                                                                  System.today().addDays(3), System.today().adddays(30),
                                                                                  bType, 110000,'INDIA', 'Consumer', 
                                                                                  'Apollo Lake', 'Planned', false);
        ipaCampaign.Core_MDF_Proposal_Based_Ind__c = false;
        insert ipaCampaign;
        List<PartnerFundRequest> pfrList4 = new List<PartnerFundRequest>();
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                 System.today().addDays(4),
                                                                                                 System.today().addDays(4),
                                                                                                 false); 
        ipaPFR.RequestedAmount = 1;
        
        
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        ipaPFR.Core_MDF_Region_nm__c = 'APJ';
        pfrList4.add(ipaPFR); 
        Database.insert(pfrList4);
        Set<ID> accIDSet1 = new Set<ID>();
        accIDSet1.add(coMarketingIPA.id);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList4,accIDSet1);
        
        Test.stopTest();
        System.assertEquals(true, pfr!=null);
        
            
    }
}