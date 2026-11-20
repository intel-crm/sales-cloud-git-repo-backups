/** Class for validation rules on Audit Rules Engine records
*  Enabled for CCF, DCF, CCFB, SPCF Claims - WW34 2021
*/
public without sharing class Core_MDF_Audit_Rules_ServiceHandler {

    /* Checks if there is always only one record with Immediate Rule - Yes per Program and Budget Type */
    public static void checkForDuplicates(List<Core_MDF_Audit_Rules_Engine__c> newAuditRules) {
        List<string> programList = new List<string>();
        Map<string,Core_MDF_Audit_Rules_Engine__c> programBTToIRMap = new Map<string,Core_MDF_Audit_Rules_Engine__c>();
        Map<string,Core_MDF_Audit_Rules_Engine__c> actualMap = new Map<string,Core_MDF_Audit_Rules_Engine__c>();
		
        try{
            for(Core_MDF_Audit_Rules_Engine__c newRules: newAuditRules) {
                if(!programList.contains(newRules.Core_MDF_Program_Nm__c)) {
                    programList.add(newRules.Core_MDF_Program_Nm__c);
                }
                if(newRules.Core_MDF_Immediate_Ind__c == 'Yes') {
                    programBTToIRMap.put(newRules.Core_MDF_Rule_Type_Nm__c+newRules.Core_MDF_Program_Nm__c+newRules.Core_MDF_Budget_Type_Multi_Nm__c+newRules.Core_MDF_Region_Cd__c, newRules);
                }
            }    
            for(Core_MDF_Audit_Rules_Engine__c rules: [select id,Core_MDF_Immediate_Ind__c, Core_MDF_Budget_Type_Multi_Nm__c,Core_MDF_Program_Nm__c,Core_MDF_Region_Cd__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c 
                                                        where Core_MDF_Program_Nm__c in :programList and Core_MDF_Immediate_Ind__c = 'Yes' and Core_MDF_Active_Ind__c=true]) {
                                                            actualMap.put(rules.Core_MDF_Rule_Type_Nm__c+rules.Core_MDF_Program_Nm__c+rules.Core_MDF_Budget_Type_Multi_Nm__c+rules.Core_MDF_Region_Cd__c, rules);
                                                        }
            for(string key: programBTToIRMap.keyset()) {
                if(actualMap.get(key) != null) {
                    if(programBTToIRMap.get(key).id != actualMap.get(key).id){
                        programBTToIRMap.get(key).addError('Immediate Rule for the Rule Type Program, Budget Type and Region already exists.');
                    }
                }
            } 
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
    }

}