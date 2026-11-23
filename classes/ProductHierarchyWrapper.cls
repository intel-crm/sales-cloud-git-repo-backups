/*********************************************************************************************************************
Apex Class Name  : ProductHierarchyWrapper
Author And Date  : Rohit Podder, 20 MAR 2026
Function         : Wrapper class to deserialize level 1 to level 5 hierarchy records coming from PIM api response
*********************************************************************************************************************/
public class ProductHierarchyWrapper {
    public ProductHierarchyWrapper() {
        // Default constructor - for test coverage
    }
    public String count;
    public Integer offset;
    
    public List<HierarchyItem> hierarchy;
    
    public class HierarchyItem {
        public String l1;
        public String l1Name;
        public Integer l1_is_active;
        public String l2;
        public String l2name;
        public Integer l2_is_active;
        public String l3;
        public String l3name;
        public Integer l3_is_active;
        public String l4;
        public String l4name;
        public Integer l4_is_active;
        public Integer l4RestrictionLevel;
        public String l5;
        public String l5name;
        public String l5_name;
        public Integer l5_is_active;
        //Ganesh Start
		public String L5DeprecationDate;
		//Ganesh End
        
        public Map<String, String> attributes;
        
        // mm_details is a list of materials
        public List<MmDetail> mm_details;
        public String dataSource;
       
    }
    
    public class MmDetail {
        public String mmid;
        public String name;
        public Integer restrictionLevel;
        public Map<String, String> attributes;
    }
}