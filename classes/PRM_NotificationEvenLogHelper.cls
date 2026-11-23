@SuppressWarnings('PMD')
public with sharing class PRM_NotificationEvenLogHelper {
    public static final String EVENT_TYPE_PRIME_NAME_UPDATE = 'Prime Name Update';
    public static final String EVENT_TYPE_LOCATION_ADD = 'Location account association';
    public static final String EVENT_TYPE_LOCATION_REMOVAL = 'Location account removal';
    public static final String STATUS_IGNORED = 'Ignored';
    public static final String STATUS_NOTIFICATION_SENT = 'Notification Sent';


    public static List<PRM_Notification_Event_Log__c> getNotificationLogs(List<PRM_Notification_Event_Log__c> inputList) {
        List<PRM_Notification_Event_Log__c> filteredLogs = new List<PRM_Notification_Event_Log__c>();
        Set<Id> opids = new Set<Id>();
        Set<String> locationOPIDSet = new Set<String>();

        for (PRM_Notification_Event_Log__c eventLog : inputList) {
            if (eventLog.PRM_Event_Type__c == EVENT_TYPE_PRIME_NAME_UPDATE && !opids.contains(eventLog.PRM_One_Partner_Id__c)) {
                opids.add(eventLog.PRM_One_Partner_Id__c);
                eventLog.PRM_Status__c = STATUS_NOTIFICATION_SENT;
                filteredLogs.add(eventLog);
            }
            else if ((eventLog.PRM_Event_Type__c == EVENT_TYPE_LOCATION_ADD ||
                eventLog.PRM_Event_Type__c == EVENT_TYPE_LOCATION_REMOVAL) && !locationOPIDSet.contains(String.valueOf(eventLog.PRM_One_Partner_Id__c)+String.valueOf(eventLog.PRM_Intel_Account__c))) {
                locationOPIDSet.add(String.valueOf(eventLog.PRM_One_Partner_Id__c)+String.valueOf(eventLog.PRM_Intel_Account__c));
                eventLog.PRM_Status__c = STATUS_NOTIFICATION_SENT;
                filteredLogs.add(eventLog);
            }
            else {
                eventLog.PRM_Status__c = STATUS_IGNORED;
            }
        }

        update inputList;

        return filteredLogs;
    }

    public static Map<Id,List<PRM_Notification_Event_Log__c>> getUserNotificationList(List<PRM_Notification_Event_Log__c> inputList) {
        Set<Id> opids = new Set<Id>();
        Set<Id> locationids = new Set<Id>();
        Map<Id,Set<Id>> opidLocationMap = new Map<Id,Set<Id>>(); // Map of OPID and associated location accounts
        Map<Id,Set<Id>> locationPartnerAdminMap = new Map<Id,Set<Id>>(); // Map of location if and related partner admins
        Map<Id,List<PRM_Notification_Event_Log__c>> logMap = new Map<Id,List<PRM_Notification_Event_Log__c>>(); // Map of PA/PAD Id and related event logs to be sent

        for (PRM_Notification_Event_Log__c eventLog : inputList) {
            opids.add(eventLog.PRM_One_Partner_Id__c);
            if (eventLog.PRM_Event_Type__c == EVENT_TYPE_LOCATION_REMOVAL){
                locationids.add(eventLog.PRM_Intel_Account__c);
            }
        }

        if (!opids.isEmpty()) {
            // To get all the location accounts under the OPID
            for (Core_Account_Group_Member__c  cagm : [SELECT Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c IN:opids AND Core_Inactive_Ind__c = false ]){
                locationids.add(cagm.Core_Intel_Account_Id__c);
                if (!opidLocationMap.containsKey(cagm.Core_Partner_Account_Id__c)) {
                    opidLocationMap.put(cagm.Core_Partner_Account_Id__c, new Set<Id>());
                }
                opidLocationMap.get(cagm.Core_Partner_Account_Id__c).add(cagm.Core_Intel_Account_Id__c);
            }

        }

        if (!locationids.isEmpty()) {
            // To get all partner admins and partner admin delegates under the location account
            for (PRM_Account_Contact_Relationship__c acr : [SELECT Id,PRM_Account_Id__c,PRM_Contact_Id__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Account_Id__c IN:locationids AND PRM_InActive_Ind__c = false AND PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c IN ('PRIMARY','PRIMCONTDEL')]) {
                if (!locationPartnerAdminMap.containsKey(acr.PRM_Account_Id__c)) {
                    locationPartnerAdminMap.put(acr.PRM_Account_Id__c, new Set<Id>());
                }
                locationPartnerAdminMap.get(acr.PRM_Account_Id__c).add(acr.PRM_Contact_Id__c);
            }
        }

        for (PRM_Notification_Event_Log__c eventLog : inputList) {
            Set<Id> contactIds = new Set<Id>();

            // To fetch all the PA/PADS of all the location accounts under the OPID
            if (opidLocationMap.containsKey(eventLog.PRM_One_Partner_Id__c)) {
                for (Id locationId : opidLocationMap.get(eventLog.PRM_One_Partner_Id__c)) {
                    if (locationPartnerAdminMap.containsKey(locationId)) {
                            contactIds.addAll(locationPartnerAdminMap.get(locationId));
                    }
                }
            }

            // To get PA/PAD of the location account removed from OPID
            if (eventLog.PRM_Event_Type__c == EVENT_TYPE_LOCATION_REMOVAL){
                    if (locationPartnerAdminMap.containsKey(eventLog.PRM_Intel_Account__c)) {
                        contactIds.addAll(locationPartnerAdminMap.get(eventLog.PRM_Intel_Account__c));
                    }
            }

            for (Id conId : contactIds) {
                if (!logMap.containsKey(conId)) {
                    logMap.put(conId, new List<PRM_Notification_Event_Log__c>());
                }
                logMap.get(conId).add(eventLog);
            }
        }

        return logMap;
    }

    public static void sendEmailToPartnerAdmins (Map<Id,List<PRM_Notification_Event_Log__c>> logMap) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id,Email,FirstName,LastName FROM Contact WHERE ID IN: logMap.keySet()]);
        Map<Id,PRM_EmailLog__c> emailLogMap = new Map<Id,PRM_EmailLog__c>();
        
        //EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'PARTNER_NOTIFICATION_POC'];
        //String htmlBody = emailTemplate.HtmlValue;
        for (Id contactId: logMap.keySet()) {
            Contact c = conMap.get(contactId);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String subject = 'Partner admin notification';
			String body = 'Hi '+c.FirstName+' '+c.LastName+'<br><br>Below are the key changes<br><br>';

            //Put it in table format
            //Replace body with content email template

            body += '<table cellpadding="1.5" border="1"><tr><th>Event Type</th></th><th>Value</th><th>OPID</th><th>Location Account</th></tr>';

			for(PRM_Notification_Event_Log__c eventLog :logMap.get(contactId)) {
				/*if (eventLog.PRM_Event_Type__c == EVENT_TYPE_PRIME_NAME_UPDATE) {
                    body+= '<br>Prime name of <b>'+eventLog.PRM_One_Partner_Id__r.Name+' </b>changed to <b>'+eventLog.PRM_Event_Action_Value__c+'</b>';
                }
                else if (eventLog.PRM_Event_Type__c == EVENT_TYPE_LOCATION_ADD){
                    body+= '<br>Location account <b>'+eventLog.PRM_Intel_Account__r.Name+' </b>added to <b>'+eventLog.PRM_One_Partner_Id__r.Name+'</b>';
                }
                else if (eventLog.PRM_Event_Type__c == EVENT_TYPE_LOCATION_REMOVAL){
                    body+= '<br>Location account <b>'+eventLog.PRM_Intel_Account__r.Name+' </b>removed from <b>'+eventLog.PRM_One_Partner_Id__r.Name+'</b>';
                }*/
                String eventValue = String.isBlank(eventLog.PRM_Event_Action_Value__c) ? '' : eventLog.PRM_Event_Action_Value__c;

                body += '<tr><td>'+eventLog.PRM_Event_Type__c+'</td><td>'+eventValue+'</td><td>'+eventLog.PRM_One_Partner_Id__r.Name+'</td><td>'+eventLog.PRM_Intel_Account__r.Name+'</td></tr>';
			}
            body += '</tr></table>';

            //htmlBody = htmlBody.replace('{!body}', body);
			email.setSubject(subject);
			//email.setToAddresses(new String [] {c.Email});
            email.setToAddresses(new String [] {'aravind.b.r@intel.com'});
            email.setHtmlBody(body);
            //email.setTargetObjectId(contactId);
            mailList.add(email);
            emailLogMap.put(contactId,returnEmailLogIntance(contactId,subject,body,true,''));
        }

        if (!mailList.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailList);

            for (Messaging.SendEmailResult result : results) {
                if(!result.isSuccess()){
                    /*Id contactId = result.getErrors()[0].getTargetObjectId();
                    String message = result.getErrors()[0].getMessage();
                    if (emailLogMap.containsKey(contactId)) {
                        emailLogMap.get(contactId).PRM_EmailDeliverabilityStatus__c = false;
                        emailLogMap.get(contactId).PRM_Email_API_Response__c = message;
                    }*/
                }
            }
        }

        if (!emailLogMap.isEmpty()) {
            insert emailLogMap.values();
        }
    }

    public static PRM_EmailLog__c returnEmailLogIntance(Id contactId, String subject, String body, Boolean isDelivered, String message) {
        PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
        emailLog.PRM_Contact__c = contactId;
        emailLog.PRM_Subject__c = subject;
        emailLog.PRM_EmailContent__c =  body;
        emailLog.PRM_EmailHTMLContent__c = body;
        emailLog.PRM_EmailDeliverabilityStatus__c = isDelivered;
        emailLog.PRM_Email_API_Response__c = message ;
        return emailLog;
    }

}