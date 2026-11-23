public inherited sharing class Pricing_Document_Const extends fflib_SObjectDomain{
    
    public Pricing_Document_Const(List<Pricing_Document__c> sObjectList)
	{
		super(sObjectList, Schema.Pricing_Document__c.SObjectType);
	}
    
    public static Pricing_Document_Const newInstance(List<Pricing_Document__c> recordList)
	{
        
		return (Pricing_Document_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}
    
    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_Document_Const((List<SObject>) objectList);
		}
	}
}