public class Pricing_Quote_Team_Selector extends fflib_SObjectSelector {

    public static Pricing_Quote_Team_Selector newInstance() {
        
        
        return (Pricing_Quote_Team_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_Quote_Team__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType(){
        return Pricing_Quote_Team__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Pricing_Quote_Team__c> selectbyQuoteId(Id quoteId){
        return [SELECT id, Pricing_Quote_Id__c FROM Pricing_Quote_Team__c where Pricing_Quote_Id__c =:quoteId];
    }
}