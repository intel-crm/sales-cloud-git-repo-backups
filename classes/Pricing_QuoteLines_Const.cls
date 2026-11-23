public inherited sharing class Pricing_QuoteLines_Const extends fflib_SObjectDomain{
    
    public Pricing_QuoteLines_Const(List<SBQQ__QuoteLine__c> sObjectList)
	{
		super(sObjectList, Schema.SBQQ__QuoteLine__c.SObjectType);
	}
    
    public static Pricing_QuoteLines_Const newInstance(List<SBQQ__QuoteLine__c> recordList)
	{
        
		return (Pricing_QuoteLines_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}

    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_QuoteLines_Const((List<SObject>) objectList);
		}
	}
}