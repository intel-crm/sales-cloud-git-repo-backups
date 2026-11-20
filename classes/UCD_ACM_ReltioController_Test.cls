@IsTest
public class UCD_ACM_ReltioController_Test {
 
    
    @IsTest
    static void testEntityUpdateForCoverage() {
        // Create mock data
        Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert account;
        List<UCD_ACM_ReltioModels.UpdateRequestModel> requestModels = new List<UCD_ACM_ReltioModels.UpdateRequestModel>();
        UCD_ACM_ReltioModels.UpdateRequestModel reqModel = new UCD_ACM_ReltioModels.UpdateRequestModel();
        reqModel.accountId = account.Id;
        reqModel.acctPriCoverage = System.Label.Intel_Covered;
        requestModels.add(reqModel);

        Test.startTest();
        // Call the method
        List<UCD_ACM_ReltioModels.UpdateResponseModel> response = UCD_ACM_ReltioController.triggerUpdateToReltio(requestModels);
        Test.stopTest();
        
        // Assert the results
        System.assertNotEquals(null, response);
    }

    @IsTest
    static void testEntityUpdateWithEmptyRequest() {
        // Create mock data
          Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert account;
        List<UCD_ACM_ReltioModels.UpdateRequestModel> requestModels = new List<UCD_ACM_ReltioModels.UpdateRequestModel>();
        UCD_ACM_ReltioModels.UpdateRequestModel reqModel = new UCD_ACM_ReltioModels.UpdateRequestModel();
        reqModel.accountId =account.Id;
        reqModel.onePartnerId = 'OP12345';
        reqModel.BPID='1000907588';
        reqModel.moduleName='OPID_UPDATE';
      //  reqModel.oPIdStatus = true;
        requestModels.add(reqModel);

     //   List<UCD_ACM_ReltioModels.UpdateRequestModel> requestModels = new List<UCD_ACM_ReltioModels.UpdateRequestModel>();

        Test.startTest();
        // Call the method
        List<UCD_ACM_ReltioModels.UpdateResponseModel> response = UCD_ACM_ReltioController.triggerUpdateToReltio(requestModels);
        Test.stopTest();
        
        // Assert the results
        System.assertEquals(0, response.size());
    }

   
     
    @IsTest
    static void testEntityUpdateWithMockService() {
        // Create mock data
        Account account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert account;
        List<UCD_ACM_ReltioModels.UpdateRequestModel> requestModels = new List<UCD_ACM_ReltioModels.UpdateRequestModel>();
        UCD_ACM_ReltioModels.UpdateRequestModel reqModel = new UCD_ACM_ReltioModels.UpdateRequestModel();
        reqModel.accountId = account.Id;
        reqModel.acctPriCoverage = System.Label.Intel_Covered;
        reqModel.BPID='1000907588';
        reqModel.moduleName='COVERAGE_UPDATE';
        requestModels.add(reqModel);

         

        Test.startTest();
        // Mock the service call
        Test.setMock(HttpCalloutMock.class, new ReltioServiceMock());
        
        // Call the method
   List<UCD_ACM_ReltioModels.UpdateResponseModel> response = UCD_ACM_ReltioController.triggerUpdateToReltio(requestModels);
          
        Test.stopTest();
        
        // Assert the results
        System.assertNotEquals(null, response);
        //System.assertEquals(1, response.size());
    }
    

    // Mock class to simulate the service response
    public class ReltioServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "status": "modified", "crosswalks": [ "entities/2WI4Tbr/crosswalks/CJiITtmh" ] }');
            res.setStatusCode(200);
            return res;
        }
    }

}