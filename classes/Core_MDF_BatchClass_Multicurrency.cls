/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_BatchClass_Multicurrency 
* Version     : 1.0 
* Created Date: 11-29-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi 		11/29/2018					  Batch class to call Multicurrency class which will load data from the Multicurrency API
* Intel - Narayani Perachi		12/26/2018                    Added Database.AllowsCallouts to allow multiple callouts and added Limit 1 to the query
* Intel - Narayani Perachi		12/26/2018                    Added Environment Label to the Mail subject to make it more readable
**************************************************************************************************************************************************************************************/
//US930209 - Added without sharing keyword to fix checkmarx issues
global without sharing class Core_MDF_BatchClass_Multicurrency implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    string query='';
    string sendEmailAddress = '';
    string message='';
    global string returnMessage ='';
      
    global Database.queryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator('SELECT Id from Core_MDF_ChannelProgram__mdt LIMIT 1');
    }

    global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
    {
        try
        {
            //system.debug('Batch class');
            returnMessage = Core_MDF_CCP_Multicurrency.callHttp();
            //system.debug('returnMessage from execte' + returnMessage);
        }
        
        catch(Exception ex)
        {
            //System.debug('Exception has occurred' + ex.getmessage());
            returnMessage += ex.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        //system.debug('Finish class');
        //system.debug('returnMessage from finish' + returnMessage);
        sendEmailAddress = Label.Core_MDF_CCP_Support_Email;               
        
        if(sendEmailAddress != null && sendEmailAddress != '')
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress};
                mail.setToAddresses(toAddresses);
                mail.setSubject(Label.Core_MDF_SFDC_Environment + ': Salesforce Multicurrency Job ');
                mail.setHtmlBody(returnMessage);
                mail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);//17001
        		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                
            }
    }
}