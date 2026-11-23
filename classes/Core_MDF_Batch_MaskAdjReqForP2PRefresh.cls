public without sharing class Core_MDF_Batch_MaskAdjReqForP2PRefresh implements Database.Batchable<sObject>,Database.Stateful {
 
    public List<Id> successAdjreqIdList = new List<Id>();
    public Map<Id,Core_MDF_Adjustment_Request__c> adjReqToBeUpdated = new Map<Id,Core_MDF_Adjustment_Request__c>{};
    // instance members to retain state across transactions
    public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public String limitStr = '10';
    public String messageBody = '';
    public String errorMessage = ''; 
    public List<Core_MDF_Adjustment_Request__c> failedAdjreqIdList;
    //Put the LIMIT in the constructor
    public Core_MDF_Batch_MaskAdjReqForP2PRefresh(Integer limitInt){
        if(limitInt != NULL){
            this.limitStr = String.valueOf(limitInt);
        }
        System.debug('this.limitStr: ' + this.limitStr);
    }
    public Core_MDF_Batch_MaskAdjReqForP2PRefresh(){
        this.limitStr = NULL;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //Querying all adjustment requests
        String query = 'SELECT Id,Core_MDF_Comments_Txt__c FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Comments_Txt__c!=NULL';
        if(limitStr != NULL){
            query += ' LIMIT ' + limitStr;
        }
        System.debug('query : ' + query);
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext bc, List<Core_MDF_Adjustment_Request__c> adjList) 
    {
        if(currorg.issandbox){
            for(Core_MDF_Adjustment_Request__c adjreq : adjList) 
            {
                //Emptying comment field of the adjustment requests
                adjreq.Core_MDF_Comments_Txt__c = '';
                adjReqToBeUpdated.put(adjreq.Id,adjreq);
            }
            try 
            {
                //updating the adjustment requests records in database
                if(adjList!=null && adjList.size()>0){
                    Database.SaveResult[] srList = Database.update(adjList,false);
                    // Iterate through each returned result
                    
                    for ( Integer index = 0; index < srList.size(); index++ )  {
                        if (srList.get(index).isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated Adjustment Request ' + srList.get(index).getId());
                            successAdjreqIdList.add(srList.get(index).getId());
                        }
                        else
                        {
                            for ( Database.Error theError : srList[index].getErrors() ) 
                            {              
                                errorMessage += '<tr><td>'+adjList.get(index).Id+'</td><td>'+theError.getMessage()+'</td></tr>';
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
                if(adjReqToBeUpdated != null && adjReqToBeUpdated.size()>0){
                    system.debug('Adjustment requests from finish():');             
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                    String message = 'The batch Apex job with JobId: '+ a.Id +' processed ' + successAdjreqIdList.size() + ' Adjustment Request records successfully.';
                    String sendEmailAddress = a.CreatedBy.Email;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {sendEmailAddress}; 
                    List<String> ccTo = new List<String>();
                    ccTo.add('ccptechsupport@intel.com');
                    ccTo.add('amal.thomas@intel.com');
                    ccTo.add('anjalix.haryani@intel.com');
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccTo);
                    mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for Adjustment Request field masking ' + a.Status);                                                                               
                    messageBody += '\nFollowing Adjustment Requests have failed during the update:\n\n';
                    messageBody += '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                    messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                       
                    messageBody += errorMessage;
                    messageBody += '</table>';                          
                    mail.setHtmlBody(message + '<br/>' + messageBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
        catch(exception ex){system.debug(ex.getMessage());}
    }
}