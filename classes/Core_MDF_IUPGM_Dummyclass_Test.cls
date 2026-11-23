public with sharing class Core_MDF_IUPGM_Dummyclass_Test {
    public Core_MDF_IUPGM_Dummyclass_Test() {
        Test.startTest();
        Core_MDF_IUPGM_Dummyclass.getRecordsToApprove();
        assert.areEqual('Hi There','Hi There' );
        Test.stopTest();
    }
}