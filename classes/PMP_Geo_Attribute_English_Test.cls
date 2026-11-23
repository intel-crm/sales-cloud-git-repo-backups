/****************************************************************************************************************************************
* Class Name  : PMP_Geo_Attribute_English_Test 
* Version     : 1.0 
* Created Date: 05-29-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/29/2019                    Test Class for Processing Geo_Attributes_English Static Resource
* ****************************************************************************************************************************************/
@isTest
public class PMP_Geo_Attribute_English_Test {
     @isTest
    public static void testProcessGeoAttributes()
    {
        PMP_Geo_Attribute_English procAttrEng = new PMP_Geo_Attribute_English();
        PMP_GeoRegion_CreateJunctionData_Test.PMP_GeoRegion_CreateJunctionDataMet_Test();
       // test.startTest();
       	PMP_ParseGeoRegionsJSON.strBaseKey = 'en_US';
        List<Database.UpsertResult> resultData = procAttrEng.processData('Geo_Attribute_English_Test');
        system.assertNotEquals(resultData,null);
       // test.stopTest();
    }
}