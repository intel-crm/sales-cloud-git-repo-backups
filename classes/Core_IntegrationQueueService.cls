public without sharing class Core_IntegrationQueueService {

    public static List<Core_ACM_Integration_Queue__c> createQueueRecords(List<Contact> contacts, Map<Id, Contact> oldContactMap, String processType) {
        List<Core_ACM_Integration_Queue__c> queueRecords = new List<Core_ACM_Integration_Queue__c>();
        try {
            queueRecords = buildQueueRecords(contacts, oldContactMap, processType);

            if (!queueRecords.isEmpty()) {
                Database.SaveResult[] results = Database.insert(queueRecords, false);
                handleInsertResults(results, queueRecords);

                List<Contact_Message__c> contactMessages = new List<Contact_Message__c>();
                List<Contact> lstToUpdateContacts = new List<Contact>();
                buildPostInsertRecords(results, queueRecords, contactMessages, lstToUpdateContacts);

                if (!contactMessages.isEmpty()) {
                    Database.SaveResult[] contactMessageResults = Database.insert(contactMessages, false);
                    handleContactMessageInsertResults(contactMessageResults, contactMessages);
                }

                if (!lstToUpdateContacts.isEmpty()) {
                    Database.SaveResult[] contactUpdateResults = Database.update(lstToUpdateContacts, false);
                    handleContactUpdateResults(contactUpdateResults, lstToUpdateContacts);
                }
            }
        } catch (Exception e) {
            UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_INTEGRATION_QUEUE_SERVICE, 'createQueueRecords',
                'Message: ' + e.getMessage() + '. StackTrace: ' + e.getStackTraceString(), null);
            throw e;
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
        return queueRecords;
    }

    private static List<Core_ACM_Integration_Queue__c> buildQueueRecords(List<Contact> contacts, Map<Id, Contact> oldContactMap, String processType) {
        List<Core_ACM_Integration_Queue__c> queueRecords = new List<Core_ACM_Integration_Queue__c>();
        for (Contact contact : contacts) {
            Core_ACM_Integration_Queue__c queueRecord = new Core_ACM_Integration_Queue__c();
            queueRecord.Core_Contact__c = contact.Id;
            queueRecord.Core_Process_Type__c = processType;
            queueRecord.Core_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS);
            //Ganesh Changes
			if(contact.Core_Erpm_Integration_Status__c == 'Successful' && contact.Core_AGS_Integration_Status__c == 'Pending'){
			queueRecord.Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_AGS;
			queueRecord.Core_Payload__c = createRoleRequestPayloadJSON(contact, oldContactMap);
			}
			else{
            queueRecord.Core_Message_Type__c = Core_ACM_Constants.MESSAGE_TYPE_ERPM;
			queueRecord.Core_Payload__c = createERPMPayloadJSON(contact, oldContactMap);
			}
			//Ganesh Change Ends
            queueRecords.add(queueRecord);
        }
        return queueRecords;
    }

    private static void buildPostInsertRecords(Database.SaveResult[] results, List<Core_ACM_Integration_Queue__c> queueRecords,
                                                List<Contact_Message__c> contactMessages, List<Contact> lstToUpdateContacts) {
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess() && queueRecords[i].Id != null) {
                Contact_Message__c contMsg = new Contact_Message__c();
                contMsg.Contact__c = queueRecords[i].Core_Contact__c;
                contMsg.ACM_Integration_Queue__c = queueRecords[i].Id;
                contactMessages.add(contMsg);
                //Ganesh Changes
                Contact cTemp = new Contact(Id = queueRecords[i].Core_Contact__c);
				if(queueRecords[i].Core_Message_Type__c == Core_ACM_Constants.MESSAGE_TYPE_AGS) {
					cTemp.Core_AGS_Integration_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.IN_PROGRESS_STATUS);}
				else{
					cTemp.Core_ERPM_Integration_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.IN_PROGRESS_STATUS);}

				//Ganesh Changes End
                lstToUpdateContacts.add(cTemp);
            }
        }
    }

    private static String createERPMPayloadJSON(Contact contact, Map<Id, Contact> oldContactMap) {
        String payloadJson;
        try {
            Core_ACM_PayloadWrapper payload = Core_ACM_PayloadBuilder.buildPayload(contact, oldContactMap);
            payloadJson = JSON.serialize(payload);
        } catch (Exception e) {
            UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_INTEGRATION_QUEUE_SERVICE, 'createERPMPayloadJSON',
                'Message: ' + e.getMessage() + '. StackTrace: ' + e.getStackTraceString(), contact.Id);
            throw e;
        }
        return payloadJson;
    }
	
    //Ganesh Changes
	private static String createRoleRequestPayloadJSON(Contact contact, Map<Id, Contact> oldContactMap) {
    String payloadJson;
    try {
        Core_ACM_PayloadWrapper.RoleRequestPayload payload = Core_ACM_PayloadBuilder.buildRoleRequestPayload(contact);
        payloadJson = JSON.serialize(payload);
    } catch (Exception e) {
        UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_INTEGRATION_QUEUE_SERVICE, 'createRoleRequestPayloadJSON',
            'Message: ' + e.getMessage() + '. StackTrace: ' + e.getStackTraceString(), contact.Id);
        throw e;
    }
    return payloadJson;
}
	//Ganesh Changes End  
    private static void handleInsertResults(Database.SaveResult[] results, List<Core_ACM_Integration_Queue__c> queueRecords) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_INTEGRATION_QUEUE_SERVICE, 'handleInsertResults',
                    'Failed to create Integration Queue record for Contact: ' + queueRecords[i].Core_Contact__c + '. Error: ' + results[i].getErrors(), queueRecords[i].Core_Contact__c);
            }
        }
    }

    private static void handleContactMessageInsertResults(Database.SaveResult[] results, List<Contact_Message__c> contactMessages) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_INTEGRATION_QUEUE_SERVICE, 'handleContactMessageInsertResults',
                    'Failed to create Contact Message record for Contact: ' + contactMessages[i].Contact__c + '. Error: ' + results[i].getErrors(), contactMessages[i].Contact__c);
            }
        }
    }

    private static void handleContactUpdateResults(Database.SaveResult[] results, List<Contact> contactsToUpdate) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                UCD_ACM_Logger.error(Core_ACM_Constants.CLASS_INTEGRATION_QUEUE_SERVICE, 'handleContactUpdateResults',
                    'Failed to update Contact integration status for Contact: ' + contactsToUpdate[i].Id + '. Error: ' + results[i].getErrors(), contactsToUpdate[i].Id);
            }
        }
    }
}