public class Core_MDF_ApproverCommentServiceHandler {
    
       /*****************************************************************************************************
Method Name :   updateApproverComment 
@return     :   NULL
Description :   update Approver Comment 
******************************************************************************************************/
    public static void updateApproverComment(List<Core_MDF_Approver_Comment__e> newList){
        
         String Comment='';
    Map<Id,Id> campIdProcessInstId = new Map<Id,Id>();
    Set<Id> campIdSet = new Set<Id>();
    Map<Id,List<ProcessInstanceStep>> piAndListofPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
    List<Core_MDF_Approver_Comment__e> cmp =new List<Core_MDF_Approver_Comment__e>();
       
    List<Campaign> toUpdateCampRecs = new List<Campaign>();
    Boolean hasL1ProposalApproverPS  = FeatureManagement.checkPermission('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');
    System.debug('hasL1ProposalApproverPS:->>>>'+hasL1ProposalApproverPS);
    
    Set<Id> cmpIdSet = new set<Id>();
    
    for(Core_MDF_Approver_Comment__e eventObj : newList){
        cmpIdSet.add(eventObj.Core_MDF_TargetObjectId__c);
    }   
    
    
    try{    
               
                        System.debug('Target object Id set==> ' + cmpIdSet);
                        
                        for(ProcessInstance pi : [SELECT Id,TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps order by CreatedDate asc) FROM ProcessInstance 
                                                  WHERE TargetObjectId IN :cmpIdSet AND Status ='Pending']){
                                                      campIdProcessInstId.put(pi.TargetObjectId, pi.Id);
                                                      piAndListofPiStepMap.put(pi.Id,pi.Steps);
                                                      System.debug('pi.Steps==> '+pi.Steps);
                                                      
                                                  }
    }Catch(Exception e){
        system.debug('exception occurred==>'+e);
    }
 } 
}