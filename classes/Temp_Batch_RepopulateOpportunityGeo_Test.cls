@isTest(seeAllData=true)
public class Temp_Batch_RepopulateOpportunityGeo_Test {

    static testmethod void testBatch() {
        Test.startTest();
        Database.executeBatch(new Temp_Batch_RepopulateOpportunityGeos());
        Test.stopTest();
    }
}