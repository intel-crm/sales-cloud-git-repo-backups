/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_RecallApprovalServiceHandler 
* Version     : 1.0 
* Created Date: 4-26-2021
* Modification Log :
* Developer                         Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  Prashant Dhanagar      4/26/2021                     recallApprovalProcess() - To recall the apporval process for given record Ids

*  Prashant Dhanagar      4/26/2021                     submitForApproval() - To submit the record in apporval for given record Ids

*/
public without sharing class Core_MDF_RecallApprovalServiceHandler {
    public static final string STATUS_PENDING ='Pending';
    public static final string ACTION_REMOVED ='Removed';
    public static final string ERR_STR ='Approval Error: ';
    public static final string STATUS_CLOSED ='Closed';
    public static final string NO_INTERNAL_APPROVAL_CT='No Internal Approval';
    public static final string STATUS_PENDING_REVIEW ='Pending Review';
    public static final string STATUS_PENDING_APPROVAL='Pending Approval';
    public static final string GEO_LEAD ='Geo Lead';
    public static String logEntryMsg = '';


   /*****************************************************************************************************
    Method Name :   recallApprovalProcess 
    @return     :   NULL
    @parameters :   list of Core_MDF_Recall_Approval__e platform event record
    Description :   Perform the Recall action of approval process.
    ******************************************************************************************************/
    public static void recallApprovalProcess(List<Core_MDF_Recall_Approval__e> newList){
        Set<Id> recallPFRId = new Set<Id>();
        Set<Id> afterFactApprovalPFRId = new Set<Id>();
        Set<Id> nextStageAffropvalIds = new Set<Id>();
        for(Core_MDF_Recall_Approval__e recallEventObj: newList){
    
                //To recall activities from approval process when closed or cancelled
                 if((recallEventObj.Core_MDF_Request_Status_nm__c == Label.Core_MDF_Activity_Cancelled_Status ||
                      recallEventObj.Core_MDF_Request_Status_nm__c == STATUS_CLOSED) ||
                    (recallEventObj.Core_MDF_Activity_Editor_txt__c == GEO_LEAD && 
                     (recallEventObj.Core_MDF_Request_Status_nm__c == STATUS_PENDING_REVIEW || 
                     recallEventObj.Core_MDF_Request_Status_nm__c == STATUS_PENDING_APPROVAL)) ){                          
                         recallPFRId.add(recallEventObj.Core_MDF_Target_Object_Id__c);    
                  }               
                //Creating a list of pfr Ids which needs to be submitted for ATF approval
                if(recallEventObj.Core_MDF_Program_nm__c == Label.Core_MDF_Retail_Channel_Program_Name && 
                   recallEventObj.Core_MDF_Request_Status_nm__c == STATUS_CLOSED && 
                   recallEventObj.Core_MDF_Closure_Type_nm__c == NO_INTERNAL_APPROVAL_CT){
                       afterFactApprovalPFRId.add(recallEventObj.Core_MDF_Target_Object_Id__c);
                   }
                //To recall activities from approval process when Geo Lead edits
               	 if(recallEventObj.Core_MDF_Activity_Editor_txt__c == GEO_LEAD && 
                    recallEventObj.Core_MDF_Program_nm__c == Label.Core_MDF_Retail_Channel_Program_Name){
                      nextStageAffropvalIds.add(recallEventObj.Core_MDF_Target_Object_Id__c);

                   }                         
        }
        //Check the size of recallPFRId , remove the Activities from Approval Queue
        try{
        if(!recallPFRId.isEmpty()){
            
            List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();                         
            for(ProcessInstanceWorkitem PIns:[SELECT Id
                                              FROM ProcessInstanceWorkitem 
                                              WHERE ProcessInstance.TargetObjectId IN :recallPFRId
                                             AND ProcessInstance.Status =: STATUS_PENDING]){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction(ACTION_REMOVED);
                pwr.setWorkItemId(PIns.id);
                pwrList.add(pwr);   
           }
            Integer index = 0;
            boolean res = false;
            List<Approval.ProcessResult> resultList = Approval.process(pwrList);
            for(Approval.ProcessResult result : resultList){
                  if(result.isSuccess()){
                      res = true;
                  }else{
                        logEntryMsg = ERR_STR + pwrList[index]; Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);
                    }
                    index++;
            }    
        }
         //Submit closed and missed internal approval activities for ATF Approval
        if(!afterFactApprovalPFRId.isEmpty()){
                
            Set<Id> processInstanceIds = getProcessInstanceWorkItem(nextStageAffropvalIds);
            submitForApproval(afterFactApprovalPFRId,processInstanceIds,'Record submitted for After The Fact approval');
        }
       if(!nextStageAffropvalIds.isEmpty()){
           Set<Id> processInstanceIds = getProcessInstanceWorkItem(nextStageAffropvalIds);
           submitForApproval(nextStageAffropvalIds,processInstanceIds,'');
       }
    } catch(exception ex){
                 logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);         
            
        }
    }
    /*****************************************************************************************************
    Method Name :   submitForApproval 
    @return     :   NA
    @parameters :   Set of recordIds to submit for approval
    Description :   submit the record for approval.
    ******************************************************************************************************/
    public static void submitForApproval(Set<Id> approvalPFRIdS, Set<Id> processInstanceIds,String comment){
                 List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
                for(Id pfrId : approvalPFRIdS){
                    if(processInstanceIds!= null && !processInstanceIds.contains(pfrId)){
                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                    appObj.setObjectId(pfrId);
                    if(String.isNotBlank(comment)){
                        appObj.setComments(comment);
                    }                    
                    appRequests.add(appObj);
                    }
                }
                
                if(appRequests != NULL && appRequests.size()> 0){
                   Approval.process(appRequests); 
                }
    }
    /******************************************************************
    Method Name :   getProcessInstanceWorkItem 
    @return     :   Set<Id>
    @parameters :   Set of recordIds
    Description :   Set of records pending for approval 
     * ****************************************************************/
    public static Set<Id> getProcessInstanceWorkItem (Set<Id> pfrIds){
        Set<Id> resultSet = new Set<Id>();
        for(ProcessInstanceWorkitem pi:[SELECT Id,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :pfrIds AND 
                 ProcessInstance.Status =: STATUS_PENDING]){
        		 resultSet.add(pi.ProcessInstance.TargetObjectId);
        }
        return resultSet;
    }
}