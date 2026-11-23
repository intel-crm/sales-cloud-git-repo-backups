//Need to correct
public class SEL_ConfiguredSKU extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_ConfiguredSKU newInstance() {
        return (SEL_ConfiguredSKU) Sales_Application.selector.newInstance(Order.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Order.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
   // public List<>

}