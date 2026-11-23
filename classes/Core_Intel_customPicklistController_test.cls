/***************************************************************************************************** 
Class Name :    Core_Intel_customPicklistController_test
Description:    This is the test class for Core_Intel_customPicklistController class
Added By   :    Accenture - VK 
Modified By:                      Date:08/03/2018                     Changes:None  
******************************************************************************************************/
@isTest
public class Core_Intel_customPicklistController_test{
    /***************************************************************************************************** 
    Method Name :    getselectOptionstest
    Description:    This method is to test the functionality to return the lapel and api name of the picklist field
    Added By   :    Accenture - VK 
    Modified By:                      Date:08/03/2018                     Changes:None  
    ******************************************************************************************************/
    
    static testmethod void getselectOptionstest() {
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        //Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 211', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, true);
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        acc2.type ='EBM';
        update acc2;
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',acc2.Id,'Desktop',true); 
        
        Map<String,String> lstpicklist= Core_Intel_customPicklistController.getselectOptions('PartnerFundRequest','Core_MDF_Activity_Types__c',camp.Id,'Core_MDF_Activity_Type__c','','');
        System.assert(lstpicklist != null);
    }
    
    /***************************************************************************************************** 
    Method Name :    getchannelpartners
    Description:    This method is to test the functionality to return the map from custom metadata
    Added By   :    Accenture - VK 
    Modified By:                      Date:08/03/2018                     Changes:None  
    ******************************************************************************************************/
    
    static testmethod void getchannelpartners(){
        List<String> channelspartners = Core_Intel_customPicklistController.fetchCPCtryMetaData('ALBANIA');
        System.assert(channelspartners != null);
    }
    
    /***************************************************************************************************** 
    Method Name :    MockHttpResponseGenerator class
    Description:    This method is for mock callout of the http response
    Added By   :    Accenture - VK 
    Modified By:                      Date:08/03/2018                     Changes:None  
    ******************************************************************************************************/
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            System.assert(res != null);
            return res;
        }
    }
    
    /***************************************************************************************************** 
    Method Name :    testCalloutforCCF
    Description:    This method is for testing mock callout for CCF record type
    Added By   :    Accenture - VK 
    Modified By:                      Date:08/03/2018                     Changes:None  
    ******************************************************************************************************/
    
    @isTest 
    static void testCalloutforCCF() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, Object> m =  Core_Intel_customPicklistController.picklistFetcher('Core_MDF_Client_CoMarketing_Fund');
        System.assert(m != null);
    }
    
    /***************************************************************************************************** 
    Method Name :    testCalloutforCCF
    Description:    This method is for testing mock callout for DCF record type
    Added By   :    Accenture - VK 
    Modified By:                      Date:08/03/2018                     Changes:None  
    ******************************************************************************************************/
    
    @isTest 
    static void testCalloutforDCF() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, Object> m =  Core_Intel_customPicklistController.picklistFetcher('Core_MDF_Data_Center_CoMarketing_Fund');
        System.assert(m != null);
    }
    
    /***************************************************************************************************** 
    Method Name :    testApitoLabelReference
    Description:    This method is for get all the picklist value for PartnerFundRequest
    Added By   :    Accenture - VK 
    Modified By:                      Date:08/03/2018                     Changes:None  
    ******************************************************************************************************/
    @isTest
    static void testApitoLabelReference(){
        String obj = 'PartnerFundRequest';
        List<String> field = new List<String>();
        field.add('Core_MDF_Brand__c'); 
        Map<String,String> result = Core_Intel_customPicklistController.apitoLabelReference(obj,field);
        System.assert(result  != null);
    }

}