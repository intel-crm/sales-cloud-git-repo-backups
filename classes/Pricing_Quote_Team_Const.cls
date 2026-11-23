public inherited sharing class Pricing_Quote_Team_Const extends fflib_SObjectDomain{
    
    public Pricing_Quote_Team_Const(List<Pricing_Quote_Team__c> sObjectList)
	{
		super(sObjectList, Schema.Pricing_Quote_Team__c.SObjectType);
	}
    
    public static Pricing_Quote_Team_Const newInstance(List<Pricing_Quote_Team__c> recordList)
	{
        
		return (Pricing_Quote_Team_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}

    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_Quote_Team_Const((List<SObject>) objectList);
		}
	}
}