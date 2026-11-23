/*********************************************************************
 * Class Name 	: Core_MDF_RuleEngineParams
 * Description	: This class retunr the audit tule engine details.
 ********************************************************************/
public class Core_MDF_RuleEngineParams {
    @auraEnabled public boolean result {get;set;}
    @auraEnabled public Core_MDF_Audit_Rules_Engine__c ruleRecord{get;set;}
    @auraEnabled public string actionOnTrue {get;set;}
    @auraEnabled public string additionalInfo {get;set;}

}