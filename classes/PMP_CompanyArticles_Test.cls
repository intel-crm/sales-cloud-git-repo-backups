@isTest
public class PMP_CompanyArticles_Test extends PMP_SearchWrapperStore {
   
    @isTest static void getArticles_Test() {
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);        
		PMP_Company__c partner = PMP_SearchTestDataFactory.createCompanyInformation('testPartner', testAccount.Id, true);
        partner.PMP_Is_Working_Copy_Ind__c = true;
        update partner;
        String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        PMP_Company_Translation__c translation = new PMP_Company_Translation__c(PMP_English_Txt__c='12345', PMP_Field_Nm__c=streamIdName, PMP_Company_Information_Id__c=partner.Id);
        insert translation;
        
        Test.setMock(HttpCalloutMock.class, new PMP_CompanyArticlesMock()); 
        Test.startTest();
        PMP_CompanyArticles.getArticles(partner.Id, 'en_US');
        Test.stopTest();
        
        PMP_CompanyArticles.ResponseBody resBdy = new PMP_CompanyArticles.ResponseBody();
        resBdy.token_type = '';
        resBdy.expires_in = '';
        PMP_CompanyArticles.ArticleResponseData ard = new PMP_CompanyArticles.ArticleResponseData();
        ard.meta = new PMP_CompanyArticles.Meta();
		ard.meta.count = 0;
        ard.meta.total_pages = 0;   
        PMP_CompanyArticles.Data dt = new PMP_CompanyArticles.Data();
        dt.id = 0;
        dt.hub_id = 0;
        dt.service = '';
        dt.title = '';
        dt.description = '';
        dt.url = '';
        dt.thumbnail_url = '';
        dt.canonical_url = '';
        dt.canonical_redirect = false;
        dt.published = true;
        dt.hidden = false;
        dt.edited = true;
        dt.deleted = false;
        dt.hide_publish_date = false;
        dt.external_created_at = '';
        dt.external_modified_at = '';
        dt.created_at = '';
        dt.modified_at = '';
        dt.content = new PMP_CompanyArticles.Content();
        dt.stream = new PMP_CompanyArticles.Stream();
        dt.author = new PMP_CompanyArticles.Author();
        dt.content.published = '';
        dt.stream.id = 0;
        dt.stream.title = '';
        dt.stream.ordinal = 0;
        dt.stream.featured = false;
        dt.author.id = 0;
        dt.author.first_name = '';
        dt.author.last_name = '';
        dt.author.full_name = '';
        dt.author.username = '';
        dt.author.email = '';
        dt.author.bio = '';
        dt.author.twitter_id = '';
        dt.author.avatar_url = '';
        
        PMP_CompanyArticles.getArticles(partner.Id, 'ja');
        PMP_CompanyArticles.getArticles(partner.Id, 'zh_CN');
        system.assertNotEquals(NULL, translation, 'no error');
    }
}