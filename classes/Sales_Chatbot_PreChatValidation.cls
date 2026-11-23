/*********************************************************************************************************************
Class Name    : Sales_Chatbot_PreChatValidation
Version       : 1.0
Created Date  : August 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma    	6-8-2021              	Validate the Pre-Chat Form Details
* *********************************************************************************************************************/
public without sharing class Sales_Chatbot_PreChatValidation {
    
    public class TranscriptInput {
        @InvocableVariable
        public ID routableID;
        @InvocableVariable
        public ID contactId;
    }
    
    public class VisitorOutput {
        @InvocableVariable
        public Boolean validContactDetails;
    }
    
    @InvocableMethod(label='Check Pre Chat Form Valid Contact')// Check if Contact is a valid salesforce Contact record
    public static List<VisitorOutput> checkValidContact(List<TranscriptInput> transcripts){
        List<VisitorOutput> outputDetails = new List<VisitorOutput>();
        Id loggedincontactId; 
        Boolean isValidUser = false;
        Boolean isInternalUser = false;
        Boolean isExternalUser = false;
        for (TranscriptInput transcript : transcripts) {
            Boolean isValid=false;
            Set<Id> profileIds = new Set<Id>();
            loggedincontactId = transcript.contactId;
            VisitorOutput op = new VisitorOutput();
            // Query for the transcript record based on the ID
            LiveChatTranscript transcriptRecord = [SELECT Name, FirstName__c, LastName__c, Email__c, ContactId, LoggedInUserId__c
                                                   FROM LiveChatTranscript 
                                                   WHERE Id = :transcript.routableID 
                                                   LIMIT 1]; 
            
            
            System.debug('transcriptRecord-->'+transcriptRecord);
            try{
                if(transcriptRecord != null){
                    User loggedInUser = [Select Id, ContactId,Contact.Email from User where id=:transcriptRecord.LoggedInUserId__c];
                    if(transcriptRecord.Email__c==loggedInUser.Contact.Email){
                        isValid=true;
                    }
                }
            }
            catch(Exception e){}           
            op.validContactDetails = isValid;
            outputDetails.add(op);// Add outputs
        }
        return outputDetails;
    }
}