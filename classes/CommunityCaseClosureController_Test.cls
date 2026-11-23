//CommunityCaseClosureController

@isTest
public class CommunityCaseClosureController_Test {

    static testmethod void CommunityCaseClosureControllerTest1(){
       
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        
        // creating Customer community  user
        System.runAs(CommunityUser){
                   
            Case ca =  TestUtilities.getCase(); 
            ca.OwnerId = CommunityUser.Id;
            insert ca;
            
            Core_IPS_Labels__c label = new Core_IPS_Labels__c();
            label.name='PUBLIC_TO_CUSTOMERS';
            label.Value__c='Public to Customers';
            insert label;

Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
            label1.name='Customer';
            label1.Value__c='Customer';
            insert label1;
            
            Test.startTest();
            System.debug('#41 ca: ' + ca);
            System.debug('#42 CommunityUser.Id: ' + CommunityUser.Id);
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            ApexPages.CurrentPage().getparameters().put('retURL', ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            CommunityCaseClosureController caseClose = new CommunityCaseClosureController(StndContr);
            Pagereference pg = caseClose.RequestCaseClosure();
            pg  = caseClose.CancelOperation();
            Test.stopTest();
        }
    }
    
    
    static testmethod void CommunityCaseClosureControllerTest2(){
       
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        
        // creating Customer community  user
        System.runAs(CommunityUser){
             
            Case ca =  TestUtilities.getCase();
            ca.OwnerId = CommunityUser.Id;
            insert ca;
            
            Core_IPS_Labels__c label = new Core_IPS_Labels__c();
            label.name='PUBLIC_TO_CUSTOMERS';
            label.Value__c='Public to Customers';
            insert label;
            
            Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
            label1.name='Customer';
            label1.Value__c='Customer';
            insert label1;

            Test.startTest();
            System.debug('#21 ca: ' + ca);
            System.debug('#22 CommunityUser.Id: ' + CommunityUser.Id);
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            CommunityCaseClosureController caseClose = new CommunityCaseClosureController(StndContr);
            Pagereference pg = caseClose.RequestCaseClosure();
            pg = caseClose.CancelOperation();
            system.debug(caseClose.ClosureComments);
            Test.stopTest();
       }
    }
    
    static testmethod void CommunityCaseClosureControllerTest3(){
       
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        
        // creating Customer community  user
        System.runAs(CommunityUser){
             
            Case ca =  TestUtilities.getCase();
            ca.OwnerId = CommunityUser.Id;
            ca.Core_Sub_Status__c = CommunityCaseClosureController.CUSTOMER_REQUESTING_CLOSE;
            insert ca;
            
            Core_IPS_Labels__c label = new Core_IPS_Labels__c();
            label.name='Customer';
            label.Value__c='Customer';
            insert label;
            
             Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
            label1.name='PUBLIC_TO_CUSTOMERS';
            label1.Value__c='Public to Customers';
            insert label1;

            Test.startTest();            
            System.debug('#21 ca: ' + ca);
            System.debug('#22 CommunityUser.Id: ' + CommunityUser.Id);
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', ca.id);
            
            ApexPages.StandardController StndContr = new ApexPages.standardController(ca);
            
            CommunityCaseClosureController caseClose = new CommunityCaseClosureController(StndContr);
            Pagereference pg = caseClose.RequestCaseClosure();
            pg = caseClose.CancelOperation();
            Test.stopTest();
       }
    }
       
}