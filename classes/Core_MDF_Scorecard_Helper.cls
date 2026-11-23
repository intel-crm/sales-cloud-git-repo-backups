public without sharing class Core_MDF_Scorecard_Helper {
    @AuraEnabled
    public static ScorecardDetailsWrapper getScoreCardDetailsAndAccess(id caseRecord){
        ScorecardDetailsWrapper scorecardDetail = new ScorecardDetailsWrapper();
	if(caseRecord == null) return scorecardDetail;
        try{
            	List<Core_MDF_Scorecard__c> scorecards = [select id, Core_MDF_Case_Id__r.Core_MDF_Status__c,Core_MDF_Case_Id__r.CreatedDate,Core_MDF_AI_Processing_Status_Nm__c,Core_MDF_AI_Comments_Txt__c,Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__r.Core_MDF_OutcomeBased_Ind__c,Core_MDF_Case_Id__r.Core_MDF_Audit_Reversal_Count_Nbr__c from Core_MDF_Scorecard__c where Core_MDF_Case_Id__c =:caseRecord LIMIT 1];
                if(scorecards.isEmpty()) return scorecardDetail;
                Core_MDF_Scorecard__c scRec = scorecards[0];
                
                Boolean statusFlag = scRec.Core_MDF_Case_Id__r.Core_MDF_Status__c == 'Under Review'? true:false;
                Boolean editAccess = FeatureManagement.checkPermission('Core_MDF_ClaimCaseReviewer')? true:false;
            	Date aiEnableDate = Date.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Enable_Date')?.Core_MDF_Value_Txt__c);//WW16.4 date
            	Boolean isOutcomebasedClaim = scRec.Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__r.Core_MDF_OutcomeBased_Ind__c;
                scorecardDetail.editability = statusFlag && editAccess;
                scorecardDetail.scorecardRec = scRec;
            
                if(statusFlag && scRec.Core_MDF_Case_Id__r.CreatedDate >= aiEnableDate && !isOutcomebasedClaim && editAccess){
                    scorecardDetail.showAIMessage = true;
                }
                if(statusFlag && scRec.Core_MDF_AI_Processing_Status_Nm__c == 'AI Processing Completed' && !isOutcomebasedClaim && scRec.Core_MDF_Case_Id__r.CreatedDate >= aiEnableDate){
                    scorecardDetail.showAIChecklistItemFields = true;
                }
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return scorecardDetail;        
    }
public class ScorecardDetailsWrapper {
    
    @AuraEnabled
    public Boolean editability { get; set; }
    
    @AuraEnabled
    public Core_MDF_Scorecard__c scorecardRec { get; set; }
    
    @AuraEnabled
    public Boolean showAIMessage { get; set; }
    
    @AuraEnabled
    public Boolean showAIChecklistItemFields { get; set; }
    
}   
}