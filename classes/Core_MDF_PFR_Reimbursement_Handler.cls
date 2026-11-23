/***************************************************************************************************** 
Class Name :    Core_MDF_PFR_Reimbursement_Handler
Description:    Activity Variable Reimbursment
Added By   :    
Modified By:                      Date:03/05/2020                     Changes:None  
******************************************************************************************************/
public without sharing class Core_MDF_PFR_Reimbursement_Handler {
    
    /***************************************************************************************************** 
    Method Name :   calculateVariableReimbursement
    Description :  
    Added By    :    
    Modified By :                      Date:03/05/2020                     Changes:None                               
    ******************************************************************************************************/
    //public static List<PartnerFundRequest> calculateVariableReimbursement(List<PartnerFundRequest>newPFRList){
	public static List<PartnerFundRequest> calculateVariableReimbursement(Map<PartnerFundRequest, Id> pfrCPIdMap) {
        Set<String> activityCategorySet = new Set<String>();
        Set<String> activityTypeSet = new Set<String>();
        Set<String> brandSet = new Set<String>();
        Set<String> productTypeSet = new Set<String>();
        Set<Id> programSet = new Set<Id>();
        Set<String> technologySet = new Set<String>();
        
        if(pfrCPIdMap != NULL && pfrCPIdMap.size() > 0){
            for(PartnerFundRequest pfr : pfrCPIdMap.keySet()){
                Id channelProgramId = pfrCPIdMap.get(pfr);
                system.debug('pfrCPIdMap.get(pfr)-->'+pfrCPIdMap.get(pfr));
                system.debug('channelProgramId: ' + channelProgramId);
                // Adding Respective Value in Set to Query from Incentive table using OR logic
                if(pfr.Core_MDF_ActivityCategory__c != NULL){
                    activityCategorySet.add(pfr.Core_MDF_ActivityCategory__c);
                }
                if(pfr.Core_MDF_Activity_Types__c != NULL){
                    activityTypeSet.add(pfr.Core_MDF_Activity_Types__c);  
                }
                if(pfr.Core_MDF_Brand__c != NULL){
                    brandSet.add(pfr.Core_MDF_Brand__c);
                }
                if(pfr.Core_MDF_ProductType__c != NULL){
                    productTypeSet.add(pfr.Core_MDF_ProductType__c);
                }
                if(channelProgramId != NULL){
                    //programSet.add(pfr.ChannelPartner.Core_MDF_Channel_Program__c);
                    programSet.add(channelProgramId);
                }
                if(pfr.Core_MDF_Technology_txt__c != NULL){
                    technologySet.addAll(pfr.Core_MDF_Technology_txt__c.split(';'));
                }
            }
        }
        system.debug('activityCategorySet-->'+activityCategorySet);
		system.debug('activityTypeSet-->'+activityTypeSet);
		system.debug('brandSet-->'+brandSet);
		system.debug('productTypeSet-->'+productTypeSet);
        system.debug('programSet-->'+programSet);
		system.debug('technologySet-->'+technologySet);
        try{    
            List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> incentiveRuleList = new List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
            if(activityCategorySet.size() > 0 || activityTypeSet.size() > 0 || brandSet.size() > 0 || productTypeSet.size() > 0 || programSet.size() > 0 || technologySet.size() > 0){
                incentiveRuleList = [SELECT Id, Name, Core_MDF_Channel_Program_Id__c, Core_MDF_Product_Type_Txt__c,Core_MDF_Brand_Nm__c,
                                            Core_MDF_Activity_Type_Nm__c, Core_MDF_Activity_Category_Nm__c, Core_MDF_Technology_Nm__c,
                                            Core_MDF_Active_Ind__c, Core_MDF_Ineffective_Dt__c, Core_MDF_Effective_Dt__c, Core_MDF_Incentive_Pct__c
                                            FROM Core_MDF_CoMarketing_Activity_Inc_Rule__c
                                            WHERE (Core_MDF_Channel_Program_Id__c IN : programSet OR
                                            Core_MDF_Activity_Category_Nm__c IN: activityCategorySet OR
                                            Core_MDF_Activity_Type_Nm__c IN: activityTypeSet OR
                                            Core_MDF_Brand_Nm__c IN: brandSet OR
                                            Core_MDF_Product_Type_Txt__c IN: productTypeSet OR
                                            Core_MDF_Technology_Nm__c IN: technologySet) AND
                                            Core_MDF_Active_Ind__c = true
                                          ];
            }
            system.debug('Here-->Size'+incentiveRuleList.size());
			for(PartnerFundRequest newPFR : pfrCPIdMap.keySet()){
                for(Core_MDF_CoMarketing_Activity_Inc_Rule__c incentiveRule : incentiveRuleList){
                    system.debug('Here-->1'+incentiveRule.Id+'---'+incentiveRule.Name);
                    Set <String> brandStrSet  = new Set <String>();
                    Set <String> productTypeStrSet  = new Set <String>();
                    Set <String> activityCatStrSet  = new Set <String>();
                    Set <String> activityTypeStrSet  = new Set <String>();
                    Set <String> technologyStrSet  = new Set <String>();
                    Boolean isTechnologyMatched = false;
                    // Prepare Set of String which for Comparing the value from PFR
                    // Each Set will then be compared to all the Activities respective value
                    // If Incentive Table Brand is not NULL
                    if(incentiveRule.Core_MDF_Brand_Nm__c != NULL){
                        brandStrSet.addAll(incentiveRule.Core_MDF_Brand_Nm__c.split(';')); 
                    }
                    // If Incentive Table Product Type is not NULL
                    if(incentiveRule.Core_MDF_Product_Type_Txt__c != NULL){
                        productTypeStrSet.addAll(incentiveRule.Core_MDF_Product_Type_Txt__c.split(';'));
                    }
                    // If Incentive Table Activity Category is not NULL
                    if(incentiveRule.Core_MDF_Activity_Category_Nm__c != NULL){
                        activityCatStrSet.addAll(incentiveRule.Core_MDF_Activity_Category_Nm__c.split(';'));
                    }
                    // If Incentive Table Actvity Type is not NULL
                    if(incentiveRule.Core_MDF_Activity_Type_Nm__c != NULL){
                        activityTypeStrSet.addAll(incentiveRule.Core_MDF_Activity_Type_Nm__c.split(';'));
                    }
                    // If Incentive Table Technology is not NULL
                    // Since Technology on Incentive Object and Activity Both Are Multi-Select we need to Check If All Value in Incentive matches with\
                    // values in Actvity Record hence we are using a boolean to check and use contains all.
                    if(incentiveRule.Core_MDF_Technology_Nm__c != NULL){
                        technologyStrSet.addAll(incentiveRule.Core_MDF_Technology_Nm__c.split(';'));
                        Set <String > pfrTechnologySet = new Set <String>();
                        system.debug('Here-->2'+newPFR.Core_MDF_Technology_txt__c);
                        if(newPFR.Core_MDF_Technology_txt__c != NULL){
                            pfrTechnologySet.addAll(newPFR.Core_MDF_Technology_txt__c.split(';'));
                            system.debug('Here-->2a'+pfrTechnologySet);
                            system.debug('Here-->2b'+technologyStrSet);
                            system.debug('Here-->2c'+pfrTechnologySet.containsAll(technologyStrSet));
                            if(pfrTechnologySet.containsAll(technologyStrSet)){
                                isTechnologyMatched = true;
                            }
                        }
                    }else{
                        isTechnologyMatched = true;
                    }
                    system.debug('Here-->3a'+brandStrSet+'--'+brandStrSet.contains(newPFR.Core_MDF_Brand__c)+'--'+brandStrSet.isEmpty());
                    system.debug('Here-->3b'+productTypeStrSet+'--'+productTypeStrSet.contains(newPFR.Core_MDF_ProductType__c)+'--'+productTypeStrSet.isEmpty());
                    system.debug('Here-->3c'+activityCatStrSet+'--'+activityCatStrSet.contains(newPFR.Core_MDF_ActivityCategory__c)+'--'+activityCatStrSet.isEmpty());
                    system.debug('Here-->3d'+activityTypeStrSet+'--'+activityTypeStrSet.contains(newPFR.Core_MDF_Activity_Types__c)+'--'+activityTypeStrSet.isEmpty());
                    system.debug('Here-->3e'+isTechnologyMatched+'--'+technologyStrSet.contains('Intel® Optane™ DC Persistent Memory')+'--'+technologyStrSet.isEmpty());
                    system.debug('Here-->3f'+incentiveRule.Core_MDF_Channel_Program_Id__c+'--'+pfrCPIdMap.get(newPFR));
                    system.debug('Here-->3g'+incentiveRule.Core_MDF_Effective_Dt__c+'--'+incentiveRule.Core_MDF_Ineffective_Dt__c+'--PFRStartDate--'+newPFR.Core_MDF_Start_Date__c);
                    system.debug('Here-->3h'+(newPFR.Core_MDF_Start_Date__c >=  incentiveRule.Core_MDF_Effective_Dt__c));
                    // Compararison of Incentive Record value with Activity Record value
                    if(
                        ((((newPFR.Core_MDF_Start_Date__c != NULL && newPFR.Core_MDF_Start_Date__c >= incentiveRule.Core_MDF_Effective_Dt__c)) || incentiveRule.Core_MDF_Effective_Dt__c == NULL)
                        && (((newPFR.Core_MDF_Start_Date__c != NULL && newPFR.Core_MDF_Start_Date__c <= incentiveRule.Core_MDF_Ineffective_Dt__c)) || incentiveRule.Core_MDF_Ineffective_Dt__c == NULL)
                        ) 
                        && (activityCatStrSet.isEmpty() || (newPFR.Core_MDF_ActivityCategory__c != NULL && activityCatStrSet.contains(newPFR.Core_MDF_ActivityCategory__c)))
                        && (activityTypeStrSet.isEmpty() || (newPFR.Core_MDF_Activity_Types__c != NULL && activityTypeStrSet.contains(newPFR.Core_MDF_Activity_Types__c)))
                        && (brandStrSet.isEmpty() || (newPFR.Core_MDF_Brand__c != NULL && brandStrSet.contains(newPFR.Core_MDF_Brand__c)))
                        && (productTypeStrSet.isEmpty() || (newPFR.Core_MDF_ProductType__c != NULL && productTypeStrSet.contains(newPFR.Core_MDF_ProductType__c)))
                        && (incentiveRule.Core_MDF_Channel_Program_Id__c == NULL || pfrCPIdMap.get(newPFR) == NULL || (pfrCPIdMap.get(newPFR) != NULL && pfrCPIdMap.get(newPFR) == incentiveRule.Core_MDF_Channel_Program_Id__c))
                        && isTechnologyMatched
                    ){
                            system.debug('Here-->4'+newPFR);
                            newPFR.Core_MDF_Incentive_Criteria_Id__c = incentiveRule.Id;
                            newPFR.Core_MDF_Incentive_pct__c = incentiveRule.Core_MDF_Incentive_Pct__c;
                            break;
                    }
                }
            }
			List<PartnerFundRequest> newPFRList = new List<PartnerFundRequest>();
			newPFRList.addAll(pfrCPIdMap.keySet());
            return newPFRList ;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new DMLException('Exception Occured:::'+e);}
    }
    /********************************************************************************************************
     * Test Code Using Recommendations*
    *********************************************************************************************************/
   	/*@InvocableMethod(label='GetRecommendations' description='Return All the rules' category='Activity')
    public static List<List<Recommendation>> getRecommendations(List<String> activityId) 
    {
        system.debug('Recommendations->activityId' + activityId);
        List<List<Recommendation>> recommendations = new List<List<Recommendation>>();
        List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> incentiveRules = new List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
        
        List<PartnerFundRequest> activityRecord = [SELECT Id,Core_MDF_ActivityCategory__c,Core_MDF_Activity_Types__c,Core_MDF_ProductType__c,
                                             Core_MDF_Brand__c,Core_MDF_Program__c,Campaign.Core_MDF_Technology__c,Core_MDF_Start_Date__c,
                                             Core_MDF_End_Date__c
                                             FROM PartnerFundRequest WHERE Id in :activityId];
        
        List<Recommendation> recs = new List<Recommendation>(); 
        Recommendation rec = new Recommendation(
                        Name = activityRecord[0].Core_MDF_Program__c,
                        Description = 'This activity is eligible for incentive. Please click the Process button to apply it.',
                        ActionReference = 'Activity_Incentive_Check',
                        AcceptanceLabel = 'Process'
                    );
        recs.add(rec);
        recommendations.add(recs);
        system.debug('Recommendations->Size' + recommendations.size());
        return recommendations;
    }*/    
}