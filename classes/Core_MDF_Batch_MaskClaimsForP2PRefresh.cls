public without sharing class Core_MDF_Batch_MaskClaimsForP2PRefresh implements Database.Batchable<sObject>,Database.Stateful {
 
    public List<Id> successClaimIdList = new List<Id>();
    public String errorMessage = ''; 
    public Map<Id,PartnerFundClaim> claimsToBeUpdated = new Map<Id,PartnerFundClaim>{};
    // instance members to retain state across transactions
    public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public String limitStr = '10';
    public String messageBody = '';
    public integer i = 0;
    
    public List<PartnerFundClaim> failedClaimList;

    //Put the LIMIT in the constructor
    public Core_MDF_Batch_MaskClaimsForP2PRefresh(Integer limitInt){
        if(limitInt != NULL){
            this.limitStr = String.valueOf(limitInt);
        }
        System.debug('this.limitStr: ' + this.limitStr);
    }
    public Core_MDF_Batch_MaskClaimsForP2PRefresh(){
        this.limitStr = NULL;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //Querying all claims
        String query = 'SELECT Id,Title,Core_MDF_Claim_Comments__c,Core_MDF_Intel_Manual_Hold_Comments_Txt__c,Core_MDF_Member_Manual_Hold_Comments_Txt__c FROM PartnerFundClaim';
        if(limitStr != NULL){
            query += ' LIMIT ' + limitStr;
        }
        System.debug('query : ' + query);
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> pfcList) 
    {
        if(currorg.issandbox){
            for(PartnerFundClaim pfc : pfcList) 
            {
                //Emptying comment field of the claim comments
                pfc.Core_MDF_Claim_Comments__c= '';
                pfc.Core_MDF_Intel_Manual_Hold_Comments_Txt__c= '';
                pfc.Core_MDF_Member_Manual_Hold_Comments_Txt__c = '';
                pfc.Title = 'Test'+i;
                i++;
                claimsToBeUpdated.put(pfc.Id,pfc);
            }
            try 
            {
                //updating the claims records in database
                if(pfcList!=null && pfcList.size()>0){
                    Database.SaveResult[] srList = Database.update(pfcList,false);
                    // Iterate through each returned result
                    for ( Integer index = 0; index < srList.size(); index++ )  {
                        if (srList.get(index).isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated Claim ' + srList.get(index).getId());
                            successClaimIdList.add(srList.get(index).getId());
                        }
                        else
                        {
                            for ( Database.Error theError : srList[index].getErrors() ) 
                            {              
                                errorMessage += '<tr><td>'+pfcList.get(index).Id+'</td><td>'+theError.getMessage()+'</td></tr>';
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
                if(claimsToBeUpdated != null && claimsToBeUpdated.size()>0){
                    system.debug('Claims from finish():');             
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                    String message = 'The batch Apex job with JobId: '+ a.Id +' processed ' + successClaimIdList.size() + ' Claim records successfully.';
                    String sendEmailAddress = a.CreatedBy.Email;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {sendEmailAddress}; 
                    List<String> ccTo = new List<String>();
                    //ccTo.add('amal.thomas@intel.com');
                    ccTo.add('anjalix.haryani@intel.com');
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccTo);
                    mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for Claims field masking ' + a.Status);
                    messageBody += '\nFollowing Claims have failed during the update:\n\n';
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