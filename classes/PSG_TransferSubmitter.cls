/****************************************************************************************************
Apex Class Name : PSG_TransferSubmitter
Version         : 1.0 
Created Date    : 2/1/2024
Function        : This class is used to call the PSG_TransferSubmitterBatch from the flow.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2/1/2024                Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_TransferSubmitter {

    /************************************************************************************************************
    *Method Name : transferSubmitterFromFlow
    *Created Date: 2/1/2024
    *Author: Bishal Singh
    *Description : Set the batch initial values and execute the batch.
    ************************************************************************************************************/
    /*@InvocableMethod(label ='transferQuoteDPAsALNs')
    public static void transferSubmitterFromFlow(List<List<String>> submitterDetails) {
        List<String> details = submitterDetails.isEmpty() ? new List<String>() : submitterDetails[0];
        try {
            Id fromcontactPreviousSubmitterId = details.isEmpty() ? null : (Id)details[0];
            String fromPreviousSubmitterName = details.size() > 1 ? details[1] : null;
            Id toNewcontactSubmitterId = details.size() > 2 ? (Id)details[2] : null;
            String toNewSubmitterName = details.size() > 3 ? details[3] : null;
            String User_choice=details.size() > 4 ? details[4] : null;
            Id fromPreviousSubmitterId;
            Id toNewSubmitterId;
            for(User u: [select id,name,ContactId from user where ContactId =:fromcontactPreviousSubmitterId or ContactId =:toNewcontactSubmitterId]){                
                if(u.ContactId==fromcontactPreviousSubmitterId){
                    fromPreviousSubmitterId=u.Id;
                }else{
                    toNewSubmitterId=u.id;
                }
            }
            PSG_TransferSubmitterBatch batch = new PSG_TransferSubmitterBatch(fromPreviousSubmitterId, toNewSubmitterId,fromPreviousSubmitterName,toNewSubmitterName,User_choice);
            String jobId=Database.executeBatch(batch, Integer.Valueof(Label.PSG_SubmitterTransferbatchSize));
            PSG_Utility.createCoreLogEntry('PSG_TransferSubmitter', 'transferSubmitterFromFlow', 'Transfer Job Details', 'JOBID => '+jobId, 'SBQQ__Quote__c/core_cpq_dpa_aln__c', 'Info', '');
        } catch (Exception e) {
            PSG_Utility.createCoreLogEntry('PSG_TransferSubmitter', 'transferSubmitterFromFlow', 'Exception while executing batch for Transfer Submitter', 'details=> '+details+' Exception =>'+e, 'SBQQ__Quote__c/core_cpq_dpa_aln__c', 'High', '');
        }
    }*/
}