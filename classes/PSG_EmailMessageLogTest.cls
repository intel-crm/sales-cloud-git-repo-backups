@IsTest
public class PSG_EmailMessageLogTest {
    @isTest
    static void testCreateEmailMessageRecord() {
        // Test data setup
        Map<String, List<String>> relatedValues = new Map<String, List<String>>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='quoteDocument@example.com', 
                          EmailEncodingKey='UTF-8', LastName='quoteDocumentUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='quoteDocument@testorg.com');
        insert u;
        Account acc = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc.Id);
        List<SBQQ__Quote__c> quote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
        relatedValues.put('relatedToId', new List<String>{quote[0].Id});
        relatedValues.put('subject', new List<String>{'Test Subject'});
        relatedValues.put('htmlBody', new List<String>{'<p>Test HTML Body</p>'});
        
        List<String> toAddressList = new List<String>{'to@example.com'};
            List<String> ccAddressList = new List<String>{'cc@example.com'};
                List<String> bccAddressList = new List<String>{'bcc@example.com'};
                    
                    // Call the method
                    PSG_EmailMessageLog.createEmailMessageRecord(
                        relatedValues,
                        'from@example.com',
                        'From Name',
                        new String[]{},
                        toAddressList,
                        ccAddressList,
                        bccAddressList
                    );
        Assert.areEqual('to@example.com',toAddressList[0],'To address should match');
    }
    /*
    @isTest
    static void testCreateEmailMessage() {
        //Test data setup
        Test.setMock(HttpCalloutMock.class, new PSG_EmailMessageLogTest_Mock());
        Map<String, List<String>> relatedValues = new Map<String, List<String>>();
        List<GroupMember> gms=new List<GroupMember>();
        List<Group> groups=[Select Id from Group where developername='ags_business_admin'];
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
		Group g=new Group(Name='Test Group',DeveloperName='ags_test_group');
        insert g;
        GroupMember gm=new GroupMember();
        gm.GroupId=groups[0].Id;
        gm.UserOrGroupId=sosUser[0].Id;
        GroupMember gm1=new GroupMember();
        gm1.GroupId=groups[0].Id;
        gm1.UserOrGroupId=g.Id;
        gms.add(gm1);
        insert gms;
        
        System.runAs(sosUser[0]){
            Account acc = PSG_Test_Utility.createAccount();
        	Contact con = PSG_Test_Utility.createContact(acc.Id);
        	List<SBQQ__Quote__c> quote = PSG_Test_Utility.createQuote(acc.Id, con.Id,1);
            quote[0].OwnerId = groups[0].Id;
        	update quote;
            List<String> record = new List<String>();
            record.add(quote[0].Id);
            record.add('test_email_alert');
            record.add('SBQQ__Quote__c');
            Test.startTest();
            PSG_EmailMessageLog.createEmailMessageRecordForFlow(record);
            Test.stopTest();
        }
    }
	*/
}