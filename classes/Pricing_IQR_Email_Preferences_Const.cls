public class Pricing_IQR_Email_Preferences_Const extends fflib_SObjectDomain {
    public Pricing_IQR_Email_Preferences_Const(List<Pricing_IQR_Email_Preferences__c> sObjectList)
	{
		super(sObjectList, Schema.Pricing_IQR_Email_Preferences__c.SObjectType);
	}
    
    public static Pricing_IQR_Email_Preferences_Const newInstance(List<Pricing_IQR_Email_Preferences__c> recordList)
	{
        
		return (Pricing_IQR_Email_Preferences_Const) Pricing_IQR_Application.Domain.newInstance(recordList);
	}
    //The name of this inner class must always be Constructor to work appropriately. This acts 
    //as a way to use the concept of reflection when initializing
    //this class, despite the fact apex still does not support it.
    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Pricing_IQR_Email_Preferences_Const((List<SObject>) objectList);
		}
	}
}