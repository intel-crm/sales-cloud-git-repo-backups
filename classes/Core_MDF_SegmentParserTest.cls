@isTest(seeAllData=false)
public class Core_MDF_SegmentParserTest {
	static testMethod void testParse() {
        String json = '[{"Core_MDF_Segment_Name_nm":"Chipsets","productIdSet":["01to0000000zcTEAAY"],"Core_MDF_Minimum_Forecast_Volume_nbr":"333","Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":"333","Core_MDF_SPIF_Notes_internal_only_txt":"333","Core_MDF_Estimated_Share_of_SPIF_crrcy":"11"}]';
        List<Core_MDF_SegmentParser> obj = Core_MDF_SegmentParser.parse(json);
        System.assert(obj != null);
    }
}