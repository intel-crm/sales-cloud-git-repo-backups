public class Core_Field {
	public Core_Field(Schema.FieldSetMember f) {
        this.DBRequired = f.DBRequired;
        this.APIName = f.fieldPath;
        this.Label = f.label;
        this.Required = f.required;
        this.isInput = true;
        this.Type = String.valueOf(f.getType());
        this.isDateField = (this.Type == 'DATE')?true:false;
        this.isChangedField = false;
    }
    
    public Core_Field(Boolean DBRequired) {
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
    public Boolean isChangedField {get; set;}
}