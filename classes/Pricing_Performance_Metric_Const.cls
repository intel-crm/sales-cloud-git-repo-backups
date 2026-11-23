public inherited sharing class Pricing_Performance_Metric_Const extends fflib_SObjectDomain{
    
    public Pricing_Performance_Metric_Const(List<Pricing_Performance_Metric__c> sObjectList)
	{
		super(sObjectList, Schema.Pricing_Performance_Metric__c.SObjectType);
	}
    
    public static Pricing_Performance_Metric_Const newInstance(List<Pricing_Performance_Metric__c> recordList)
	{
        
		return (Pricing_Performance_Metric_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}
    //The name of this inner class must always be Constructor to work appropriately. This acts 
    //as a way to use the concept of reflection when initializing
    //this class, despite the fact apex still does not support it.
    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_Performance_Metric_Const((List<SObject>) objectList);
		}
	}
}