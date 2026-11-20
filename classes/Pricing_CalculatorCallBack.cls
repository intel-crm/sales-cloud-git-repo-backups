global without sharing class Pricing_CalculatorCallBack implements SBQQ.CalculateCallback {
	global void callback(String quoteJSON){
		SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);
        ResponseWrapper res = (ResponseWrapper) JSON.deserialize(quoteJSON, ResponseWrapper.class);
        QuoteLineBusinessLogic.publishQuoteLetter(res.record.id);
	}
    
    public class ResponseWrapper{
       public Record record;
    }
    
	public class Attributes {
		public String type;
		public String url;
	}

	public class Record {
		public Attributes attributes;
		public String Id;
		public String Name;
	}
}