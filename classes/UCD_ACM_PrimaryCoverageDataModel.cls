public class UCD_ACM_PrimaryCoverageDataModel {
    public class RequestModel{
        public List<RequestCrossWalk> crosswalks{set;get;}
        public String type{set;get;}
        public Attribute attributes{set;get;}
    }
    public class Attribute {
        public List<CustomerSalesCoverageTypeCd> CustomerSalesCoverageTypeCd;
    }
    public class CustomerSalesCoverageTypeCd {
        public string type;
        public string value;
    }
    public class RequestCrossWalk {
		public String type;
		public String sourceTable;
		public String value;
		public Boolean dataProvider;
	}

}