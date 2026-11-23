public without sharing class Core_MDF_Batch_MaskPaymentForP2PRefresh implements Database.Batchable<sObject>,Database.Stateful {
 
    public List<Id> successPaymentIdList = new List<Id>();
    public String errorMessage = ''; 
    public Map<Id,Core_MDF_Payment__c> paymenttobeupdated = new Map<Id,Core_MDF_Payment__c>{};
    // instance members to retain state across transactions
    public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public String limitStr = '10';
    public String messageBody = '';
    public List<Core_MDF_Payment__c> failedPaymentIdList;
    //Put the LIMIT in the constructor
    public Core_MDF_Batch_MaskPaymentForP2PRefresh(Integer limitInt){
        if(limitInt != NULL){
            this.limitStr = String.valueOf(limitInt);
        }
        System.debug('this.limitStr: ' + this.limitStr);
    }
    public Core_MDF_Batch_MaskPaymentForP2PRefresh(){
        this.limitStr = NULL;
    }
        
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //Querying all payments
        String query = 'SELECT Id,Core_MDF_EFT_Nbr__c FROM Core_MDF_Payment__c';
        if(limitStr != NULL){
            query += ' LIMIT ' + limitStr;
        }
        System.debug('query : ' + query);
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext bc, List<Core_MDF_Payment__c> paymentList) 
    {
        if(currorg.issandbox){
            for(Core_MDF_Payment__c payment : paymentList) 
            {
                //Emptying field of the payment
                payment.Core_MDF_EFT_Nbr__c = '';
                paymenttobeupdated.put(payment.Id,payment);
            }
            try 
            {
                //updating the payments records in database
                if(paymentList!=null && paymentList.size()>0){
                    Database.SaveResult[] srList = Database.update(paymentList,false);
                    // Iterate through each returned result
                    for ( Integer index = 0; index < srList.size(); index++ )  {
                        if (srList.get(index).isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated Payment ' + srList.get(index).getId());
                            successPaymentIdList.add(srList.get(index).getId());
                        }
                        else
                        {
                            for ( Database.Error theError : srList[index].getErrors() ) 
                            {              
                                errorMessage += '<tr><td>'+paymentList.get(index).Id+'</td><td>'+theError.getMessage()+'</td></tr>';
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
                if(paymenttobeupdated != null && paymenttobeupdated.size()>0){
                    system.debug('payment from finish():');             
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                    String message = 'The batch Apex job with JobId: '+ a.Id +' processed ' + successPaymentIdList.size() + ' Payment records successfully.';
                    //List<Core_MDF_Payment__c> failedPaymentIdList =  [SELECT Id,Core_MDF_EFT_Nbr__c FROM Core_MDF_Payment__c where id in :paymenttobeupdated.keySet() and Core_MDF_EFT_Nbr__c!=null];
                    String sendEmailAddress = a.CreatedBy.Email;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {sendEmailAddress}; 
                    List<String> ccTo = new List<String>();
                    //ccTo.add('amal.thomas@intel.com');
                    ccTo.add('anjalix.haryani@intel.com');
                    ccTo.add('ccptechsupport@intel.com');
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccTo);
                    mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for Payment field masking ' + a.Status);
                    messageBody += '\nFollowing payments have failed during the update:\n\n';
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