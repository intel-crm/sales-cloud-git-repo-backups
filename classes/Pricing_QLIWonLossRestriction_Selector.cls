public class Pricing_QLIWonLossRestriction_Selector extends fflib_SObjectSelector {

    public static Pricing_QLIWonLossRestriction_Selector newInstance() {
        
        
        return (Pricing_QLIWonLossRestriction_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_QuoteLine_WonLoss_Restriction__mdt.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Pricing_QuoteLine_WonLoss_Restriction__mdt.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }

    public Integer selectByAccountIds(Id accId){
        return [SELECT count() FROM Pricing_QuoteLine_WonLoss_Restriction__mdt WHERE Pricing_Account_Id__c = :accId AND Pricing_IsActive_Ind__c=true];
    }
}