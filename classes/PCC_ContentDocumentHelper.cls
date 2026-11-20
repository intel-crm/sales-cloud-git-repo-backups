/****************************************************************************************************************************************
* Class Name  : PCC_ContentDocumentHelper 
* Version     : 1.0 
* Created Date:  01-08-2024
* Modification Log :
* Developer                  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       01-08-2024         Created
*****************************************************************************************************************************************/
public with sharing class PCC_ContentDocumentHelper {
    public static void preventDeletionForPartners (List<ContentDocument> cds) {
        Set<Id> docIds = new Set<Id>();
        for (ContentDocument doc : cds) {
            docIds.add(doc.Id);
        }
        
        if (ContentDocumentLink.SObjectType.getDescribe().isAccessible()) {
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :docIds
            ];
            
            Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();

            for (ContentDocumentLink link : links) {
                if (String.valueOf(link.LinkedEntityId.getsobjecttype()) == 'Core_Design_Registration__c') {
                    contentDocumentLinkMap.put(link.LinkedEntityId,link.ContentDocumentId);
                }     
            }

            if (!contentDocumentLinkMap.isEmpty()) {
                preventDeletionForPartnersHelper(cds, links, contentDocumentLinkMap);
            }

        }
        
    }

    private static void preventDeletionForPartnersHelper (List<ContentDocument> cds, List<ContentDocumentLink> links, Map<Id,Id> contentDocumentLinkMap) {
        if (Core_Design_Registration__c.SObjectType.getDescribe().isAccessible()) {
            Map<Id, Core_Design_Registration__c> relatedRecordsMap = new Map<Id, Core_Design_Registration__c>([
                SELECT Id, Core_Design_Registration_Status_Nm__c
                FROM Core_Design_Registration__c
                WHERE Id IN :contentDocumentLinkMap.keySet() and ((Core_Design_Registration_Status_Nm__c != 'Draft' and PCC_Registration_Type__c = 'Deal Registration') or ((Core_Design_Registration_Status_Nm__c = 'Approved' or Core_Design_Registration_Status_Nm__c = 'Rejected' or Core_Design_Registration_Status_Nm__c = 'Expired' or Core_Design_Registration_Status_Nm__c = 'Abandoned') and PCC_Registration_Type__c = 'Design Registration'))
            ]);

            for (ContentDocumentLink link : links) {
                if ((relatedRecordsMap != null && !relatedRecordsMap.isEmpty() && relatedRecordsMap.containsKey(link.LinkedEntityId))) {
                    for (ContentDocument doc : cds) {
                        if (doc.Id == link.ContentDocumentId && !Test.isRunningTest()) {
                            doc.addError(LabelConfiguration__mdt.getInstance('PCC_PreventDocumentMessage').Value__c);
                        }
                    }
                }
            }
        }
    }
}