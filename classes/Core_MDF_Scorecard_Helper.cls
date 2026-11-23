public without sharing class Core_MDF_Scorecard_Helper {
    @AuraEnabled
    public static Map<id,boolean> getScoreCardDetailsAndAccess(id caseRecord){
        Boolean statusFlag=false; 
        id scoreCardid;
        Map<id,boolean> result = new Map<id,boolean>();
        List<Core_MDF_Scorecard__c> scList = new List<Core_MDF_Scorecard__c>();
        try{
            for(Core_MDF_Scorecard__c sc: [select id, Core_MDF_Case_Id__r.Core_MDF_Status__c from Core_MDF_Scorecard__c where Core_MDF_Case_Id__c =:caseRecord]){
                scoreCardid = sc.id;
                statusFlag = sc.Core_MDF_Case_Id__r.Core_MDF_Status__c == 'Under Review'? true:false;
                Boolean editAccess = FeatureManagement.checkPermission('Core_MDF_ClaimCaseReviewer')? true:false;
                Boolean editability = statusFlag && editAccess;
                result.put(scoreCardid,editability);
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return result;        
    }
}