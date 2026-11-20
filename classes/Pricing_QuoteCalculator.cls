public without sharing class Pricing_QuoteCalculator {
    
	public void calculate(QuoteModel quote, String callbackClass) {
		QuoteCalculatorContext ctx = new QuoteCalculatorContext(quote, callbackClass);
		SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(ctx));
	}

	public void calculate(List<QuoteModel> quotes, String callbackClass) {
		for(QuoteModel quote : quotes){
			QuoteCalculatorContext ctx = new QuoteCalculatorContext(quote, callbackClass);
			SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(ctx));
		}		
	}
    
	private class QuoteCalculatorContext {
		private QuoteModel quote;
		private String callbackClass;
		private QuoteCalculatorContext(QuoteModel quote, String callbackClass) {
			this.quote = quote;
			this.callbackClass = callbackClass;
		}
	}
}