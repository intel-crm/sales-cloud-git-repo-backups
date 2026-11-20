/****************************************************************************************************************************************
* Class Name  : PMP_Geo_Attribute_Chinese_Test 
* Version     : 1.0 
* Created Date: 10-23-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      10/23/2019                    Test Class for Processing PMP_Geo_Attribute_Chinese Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Geo_Attribute_Chinese_Test {

        static testMethod void processDataTest (){
        
        PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
        spec1.PMP_Partner_Product_Specification_Id__c = 'NPP_GeographicCoverage';
        update spec1;
        
        List<Database.UpsertResult> resultData = new List<Database.UpsertResult>();
        
    	PMP_Geo_Attribute_Chinese testGeo = new PMP_Geo_Attribute_Chinese();
        test.startTest();
        PMP_ParseGeoRegionsJSON.languageCode = 'zh_CN';
        resultData = testGeo.processData('Geo_Attribute_English_Test');
        system.assertNotEquals(resultData,null);
        test.stopTest();
    }
}