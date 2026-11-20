@isTest
public class PRM_WeChat_Link_Test {
    @testSetup
    private static void createData() {
        List<Account> lstAccts = new List<Account>();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account intelAccount1 = new Account(Name ='IntelAccount1',RecordTypeId = accountRecordTypeIntel,Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        lstAccts.add(intelAccount1);
        Database.insert(lstAccts);
        
        //Get Contact Record Type
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=intelAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                  MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456', Core_Login_Id__c='testcontact1@mailinator.com', 
                                  Core_Enterprise_Id__c='300000551666');
        insert cnt;
        ////system.debug('Data creation done');
    }
    
    @isTest
    private static void LinkWeChatByEmailTest() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/linkwechat/';
        request.httpMethod = 'POST';
        reqBody = '{"enterpriseId" : "300000551666","loginId" : "testcontact1@mailinator.com","email" : "testcontact1@mailinator.com","wechatUnionId" : "+I03YX86EQVo+SHstHNLSA==","unfollow" : false}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        ////system.debug('req obj ready');
        PRM_WeChat_Link_Model res = PRM_WeChat_Link.LinkWeChatUnionId();
        
        List<Contact> cons = [SELECT Id, PRM_Wechat_Union_Id__c FROM Contact WHERE email = 'testcontact1@mailinator.com' ];
        
        system.assertEquals('Success', res.status, 'WeChat union id is updated');
        system.assertEquals('ATB23456', cons[0].PRM_Wechat_Union_Id__c);
        test.stopTest();
    }
    
    @isTest
    private static void LinkWeChatEmptyInput() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/linkwechat/';
        request.httpMethod = 'POST';
        reqBody = '{"enterpriseId" : "","loginId" : "","email" : "","wechatUnionId" : "+I03YX86EQVo+SHstHNLSA==","unfollow" : false}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        ////system.debug('req obj ready');
        PRM_WeChat_Link_Model res = PRM_WeChat_Link.LinkWeChatUnionId();
        
        system.assertEquals('Failure', res.status, 'Failed as no input');     
        test.stopTest();
    }
    
    @isTest
    private static void LinkWeChatNoContact() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/linkwechat/';
        request.httpMethod = 'POST';
        reqBody = '{"enterpriseId" : null,"loginId" : "testcontact13@mailinator.com","email" : null,"wechatUnionId" : "+I03YX86EQVo+SHstHNLSA==","unfollow" : false}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        ////system.debug('req obj ready');
        PRM_WeChat_Link_Model res = PRM_WeChat_Link.LinkWeChatUnionId();
        
        system.assertEquals('Failure', res.status, 'WeChat union id is updated');
        test.stopTest();
    }
    
    @isTest
    private static void LinkWeChatNoUnionId() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/linkwechat/';
        request.httpMethod = 'POST';
        reqBody = '{"enterpriseId" : null,"loginId" : "testcontact13@mailinator.com","email" : null,"wechatUnionId" : "","unfollow" : false}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        ////system.debug('req obj ready');
        PRM_WeChat_Link_Model res = PRM_WeChat_Link.LinkWeChatUnionId();
        
        system.assertEquals('Failure', res.status, 'WeChat union id should not be empty');
        test.stopTest();
    }
    
    @isTest
    private static void UnLinkWeChatByEnterpriseId() {
        String reqBody = '';
        test.startTest();
        List<Contact> cons = [SELECT Id, PRM_Wechat_Union_Id__c FROM Contact WHERE email = 'testcontact1@mailinator.com' ];
        cons[0].PRM_Wechat_Union_Id__c = 'ATB23456';
        update cons;
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/linkwechat/';
        request.httpMethod = 'POST';
        reqBody = '{"enterpriseId" : "300000551666","loginId" : "","email" : "","wechatUnionId" : "+I03YX86EQVo+SHstHNLSA==","unfollow" : true}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        ////system.debug('req obj ready');
        PRM_WeChat_Link_Model res = PRM_WeChat_Link.LinkWeChatUnionId();
        
        List<Contact> consUpdt = [SELECT Id, PRM_Wechat_Union_Id__c FROM Contact WHERE email = 'testcontact1@mailinator.com' ];
        
        system.assertEquals('Success', res.status, 'WeChat union id is updated');
        system.assert(String.isBlank(consUpdt[0].PRM_Wechat_Union_Id__c));
        test.stopTest();
    }
    
    @isTest
    private static void LinkWeChatException() {
        String reqBody = '';
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/linkwechat/';
        request.httpMethod = 'POST';
        reqBody = '{"enterpriseId" : null "loginId" : "testcontact13@mailinator.com","email" : null,"wechatUnionId" : "+I03YX86EQVo+SHstHNLSA==","unfollow" : false}';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        ////system.debug('req obj ready');
        PRM_WeChat_Link_Model res = PRM_WeChat_Link.LinkWeChatUnionId();
        
        system.assertEquals('Failure', res.status, 'WeChat union id is updated');
        test.stopTest();
    }
}