trigger UpdateOfferingAndCompanyTopics on TopicAssignment (after insert,after delete) {
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
//    Set<Id> topicAssignIds = new Set<Id>();
//    Map<Id,Integer> offTopicMap = new Map<Id,Integer>();
//    Map<Id,Integer> partnerTopicMap = new Map<Id,Integer>();
//    List<TopicAssignment> insertTopicList = new List<TopicAssignment>();
//   List<TopicAssignment> deleteTopicList = new List<TopicAssignment>();
//    List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
//    List<PMP_Company__c> partnerList = new List<PMP_Company__c>();

//   if(Trigger.isInsert)
//    {
        /*for(TopicAssignment topicInsert:Trigger.New){
            if(topicInsert!=null){//not reqd
                insertTopicList.add(topicInsert);
            }         
        }*/
//        updateTopicCount(Trigger.New);
//    }   
//    if(Trigger.isDelete){ 
        
//         updateTopicCount(Trigger.old);
//    }
    
//    void updateTopicCount(List<TopicAssignment> topicList){
        
//            for(TopicAssignment ta: topicList){
//                if(ta != null){
//                    topicAssignIds.add(ta.EntityId);
//                }
            
//        }
        
//        for(TopicAssignment topic:[select id, TopicId, EntityId, EntityType from TopicAssignment where EntityId IN:topicAssignIds]){
        //Topic Count on Offering
//        Integer offTopicCount = 0;
//        if(topic.EntityType=='PMP_Partner_Offering' && offTopicMap.containsKey(topic.EntityId)){
            
//            system.debug('topic---'+topic);
//            system.debug('offTopicMap at 25---'+offTopicMap);
//            offTopicCount = offTopicMap.get(topic.EntityId);
//           offTopicCount++;
//           offTopicMap.put(topic.EntityId,offTopicCount);
//            system.debug('offTopicCount---'+offTopicCount);
//        }else{
//           offTopicMap.put(topic.EntityId,++offTopicCount);
//            system.debug('offTopicMap at 31---'+offTopicMap);
//         }
        // Topic Count on Company
//        if(topic.EntityType=='PMP_Company' && partnerTopicMap.containsKey(topic.EntityId)){
//            Integer compTopicCount = 0;
//            compTopicCount = partnerTopicMap.get(topic.EntityId);
//            compTopicCount++;
//        }else{
//            partnerTopicMap.put(topic.EntityId,1);
//        }
//   }
    
        
//    for(Id entityId :offTopicMap.keySet()){
//        system.debug('entityId--'+entityId);
//        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
//        off.Id = entityId;
//        //off.PMP_Topic_Count__c = String.valueOf(offTopicMap.get(entityId));
//        offeringList.add(off);
//        system.debug('offeringList--'+offeringList);
//    } 
      /*  for(Id entityId :offTopicMap.keySet()){
            PMP_Company__c partner = new PMP_Company__c();
            partner.Id = entityId;
            partner.PMP_Topic_Count__c = String.valueOf(partnerTopicMap.get(entityId));
            partnerList.add(partner);
        } 
        update offeringList;
        update partnerList;*/
//        update offeringList;
//    }
 
}