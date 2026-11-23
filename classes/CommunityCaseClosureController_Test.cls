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
            
            Core_IPS_Labels__c label11 = new Core_IPS_Labels__c(name='PRIVATE_TO_PARTNERS',Value__c='PRIVATE_TO_PARTNERS');            
            insert label11;            
            Core_IPS_Labels__c label12 = new Core_IPS_Labels__c(name='PRIVATE_TO_INTEL',Value__c='PRIVATE_TO_INTEL');            
            insert label12;
			
            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
            label6.name='Backend Integration';
            label6.Value__c='Backend Integration';
            insert label6;
            
            Core_IPS_Labels__c label31 = new Core_IPS_Labels__c(name='Comment Source - Email',Value__c='Comment Source - Email');            
            insert label31;            
            Core_IPS_Labels__c label32 = new Core_IPS_Labels__c(name='Comment Source - Backend System',Value__c='Comment Source - Backend System');            
            insert label32;
            Core_IPS_Labels__c label13 = new Core_IPS_Labels__c(name='Comment Source - Data Migration',Value__c='Comment Source - Data Migration');            
            insert label13;
            Core_IPS_Labels__c label14 = new Core_IPS_Labels__c(name='Comment Source - Internal',Value__c='Comment Source - Internal');            
            insert label14;
            Core_IPS_Labels__c label15 = new Core_IPS_Labels__c(name='Comment Source - N/A',Value__c='Comment Source - N/A');            
            insert label15;
            Core_IPS_Labels__c label16 = new Core_IPS_Labels__c(name='Agent',Value__c='Agent');            
            insert label16;
            Core_IPS_Labels__c label17 = new Core_IPS_Labels__c(name='Data Migration',Value__c='Data Migration');            
            insert label17;
            Core_IPS_Labels__c label20 = new Core_IPS_Labels__c(name='FAE',Value__c='FAE');            
            insert label20;
            Core_IPS_Labels__c label18 = new Core_IPS_Labels__c(name='Partner - DFAE',Value__c='Partner - DFAE');            
            insert label18;
            Core_IPS_Labels__c label19 = new Core_IPS_Labels__c(name='Partner - Agent',Value__c='Partner - Agent');            
            insert label19;
            Core_IPS_Labels__c label22 = new Core_IPS_Labels__c(name='Partner',Value__c='Partner');            
            insert label22;
            Core_IPS_Labels__c label23 = new Core_IPS_Labels__c(name='Comment Source - Customer',Value__c='Comment Source - Customer');            
            insert label23;
            
            Test.startTest();
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
			
                        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c(name='PRIVATE_TO_PARTNERS',Value__c='PRIVATE_TO_PARTNERS');            
            insert label11;            
            Core_IPS_Labels__c label12 = new Core_IPS_Labels__c(name='PRIVATE_TO_INTEL',Value__c='PRIVATE_TO_INTEL');            
            insert label12;
			
            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
            label6.name='Backend Integration';
            label6.Value__c='Backend Integration';
            insert label6;
            
            Core_IPS_Labels__c label31 = new Core_IPS_Labels__c(name='Comment Source - Email',Value__c='Comment Source - Email');            
            insert label31;            
            Core_IPS_Labels__c label32 = new Core_IPS_Labels__c(name='Comment Source - Backend System',Value__c='Comment Source - Backend System');            
            insert label32;
            Core_IPS_Labels__c label13 = new Core_IPS_Labels__c(name='Comment Source - Data Migration',Value__c='Comment Source - Data Migration');            
            insert label13;
            Core_IPS_Labels__c label14 = new Core_IPS_Labels__c(name='Comment Source - Internal',Value__c='Comment Source - Internal');            
            insert label14;
            Core_IPS_Labels__c label15 = new Core_IPS_Labels__c(name='Comment Source - N/A',Value__c='Comment Source - N/A');            
            insert label15;
            Core_IPS_Labels__c label16 = new Core_IPS_Labels__c(name='Agent',Value__c='Agent');            
            insert label16;
            Core_IPS_Labels__c label17 = new Core_IPS_Labels__c(name='Data Migration',Value__c='Data Migration');            
            insert label17;
            Core_IPS_Labels__c label20 = new Core_IPS_Labels__c(name='FAE',Value__c='FAE');            
            insert label20;
            Core_IPS_Labels__c label18 = new Core_IPS_Labels__c(name='Partner - DFAE',Value__c='Partner - DFAE');            
            insert label18;
            Core_IPS_Labels__c label19 = new Core_IPS_Labels__c(name='Partner - Agent',Value__c='Partner - Agent');            
            insert label19;
            Core_IPS_Labels__c label22 = new Core_IPS_Labels__c(name='Partner',Value__c='Partner');            
            insert label22;
            Core_IPS_Labels__c label23 = new Core_IPS_Labels__c(name='Comment Source - Customer',Value__c='Comment Source - Customer');            
            insert label23;
            
            Test.startTest();
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

                        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c(name='PRIVATE_TO_PARTNERS',Value__c='PRIVATE_TO_PARTNERS');            
            insert label11;            
            Core_IPS_Labels__c label12 = new Core_IPS_Labels__c(name='PRIVATE_TO_INTEL',Value__c='PRIVATE_TO_INTEL');            
            insert label12;
			
            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
            label6.name='Backend Integration';
            label6.Value__c='Backend Integration';
            insert label6;
            
            Core_IPS_Labels__c label31 = new Core_IPS_Labels__c(name='Comment Source - Email',Value__c='Comment Source - Email');            
            insert label31;            
            Core_IPS_Labels__c label32 = new Core_IPS_Labels__c(name='Comment Source - Backend System',Value__c='Comment Source - Backend System');            
            insert label32;
            Core_IPS_Labels__c label13 = new Core_IPS_Labels__c(name='Comment Source - Data Migration',Value__c='Comment Source - Data Migration');            
            insert label13;
            Core_IPS_Labels__c label14 = new Core_IPS_Labels__c(name='Comment Source - Internal',Value__c='Comment Source - Internal');            
            insert label14;
            Core_IPS_Labels__c label15 = new Core_IPS_Labels__c(name='Comment Source - N/A',Value__c='Comment Source - N/A');            
            insert label15;
            Core_IPS_Labels__c label16 = new Core_IPS_Labels__c(name='Agent',Value__c='Agent');            
            insert label16;
            Core_IPS_Labels__c label17 = new Core_IPS_Labels__c(name='Data Migration',Value__c='Data Migration');            
            insert label17;
            Core_IPS_Labels__c label20 = new Core_IPS_Labels__c(name='FAE',Value__c='FAE');            
            insert label20;
            Core_IPS_Labels__c label18 = new Core_IPS_Labels__c(name='Partner - DFAE',Value__c='Partner - DFAE');            
            insert label18;
            Core_IPS_Labels__c label19 = new Core_IPS_Labels__c(name='Partner - Agent',Value__c='Partner - Agent');            
            insert label19;
            Core_IPS_Labels__c label22 = new Core_IPS_Labels__c(name='Partner',Value__c='Partner');            
            insert label22;
            Core_IPS_Labels__c label23 = new Core_IPS_Labels__c(name='Comment Source - Customer',Value__c='Comment Source - Customer');            
            insert label23;
            
            Test.startTest();            
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