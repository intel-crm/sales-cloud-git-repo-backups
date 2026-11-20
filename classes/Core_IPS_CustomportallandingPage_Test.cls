@isTest
public class Core_IPS_CustomportallandingPage_Test{

static testmethod void Core_IPS_CustomportallandingPageTest1(){
       
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        // creating Customer community  user
       System.runAs(CommunityUser){
             
            Test.startTest();
            
            
            
             //commented for classic EOL: Tejaswini 
          /*  Core_IPS_CustomportallandingPage landingPage = new Core_IPS_CustomportallandingPage();
             landingPage.PageInit();*/
            //Pg  = caseClose.CancelOperation();
            Test.stopTest();
       }
        // Creating Product Record
        
        
        
    }
    static testmethod void Core_IPS_CustomportallandingPageTest2(){
       
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        
        Contact c =  [select id,Core_IPS_NDA_Acceptance_Date__c from contact where id =:CommunityUser.contactId];
        c.Core_IPS_NDA_Acceptance_Date__c = system.today();
        update c;
        // creating Customer community  user
       System.runAs(CommunityUser){
             
            Test.startTest();
            
             //commented for classic EOL: Tejaswini 
          /*  Core_IPS_CustomportallandingPage landingPage = new Core_IPS_CustomportallandingPage();
             landingPage.PageInit();*/
            //Pg  = caseClose.CancelOperation();
            Test.stopTest();
       }
        // Creating Product Record
        
        
        
    }
     static testmethod void Core_IPS_CustomportallandingPageTest3(){
       
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        
        Contact c =  [select id,Core_IPS_NDA_Acceptance_Date__c from contact where id =:CommunityUser.contactId];
        c.Core_IPS_NDA_Acceptance_Date__c = system.today().addDays(-95);
        update c;
        // creating Customer community  user
       System.runAs(CommunityUser){
             
            Test.startTest();
            
            
             //commented for classic EOL: Tejaswini 
          /*  Core_IPS_CustomportallandingPage landingPage = new Core_IPS_CustomportallandingPage();
             landingPage.PageInit();*/
            //Pg  = caseClose.CancelOperation();
            Test.stopTest();
       }
        // Creating Product Record
        
        
        
    }
}