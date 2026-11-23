@isTest
private class Core_CustomCoveoPanelExtension_Test {
	
    public static testMethod void testMethod1(){
        Case cs = TestUtilities.getCase();
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Core_CustomCoveoPanelExtension coveoExtension = new Core_CustomCoveoPanelExtension(sc);
        System.assert(cs!=null);
    }
}