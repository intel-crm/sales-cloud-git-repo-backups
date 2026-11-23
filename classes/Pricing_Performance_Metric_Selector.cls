public class Pricing_Performance_Metric_Selector extends fflib_SObjectSelector {
    public static Pricing_Performance_Metric_Selector newInstance() {
        
       
        return (Pricing_Performance_Metric_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_Performance_Metric__c.SObjectType);
    }
    
    
    public Schema.SObjectType getSObjectType(){
        return Pricing_Performance_Metric__c.sObjectType;
    }
    
    /**
    * @description getSObjectFieldList to get the list of feilds
    * @author Rakshitha BR | 03-18-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    /**
    * @description Add the Method type and its parameter
    * @author Rakshitha BR | 03-18-2022 
    * @param recId 
    * @param recordTypeId 
    * @return List<Pricing_Comments__c> 
    **/
    public List<Pricing_Performance_Metric__c> selectByrecordIds(Id recordId){
        
        return [Select Id FROM Pricing_Performance_Metric__c where Id =:recordId];        
    
    }
     public List<Pricing_Performance_Metric__c> selectByQuoteLineIds(Id recordId){
        
        return [SELECT Id,Pricing_Performance_Metric_Nm__c, Pricing_Weighting_Pct__c, Pricing_Intel_SKU_Performance_Nbr__c ,
                Pricing_Comp_SKU_Performance_Nbr__c, Pricing_Other_Nm__c,Pricing_Quote_Line__r.RecordType.Name
                FROM Pricing_Performance_Metric__c WHERE Pricing_Quote_Line__c = :recordId order by Id];  
     }
    
    
}