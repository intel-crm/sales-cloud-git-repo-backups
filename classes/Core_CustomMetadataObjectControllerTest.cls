/****************************************************************************************************************************************
* Class Name  : Core_CustomMetadataObjectControllerTest 
* Version     : 1.0 
* Created Date: 23-10-2024
* Modification Log :
* Developer            		  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       23-10-2024         This is a test class for Core_CustomMetadataObjectController class
*****************************************************************************************************************************************/
@IsTest
private class Core_CustomMetadataObjectControllerTest {
    /**
     * This is a setup method used to insert required data for this particular test class.
     */
    @TestSetup
    static void setupData() {
        List<Core_CustomMetadata_Object__c> cms = new List<Core_CustomMetadata_Object__c>();

        Core_CustomMetadata_Object__c cm1 = new Core_CustomMetadata_Object__c();
        cm1.DeveloperName__c = 'DeveloperName';
        cm1.MasterLabel__c = 'MasterLabel';
        cm1.Metadata_Name__c = 'testmetadata';
        cm1.Field_1__c = 'testfield1';
        cm1.Field_1_Text_Area__c = 'testtafield1';
        cm1.Field_1_Text_Area_Long__c = 'testtalfield1';
        insert cm1;

        Core_CustomMetadata_Object__c cm2 = new Core_CustomMetadata_Object__c();
        cm2.Header_row__c = cm1.Id;
        cm2.DeveloperName__c = 'testdn';
        cm2.MasterLabel__c = 'testml';
        cm2.Metadata_Name__c = 'testmetadata';
        cm2.Field_1__c = 'testvalue1';
        cm2.Field_1_Text_Area__c = 'testtaval1';
        cm2.Field_1_Text_Area_Long__c = 'testtalval1';
        cms.add(cm2);

        Core_CustomMetadata_Object__c cm3 = new Core_CustomMetadata_Object__c();
        cm3.Header_row__c = cm1.Id;
        cm3.DeveloperName__c = 'testdn1';
        cm3.MasterLabel__c = 'testml1';
        cm3.Metadata_Name__c = 'testmetadata';
        cm3.Field_1__c = 'testvalue2';
        cm3.Field_1_Text_Area__c = 'testtaval2';
        cm3.Field_1_Text_Area_Long__c = 'testtalval2';
        cms.add(cm3);

        insert cms;
    }
    /**
     * This method is used to cover getInstance method.
     */
    @isTest
    public static void testGetInstance() {
        Test.startTest();
        Map<String, Object> metRec = new Core_CustomMetadataObjectController('testmetadata').getInstance('testdn');
        Test.stopTest();
        Assert.areEqual('testvalue1', String.valueOf(metRec.get('testfield1')), 'Expected testvalue1');
    }
    /**
     * This method is used to cover getAll method.
     */
    @isTest
    public static void testGetAll() {
        Test.startTest();
        Map<String,Map<String, Object>> metRecs = new Core_CustomMetadataObjectController('testmetadata').getAll();
        Test.stopTest();
        Assert.areEqual(2, metRecs.size(), 'Expected 2 records');
    }
}