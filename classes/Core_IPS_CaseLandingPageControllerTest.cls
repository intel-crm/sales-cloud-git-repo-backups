/* Test class Name : Core_IPS_CaseLandingPageControllerTest
 * Test class For  : Core_IPS_CaseLandingPageController
 * 
 */
@isTest(seeAllData=false)
private class Core_IPS_CaseLandingPageControllerTest {    
    @isTest
    private static void testMethod1() {
        List<StandardActionRedirection__C> ListStdActions = TestUtilities.getStandardActionRedirection(1);
        for(StandardActionRedirection__C stdAct:ListStdActions){
            stdAct.Name='1';
            stdAct.Object__c='case';
            stdAct.Action__c='new';
            stdAct.Record_Type__c='IPS_Case_Create';
            stdAct.URI__c='/apex/Core_IPS_Internal_Case_Creation?mode=edit&id=';
        }
        insert ListStdActions;
        System.AssertEquals(ListStdActions.size()>0, true);
        Core_IPS_CaseLandingPageController.getCaseRecordTypeIds();	 
        Core_IPS_CaseLandingPageController.getStandardActionRedirectionURL('new', 'case', 'null', 'IPS_Case_Create');
        Core_IPS_CaseLandingPageController.getStandardActionRedirectionURL('new', 'case', 'null', 'Core_IPS_Case_Create_Self_Assigned');
    } 
}