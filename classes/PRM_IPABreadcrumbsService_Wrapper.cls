public class PRM_IPABreadcrumbsService_Wrapper {
    public cls_breadcrumb breadcrumb; 
    public class cls_breadcrumb {
        public Integer id; 	//1
        public boolean selected;
        public String text; 	//Intel Partner Alliance
        public String url; 	//https://intelpartneralliance.com
        public List<cls_children> children = new List<cls_children>(); 
    }
    
     public class Attributes {
		public String pageName; 
     }
    public class Data {
		public String type; // in json: type
        public Attributes attributes; 
    }
    
    public class cls_children {
		public Integer id; 
		public String text;
		public String url;
		public Boolean cancelEvent;
		public Data data; 
		public Boolean useCallback; 
		public String target; 
		public Boolean selected; 
    }
}