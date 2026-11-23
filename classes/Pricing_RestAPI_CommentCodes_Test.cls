@isTest
public class Pricing_RestAPI_CommentCodes_Test {
    
    
   	@testSetup 
    private static void createData(){
        Pricing_Test_Utility.createPriceBook();
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0]){
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            test.stopTest();
        }
    }
	
    
    @isTest static void testDoGet() {
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/questioncodemapping';
            request.httpMethod = 'GET';
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_CommentCodes.doGet();
            system.assert(restResponse.successContent!=null);
        }
    }
}