public class ConfigAttributeModel { 
    public String name {get;set;}
    public String targetFieldName {get;set;}
    public Decimal displayOrder {get;set;}
    public String colmnOrder {get;set;}
    public Boolean required {get;set;}
    public Id featureId {get;set;}
    public String position {get;set;}
    public Boolean appliedImmediately {get;set;}
    public Boolean applyToProductOptions {get;set;}
    public Boolean autoSelect {get;set;}
    public String[] shownValues {get;set;}
    public String[] hiddenValues {get;set;}
    public Boolean hidden {get;set;}
    public String noSuchFieldName {get;set;}
    public Id myId {get;set;}
}