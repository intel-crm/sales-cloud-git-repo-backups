public inherited sharing class Pricing_Quote_Const extends fflib_SObjectDomain{
    
    public Pricing_Quote_Const(List<SBQQ__Quote__c> sObjectList)
	{
		super(sObjectList, Schema.SBQQ__Quote__c.SObjectType);
	}
    
    public static Pricing_Quote_Const newInstance(List<SBQQ__Quote__c> recordList)
	{
        
		return (Pricing_Quote_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}

    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_Quote_Const((List<SObject>) objectList);
		}
	}
}