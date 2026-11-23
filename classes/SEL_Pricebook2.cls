public class SEL_Pricebook2 extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Pricebook2 newInstance() {
        return (SEL_Pricebook2) Sales_Application.selector.newInstance(Pricebook2.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Pricebook2.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Pricebook2> selectByNames(List<String> pbNames) {
        return [Select id,Name from Pricebook2 where Name = : pbNames and IsActive=true];
    }
}