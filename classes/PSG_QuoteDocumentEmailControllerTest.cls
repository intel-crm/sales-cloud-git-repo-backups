@isTest
public class PSG_QuoteDocumentEmailControllerTest {
    
    /*@testSetup 
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='quoteDocument@example.com', 
                          EmailEncodingKey='UTF-8', LastName='quoteDocumentUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='quoteDocument@testorg.com');
        insert u;
        Account acc = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc.Id);
        List<SBQQ__Quote__c> quote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c();
        quoteTemplate.Name = 'Test Template';
        quoteTemplate.SBQQ__DeploymentStatus__c = 'Deployed';
        insert quoteTemplate;
        
        SBQQ__QuoteDocument__c  quoteDocument = new SBQQ__QuoteDocument__c();
        quoteDocument.SBQQ__Quote__c = quote[0].Id;
        quoteDocument.SBQQ__QuoteTemplate__c = quoteTemplate.Id;
        quoteDocument.SBQQ__Version__c = 1;
        insert quoteDocument;
    }
    
    @isTest 
    static void testGetRequestorEmail() {
        SBQQ__QuoteDocument__c quoteDoc = [SELECT Id from SBQQ__QuoteDocument__c LIMIT 1];
        PSG_QuoteDocumentEmailController.getInitDetails(quoteDoc.Id); 
        Assert.isNotNull(quoteDoc,'quote is not null');
    }
     /*
    @isTest
    static void testGetBodySubject(){
        SBQQ__QuoteDocument__c quoteDoc = [SELECT Id from SBQQ__QuoteDocument__c LIMIT 1];
        String recordId = quoteDoc.Id;
        PSG_QuoteDocumentEmailController.getBodySubject(recordId);
    }
    */
    /*
    @isTest 
    static void testGetAvailableContact() {
        List<PSG_QuoteDocumentEmailController.ContactWrapper> cw = new List<PSG_QuoteDocumentEmailController.ContactWrapper>();
        cw = PSG_QuoteDocumentEmailController.getAvailableContact();
    }
	*/
    
    /*@isTest 
    static void testSearchContactOrUser() {
        Contact con = [SELECT Id,Name from Contact];
        List<PSG_QuoteDocumentEmailController.ContactWrapper> cw = new List<PSG_QuoteDocumentEmailController.ContactWrapper>();
        cw = PSG_QuoteDocumentEmailController.searchContactOrUser(con.Name,'Contact');
        User u = [SELECT Id, Name,UserName FROM User where UserName='quoteDocument@testorg.com'];
        cw = PSG_QuoteDocumentEmailController.searchContactOrUser(u.Name,'User');
        Assert.areEqual('quotedocument@testorg.com',u.Username,'Username is checked');
    }
    
    @isTest
    static void testsendEmailController(){
        SBQQ__QuoteDocument__c quoteDoc = [SELECT Id from SBQQ__QuoteDocument__c LIMIT 1];
        String recordId = quoteDoc.Id;
        List<Contact> con = [SELECT Id,Email from Contact];
        List<String> emailTo = new List<String>();
        List<String> emailCc = new List<String>();
        List<String> emailBcc = new List<String>();
        emailTo.add(con[0].Email);
        emailCc.add(con[0].Email);
        emailBcc.add(con[0].Email);
        PSG_QuoteDocumentEmailController.sendEmailController(recordId,emailTo,emailCc,emailBcc);
        Assert.isNotNull(emailTo,'email is not null');
        
    }*/
    
}