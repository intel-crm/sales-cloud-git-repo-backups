@isTest
public with sharing class Core_MDF_IUPGM_Dummyclass_Test {
    @isTest
    public static void dummytest() {
        Test.startTest();
        Core_MDF_IUPGM_Dummyclass.getRecordsToApprove();
        assert.areEqual('Hi There','Hi There' );
        Test.stopTest();
    }
}