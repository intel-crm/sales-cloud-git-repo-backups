/***************************************************************************************************************************************
Apex Class Name     : PRM_ACRNotificationMessage 
Version             : 1.0
Created Date        : 7th August 2020

Modification Log    :
* Developer             Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Bharath Kumar       7th August 2020          Apex class to Send Notifications Messages to Contacts when new ACR is inserted/Updated.

***************************************************************************************************************************************/
public with sharing class PRM_ACRNotificationMessage {

    public static final String STATUS_COMPLETE = 'Complete';
    public static final String LOG_ENTRY_ORIGIN   = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_PROJECT  = 'IPA';
    public static final String LOG_ENTRY_SCOPE    = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static string MsgForLogEntry='*** Entered PRM_ACRNotificationMessage ***\n';

    @InvocableMethod(label='Send ACR Notification Message') 
    public static void sendNotifications(MessageWrapper[] msgWrap){
        Id conId = null;
        String messageCd = '';
        List<Id> contactList = new List<Id>();  
        Boolean isCreatedSameDateAndTime = true;
        Integer existingAcrCount = 0;
        try{
            for(MessageWrapper msg:msgWrap){
                conId = msg.contactId;
                messageCd = msg.msgCd;
            }
            //String acrStatus = System.Label.PRM_ACR_Status;
            MsgForLogEntry+='\n*** ACR Query Starts ***';
            List<PRM_Account_Contact_Relationship__c> acrList = [Select PRM_Status_Nm__c,CreatedDate from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c = :conId and PRM_InActive_Ind__c = false];
            if(acrList!= null && !acrList.isEmpty()){
                MsgForLogEntry+='\n ACR List Size==> '+acrList.size();
                
                DateTime firstRecDatetime = acrList[0].CreatedDate;
                for(PRM_Account_Contact_Relationship__c acr:acrList){
                    if(acr.PRM_Status_Nm__c == System.Label.PRM_ACR_Status){
                        existingAcrCount++;
                        isCreatedSameDateAndTime = (acr.CreatedDate != firstRecDatetime) ? false : true;

                    }
                }
                MsgForLogEntry+='\n*** ACR Query Ends ***\n';
                }
                if(existingAcrCount <= 1 || ((existingAcrCount > 1) && isCreatedSameDateAndTime)){ //If the current contact have already existing ACR record no message log should be generate
                    contactList.add(conId);
                    if(!contactList.isEmpty() && contactList != null){
                        MsgForLogEntry+='\n*** Entering PRM_SendNotificationMessages ***';
                        PRM_SendNotificationMessages.upsertMsgLogRecs(contactList,System.label.PRM_Msgcd_NewContact);
                    }
                }
        }
        Catch(Exception e){
            Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'PRM_ACRNotificationMessage Invoked at'+system.today() ,MsgForLogEntry+e.getmessage()  , '', '', '');           
            
        }
        Finally{
            Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'PRM_ACRNotificationMessage  Invoked at'+system.today() ,MsgForLogEntry , '', '', '');           
        
        }
    }

    public class MessageWrapper{
        @InvocableVariable(required=true)
        public String msgCd;
        @InvocableVariable(required=true)
        public Id contactId;
    }
}