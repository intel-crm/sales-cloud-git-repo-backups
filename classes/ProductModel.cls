public class ProductModel {
    public Product2 record {get;set;}
    public Id upgradedAssetId {get;set;}
    public String currencySymbol {get;set;}
    public String currencyCode {get;set;}
    public String[] featureCategories {get;set;}
    public OptionModel[] options {get;set;}
    public FeatureModel[] features {get;set;}
    public ConfigurationModel configuration {get;set;}
    public ConfigAttributeModel[] configurationAttributes {get;set;}
    public ConfigAttributeModel[] inheritedConfigurationAttributes {get;set;}
    public ConstraintModel[] constraints {get;set;}
}