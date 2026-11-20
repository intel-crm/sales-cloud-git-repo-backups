public without sharing class Core_MDF_Scorecard_ServiceHandler {
    public static void clearOutValues(List<Core_MDF_Scorecard__c> scoreCardRecords, Map<id,Core_MDF_Scorecard__c> oldMap) {
        List<Case> updateRecordList = new List<Case>();
        Map<decimal,decimal> scoreToRecovery = new Map<decimal,decimal>();
        Set<id> caseIds = new Set<id>();
        Map<id,decimal> caseToScore = new Map<id,decimal>();
        Map<id,decimal> caseToRecovery = new Map<id,decimal>();
        try{
            for(Core_MDF_Scorecard__c sc: scoreCardRecords){
                if(sc.Core_MDF_Attribution_Nbr__c != oldMap.get(sc.id).Core_MDF_Attribution_Nbr__c || sc.Core_MDF_Engagement_Nbr__c != oldMap.get(sc.id).Core_MDF_Engagement_Nbr__c || sc.Core_MDF_POP__c != oldMap.get(sc.id).Core_MDF_POP__c ||sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c!=oldMap.get(sc.id).Core_MDF_Manual_Recovery_Amount_USD_Amt__c){ 
                    sc.Core_MDF_Attribution_PV_Ind__c = sc.Core_MDF_Attribution_Nbr__c != '1'? '': sc.Core_MDF_Attribution_PV_Ind__c;
                    sc.Core_MDF_Engagement_PV_Ind__c = sc.Core_MDF_Engagement_Nbr__c != '1'? '': sc.Core_MDF_Engagement_PV_Ind__c;
                    sc.Core_MDF_POP_PV_Ind__c = sc.Core_MDF_POP__c != '1'? '': sc.Core_MDF_POP_PV_Ind__c; 
                    caseIds.add(sc.Core_MDF_Case_Id__c);
                    caseToScore.put(sc.Core_MDF_Case_Id__c,sc.Core_MDF_Score_Nbr__c);
                    caseToRecovery.put(sc.Core_MDF_Case_Id__c,sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
                }   
            }  
            if(caseIds.size() > 0){
                scoreToRecovery = queryRecoveryScores();
                for(Case caseRecord:[select id,Core_MDF_Requested_Amount_USD_Amt__c,Core_MDF_Excess_Requested_Amt__c from Case where id in :caseIds ]){
                    caseRecord.Core_MDF_Scorecard_Score_Nbr__c = caseToScore.get(caseRecord.id);
                    //NP Fix - WW42
                    decimal excessAmount = caseRecord.Core_MDF_Excess_Requested_Amt__c == null? 0 : caseRecord.Core_MDF_Excess_Requested_Amt__c;
                    caseRecord.Core_MDF_Right_to_Recover_Amt__c = (caseRecord.Core_MDF_Requested_Amount_USD_Amt__c-excessAmount)* (scoreToRecovery.get(caseToScore.get(caseRecord.id))/100);
                    caseRecord.Core_MDF_Manual_Recovery_Amount_USD_Amt__c = caseToRecovery.get(caseRecord.id);
                    /*Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                    evtObj.Core_MDF_JSON_Data__c = JSON.serialize(caseRecord); 
                    evtObj.Core_MDF_Object_Name__c = 'Case';*/
                    updateRecordList.add(caseRecord); 
                }
            }
            if(updateRecordList.size()>0){
                //List<Database.SaveResult> results = EventBus.publish(updateRecordList);
                //TWC742-357 - Auto refresh of scorecard is not refreshing the RTR amount
                Database.SaveResult[] srList = Database.update(updateRecordList, false);
                
                
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
    } 
    
    public static Map<decimal,decimal> queryRecoveryScores(){
        Map<decimal,decimal> scoreToRecovery = new Map<decimal,decimal>();
        try{        
            String recoveryScoresJson = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RecoveryPercentagesJson');
	     Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(recoveryScoresJson);
             for(String key:jsonMap.keySet()){
                 Decimal k = Decimal.valueOf(key);
                 Decimal v = (Decimal)jsonMap.get(key);
                 scoreToRecovery.put(k,v);
             }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return scoreToRecovery;   
    }
    
    public static void refreshPage(List<Core_MDF_Scorecard__c> scoreCardRecords, Map<id,Core_MDF_Scorecard__c> oldMap){ 
        List<Core_MDF_Listener_PE__e> updateRecordList=new List<Core_MDF_Listener_PE__e>();
        try{
            for(Core_MDF_Scorecard__c sc: scoreCardRecords){
                if(sc != oldMap.get(sc.id)){
                    Core_MDF_Listener_PE__e evtObj = new Core_MDF_Listener_PE__e(); 
                    evtObj.Core_MDF_Updated_Ind__c = true; 
                    evtObj.Core_MDF_Object_ID__c = sc.Core_MDF_Case_Id__c;                        
                    updateRecordList.add(evtObj);   
                }
            }
            List<Database.SaveResult> results = EventBus.publish(updateRecordList);
           
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
    }
   
}