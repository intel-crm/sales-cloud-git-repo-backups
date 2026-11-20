public class Core_MDF_SegmentParser {
	public String segmentId;
	public String Core_MDF_Segment_Name_nm;
	public String Core_MDF_Minimum_Forecast_Volume_nbr;
	public String Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr;
	public String Core_MDF_Estimated_Share_of_SPIF_amt;
	public String Core_MDF_SPIF_Notes_internal_only_txt;
	public String Core_MDF_SPIF_Notes_txt;
        public String Core_MDF_Maximum_Cost_of_Bundle_nbr;
        public String Core_MDF_Maximum_Bundled_Volume_nbr;
	public List<String> productIdSet;
	
	public static List<Core_MDF_SegmentParser> parse(String segmentJSON) {
		return (List<Core_MDF_SegmentParser>) System.JSON.deserialize(segmentJSON, List<Core_MDF_SegmentParser>.class);
	}
}