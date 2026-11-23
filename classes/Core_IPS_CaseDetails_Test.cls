@isTest
public class Core_IPS_CaseDetails_Test {
     public static testMethod void test_GetCase(){
       Case caseRecord = TestUtilities.getCase(); 
        caseRecord.Core_IPS_Customer_Visible__c = true;
       insert caseRecord;
        
       System.assert(true,caseRecord.id!=null);
       test.starttest();
      Core_IPS_CaseDetails.CaseWrapperCount testvariable= Core_IPS_CaseDetails.get_Case();
       System.assertEquals('New',caseRecord.Status);
       System.assertEquals(1,testvariable.countNew); 
       System.assertNotEquals(1,Core_IPS_CaseDetails.get_Case().countOpen);
       System.assertEquals(1,Core_IPS_CaseDetails.get_Case().countOpenNew);
       System.assertEquals('TestDescription',caseRecord.Description);
         Core_IPS_CaseDetails.CaseWrapper wrpcls = new Core_IPS_CaseDetails.CaseWrapper();
         wrpcls.AccountId=null;
         wrpcls.ContactId=null;
         wrpcls.product=null;
       test.stoptest(); 
    }
}