/****************************************************************************************************************************************
* Class Name        : Core_MDF_PFR_Approval_Test
* Created Date      : 11/26/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - HA       11/26/2019         Test Class for Core_MDF_PFR_Approval
*****************************************************************************************************************************************/

@isTest(SeeAllData=false)
public class Core_MDF_PFR_Approval_Test {
    
    @TestSetUp
    static void createData(){
        
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);

        List<Core_MDF_Partner_Group_Mapping__c> ccfpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        System.runAs(usr){
            
            
            
            //Create CCF Channel Program
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            Database.insert(acc1Retail);
            
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'EMEA';
//            accRetail.Core_Sub_Geo__c = 'LAR';
            Database.insert(accRetail);
            
            
            PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
           	PermissionSet accountReviewer = [select id from PermissionSet where name=:Label.Core_MDF_Retail_Reviewer_Permission_Set];
            
            List<User> userList = new List<User>();
            
            //Creating User who is an Account Manager
            User usrRW = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrRW.UserRoleId = usRole1.Id;
            usrRW.LastName = 'Retail Account Reviewer Test ';
            userList.add(usrRW);
            
            //Creating User who is an Account Manager
            User usrAM = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrAM.LastName = 'Retail Account Manager';
            userList.add(usrAM);
            Database.insert(userList);
            
            
            PermissionSetAssignment psAR = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrRW.id,accountReviewer.id,false);
         	PermissionSetAssignment psAM = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usrAM.id,accountManager.id,false);
           	List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            psaList.add(psAR);
            psaList.add(psAM);
            Database.insert(psaList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            con.Core_Audience_List__c = 'RMF User; RMF External activity approver';
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 50000];
            
            // Creating User with utility class
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'External Approver 1';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usr2.isActive = true;
            Database.insert(usr2);
            Test.startTest();
            Core_MDF_Partner_Node_User_Mapping__c pnumap = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRetail.Id, usr2.Id, true);
            
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';
            Database.insert(grp1);
            
            // Creating Group Members
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr2.Id;
            grpMember.GroupId = grp1.Id;
            Database.insert(grpMember);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1Retail.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;
            pgm1.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = acc1Retail.Id+'Core_MDF_CCP_External';
            pgm1.Core_MDF_Source_Txt__c = 'test';
            Database.insert(pgm1);
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_External_Activity_Approver'];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id);

            //Create Retail Group
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core CCP Retail Internal EMEA';
            ccfgrp3.DeveloperName = 'Core_CCP_Retail_Internal_EMEA';
            Database.insert(ccfgrp3);

             // Creating Group Members
            GroupMember grpMemberam = new GroupMember();
            grpMemberam.UserOrGroupId = usrAM.Id;
            grpMemberam.GroupId = ccfgrp3.Id;
            Database.insert(grpMemberam);

            Core_MDF_Partner_Group_Mapping__c ccfPgm3 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm3.Core_MDF_Account__c = acc1Retail.Id;
            ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal_EMEA';
            ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
            ccfPgm3.Core_MDF_Channel_Program__c = cpRetail.Id;
            ccfPgm3.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm3.Core_MDF_Source_Txt__c = 'test';
            Database.insert(ccfPgm3);
            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           accRetail.id, cpRetail.Id , 10000 , System.today()-60 , System.today() + 30 , 
                                                                                           false);
            
            testBudget1.IsIgnoreValidation = true;
            // testBudget1.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            insert testBudget1;
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            update testBudget1;

            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', true);
            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLevel',
                 'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                 'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than','0','RequestedAmount','Greater Than','0',false);
            crMulti.Core_MDF_Number_Of_Steps__c = '4';
            Database.insert(crMulti);
            
            Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usrAM.Id, false);
            ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
            ap1Retail.Core_MDF_Step_Number__c = 1;
            Database.insert(ap1Retail);

            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                               'Retail Marketing Funds',true);
        
            Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than',
                                                                                               '0',true);
        
            Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                               'Pending Review',true);
            Core_MDF_Criteria_Rule__c cruleR4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Approval_Step_Completed__c','Equal',
                                                                                               '0',true);

            ap1Retail.Core_MDF_Active__c = true;
            Database.update(ap1Retail);
            crMulti.Core_MDF_Active__c = true;
            Database.update(crMulti);

            Core_MDF_Approver__c ap2Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usr2.Id, false);
            ap2Retail.Core_MDF_Approver_Type__c = 'External';
            ap2Retail.Core_MDF_Step_Number__c = 2;
            Database.insert(ap2Retail);
            
            // Retail criteria rules
            Core_MDF_Criteria_Rule__c cruleR21 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                               'Retail Marketing Funds',true);
        
            Core_MDF_Criteria_Rule__c cruleR22 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'RequestedAmount','Greater Than',
                                                                                               '0',true);
        
            Core_MDF_Criteria_Rule__c cruleR23 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                               'Pending Approval',true);

            Core_MDF_Criteria_Rule__c cruleR24 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2Retail.Id,'Core_MDF_Approval_Step_Completed__c','Equal',
                                                                                               '1',true);

            ap2Retail.Core_MDF_Active__c = true;
            Database.update(ap2Retail);

            // Create activity

            date sdate = date.today();        
            list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false); 
            //PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
            //                                                                                Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Gaming','2-in-1',
            //                                                                                '10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 15;
            pfr.Core_MDF_Country_nm__c = 'UNITED KINGDOM';
            pfr.Core_MDF_Region_Cd__c = 'EMEA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_Approval_Step_Completed__c = 0;
            pfr.Core_MDF_Approver_1__c = usrAM.Id;
            pfr.Core_MDF_Approver_2__c = usrAM.Id;
            pfr.Core_MDF_Approver_3__c = usrAM.Id;
            pfr.Core_MDF_Approver_4__c = usrAM.Id;
            pfr.Core_MDF_Approver_5__c = usrAM.Id;
            pfr.Core_MDF_Approver_6__c = usrAM.Id;
            pfr.Core_MDF_Approver_7__c = usrAM.Id;
            pfr.Core_MDF_Approver_8__c = usrAM.Id;
            pfr.Core_MDF_Approver_9__c = usrAM.Id;
            pfr.Core_MDF_Approver_10__c = usrAM.Id;
            pfrs.add(pfr);
            Database.insert(pfrs);
            
			Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(pfr.id);
            Approval.ProcessResult result = Approval.process(app);

            
            //UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
            //Creating User with utility class 
            User usrg = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrg.LastName = 'User Testg';
            usrg.UserRoleId = usRole1.Id;
            Database.insert(usrg);
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
            insert new PermissionSetAssignment(AssigneeId = usrg.id, PermissionSetId = ps1.Id);
            
            Test.stopTest();
        }
    }
    @isTest
    static void loadPFRAccountManagerSubmit(){
        
        User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' LIMIT 1];
        PartnerFundRequest pfr = [select id, RecordType.Name, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
        System.debug('pfr.Core_MDF_Fund_Request_Status__c '+pfr.Core_MDF_Fund_Request_Status__c);
        System.debug('pfr.RecordType.Name '+pfr.RecordType.Name);
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        List<Id> pfrsId = new List<Id>();
        pfrsId.add(pfr.Id);
        
       
        Boolean submitStatus = Core_MDF_PFR_Approval.submitForApproval(pfrsId);
        try{

            System.runAs(usr1){
                
                string approvalComments = 'Test';
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                
                
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                
                ProcessInstanceWorkItem piwitmtst = [SELECT ProcessInstance.TargetObjectId, Id,ActorId, ProcessInstance.status FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId IN:pfrsId];
                system.debug('piwitmtstsubmit status->' + piwitmtst.ProcessInstance.status);
                
                Boolean approvalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                
                // Validate the pending approval
                pfrMapValues = new Map<Id,Map<String,String>>();
                pfrInstanceMap = new Map<String,String>();
                pfrInstanceMap.put('Test internal comments', 'Decline');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                Boolean extApprovalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                
              //  System.assertEquals(submitStatus, false);
            }
       }
        catch(Exception ex){
            System.debug('##Approval Test Exception->' + ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains('PFRIDs->') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
       }
               
    }
    
    
    @isTest
    static void loadPFRAccountManagerApprove(){

        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            pfr = [select id, Core_MDF_Fund_Request_Status__c, RecordType.Name from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
            System.debug('pfr.Core_MDF_Fund_Request_Status__c '+pfr.Core_MDF_Fund_Request_Status__c);
            System.debug('pfr.RecordType.Name '+pfr.RecordType.Name);
            List<Id> pfrIdLst = new List<Id>();
            pfrIdLst.add(pfr.Id);
            //Boolean submitStatus = Core_MDF_PFR_Approval.submitForApproval(pfrIdLst);
            Test.startTest();
            System.runAs(usr1){
                    
                pfrInstanceMap.put('Test internal comments', 'Approve');
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                approvalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
            }
            Test.stopTest();

            System.assertEquals(approvalStatus, true);

            User usr2 = [select id from User where LastName = 'External Approver 1' LIMIT 1];

            List<Id> pfrsId = new List<Id>();
            pfrMapValues = new Map<Id,Map<String,String>>();

            pfr = [select id,Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
            System.debug('##pfr status external approve->' + pfr.core_mdf_fund_request_status__c);
            
            System.runAs(usr2){
                
                pfrInstanceMap = new Map<String,String>();
                pfrInstanceMap.put('Test external comments', 'Approve');
                
                pfrMapValues.put(pfr.Id, pfrInstanceMap);
                
                Core_MDF_PFR_Approval.loadPFRRecord(pfr.Id);
                pfrsId.add(pfr.id);
                Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                
            }
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
    
    static void loadPFRAccountManagerReject(){
        
        Map<Id,Map<String,String>> pfrMapValues = new Map<Id,Map<String,String>>();
        Map<String,String> pfrInstanceMap = new Map<String,String>();
        PartnerFundRequest PFR = new PartnerFundRequest();
        Boolean approvalStatus = false;
        string approvalComments = 'Test';
        
        try{
            User usr1 = [select id from user where lastname = 'Retail Account Reviewer Test' limit 1];
            pfr = [select id from PartnerFundRequest where Title = 'Test Retail Activity' and Core_MDF_Country_nm__c = 'UNITED KINGDOM' limit 1];
            
            
            System.runAs(usr1){
                
                pfrInstanceMap.put('Test internal comments', 'Reject');
                    pfrMapValues.put(pfr.Id, pfrInstanceMap);
                    
                    approvalStatus = Core_MDF_PFR_Approval.approveRejectActivity(pfrMapValues, approvalComments);
                 
            }
            Core_MDF_PFR_Approval.populateApproverComments('Approve','','Test Approve');
            Core_MDF_PFR_Approval.populateApproverComments('Decline','Test','Test Approve');
            System.assertEquals(approvalStatus, true);
            
         }
         catch(Exception ex){
             Boolean expectedExceptionThrown =  ex.getMessage() == '' ? false : true;
             System.assertEquals(expectedExceptionThrown, true);
         }
        
    }
}