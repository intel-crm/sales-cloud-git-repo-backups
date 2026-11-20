public with sharing class PMP_MarketplaceTopics { 
    public static Boolean isWorking() {
        return true;
    }

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static map<Id,PMP_Marketplace_Topic__c> getTopicMetadata(){
        
            Map<Id,PMP_Marketplace_Topic__c> mapTopicIdToTopicMdt = new Map<Id,PMP_Marketplace_Topic__c>();
            // Get the translations for the topics
            for(PMP_Marketplace_Topic__c topic_mdt :[SELECT PMP_Topic_Id__c,PMP_Marketplace_Topic_Name__c,PMP_Topic_Type__c,PMP_Marketplace_Event_Id__c,
                                                        PMP_Topic_Chinese_Nm__c,PMP_Topic_Japanese_Nm__c,PMP_Topic_English_Dsc__c,
                                                        PMP_Topic_Chinese_Dsc__c,PMP_Topic_Japanese_Dsc__c FROM PMP_Marketplace_Topic__c where PMP_Is_Active_Ind__c = true order by PMP_Marketplace_Topic_Name__c]){
                                                            mapTopicIdToTopicMdt.put(topic_mdt.PMP_Topic_Id__c,topic_mdt);
                                                        }
            return mapTopicIdToTopicMdt;
    } 


    public static map<Id,PMP_Marketplace_Topic__c> getAllEventTopicsMetadata(){
        
        Map<Id,PMP_Marketplace_Topic__c> mapTopicIdToTopicMdt = new Map<Id,PMP_Marketplace_Topic__c>();
        // Get the translations for the topics
        for(PMP_Marketplace_Topic__c topic_mdt :[SELECT PMP_Topic_Id__c,PMP_Marketplace_Topic_Name__c,PMP_Topic_Type__c,PMP_Marketplace_Event_Id__c,
                                                    PMP_Topic_Chinese_Nm__c,PMP_Topic_Japanese_Nm__c,PMP_Topic_English_Dsc__c,
                                                    PMP_Topic_Chinese_Dsc__c,PMP_Topic_Japanese_Dsc__c FROM PMP_Marketplace_Topic__c where PMP_Topic_Type__c = 'Event Topic']){
                                                        mapTopicIdToTopicMdt.put(topic_mdt.PMP_Topic_Id__c,topic_mdt);
                                                    }
        return mapTopicIdToTopicMdt;
} 
    
    public static String getEventIdForTopics(String topicId){
        
        List<PMP_Marketplace_Topic__c> getEventId  = [Select id, PMP_Marketplace_Event_Id__c from PMP_Marketplace_Topic__c where id =:topicId limit 1];

        if(getEventId!=null && getEventId.size()>0) {
            return getEventId[0].PMP_Marketplace_Event_Id__c;
        }else{
            return null;
        }

    }

    public static void cloneImageToEvents(String topicId){
        Boolean topicEventSync = Boolean.valueOf(PMP_Utility.getValue('PMP_Topic_Event_Sync')); 
        String eventId = getEventIdForTopics(topicId);

        if(!String.isBlank(eventId) && topicEventSync == true){
            
            List<ContentDocumentLink> newDocumentLinks = new List<ContentDocumentLink>();
            List<ContentDocumentLink> links = [SELECT id, ContentDocumentId,LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId = :eventId];

            
            if(links<> null){
                delete links;
            }


            List<ContentDocumentLink> newEventLinks = [SELECT id, ContentDocumentId,LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId = :topicId];

            if(newEventLinks<> null && !newEventLinks.isEmpty()){
                for(ContentDocumentLink cdLink : newEventLinks){
                    ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(cdLink.ContentDocumentId, eventId);
                    newDocumentLinks.add(cdl);
                }    
            }

            if(newDocumentLinks<>null){
                insert newDocumentLinks;
            }
        }
    }

    public static boolean getEventTopicType(String topicId){
        
        List<PMP_Marketplace_Topic__c> getEventTopicType  = [Select id, PMP_Topic_Type__c from PMP_Marketplace_Topic__c where id =:topicId limit 1];

        if(getEventTopicType!=null && getEventTopicType.size()>0) {
            if (getEventTopicType[0].PMP_Topic_Type__c =='Event Topic'){
                return true;
            }else{
                return false;
            } 

        }else{
            return false;
        }

    }*/
}