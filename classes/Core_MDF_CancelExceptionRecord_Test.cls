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
    static void createExceptionRecord(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        //Create Exception Submitter User
        User submitter = Core_MDF_CCP_TestDataUtility.createUser(false);
        submitter.LastName = 'Exception Submitter';
        submitter.UserRoleId = usRole.Id;
        Database.insert(submitter);
        //Assign Exception Submitter permission set
        PermissionSet submitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Account_Manager' LIMIT 1];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = submitterPS.Id, AssigneeId = submitter.Id);
        Database.insert(psa1);
        
        //Create PMG Approver
        User pmgReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
        pmgReviewer.LastName = 'PMG Approver';
        pmgReviewer.UserRoleId = usRole.Id;
        Database.insert(pmgReviewer);
        //Assign PMG Approver Permission set
        PermissionSet pmgReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Exception_Reviewer' LIMIT 1];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = pmgReviewerPS.Id, AssigneeId = pmgReviewer.Id);
        Database.insert(psa2);
        
        //Create FCC Approver
        User fccReviewer = Core_MDF_CCP_TestDataUtility.createUser(false);
        fccReviewer.LastName = 'FCC Approver';
        fccReviewer.UserRoleId = usRole.Id;
        Database.insert(fccReviewer);
        //Assign FCC Approver Permission set
        PermissionSet fccReviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Exception_Reviewer' LIMIT 1];
        PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = fccReviewerPS.Id, AssigneeId = fccReviewer.Id);
        Database.insert(psa3);
        
        //Create Exception as Submitter
        System.runAs(submitter){
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception';
            expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
            expt.Core_MDF_Comments_txt__c = 'Test Comments';
            expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
            expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
            expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
            expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
            expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
            expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
            expt.Core_MDF_Country_Region_nm__c = 'India';
            expt.Core_MDF_Company_Name_txt__c = 'Dell Computer Corporation;Nokia Corporation';
            insert expt;

            expt.Core_MDF_Exception_Status_nm__c = 'Pending Review';
            update expt;
        }
    }
    
    //Reviewer cancelling Approved record
    @isTest
    static void exceptionApproved(){
        
        Core_MDF_Exception__c expt = [SELECT Id,Core_MDF_Exception_Status_nm__c FROM Core_MDF_Exception__c LIMIT 1];
        expt.Core_MDF_Exception_Status_nm__c = 'Approved';
        database.update(expt);
        
        User pmgUser = [SELECT Id,Name FROM User WHERE LastName = 'PMG Approver'];
        system.runAs(pmgUser){
            Core_MDF_CancelExceptionRecord.CheckExceptionEligibility(expt.Id);   
        } 
        
        Core_MDF_Exception__c exptCancelled = [SELECT Id,Core_MDF_Exception_Status_nm__c FROM Core_MDF_Exception__c LIMIT 1];
        System.assertEquals('Cancelled',exptCancelled.Core_MDF_Exception_Status_nm__c);
    }
    
    //Reviewer cancelling from Pending review state
    @isTest 
    static void cancelExceptionRecord(){
        Test.startTest();
        
        Core_MDF_Exception__c cancelledExpt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                               FROM Core_MDF_Exception__c LIMIT 1];
        
        User pmgUser = [SELECT Id,Name FROM User WHERE LastName = 'PMG Approver'];
        
        system.runAs(pmgUser){ 
            
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
        
        User pmgUser = [SELECT Id,Name FROM User WHERE LastName = 'PMG Approver'];
        system.runAs(pmgUser){   
            Core_MDF_Exception__c deniedExpt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                                FROM Core_MDF_Exception__c LIMIT 1];
            
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
            //System.assertEquals(false, Core_MDF_CancelExceptionRecord.cancelExceptionWrapper);
        }
    }
    
    //Submitter cancelling an Approved exception
    @isTest
    static void submitterCancellingApprovedRecord(){
        User submitter = [SELECT Id,Name FROM User WHERE LastName = 'Exception Submitter'];
        
        Core_MDF_Exception__c approvedExpt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                              FROM Core_MDF_Exception__c LIMIT 1];
        approvedExpt.Core_MDF_Exception_Status_nm__c = 'Approved';
        database.update(approvedExpt);
        
        System.runAs(submitter){
            Core_MDF_CancelExceptionRecord.cancelExceptionWrapper cancelException = Core_MDF_CancelExceptionRecord.CheckExceptionEligibility(approvedExpt.Id);
            
            Core_MDF_Exception__c expt = [SELECT Id, Core_MDF_Exception_Status_nm__c 
                                          FROM Core_MDF_Exception__c LIMIT 1];
            
            System.assertEquals('Approved',expt.Core_MDF_Exception_Status_nm__c);
        }
    }
}