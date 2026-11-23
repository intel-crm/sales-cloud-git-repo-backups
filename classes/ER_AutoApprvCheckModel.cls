public class ER_AutoApprvCheckModel {

    public List<Rule> criteria;
	public String expression;	//Rule1 OR (Rule2 AND Rule3)
	public class rule {
		public String objectname;	//Account
		public String field;	//Core_CIM_ID__c
		public String value;	//
		public String operator;	//
        public String wherefield;
        public String wherevalue;
		public boolean hasvaluecheck; //true
	}
    
    public static ER_AutoApprvCheckModel parse(String json){
		return (ER_AutoApprvCheckModel) System.JSON.deserialize(json, ER_AutoApprvCheckModel.class);
	}
}