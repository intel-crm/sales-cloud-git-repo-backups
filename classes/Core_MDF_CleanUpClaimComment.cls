/****************************************************************************************************************************************
* Class Name  : Core_MDF_CleanUpClaimComment 
* Version     : 1.0 
* Created Date: 05-25-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Anjali Haryani         05/05/2020               Created Core_MDF_CleanUpClaimComment for cleaning up comments field on claim
*****************************************************************************************************************************************/

global class Core_MDF_CleanUpClaimComment implements Database.Batchable<sObject>,Database.Stateful {
    global integer i = 1;
    global String errorMessage = '';  
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    global Map<Id,PartnerFundClaim> claimtobeupdated = new Map<Id,PartnerFundClaim>{};

    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Querying claims 
        String query = 'SELECT Id,Title,Core_MDF_Claim_Comments__c,Core_MDF_Intel_Manual_Hold_Comments_Txt__c,Core_MDF_Member_Manual_Hold_Comments_Txt__c FROM PartnerFundClaim limit 15';
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext BC, List<PartnerFundClaim> claimList) 
    {
        if(currorg.issandbox)
        {
            for(PartnerFundClaim claim : claimList) 
            {
                //Emptying all three comment fields of the claims
                if(claim.Core_MDF_Claim_Comments__c!=NULL)
                    claim.Core_MDF_Claim_Comments__c = '';
                if(claim.Core_MDF_Intel_Manual_Hold_Comments_Txt__c!=NULL)            
                    claim.Core_MDF_Intel_Manual_Hold_Comments_Txt__c = '';
                if(claim.Core_MDF_Member_Manual_Hold_Comments_Txt__c!=NULL)             
                    claim.Core_MDF_Member_Manual_Hold_Comments_Txt__c = '';
                claim.Title = 'test'+i;
                i+=1; 
                claimtobeupdated.put(claim.Id,claim);
            }
            try 
            {
                //updating the claims in database
                if(claimList!=null && claimList.size()>0){
                    Database.update(claimList,false);
                }               
            } 
            catch(Exception e) 
            {
                System.debug('Exception'+e);
                Core_MDF_CCP_UtilityClass.logError(e);        
            }
        }
    }        
    public void finish(Database.BatchableContext BC) 
    {
        try
        {
            if(claimtobeupdated != null && claimtobeupdated.size()>0){
                system.debug('claims inside finish:');          
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String message = 'The batch Apex job with JObId: '+ a.Id +' processed below claim records.';
                List<PartnerFundClaim> claimList =  [SELECT Id,Title,Core_MDF_Claim_Comments__c,Core_MDF_Intel_Manual_Hold_Comments_Txt__c,Core_MDF_Member_Manual_Hold_Comments_Txt__c FROM PartnerFundClaim where id in :claimtobeupdated.keySet()];
                String sendEmailAddress = a.CreatedBy.Email;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress}; 
                mail.setToAddresses(toAddresses);
                mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for claim records field masking ' + a.Status);
                String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                messageBody += '<table style="width:100%"><tr><th>Id</th><th>Core_MDF_Claim_Comments__c</th><th>Core_MDF_Intel_Manual_Hold_Comments_Txt__c</th></tr>';
                for(PartnerFundClaim p:claimList)
                {
                  messageBody += '<tr><td>'+p.Id+'</td><td>'+p.Core_MDF_Claim_Comments__c+'</td><td>'+p.Core_MDF_Intel_Manual_Hold_Comments_Txt__c+'</td></tr>';
                }
                messageBody += '</table>';              
                mail.setHtmlBody(message + '<br/>' + messageBody);
                if(errorMessage != '')
                {                   
                    messageBody += '\nFollowing claim records have failed during the update:\n\n';
                    messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                                                                
                    messageBody +=  errorMessage;
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }
        catch(exception ex){system.debug(ex.getMessage());}
    }
}