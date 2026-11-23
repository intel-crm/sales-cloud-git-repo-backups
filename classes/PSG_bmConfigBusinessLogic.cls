/****************************************************************************************************
Apex Class Name : PSG_bmConfigBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Handler class for BMConfig logic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
public without sharing class PSG_bmConfigBusinessLogic{
    /************************************************************************************************************
	*Method Name : beforeInsertUpdateOperations
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Performs operations on before context of trigger.
	************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<core_cpq_bm_assignment_config__c> bmApproverList,Map<Id,core_cpq_bm_assignment_config__c> oldMap,Boolean isInsert){
        String tier_bUnit = '';
        Set<Id> bmEcpSet          =  new Set<Id>();
        Set<String> tierBUnitSet  =  new Set<String>();
        try{
            for(core_cpq_bm_assignment_config__c oldbmRec: [select Id, Name, core_cpq_end_customer_parent__c, core_cpq_business_unit_nm__c, core_cpq_asmo_txt__c, core_cpq_emea_txt__c,
                                                        core_cpq_japan_txt__c, core_cpq_apj_prc_txt__c, core_cpq_account_tier_nm__c  from core_cpq_bm_assignment_config__c ]){
                if(oldbmRec.core_cpq_end_customer_parent__c != null){
                    bmEcpSet.add(oldbmRec.core_cpq_end_customer_parent__c);
                }else{
                    tier_bUnit = ((String.isBlank(oldbmRec.core_cpq_account_tier_nm__c)?'': oldbmRec.core_cpq_account_tier_nm__c) + (String.isBlank(oldbmRec.core_cpq_business_unit_nm__c)?'': oldbmRec.core_cpq_business_unit_nm__c)).trim();
                    tierBUnitSet.add(tier_bUnit);
                }
            }
            Set<String> accountTierSet = new Set<String>{'PSG-Tier 1','PSG-Tier 2','PSG-Tier 3'};
            for(core_cpq_bm_assignment_config__c bmRec: bmApproverList){
                if((bmRec.core_cpq_end_customer_parent__c==null || !accountTierSet.contains(bmRec.core_cpq_account_tier_nm__c)) && bmRec.core_cpq_business_unit_nm__c=='All'){
                    bmRec.addError('Business Unit with value \'All\' cannot be selected for Tier-4 Accounts or when the ECP is left blank');
                }
                
                if(bmEcpSet.contains(bmRec.core_cpq_end_customer_parent__c)){
                    bmRec.addError('There cannot exist another duplicate record with the same ECP');
                }else if(bmRec.core_cpq_end_customer_parent__c==null){
                    String tier_bUnitStr = ((String.isBlank(bmRec.core_cpq_account_tier_nm__c)?'': bmRec.core_cpq_account_tier_nm__c) + (String.isBlank(bmRec.core_cpq_business_unit_nm__c)?'': bmRec.core_cpq_business_unit_nm__c)).trim();
                    if(tierBUnitSet.contains(tier_bUnitStr)){
                        bmRec.addError('There cannot exist another duplicate record with the same Account Tier and Business Unit, when the ECP is left blank');
                    }
                }
            }
        }catch(Exception e){
            PSG_Utility.logError(e);
        }        
    }
}