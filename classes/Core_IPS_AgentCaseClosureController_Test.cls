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
        system.assert(ca.id!=null,'Case not created');
        
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
        system.assert(ca.id!=null,'Case not created');
        
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
            system.assert(ca.id!=null,'Case not created');
            
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
        system.assert(ca.id!=null,'Case not created');
        
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
        system.assert(ca.id!=null,'Case not created');
        
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
        system.assert(ca.id!=null,'Case not created');
        
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
    static testmethod void core_IPS_AgentCaseClosureControllerLEX(){
             profile p = [select id,name from profile where name='IT Admin' limit 1];
             Profile p1 = [select id, name from Profile where name='Sales Rep-BB' limit 1];
        User userRecord = new User(
            Alias = 'StdTesto', 
            Email = 'newuserOnlyhere@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId(),
            isActive = true,
            profileid =p.id
        );
       insert userRecord;
        
        User userRecord1 = new User(
            Alias = 'StdTest1', 
            Email = 'newuserOnlyhere1@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing1', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId(),
            isActive = true,
            profileid =p1.id
        );
        insert userRecord1;
        
        system.runAs(userRecord1){
            Case CaseRecord = new Case();
            CaseRecord.Status = 'New';
            CaseRecord.Origin = 'Web';
            CaseRecord.Priority = 'High';
            CaseRecord.Subject = 'TestSubject';
            CaseRecord.Core_Sub_Status__c = 'Close-Pending';
            CaseRecord.Description = 'TestDescription';
            insert CaseRecord;
            system.assert(CaseRecord.id!=null,'Case not created');
            Core_IPS_AgentCaseClosureControllerLEX.initialValidations(CaseRecord.Id);
        }    
        
        Test.startTest();
        system.runAs(userRecord){
            Case CaseRecord = new Case();
            CaseRecord.Status = 'New';
            CaseRecord.Origin = 'Web';
            CaseRecord.Priority = 'High';
            CaseRecord.Subject = 'TestSubject';
            CaseRecord.Core_Sub_Status__c = 'Close-Pending';
            CaseRecord.Description = 'TestDescription';
            insert CaseRecord;
            system.assert(CaseRecord.id!=null,'Case not created');
            
            CaseRecord.Status = 'Open';
            CaseRecord.Core_Sub_Status__c  = 'Close-Pending';
            CaseRecord.Core_IPS_Date_Time_Close_Pending__c = DateTime.Now();
            if(Case.SObjectType.getDescribe().isUpdateable()){
                update CaseRecord;
            }
            Core_IPS_Labels__c label = new Core_IPS_Labels__c ();
            label.name= 'Core_IPS_Close_Pending_SubStatus';
            label.value__c='Close-Pending';
            insert label;
            
            Core_IPS_Labels__c label1 = new Core_IPS_Labels__c ();
            label1.name= 'Core_IPS_Profile_IPS_Agent_Partner';
            label1.value__c='IPS Agent-Partner';
            insert label1;
                        
            Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
            labels.name= 'PUBLIC_TO_CUSTOMERS';
            labels.value__c='Public to Customers';
            insert labels;
            
            Core_IPS_Labels__c Label9 = new Core_IPS_Labels__c ();
            Label9.name= 'PRIVATE_TO_PARTNERS';
            label9.value__c= 'Private to Partner';
            insert label9;
            
            Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
            Label2.name= 'PRIVATE_TO_INTEL';
            label2.value__c= 'Private to Intel';
            insert label2;
            
            Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
            label5.name='Agent';
            label5.value__c='Agent';
            insert label5;
            
            Core_IPS_AgentCaseClosureControllerLEX.initialValidations(CaseRecord.Id);
            Core_IPS_AgentCaseClosureControllerLEX.getAuthorType();
            Core_IPS_AgentCaseClosureControllerLEX.getCaseClosureAccess();
            Core_IPS_AgentCaseClosureControllerLEX.getCaseCloneAccess();
            
        }
       
        
    }
    
    static testmethod void core_IPS_AgentCaseClosureControllerTest7(){
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
        
        Core_IPS_caseClosure_require_value__c value1 = new Core_IPS_caseClosure_require_value__c();
        value1.name ='Intel > Answered General Inquiry';
        insert value1;
        
        Core_IPS_caseClosure_require_value__c value2 = new Core_IPS_caseClosure_require_value__c();
        value2.name ='Intel > No Fix/Not To Be Fixed';
        insert value2;
        
        Core_IPS_caseClosure_require_value__c value3 = new Core_IPS_caseClosure_require_value__c();
        value3.name ='Customer > Duplicate';
        insert value3;
        
        Core_IPS_caseClosure_require_value__c value4 = new Core_IPS_caseClosure_require_value__c();
        value4.name ='Intel > Customized Solution';
        insert value4;
        
        Case ca =  TestUtilities.getCase();
        ca.Core_Case_Closure__c = 'Intel > Customized Solution';
        System.RunAs(agentUser){
            insert ca;
            system.assert(ca.id!=null,'Case not created');
            
            Test.startTest();
            
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            
            Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
            caseClose.ClosureComments = 'Test';
            caseClose.caseRTName = 'Core_IPS_Case_Create_Self_Assigned';                  
            Pagereference pg = caseClose.RequestCaseClosure();                       
            caseClose.displayClosureDetails();                    
        }
        Test.stopTest();
        
      }
      
      static testmethod void core_IPS_AgentCaseClosureControllerTest8(){
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
        
        Core_IPS_caseClosure_require_value__c value1 = new Core_IPS_caseClosure_require_value__c();
        value1.name ='Intel > Answered General Inquiry';
        insert value1;
        
        Core_IPS_caseClosure_require_value__c value2 = new Core_IPS_caseClosure_require_value__c();
        value2.name ='Intel > No Fix/Not To Be Fixed';
        insert value2;
        
        Core_IPS_caseClosure_require_value__c value3 = new Core_IPS_caseClosure_require_value__c();
        value3.name ='Customer > Duplicate';
        insert value3;
        
        Core_IPS_caseClosure_require_value__c value4 = new Core_IPS_caseClosure_require_value__c();
        value4.name ='Intel > Customized Solution';
        insert value4;
        
        Case ca =  TestUtilities.getCase();
        ca.Core_Case_Closure__c = 'Intel > Known Issue';
        System.RunAs(agentUser){
            insert ca;
            system.assert(ca.id!=null,'Case not created');
            
            Test.startTest();
            
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            
            Core_IPS_AgentCaseClosureController caseClose = new Core_IPS_AgentCaseClosureController(StndContr);
            caseClose.ClosureComments = 'Test';
            caseClose.caseRTName = 'Core_IPS_Case_Create_Self_Assigned';
            //caseClose.dispClosureDetails = true;            
            Pagereference pg = caseClose.RequestCaseClosure();                       
            caseClose.displayClosureDetails();                 
        }
        Test.stopTest();
        
      }
        
}