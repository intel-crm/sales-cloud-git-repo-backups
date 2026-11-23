@istest
public class Core_IPS_ContactloginDisclaimer_Test
{
   /*
     for the class Core_IPS_ContactloginDisclaimer
     covering following methods   
     1. Cancel method
     2. redirect
   */
  static testMethod void Core_IPS_ContactloginDisclaimerTestMethod1() 
  {
  
       Document Doc = TestUtilities.getDocunmentRecord('Shared Documents','NDAConfidential');    
       //User u = TestUtilities.getCustomerUser('IPS External Customer'); 
       //system.runAs(u)
       {
         Core_IPS_ContactloginDisclaimer Disclaimer =  new Core_IPS_ContactloginDisclaimer();
         Disclaimer.cancel();
         PageReference Pg = Disclaimer.redirect();
       }
       
  }
  /*
     for the class Core_IPS_ContactloginDisclaimer
     covering following methods   
     1. redirectAutomate
     2. redirect
   */
  static testMethod void Core_IPS_ContactloginDisclaimerTestMethod2() 
  {
  
       Document Doc = TestUtilities.getDocunmentRecord('Shared Documents','NDAConfidential');    
       //User u = TestUtilities.getCustomerUser('IPS External Customer'); 
       //system.runAs(u)
       //{
         Core_IPS_ContactloginDisclaimer Disclaimer =  new Core_IPS_ContactloginDisclaimer();
         //Disclaimer.cancel();
         PageReference Pg =   Disclaimer.redirect();
         Pg = Disclaimer.redirectAutomate();
       //}
       
  }
  /*
     for the class Core_IPS_ContactloginDisclaimer
     covering following methods   
     1. redirectAutomate
     
   */
  static testMethod void Core_IPS_ContactloginDisclaimerTestMethod3() 
  {
  
       Document Doc = TestUtilities.getDocunmentRecord('Shared Documents','NDAConfidential');   

       User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        // creating Customer community  user
       System.runAs(CommunityUser){
             
            Test.startTest();
            
            
            Core_IPS_ContactloginDisclaimer Disclaimer =  new Core_IPS_ContactloginDisclaimer();
             
           Pagereference Pg = Disclaimer.redirectAutomate();
            Test.stopTest();
       }       
      
       
  }
}