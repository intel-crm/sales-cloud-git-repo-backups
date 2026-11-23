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
        User u = getCustomerUser('IPS External Customer','Today'); 
        try{
            system.runAs(u)
            {
                Core_IPS_ContactloginDisclaimer Disclaimer =  new Core_IPS_ContactloginDisclaimer();
                Disclaimer.cancel();
                PageReference Pg = Disclaimer.redirect();
            }
        }catch(Exception e){
            
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
        
        User CommunityUser = getCustomerUser('IPS External Customer','Today');
        User CommunityUserwithNoDate = getCustomerUser('IPS External Customer','NoDate');
        
        // creating Customer community  user
       Test.startTest();
        System.runAs(CommunityUser){
            
            Core_IPS_ContactloginDisclaimer Disclaimer =  new Core_IPS_ContactloginDisclaimer();
            
            Pagereference Pg = Disclaimer.redirectAutomate();
            
        } 
        
        System.runAs(CommunityUserwithNoDate){
            
            Core_IPS_ContactloginDisclaimer Disclaimer =  new Core_IPS_ContactloginDisclaimer();
            
            Pagereference Pg = Disclaimer.redirectAutomate();
            
        } 
        Test.stopTest();
        
        
    }
    
    private static User getCustomerUser(String profileName,String type){
        
        User thisUser = [ select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            // Modified for DE55770 
            Account acc = new Account (
                Name = 'newAcc1'+type,
                BillingCity = 'folsom'+type,
                BillingCountry = 'USA',
                BillingStreet = 'Creek Side Dr',
                BillingState = 'NV',
                BillingPostalCode = '591213',
                Core_CIM_ID__c = '11429344',
                Core_B2B_Entitlement__c = true,
                Core_Account_Legal_Name__c = 'TestLegalName',
                Ownerid =thisUser.id
            );  
        insert acc;
        
        Date today;
        
        if(type=='Today')
        	today= system.today();
        
        Contact con = new Contact (
            AccountId = acc.id,
            FirstName = 'portia'+type,
            LastName  = 'portalTestUser',
            email     = 'pb@ff'+type +'.com',
            Core_IPS_NDA_Acceptance_Date__c = today
        );
        insert con;
        
        User newUser;
        System.runAs ( thisUser ) {
            // UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
            Profile p =   [select Id,name from Profile where Name = :profileName limit 1];
            system.debug('>>>>>>>>>>>>>>>' + p);
            newUser = new User(
                //UserRoleId = ur.Id,
                profileId = p.id,
                username = 'newUser@yahoo.com'+type,
                email = 'pb@ff.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
            );
            system.debug(newUser);
            insert newUser;            
        }
        return newUser;
    }
}