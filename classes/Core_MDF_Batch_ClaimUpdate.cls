global without sharing class Core_MDF_Batch_ClaimUpdate implements Database.Batchable<sObject>, Database.Stateful
 {
     //NZ
    Set<Id> updateClaimIdSet = new Set<Id>{};
	global List<PartnerFundClaim> claimListTobeUpdated = new List<PartnerFundClaim>();
    global String queryActive;
    global String errorMessage = '';
    global Set<Id> pfcIdSet = new Set<Id>();
   
    //global List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
    //Making sure the batch always picks up record whose minimum time gap is 15 min.
    //In case the time from the label is > 15 min then also add 15 mins.
  
  
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        
         string qryStr = '';
       	 qryStr = 'SELECT Id, Title, Core_MDF_Region_Cd__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c,'+
                    ' Core_MDF_Activity_Types__c, Core_MDF_Program__c, Core_MDF_Status__c, RequestId, Request.CreatedDate,'+
                    ' Core_MDF_Claim_Review_Case__c, Core_MDF_Claim_Review_Case__r.CaseNumber, budget.Amount, Amount,'+
                    ' ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c'+
                    ' FROM PartnerFundClaim'+
                    ' WHERE Id IN :pfcIdSet';
        return Database.getQueryLocator(qryStr);
    }
       
    global void execute(Database.BatchableContext batchableContext,List<PartnerFundClaim> pfcList)
    { 
   
    try{
       
        
        //System.debug('NZ-->updateClaimIdSet: '+updateClaimIdSet);
        
             //NZ
          for(PartnerFundClaim claim : pfcList){
                                            
              PartnerFundClaim pfc = new PartnerFundClaim();
              pfc.Id = claim.Id;
              pfc.Core_MDF_Audit_Type__c = 'Random';            
              pfc.Core_MDF_FlaggedForAudit__c = TRUE;
              pfc.Core_MDF_Status__c = 'Hold';
              pfc.Core_MDF_Audit_Hold__c = TRUE;
              claimListTobeUpdated.add(pfc);
        }
        System.debug('NZ-->claimListTobeUpdated: '+claimListTobeUpdated);
        if(claimListTobeUpdated != null && !claimListTobeUpdated.isEmpty() && claimListTobeUpdated.size()>0) {
        	Database.SaveResult[] clLst = Database.update(claimListTobeUpdated);
        //	    System.debug('NZ-->clLst: '+clLst);
        }
        }                        
     
        catch(exception ex){Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Core_MDF_Batch_RetryCaseCreation');} 
    
    } 
            
    global void finish (Database.BatchableContext batchableContext){
        try{           
      			//Core_MDF_ClaimReviewCaseProcess.insertAudHoldClaimsForCaseRetry(claimListTobeUpdated);
        }
        catch(exception ex){
            String errMsg = ex.getMessage();
           
            if(errMsg.contains('UNABLE_TO_LOCK_ROW')){
                String idStr = '';
                List<String> errorStrList = new List<String>();
                errorStrList = errMsg.split('id ');	
                idStr = errorStrList[1].Substring(0,18); 
                
            }else{
             	 Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Core_MDF_Batch_RetryCaseCreation');
        	}
           
        }
    }
    //US861738 - [KIIT]: Batch Retry to incorporate the Case Closure which pass due date
    //Method to update the case status to Non-complaint if the Document submission due date is past
    public static void updateCaseStatus(){
        //Id JobId = System.enqueueJob(new Core_MDF_CaseStatusUpdate());
        /*try{
            List<Case> toUpdateCaseList = new List<Case>();
            DateTime curDateTime = System.now();
            System.debug('Inside Update case status');
            Integer recsLimit = Integer.valueOf(System.Label.Core_MDF_CaseRecsUpdateLimit);
            for(Case cs:[Select Id,Core_MDF_Document_Submission_DueDate_dtm__c,Core_MDF_Status__c,Core_MDF_Review_Case_Status__c from Case where RecordType.DeveloperName = 'Core_MDF_Audit' and Core_MDF_Status__c = 'Pending Documents' and Core_MDF_Document_Submission_DueDate_dtm__c <:curDateTime Limit :recsLimit]){
                DateTime docSubmissionDueDate = cs.Core_MDF_Document_Submission_DueDate_dtm__c;
                docSubmissionDueDate = docSubmissionDueDate.addDays(1);
                if(docSubmissionDueDate < curDateTime){
                    cs.Core_MDF_Review_Case_Status__c = 'Non-compliant';
                    toUpdateCaseList.add(cs);
                }
            }
            if(toUpdateCaseList != null && !toUpdateCaseList.isEmpty()){
                Database.SaveResult[] sr = Database.update(toUpdateCaseList, false);
            }
        }catch(exception e){
            System.debug('Case status update Exception =>'+e.getMessage());
        }*/
    }
}