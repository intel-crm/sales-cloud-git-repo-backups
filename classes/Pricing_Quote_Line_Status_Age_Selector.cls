public class Pricing_Quote_Line_Status_Age_Selector extends fflib_SObjectSelector {

    public static Pricing_Quote_Line_Status_Age_Selector newInstance() {
        
        
        return (Pricing_Quote_Line_Status_Age_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_Quote_Line_Status_Age__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType(){
        return Pricing_Quote_Line_Status_Age__c.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Pricing_Quote_Line_Status_Age__c> selectbyQliId(Id quoteLineId){
        return [SELECT Id,Pricing_TPT_Quote_Line_Number__c from Pricing_Quote_Line_Status_Age__c where Pricing_TPT_Quote_Line_Number__c =: quoteLineId];
    }
    
    public List<Pricing_Quote_Line_Status_Age__c> selectbyQuoteId(Id quoteId){
        return [SELECT id FROM Pricing_Quote_Line_Status_Age__c where Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c =: quoteId];
    }
    
    public List<Pricing_Quote_Line_Status_Age__c> selectbyQliIdandRole(Set<Id> quoteLineIdSet,String currentUserRole){
        return [SELECT Id, Name,Pricing_TPT_Status_From__c,Pricing_TPT_Status_Name__c,Pricing_TPT_Aggregate_Role_Time__c, Pricing_TPT_Role_Aggregate_cb__c,Pricing_TPT_User_Role__c,Pricing_TPT_Set_Time__c,Pricing_TPT_Change_Time__c,Pricing_TPT_To_Stage_Actor_Nm__c,Pricing_TPT_Quote_Line_Number__c,Pricing_TPT_Change_Request_QuoteLine_cb__c,Revision_QuoteLine__c from Pricing_Quote_Line_Status_Age__c 
                where (Pricing_TPT_Quote_Line_Number__c IN : quoteLineIdSet and (Pricing_TPT_Change_Time__c = null or (Pricing_TPT_Role_Aggregate_cb__c = true and Pricing_TPT_User_Role__c =: currentUserRole)))];
    }    
}