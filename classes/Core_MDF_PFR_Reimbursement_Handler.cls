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
    public static Core_MDF_VRQuestionsWrapper.vrQuestionWrap calculateVariableReimbursement(Map<PartnerFundRequest, Id> pfrCPIdMap,String camptechnology) {
        Set<String> activityCategorySet = new Set<String>();
        Set<String> activityTypeSet = new Set<String>();
        Set<String> brandSet = new Set<String>();
        Set<String> productTypeSet = new Set<String>();
        Set<Id> programSet = new Set<Id>();
        Set<String> technologySet = new Set<String>();
        Core_MDF_VRQuestionsWrapper.vrQuestionWrap holdVRQuestn = new Core_MDF_VRQuestionsWrapper.vrQuestionWrap();
        String  questnIncentve = '';

        String questionAns = '';
        if(pfrCPIdMap != NULL && pfrCPIdMap.size() > 0){
            for(PartnerFundRequest pfr : pfrCPIdMap.keySet()){
                Id channelProgramId = pfrCPIdMap.get(pfr);
               
                // Adding Respective Value in Set to Query from Incentive table using OR logic
                if(pfr.Core_MDF_ActivityCategory__c != NULL){
                    activityCategorySet.add(pfr.Core_MDF_ActivityCategory__c);
                }
                if(pfr.Core_MDF_Activity_Types__c != NULL){
                    activityTypeSet.add(pfr.Core_MDF_Activity_Types__c);  
                }
                if(pfr.Core_MDF_Brand_nm__c != NULL){
                  
                    List<string> brandlst=new List<string>();
                    String brandVal=pfr.Core_MDF_Brand_nm__c;
                    //Avoid Deeply Nested IF Statements
                    brandlst = brandVal.contains(';') ? brandVal.split(';') : null;
                    for(String x:brandlst){
                        brandSet.add(x);
                    }
                }
                if(pfr.Core_MDF_ProductType__c != NULL){
                    productTypeSet.add(pfr.Core_MDF_ProductType__c);
                }
                if(channelProgramId != NULL){
                   
                    programSet.add(channelProgramId);
                }
                if(camptechnology != NULL){
                    technologySet.addAll(camptechnology.split(';'));
                }
            }
        }
       
        try{    
            List<Core_MDF_CoMarketing_Activity_Inc_Rule__c> incentiveRuleList = new List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>();
            if(activityCategorySet.size() > 0 || activityTypeSet.size() > 0 || brandSet.size() > 0 || productTypeSet.size() > 0 || programSet.size() > 0 || technologySet.size() > 0){
                incentiveRuleList = [SELECT Id, Name, Core_MDF_Channel_Program_Id__c, Core_MDF_Product_Type_Txt__c,Core_MDF_Brand_Nm__c,
                                            Core_MDF_Activity_Type_Nm__c, Core_MDF_Activity_Category_Nm__c, Core_MDF_Technology_Nm__c,
                                            Core_MDF_Active_Ind__c, Core_MDF_Ineffective_Dt__c, Core_MDF_Effective_Dt__c, Core_MDF_Incentive_Pct__c,Core_MDF_Question_Label__c  
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
            
            for(PartnerFundRequest newPFR : pfrCPIdMap.keySet()){
                for(Core_MDF_CoMarketing_Activity_Inc_Rule__c incentiveRule : incentiveRuleList){
                   
                    Set <String> brandStrSet  = new Set <String>();
                    Set <String> productTypeStrSet  = new Set <String>();
                    Set <String> activityCatStrSet  = new Set <String>();
                    Set <String> activityTypeStrSet  = new Set <String>();
                    Set <String> technologyStrSet  = new Set <String>();
                    Boolean isTechnologyMatched = false;
                    Boolean isBrandMatched=false;
                    // Prepare Set of String which for Comparing the value from PFR
                    // Each Set will then be compared to all the Activities respective value
                    // If Incentive Table Brand is not NULL
                    //Avoid Deeply Nested IF Statements
                    Set <String > pfrBrandSet = new Set <String>();
                    if(incentiveRule.Core_MDF_Brand_Nm__c != NULL){
                        brandStrSet.addAll(incentiveRule.Core_MDF_Brand_Nm__c.split(';'));
                    }
                    if(incentiveRule.Core_MDF_Brand_Nm__c != NULL && newPFR.Core_MDF_Brand_nm__c!=NULL){
                            pfrBrandSet.addAll(newPFR.Core_MDF_Brand_nm__c.split(';'));
                            for(String pfrBrand:brandStrSet){
                                
                                if(pfrBrandSet.contains(pfrBrand)){
                                    isBrandMatched=true;
                                    break;
                                }
                            }
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
                    //Avoid Deeply Nested IF Statements
                    Set <String > pfrTechnologySet = new Set <String>();
                    if(incentiveRule.Core_MDF_Technology_Nm__c != NULL && incentiveRule.Core_MDF_Technology_Nm__c != ''){
                        technologyStrSet.addAll(incentiveRule.Core_MDF_Technology_Nm__c.split(';'));
                    }
                    if(incentiveRule.Core_MDF_Technology_Nm__c != NULL && incentiveRule.Core_MDF_Technology_Nm__c != '' && camptechnology != NULL){
                        pfrTechnologySet.addAll(camptechnology.split(';'));
                            //[DCF/SPCF] - [OOC]  US945421 - start - added this logic if atleast one technology matches with activity technology that set technology to true if records on acitvity incentive field Core_MDF_ContainsCheck__c is set to true
                            for(String pfrTech : technologyStrSet){
                                if(pfrTechnologySet.contains(pfrTech)){
                                    isTechnologyMatched = true; 
                                    Break;
                                }
                          }
                            //[DCF/SPCF] - [OOC]  US945421 added this logic if atleast one technology matches with activity technology that set technology to true if records on acitvity incentive field Core_MDF_ContainsCheck__c is set to true
                        }
                    else{
                        isTechnologyMatched = true;
                    }
                   
                    // Compararison of Incentive Record value with Activity Record value
                     if(
                        ((((newPFR.Core_MDF_Start_Date__c != NULL && newPFR.Core_MDF_Start_Date__c >= incentiveRule.Core_MDF_Effective_Dt__c)) || incentiveRule.Core_MDF_Effective_Dt__c == NULL)
                        && (((newPFR.Core_MDF_Start_Date__c != NULL && newPFR.Core_MDF_Start_Date__c <= incentiveRule.Core_MDF_Ineffective_Dt__c)) || incentiveRule.Core_MDF_Ineffective_Dt__c == NULL)
                        ) 
                        && (activityCatStrSet.isEmpty() || (newPFR.Core_MDF_ActivityCategory__c != NULL && activityCatStrSet.contains(newPFR.Core_MDF_ActivityCategory__c)))
                        && (activityTypeStrSet.isEmpty() || (newPFR.Core_MDF_Activity_Types__c != NULL && activityTypeStrSet.contains(newPFR.Core_MDF_Activity_Types__c)))
                        //&& (brandStrSet.isEmpty() || (newPFR.Core_MDF_Brand__c != NULL && brandStrSet.contains(newPFR.Core_MDF_Brand__c)))
                        && (productTypeStrSet.isEmpty() || (newPFR.Core_MDF_ProductType__c != NULL && productTypeStrSet.contains(newPFR.Core_MDF_ProductType__c)))
                        && (incentiveRule.Core_MDF_Channel_Program_Id__c == NULL || pfrCPIdMap.get(newPFR) == NULL || (pfrCPIdMap.get(newPFR) != NULL && pfrCPIdMap.get(newPFR) == incentiveRule.Core_MDF_Channel_Program_Id__c))
                        && isTechnologyMatched && (brandStrSet.isEmpty() || isBrandMatched)
                    ){
                            
                            newPFR.Core_MDF_Incentive_Criteria_Id__c = incentiveRule.Id;
                            newPFR.Core_MDF_Incentive_pct__c = incentiveRule.Core_MDF_Incentive_Pct__c;
                        questnIncentve = incentiveRule.Core_MDF_Question_Label__c;
                        questionAns = (String)newPFR.get('Core_MDF_Incentive_Opted_In_ind__c');                      
                            break;
                    }
                }
            }
            List<PartnerFundRequest> newPFRList = new List<PartnerFundRequest>();
            newPFRList.addAll(pfrCPIdMap.keySet());
            holdVRQuestn.pfrData = newPFRList;
            holdVRQuestn.questionLabel = questnIncentve;
            holdVRQuestn.questionAns = questionAns;
            return holdVRQuestn;
          
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new DMLException('Exception Occured:::'+e);}
    }
    }