@isTest
public class PRM_MatchingAccWrapperTest {

    @isTest
    public static void testParseMethod() {
        // Create a JSON string representing a MatchingAccWrapper object
        String jsonString = '{' +
            '"accUrl": "https://example.com/account/12345",' +
            '"accId": "001D000000IqhSL",' +
            '"accName": "Test Account",' +
            '"unifiedHierarchy": "Hierarchy1",' +
            '"aggrCode": "AG123",' +
            '"intrmdtCust": "Intermediate Customer",' +
            '"unifiedId": "UN123",' +
            '"address": "123 Test St",' +
            '"bizOrgType": "Business",' +
            '"ipaAccount": true,' +
            '"partnerRole": "Partner",' +
            '"gecBlock": false,' +
            '"recordType": "Type1",' +
            '"accountOwner": "Owner Name",' +
            '"parentAccUrl": "https://example.com/account/67890",' +
            '"parentAccName": "Parent Account",' +
            '"street": "123 Test St",' +
            '"city": "Test City",' +
            '"state": "Test State",' +
            '"stateCode": "TS",' +
            '"postalCode": "12345",' +
            '"country": "Test Country",' +
            '"countryCode": "TC"' +
        '}';

        // Use the parse method to deserialize the JSON string
        Test.startTest();
        MatchingAccWrapper wrapper = MatchingAccWrapper.parse(jsonString);
		Test.stopTest();
      
    }
}