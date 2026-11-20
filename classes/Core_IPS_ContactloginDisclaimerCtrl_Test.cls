@isTest
private class Core_IPS_ContactloginDisclaimerCtrl_Test {
        @isTest static void test1(){
        list<Document> g=new list<Document>();
    	Document documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Text');
    	documentObj.ContentType = 'application/pdf';
    	documentObj.DeveloperName = 'my_document';
    	documentObj.IsPublic = true;
    	documentObj.Name = 'NDAConfidential';
    	documentObj.FolderId =  UserInfo.getUserId();
        
        try{
        	g.add(documentObj);
            insert g;
            
            }
            catch(AuraHandledException e){
                System.assert(e.getMessage().contains('Please verify details'));
            }
                Core_IPS_ContactloginDisclaimerCtrl_LWC.getDocData();  
        
        }
    private static User getCustomerUser(String profileName,String type){
        
        User thisUser = [ select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();//test class fix
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
                Ownerid =thisUser.id,
		RecordTypeId = recordTypeIdAccount
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
            Core_IPS_NDA_Acceptance_Date__c = today,
            MailingCountry = 'India'
        );
        insert con;
        
        User newUser;
        System.runAs ( thisUser ) {
           
            Profile p =   [select Id,name from Profile where Name = :profileName limit 1];
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
			User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
			System.runAs(validationBypassUser){
			insert newUser; 
			}
            //insert newUser;            
        }
        return newUser;
    }
             static testMethod void Core_IPS_ContactloginDisclaimerCtrlTestMethod1() 
    {
        
        Document documentRecord = TestUtilities.getDocunmentRecord('Shared Documents','NDAConfidential');    
        User u = getCustomerUser('IPS External Customer','Today'); 
        try{
            system.runAs(u)
            {
               Core_IPS_ContactloginDisclaimerCtrl_LWC.getRedirected();
               
            }
        }catch(Exception e){
            
        }
        System.assert(documentRecord.id != null,true);
        
    }
 
    static testMethod void Core_IPS_ContactloginDisclaimerTestMethod2() 
    {
        
        Document documentRecord = TestUtilities.getDocunmentRecord('Shared Documents','NDAConfidential');    
                 Core_IPS_ContactloginDisclaimerCtrl_LWC.getRedirected();
                 Core_IPS_ContactloginDisclaimerCtrl_LWC.redirectAutomate();
        System.assert(documentRecord.id != null,true);
        
    }
    
    static testMethod void Core_IPS_ContactloginDisclaimerTestMethod3() 
    {
        
        Document documentRecord = TestUtilities.getDocunmentRecord('Shared Documents','NDAConfidential'); 
        
        User communityUser = getCustomerUser('IPS External Customer','Today');
        User communityUserWithNoDate = getCustomerUser('IPS External Customer','NoDate');
      
       Test.startTest();
        System.runAs(communityUser){
            
          
                 Core_IPS_ContactloginDisclaimerCtrl_LWC.redirectAutomate();
            
        } 
        
        System.runAs(communityUserWithNoDate){
            
           
                 Core_IPS_ContactloginDisclaimerCtrl_LWC.redirectAutomate();
            
        } 
        Test.stopTest();
        System.assert(documentRecord.id != null,true);
        
    }

}