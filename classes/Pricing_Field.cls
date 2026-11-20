public class Pricing_Field {
	public Pricing_Field(Schema.FieldSetMember f) {
        this.DBRequired = f.DBRequired;
        this.APIName = f.fieldPath;
        this.Label = f.label;
        this.Required = f.required;
        this.isInput = true;
        this.Type = String.valueOf(f.getType());
        this.isDateField = (this.Type == 'DATE')?true:false;
    }
    
    public Pricing_Field(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    @AuraEnabled
    public Boolean DBRequired { get;set; }
    
    @AuraEnabled
    public String APIName { get;set; }
    
    @AuraEnabled
    public String Label { get;set; }
    
    @AuraEnabled
    public Boolean Required { get;set; }
    
    @AuraEnabled
    public String Type { get; set; }
    
    @AuraEnabled 
    public Boolean isInput { get; set; }
    
    @AuraEnabled 
    public date fieldValue {get; set;}
    
    @AuraEnabled
    public Boolean isDateField { get; set; }
    
    @AuraEnabled 
    public String programType {get; set;}
    
    @AuraEnabled 
    public Double doubleFieldValue {get; set;}
    
    @AuraEnabled 
    public Boolean fieldDisabled {get; set;}    
    
}