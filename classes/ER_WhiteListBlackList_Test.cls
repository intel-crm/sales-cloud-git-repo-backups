@isTest
public class ER_WhiteListBlackList_Test {
@isTest
    private static void getDomainListTest() {
        String reqBody = '';
        test.startTest();
        Business_Types__c  bus=new Business_Types__c();
        bus.Name='Developer Zone Premier';
        bus.Is_Active__c=true;
        insert bus;
        
        
        BusinessValidation__c valid= new BusinessValidation__c();
        valid.Country__c='UNITED STATES';
        valid.Geo__c='APJ';
        valid.Business_Types__c=bus.Id;
        valid.Domain_Name__c='abc.com';
        valid.RecordTypeId= Schema.SObjectType.BusinessValidation__c.getRecordTypeInfosByName().get('WhiteListed Domain').getRecordTypeId();
        valid.IsActive__c=true;
        valid.IsWhiteListed__c=true;
        insert valid;
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrationValidations/';
        request.httpMethod = 'POST';
          reqBody = '{"ProgramCode" : "Developer Zone Premier"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        system.debug('req obj ready');
        ER_WhiteListBlackList_Model.WhitelistBlackListResult res = ER_WhiteListBlackList.GetWhitelistBlacklistDomains();
        ER_WhiteListBlackList_Model.WhiteListedWrapper record = new ER_WhiteListBlackList_Model.WhiteListedWrapper();
        record=res.AcceptableDomainList[0];
        system.assertEquals(record.Domains,'abc.com');
        test.stopTest();
    }
    
    @isTest
    private static void getProjectBudgetDetailsTest() {
        String reqBody = '';
        test.startTest();
        
        Business_Types__c  bus=new Business_Types__c();
        bus.Name='Developer Zone Premier';
        bus.Is_Active__c=true;
        insert bus;
        
        
        BusinessValidation__c valid= new BusinessValidation__c();
        valid.Country__c='UNITED STATES';
        valid.Geo__c='APJ';
        valid.Business_Types__c=bus.Id;
        valid.MaxBudget__c='600K';
        valid.MinBudget__c='0K';
        valid.RecordTypeId= Schema.SObjectType.BusinessValidation__c.getRecordTypeInfosByName().get('Budget').getRecordTypeId();
        insert valid;
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrationValidations/';
        request.httpMethod = 'POST';
        reqBody = '{"ProgramCode" : "Developer Zone Premier"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        system.debug('req obj ready');
        ER_WhiteListBlackList_Model.WhitelistBlackListResult res = ER_WhiteListBlackList.GetWhitelistBlacklistDomains();
        system.debug('res'+res);
        ER_WhiteListBlackList_Model.ProjectBudgetWrapper wrapper= new ER_WhiteListBlackList_Model.ProjectBudgetWrapper();
        wrapper=res.ProjectBudgetDetails[0];
        system.assertEquals(wrapper.MaxBudget,'600K');
        test.stopTest();
    }
    
    @isTest
    private static void getExceptionTest() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrationValidations/';
        request.httpMethod = 'POST';
        reqBody = '{"ProgramCode" : "XYZ"}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        system.debug('req obj ready');
        ER_WhiteListBlackList_Model.WhitelistBlackListResult res = ER_WhiteListBlackList.GetWhitelistBlacklistDomains();
        
        system.assertEquals(res.ExceptionDetails.Message, 'Script-thrown exception');
        test.stopTest();
    }
    
    @isTest
    private static void getExceptionEmptyPrgmCdTest() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrationValidations/';
        request.httpMethod = 'POST';
        reqBody = '{"ProgramCode" : ""}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        system.debug('req obj ready');
        ER_WhiteListBlackList_Model.WhitelistBlackListResult res = ER_WhiteListBlackList.GetWhitelistBlacklistDomains();
        
        system.assertEquals(res.ExceptionDetails.Message, 'Program Code is mandatory');
        test.stopTest();
    }
}