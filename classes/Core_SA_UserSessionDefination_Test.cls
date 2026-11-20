@IsTest
public class Core_SA_UserSessionDefination_Test {
//
// Generated Core_SA_UserSessionDefination_Test
//

	static testMethod void testParse() {
		String json = '{\"cimId\":\"21705855\", \"orgId\":\"00D0n000000D3l9\",\"sessionId\":\"00D0n000000D3l9!ARcAQDkv.yJnakemzzVmfIf4Olmh2lZ0AZtHyqYCkOC6pq0xHlyfQNog5j3MQWEWiHratbhn82GzmiQVtQUCL0MQjA5_HwDK\",\"wwid\":\"10526157\",\"email\":\"Harshad.panchal@intel.com\"}';
		Core_SA_UserSessionDefination obj = Core_SA_UserSessionDefination.parse(json);
		System.assert(obj != null);
	}
}