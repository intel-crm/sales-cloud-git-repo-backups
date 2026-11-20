public class Core_GenerateAccountSummaryJson {

	@AuraEnabled
    public Integer statusCode;
    @AuraEnabled
	public Body body;
    @AuraEnabled
	public Object message;

	public class Body {
        @AuraEnabled
		public String message;
        @AuraEnabled
		public Boolean show;
	}

	@AuraEnabled
	public static Core_GenerateAccountSummaryJson parse(String json) {
		return (Core_GenerateAccountSummaryJson) System.JSON.deserialize(json, Core_GenerateAccountSummaryJson.class);
	}
}