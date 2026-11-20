//CommunityCaseClosureController

@isTest
public class CommunityCaseClosureController_Test {

    static Case createTestCase(User caseOwner) {
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Case ca;
        System.runAs(adminUser) {
            ca = TestUtilities.getCase(); 
            ca.OwnerId = caseOwner.Id;
            insert ca;
        }
        return ca;
    }

    static testmethod void communityCaseClosureControllerTest1(){
       
        User communityUser = TestUtilities.getCustomerUser('IPS External Customer');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        // Create test data as admin
        Case ca = createTestCase(communityUser);
        
        // Run test as admin (has access to all objects and fields)
        System.runAs(adminUser){
            
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
            ApexPages.StandardController stndContr = new ApexPages.standardController(ca);
            
            CommunityCaseClosureController caseClose = new CommunityCaseClosureController(stndContr);
            PageReference pg = caseClose.requestCaseClosure();
            pg  = caseClose.cancelOperation();
            Test.stopTest();
        }
    }
    
    static testmethod void communityCaseClosureControllerTest2(){
       
        User communityUser = TestUtilities.getCustomerUser('IPS External Customer');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        // Create test data as admin
        Case ca = createTestCase(communityUser);
        
        // Run test as admin (has access to all objects and fields)
        System.runAs(adminUser){
            
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
            
            ApexPages.StandardController stndContr = new ApexPages.standardController(ca);
            
            CommunityCaseClosureController caseClose = new CommunityCaseClosureController(stndContr);
            PageReference pg = caseClose.requestCaseClosure();
            pg = caseClose.cancelOperation();
            Test.stopTest();
        }
    }
    
    static testmethod void communityCaseClosureControllerTest3(){
       
        User communityUser = TestUtilities.getCustomerUser('IPS External Customer');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        // Create test data as admin with specific sub-status
        Case ca;
        System.runAs(adminUser) {
            ca = TestUtilities.getCase();
            ca.OwnerId = communityUser.Id;
            ca.Core_Sub_Status__c = CommunityCaseClosureController.CUSTOMER_REQUESTING_CLOSE;
            insert ca;
        }
        
        // Run test as admin (has access to all objects and fields)
        System.runAs(adminUser){
            
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
            
            ApexPages.StandardController stndContr = new ApexPages.standardController(ca);
            
            CommunityCaseClosureController caseClose = new CommunityCaseClosureController(stndContr);
            PageReference pg = caseClose.requestCaseClosure();
            pg = caseClose.cancelOperation();
            Test.stopTest();
        }
    }
       
}