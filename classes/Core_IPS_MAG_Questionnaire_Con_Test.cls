/***************************************************************************************************
Class Name:  Core_IPS_MAG_Questionnaire_Con_Test
Class Type: Test Class 
Version     : 1.0 
Description:   This class contains unit test scenarios for Core_IPS_MAG_Questionnaire_Controller class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    17/08/2018               Created(UserStory# Iteration 15)
****************************************************************************************************/   
@isTest
public class Core_IPS_MAG_Questionnaire_Con_Test {

    
    
    @testSetup 
    static void TestData() {
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.ProfileID =  sysAdminProfileID;  
        sysadmin.username='intel.com.crm@intel.com';  
        //sysadmin.Core_User_Country_Code__c ='DEU';     
        insert sysadmin;
        
        System.runAs(sysadmin) {
            Case objCase = TestUtilities.getCase();
            objCase.RecordTypeId = schema.sobjecttype.Case.getrecordtypeinfosbyname().get('IPS Case Create').getRecordTypeId();
            insert objCase;
            
            Id magRecordTypeId = schema.sobjecttype.Core_IPS_Question__c.getrecordtypeinfosbyname().get('MAG Question').getRecordTypeId();
            List<Core_IPS_Question__c> lstQues = new List<Core_IPS_Question__c>();
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=magRecordTypeId, Core_IPS_Order_No__c=1, Core_IPS_Question__c='Question 1', Core_IPS_DataType__c='Picklist', Core_IPS_Status__c = 'Active'));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=magRecordTypeId, Core_IPS_Order_No__c=2, Core_IPS_Question__c='Question 2', Core_IPS_DataType__c='Multiselect Picklist', Core_IPS_Status__c = 'Active'));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=magRecordTypeId, Core_IPS_Order_No__c=3, Core_IPS_Question__c='Question 3', Core_IPS_DataType__c='Text Area', Core_IPS_Status__c = 'Active',Core_IPS_Required__c=True));
            insert lstQues;
            
            List<Core_IPS_Answer__c> lstAns = new List<Core_IPS_Answer__c>();
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=1, Core_IPS_Answer__c='Yes'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=2, Core_IPS_Answer__c='No'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[1].Id, Core_IPS_Order_No__c=3, Core_IPS_Answer__c='None'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[1].Id, Core_IPS_Order_No__c=4, Core_IPS_Answer__c='MSP1'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[1].Id, Core_IPS_Order_No__c=4, Core_IPS_Answer__c='MSP2'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[2].Id, Core_IPS_Order_No__c=4, Core_IPS_Answer__c='MSP3'));
            insert lstAns;
            
            lstQues[0].Core_IPS_Environment_Detail_Answer__c = lstAns[0].id;
            lstQues[1].Core_IPS_Environment_Detail_Answer__c = lstAns[2].id;
            lstQues[2].Core_IPS_Environment_Detail_Answer__c = lstAns[5].id;
            update lstQues;
            
            List<Core_IPS_Response__c> lstResponse = new List<Core_IPS_Response__c>();
            lstResponse.add(new Core_IPS_Response__c(Core_IPS_Case__c=objCase.id,Core_IPS_Question_Master__c=lstQues[0].id,Core_IPS_Answer_Master__c=lstAns[0].id));
            lstResponse.add(new Core_IPS_Response__c(Core_IPS_Case__c=objCase.id,Core_IPS_Question_Master__c=lstQues[1].id,Core_IPS_Answer_Master__c=lstAns[1].id));
            lstResponse.add(new Core_IPS_Response__c(Core_IPS_Case__c=objCase.id,Core_IPS_Question_Master__c=lstQues[1].id,Core_IPS_Answer_Master__c=lstAns[2].id));
            insert lstResponse;
            
            Core_IPS_Labels__c objLabel = new Core_IPS_Labels__c(Name='Core_IPS_MSP_Order', Value__c='2');
            insert objLabel;
            Core_IPS_Labels__c objLabel2 = new Core_IPS_Labels__c(Name='MINDS_Questionnaire_Completed', Value__c='MAG Questionnaire Completed');
            insert objLabel2 ;
        }
    }  
    
    static testmethod void MAG_Questionnaire_ConTest1(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);       
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.selectedAnswerOrder = '1';
        Pagereference pg = con.saveAnswer();       
        con.renderDependentQuestions();        
        Test.stopTest();     
    }
    
     static testmethod void MAG_Questionnaire_ConTest11(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);       
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.selectedAnswerOrder = '2';
        Pagereference pg = con.saveAnswer();       
        con.renderDependentQuestions();        
        Test.stopTest();     
    }
    
    
    static testmethod void MAG_Questionnaire_ConTest4(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c  FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.selectedAnswerOrder = '2';     
        Pagereference pg = con.saveAnswer();
        pg  = con.CancelOperation();
        con.renderDependentQuestions();
        con.selectedTextVal = 'MSP1';
        con.renderMSPDepQues();
        Test.stopTest();     
    }
    
    //When case id is not passed as parameter, Error will be thrown.
    static testmethod void MAG_Questionnaire_ConTest5(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);      
        Pagereference pg = con.saveAnswer();
        Test.stopTest();     
    }
    
     //When MSP is empty, and saved
    static testmethod void MAG_Questionnaire_ConTest6(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.lstQuestions[1].dependentQues = False;
        con.lstQuestions[1].required = true;
        con.lstQuestions[1].selectedValues = null;       
        Pagereference pg = con.saveAnswer();
        Test.stopTest();     
    }
    
     static testmethod void MAG_Questionnaire_ConTest10(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.lstQuestions[2].dependentQues = False;
        con.lstQuestions[2].required = true;
        con.lstQuestions[2].answer= null;       
        Pagereference pg = con.saveAnswer();
        Test.stopTest();     
    }
       
        static testmethod void MAG_Questionnaire_ConTest8(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.lstQuestions[1].dependentQues = False;
        con.lstQuestions[1].required = true;
        con.lstQuestions[1].selectedValues = new List<String>();
        con.lstQuestions[0].answer = '';
        Pagereference pg = con.saveAnswer();
        Test.stopTest();     
    }
    
    static testmethod void MAG_Questionnaire_ConTest7(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        con.lstQuestions[0].dependentQues = False;
        con.lstQuestions[0].required = true;
        con.lstQuestions[0].answer = '';
        con.lstQuestions[1].selectedValues = new List<String>();
        Pagereference pg = con.saveAnswer();
        Test.stopTest();     
    }
    
    static testmethod void MAG_Questionnaire_ConTest9(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);       
        con.lstQuestions[1].selectedValues = new List<String>();
        Pagereference pg = con.saveAnswer();
        Test.stopTest();     
    }
       
   /* static testmethod void MAG_Questionnaire_ConTest2(){
        Case ca = new Case();
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        Test.stopTest();     
    }*/
    
    static testmethod void MAG_Questionnaire_ConTest3(){
        Case ca = [SELECT Id,Core_Sub_Status__c,Status FROM Case LIMIT 1];
        List<Core_IPS_Question__c> lstQ = [Select id from Core_IPS_Question__c];
        List<Core_IPS_Response__c> lstR = [Select id from Core_IPS_Response__c];
        Test.startTest();
        
        PageReference pageRef = Page.Core_IPS_MAG_Questionnaire;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', ca.id);
        ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
        Delete lstR;
        Delete lstQ;
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        Core_IPS_MAG_Questionnaire_Controller con = new Core_IPS_MAG_Questionnaire_Controller(StndContr);
        Test.stopTest();     
    }
}