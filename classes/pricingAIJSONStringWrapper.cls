public class pricingAIJSONStringWrapper{
    public Plots plots {set;get;} 
    public Integer requestedPrice;
    public Integer ecapPrice;
    public list<Object> priceAxisRange;
    public list<Object> ranges;
        public class Plots{
            public list<Object> low_risk;
            public list<Object> high_risk;
            public list<Object> severe_risk;
        }
}