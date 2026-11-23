@isTest
public class Core_OpportunityCreate_SalesAssistTest {

    static testmethod void test1(){
        Account acc = Core_SalesSupportPSGQuote_Test.createAccount(1,false)[0];
        String RecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Opportunity').getRecordTypeId();
        Test.startTest();
        PageReference pageRef = Page.Core_OpportunityCreate_SalesAssist;
        pageRef.getParameters().put('ent', 'opportunity');
		pageRef.getParameters().put('RecordType', RecTypeId);
        pageRef.getParameters().put('accid', acc.Id);
        pageRef.getParameters().put('opp14', 'Test');
        Test.setCurrentPage(pageRef);
        Core_OpportunityCreate_SalesAssistCtrl oppCreate = new Core_OpportunityCreate_SalesAssistCtrl();
        Test.stopTest();
    }
}