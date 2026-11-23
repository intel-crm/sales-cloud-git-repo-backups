/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_MaskClmBatchForP2PRefresh
* Version     : 1.0
* Created Date: 05-10-2020
* Modification Log :
* Developer                Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – PS         05/10/2020               Created Core_MDF_Batch_MaskClmBatchForP2PRefresh for cleaning up Claim Batch Supplier# and Comments
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_MaskClmBatchForP2PRefresh implements Database.Batchable<sObject>,Database.Stateful {
 
    public integer supplierNumber=1000000000;
    public String errorMessage = ''; 
    public List<Id> successClaimBatchStageIdList = new List<Id>();
    public Map<Id,Core_MDF_Claim_Batch_Stage__c> claimBatchStageToBeUpdated = new Map<Id,Core_MDF_Claim_Batch_Stage__c>{};
    // instance members to retain state across transactions
    public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public String limitStr = '10';
    public String messageBody = '';

    //Put the LIMIT in the constructor
    public Core_MDF_Batch_MaskClmBatchForP2PRefresh(Integer limitInt){
        if(limitInt != NULL){
            this.limitStr = String.valueOf(limitInt);
        }
        System.debug('this.limitStr: ' + this.limitStr);
    }
    public Core_MDF_Batch_MaskClmBatchForP2PRefresh(){
        this.limitStr = NULL;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //Querying all Claim Batch Stage records
        String query = 'SELECT Id,Core_MDF_Bank_Nbr__c, Core_MDF_Claim_Comment_txt__c FROM Core_MDF_Claim_Batch_Stage__c where Core_MDF_Claim_Comment_txt__c !=null';
        if(limitStr != NULL){
            query += ' LIMIT ' + limitStr;
        }
        //createUpdateMetadata(true);
        System.debug('query : ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Core_MDF_Claim_Batch_Stage__c> claimBatchList) 
    {
        if(currorg.issandbox){
            
            for(Core_MDF_Claim_Batch_Stage__c claimBatch : claimBatchList) 
            {
                System.debug('before masking:'+claimBatch.Core_MDF_Bank_Nbr__c);
                //Emptying field of the claim batch record
                claimBatch.Core_MDF_Bank_Nbr__c = String.valueof(supplierNumber);
                supplierNumber++;
                claimBatch.Core_MDF_Claim_Comment_txt__c = '';
                System.debug('after masking:'+claimBatch.Core_MDF_Bank_Nbr__c);
                claimBatchStageToBeUpdated.put(claimBatch.Id,claimBatch);
            }
            try 
            {
                //updating the claim Batch Stage records in database
                if(claimBatchList!=null && claimBatchList.size()>0){
                    Database.SaveResult[] srList = Database.update(claimBatchList,false);
                     // Iterate through each returned result
                    for ( Integer index = 0; index < srList.size(); index++ )  {
                        if (srList.get(index).isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated Claim Batch Stage' + srList.get(index).getId());
                            successClaimBatchStageIdList.add(srList.get(index).getId());
                        }
                        else
                        {
                            for ( Database.Error theError : srList[index].getErrors() ) 
                            {              
                                errorMessage += '<tr><td>'+claimBatchList.get(index).Id+'</td><td>'+theError.getMessage()+'</td></tr>';
                            }
                        }
                    }
                }               
            } 
            catch(Exception e) 
            {
                System.debug('Exception'+e);
                Core_MDF_CCP_UtilityClass.logError(e);        
            }  
        }
    }        
    public void finish(Database.BatchableContext bc) 
    {
        try
        {
            if(currorg.isSandbox){
                //createUpdateMetadata(false);
                if(claimBatchStageToBeUpdated != null && claimBatchStageToBeUpdated.size()>0){
                    system.debug('Claim Batch Stage from finish():');             
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                    String message = 'The batch Apex job with JobId: '+ a.Id +' processed ' + successClaimBatchStageIdList.size() + ' Claim Batch Stage records successfully.';
                    String sendEmailAddress = a.CreatedBy.Email;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {sendEmailAddress}; 
                    List<String> ccTo = new List<String>();
                    //ccTo.add('amal.thomas@intel.com');
                    ccTo.add('anjalix.haryani@intel.com');
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccTo);
                    mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for Claim Batch Stage field masking ' + a.Status);
                    messageBody += '\nFollowing Claim Batch Stage Requests have failed during the update due to following errors:\n\n'+'<br>';
                    messageBody += '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                    messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';
                    messageBody += errorMessage;
                    messageBody += '</table>';
                    mail.setHtmlBody(message + '<br/>' + messageBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    System.enqueueJob( new Core_MDF_Queue_ClmStgMtdataForP2PRefresh(true));
                }
            }
        }
        catch(exception ex){system.debug(ex.getMessage());}        
    }
}