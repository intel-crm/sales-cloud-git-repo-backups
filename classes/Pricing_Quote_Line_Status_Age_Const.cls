public inherited sharing class Pricing_Quote_Line_Status_Age_Const extends fflib_SObjectDomain{
    
    public Pricing_Quote_Line_Status_Age_Const(List<Pricing_Quote_Line_Status_Age__c> sObjectList)
	{
		super(sObjectList, Schema.Pricing_Quote_Line_Status_Age__c.SObjectType);
	}
    
    public static Pricing_Quote_Line_Status_Age_Const newInstance(List<Pricing_Quote_Line_Status_Age__c> recordList)
	{
        
		return (Pricing_Quote_Line_Status_Age_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}
    //The name of this inner class must always be Constructor to work appropriately. This acts 
    //as a way to use the concept of reflection when initializing
    //this class, despite the fact apex still does not support it.
    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_Quote_Line_Status_Age_Const((List<SObject>) objectList);
		}
	}
}