/***************************************************************************************************** 
Class Name :    Core_MDF_PFR_RecordTypeSelector_Test
Description:    This is the test class for Core_MDF_PFR_RecordTypeSelector class
Added By   :    Accenture - SKS 
Modified By:                      Date:07/31/2018                     Changes:None  
******************************************************************************************************/
@isTest
private class Core_MDF_PFR_RecordTypeSelector_Test
{
    @isTest
    static void fetchRecordTypeValuesTest()
    {
        Map<String, String> newrecordtypemap = new map<String,string>();
        string objectName = 'Campaign';
        newrecordtypemap= Core_MDF_PFR_RecordTypeSelector.fetchRecordTypeValues(objectName);
        Map<String,id>  testMap= Core_MDF_PFR_RecordTypeSelector.fetchRecordTypeValues_string_id(objectName);
        Core_MDF_PFR_RecordTypeSelector.fetchRecordType(objectName);
        System.assertEquals(newrecordtypemap.values().contains('Client Co-Marketing Fund'), true);
    }
    
   
}