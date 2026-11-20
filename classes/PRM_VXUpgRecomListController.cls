/****************************************************************************************************************************
Apex Class Name     : PRM_VXUpgRecomListController 
Version             : 1.0
Created Date        : 02 Apr 2020

Modification Log    :
* Developer                 Date                    Description
* -------------------------------------------------------------------------------------------------------------------------------
* Bharath Kumar       02 Apr 2020                Displaying Aggregated list of Records for Value Exchange Upgrade Recommendations
* Bharath             09 Sep 2020                US773368 - Removed Inprocess Records from the UI only Status New records should display
**********************************************************************************************************************************/
public without sharing class PRM_VXUpgRecomListController {
    
    public static Schema.DescribeFieldResult fieldResult = PRM_Value_Exchange_Recommendation__c.PRM_Partner_Role_Nm__c.getDescribe();  
    public static List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
    //US773368 - Commented Status InProcess as part of this User story change
    public static final String[] VX_STATUS_NEW_INPROCESS = new  String[]{System.Label.PRM_Status_New/*,System.Label.PRM_VX_Status*/};
    public static final string VX_RECOMMENDATION_TYPE_UPGARDE = 'Upgrade';
    public static final string SPECIALTY_YES = 'Yes';
    public static final string SPECIALTY_NO = 'No';
    public static final string SPECIALTY_NA = 'NA';
    public static final string SYM_SEMICOL = ';';
    //Method to return all the Aggregated Records for Upgrade Recommendations
    @AuraEnabled(cacheable=true)
    public static FinalWrapper getUpgRecList(){
        FinalWrapper parentRecMapAndList = new FinalWrapper();
        Map<String,String> tierMap = new Map<String,String>();
        Map<String,PRM_Value_Exchange_Recommendation__c> notGroupedQualFields = new Map<String,PRM_Value_Exchange_Recommendation__c>();
        Map<String,Map<String,Decimal>> mapOfStrKeyandUniqAccforTrainingCredits = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> mapOfStrKeyandUniqAccforMpSolutions = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> mapOfStrKeyandUniqAccforNoOfEmpTraining = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> mapOfStrKeyandUniqAccforTotalNbrComp = new Map<String,Map<String,Decimal>>();
        Map<String,String> selectBenifitMap = new Map<String,String>();
        Map<String,String> specialtyPresentMap = new Map<String,String>();
        //Map<String,String> specialtyCriteriaNotPresentMap = new Map<String,String>();
        Map<String,Decimal> strParentKeyandSumValfortrainingCreditsMap = new Map<String,Decimal>();
        Map<String,Decimal> strParentKeyandSumValforMPSolutionsMap = new Map<String,Decimal>();
        Map<String,Decimal> strParentKeyandSumValforNoofEmpTrainingMap = new Map<String,Decimal>();
        Map<String,Decimal> strParentKeyandSumValforTotalNbrComp = new Map<String,Decimal>();

        Id upgRecTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();        
        
        for(ChannelProgramLevel tier : [Select Id,Name from ChannelProgramLevel]){
            tierMap.put(tier.Id,tier.Name);
        }
        
        List<PRM_Value_Exchange_Recommendation__c> vxRecords = [SELECT PRM_One_Partner_Id__c,PRM_One_Partner_Id__r.Name,PRM_Account_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Tier_Id__r.Name,PRM_Market_Type_Nm__c,PRM_Recommendation_Type_Nm__c,PRM_Eligibility_Tier__r.Name,
                                                                PRM_Recommendation_Status_Nm__c,PRM_Type_Of_Solutions_Txt__c,PRM_Specialty_Present_Nm__c,PRM_Select_Benefit_Txt__c,PRM_Rank_Nbr__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Number_Of_MP_Solutions_Nbr__c,PRM_No_Of_Employees_Done_Training_Nbr__c,  
                                                                PRM_Total_Achieved_Competency_Nbr__c,PRM_Submitted_Integration_Report_Ind__c,PRM_Account_Plan_Ind__c,PRM_Notes__c FROM PRM_Value_Exchange_Recommendation__c WHERE RecordTypeId = :upgRecTypeId and PRM_Recommendation_Type_Nm__c =:VX_RECOMMENDATION_TYPE_UPGARDE and PRM_Recommendation_Status_Nm__c IN :VX_STATUS_NEW_INPROCESS];  
        for(PRM_Value_Exchange_Recommendation__c ver:vxRecords){
            String vxKey = ver.PRM_One_Partner_Id__r.Name+SYM_SEMICOL+ver.PRM_Partner_Role_Nm__c+SYM_SEMICOL+ver.PRM_Tier_Id__r.Name+SYM_SEMICOL+ver.PRM_Market_Type_Nm__c;
            if(!notGroupedQualFields.containsKey(vxKey)){
                PRM_Value_Exchange_Recommendation__c qfields = new PRM_Value_Exchange_Recommendation__c();
                qfields.PRM_Eligibility_Tier__c = ver.PRM_Eligibility_Tier__c;
                qfields.PRM_Recommendation_Type_Nm__c = ver.PRM_Recommendation_Type_Nm__c;
                qfields.PRM_Recommendation_Status_Nm__c = ver.PRM_Recommendation_Status_Nm__c;
                qfields.PRM_One_Partner_Id__c = ver.PRM_One_Partner_Id__c;
                qfields.PRM_Rank_Nbr__c = ver.PRM_Rank_Nbr__c;
                qfields.PRM_Notes__c = ver.PRM_Notes__c;
                qfields.PRM_Submitted_Integration_Report_Ind__c = ver.PRM_Submitted_Integration_Report_Ind__c;
                qfields.PRM_Account_Plan_Ind__c = ver.PRM_Account_Plan_Ind__c;
                qfields.PRM_Recommendation_Status_Nm__c = ver.PRM_Recommendation_Status_Nm__c;
                //Adding all the remaining fileds in Map which can not be grouped 
                notGroupedQualFields.put(vxKey,qfields);
            }
            //Adding Specialty present value to the Map If any one of the child records criteria is present
            if(!specialtyPresentMap.containsKey(vxKey) && ver.PRM_Specialty_Present_Nm__c == SPECIALTY_YES ){
                specialtyPresentMap.put(vxKey,ver.PRM_Specialty_Present_Nm__c);
            }

            /*if(!specialtyCriteriaNotPresentMap.containsKey(vxKey) && ver.PRM_Specialty_Present_Nm__c == SPECIALTY_NO){
                specialtyCriteriaNotPresentMap.put(vxKey,ver.PRM_Specialty_Present_Nm__c);
            }*/
            //Merging all the Select benefits present at the account level seperated by comma
            if(selectBenifitMap.containsKey(vxKey) && ver.PRM_Select_Benefit_Txt__c != null && ver.PRM_Select_Benefit_Txt__c != SPECIALTY_NA){
                String existingSelBenefit = selectBenifitMap.get(vxKey);
                for(String curBenefits:ver.PRM_Select_Benefit_Txt__c.split(',')){
                    if(!existingSelBenefit.containsIgnoreCase(curBenefits)){
                        existingSelBenefit = existingSelBenefit + ','+curBenefits;
                    }
                }
                selectBenifitMap.put(vxKey,existingSelBenefit);
            }else{
                if(ver.PRM_Select_Benefit_Txt__c != null && !selectBenifitMap.containsKey(vxKey) && ver.PRM_Select_Benefit_Txt__c != SPECIALTY_NA){
                    selectBenifitMap.put(vxKey,ver.PRM_Select_Benefit_Txt__c);
                }
            }
            //Adding all the accounts to Map for a parent key, if have same account multiple times considering min value for Training credits
            if(mapOfStrKeyandUniqAccforTrainingCredits.containsKey(vxKey) && ver.PRM_Training_Credit_Points_Count_Nbr__c != null){
                Map<String,Decimal> existingAccsandValues = mapOfStrKeyandUniqAccforTrainingCredits.get(vxKey);
                String currAcckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                //for(String acc:existingAccsandValues.keySet()){
                    if(existingAccsandValues.containsKey(currAcckey) && (existingAccsandValues.get(currAcckey) > ver.PRM_Training_Credit_Points_Count_Nbr__c)){
                        existingAccsandValues.put(currAcckey,ver.PRM_Training_Credit_Points_Count_Nbr__c);
                    }else{
                        if(!existingAccsandValues.containsKey(currAcckey)){
                            existingAccsandValues.put(currAcckey,ver.PRM_Training_Credit_Points_Count_Nbr__c);
                        }
                    }
                //}
                mapOfStrKeyandUniqAccforTrainingCredits.put(vxKey,existingAccsandValues);
            }else{
                if(ver.PRM_Training_Credit_Points_Count_Nbr__c != null){
                    Map<String,Decimal> singleAccAndValueMap = new Map<String,Decimal>();
                    String acckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                    singleAccAndValueMap.put(acckey,ver.PRM_Training_Credit_Points_Count_Nbr__c);
                    mapOfStrKeyandUniqAccforTrainingCredits.put(vxKey,singleAccAndValueMap);
                }
            }
            
            if(mapOfStrKeyandUniqAccforMpSolutions.containsKey(vxKey) && ver.PRM_Number_Of_MP_Solutions_Nbr__c != null){
                Map<String,Decimal> existingAccsandValues = mapOfStrKeyandUniqAccforMpSolutions.get(vxKey);
                String currAcckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                //for(String acc:existingAccsandValues.keySet()){
                    if(existingAccsandValues.containsKey(currAcckey) && (existingAccsandValues.get(currAcckey) > ver.PRM_Number_Of_MP_Solutions_Nbr__c)){
                        existingAccsandValues.put(currAcckey,ver.PRM_Number_Of_MP_Solutions_Nbr__c);
                    }else{
                        if(!existingAccsandValues.containsKey(currAcckey)){
                            existingAccsandValues.put(currAcckey,ver.PRM_Number_Of_MP_Solutions_Nbr__c);
                        }
                    }
                //}
                mapOfStrKeyandUniqAccforMpSolutions.put(vxKey,existingAccsandValues);
            }else{
                if(ver.PRM_Number_Of_MP_Solutions_Nbr__c != null){
                    Map<String,Decimal> singleAccAndValueMap = new Map<String,Decimal>();
                    String acckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                    singleAccAndValueMap.put(acckey,ver.PRM_Number_Of_MP_Solutions_Nbr__c);
                    mapOfStrKeyandUniqAccforMpSolutions.put(vxKey,singleAccAndValueMap);
                }
            }

            if(mapOfStrKeyandUniqAccforNoOfEmpTraining.containsKey(vxKey) && ver.PRM_No_Of_Employees_Done_Training_Nbr__c != null){
                Map<String,Decimal> existingAccsandValues = mapOfStrKeyandUniqAccforNoOfEmpTraining.get(vxKey);
                String currAcckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                //for(String acc:existingAccsandValues.keySet()){
                    if(existingAccsandValues.containsKey(currAcckey) && (existingAccsandValues.get(currAcckey) > ver.PRM_No_Of_Employees_Done_Training_Nbr__c)){
                        existingAccsandValues.put(currAcckey,ver.PRM_No_Of_Employees_Done_Training_Nbr__c);
                    }else{
                        if(!existingAccsandValues.containsKey(currAcckey)){
                            existingAccsandValues.put(currAcckey,ver.PRM_No_Of_Employees_Done_Training_Nbr__c);
                        }
                    }
                //}
                mapOfStrKeyandUniqAccforNoOfEmpTraining.put(vxKey,existingAccsandValues);
            }else{
                if(ver.PRM_No_Of_Employees_Done_Training_Nbr__c != null){
                    Map<String,Decimal> singleAccAndValueMap = new Map<String,Decimal>();
                    String acckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                    singleAccAndValueMap.put(acckey,ver.PRM_No_Of_Employees_Done_Training_Nbr__c);
                    mapOfStrKeyandUniqAccforNoOfEmpTraining.put(vxKey,singleAccAndValueMap);
                }
            }

            if(mapOfStrKeyandUniqAccforTotalNbrComp.containsKey(vxKey) && ver.PRM_Total_Achieved_Competency_Nbr__c != null){
                Map<String,Decimal> existingAccsandValues = mapOfStrKeyandUniqAccforTotalNbrComp.get(vxKey);
                String currAcckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                //for(String acc:existingAccsandValues.keySet()){
                    if(existingAccsandValues.containsKey(currAcckey) && (existingAccsandValues.get(currAcckey) > ver.PRM_Total_Achieved_Competency_Nbr__c)){
                        existingAccsandValues.put(currAcckey,ver.PRM_Total_Achieved_Competency_Nbr__c);
                    }else{
                        if(!existingAccsandValues.containsKey(currAcckey)){
                            existingAccsandValues.put(currAcckey,ver.PRM_Total_Achieved_Competency_Nbr__c);
                        }
                    }
                //}
                mapOfStrKeyandUniqAccforTotalNbrComp.put(vxKey,existingAccsandValues);
            }else{
                if(ver.PRM_Total_Achieved_Competency_Nbr__c != null){
                    Map<String,Decimal> singleAccAndValueMap = new Map<String,Decimal>();
                    String acckey = ver.PRM_One_Partner_Id__r.Name+ver.PRM_Account_Id__c+ver.PRM_Partner_Role_Nm__c+ver.PRM_Tier_Id__r.Name+ver.PRM_Market_Type_Nm__c;
                    singleAccAndValueMap.put(acckey,ver.PRM_Total_Achieved_Competency_Nbr__c);
                    mapOfStrKeyandUniqAccforTotalNbrComp.put(vxKey,singleAccAndValueMap);
                }
            }
            
        }
        
        strParentKeyandSumValfortrainingCreditsMap = calculateSumVal(mapOfStrKeyandUniqAccforTrainingCredits);
        strParentKeyandSumValforMPSolutionsMap = calculateSumVal(mapOfStrKeyandUniqAccforMpSolutions);
        strParentKeyandSumValforNoofEmpTrainingMap = calculateSumVal(mapOfStrKeyandUniqAccforNoOfEmpTraining);
        strParentKeyandSumValforTotalNbrComp = calculateSumVal(mapOfStrKeyandUniqAccforTotalNbrComp); 
        
        List<AggregateResult> recomRecords = [SELECT PRM_One_Partner_Id__r.Name opidname,PRM_Partner_Role_Nm__c,PRM_Tier_Id__r.Name tier,PRM_Market_Type_Nm__c,SUM(PRM_Sales_Amount_Nbr__c)totalSales FROM PRM_Value_Exchange_Recommendation__c WHERE RecordTypeId = :upgRecTypeId and PRM_Recommendation_Status_Nm__c IN :VX_STATUS_NEW_INPROCESS and PRM_Recommendation_Type_Nm__c =:VX_RECOMMENDATION_TYPE_UPGARDE GROUP BY PRM_One_Partner_Id__r.Name,PRM_Market_Type_Nm__c,PRM_Tier_Id__r.Name,PRM_Partner_Role_Nm__c];  
        for(AggregateResult ar:recomRecords){
            String opidName = (String)ar.get('opidname'); 
            String partnerRole = (String)ar.get('PRM_Partner_Role_Nm__c'); 
            String tier = (String)ar.get('tier');
            String marketType = (String)ar.get('PRM_Market_Type_Nm__c');
            Decimal totalSales = (Decimal)ar.get('totalSales');
           
            String key = opidName+SYM_SEMICOL+partnerRole+SYM_SEMICOL+tier+SYM_SEMICOL+marketType;
            if(!parentRecMapAndList.parentRecMap.containsKey(key)){
                PRM_Value_Exchange_Recommendation__c vxrecRecord = notGroupedQualFields.get(key);
                UpgradeRecommendationWrapper upgWrap = new UpgradeRecommendationWrapper();
                upgWrap.opidName = opidName;
                upgWrap.partnerRole = getPartnerRoleLabel(partnerRole);
                upgWrap.tier = tier;
                upgWrap.marketType = marketType;
                //upgWrap.trainingPointsCount = trainingPointsCount;
                if(strParentKeyandSumValfortrainingCreditsMap.containsKey(key)){
                    upgWrap.trainingPointsCount = strParentKeyandSumValfortrainingCreditsMap.get(key);
                }else{
                    upgWrap.trainingPointsCount = null;
                }
                upgWrap.totalSales = totalSales;
                if(strParentKeyandSumValforNoofEmpTrainingMap.containsKey(key)){
                    upgWrap.noOfEmpDoneTraining = strParentKeyandSumValforNoofEmpTrainingMap.get(key);
                }else{
                    upgWrap.noOfEmpDoneTraining = null;
                }
                //upgWrap.noOfEmpDoneTraining = noOfEmpDoneTraining; 
                if(strParentKeyandSumValforMPSolutionsMap.containsKey(key)){
                    upgWrap.noOfMPSolutions = strParentKeyandSumValforMPSolutionsMap.get(key);
                }else{
                    upgWrap.noOfMPSolutions = null;
                }
                //upgWrap.noOfMPSolutions = noOfMPSolutions;  
                if(strParentKeyandSumValforTotalNbrComp.containsKey(key)){
                    upgWrap.trainingCompetancy = strParentKeyandSumValforTotalNbrComp.get(key);
                }else{
                    upgWrap.trainingCompetancy = null;
                }
                //upgWrap.trainingCompetancy = trainingCompetancy;
                upgWrap.rank = vxrecRecord.PRM_Rank_Nbr__c;
                upgWrap.elegibilityTier = tierMap.get(vxrecRecord.PRM_Eligibility_Tier__c);
                upgWrap.recommType = vxrecRecord.PRM_Recommendation_Type_Nm__c;
                upgWrap.status = vxrecRecord.PRM_Recommendation_Status_Nm__c;
                upgWrap.key = opidName+SYM_SEMICOL+partnerRole+SYM_SEMICOL+tier+SYM_SEMICOL+marketType;
                upgWrap.id = vxrecRecord.PRM_One_Partner_Id__c;
                upgWrap.operation = System.Label.PRM_Icon_New;
                upgWrap.disableIcon = false;
                //upgWrap.salesGroup = '';
                upgWrap.notes = vxrecRecord.PRM_Notes__c;
                if(selectBenifitMap.containsKey(key) && selectBenifitMap.get(key) != null){
                    upgWrap.selectBenefit = selectBenifitMap.get(key);
                }else{
                    upgWrap.selectBenefit = SPECIALTY_NA;
                }
                if(specialtyPresentMap.containsKey(key)){
                    upgWrap.specialtyPresent = specialtyPresentMap.get(key);
                }/*else if(specialtyCriteriaNotPresentMap.containsKey(key)){
                    upgWrap.specialtyPresent = specialtyCriteriaNotPresentMap.get(key);
                }*/else{
                    upgWrap.specialtyPresent = SPECIALTY_NA;
                }
                upgWrap.submittedIntegReport = vxrecRecord.PRM_Submitted_Integration_Report_Ind__c;
                upgWrap.accountPlanInd = vxrecRecord.PRM_Account_Plan_Ind__c;
                If(vxrecRecord.PRM_Recommendation_Status_Nm__c == System.Label.PRM_VX_Status){
                    upgWrap.disableUpgBotton = true;
                } else{
                    upgWrap.disableUpgBotton = false;
                }
                //Adding all the aggregated fields and remaining fields to Map in the Wrapper
                parentRecMapAndList.parentRecMap.put(key,upgWrap);                   
            }
        }
        //Fetching all the values from Map and Adding it to List to display in the Datatable
        for(String s:parentRecMapAndList.parentRecMap.keySet()){
            parentRecMapAndList.parentRecList.add(parentRecMapAndList.parentRecMap.get(s));
        }
        return parentRecMapAndList;    
    }

    //Method to return child records of clicked Parent Record and all Parent Records
    @AuraEnabled
    public static List<UpgradeRecommendationWrapper> fetchChildRecords(String key){
        String opidName = '';
        String partnerRole = '';
        String tier = '';
        String marketType = '';
        Map<String,List<UpgradeRecommendationWrapper>> mapOfStrKeyandchildrec = new Map<String,List<UpgradeRecommendationWrapper>>();
        Map<String,UpgradeRecommendationWrapper> childRecKeySameValMap = new Map<String,UpgradeRecommendationWrapper>();
        List<UpgradeRecommendationWrapper> parentChildRecords = new List<UpgradeRecommendationWrapper>();
        Id upgRecTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
        String[] keySplit = key.split(SYM_SEMICOL);
        opidName = keySplit[0];
        partnerRole = keySplit[1];
        tier = keySplit[2];
        marketType = keySplit[3];
        Map<String,String> eligibilityTierMap = new Map<String,String>();
        for(ChannelProgramLevel cpl : [Select Id,Name from ChannelProgramLevel]){
            eligibilityTierMap.put(cpl.Id,cpl.Name);
        }
       
        List<PRM_Value_Exchange_Recommendation__c> childData = [SELECT PRM_One_Partner_Id__r.Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Tier_Id__r.Name ,PRM_Market_Type_Nm__c,PRM_Training_Credit_Points_Count_Nbr__c,
                               PRM_Sales_Amount_Nbr__c,PRM_No_Of_Employees_Done_Training_Nbr__c,PRM_Number_Of_MP_Solutions_Nbr__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Eligibility_Tier__c,PRM_Recommendation_Type_Nm__c,PRM_Recommendation_Status_Nm__c,
                               PRM_Select_Benefit_Txt__c,PRM_Specialty_Present_Nm__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Rank_Nbr__c,PRM_Notes__c,PRM_Submitted_Integration_Report_Ind__c,PRM_Account_Plan_Ind__c FROM PRM_Value_Exchange_Recommendation__c WHERE RecordTypeId =:upgRecTypeId and PRM_Recommendation_Status_Nm__c IN :VX_STATUS_NEW_INPROCESS and
                               PRM_One_Partner_Id__r.Name =:opidName and PRM_Partner_Role_Nm__c =:partnerRole and PRM_Tier_Id__r.Name =:tier and PRM_Market_Type_Nm__c =:marketType and PRM_Recommendation_Type_Nm__c = :VX_RECOMMENDATION_TYPE_UPGARDE];
        
       
                               
        for(PRM_Value_Exchange_Recommendation__c vx:childData){
            String childRecKey = vx.PRM_One_Partner_Id__r.Name+SYM_SEMICOL+vx.PRM_Account_Id__r.Name+SYM_SEMICOL+vx.PRM_Partner_Role_Nm__c+SYM_SEMICOL+vx.PRM_Tier_Id__r.Name+SYM_SEMICOL+vx.PRM_Market_Type_Nm__c;
            if(!childRecKeySameValMap.containsKey(childRecKey)){
                UpgradeRecommendationWrapper childRec = new UpgradeRecommendationWrapper();
                childRec.elegibilityTier = vx.PRM_Eligibility_Tier__c;
                childRec.recommType = vx.PRM_Recommendation_Type_Nm__c;
                childRec.status = vx.PRM_Recommendation_Status_Nm__c;
                childRec.rank = vx.PRM_Rank_Nbr__c;
                childRec.notes = vx.PRM_Notes__c;
                childRec.submittedIntegReport = vx.PRM_Submitted_Integration_Report_Ind__c;
                childRec.accountPlanInd = vx.PRM_Account_Plan_Ind__c;
                childRec.specialtyPresent = vx.PRM_Specialty_Present_Nm__c;
                childRec.selectBenefit = vx.PRM_Select_Benefit_Txt__c;
                childRec.id = vx.PRM_Account_Id__c;
                //Add not grouped qualitative fields to a map
                childRecKeySameValMap.put(childRecKey,childRec);
            }             
        }
        List<AggregateResult> aggrChildRecs =[Select PRM_One_Partner_Id__r.Name opidName,PRM_Account_Id__r.Name accName, PRM_Partner_Role_Nm__c, PRM_Tier_Id__r.Name tier, PRM_Market_Type_Nm__c, SUM(PRM_Sales_Amount_Nbr__c)salesAmount,MIN(PRM_Total_Achieved_Competency_Nbr__c)totalAcheivedComp,MIN(PRM_Training_Credit_Points_Count_Nbr__c)trainingCredits,MIN(PRM_No_Of_Employees_Done_Training_Nbr__c)empDoneTrainig,MIN(PRM_Number_Of_MP_Solutions_Nbr__c)mpSolCount from PRM_Value_Exchange_Recommendation__c where 
                                                RecordTypeId =:upgRecTypeId and PRM_Recommendation_Status_Nm__c IN :VX_STATUS_NEW_INPROCESS and PRM_One_Partner_Id__r.Name =:opidName and PRM_Partner_Role_Nm__c =:partnerRole and PRM_Tier_Id__r.Name =:tier and PRM_Market_Type_Nm__c =:marketType and PRM_Recommendation_Type_Nm__c = :VX_RECOMMENDATION_TYPE_UPGARDE
                                                GROUP BY PRM_One_Partner_Id__r.Name,PRM_Account_Id__r.Name, PRM_Partner_Role_Nm__c, PRM_Tier_Id__r.Name, PRM_Market_Type_Nm__c]; 
        
        if(aggrChildRecs != null && !aggrChildRecs.isEmpty()){
            for(AggregateResult agr:aggrChildRecs){
                String agrKey = (String)agr.get('opidName')+SYM_SEMICOL+(String)agr.get('accName')+SYM_SEMICOL+(String)agr.get('PRM_Partner_Role_Nm__c')+SYM_SEMICOL+(String)agr.get('tier')+SYM_SEMICOL+(String)agr.get('PRM_Market_Type_Nm__c');
            
                UpgradeRecommendationWrapper existingUpgRec = childRecKeySameValMap.get(agrKey);
            
                UpgradeRecommendationWrapper childRecWrap = new UpgradeRecommendationWrapper();
                childRecWrap.opidName = (String)agr.get('accName');
                childRecWrap.partnerRole = getPartnerRoleLabel((String)agr.get('PRM_Partner_Role_Nm__c'));
                childRecWrap.tier = (String)agr.get('tier');
                childRecWrap.marketType = (String)agr.get('PRM_Market_Type_Nm__c');
                childRecWrap.totalSales = (Decimal)agr.get('salesAmount');
                childRecWrap.trainingCompetancy = (Decimal)agr.get('totalAcheivedComp');
                childRecWrap.trainingPointsCount = (Decimal)agr.get('trainingCredits');
                childRecWrap.noOfEmpDoneTraining = (Decimal)agr.get('empDoneTrainig');
                childRecWrap.noOfMPSolutions = (Decimal)agr.get('mpSolCount');
                childRecWrap.elegibilityTier = eligibilityTierMap.get(existingUpgRec.elegibilityTier);
                childRecWrap.rank = existingUpgRec.rank;
                childRecWrap.recommType = existingUpgRec.recommType;
                childRecWrap.status = existingUpgRec.status;
                childRecWrap.id = existingUpgRec.id;
                childRecWrap.operation = System.Label.PRM_Icon_chevronright;
                childRecWrap.disableIcon = true;
                childRecWrap.selectBenefit = existingUpgRec.selectBenefit;
                childRecWrap.specialtyPresent = existingUpgRec.specialtyPresent;
                childRecWrap.notes = existingUpgRec.notes;
                childRecWrap.key =(String)agr.get('accName')+SYM_SEMICOL+(String)agr.get('PRM_Partner_Role_Nm__c')+SYM_SEMICOL+(String)agr.get('tier')+SYM_SEMICOL+(String)agr.get('PRM_Market_Type_Nm__c')+SYM_SEMICOL+SPECIALTY_NA;
                childRecWrap.submittedIntegReport = existingUpgRec.submittedIntegReport;
                childRecWrap.accountPlanInd = existingUpgRec.accountPlanInd;
                childRecWrap.disableUpgBotton = true;

                String childRecAggKey = (String)agr.get('opidName')+SYM_SEMICOL+(String)agr.get('PRM_Partner_Role_Nm__c')+SYM_SEMICOL+(String)agr.get('tier')+SYM_SEMICOL+(String)agr.get('PRM_Market_Type_Nm__c');
                if(mapOfStrKeyandchildrec.containsKey(childRecAggKey)){
                    List<UpgradeRecommendationWrapper> lstOfChildRec = mapOfStrKeyandchildrec.get(childRecAggKey);
                    lstOfChildRec.add(childRecWrap);
                    mapOfStrKeyandchildrec.put(childRecAggKey, lstOfChildRec);
                }else {
                        //Map to store all child Records
                    mapOfStrKeyandchildrec.put(childRecAggKey,new List<UpgradeRecommendationWrapper> {childRecWrap});
                }
            }
        }
       
        //String key = opidName+partnerRole+tier+marketType;
        //Fetching all the Parent Records from the Final Wrapper      
        Map<String,UpgradeRecommendationWrapper> mapOfStrKeyAndParentrec = getUpgRecList().parentRecMap;
        //String parentrecKey = '';
        //To display child Records for clicked Parent Record and all Parent Records
        if(mapOfStrKeyAndParentrec != null && !mapOfStrKeyAndParentrec.isEmpty()){
            for(UpgradeRecommendationWrapper parentrec : mapOfStrKeyAndParentrec.values()){         
                //if(mapOfStrKeyandchildrec != null && !mapOfStrKeyandchildrec.isEmpty()){
                    for(String childkey : mapOfStrKeyandchildrec.keySet()){                        
                        //parentrecKey = parentrec.opidName+parentrec.partnerRole+parentrec.tier+parentrec.marketType;    
                        if(parentrec.key == childkey){                                 
                            parentrec.operation = System.Label.PRM_Icon_Dash;                                                                
                            parentChildRecords.add(parentrec);
                            List<UpgradeRecommendationWrapper> childrecs = mapOfStrKeyandchildrec.get(childkey);
                            parentChildRecords.addAll(childrecs);
                        }else{
                            parentChildRecords.add(parentrec);
                        }    
                    }
                //}
            }                
        }   
        return parentChildRecords;
    }
    //Method to calculate Summurized value of all the child Accounts
    public static Map<String,Decimal> calculateSumVal(Map<String,Map<String,Decimal>> strParentKeyandUniqAccs){
        Map<String,Decimal>  calculatedSumValue= new Map<String,Decimal>();
        for(String key:strParentKeyandUniqAccs.keySet()){
            Decimal initialValue = 0;
            Map<String,Decimal> allUniqAccs = strParentKeyandUniqAccs.get(key);
            for(String acckey:allUniqAccs.keySet()){
                initialValue = initialValue + allUniqAccs.get(acckey);
            }
            calculatedSumValue.put(Key,initialValue);
        }
        return calculatedSumValue;
    }
    //Method to Update Notes, Submitted Integration Report and Account Plan Indicator fields when Inline Edit happens
    @AuraEnabled
    public static Boolean updateRecords(List<object> draftValues){ 
        List<String> opidNamesList = new List<String>();
        List<String> partnerRolesList = new List<String>();
        List<String> tiersList = new List<String>();
        List<String> marketTypesList = new List<String>();
        Integer successCount = 0;
        Integer failureCount = 0;
        Id upgRecTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
        Map<String,UpgradeRecommendationWrapper> stringKeyandToUpdateFieldValuesMap = new Map<String,UpgradeRecommendationWrapper>();
        List<UpgradeRecommendationWrapper> toUpdateList = (List<UpgradeRecommendationWrapper>)JSON.deserialize(JSON.serialize(draftValues), List<UpgradeRecommendationWrapper>.class);
        
        for(UpgradeRecommendationWrapper upgwrap:toUpdateList){
            String[] key = upgwrap.key.split(SYM_SEMICOL);
            if(!opidNamesList.contains(key[0])){
                opidNamesList.add(key[0]);
            }
            if(!partnerRolesList.contains(key[1])){
                partnerRolesList.add(key[1]);
            }
            if(!tiersList.contains(key[2])){
                tiersList.add(key[2]);
            }
            if(!marketTypesList.contains(key[3])){
                marketTypesList.add(key[3]);
            }
            stringKeyandToUpdateFieldValuesMap.put(upgwrap.key,upgwrap);
        }
        
        List<PRM_Value_Exchange_Recommendation__c> vxRecList = [Select Id,PRM_One_Partner_Id__r.Name,PRM_Account_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Tier_Id__r.Name,PRM_Market_Type_Nm__c,PRM_Notes__c,PRM_Submitted_Integration_Report_Ind__c,PRM_Account_Plan_Ind__c
                                                                    FROM PRM_Value_Exchange_Recommendation__c WHERE RecordTypeId = :upgRecTypeId and PRM_Recommendation_Type_Nm__c = :VX_RECOMMENDATION_TYPE_UPGARDE and PRM_Recommendation_Status_Nm__c IN :VX_STATUS_NEW_INPROCESS and 
                                                                    PRM_One_Partner_Id__r.Name IN :opidNamesList and PRM_Partner_Role_Nm__c IN :partnerRolesList and PRM_Tier_Id__r.Name In :tiersList and PRM_Market_Type_Nm__c IN :marketTypesList];
        if(vxRecList != null && !vxRecList.isEmpty()){
            for(PRM_Value_Exchange_Recommendation__c ver:vxRecList){
                String key = ver.PRM_One_Partner_Id__r.Name+SYM_SEMICOL+ver.PRM_Partner_Role_Nm__c+SYM_SEMICOL+ver.PRM_Tier_Id__r.Name+SYM_SEMICOL+ver.PRM_Market_Type_Nm__c;
                if((stringKeyandToUpdateFieldValuesMap.containsKey(key)) && (stringKeyandToUpdateFieldValuesMap.get(key).notes != null)){
                    ver.PRM_Notes__c = stringKeyandToUpdateFieldValuesMap.get(key).notes;
                }
                if((stringKeyandToUpdateFieldValuesMap.containsKey(key)) && (stringKeyandToUpdateFieldValuesMap.get(key).submittedIntegReport != null)){
                    ver.PRM_Submitted_Integration_Report_Ind__c = stringKeyandToUpdateFieldValuesMap.get(key).submittedIntegReport;
                }
                if((stringKeyandToUpdateFieldValuesMap.containsKey(key)) && (stringKeyandToUpdateFieldValuesMap.get(key).accountPlanInd != null)){
                    ver.PRM_Account_Plan_Ind__c = stringKeyandToUpdateFieldValuesMap.get(key).accountPlanInd;
                }
                if(!stringKeyandToUpdateFieldValuesMap.containsKey(key)){
                    
                }
            }
        }
        Database.SaveResult[] result = Database.update(vxRecList,false);
        for(Database.SaveResult sr:result){
      
            if(sr.isSuccess()){
                
                successCount++;
            }else{
                Database.Error[] errors =sr.getErrors();
                for(Database.Error er :errors){
                   
                    failureCount++;
                }
            }
        }
        if((failureCount <= 0) && (successCount > 0)){
            return true;
        }else{
            return false;
        }
    }

    //Method to Update the Status to In Process when Upgrade button is clicked on the UI
    @AuraEnabled
    public static Boolean updateStatus(String key){
        String opidName = '';
        String partnerRole = '';
        String tier = '';
        String marketType = '';
        Integer successRecCount = 0;
        Integer failureRecCount = 0;
        Id upgRecTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
        String[] splitKey = key.split(SYM_SEMICOL);
        opidName = splitKey[0];
        partnerRole = splitKey[1];
        tier = splitKey[2];
        marketType = splitKey[3];

        List<PRM_Value_Exchange_Recommendation__c> toUpdateRecords = [SELECT Id,PRM_One_Partner_Id__r.Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Tier_Id__r.Name ,PRM_Market_Type_Nm__c,
                               PRM_Recommendation_Status_Nm__c FROM PRM_Value_Exchange_Recommendation__c WHERE RecordTypeId =:upgRecTypeId and PRM_Recommendation_Status_Nm__c = :System.Label.PRM_Status_New and PRM_Recommendation_Type_Nm__c = :VX_RECOMMENDATION_TYPE_UPGARDE
                               and PRM_One_Partner_Id__r.Name =:opidName and PRM_Partner_Role_Nm__c =:partnerRole and PRM_Tier_Id__r.Name =:tier and PRM_Market_Type_Nm__c =:marketType];
        
       
        if(toUpdateRecords != null && !toUpdateRecords.isEmpty()){
            for(PRM_Value_Exchange_Recommendation__c ver:toUpdateRecords){
                String curKey = ver.PRM_One_Partner_Id__r.Name+SYM_SEMICOL+ver.PRM_Partner_Role_Nm__c+SYM_SEMICOL+ver.PRM_Tier_Id__r.Name+SYM_SEMICOL+ver.PRM_Market_Type_Nm__c;
                if(curKey != null && curKey == key){
                    ver.PRM_Recommendation_Status_Nm__c = System.Label.PRM_VX_Status; 
                }
            }
        }

        Database.SaveResult[] result = Database.update(toUpdateRecords,false);
        for(Database.SaveResult sr:result){
            if(sr.isSuccess()){
               
                successRecCount++;
            }else{
                Database.Error[] errors =sr.getErrors();
                for(Database.Error er :errors){
                    
                    failureRecCount++;
                }
            }
        }
        if((failureRecCount <= 0) && (successRecCount > 0)){
            return true;
        }else{
            return false;
        }
        
    }
    //Method to fetch the PartnerRole Picklist field label(To display picklist value in UI instead of API Name)
    @AuraEnabled
    public static string getPartnerRoleLabel(String partnerRoleValue){
        String partnerRoleLabel = '';
        for (Schema.PicklistEntry f : picklistVal) {
            if(partnerRoleValue == f.getValue()){
                partnerRoleLabel = f.getLabel();
            }
        }
        return partnerRoleLabel;
    }

    public with sharing class UpgradeRecommendationWrapper {
        @AuraEnabled public String opidName {set;get;}
        @AuraEnabled public String accName {set;get;}
        @AuraEnabled public String partnerRole {set;get;}
        @AuraEnabled public String tier {set;get;}
        @AuraEnabled public String marketType {set;get;}
        @AuraEnabled public Decimal trainingPointsCount {set;get;}
        @AuraEnabled public Decimal totalSales {set;get;}
        @AuraEnabled public Decimal noOfEmpDoneTraining {set;get;}
        @AuraEnabled public Decimal noOfMPSolutions {set;get;}
        @AuraEnabled public Decimal trainingCompetancy {set;get;}
        @AuraEnabled public Decimal rank {set;get;}
        @AuraEnabled public String elegibilityTier {set;get;}
        @AuraEnabled public String recommType {set;get;}
        @AuraEnabled public String status {set;get;}
        @AuraEnabled public Id id {set;get;}
        @AuraEnabled public String key {set;get;}
        @AuraEnabled public String operation {set;get;}  
        @AuraEnabled public Boolean disableIcon {set;get;}
        @AuraEnabled public String specialtyPresent {set;get;}
        @AuraEnabled public String selectBenefit {set;get;}
        //@AuraEnabled public String salesGroup   {set;get;}
        @AuraEnabled public String notes    {set;get;}
        @AuraEnabled public Boolean accountPlanInd  {set;get;}
        @AuraEnabled public Boolean submittedIntegReport  {set;get;}
        @AuraEnabled public Boolean disableUpgBotton    {set;get;}
    }
    
    public with sharing class FinalWrapper{
        @AuraEnabled public Map<String,UpgradeRecommendationWrapper> parentRecMap {set;get;}
        @AuraEnabled public List<UpgradeRecommendationWrapper> parentRecList {set;get;}

        public FinalWrapper(){
            parentRecMap = new Map<String,UpgradeRecommendationWrapper>();
            parentRecList = new List<UpgradeRecommendationWrapper>();
        }
    }
}