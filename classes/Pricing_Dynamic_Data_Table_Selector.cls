public class Pricing_Dynamic_Data_Table_Selector extends fflib_SObjectSelector {
    
    public static Pricing_Dynamic_Data_Table_Selector newInstance() {
        return (Pricing_Dynamic_Data_Table_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_Dynamic_Data_Table__mdt.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return Pricing_Dynamic_Data_Table__mdt.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Pricing_Dynamic_Data_Table__mdt> selectByType(Set<String> quoteLineType){
        return [SELECT Id,Pricing_Field_Label__c,Pricing_Field_Value__c, Pricing_Query__c, Label, Pricing_Where_Clause__c,Pricing_Record_Type_Pkl__c,Pricing_SearchColumn_Field__c FROM Pricing_Dynamic_Data_Table__mdt WHERE Pricing_Record_Type_Pkl__c =:quoteLineType];
    }
    
    public List <Pricing_Dynamic_Data_Table__mdt> selectByLabel(){
        return [SELECT Id,Pricing_Field_Label__c,Pricing_Field_Value__c, Label, Pricing_Record_Type_Pkl__c FROM Pricing_Dynamic_Data_Table__mdt WHERE Label NOT IN ('SVD', 'Quote', 'Quote Group')];
    }
}