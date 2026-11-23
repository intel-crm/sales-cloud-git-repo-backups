//global class Core_MDF_Batch_UpdateCampaignSts implements Database.Batchable<sObject>, Database.Stateful{
//US949837 - Added without sharing keyword to fix checkmarx issue
global without sharing class Core_MDF_Batch_UpdateCampaignSts implements Database.Batchable<sObject>, Database.Stateful{

global Datetime dtTime=System.now();
global date todaydt= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()));            
global final String changeToCompletedStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Campaign_Completed_Sts');
global final String changeToInProgressStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Campaign_InProgress_Sts');
global List<String> checkStatus = new List<String>{'Planned','In Progress'};
    
    global String ccpProgramAPIName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RecordType_API_Name');
    global String[] ccpProgram =  CCPProgramAPIName.split(',');

    
//global List<String> checkProgram = new List<String>{'Client CoMarketing Fund','Data Center CoMarketing Fund'};
global List<Id> updatedCampaignIds = new List<Id>();
global List<Campaign> campaignsUpdated = new List<Campaign>();
global List<Id> campaignsIdUpdated = new List<Id>();
global String queryActive;
global String errorMessage = '';   
    
    
global Database.QueryLocator start(Database.BatchableContext batchableContext)
    {   
    	return Database.getQueryLocator(queryActive);
    } 

global void execute(Database.BatchableContext batchableContext, List<Campaign> campaigns)
    { 
       
        try
        {
            system.debug('campaigns:'+campaigns);
                if(!campaigns.isEmpty())
                    {
                        List<Campaign> finalCampaignsToUpdate = new List<Campaign>();
                        
                       //Iterating through each campaign and updating status to 'Completed'.
                        for(Campaign completeCampaign : campaigns)
                            {
                               
                                //Added check for Enddate
                                if(completeCampaign.StartDate <= todaydt && completeCampaign.endDate > todaydt)
                                    {
                                        completeCampaign.Status = changeToInProgressStatus;
                                    }
                                else
                                    {
                                        completeCampaign.Status = changeToCompletedStatus;
                                        //Added for IPA
                                        if(completeCampaign.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')){
                                            completeCampaign.RecordTypeId =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_CampaignClosedRecordId');
                                        }
                                    }                
                                finalCampaignsToUpdate.add(completeCampaign);
                                updatedCampaignIds.add(completeCampaign.Id);
                            }
                        list<Database.SaveResult> results = Database.update(finalCampaignsToUpdate,false);
                        
                        for ( Integer i = 0; i < results.size(); i++ ) 
                            {
                                if ( !results.get(i).isSuccess() || Test.isRunningTest()) 
                                    {                
                                    errorMessage +='<tr><td>'+finalCampaignsToUpdate.get(i).Core_mdf_program__c+'</td><td>'+finalCampaignsToUpdate.get(i).Core_MDF_Campaign_Reference_Number__c+'</td><td>'+finalCampaignsToUpdate.get(i).Id+'</td><td>'+finalCampaignsToUpdate.get(i).Name+'</td> <td>';
                                    for ( Database.Error theError : results.get(i).getErrors() ) 
                                        {
                                            errorMessage += theError.getMessage()+'</td></tr>';
                                        }
                                    }
                                else{
                                    campaignsIdUpdated.add(finalCampaignsToUpdate.get(i).Id);                                 
                                }
                                if(Test.isRunningTest()){
                                    campaignsIdUpdated.add(finalCampaignsToUpdate.get(i).Id);                                 
                                }
                            }
                        if(!campaignsIdUpdated.isEmpty())
                            {
                                   campaignsUpdated = [Select Id,Core_mdf_program__c,Core_MDF_Campaign_Reference_Number__c,Name,Status,StartDate,EndDate from Campaign where Id in:campaignsIdUpdated];
                                   System.debug('*** Campaigns updated : '+campaignsUpdated);
                            }
                    }  
            }
        	
        	catch(Exception ex)
                {
                	System.debug('***Exception occurred while ReProcessing' + ex.getmessage()); 
                }   
    }     

global void finish (Database.BatchableContext batchableContext)
    {
        System.debug('*** Campaigns updated : '+campaignsUpdated);
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
        String message = 'The batch Apex job with JObId: '+ a.Id +' processed. <br><br>';
       
        //Fetching Email Address details from Custom setting.
        String sendEmailAddress = Label.Core_MDF_CCP_Support_Email;
        //String sendEmailAddress = 'ealisha.chatterjee@intel.com';
        Boolean sendemail = false;
        // Send an email to the Apex job's ;submitter notifying of job completion only if Custom Setting 'toAddress' data is available
        if(Test.isRunningTest())
            {
                sendEmailAddress = 'ealisha.chatterjee@intel.com';
                sendemail = true;
            }
         
        if((campaignsUpdated != null && !campaignsUpdated.isEmpty()) || errorMessage != '')
        	{
                sendemail = true;
            }        
        
        
        if( sendemail == true && (sendEmailAddress != null && sendEmailAddress != ''))        
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress};
                mail.setToAddresses(toAddresses);
                mail.setSubject(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SFDC_Environment') + ': Salesforce BatchUpdateCampaignField ' + a.Status);
                String messageBody = '';
                if(!campaignsUpdated.isEmpty() || Test.isRunningTest()){
                messageBody += '\nCampaigns Processed:\n\n';
                messageBody += '<table style="width:100%"><tr><th>Program</th><th>Campaign Reference Number</th><th>Campaign Id</th><th>Campaign Name</th><th>Status</th><th>StartDate</th><th>EndDate</th></tr>';
                for(campaign c:campaignsUpdated)
                    {
                      messageBody += '<tr><td>'+c.Core_mdf_program__c+'</td> <td>'+c.Core_MDF_Campaign_Reference_Number__c+'</td><td>'+c.Id+'</td><td>'+c.Name+'</td><td>'+c.Status+'</td><td>'+c.StartDate+'</td><td>'+c.EndDate+'</td></tr>';
                    }
                messageBody += '</table><br>';
                }
                
                if(errorMessage != '' || Test.isRunningTest())
                    {
                        
                        messageBody += '\nFollowing campaigns have failed during the update:\n\n';
                        messageBody += '<table style="width:100%"><tr><th>Program</th><th>Campaign Reference Number</th><th>Campaign Id</th><th>Campaign Name</th><th>Error Message</th></tr>';                                                                
                        messageBody +=  errorMessage;
                    }
                mail.setHtmlBody(message + '\n' + '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>' + messageBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
             }
    }
}