/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SurveyCategoryResultTrigger_Utility {
    
    /*public static void calculateCategoryScore(List<ArdiraSurvey__Survey_Category_Result__c> catResultList){
        List<ArdiraSurvey__Survey_Category_Result__c> surveyCatResultList = [Select id,Name,ArdiraSurvey__Survey_Result__c,ArdiraSurvey__Survey_Result__r.PSS_AIIP_Score__c,
                                                                             ArdiraSurvey__Survey_Result__r.PSS_MRS_Score__c,
                                                                             ArdiraSurvey__Survey_Result__r.PSS_RRK_Score__c,
                                                                             ArdiraSurvey__Survey_Result__r.PSS_Fail_Fast_Status_Nm__c,
                                                                             ArdiraSurvey__Survey_Result__r.PSS_Programs_Applicable_Nm__c,
                                                                             ArdiraSurvey__Category__r.name,ArdiraSurvey__Category__r.PSS_Category_Threshold_Value__c,
                                                                             ArdiraSurvey__Survey_Result__r.PSS_Partner_Solution_Lifecycle_Status_Nm__c,ArdiraSurvey__Survey_Result__r.PSS_Solution_Category_Nm__c,
                                                                             ArdiraSurvey__Score_Raw__c
                                                                             FROM ArdiraSurvey__Survey_Category_Result__c
                                                                             Where id in : catResultList];
        
        map<id, ArdiraSurvey__Survey_Result__c> surveyResultMap= new map<id, ArdiraSurvey__Survey_Result__c>();
        
        for(ArdiraSurvey__Survey_Category_Result__c catResult: surveyCatResultList){
            ArdiraSurvey__Survey_Result__c res;
            if(surveyResultMap.containsKey(catResult.ArdiraSurvey__Survey_Result__c)){
                res= surveyResultMap.get(catResult.ArdiraSurvey__Survey_Result__c);
            }else{
                res= new ArdiraSurvey__Survey_Result__c(id=catResult.ArdiraSurvey__Survey_Result__c);
            }
            if(catResult.ArdiraSurvey__Score_Raw__c >=catResult.ArdiraSurvey__Category__r.PSS_Category_Threshold_Value__c ){
                res.PSS_Programs_Applicable_Nm__c = (res.PSS_Programs_Applicable_Nm__c == NULL)?catResult.ArdiraSurvey__Category__r.Name:res.PSS_Programs_Applicable_Nm__c +catResult.ArdiraSurvey__Category__r.Name+';';
                surveyResultMap.put(catResult.ArdiraSurvey__Survey_Result__c,res);
            }
            
        }
        
        for(Id resultId : surveyResultMap.keySet()){
            ArdiraSurvey__Survey_Result__c res= surveyResultMap.get(resultId);

            if(res.PSS_Programs_Applicable_Nm__c!=NULL){
                if(res.PSS_Programs_Applicable_Nm__c.contains('MRS') || res.PSS_Programs_Applicable_Nm__c.contains('RRK')){
                    res.PSS_Solution_Category_Nm__c ='IOTG';
                }else{
                    res.PSS_Solution_Category_Nm__c ='DCG';
                }
                res.PSS_Fail_Fast_Status_Nm__c  = 'Pass';
            }else{
                res.PSS_Fail_Fast_Status_Nm__c = 'Fail'; 
            }
            surveyResultMap.put(resultId,res);
        }
        
        update surveyResultMap.values();
    }*/
    
}