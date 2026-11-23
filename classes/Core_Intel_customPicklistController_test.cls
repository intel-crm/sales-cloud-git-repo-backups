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
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);
        system.runAs(usr){
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM, Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME, true);
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            acc2.type ='EBM';
            update acc2;
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'CMP only', Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(2), System.today().addDays(346), 10000, 'Always Connected PC',acc2.Id,'Radio', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            insert camp;
            
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            Test.startTest();
            Map<String,String> lstpicklist = Core_Intel_customPicklistController.getselectOptions('PartnerFundRequest','Core_MDF_Activity_Types__c',camp.Id,'Core_MDF_Activity_Type__c','','');
            Test.stopTest();
            Assert.isTrue(!lstpicklist.values().contains('Radio'));
        }
    }
    /***************************************************************************************************** 
Method Name :    getchannelpartners
Description:    This method is to test the functionality to return the map from custom metadata
Added By   :    Accenture - VK 
Modified By:                      Date:08/03/2018                     Changes:None  
******************************************************************************************************/
    
    static testmethod void getchannelpartners(){
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);
        system.runAs(usr){
        test.startTest();
        List<String> channelspartners = Core_Intel_customPicklistController.fetchIndPartnerCtryPgmMapping('ALBANIA',Core_MDF_CCP_ConstantClass.DCF_PROGRAM);
        test.stopTest(); 
    }
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
        
    }
    
    /***************************************************************************************************** 
Method Name :    testCalloutforDCF
Description:    This method is for testing mock callout for DCF record type
Added By   :    Accenture - VK 
Modified By:                      Date:08/03/2018                     Changes:None  
******************************************************************************************************/
    
    @isTest 
    static void testCalloutforDCF() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, Object> m =  Core_Intel_customPicklistController.picklistFetcher('Core_MDF_Data_Center_CoMarketing_Fund');
        
        
    }  
    /***************************************************************************************************** 
Method Name :    testApitoLabelReference
Description:    This method is for get all the picklist value for PartnerFundRequest
Added By   :    Accenture - VK 
Modified By:                      Date:08/03/2018                     Changes:None  
******************************************************************************************************/
    @isTest
    static void testApitoLabelReference(){
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);
        system.runAs(usr){
        test.startTest();
        String obj = 'PartnerFundRequest';
        List<String> field = new List<String>();
        field.add('Core_MDF_Brand__c'); 
        Map<String,String> result = Core_Intel_customPicklistController.apitoLabelReference(obj,field);
        test.stopTest();
        Assert.isTrue(result.values().contains('10ᵗʰ Gen'));
    }
    }
    @isTest
    static void testApitoLabelCampaignReference(){
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);
        system.runAs(usr){
        test.startTest();
        String obj = 'Campaign';
        List<String> field = new List<String>();
        field.add('Core_MDF_Brand__c'); 
        Map<String,String> result = Core_Intel_customPicklistController.apitoLabelReferenceCampaign(obj,field);
        test.stopTest();
        Assert.isTrue(result.values().contains('10ᵗʰ Gen Core i5 processors')); 
    }
    }
}