@isTest
public class PMP_SearchCompanyArticles_Test extends PMP_SearchWrapperStore{
	
    @testSetup static void dataFactory(){
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);        
		PMP_Company__c testpartner = PMP_SearchTestDataFactory.createCompanyInformation('testPartner', testAccount.Id, true);
    } 
    
   @isTest static void testPostCallout() {
       PMP_Company__c partner = [SELECT Id, Name from PMP_Company__c where Name='testPartner'];
        Test.setMock(HttpCalloutMock.class, new PMP_SearchCompanyArticlesMock()); 
        Test.startTest();
        system.assertEquals(6, PMP_SearchCompanyArticles.getPartnerArticles(partner.Id,'en_US').articleList.size());
        Test.stopTest();
    }
    
}