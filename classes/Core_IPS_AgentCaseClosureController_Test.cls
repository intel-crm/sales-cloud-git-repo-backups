/***************************************************************************************************
Class Name:  Core_IPS_AgentCaseClosureController_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 12 Dec 2017
Function    : This class contains test coverage for Core_IPS_AgentCaseClosureController class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_AgentCaseClosureController class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    12/12/2017              Created(UserStory US72550 Iteration 4)
****************************************************************************************************/   
@isTest
public class Core_IPS_AgentCaseClosureController_Test{
      static testmethod void AgentCaseClosureControllerTest1(){                 
            Case ca =  TestUtilities.getCase();
            insert ca;

            Test.startTest();
            PageReference pageRef = Page.Core_IPS_AgentCaseClosure;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
            Pagereference pg = caseClose.RequestCaseClosure();
            pg  = caseClose.CancelOperation();
            Test.stopTest();     
    }
    static testmethod void AgentCaseClosureControllerTest2(){                 
            Case ca =  TestUtilities.getCase();
            insert ca;
             // Insert IPS Labels
            List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c IL: IPSLabels){
                if(IL.name=='Core_IPS_Close_Pending_SubStatus'){
                     IL.Value__c = 'Close-Pending';
                }
                if(IL.name=='PUBLIC_TO_CUSTOMERS')
                {
                    IL.Value__c = 'PUBLIC_TO_CUSTOMERS';
                }             
            }
            insert IPSLabels;
            
            Test.startTest();
            PageReference pageRef = Page.Core_IPS_AgentCaseClosure;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
            caseClose.ClosureComments = 'Test';
            caseClose.Close_Pending_SubStatus  = 'Close-Pending';
            Pagereference pg = caseClose.RequestCaseClosure();
            Core_IPS_AgentCaseClosureController caseClose1 = new Core_IPS_AgentCaseClosureController(StndContr);
            
            Test.stopTest();     
    }
    static testmethod void AgentCaseClosureControllerTest3(){     
            User agentUser = TestUtilities.getUser();
            profile p=[select id,name from profile where name='IPS Agent' limit 1];
            agentUser.profileid =p.id;
            insert agentUser;
            
            // Insert IPS Labels
            List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c IL: IPSLabels){
                if(IL.name=='Core_IPS_Close_Pending_SubStatus'){
                     IL.Value__c = 'Close-Pending';
                }
                if(IL.name=='Core_IPS_No_Ass_Contact_Case_RT'){
                     IL.Value__c = 'Core_IPS_Case_Create_Self_Assigned';
                }
                if(IL.name=='PUBLIC_TO_CUSTOMERS')
                {
                    IL.Value__c = 'PUBLIC_TO_CUSTOMERS';
                } 
                if(IL.name=='Agent')
                {
                    IL.Value__c = 'Agent';
                }
            }
            insert IPSLabels;
            
            Case ca =  TestUtilities.getCase();
            
           System.RunAs(agentUser){
            insert ca;
            
            Test.startTest();
            
                PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
                Test.setCurrentPage(pageRef);
                ApexPages.CurrentPage().getparameters().put('id', ca.id);
                
                ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
                
                Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
                caseClose.ClosureComments = 'Test';
                caseClose.caseRTName = 'Core_IPS_Case_Create_Self_Assigned';
                Pagereference pg = caseClose.RequestCaseClosure();
                pg = caseClose.CancelOperation();
            }
            Test.stopTest();
       
    }
    static testmethod void AgentCaseClosureControllerTest4(){ 
        Case ca =  TestUtilities.getCase();
        insert ca;
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_AgentCaseClosure;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id', null);
        ApexPages.CurrentPage().getparameters().put('retURL', null);
        ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
        
        Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
        
        Test.stopTest();   
    }   
    static testmethod void AgentCaseClosureControllerTest5(){ 
        User FAEUser = TestUtilities.getUser();
        profile p=[select id,name from profile where name='Sales Manager' limit 1];
        FAEUser.profileid =p.id;
        insert FAEUser;
        
        Case ca =  TestUtilities.getCase();
        insert ca;
        
        Test.startTest();
        system.runAs(FAEUser){
            PageReference pageRef = Page.Core_IPS_AgentCaseClosure;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
        }
        Test.stopTest();   
    } 
    static testmethod void AgentCaseClosureControllerTest6(){ 
        User FAEUser = TestUtilities.getUser();
        profile p=[select id,name from profile where name='Sales Rep-BB-Dual IPS' limit 1];
        FAEUser.profileid =p.id;
        insert FAEUser;
        
        Case ca =  TestUtilities.getCase();
        insert ca;
        
        Test.startTest();
        system.runAs(FAEUser){
            PageReference pageRef = Page.Core_IPS_AgentCaseClosure;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
        }
        Test.stopTest();   
    } 

}