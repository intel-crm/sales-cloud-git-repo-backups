/********************************************************************************************************************
Apex Class Name:  Core_IPS_Survey_Page_Controller_Test
Version     : 1.0 
Created Date: 09/01/2017
Function    : Test class for Core_IPS_Survey_Page_Controller
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh Sahu                       09/01/2017                Created - US79635
* Amritesh                            04/15/2018                Modified - US103747
* Amritesh                            04/15/2018                Modified - US109362
*******************************************************************************************************************/

@isTest
public class Core_IPS_Survey_Page_Controller_Test {
    
    @testSetup 
    static void TestData() {
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.ProfileID =  sysAdminProfileID;  
        sysadmin.username='sysAdmin@intel.com.test.' + String.valueOf(System.Now().getTime());     
        sysadmin.Core_User_Country_Code__c ='DEU'; 
        insert sysadmin;
        
        System.runAs(sysadmin) {
            Case objCase = TestUtilities.getCase();
            objCase.RecordTypeId = schema.sobjecttype.Case.getrecordtypeinfosbyname().get('IPS Case Create').getRecordTypeId();
            insert objCase;
            objCase.Status = 'Closed';
            objCase.Core_Sub_Status__c = 'Closed'; // added by amritesh - US103747
            update objCase;
            
            Id surveyRecordTypeId = schema.sobjecttype.Core_IPS_Question__c.getrecordtypeinfosbyname().get('Survey').getRecordTypeId();
            List<Core_IPS_Question__c> lstQues = new List<Core_IPS_Question__c>();
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=surveyRecordTypeId, Core_IPS_Order_No__c=1, Core_IPS_Question__c='Question 1', Core_IPS_DataType__c='Picklist', Core_IPS_Status__c = 'Active', Core_IPS_Survey_Type__c = 'Customer', Core_IPS_Required__c=true));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=surveyRecordTypeId, Core_IPS_Order_No__c=2, Core_IPS_Question__c='Question 2', Core_IPS_DataType__c='Select Radio', Core_IPS_Status__c = 'Active', Core_IPS_Survey_Type__c = 'Customer'));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=surveyRecordTypeId, Core_IPS_Order_No__c=3, Core_IPS_Question__c='Question 3', Core_IPS_DataType__c='Text Area', Core_IPS_Status__c = 'Active', Core_IPS_Survey_Type__c = 'Customer'));
            insert lstQues;
            
            List<Core_IPS_Answer__c> lstAns = new List<Core_IPS_Answer__c>();
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=1, Core_IPS_Answer__c='Yes'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=2, Core_IPS_Answer__c='No'));
            insert lstAns;
            
            Core_IPS_Survey_Settings__c surveySetting = new Core_IPS_Survey_Settings__c(Name='Customer');
            insert surveySetting;
        }
    }
    
    
    static testMethod void Core_IPS_Survey_Controller_test() {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;        
        Pagereference pgref = Page.Core_IPS_Survey;
        pgref.getParameters().put('caid', caseId);
        pgref.getParameters().put('retURL', '/' + caseId);
        pgref.getParameters().put('stype', 'Customer');
        Test.setCurrentPage(pgref);
        
        Test.startTest();
        Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        System.assert(surveyController.lstQuestions.size()>0);
        surveyController.lstQuestions[0].answer = 'Yes';
        surveyController.captureSurvey();
        System.assert([SELECT COUNT() FROM Core_IPS_Response__c]>0, 'Response should be Captured');
        Boolean showMainContent = surveyController.showMainContent;
        surveyController = new Core_IPS_Survey_Page_Controller();
        System.assert(surveyController.isError, true);
        Test.stopTest();
    }
    
    static testMethod void Core_IPS_Negative_Survey_Controller_test() {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;        
        Pagereference pgref = Page.Core_IPS_Survey;
        pgref.getParameters().put('caid', '');
        pgref.getParameters().put('retURL', '/' + '');
        pgref.getParameters().put('stype', '');
        Test.setCurrentPage(pgref);
        
        Test.startTest();
        Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        surveyController.captureSurvey();
        surveyController.getProfilename();
        Boolean showMainContent = surveyController.showMainContent;
        surveyController = new Core_IPS_Survey_Page_Controller();
        system.assert(caseId != null);
        Test.stopTest();
    }
    
    
    static testMethod void Core_IPS_Survey_Page_Controller_negative_test() {
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        Id caseId = objCase.Id;
        User sysAdmin = [SELECT Id FROM User WHERE Profile.Name='System Administrator' AND isActive=true LIMIT 1];
        Pagereference pgref = Page.Core_IPS_Survey;
        Test.setCurrentPage(pgref);
        
        Test.startTest();
        Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        pgref.getParameters().put('caid', '123');
        surveyController = new Core_IPS_Survey_Page_Controller();
        pgref.getParameters().put('caid', caseId);
        surveyController = new Core_IPS_Survey_Page_Controller();
        pgref.getParameters().put('stype', 'Customer');
        surveyController = new Core_IPS_Survey_Page_Controller();
        System.runAs(sysadmin){
            update new Case(Id=CaseId,Status='Open'); 
        }
        surveyController = new Core_IPS_Survey_Page_Controller();
        System.runAs(sysadmin){
            update new Case(Id=CaseId,Status='Closed'); 
        }
        surveyController = new Core_IPS_Survey_Page_Controller();
        
        surveyController.captureSurvey();
        
        System.assert([SELECT COUNT() FROM Core_IPS_Response__c]==0);
        surveyController.lstQuestions[0].isRequired = false;
        surveyController.captureSurvey();
        surveyController.backfromWarning();
        surveyController.hasPermissionSet(new Set<String>{userinfo.getProfileId()});
        
    }
    
    static testMethod void Core_IPS_Survey_Page_Controller_negative_test2() {
        Test.startTest();        
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        
        Pagereference pgref = Page.Core_IPS_Survey;
        Test.setCurrentPage(pgref);
        //Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        pgref.getParameters().put('caid', objCase.Id);
        pgref.getParameters().put('stype', 'Customer');
        Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        delete [SELECT Id FROM Core_IPS_Question__c];
        surveyController = new Core_IPS_Survey_Page_Controller();
        System.assert([SELECT COUNT() FROM Core_IPS_Question__c]==0);
        delete objCase;
        surveyController = new Core_IPS_Survey_Page_Controller();
        System.assert([SELECT COUNT() FROM Case]==0);
        Test.stopTest();       
    }
    static testMethod void Core_IPS_Survey_Page_Controller_RedirectTest() {
        Test.startTest();        
        Case objCase = [SELECT Id,Core_IPS_Survey_Captured__c FROM Case LIMIT 1];
        System.assertNotEquals(objCase.Id,null);
        Pagereference pgref = Page.Core_IPS_Survey;
        Test.setCurrentPage(pgref);
        pgref.getParameters().put('caid', objCase.Id);
        Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        surveyController.caseOwnerRedirectPage();
        Test.stopTest();       
    }
    //Added by karthick
    static testMethod void caseOwnerRedirectPage_Test() {
        Test.startTest();        
        
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.ProfileID =  sysAdminProfileID;  
        sysadmin.username='sysAdmin@intel.com.test.' + String.valueOf(System.Now().getTime());     
        sysadmin.Core_User_Country_Code__c ='DEU'; 
        insert sysadmin;
        
        User sysadmin2 = TestUtilities.getUser();
        sysadmin2.ProfileID =  sysAdminProfileID;  
        sysadmin2.username='sysAdmin@intel.com.test.' + String.valueOf(System.Now().getTime());     
        sysadmin2.Core_User_Country_Code__c ='IND'; 
        insert sysadmin2;
        
        Case objCase = [SELECT Id,Core_IPS_Survey_Captured__c,OwnerId FROM Case LIMIT 1];
        objCase.OwnerId=sysadmin.id;
        update objCase;
        
        objCase.OwnerId=sysadmin2.id;
        update objCase;
        
        CaseHistory objectHistory = new CaseHistory(CaseId = objCase.Id, Field = 'Owner');
        insert objectHistory;
        
        
        System.assertNotEquals(objCase.Id,null);
        Pagereference pgref = Page.Core_IPS_Survey;
        Test.setCurrentPage(pgref);
        pgref.getParameters().put('caid', objCase.Id);
        Core_IPS_Survey_Page_Controller surveyController = new Core_IPS_Survey_Page_Controller();
        surveyController.caseOwnerRedirectPage();
        Test.stopTest();       
    }
}