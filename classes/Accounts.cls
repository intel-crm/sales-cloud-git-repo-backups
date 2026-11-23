//All domain classes should utilize inherited sharing so that the caller determines whether it //should operate in system context or not. The should
//also extend the fflib_SObjectDomain class
public inherited sharing class Accounts extends fflib_SObjectDomain{
    
    public Accounts(List<Account> sObjectList)
	{
		super(sObjectList, Schema.Account.SObjectType);
	}
    
    public static Accounts newInstance(List<Account> recordList)
	{
		return (Accounts) Application.Domain.newInstance(recordList);
	}
    //The name of this inner class must always be Constructor to work appropriately. This acts 
    //as a way to use the concept of reflection when initializing
    //this class, despite the fact apex still does not support it.
    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Accounts((List<SObject>) objectList);
		}
	}
}