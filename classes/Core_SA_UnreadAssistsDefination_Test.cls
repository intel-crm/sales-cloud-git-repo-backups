@IsTest
public class Core_SA_UnreadAssistsDefination_Test {
//
// Generated Core_SA_UnreadAssistsDefination_Test
//
	static testMethod void testParse() {
		String json = '{\"content\":\"You Have 31 Unread Assists!\", \"show\":true}';
		Core_SA_UnreadAssistsDefination obj = Core_SA_UnreadAssistsDefination.parse(json);
		System.assert(obj != null);
	}
}