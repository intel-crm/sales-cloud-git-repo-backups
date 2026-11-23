@isTest(SeeAllData=false)
/****************************************************************************************************************************************
* Class Name  : Core_MDF_CancelExceptionRecord_Test
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Varun Kumar                    05-09-2019                   Test class for Core_MDF_CancelExceptionRecord class
*****************************************************************************************************************************************/
public class Core_MDF_CancelExceptionRecord_Test {
    
    @TestSetUp
    static void createData(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        System.runAs(usr){
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            
            Account flipkartTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('FlipkartTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account myntraTestAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('MyntraTestAccount', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet programAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Program_Adm' LIMIT 1];
            PermissionSet exceptionReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Exception_Reviewer' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            //DCF Account Manager
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            //CCF WW Account Manager
            User ccfwwAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfwwAccountManager.profileId = ccpCoreProfile.Id;
            ccfwwAccountManager.LastName = 'CCF WW Acc Manager';
            userList.add(ccfwwAccountManager);
            
            //CCF Account Manager
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            //Exception Reviewer
            User exceptionReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
            exceptionReviewer.profileId = ccpCoreProfile.Id;
            exceptionReviewer.LastName = 'Excpetion Reviewer';
            userList.add(exceptionReviewer);

            insert userList;
            
            //Assign  CCF Account Manager Permission Set 
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
           
            //Assign  CCF WW Account Manager Permission Set 
            PermissionSetAssignment psaCCFWW = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfwwAccountManager.Id);
            permissionSetAssignmentList.add(psaCCFWW);
            
            
            //Adding reviewer and program admin permission set to Excption Reviewer
            PermissionSetAssignment psaProgramAdmin = new PermissionSetAssignment(PermissionSetId = programAdminPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaProgramAdmin);

            PermissionSetAssignment psaExpReviewer = new PermissionSetAssignment(PermissionSetId = exceptionReviewerPS.Id, AssigneeId = exceptionReviewer.Id);
            permissionSetAssignmentList.add(psaExpReviewer);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            insert permissionSetAssignmentList;
            
            group grpAllEmployees = [select DeveloperName from group where DeveloperName='Core_All_Employees_Group' LIMIT 1];
            group grpCCPInternal = [select DeveloperName from group where DeveloperName='Core_All_Users_CCP_Internal' LIMIT 1];
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP FLIPKARTT CCF APJ INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            Database.insert(ccfgrp);
            
            List<groupmember> groupMemberList = new List<groupmember>();
            groupmember grpmembAllEmployees = new groupmember();
            grpmembAllEmployees.groupid = grpAllEmployees.id;
            grpmembAllEmployees.UserOrGroupId = exceptionReviewer.id;
            groupMemberList.add(grpmembAllEmployees);
            
            groupmember grpmembCCPInternal = new groupmember();
            grpmembCCPInternal.groupid = grpCCPInternal.id;
            grpmembCCPInternal.UserOrGroupId = exceptionReviewer.id;
            groupMemberList.add(grpmembCCPInternal);
            
            database.insert(groupMemberList);

            List<Core_MDF_Partner_Group_Mapping__c> pgm = new List<Core_MDF_Partner_Group_Mapping__c>();
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Source_Txt__c = 'test';
            ccfPgm.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'APJ';
            Database.insert(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmRegion = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmRegion.Core_MDF_Source_Txt__c = 'test';
            ccfPgmRegion.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmRegion.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_SA_INTERNAL';
            ccfPgmRegion.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmRegion.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmRegion.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmRegion.Core_MDF_Region_cd__c = 'APJ';
            ccfPgmRegion.Core_MDF_Sub_Region_cd__c = 'SA';
            Database.insert(ccfPgmRegion);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgmWW = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgmWW.Core_MDF_Source_Txt__c = 'test';
            ccfPgmWW.Core_MDF_Account__c = flipkartTestAccount.Id;
            ccfPgmWW.Core_MDF_Group_Name__c = 'Core_MDF_CCP_FLIPKARTT_CCF_APJ_WW_INTERNAL';
            ccfPgmWW.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgmWW.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgmWW.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgmWW.Core_MDF_Region_cd__c = 'WW';
            Database.insert(ccfPgmWW); 
            
            //Database.insert(pgm);

            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmWW = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmWW.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgmWW.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            //iupgmWW.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgmWW.Core_MDF_Region_cd__c = 'APJ';
            iupgmWW.Core_MDF_User_id__c = ccfAccountManager.Id;
            iupgmWW.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmList.add(iupgmWW);
            
             Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = flipkartTestAccount.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Region_cd__c = 'WW';
            iupgm.Core_MDF_User_id__c = ccfwwAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmList.add(iupgm);
            
            insert iupgmList;
            
          
            Account flipkartTestAccountCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, flipkartTestAccount.Id, false);
             Account myntraTestAccountDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test DCF Account', dcfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, myntraTestAccount.Id, false);
      Account myntraTestAccountCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account Myntra', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, myntraTestAccount.Id, false);
      List<Account> accountList = new List<Account>();
            accountList.add(flipkartTestAccountCCF);
      accountList.add(myntraTestAccountDCF);
      accountList.add(myntraTestAccountCCF);
      insert accountList;

            List<AccountShare> accshare = new List<AccountShare>();
            
            AccountShare accshareRecordCCFWW = new AccountShare();
            accshareRecordCCFWW.AccountId = flipkartTestAccount.Id;
            accshareRecordCCFWW.UserOrGroupId = ccfwwAccountManager.Id;
            accshareRecordCCFWW.RowCause = 'Manual';
            accshareRecordCCFWW.AccountAccessLevel = 'Read';
            accshareRecordCCFWW.OpportunityAccessLevel = 'None';
            accshareRecordCCFWW.CaseAccessLevel = 'None';
            accshare.add(accshareRecordCCFWW);
            
            AccountShare accshareRecordCCF = new AccountShare();
            accshareRecordCCF.AccountId = flipkartTestAccount.Id;
            accshareRecordCCF.UserOrGroupId = ccfAccountManager.Id;
            accshareRecordCCF.RowCause = 'Manual';
            accshareRecordCCF.AccountAccessLevel = 'Read';
            accshareRecordCCF.OpportunityAccessLevel = 'None';
            accshareRecordCCF.CaseAccessLevel = 'None';
            accshare.add(accshareRecordCCF);
            
            AccountShare accshareExcepetionReviewer = new AccountShare();
            accshareExcepetionReviewer.AccountId = flipkartTestAccount.Id;
            accshareExcepetionReviewer.UserOrGroupId = exceptionReviewer.Id;
            accshareExcepetionReviewer.RowCause = 'Manual';
            accshareExcepetionReviewer.AccountAccessLevel = 'Read';
            accshareExcepetionReviewer.OpportunityAccessLevel = 'None';
            accshareExcepetionReviewer.CaseAccessLevel = 'None';
            accshare.add(accshareExcepetionReviewer);
            
            AccountShare accshareMyntraExcepetionReviewer = new AccountShare();
            accshareMyntraExcepetionReviewer.AccountId = myntraTestAccount.Id;
            accshareMyntraExcepetionReviewer.UserOrGroupId = exceptionReviewer.Id;
            accshareMyntraExcepetionReviewer.RowCause = 'Manual';
            accshareMyntraExcepetionReviewer.AccountAccessLevel = 'Read';
            accshareMyntraExcepetionReviewer.OpportunityAccessLevel = 'None';
            accshareMyntraExcepetionReviewer.CaseAccessLevel = 'None';
            accshare.add(accshareMyntraExcepetionReviewer);
            
            Database.insert(accshare);
            
        }
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'FlipkartTestAccount' LIMIT 1];
        Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
        Test.startTest();
        
        System.runAs(submitter){ 
          	//Account       Country
            //Single        Single 
            
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account Single Country';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'INDIA';
            expt.Core_MDF_Account_id__c = acc.Id;
           	Database.insert(expt);
        }
         Test.stopTest();
    } 
       
    //Reviewer cancelling Approved record
    @isTest
    static void exceptionApproved(){
        
       	Core_MDF_Exception__c expt = [SELECT Id,Core_MDF_Exception_Status_nm__c FROM Core_MDF_Exception__c LIMIT 1]; 
        //Object record id to recall the approval process
        String recordId = expt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
		User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        system.runAs(submitter){
           
            expt.Core_MDF_Exception_Status_nm__c = 'Approved';
            database.update(expt);
            Core_MDF_CancelExceptionRecord.CheckExceptionEligibility(expt.Id);   
        } 
        
        Core_MDF_Exception__c exptCancelled = [SELECT Id,Core_MDF_Exception_Status_nm__c FROM Core_MDF_Exception__c LIMIT 1];
        System.assertEquals('Approved',exptCancelled.Core_MDF_Exception_Status_nm__c);
    }
    
    //Reviewer cancelling from Pending review state
    @isTest 
    static void cancelExceptionRecord(){
        Test.startTest();
        
        Core_MDF_Exception__c cancelledExpt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                               FROM Core_MDF_Exception__c LIMIT 1];
        
        //Object record id to recall the approval process
        String recordId = cancelledExpt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
       User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        
        system.runAs(submitter){ 
            
            Core_MDF_CancelExceptionRecord.CheckExceptionEligibility(cancelledExpt.Id);
            
            Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                          FROM Core_MDF_Exception__c LIMIT 1];
            
            System.assertEquals('Cancelled', expt.Core_MDF_Exception_Status_nm__c);
        }
        Test.stopTest();           
    }
    
    //Exception in denied and cannot be cancelled
    @isTest
    static void testExceptionDenied(){
        
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
         Core_MDF_Exception__c deniedExpt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                                FROM Core_MDF_Exception__c LIMIT 1];
            
        
        //Object record id to recall the approval process
        String recordId = deniedExpt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        system.runAs(submitter){    
           
            deniedExpt.Core_MDF_Exception_Status_nm__c = 'Denied';
            database.update(deniedExpt);
            Core_MDF_CancelExceptionRecord.cancelExceptionWrapper deniedException = Core_MDF_CancelExceptionRecord.CheckExceptionEligibility(deniedExpt.Id);
            
            Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                          FROM Core_MDF_Exception__c LIMIT 1];
            
            System.assertEquals('Denied',expt.Core_MDF_Exception_Status_nm__c);
        }
    }
    
    //Check user has custom permission
    @isTest 
    static void checkingUserPermission(){
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        Database.insert(usr);
        System.runAs(usr){
            Core_MDF_CancelExceptionRecord.cancelExceptionWrapper resultUserhasPerm = Core_MDF_CancelExceptionRecord.isUserEligibiletoCancel();
            System.assertEquals(false, resultUserhasPerm.isUserEligibleToCancel);
        }
    }
    
    //Submitter cancelling an Approved exception
    @isTest
    static void submitterCancellingApprovedRecord(){
        Core_MDF_Exception__c approvedExpt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                              FROM Core_MDF_Exception__c LIMIT 1];
        User submitter  = [SELECT Id FROM USER WHERE LastName = 'CCF Acc Manager'];
        //Object record id to recall the approval process
        String recordId = approvedExpt.Id;
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
        }
        
        system.runAs(submitter){ 
            
        
        approvedExpt.Core_MDF_Exception_Status_nm__c = 'Approved';
        database.update(approvedExpt);
        
            Core_MDF_CancelExceptionRecord.cancelExceptionWrapper cancelException = Core_MDF_CancelExceptionRecord.CheckExceptionEligibility(approvedExpt.Id);
            
            Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                          FROM Core_MDF_Exception__c LIMIT 1];
            
            System.assertEquals('Approved',expt.Core_MDF_Exception_Status_nm__c);
        }
    }
}