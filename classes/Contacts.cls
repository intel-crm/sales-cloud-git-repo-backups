//All domain classes should utilize inherited sharing so that the caller determines whether it //should operate in system context or not. The should
//also extend the fflib_SObjectDomain class
public inherited sharing class Contacts extends fflib_SObjectDomain{
    
    public Contacts(List<Contact> sObjectList)
	{
		super(sObjectList, Schema.Contact.SObjectType);
	}
    
    public static Contacts newInstance(List<Contact> recordList)
	{
		return (Contacts) Application.Domain.newInstance(recordList);
	}
    //The name of this inner class must always be Constructor to work appropriately. This acts 
    //as a way to use the concept of reflection when initializing
    //this class, despite the fact apex still does not support it.
    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Contacts((List<SObject>) objectList);
		}
	}
}