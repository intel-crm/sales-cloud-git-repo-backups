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
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            Test.startTest();
            // Creating Users with utility class 
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
            
            User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr9.LastName = 'User Test9';
            Database.insert(usr9);
            
            User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr10.LastName = 'User Test10';
            Database.insert(usr10);
            
            User usr11 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr11.LastName = 'User Test11';
            Database.insert(usr11);
            
            User usr12 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr12.LastName = 'User Test12';
            Database.insert(usr12);
            
            User usr13 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr13.LastName = 'User Test13';
            Database.insert(usr13);
            
            User usr14 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr14.LastName = 'User Test14';
            Database.insert(usr14);
            
            User usr15 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr15.LastName = 'User Test15';
            Database.insert(usr15);
            
            User usr16 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr16.LastName = 'User Test16';
            Database.insert(usr16);
            
            User usr17 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr17.LastName = 'User Test17';
            Database.insert(usr17);
            
            User usr18 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr18.LastName = 'User Test18';
            Database.insert(usr18);
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                            Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(acc1);
        
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', 
                                                                      cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);
        
            // Creating Criterias for approval required
            List<Core_MDF_Criteria__c> crList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                  'Core_MDF_Channel_Partner_Led__c','Equal','true','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                  'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Country__c';
            cr.Core_MDF_Operator_6__c = 'Equal';
            cr.Core_MDF_Value_6__c = 'INDIA';
            cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Country__c';
            cr.Core_MDF_Operator_7__c = 'Equal';
            cr.Core_MDF_Value_7__c = 'INDIA';
            cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Country__c';
            cr.Core_MDF_Operator_8__c = 'Equal';
            cr.Core_MDF_Value_8__c = 'INDIA';
            cr.Core_MDF_Field_Name_9__c = 'Core_MDF_Country__c';
            cr.Core_MDF_Operator_9__c = 'Equal';
            cr.Core_MDF_Value_9__c = 'INDIA';
            cr.Core_MDF_Field_Name_10__c = 'Core_MDF_Country__c';
            cr.Core_MDF_Operator_10__c = 'Equal';
            cr.Core_MDF_Value_10__c = 'INDIA';
            
            Core_MDF_Criteria__c cr1 = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                  'Core_MDF_Channel_Partner_Led__c','Equal','False','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                  'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            cr1.Core_MDF_Field_Name_6__c = 'Core_MDF_Country__c';
            cr1.Core_MDF_Operator_6__c = 'Equal';
            cr1.Core_MDF_Value_6__c = 'INDIA';
            cr1.Core_MDF_Field_Name_7__c = 'Core_MDF_Country__c';
            cr1.Core_MDF_Operator_7__c = 'Equal';
            cr1.Core_MDF_Value_7__c = 'INDIA';
            cr1.Core_MDF_Field_Name_8__c = 'Core_MDF_Country__c';
            cr1.Core_MDF_Operator_8__c = 'Equal';
            cr1.Core_MDF_Value_8__c = 'INDIA';
            cr1.Core_MDF_Field_Name_9__c = 'Core_MDF_Country__c';
            cr1.Core_MDF_Operator_9__c = 'Equal';
            cr1.Core_MDF_Value_9__c = 'INDIA';
            cr1.Core_MDF_Field_Name_10__c = 'Core_MDF_Country__c';
            cr1.Core_MDF_Operator_10__c = 'Equal';
            cr1.Core_MDF_Value_10__c = 'INDIA';
            
            crList.add(cr);
            crList.add(cr1);
            Database.insert(crList);
            
            // Creating 6 approvers for activity which are not qualified for auto approval
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_2__c = usr2.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr7.Id;
            ap1.Core_MDF_Approver_5__c = usr8.Id;
            ap1.Core_MDF_Approver_6__c = usr14.Id;
            ap1.Core_MDF_Approver_7__c = usr15.Id;
            ap1.Core_MDF_Approver_8__c = usr16.Id;
            ap1.Core_MDF_Approver_9__c = usr17.Id;
            ap1.Core_MDF_Approver_10__c = usr18.Id;
            Database.insert(ap1);
        
            Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr3.Id, true);
        
            Core_MDF_Approver__c ap3 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr4.Id, false);
            ap3.Core_MDF_Approver_2__c = usr5.Id;
            Database.insert(ap3);
            
            Core_MDF_Approver__c ap4 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,usr9.Id, false);
            ap4.Core_MDF_Approver_2__c = usr10.Id;
            ap4.Core_MDF_Approver_3__c = usr6.Id;
            ap4.Core_MDF_Approver_4__c = usr7.Id;
            ap4.Core_MDF_Approver_5__c = usr8.Id;
            ap4.Core_MDF_Approver_6__c = usr14.Id;
            ap4.Core_MDF_Approver_7__c = usr15.Id;
            ap4.Core_MDF_Approver_8__c = usr16.Id;
            ap4.Core_MDF_Approver_9__c = usr17.Id;
            ap4.Core_MDF_Approver_10__c = usr18.Id;
            Database.insert(ap4);
            
            Core_MDF_Approver__c ap5 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,usr11.Id, true);
            
            Core_MDF_Approver__c ap6 = Core_MDF_CCP_TestDataUtility.createApprover(cr1.Id,usr12.Id, false);
            ap6.Core_MDF_Approver_2__c = usr13.Id;
            Database.insert(ap6);
        
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
                                                                                               'Consumer',true);
            
            Core_MDF_Criteria_Rule__c crule10 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap4.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                                'Consumer',true);
            
            Core_MDF_Criteria_Rule__c crule11 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap4.Id,'RequestedAmount','Equal','10000',true);
            
            Core_MDF_Criteria_Rule__c crule12 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap4.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                                'Broadcast',true);
            
            Core_MDF_Criteria_Rule__c crule13 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap5.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                                'Print Media',true);
            
            Core_MDF_Criteria_Rule__c crule14 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap5.Id,'Core_MDF_Activity_Types__c','Equal',
                                                                                                'Direct Mail',true);
            
            Core_MDF_Criteria_Rule__c crule15 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap5.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                                'Mid Market / Large Enterprise',true);
            
            Core_MDF_Criteria_Rule__c crule16 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap6.Id,'Core_MDF_ActivityCategory__c','Equal',
                                                                                                'Out of Home Media',true);
        
            Core_MDF_Criteria_Rule__c crule17 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap6.Id,'Core_MDF_Activity_Types__c','Equal',
                                                                                                'Cinema',true);
            
            Core_MDF_Criteria_Rule__c crule18 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap6.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                                'Gaming',true);
            //Activating Approvers
            ap1.Core_MDF_Active__c = True;
            Database.update(ap1);
            ap2.Core_MDF_Active__c = True;
            Database.update(ap2);
            ap3.Core_MDF_Active__c = True;
            Database.update(ap3);
            
            //Activating Approval Criteria
            cr.Core_MDF_Active__c = True;
            Database.update(cr);
            
            //Activating Approvers
            ap4.Core_MDF_Active__c = True;
            Database.update(ap4);
            ap5.Core_MDF_Active__c = True;
            Database.update(ap5);
            ap6.Core_MDF_Active__c = True;
            Database.update(ap6);
            
            //Activating Approval Criteria
            cr1.Core_MDF_Active__c = True;
            Database.update(cr1);
        
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Core™ i7+ Processor', 
                  Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today().addDays(5) , 
                  System.today().addYears(1), 2000, 'Unite', acc.Id,'2-in-1', true);

            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            // Create PMB for the above Account 
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),false);
            //pmbRecord.IsIgnoreValidation = true;
            insert pmbRecord;
                
            // Create PFA records for the above accounts :
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 1234,true);        
    
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i7+ Processor','Broadcast','Radio','Draft',false);
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today().addDays(1);
            pfr.RequestedAmount = 6000;
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            Database.insert(pfr);
    
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Creator','Desktop',
                  'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            pfr1.Title = 'Test Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Activity1';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr1.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr1.RequestedAmount = 9000;
            pfr1.Core_MDF_Channel_Partner_Led__c = True;
            Database.insert(pfr1);
        
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i9 Processor','Broadcast','Radio','Draft',false);
            pfr2.Title = 'Test Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
            pfr2.Core_MDF_Start_Date__c = System.today();
            pfr2.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            Database.insert(pfr2);
        
            PartnerFundRequest pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Consumer','Desktop',
                  'Intel® Core™ i7+ Processor','Broadcast','Radio','Draft',false);
            pfr3.Title = 'Test Activity3';
            pfr3.Core_MDF_Activity_Description__c = 'Test Activity3';
            pfr3.Core_MDF_Start_Date__c = System.today();
            pfr3.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr3.RequestedAmount = 10000;
            pfr3.Core_MDF_Channel_Partner_Led__c = False;
            Database.insert(pfr3);
            
            PartnerFundRequest pfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Gaming',
                  'Desktop','Intel® Core™ i7+ Processor','Print Media','Direct Mail','Draft',false);
            pfr4.Title = 'Test Activity4';
            pfr4.Core_MDF_Activity_Description__c = 'Test Activity4';
            pfr4.Core_MDF_Start_Date__c = System.today();
            pfr4.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr4.Core_MDF_Channel_Partner_Led__c = False;
            pfr4.Core_MDF_ofPagesEligible__c  = 10;
            pfr4.Core_MDF_pagespayingfor__c = 10;
            Database.insert(pfr4);
            
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'INDIA','Gaming','Desktop',
                  'Intel® Core™ i7+ Processor','Out of Home Media','Cinema','Draft',false);
            pfr5.Title = 'Test Activity5';
            pfr5.Core_MDF_Activity_Description__c = 'Test Activity5';
            pfr5.Core_MDF_Start_Date__c = System.today();
            pfr5.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr5.Core_MDF_Channel_Partner_Led__c = False;
            Database.insert(pfr5);
            
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,null,'ANGOLA','Gaming','Mini PC',
                  'Intel® Core™ i7+ Processor','Out of Home Media','Cinema','Draft',false);
            pfr6.Title = 'Test Activity6';
            pfr6.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr6.Core_MDF_Start_Date__c = System.today();
            pfr6.Core_MDF_End_Date__c = System.today().addDays(3);
            pfr6.Core_MDF_Channel_Partner_Led__c = False;
            pfr6.RequestedAmount = 1000;
            Database.insert(pfr6);
            
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
    @isTest static void testCustomApprovalProcessMethod(){ 
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        System.runAs(user){
            Test.startTest();
            list<User> usrList = [SELECT Id, LastName FROM User WHERE LastName LIKE 'usr%' LIMIT 10000 ];
            
            list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c, 
                   Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c,  Core_MDF_Brand__c, Core_MDF_Approver_1__c, 
                   Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c,Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                   Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                   Core_MDF_ActivityCategory__c, Core_MDF_Country__c, Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c, 
                   Core_MDF_Reimbursement_Rate__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity%' LIMIT 50000];
            Test.stopTest();
            Map<String,Map<String, list<Id>>> setApproverResultMap1 = Core_MDF_GenericApprovalProcess.setApprovers((List<SObject>) pfrList);
            
            // Testing auto approval records 
            if(setApproverResultMap1.containsKey('autoApproved')){
                Map<String, list<Id>> autoApprovedSObjects = setApproverResultMap1.get('autoApproved');
                PartnerFundRequest autoApprovedActivity = [SELECT Id,  Title FROM PartnerFundRequest WHERE Title ='Test Activity6' LIMIT 1];
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
           
        }
    }
}