/****************************************************************************************************************************************
* Class Name  : PCC_PartnerLedPriceMappingBatchTest 
* Version     : 1.0 
* Created Date:  01-08-2024
* Modification Log :
* Developer            		  Date               DescriptionP
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       01-08-2024         Created
*****************************************************************************************************************************************/
@IsTest
private class PCC_PartnerLedPriceMappingBatchTest {
    @TestSetup
    static void setupData(){

        Product_MM_Attribute_Mapping__c mmAttributes = new Product_MM_Attribute_Mapping__c();
		mmAttributes.Level_1_EPM_ID__c = '98836';
        mmAttributes.Level_2_EPM_ID__c = '130101';
        mmAttributes.Level_3_EPM_ID__c = '130103';
        mmAttributes.Level_4_EPM_ID__c = '147261';
        mmAttributes.Level_5_EPM_ID__c = '130211';
       // mmAttributes.MMID__c = '768221';
        mmAttributes.Unique_ID__c = '768221;130211;147261;130103;130101;98836';
        mmAttributes.iPaaS_Load_ID__c = '654890';
        mmAttributes.Name = '89292';
        mmAttributes.IsActive__c = true;
        insert mmAttributes;

        PCC_ParnterLed_Price__c priceRec = new PCC_ParnterLed_Price__c();
        priceRec.PCC_Material_Master__c = '89292';
        insert priceRec;

    } 

    @isTest 
    public static void testMapMethod(){
        Test.startTest();
        Database.executeBatch(new PCC_PartnerLedPriceMappingBatch());
        Test.stopTest();
        List<PCC_ParnterLed_Price__c> priceData = [Select Id,PCC_Product_MM_Attribute_Mapping__c FROM PCC_ParnterLed_Price__c LIMIT 1];
        List<Product_MM_Attribute_Mapping__c> mmAttributes = [Select Id FROM Product_MM_Attribute_Mapping__c LIMIT 1];
        Assert.areEqual(mmAttributes[0].Id, priceData[0].PCC_Product_MM_Attribute_Mapping__c, 'Mapping has been done'); 
    }  
}