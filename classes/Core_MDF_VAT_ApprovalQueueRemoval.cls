/****************************************************************************************************************************************
* Class Name  : Core_MDF_VAT_ApprovalQueueRemoval 
* Version     : 1.0   
* Created Date: 19 Nov,2020
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Areefa         19 Nov,2020                    Created Core_MDF_VAT_ApprovalQueueRemoval to remove record from approval queue for VAT process
*														Testclass coverage : Core_MDF_PFC_VAT_ServiceHandlerTest
*****************************************************************************************************************************************/ 
public without sharing class Core_MDF_VAT_ApprovalQueueRemoval {
 
/****************************************************************************************************************************************
    Method Name:                                             removeRecordsFromApprovalQueue
    @return  :                                               return Boolean.
    @parameters:                                             LIST<ID>
    Description:                                             remove the record from approval requests
    Added By:                                                Sridhar – 11/03/2020
*****************************************************************************************************************************************/    
   public static Boolean removeRecordsFromApprovalQueue(List<ID> removeRecords){ 
        
    Boolean status = false;
    string logEntryMsg = '';
    
    //Map<Id,Id> vatIDsRemoved = new Map<Id,Id>();
    //Check the size of vatRecords , remove the vat records from Approval Queue
    if(removeRecords.size()>0){

        ProcessInstanceWorkitem[] workItems = [SELECT Id, ProcessInstance.TargetObjectId
                                                FROM ProcessInstanceWorkitem 
                                                WHERE ProcessInstance.TargetObjectId IN :removeRecords
                                                AND ProcessInstance.Status = 'Pending'];
        
        List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();    

        //system.debug('##workItems->' + workItems);
        for(ProcessInstanceWorkitem PIns:workItems){
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setComments(Label.Core_MDF_VAT_Auto_Reject_Message);
            pwr.setAction('Reject');
            pwr.setWorkItemId(PIns.id);
            pwrList.add(pwr);   
            
        }
        Integer index = 0;

        //system.debug('##pwrList->' + pwrList);
        List<Approval.ProcessResult> resultList = Approval.process(pwrList);
        for(Approval.ProcessResult result : resultList){
            if(result.isSuccess()){
                status = true;
                //system.debug('##result.getEntityId()->' + result.getEntityId());
                //vatIDsRemoved.put(result.getEntityId(),result.getEntityId());
            }
            else{logEntryMsg = 'removeRecordsFromApprovalQueue Error: '+pwrList[index];Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_Claim_VAT_Info__c');}
            index++;
        }   
    }   
    
    return status;
   }

     
}