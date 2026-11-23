/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_ThirdPartyPOP
* Test Class  : Core_MDF_PFC_ThirdPartyPOP_TestClass
* Version     : 1.0 
* Created Date: 14-1-2022
* Modification Log :
* Developer                   Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
*INTEL-Areefa Banu            14-1-2022               Created to identify PartnerFundClaim which is eligible for ThirdParty POP functionality. 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFC_ThirdPartyPOP {
    
    public class wrapperThirdPartyPOP{
        @AuraEnabled public string ruleId;
        @AuraEnabled public boolean isThirdPartyPOP; 
    }
	    
    @AuraEnabled(cacheable=true) 
    public static wrapperThirdPartyPOP isValidThirdPartyPOPClaim(PartnerFundClaim pfc){
        try{
                   
            //boolean isThirstPartyPOP = false;
            List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
            Map<string,List<sobject>> inputForRuleEngine= new Map<string,List<sobject>>();
            Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = new  Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>>();
            wrapperThirdPartyPOP obj = new wrapperThirdPartyPOP();

            //Exclude RMF program from 3rd Party Rule Engine check
            List<String> thirdPartyRuleCheckExclusionProgramList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_3rdPartyRuleCheckExclusionPrgms');
            if(String.isNotBlank(pfc.Core_MDF_Program__c) && !thirdPartyRuleCheckExclusionProgramList.contains(pfc.Core_MDF_Program__c)){
                claimListToBeProcessed.add(pfc);
            }

            if(claimListToBeProcessed!=null && claimListToBeProcessed.size()>0){
                Core_MDF_Claim_Utility.calculateClaimAmtFieldsOnInsert(claimListToBeProcessed);  
              
                getGeoAndSubGeo(claimListToBeProcessed); 
                
                inputForRuleEngine.put('Third Party',claimListToBeProcessed);
                
                ruleEngineResult = Core_MDF_Rules_Engine.executeRulesByObjects(inputForRuleEngine); 
                 // try excepetion if rule engin fails : what will be falge and rule id value
            }       	
            
            if(!ruleEngineResult.isEmpty() &&  ruleEngineResult.containsKey('Third Party')){
                Map<String,Core_MDF_Rules_Engine.RulesEngineParams> rule1 = ruleEngineResult.get('Third Party');
               
                for(String thirdPartyPOP : rule1.keySet()){
                    if(rule1.get(thirdPartyPOP).result){
                       
                        obj.isThirdPartyPOP=true;
                        obj.ruleId =rule1.get(thirdPartyPOP).ruleRecord.Name;                    
                    }
                    else{
                      
                        obj.isThirdPartyPOP=false;
                        //obj.ruleId =rule1.get(thirdPartyPOP).ruleRecord.Name;     Even if rule engine return false, last rule Id will be return . so no need to stamp on claim.               
                    }
                    break;
                }
            }
         
            return obj;
        }catch (Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e); 
            return null; 
        }  
        /*wrapperThirdPartyPOP obj = new wrapperThirdPartyPOP();
        obj.isThirdPartyPOP=true;return obj;*/
    }
    
    @AuraEnabled(cacheable=true)
    public static wrapperThirdPartyPOP isClaimFlagedForThirdPartyPOP(Id claimRecordId){
        wrapperThirdPartyPOP obj = new wrapperThirdPartyPOP();
      
        PartnerFundClaim pfc = [select Id,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c from PartnerFundClaim where Id=:claimRecordId LIMIT 1];
        
        obj.isThirdPartyPOP = pfc.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c;
        return obj;
    }
    
    public static void getGeoAndSubGeo(List<PartnerFundClaim> newclaimList){
       
        // update Region field according to country on claim record
        Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper> wrapperMapOfCountryRegion = new Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper>();        
        wrapperMapOfCountryRegion = Core_MDF_CCP_GenericUtility.getCountryGeoMap();
        if(newclaimList != NULL && newclaimList.size() > 0){
            for(PartnerFundClaim pfc : newclaimList){
                pfc.Core_MDF_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).geo;
                pfc.Core_MDF_Sub_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).subGeo;
                 
            }
        }
    }    
   
}