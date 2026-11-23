public class UpdateACR {
    //@InvocableVariable String str; 
	@InvocableMethod
    public static void updateACRonEntitlementChange(List<String> entitlementName) {
        System.debug('entitlementName' + entitlementName);
    }
}