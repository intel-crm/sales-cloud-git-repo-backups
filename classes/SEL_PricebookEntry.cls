public class SEL_PricebookEntry extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_PricebookEntry newInstance() {
        return (SEL_PricebookEntry) Sales_Application.selector.newInstance(PricebookEntry.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return PricebookEntry.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<PricebookEntry> selectByIdAndProductIds(Set<Id> pricebookEntryIds, Set<Id> productIdSet) {
        return [Select Id,UnitPrice,price_disty_cost__c,Product2Id from PricebookEntry where Id IN: pricebookEntryIds And Product2Id IN: productIdSet];
    }
    
    public List<PricebookEntry> selectByPricebook2IdAndProductIds(Set<Id> pricebookIds, Set<Id> productIds){
        return [select id,Product2Id from PriceBookEntry where Pricebook2Id IN:pricebookIds and Product2Id IN : productIds];
    }
    
   
}