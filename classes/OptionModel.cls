public class OptionModel { 
    public SBQQ__ProductOption__c record {get;set;}
    public Map<String,String> externalConfigurationData {get;set;}
    public Boolean configurable {get;set;}
    public Boolean configurationRequired {get;set;}
    public Boolean quantityEditable {get;set;}
    public Boolean priceEditable {get;set;}
    public Decimal productQuantityScale {get;set;}
    public Boolean priorOptionExists {get;set;}
    public Set<Id> dependentIds {get;set;}
    public Map<String,Set<Id>> controllingGroups {get;set;}
    public Map<String,Set<Id>> exclusionGroups {get;set;}
    public String reconfigureDimensionWarning {get;set;}
    public Boolean hasDimension {get;set;}
    public Boolean isUpgrade {get;set;}
    public String dynamicOptionKey {get;set;}
}