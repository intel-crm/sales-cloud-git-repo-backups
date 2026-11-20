@isTest(SeeAllData=false)
public class Core_MDF_CustomLabelConfig_Test {
    @isTest static void metadataRecords(){
        //returns the   value in string format for given label
        Core_MDF_CustomLabelConfig.getTextValues('FOR_TEST_TEXT');
        //Core_MDF_CustomLabelConfig.getTextValues('');
        Core_MDF_CustomLabelConfig.getTextValues('FOR_TEST_TEXT_ORG_SPECIFIC');       
        //returns the metadata value in Boolean format for given label
        Core_MDF_CustomLabelConfig.getBooleanValues('FOR_TEST_BOOLEAN');
        Assert.isTrue(Core_MDF_CustomLabelConfig.getBooleanValues('FOR_TEST_BOOLEAN'));
        //returns the metadata value in Integer format for given label
        Core_MDF_CustomLabelConfig.getIntegerValues('FOR_TEST_INTEGER');
        Assert.areEqual(123, Core_MDF_CustomLabelConfig.getIntegerValues('FOR_TEST_INTEGER'));
        //returns the metadata value in Double format for given label
        Core_MDF_CustomLabelConfig.getDoubleValues('FOR_TEST_DOUBLE');
        Assert.areEqual(200.768, Core_MDF_CustomLabelConfig.getDoubleValues('FOR_TEST_DOUBLE'));
        //returns the list of semicolon seperated metadata values from the given label
        List<String> listLabels=Core_MDF_CustomLabelConfig.getTextList('FOR_TEST_TEXTLIST');
        Assert.areNotEqual(0, listLabels.size());
        //returns the list of colon seperated metadata values from the given label
        List<String> listLabelsSep=Core_MDF_CustomLabelConfig.getTextList('FOR_TEST_TEXTLIST',':');
        Assert.areNotEqual(0, listLabelsSep.size());
        //returns the list of semicolon seperated metadata values in string from the given label
        List<Integer> intList=Core_MDF_CustomLabelConfig.getIntegerList('FOR_TEST_INTEGERLIST');
        Assert.areNotEqual(0, intList.size());
        //returns the list of colon seperated metadata values as integer from the given label
        List<Integer> intListSep=Core_MDF_CustomLabelConfig.getIntegerList('FOR_TEST_INTEGERLIST',':');
        //returns error if list contains no value
        Assert.areNotEqual(0, intListSep.size());
        List<String> lst=new List<String>();
        lst.add('FOR_TEST_TEXT');
        lst.add('FOR_TEST_BOOLEAN');
        lst.add('FOR_TEST_INTEGER');
        lst.add('FOR_TEST_TEXTLIST');
        lst.add('FOR_TEST_INTEGERLIST');
        lst.add('FOR_TEST_TEXT_ORG_SPECIFIC');
        lst.add('');
        //returns the map of metadata values in string from the given label list
        Core_MDF_CustomLabelConfig.getBulkTextValues(lst);
        Map<String,String> labelsMap= Core_MDF_CustomLabelConfig.getBulkTextValues(lst);
        Assert.areNotEqual(0, labelsMap.size());
        //returns the map of metadata values in string for the given category value
        Core_MDF_CustomLabelConfig.getBulkTextValuesByCategory('Test');
       	Map<String,String> labelsMap1= Core_MDF_CustomLabelConfig.getBulkTextValuesByCategory('SPCF');
		Assert.areNotEqual(0, labelsMap1.size()); 
    }
}