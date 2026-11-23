public class SEL_Contact extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Contact newInstance() {
        return (SEL_Contact) Sales_Application.selector.newInstance(Contact.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Contact.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Contact> selectByPrimaryOrDelIds( Id fromPrimayAdmin, Id toPrimaryAdmin){
        return [Select Id,Name,Email from Contact where Id=:fromPrimayAdmin OR Id=:toPrimaryAdmin];
    }

}