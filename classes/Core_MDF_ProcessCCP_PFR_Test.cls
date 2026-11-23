/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_PFR_Test 
* Version     : 1.0 
* Created Date: 8-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        8/27/2018                    Created to test Approvers based on criteria.  
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_PFR_Test{
/****************************************************************************************************************************************
    Method Name:                                   createTestData
    Description:                                   Creating test data to test approval process
    Added By:                                      Accenture – Harika P  -  8/27/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        8/27/2018           Created.
    Accenture – Shridhar K        12/24/2018       Added Allocation and budget parameters createPartnerFundRequest method to fix null pointer exception 
    Intel - Narayani Perachi    02/11/2019         Added user and PFR record to test the functionality of Auto approver if created/modified by Account Manager
*****************************************************************************************************************************************/    
    @TestSetup static void createTestData() 
    {
        //Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_DCF_Account_Manager'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            // Creating 5 Users with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            Database.insert(usr1);
        
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            Database.insert(usr2);
        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            Database.insert(usr3);
        
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test4';
            Database.insert(usr4);
        
            User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr5.LastName = 'User Test5';
            Database.insert(usr5);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test6';
            Database.insert(usr6);
            
            User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr7.LastName = 'User Test7';
            Database.insert(usr7);
            
            User usr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr8.LastName = 'User Test8';
            Database.insert(usr8);
            
            //Creating User who is an Account Manager
            User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr10.LastName = 'User Test10';
            Database.insert(usr10);
            Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr10.id,accountManager.id,true);
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(acc1);

            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'ASMO';
            acc1Retail.Core_Sub_Geo__c = 'LAR';
            Database.insert(acc1Retail);
        
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);
            
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'ASMO';
            accRetail.Core_Sub_Geo__c = 'LAR';
            Database.insert(accRetail);

            // Creating User with utility class 
            User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr9.LastName = 'User Test9';
            Database.insert(usr9);
            
            // Creating Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
            Database.insert(ccfgrp);
            
            // Creating Group Member
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr9.Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            Database.insert(ccfGrpMem);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'Internal';
            pgm1.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc1Retail.Id;
            pgm2.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm2.Core_MDF_Channel_Program__c = cpRetail.Id;
            Database.insert(pgm2);
        
            // Creating Criterias for approval required
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                 'Core_MDF_Channel_Partner_Led__c','Equal','true','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                 'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',true);

            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLevel',
                 'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                 'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','2-in-1','RequestedAmount','Greater Than','0',true);
            
            // Creating 6 approvers for activity which are not qualified for auto approval
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_2__c = usr2.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr7.Id;
            ap1.Core_MDF_Approver_5__c = usr8.Id;
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            Database.insert(ap1);
        
            Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usr1.Id, false);
            ap1Retail.Core_MDF_Approver_2__c = usr2.Id;
            ap1Retail.Core_MDF_Approver_3__c = usr6.Id;
            ap1Retail.Core_MDF_Approver_4__c = usr7.Id;
            ap1Retail.Core_MDF_Approver_5__c = usr8.Id;
            ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
            Database.insert(ap1Retail);

            Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr3.Id, false);
            ap2.Core_MDF_Approver_Type__c = 'Internal';
            Database.insert(ap2);
        
            Core_MDF_Approver__c ap3 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr4.Id, false);
            ap3.Core_MDF_Approver_2__c = usr5.Id;
            ap3.Core_MDF_Approver_Type__c = 'Internal';
            Database.insert(ap3);
            
            // Creating Criteria rules for approvers
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_End_Date__c','Less Than',
                                                                                               String.valueOf(System.today().addDays(2)),true);
        
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'RequestedAmount','Less Than or Equal',
                                                                                               '8000',true);
        
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Brand__c','Equal',
                                                                                               'Intel® Core™ i7+ Processor',true);
        
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
            
            ap1.Core_MDF_Active__c = True;
            Database.update(ap1);
            ap2.Core_MDF_Active__c = True;
            Database.update(ap2);
            ap3.Core_MDF_Active__c = True;
            Database.update(ap3);
            
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

            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                  System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', true);

            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                  System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', true);
                      
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            // Create PMB for the above Account 
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
            //pmbRecord.IsIgnoreValidation = true;
            insert pmbRecord;
            
            // Create PFA records for the above accounts :
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 1234,true);        
            PartnerFundAllocation pfaRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA1',pmbRecord, acc, 12345, true);
            PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, acc, 12345, true);   
            
            Test.startTest();
            list<PartnerFundRequest> listPRFToBeInserted = new list<PartnerFundRequest>();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                  'Intel® Core™ i7+ Processor','Broadcast','Radio','Draft',false);
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today().addDays(1);
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
            pfr1.Core_MDF_End_Date__c = System.today().addDays(3);
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
            pfr2.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr2);
            
            //Creating partner fund request
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                  'Intel® Core™ i7+ Processor','Out of Home Media','Cinema','Draft',false);
            pfr5.Title = 'Test Activity5';
            pfr5.Core_MDF_Activity_Description__c = 'Test Activity5';
            pfr5.Core_MDF_Start_Date__c = System.today();
            pfr5.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr5.RequestedAmount = 16000;
            pfr5.Core_MDF_Channel_Partner_Led__c = True;
            pfr5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr5);
            
            //Creating partner fund request
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                  'Intel® Core™ i7+ Processor','Out of Home Media','Cinema','Draft',false);
            pfr6.Title = 'Test Activity6';
            pfr6.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr6.Core_MDF_Start_Date__c = System.today();
            pfr6.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr6.RequestedAmount = 16000;
            pfr6.Core_MDF_Channel_Partner_Led__c = False;
            pfr6.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            //Database.insert(pfr6);
            
            //Creating partner fund request with Modified by Account Manager
            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                'Intel® Core™ i7+ Processor','Out of Home Media','Cinema','Draft',false);
            pfr7.Title = 'Test Activity7';
            pfr7.Core_MDF_Activity_Description__c = 'Test Activity7';
            pfr7.Core_MDF_Start_Date__c = System.today();
            pfr7.Core_MDF_End_Date__c = System.today().addDays(3);
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
            pfr8.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr8.RequestedAmount = 9000;
            pfr8.OwnerId = usr1.Id;
            pfr8.Core_MDF_Channel_Partner_Led__c = True;
            pfr8.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            listPRFToBeInserted.add(pfr);            
            listPRFToBeInserted.add(pfr1);
            listPRFToBeInserted.add(pfr2);
            listPRFToBeInserted.add(pfr5);
            listPRFToBeInserted.add(pfr6);
            listPRFToBeInserted.add(pfr7);
            listPRFToBeInserted.add(pfr8);
            
            Database.insert(listPRFToBeInserted);
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            // Assigning internal ccf acc mgr permission set to usr1
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = usr1.Id);
            Database.insert(psa1);
            
            pfr8.OwnerId = usr2.Id;
            Database.update(pfr8);
            
            Test.stopTest();
            
            //ProcessInstance pi = [SELECT Id, TargetObjectId,(SELECT Id FROM Workitems) FROM ProcessInstance where TargetObjectId =: pfr1.Id];      
            //System.debug('pi Workitems: '+pi.Workitems);
                
        }
    }  
