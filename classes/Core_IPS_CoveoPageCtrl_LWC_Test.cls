@isTest
public class Core_IPS_CoveoPageCtrl_LWC_Test {
    @isTest
    public static void generateTokenTest(){
        //Preparing dummy records
        // Profile profileId= [Select Id from profile where Name='IPS External Customer']; 
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        //User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston'+Crypto.getRandomLong()+'@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            Core_WWID__c='12345',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA',
	    RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId()
        );
        insert newAccount;        
        Contact cc = new Contact(  
            FirstName='Joe',
            LastName='Schmoe',
            Email='Joe.Schmoe@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            //Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc;
	system.assert(cc.Id != null);
	Organization orgt = [SELECT Id from Organization limit 1][0];
        Core_IPS_Coveo_TokenGenerator__c custset = new Core_IPS_Coveo_TokenGenerator__c();
        custset.name = 'Core_IPS_Coveo';
        custset.Core_IPS_Coveo_Token__c = 'Bearer xxd645a3c4-d795-40ee-b989-90b6a5a3a51512';
        custset.Core_IPS_CoveoEndpoint__c = 'https://intelcorporationnonproduction2ybdyblf7.org.coveo.com/rest/search/v2/token?organizationId=intelcorporationnonproduction2ybdyblf713';
        insert custset;
        //calling method 
        Test.startTest();
        system.runAs(usr){
            Test.setMock(HttpCalloutMock.class, new authorizedEndpointResponse());
            Core_IPS_CoveoPageCtrl_LWC.generateToken();
        }
        Test.stopTest();
    }
    @TestVisible public class authorizedEndpointResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            Core_IPS_CoveoPageCtrl_LWC.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'RDC Privileged User Internal, ODC User, SFDC A&E User, Employee'}};
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            response.setBody('{"access_token": "afdljasdfa", "token_type":"Bearer", "expires_in":"3599", "ext_expires_in":"3599"}');
            response.setStatusCode(200);
            return response;
        }
    }

}