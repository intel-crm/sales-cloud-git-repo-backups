/**************************************************************************************
Apex Class Name : PMP_TopicAssignmentHelper
Version     : 1.0 
Created Date: 29th April, 2022
Description : Marketplace logic for handler for TopicAssignment
* Modification Log :
* Developer                 Date                     Description 
* ----------------------------------------------------------------------------
* Sathish                  29/04/2022               Original Version
*************************************************************************************/

public With Sharing class PMP_TopicAssignmentHelper {
    public static Boolean isWorking() {
        return true;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static void validateTopicAssignment(List<TopicAssignment> newList) {
        final Map<Id, List<TopicAssignment>> mapEntityIdToTopicAssignment = buildEntityIdToTopicAssignmentMap(newList);
        final Set<Id> companyIds = new Set<Id>();
        final Set<Id> offeringIds = new Set<Id>();
    
        extractEntityAndTopicIds(newList, mapEntityIdToTopicAssignment, companyIds, offeringIds);
    
        Map<Id, PMP_Marketplace_Topic__c> mapMarketplaceTopics = buildMarketplaceTopicsMap();
    
        if (!companyIds.isEmpty() || !offeringIds.isEmpty()) {
            validateTopics(mapMarketplaceTopics, newList);
        }
    
        if (offeringIds.isEmpty()) {
            return;
        }
    
        preventInvalidOfferingAssignment(mapEntityIdToTopicAssignment, mapMarketplaceTopics, offeringIds);
    }
    
    private static Map<Id, List<TopicAssignment>> buildEntityIdToTopicAssignmentMap(List<TopicAssignment> newList) {
        Map<Id, List<TopicAssignment>> mapEntityIdToTopicAssignment = new Map<Id, List<TopicAssignment>>();
    
        for (TopicAssignment topicAssignment : newList) {
            if (mapEntityIdToTopicAssignment.containsKey(topicAssignment.entityId)) {
                mapEntityIdToTopicAssignment.get(topicAssignment.entityId).add(topicAssignment);
            } else {
                mapEntityIdToTopicAssignment.put(topicAssignment.entityId, new List<TopicAssignment>{topicAssignment});
            }
        }
    
        return mapEntityIdToTopicAssignment;
    }
    
    private static void extractEntityAndTopicIds(List<TopicAssignment> newList, Map<Id, List<TopicAssignment>> mapEntityIdToTopicAssignment, Set<Id> companyIds, Set<Id> offeringIds) {
        for (TopicAssignment topicAssignment : newList) {
            final String sobjectType = topicAssignment.entityId.getSObjectType().getDescribe().getName();
            if (sobjectType == 'PMP_Partner_Offering__c') {
                offeringIds.add(topicAssignment.entityId);
            } else if (sobjectType == 'PMP_Company__c') {
                companyIds.add(topicAssignment.entityId);
            }
        }
    }
    
    private static Map<Id, PMP_Marketplace_Topic__c> buildMarketplaceTopicsMap() {
        Map<Id, PMP_Marketplace_Topic__c> mapMarketplaceTopics = new Map<Id, PMP_Marketplace_Topic__c>();
    
        for (PMP_Marketplace_Topic__c topic_mdt : PMP_MarketplaceTopics.getTopicMetadata().values()) {
            mapMarketplaceTopics.put(topic_mdt.PMP_Topic_Id__c, topic_mdt);
        }
    
        return mapMarketplaceTopics;
    }
    
    private static void validateTopics(Map<Id, PMP_Marketplace_Topic__c> mapMarketplaceTopics, List<TopicAssignment> newList) {
        for (TopicAssignment topicAssignment : newList) {
            if (!mapMarketplaceTopics.containsKey(topicAssignment.TopicId)) {
                topicAssignment.addError(System.label.PMP_Valid_Topic_Error);
            }
        }
    }
    
    private static void preventInvalidOfferingAssignment(Map<Id, List<TopicAssignment>> mapEntityIdToTopicAssignment, Map<Id, PMP_Marketplace_Topic__c> mapMarketplaceTopics, Set<Id> offeringIds) {
        List<String> validFeaturedOfferingStatus = PMP_Utility.getValue('PMP_Valid_Featured_Offering_Status').split(';');
        List<String> validEventOfferingStatus = PMP_Utility.getValue('PMP_Valid_Event_Offering_Status').split(';');
    
        for (PMP_Partner_Offering__c offering : [SELECT Id, PMP_Partner_Offering_Lifecycle_Status_Nm__c 
                                                  FROM PMP_Partner_Offering__c WHERE Id IN :offeringIds]) {
            List<TopicAssignment> listTopicAssignments = mapEntityIdToTopicAssignment.get(offering.id);
            
            for (TopicAssignment topicAssign : listTopicAssignments) {
                if (!validFeaturedOfferingStatus.contains(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c) 
                    && mapMarketplaceTopics.containsKey(topicAssign.TopicId) 
                    && mapMarketplaceTopics.get(topicAssign.TopicId).PMP_Topic_Type__c == 'Featured Topic') {
                    topicAssign.addError(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c + ' Offering cannot be assigned to Featured Topic');
                } else if (!validEventOfferingStatus.contains(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c) 
                           && mapMarketplaceTopics.containsKey(topicAssign.TopicId) 
                           && mapMarketplaceTopics.get(topicAssign.TopicId).PMP_Topic_Type__c == 'Event Topic') {
                    topicAssign.addError(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c + ' Offering cannot be assigned to Event Topic');
                }
            }
        }
    }
    
    
    
    
    public static void autoAssignTopics(Map<Id, TopicAssignment> newMap, Boolean syncEvents) {
        Map<Id, List<TopicAssignment>> mapInsertedCompanyTopicAssignment = new Map<Id, List<TopicAssignment>>();
        Map<Id, List<TopicAssignment>> mapInsertedOfferingTopicAssignment = new Map<Id, List<TopicAssignment>>();
        Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment = new Map<Id, Set<Id>>();
    
        createAssignmentMaps(newMap, mapInsertedCompanyTopicAssignment, mapInsertedOfferingTopicAssignment);
        Map<Id, Set<Id>> mapRelatedEntityTopicAssignment = processCompanyRecords(mapInsertedCompanyTopicAssignment, mapEventPublishedCompanyToTopicAssignment);
        mapRelatedEntityTopicAssignment.putAll(processOfferingRecords(mapInsertedOfferingTopicAssignment, mapEventPublishedOfferingToTopicAssignment));
    
        insertTopicAssignments(mapRelatedEntityTopicAssignment, newMap.values());
    
        if (syncEvents) {
            syncTopicAssignmentsToEvents(mapEventPublishedCompanyToTopicAssignment, mapEventPublishedOfferingToTopicAssignment, newMap.values());
        }
    }
    
    private static void createAssignmentMaps(Map<Id, TopicAssignment> newMap, Map<Id, List<TopicAssignment>> mapInsertedCompanyTopicAssignment, Map<Id, List<TopicAssignment>> mapInsertedOfferingTopicAssignment) {
        for (TopicAssignment topicAssignment : newMap.values()) {
            if (topicAssignment.entityId.getSObjectType() == PMP_Company__c.sObjectType) {
                addToAssignmentMap(mapInsertedCompanyTopicAssignment, topicAssignment);
            } else if (topicAssignment.entityId.getSObjectType() == PMP_Partner_Offering__c.sObjectType) {
                addToAssignmentMap(mapInsertedOfferingTopicAssignment, topicAssignment);
            }
        }
    }
    
    private static void addToAssignmentMap(Map<Id, List<TopicAssignment>> assignmentMap, TopicAssignment topicAssignment) {
        Id entityId = topicAssignment.entityId;
        if (!assignmentMap.containsKey(entityId)) {
            assignmentMap.put(entityId, new List<TopicAssignment>{topicAssignment});
        } else {
            assignmentMap.get(entityId).add(topicAssignment);
        }
    }
    
    private static Map<Id, Set<Id>> processCompanyRecords(Map<Id, List<TopicAssignment>> mapInsertedCompanyTopicAssignment, Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment) {
        Map<Id, Set<Id>> mapRelatedEntityTopicAssignment = new Map<Id, Set<Id>>();
    
        for (PMP_Company__c company : [SELECT Id, PMP_Published_Copy_Id__c, PMP_Working_Copy_Id__c, PMP_Is_Working_Copy_Ind__c, PMP_Is_Published_Ind__c FROM PMP_Company__c WHERE Id IN :mapInsertedCompanyTopicAssignment.keySet()]) {
            processCompany(company, mapInsertedCompanyTopicAssignment, mapRelatedEntityTopicAssignment, mapEventPublishedCompanyToTopicAssignment);
        }
    
        return mapRelatedEntityTopicAssignment;
    }
    
    private static void processCompany(PMP_Company__c company, Map<Id, List<TopicAssignment>> mapInsertedCompanyTopicAssignment, Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment) {
        List<TopicAssignment> linkedTopicAssignments = mapInsertedCompanyTopicAssignment.get(company.Id);
        for (TopicAssignment linkedTopicAssignment : linkedTopicAssignments) {
            if (company.PMP_Is_Working_Copy_Ind__c && company.PMP_Published_Copy_Id__c != null && linkedTopicAssignment != null) {
                addRelatedTopicAssignment(mapRelatedEntityTopicAssignment, company.PMP_Published_Copy_Id__c, linkedTopicAssignment);
            } else if (company.PMP_Is_Published_Ind__c && company.PMP_Working_Copy_Id__c != null && linkedTopicAssignment != null) {
                addRelatedTopicAssignment(mapRelatedEntityTopicAssignment, company.PMP_Working_Copy_Id__c, linkedTopicAssignment);
                addEventPublishedTopicAssignment(mapEventPublishedCompanyToTopicAssignment, company.Id, linkedTopicAssignment);
            }
        }
    }
    
    private static Map<Id, Set<Id>> processOfferingRecords(Map<Id, List<TopicAssignment>> mapInsertedOfferingTopicAssignment, Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment) {
        Map<Id, Set<Id>> mapRelatedEntityTopicAssignment = new Map<Id, Set<Id>>();
    
        for (PMP_Partner_Offering__c offering : [SELECT Id, PMP_Published_Copy_Id_Txt__c, PMP_Working_Copy_Id__c FROM PMP_Partner_Offering__c WHERE Id IN :mapInsertedOfferingTopicAssignment.keySet()]) {
            processOffering(offering, mapInsertedOfferingTopicAssignment, mapRelatedEntityTopicAssignment, mapEventPublishedOfferingToTopicAssignment);
        }
    
        return mapRelatedEntityTopicAssignment;
    }
    
    private static void processOffering(PMP_Partner_Offering__c offering, Map<Id, List<TopicAssignment>> mapInsertedOfferingTopicAssignment, Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment) {
        List<TopicAssignment> linkedTopicAssignments = mapInsertedOfferingTopicAssignment.get(offering.Id);
        for (TopicAssignment linkedTopicAssignment : linkedTopicAssignments) {
            if (offering.PMP_Working_Copy_Id__c != null && linkedTopicAssignment != null) {
                addRelatedTopicAssignment(mapRelatedEntityTopicAssignment, offering.PMP_Working_Copy_Id__c, linkedTopicAssignment);
                addEventPublishedTopicAssignment(mapEventPublishedOfferingToTopicAssignment, offering.Id, linkedTopicAssignment);
            } else if (offering.PMP_Working_Copy_Id__c == null && offering.PMP_Published_Copy_Id_Txt__c != null && linkedTopicAssignment != null) {
                addRelatedTopicAssignment(mapRelatedEntityTopicAssignment, offering.PMP_Published_Copy_Id_Txt__c, linkedTopicAssignment);
            }
        }
    }
    
    private static void addRelatedTopicAssignment(Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, Id entityId, TopicAssignment linkedTopicAssignment) {
        if (!mapRelatedEntityTopicAssignment.containsKey(entityId)) {
            mapRelatedEntityTopicAssignment.put(entityId, new Set<Id>{linkedTopicAssignment.TopicId});
        } else {
            mapRelatedEntityTopicAssignment.get(entityId).add(linkedTopicAssignment.TopicId);
        }
    }
    
    private static void addEventPublishedTopicAssignment(Map<Id, Set<Id>> mapEventPublishedToTopicAssignment, Id entityId, TopicAssignment linkedTopicAssignment) {
        if (!mapEventPublishedToTopicAssignment.containsKey(entityId)) {
            mapEventPublishedToTopicAssignment.put(entityId, new Set<Id>{linkedTopicAssignment.TopicId});
        } else {
            mapEventPublishedToTopicAssignment.get(entityId).add(linkedTopicAssignment.TopicId);
        }
    }
    
    private static void insertTopicAssignments(Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, List<TopicAssignment> newMapValues) {
        Set<Id> allTopicIds = new Set<Id>();
        for (Set<Id> topicIds : mapRelatedEntityTopicAssignment.values()) {
            allTopicIds.addAll(topicIds);
        }
    
        Map<String, TopicAssignment> existingTopicAssignment = new Map<String, TopicAssignment>();
        for (TopicAssignment topicAssgn : [SELECT Id, EntityId, TopicId FROM TopicAssignment WHERE EntityId IN :mapRelatedEntityTopicAssignment.keySet() AND TopicId IN :allTopicIds]) {
            existingTopicAssignment.put(topicAssgn.EntityId + '' + topicAssgn.TopicId, topicAssgn);
        }
    
        List<TopicAssignment> topicsAssignmentsToBeInserted = new List<TopicAssignment>();
        for (Id entityId : mapRelatedEntityTopicAssignment.keySet()) {
            Set<Id> toBeInsertedTopicIds = mapRelatedEntityTopicAssignment.get(entityId);
            for (Id topicId : toBeInsertedTopicIds) {
                if (!existingTopicAssignment.containsKey(entityId + '' + topicId)) {
                    TopicAssignment topicAssignment = new TopicAssignment();
                    topicAssignment.EntityId = entityId;
                    topicAssignment.TopicId = topicId;
                    topicsAssignmentsToBeInserted.add(topicAssignment);
                }
            }
        }
    
        if (!topicsAssignmentsToBeInserted.isEmpty()) {
            try {
                insert topicsAssignmentsToBeInserted;
            } catch (DmlException e) {
                handleException('PMP_TopicAssignmentHelper.autoAssignTopics', e, newMapValues);
            }
        }
    }
    
    
    
    
    public static void autoRemoveTopicAssignment(Map<Id, TopicAssignment> oldMap, Boolean syncEvents) {
        Map<Id, List<TopicAssignment>> mapDeletedCompanyTopicAssignment = new Map<Id, List<TopicAssignment>>();
        Map<Id, List<TopicAssignment>> mapDeletedOfferingTopicAssignment = new Map<Id, List<TopicAssignment>>();
        Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment = new Map<Id, Set<Id>>();
    
        createDeletedAssignmentMaps(oldMap, mapDeletedCompanyTopicAssignment, mapDeletedOfferingTopicAssignment);
        Map<Id, Set<Id>> mapRelatedEntityTopicAssignment = processDeletedCompanyRecords(mapDeletedCompanyTopicAssignment, mapEventPublishedCompanyToTopicAssignment);
        mapRelatedEntityTopicAssignment.putAll(processDeletedOfferingRecords(mapDeletedOfferingTopicAssignment, mapEventPublishedOfferingToTopicAssignment));
    
        deleteTopicAssignments(mapRelatedEntityTopicAssignment, oldMap.values());
    
        if (syncEvents && !mapRelatedEntityTopicAssignment.isEmpty()) {
            autoRemoveTopicAssignmentsOnEvent(mapEventPublishedCompanyToTopicAssignment, mapEventPublishedOfferingToTopicAssignment, oldMap.values());
        }
    }
    
    private static void createDeletedAssignmentMaps(Map<Id, TopicAssignment> oldMap, Map<Id, List<TopicAssignment>> mapDeletedCompanyTopicAssignment, Map<Id, List<TopicAssignment>> mapDeletedOfferingTopicAssignment) {
        for (TopicAssignment topicAssignment : oldMap.values()) {
            String sobjectType = topicAssignment.entityId.getSObjectType().getDescribe().getName();
            if (sobjectType == 'PMP_Company__c') {
                addToDeletedAssignmentMap(mapDeletedCompanyTopicAssignment, topicAssignment);
            } else if (sobjectType == 'PMP_Partner_Offering__c') {
                addToDeletedAssignmentMap(mapDeletedOfferingTopicAssignment, topicAssignment);
            }
        }
    }
    
    private static void addToDeletedAssignmentMap(Map<Id, List<TopicAssignment>> assignmentMap, TopicAssignment topicAssignment) {
        Id entityId = topicAssignment.entityId;
        if (!assignmentMap.containsKey(entityId)) {
            assignmentMap.put(entityId, new List<TopicAssignment>{topicAssignment});
        } else {
            assignmentMap.get(entityId).add(topicAssignment);
        }
    }
    
    private static Map<Id, Set<Id>> processDeletedCompanyRecords(Map<Id, List<TopicAssignment>> mapDeletedCompanyTopicAssignment, Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment) {
        Map<Id, Set<Id>> mapRelatedEntityTopicAssignment = new Map<Id, Set<Id>>();
        for (PMP_Company__c company : [SELECT Id, PMP_Published_Copy_Id__c, PMP_Working_Copy_Id__c, PMP_Is_Working_Copy_Ind__c, PMP_Is_Published_Ind__c FROM PMP_Company__c WHERE Id IN :mapDeletedCompanyTopicAssignment.keySet()]) {
            List<TopicAssignment> linkedTopicAssignments = mapDeletedCompanyTopicAssignment.get(company.Id);
            for (TopicAssignment linkedTopicAssignment : linkedTopicAssignments) {
                processCompanyTopicAssignment(company, linkedTopicAssignment, mapRelatedEntityTopicAssignment, mapEventPublishedCompanyToTopicAssignment);
            }
        }
        return mapRelatedEntityTopicAssignment;
    }
    
    private static void processCompanyTopicAssignment(PMP_Company__c company, TopicAssignment linkedTopicAssignment, Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment) {
        if (company.PMP_Is_Working_Copy_Ind__c && company.PMP_Published_Copy_Id__c != null && linkedTopicAssignment != null) {
            addToRelatedEntityTopicAssignmentMap(mapRelatedEntityTopicAssignment, company.PMP_Published_Copy_Id__c, linkedTopicAssignment.TopicId);
        } else if (company.PMP_Is_Published_Ind__c && company.PMP_Working_Copy_Id__c != null && linkedTopicAssignment != null) {
            addToRelatedEntityTopicAssignmentMap(mapRelatedEntityTopicAssignment, company.PMP_Working_Copy_Id__c, linkedTopicAssignment.TopicId);
            addToEventPublishedMap(mapEventPublishedCompanyToTopicAssignment, company.Id, linkedTopicAssignment.TopicId);
        }
    }
    
    private static void addToRelatedEntityTopicAssignmentMap(Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, Id entityId, Id topicId) {
        if (!mapRelatedEntityTopicAssignment.containsKey(entityId)) {
            mapRelatedEntityTopicAssignment.put(entityId, new Set<Id>{topicId});
        } else {
            mapRelatedEntityTopicAssignment.get(entityId).add(topicId);
        }
    }
    
    private static void addToEventPublishedMap(Map<Id, Set<Id>> eventPublishedMap, Id entityId, Id topicId) {
        if (!eventPublishedMap.containsKey(entityId)) {
            eventPublishedMap.put(entityId, new Set<Id>{topicId});
        } else {
            eventPublishedMap.get(entityId).add(topicId);
        }
    }
    
    private static Map<Id, Set<Id>> processDeletedOfferingRecords(Map<Id, List<TopicAssignment>> mapDeletedOfferingTopicAssignment, Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment) {
        Map<Id, Set<Id>> mapRelatedEntityTopicAssignment = new Map<Id, Set<Id>>();
        for (PMP_Partner_Offering__c offering : [SELECT Id, PMP_Published_Copy_Id_Txt__c, PMP_Working_Copy_Id__c FROM PMP_Partner_Offering__c WHERE Id IN :mapDeletedOfferingTopicAssignment.keySet()]) {
            List<TopicAssignment> linkedTopicAssignments = mapDeletedOfferingTopicAssignment.get(offering.Id);
            for (TopicAssignment linkedTopicAssignment : linkedTopicAssignments) {
                processOfferingTopicAssignment(offering, linkedTopicAssignment, mapRelatedEntityTopicAssignment, mapEventPublishedOfferingToTopicAssignment);
            }
        }
        return mapRelatedEntityTopicAssignment;
    }
    
    private static void processOfferingTopicAssignment(PMP_Partner_Offering__c offering, TopicAssignment linkedTopicAssignment, Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment) {
        if (offering.PMP_Working_Copy_Id__c != null && linkedTopicAssignment != null) {
            addToRelatedEntityTopicAssignmentMap(mapRelatedEntityTopicAssignment, offering.PMP_Working_Copy_Id__c, linkedTopicAssignment.TopicId);
            addToEventPublishedMap(mapEventPublishedOfferingToTopicAssignment, offering.Id, linkedTopicAssignment.TopicId);
        } else if (offering.PMP_Working_Copy_Id__c == null && offering.PMP_Published_Copy_Id_Txt__c != null && linkedTopicAssignment != null) {
            addToRelatedEntityTopicAssignmentMap(mapRelatedEntityTopicAssignment, offering.PMP_Published_Copy_Id_Txt__c, linkedTopicAssignment.TopicId);
        }
    }
    
    private static void deleteTopicAssignments(Map<Id, Set<Id>> mapRelatedEntityTopicAssignment, List<TopicAssignment> oldMapValues) {
        List<TopicAssignment> topicsAssignmentsToBeDeleted = new List<TopicAssignment>();
        Set<Id> allTopicsIds = new Set<Id>();
        for (Set<Id> topicIds : mapRelatedEntityTopicAssignment.values()) {
            allTopicsIds.addAll(topicIds);
        }
        if (!mapRelatedEntityTopicAssignment.isEmpty()) {
            for (TopicAssignment topicAssignment : [SELECT Id, EntityId, TopicId FROM TopicAssignment WHERE EntityId IN :mapRelatedEntityTopicAssignment.keySet() AND TopicId IN :allTopicsIds]) {
                Set<Id> toBeDeletedTopicIds = mapRelatedEntityTopicAssignment.get(topicAssignment.EntityId);
                if (toBeDeletedTopicIds != null && toBeDeletedTopicIds.contains(topicAssignment.TopicId)) {
                    topicsAssignmentsToBeDeleted.add(topicAssignment);
                }
            }
    
            try {
                delete topicsAssignmentsToBeDeleted;
            } catch (DmlException e) {
                handleException('PMP_TopicAssignmentHelper.autoRemoveTopicAssignment', e, oldMapValues);
            }
        }
    }
    
    
    
    public static void syncTopicAssignmentsToEvents(Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment, Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment, List<TopicAssignment> errorRecords) {
        Map<Id, PMP_Marketplace_Topic__c> mapTopicToEventId = PMP_MarketplaceTopics.getAllEventTopicsMetadata();
    
        List<PMP_Marketplace_Event_Offering__c> listEventOffering = createEventOfferings(mapEventPublishedOfferingToTopicAssignment, mapTopicToEventId);
        List<PMP_Marketplace_Event_Partner__c> listEventPartner = createEventPartners(mapEventPublishedCompanyToTopicAssignment, mapTopicToEventId);
    
        insertEventOfferings(listEventOffering, errorRecords);
        insertEventPartners(listEventPartner, errorRecords);
    }
    
    private static List<PMP_Marketplace_Event_Offering__c> createEventOfferings(Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment, Map<Id, PMP_Marketplace_Topic__c> mapTopicToEventId) {
        List<PMP_Marketplace_Event_Offering__c> listEventOffering = new List<PMP_Marketplace_Event_Offering__c>();
        for (Id offeringId : mapEventPublishedOfferingToTopicAssignment.keySet()) {
            for (Id topicId : mapEventPublishedOfferingToTopicAssignment.get(offeringId)) {
                if (mapTopicToEventId.containsKey(topicId)) {
                    PMP_Marketplace_Event_Offering__c eventOffering = new PMP_Marketplace_Event_Offering__c();
                    eventOffering.PMP_Event_Id__c = mapTopicToEventId.get(topicId).PMP_Marketplace_Event_Id__c;
                    eventOffering.PMP_Offering_Id__c = offeringId;
                    listEventOffering.add(eventOffering);
                }
            }
        }
        return listEventOffering;
    }
    
    private static List<PMP_Marketplace_Event_Partner__c> createEventPartners(Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment, Map<Id, PMP_Marketplace_Topic__c> mapTopicToEventId) {
        List<PMP_Marketplace_Event_Partner__c> listEventPartner = new List<PMP_Marketplace_Event_Partner__c>();
        for (Id companyId : mapEventPublishedCompanyToTopicAssignment.keySet()) {
            for (Id topicId : mapEventPublishedCompanyToTopicAssignment.get(companyId)) {
                if (mapTopicToEventId.containsKey(topicId)) {
                    PMP_Marketplace_Event_Partner__c eventPartner = new PMP_Marketplace_Event_Partner__c();
                    eventPartner.PMP_Event_Id__c = mapTopicToEventId.get(topicId).PMP_Marketplace_Event_Id__c;
                    eventPartner.PMP_Company_Id__c = companyId;
                    listEventPartner.add(eventPartner);
                }
            }
        }
        return listEventPartner;
    }
    
    private static void insertEventOfferings(List<PMP_Marketplace_Event_Offering__c> listEventOffering, List<TopicAssignment> errorRecords) {
        if (!listEventOffering.isEmpty()) {
            try {
                insert listEventOffering;
            } catch (DmlException e) {
                handleException('PMP_TopicAssignmentHelper.insertEventOffering', e, errorRecords);
            }
        }
    }
    
    private static void insertEventPartners(List<PMP_Marketplace_Event_Partner__c> listEventPartner, List<TopicAssignment> errorRecords) {
        if (!listEventPartner.isEmpty()) {
            try {
                insert listEventPartner;
            } catch (DmlException e) {
                handleException('PMP_TopicAssignmentHelper.insertEventPartner', e, errorRecords);
            }
        }
    }
    
    
    
    public static void autoRemoveTopicAssignmentsOnEvent(Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment, Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment, List<TopicAssignment> errorRecords) {
        Map<Id, PMP_Marketplace_Topic__c> mapTopicToEventId = PMP_MarketplaceTopics.getAllEventTopicsMetadata();    
    
        Set<Id> listCompanyEventIds = new Set<Id>();
        Set<Id> listCompanyIds = new Set<Id>();
        findCompanyEvents(mapEventPublishedCompanyToTopicAssignment, mapTopicToEventId, listCompanyEventIds, listCompanyIds);
    
        Set<Id> listOfferingEventIds = new Set<Id>();
        Set<Id> listOfferingIds = new Set<Id>();
        findOfferingEvents(mapEventPublishedOfferingToTopicAssignment, mapTopicToEventId, listOfferingEventIds, listOfferingIds);
    
        deleteEventPartners(listCompanyIds, listCompanyEventIds, errorRecords);
        deleteEventOfferings(listOfferingIds, listOfferingEventIds, errorRecords);
    }
    
    private static void findCompanyEvents(Map<Id, Set<Id>> mapEventPublishedCompanyToTopicAssignment, Map<Id, PMP_Marketplace_Topic__c> mapTopicToEventId, Set<Id> listCompanyEventIds, Set<Id> listCompanyIds) {
        for (Id companyId : mapEventPublishedCompanyToTopicAssignment.keySet()) {
            for (Id topicId : mapEventPublishedCompanyToTopicAssignment.get(companyId)) {
                if (mapTopicToEventId.containsKey(topicId)) {
                    PMP_Marketplace_Topic__c topic = mapTopicToEventId.get(topicId);
                    listCompanyEventIds.add(topic.PMP_Marketplace_Event_Id__c);
                    listCompanyIds.add(companyId);
                }
            }
        }
    }
    
    private static void findOfferingEvents(Map<Id, Set<Id>> mapEventPublishedOfferingToTopicAssignment, Map<Id, PMP_Marketplace_Topic__c> mapTopicToEventId, Set<Id> listOfferingEventIds, Set<Id> listOfferingIds) {
        for (Id offeringId : mapEventPublishedOfferingToTopicAssignment.keySet()) {
            for (Id topicId : mapEventPublishedOfferingToTopicAssignment.get(offeringId)) {
                if (mapTopicToEventId.containsKey(topicId)) {
                    PMP_Marketplace_Topic__c topic = mapTopicToEventId.get(topicId);
                    listOfferingEventIds.add(topic.PMP_Marketplace_Event_Id__c);
                    listOfferingIds.add(offeringId);
                }
            }
        }
    }
    
    private static void deleteEventPartners(Set<Id> listCompanyIds, Set<Id> listCompanyEventIds, List<TopicAssignment> errorRecords) {
        List<PMP_Marketplace_Event_Partner__c> eventMpiToBeDeleted = new List<PMP_Marketplace_Event_Partner__c>();
        if (!listCompanyIds.isEmpty()) {
            eventMpiToBeDeleted = [SELECT Id FROM PMP_Marketplace_Event_Partner__c WHERE PMP_Event_Id__c IN :listCompanyEventIds AND PMP_Company_Id__c IN :listCompanyIds];
        }
    
        if (!eventMpiToBeDeleted.isEmpty()) {
            try {
                delete eventMpiToBeDeleted;
            } catch (DmlException e) {
                handleException('PMP_TopicAssignmentHelper.deleteEventPartner', e, errorRecords);
            }
        }
    }
    
    private static void deleteEventOfferings(Set<Id> listOfferingIds, Set<Id> listOfferingEventIds, List<TopicAssignment> errorRecords) {
        List<PMP_Marketplace_Event_Offering__c> eventOfferingsToBeDeleted = new List<PMP_Marketplace_Event_Offering__c>();
        if (!listOfferingIds.isEmpty()) {
            eventOfferingsToBeDeleted = [SELECT Id FROM PMP_Marketplace_Event_Offering__c WHERE PMP_Event_Id__c IN :listOfferingEventIds AND PMP_Offering_Id__c IN :listOfferingIds];
        }
    
        if (!eventOfferingsToBeDeleted.isEmpty()) {
            try {
                delete eventOfferingsToBeDeleted;
            } catch (DmlException e) {
                handleException('PMP_TopicAssignmentHelper.deleteEventOffering', e, errorRecords);
            }
        }
    }
    
    
    public static void handleException(String message,DmlException e,List<SObject> errorRecords ){
        //System.debug(e);
        PMP_Utility.logError(e, message);
        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            
            for(Sobject record : errorRecords){
                record.addError(e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(':'));
            }
        }else if(e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
            for(Sobject record : errorRecords){
                record.addError(e.getMessage().substringAfter('FIELD_FILTER_VALIDATION_EXCEPTION,').substringBefore(':'));
            }
        }else{
            throw e;
        }
    }
    
    public static void syncTopicCountToOffAndPartner(List<TopicAssignment> topicAssignmentList){
        //system.debug('Inside Trigger');
        Set<Id> topicEntityIds = new Set<Id>();
        Map<Id,Integer> offTopicMap = new Map<Id,Integer>();
        Map<Id,Integer> partnerTopicMap = new Map<Id,Integer>();
        List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        
        for(TopicAssignment ta: topicAssignmentList){
            if(ta.EntityType=='PMP_Partner_Offering'){
                offTopicMap.put(ta.EntityId,0);
               		
            }else if(ta.EntityType=='PMP_Company'){
                partnerTopicMap.put(ta.EntityId,0);
            }
                topicEntityIds.add(ta.EntityId);
           
        }
        
        for(TopicAssignment topic:[select id, TopicId, EntityId, EntityType from TopicAssignment where EntityId IN:topicEntityIds]){
            //Topic Count on Offering            
            if(topic.EntityType=='PMP_Partner_Offering'){
                offTopicMap.put(topic.EntityId,offTopicMap.get(topic.EntityId)+1);
                
            }
           // Topic Count on Company
            if(topic.EntityType=='PMP_Company'){
            	partnerTopicMap.put(topic.EntityId,partnerTopicMap.get(topic.EntityId)+1);
            }
            
        }
      
        for(Id offEntityId :offTopicMap.keySet()){
            PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
            off.Id = offEntityId;
            off.PMP_Topic_Count__c = offTopicMap.get(offEntityId);
            offeringList.add(off);       
        } 
        
        for(Id partEntityId :partnerTopicMap.keySet()){
            PMP_Company__c partner = new PMP_Company__c();
            partner.Id = partEntityId;
            partner.PMP_Topic_Count__c = partnerTopicMap.get(partEntityId);
            partnerList.add(partner);
        } 
        
		update offeringList;
		update partnerList;
        
    }*/

}