/****************************************************************************************************************************************
    Method Name:                                   testCustomApprovalProcessMethod
    Description:                                   Created for testing custom approval process for PartnerFundRequest Object
    Added By:                                      Accenture – Harika P  -  8/27/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        8/27/2018          Created.
*****************************************************************************************************************************************/   
    @isTest static void testCustomApprovalProcessMethod(){ 
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        System.runAs(user){
            Test.startTest();
            list<User> usrList = [SELECT Id, LastName FROM User LIMIT 1000];
            
            list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c,  
                 Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c,  Core_MDF_Brand__c, Core_MDF_Approver_1__c,  
                 Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c, Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                 Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                 Core_MDF_ActivityCategory__c, Core_MDF_Country__c, Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c, 
                 Core_MDF_Approver_6__c, Core_MDF_Approver_7__c, Core_MDF_Approver_8__c, Core_MDF_Approver_9__c, Core_MDF_Reimbursement_Rate__c,
                 Core_MDF_Approver_10__c, Core_MDF_Program__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity%' LIMIT 100];
            
            Map<String,Map<String, list<Id>>> setApproverResultMap1 = Core_MDF_GenericApprovalProcess.setApprovers((List<SObject>) pfrList);
            
            // Testing auto approval records 
            if(setApproverResultMap1.containsKey('autoApproved')){
                Map<String, list<Id>> autoApprovedSObjects = setApproverResultMap1.get('autoApproved');
                PartnerFundRequest autoApprovedActivity = [SELECT Id,  Title, Core_MDF_Fund_Request_Status__c,Core_MDF_Approver_1__c,
                      Core_MDF_Approver_2__c,Core_MDF_Approver_3__c,Core_MDF_Approver_4__c,Core_MDF_Approver_5__c,Core_MDF_Approver_6__c, 
                      Core_MDF_Approver_7__c, Core_MDF_Approver_8__c, Core_MDF_Approver_9__c, Core_MDF_Approver_10__c, Core_MDF_Reimbursement_Rate__c
                  FROM PartnerFundRequest WHERE 
                      Title ='Test Activity6' LIMIT 50000];
                System.assert(autoApprovedSObjects.keySet().contains(String.valueOf(autoApprovedActivity.Id)));
                
            }
            Test.stopTest();
            
            // Testing approval required records 
            if(setApproverResultMap1.containsKey('approvalRequired')){
                Map<String, list<Id>> nonAutoApprovedSObjects = setApproverResultMap1.get('approvalRequired');
                for(PartnerFundRequest pfr:pfrList){
                    if(nonAutoApprovedSObjects.keySet().contains(pfr.Id)){
                        for(User usr : usrList){
                            if(pfr.Title == 'Test Activity'){
                                //Testing whether User Test1 is the approver or not 
                                if(usr.LastName == 'User Test1'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                //Testing whether User Test2 is the approver or not 
                                if(usr.LastName == 'User Test2'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                //Testing whether User Test6 is the approver or not 
                                if(usr.LastName == 'User Test6'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                //Testing whether User Test7 is the approver or not                                 
                                if(usr.LastName == 'User Test7'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                //Testing whether User Test8 is the approver or not 
                                if(usr.LastName == 'User Test8'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }                               
    
                            }
                            
                            //Testing whether User Test3 is the approver of test Activity1 or not 
                            if(pfr.Title == 'Test Activity1'){
                                if(usr.LastName == 'User Test3'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                
                            }
                        
                            //Testing whether User Test4 and User Test5 are the approvers of test Activity2 or not 
                            if(pfr.Title == 'Test Activity2'){
                                if(usr.LastName == 'User Test4'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                                if(usr.LastName == 'User Test5'){
                                    System.assert(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id));
                                }
                            }
                            //Testing whether User Test9 is the approver of test Activity5 or not 
                            if(pfr.Title == 'Test Activity5'){
                                if(usr.LastName == 'User Test9'){
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
/****************************************************************************************************************************************
    Method Name:                                   testRecallApprovalProcess
    Description:                                   Created to test recall functionalities.
    Added By:                                      Accenture – Shridhar K 12/23/2018
    Modified By:                  Date:            Changes: 
    Accenture – Shridhar K        12/23/2018       Created. 
*****************************************************************************************************************************************/
    @isTest static void testRecallApprovalProcess(){
        Test.startTest();        
        
            PartnerFundRequest pfrCancelled = [SELECT Id,  Title, Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE 
                                                Title ='Test Activity1' LIMIT 1];
                                                
            //ProcessInstance pi = [SELECT Id, TargetObjectId,(SELECT Id FROM Workitems) FROM ProcessInstance where TargetObjectId =: pfrCancelled.Id];      
            //System.assert(pi.Workitems.size()>0);
                                                            
            pfrCancelled.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            Database.update(pfrCancelled);
            System.assertEquals('Cancelled',pfrCancelled.Core_MDF_Fund_Request_Status__c);
        
            //ProcessInstance pi1 = [SELECT Id, TargetObjectId,(SELECT Id FROM Workitems) FROM ProcessInstance where TargetObjectId =: pfrCancelled.Id];      
            //System.assertEquals(0,pi1.Workitems.size()); 
              
        Test.stopTest(); 
        
        // Calling methods to cover exceptions
        Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess (NULL,NULL,NULL,False); 
        Core_MDF_ProcessCCP_PartnerFundRequest.assignAccountManagers(NULL,NULL,NULL);
        Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess(NULL,NULL,NULL,False);
        Core_MDF_ProcessCCP_PartnerFundRequest.updateApprovers(NULL);
        Core_MDF_ProcessCCP_PartnerFundRequest.checkIfActivitySubmitterIsAccountManager (NULL);
        Core_MDF_ProcessCCP_PartnerFundRequest.recallApprovalProcess(NULL,NULL);
    }

    @isTest static void testRetailActivities(){
        
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail'  LIMIT 1];
        list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();

        System.runAs(user){

            Test.startTest();        
            //Creating partner fund request
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Gaming','2-in-1',
                  'Athena','Online','Customer.com','Draft',false);
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            pfr.Core_MDF_Country__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Gaming','2-in-1',
                  'Athena','Online','Customer.com','Draft',false);
            pfr1.Title = 'Test Retail Activity 1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr1.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr1.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr1.RequestedAmount = 1000;
            pfr1.Core_MDF_Country_nm__c = 'INDIA';
            pfr1.Core_MDF_Country__c = 'INDIA';
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            

            pfrs.add(pfr);
            pfrs.add(pfr1);

            Database.insert(pfrs);

            Test.stopTest(); 
        }
        System.assert(pfrs != NULL);
    }
/****************************************************************************************************************************************
    Method Name:                                   testNullApprovers
    Description:                                   Created to test null approvers functionality.
    Added By:                                      Accenture – Harika P  11/27/2019 
    Modified By:                  Date:            Changes: 
    Accenture – Harika P          11/27/2019       Created.
*****************************************************************************************************************************************/       
    @isTest static void testNullApprovers(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 1'];
        User user = [SELECT Id FROM User WHERE LastName = 'User Test1'];
        test.startTest();
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_cd__c = 'ASMO;EMEA;PRC;WW';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO;EMEA;PRC;WW';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        Database.insert(iupgm);
        
        PartnerFundRequest pfr = [SELECT Id, CampaignId, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                          Campaign.Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c 
                                          FROM PartnerFundRequest  WHERE 
                                                Title ='Test Activity1' LIMIT 1];
        Campaign cmp = [Select Id,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c FROM Campaign Where Name ='TestCamp' LIMIT 1];
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        pfrMap.put(pfr.Id,pfr);
        Set<Id> campIdSet = new Set<Id>();
        campIdSet.add(cmp.Id);
        List<String> nullApprovers = new List<String>();
        nullApprovers.add(pfr.Id);
        Core_MDF_ProcessCCP_PartnerFundRequest.assignAccountManagers (pfrMap,campIdSet,nullApprovers);
        test.stopTest();
        System.assertEquals(iupgm.Core_MDF_User_id__c,user.Id);
        
    }
}