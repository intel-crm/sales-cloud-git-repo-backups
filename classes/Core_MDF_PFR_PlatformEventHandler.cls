/*****************************************************************************************************
Class        :   Core_MDF_PFR_PlatformEventHandler
Description  :   Class to handle Activity PlatformEvent
Developed By :   Weezer - Shiva
*****************************************************************************************************/
public without sharing class Core_MDF_PFR_PlatformEventHandler {
    
    Public static Integer BATCH_SCOPE = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BulkUpdate_BatchSize'));
    Public static List<string> pfcStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EscClaim_Cancel_or_ReSubClosed').split(';');
    public static string LATECLAIM_TYPE = Core_MDF_CCP_ConstantClass.LATECLAIM_TYPE;
    
    //Method to update escalation status to cancelled once associated late claim is cancelled or Expired if associated claim goes into resubmission window closed
    public static void updateEscalationStatus(set<Id> escalationIds){
        List<Core_MDF_Escalation__c> escalationList = new List<Core_MDF_Escalation__c>();
        Set<Id> escalationIdSet = new Set<Id>();
        string ESC_CANCELLED_STATUS = Core_MDF_CCP_ConstantClass.CANCELLED_STATUS;
        string ESC_EXPIRED_STATUS = Core_MDF_CCP_ConstantClass.ESC_EXPIRED_STATUS;
        
        string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
        string systemCancelText = '\n' + 'Note: ' + System.now().date().format() + ' ' + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_with_Cancel_Claims');
        string systemCloseText = '\n' + 'Note: ' + System.now().date().format() + ' ' + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Esc_With_ResubClosed_Claims');
        
        for(Core_MDF_Escalation__c esc : [SELECT Id, Core_MDF_Escalation_Status_nm__c, Core_MDF_Issue_Description_txt__c,Core_MDF_Claim_Number_id__r.Core_MDF_Status__c,
                                          (select id,Core_MDF_Status__c from Partner_Fund_Claims__r where Core_MDF_Status__c NOT IN: pfcStatus)
                                          FROM Core_MDF_Escalation__c 
                                          Where Core_MDF_Claim_Number_id__c != Null 
                                          AND Core_MDF_Escalation_Type_nm__c =: LATECLAIM_TYPE
                                          AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                          AND ID IN: escalationIds]){
                                              
                                              if(esc.Partner_Fund_Claims__r == NULL || (esc.Partner_Fund_Claims__r != NULL && esc.Partner_Fund_Claims__r.isEmpty())){//add comment
                                                  Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                                                  escObj.Id = esc.Id;    	
                                                  
                                                  if(esc.Core_MDF_Claim_Number_id__r.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Cancelled){
                                                      escObj.Core_MDF_Issue_Description_txt__c = esc.Core_MDF_Issue_Description_txt__c != null ? 
                                                          esc.Core_MDF_Issue_Description_txt__c + systemCancelText:
                                                      systemCancelText;
                                                      escObj.Core_MDF_Escalation_Status_nm__c = ESC_CANCELLED_STATUS;
                                                      
                                                  }else{
                                                      escObj.Core_MDF_Issue_Description_txt__c = esc.Core_MDF_Issue_Description_txt__c != null ?
                                                          esc.Core_MDF_Issue_Description_txt__c + systemCloseText:
                                                      systemCloseText;
                                                      escObj.Core_MDF_Escalation_Status_nm__c = ESC_EXPIRED_STATUS;
                                                  }
                                                  escalationList.add(escObj);
                                              }
                                          }
        
        if(!escalationList.isEmpty()){
            Database.executeBatch(new Core_MDF_BulkUpdate_Batch(escalationList), BATCH_SCOPE);
        }  
        
    }    
    
    //Method to update amount on activity once claim is cancelled or claim goes to resubmission window closed
    public static void updateActivityAmount(set<Id> pfrIds){
        string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM; 
        string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
        Map<Id, Decimal> pfrToClaimAmtMap = new Map<Id,Decimal>();
        Map<Id, Decimal> pfrToEscalationAmtMap = new Map<Id, Decimal>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<string> pfcCloseStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
        
        for(AggregateResult pfc : [SELECT RequestId Id ,sum(Amount)amt
                                   FROM PartnerFundClaim 
                                   WHERE RequestId IN: pfrIds AND Core_MDF_Status__c IN:pfcCloseStatus  
                                   AND Core_MDF_Type_Txt__c =: TYPE_CLAIM 
                                   AND Core_MDF_Escalation_Id__c = null 
                                   GROUP BY RequestId]){ 
                                       ID pfrID =(Id)pfc.get('Id');Decimal pfrClaimedAmount =(Decimal)pfc.get('amt'); pfrToClaimAmtMap.put(pfrID,pfrClaimedAmount);
                                   }
        
        for(Core_MDF_Escalation__c esc : [SELECT Id,Core_MDF_Co_Marketing_Activity_id__c,Core_MDF_Claim_Number_id__c,Core_MDF_Approved_Amount_amt__c,
                                          (select id,Core_MDF_Status__c from Partner_Fund_Claims__r where Core_MDF_Status__c NOT IN: pfcStatus)
                                          FROM Core_MDF_Escalation__c 
                                          Where Core_MDF_Escalation_Type_nm__c =: LATECLAIM_TYPE
                                          AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                          AND Core_MDF_Co_Marketing_Activity_id__c IN: pfrIds]){
                                              
                                              
                                              if(!esc.Partner_Fund_Claims__r.isEmpty() || esc.Core_MDF_Claim_Number_id__c == NULL)
                                              { 
                                                  if(pfrToEscalationAmtMap.containskey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                                                      Decimal pfrEscAmount = esc.Core_MDF_Approved_Amount_amt__c + pfrToEscalationAmtMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                                                      pfrToEscalationAmtMap.put(esc.Core_MDF_Co_Marketing_Activity_id__c,pfrEscAmount);
                                                  }else{
                                                      pfrToEscalationAmtMap.put(esc.Core_MDF_Co_Marketing_Activity_id__c,esc.Core_MDF_Approved_Amount_amt__c);
                                                  }
                                                      
                                              }
                                              
                                          }
        
        /*for(AggregateResult esc : [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum()amt
                                   FROM Core_MDF_Escalation__c
                                   WHERE Core_MDF_Co_Marketing_Activity_id__c IN: pfrIds 
                                   AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                   AND (Core_MDF_Claim_Number_id__c = NULL OR Core_MDF_Claim_Number_id__r.Core_MDF_Status__c NOT IN: pfcStatus)
                                   GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){
                                       ID pfrID =(Id)esc.get('Id');
                                       Decimal pfrEscAmount =(Decimal)esc.get('amt');
                                       pfrToEscalationAmtMap.put(pfrID,pfrEscAmount); 
                                   }*/
        
        for(PartnerFundRequest pfr : [SELECT Id, Amount, Core_MDF_Activity_Reimbursement_Amt_nbr__c
                                      FROM PartnerFundRequest
                                      WHERE Id IN: pfrIds]){
                                          PartnerFundRequest pfrObj = new PartnerFundRequest();
                                          pfrObj.Id = pfr.Id;                               
                                          Decimal totalEscAmt = pfrToEscalationAmtMap.containskey(pfr.Id) ? 
                                              pfrToEscalationAmtMap.get(pfr.Id) : 0;
                                          Decimal totalClaimedAmt = pfrToClaimAmtMap.containskey(pfr.Id) ? 
                                              pfrToClaimAmtMap.get(pfr.Id) : 0;
                                                                      
                                          pfrObj.Amount = (totalEscAmt + totalClaimedAmt) > pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c ?
                                              pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c:
                                          totalEscAmt + totalClaimedAmt;
                                          
                                          pfrList.add(pfrObj);
                                                                           
                                      }
        
        if(!pfrList.isEmpty()){
            Database.executeBatch(new Core_MDF_BulkUpdate_Batch(pfrList), BATCH_SCOPE);
        }
    }
}