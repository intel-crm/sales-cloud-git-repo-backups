public without sharing class Core_ERPMFlowRouter {
    public class Request {
        @InvocableVariable(required=true)
        public Id contactId;

        @InvocableVariable
        public String priorPhone;

        @InvocableVariable
        public String priorMobilePhone;
    }

    @InvocableMethod(label='Route ERPM Contacts' description='Routes Contacts through the ERPM live or bulk processing path from Flow.')
    public static void routeContacts(List<Request> requests) {
        try {
            Set<Id> contactIds = new Set<Id>();
            Map<Id, Contact> oldContactMap = buildOldContactMap(requests);

            if (requests != null) {
                for (Request request : requests) {
                    if (request != null && request.contactId != null) {
                        contactIds.add(request.contactId);
                    }
                }
            }

            if (contactIds.isEmpty()) {
                return;
            }

            List<Contact> contacts = queryContacts(contactIds);
            if (!contacts.isEmpty()) {
                Core_ContactHandler.erpmProcessFlow(contacts, oldContactMap);
            }
        } catch (Exception ex) {
            UCD_ACM_Logger.error(
                'Core_ERPMFlowRouter',
                'routeContacts',
                'Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString(),
                null
            );
            throw ex;
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }

    @TestVisible
    private static Map<Id, Contact> buildOldContactMap(List<Request> requests) {
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        if (requests == null) {
            return oldContactMap;
        }

        for (Request request : requests) {
            if (request == null || request.contactId == null) {
                continue;
            }

            Contact priorContact = new Contact(Id = request.contactId);
            Boolean hasPriorValue = false;

            if (String.isNotBlank(request.priorPhone)) {
                priorContact.Phone = request.priorPhone;
                hasPriorValue = true;
            }

            if (String.isNotBlank(request.priorMobilePhone)) {
                priorContact.MobilePhone = request.priorMobilePhone;
                hasPriorValue = true;
            }

            if (hasPriorValue) {
                oldContactMap.put(request.contactId, priorContact);
            }
        }

        return oldContactMap;
    }

    @TestVisible
    private static List<Contact> queryContacts(Set<Id> contactIds) {
        return [
            SELECT Id, AccountId, FirstName, LastName, Email, Phone, MobilePhone, Salutation,
                   MailingCountryCode, MailingStateCode,
                   Core_Enterprise_Id__c, Core_eRPM_Person_Id__c,
                   Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,
                   Core_Profession__c, Core_Job_Function_Code__c,
                   Core_Preferred_Language__c, Core_Do_Not_Contact__c,
                   Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact_Dtm__c,
                   Core_Marketing_Do_Not_Contact_Dtm__c,
                   Core_Erpm_Integration_Status__c, Core_ERPM_Integration_Queue_txt__c,
                   Core_IPS_Employee_Customer__c,
                   Account.BillingCountryCode,
                   (SELECT Id, Core_Contact_Id__c, Core_Selected__c,
                           Core_Entitlement_Id__r.Core_IsActive__c,
                           Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,
                           Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c
                    FROM Contact_Entitlements__r),
                   (SELECT Id, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                           PRM_Partner_Subscription_Id__r.Name,
                           PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c
                    FROM Contact_Subscription_Associations__r 
                    WHERE PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c != true),
                   (SELECT Id, Status__c FROM Contact_Business_Types__r
                    WHERE Business_Types__r.Name = :Label.DZP_Business_Type)
            FROM Contact
            WHERE Id IN :contactIds
        ];
    }
}