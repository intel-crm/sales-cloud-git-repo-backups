@IsTest
public class Core_GenerateAccountSummaryJson_Test {
	
	static testMethod void testParse() {
		String json = '{\"statusCode\": 200, \"body\": {\"message\": \"AI summary available for user id: 10681329, account_id: 001o000000O650VAAR\", \"show\": true}, \"message\": null}';
		Core_GenerateAccountSummaryJson obj = Core_GenerateAccountSummaryJson.parse(json);
		System.assert(obj != null);
	}
}