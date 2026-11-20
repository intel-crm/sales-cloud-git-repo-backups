/**************************************************************************************
Apex Class Name : PMP_Marketplace_Topic_Helper
Version     : 1.0 
Created Date: 3rd August, 2022
Description : Marketplace logic for helper for Marketplace Topic Record
* Modification Log :
* Developer                 Date                     Description 
* ----------------------------------------------------------------------------
* Sathish                  03/Aug/2022               Original Version
*************************************************************************************/

public with sharing class PMP_Marketplace_Topic_Helper {
    public static Boolean isWorking() {
        boolean flag=true;
        return flag;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static void  insertTopicRecord(List<PMP_Marketplace_Topic__c> listMarketplaceTopics){

        Set<String> topicNames = new Set<String>();
        for(PMP_Marketplace_Topic__c marketplaceTopic : listMarketplaceTopics){
            topicNames.add(marketplaceTopic.PMP_Marketplace_Topic_Name__c);
        }
        // Query the existing topics using the topic Name
        // Network Id is null, to determine the internal topics and not the community topics
        Map<String,Topic> mapTopics = new Map<String,Topic>();
        for(Topic topic :[select Id,Name from Topic where NetworkId = null and name in:topicNames]){
            String name = topic.Name;
            name = name.deleteWhitespace();
            name = name.toLowerCase();
            mapTopics.put(name,topic);
        }

        Set<String> listTopicsToBeCreated = new Set<String>();
        for(PMP_Marketplace_Topic__c marketplaceTopic:listMarketplaceTopics){
            // If topic already contains map the topic Id to Marketplace Topic Record else create the standard topic
            String mpTopicName = marketplaceTopic.PMP_Marketplace_Topic_Name__c;
            mpTopicName = mpTopicName.deleteWhitespace();
            mpTopicName = mpTopicName.toLowerCase();

            if(mapTopics.keyset().contains(mpTopicName)){
                Topic topic = mapTopics.get(mpTopicName);
                marketplaceTopic.PMP_Topic_Id__c = topic.Id;    
                marketplaceTopic.PMP_Marketplace_Topic_Name__c = topic.Name;
            }else{
                listTopicsToBeCreated.add(marketplaceTopic.PMP_Marketplace_Topic_Name__c);
            }

        }

        List<Topic> listTopics = new List<Topic>();

        for(String topicName :listTopicsToBeCreated){
            Topic topic = new Topic();
            topic.Name = topicName;
            listTopics.add(topic);
        }

        // Insert Standard Topic Records if topic doesn't exist
        if(!listTopics.isEmpty()){
            try {
            insert listTopics;
            } catch(DmlException e){
                //System.debug(e);
               if(e.getMessage().contains('DUPLICATE_VALUE')){
                    PMP_Utility.logError(e, 'PMP_Marketplace_Topic_Helper.DuplicateStandardTopic');
                    for(PMP_Marketplace_Topic__c topicRecord : listMarketplaceTopics){
                        topicRecord.addError(e.getMessage().substringAfter('DUPLICATE_VALUE,').substringBefore(':'));
                    }
                }else{
                    handleException('PMP_Marketplace_Topic_Helper.InsertTopicRecord', e, listMarketplaceTopics);
                }
            }
        }

        for(Topic topic : listTopics){
            for(PMP_Marketplace_Topic__c marketplaceTopic : listMarketplaceTopics){
                if(topic.Name == marketplaceTopic.PMP_Marketplace_Topic_Name__c){
                    marketplaceTopic.PMP_Topic_Id__c = topic.Id;
                }
            }
        }

    }

    
    // This method is used the sync Marketplace Topic records to the Marketplace Event Records
    public static void upsertEventRecords(List<PMP_Marketplace_Topic__c> listmarketplaceTopics){

        Map<Id,PMP_Marketplace_Topic__c> mapMarketplaceTopics = new Map<Id,PMP_Marketplace_Topic__c>();
        for(PMP_Marketplace_Topic__c topic : listmarketplaceTopics){
            mapMarketplaceTopics.put(topic.PMP_Topic_Id__c,topic);
        }
        Map<Id,PMP_Marketplace_Event__c> mapTopicToEvent = new Map<Id,PMP_Marketplace_Event__c>();
        for(PMP_Marketplace_Topic__c topic : listmarketplaceTopics){

            if(topic.PMP_Topic_Type__c == 'Event Topic'){
                PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__C();
                event.Id = topic.PMP_Marketplace_Event_Id__c;
                event.name = topic.PMP_Marketplace_Topic_Name__c;
                event.PMP_Event_Banner_Language__c = topic.PMP_Event_Banner_Language__c;
                event.PMP_Event_Banner_Language_Mapping__c = topic.PMP_Event_Banner_Language_Mapping__c;
                event.PMP_Event_Learn_More_Link_Txt__c = topic.PMP_Event_Learn_More_Link_Txt__c;
                event.PMP_Event_Marquee_Desc_Txt__c = topic.PMP_Topic_English_Dsc__c;
                event.PMP_Marketplace_Desc__c = topic.PMP_Topic_English_Dsc__c;
                event.PMP_Event_Screen_Reader_Txt__c = topic.PMP_Event_Screen_Reader_Txt__c;
                event.PMP_Marketplace_Event_End_Dt__c = topic.PMP_Marketplace_Event_End_Dt__c;
                event.PMP_Marketplace_Event_Start_Dt__c = topic.PMP_Marketplace_Event_Start_Dt__c;
                event.PMP_Marketplace_Event_Tagline__c = topic.PMP_Marketplace_Event_Tagline__c;
                mapTopicToEvent.put(topic.PMP_Topic_Id__c,event);
            }
            
        }
        // Upsert the Event records
        if(!mapTopicToEvent.isEmpty()){
            try{
            upsert mapTopicToEvent.values();
            }catch(DmlException e){
                handleException('PMP_Marketplace_Topic_Helper.UpsertEventRecord', e, listmarketplaceTopics);
            }
        }
        Map<Id,PMP_Marketplace_Event__c> mapEvent = new Map<Id,PMP_Marketplace_Event__c>();
        for(PMP_Marketplace_Event__c event : mapTopicToEvent.values()){
            mapEvent.put(event.Id,event);
        }

         // get the translation records for the event
         Map<Id,List<PMP_Marketplace_Event_Translation__c>> mapEventTolistTranslationRec = new Map<Id,List<PMP_Marketplace_Event_Translation__c>>();
         if(!mapEvent.isEmpty()){
            for(PMP_Marketplace_Event_Translation__c trans : [select id,PMP_Marketplace_Event_Id__c,PMP_Field_Nm__c,PMP_English_Txt__c,PMP_Japanese_Txt__c,PMP_Chinese_Txt__c from PMP_Marketplace_Event_Translation__c where PMP_Marketplace_Event_Id__c in : mapEvent.keyset()]){
                if(mapEventTolistTranslationRec.containsKey(trans.PMP_Marketplace_Event_Id__c)){
                    mapEventTolistTranslationRec.get(trans.PMP_Marketplace_Event_Id__c).add(trans);
                }else{
                mapEventTolistTranslationRec.put(trans.PMP_Marketplace_Event_Id__c,new List<PMP_Marketplace_Event_Translation__c>{trans});
                }
            }
        }
         
        List<PMP_Marketplace_Event_Translation__c> listUpsertTranslationRec = new List<PMP_Marketplace_Event_Translation__c>();
         for(Id topicId : mapTopicToEvent.keyset()){

            // Stamp back the Event Id on to the Marketplace Topic record - This is before trigger - Changes to Marketplace topic record will automatically reflect
            mapMarketplaceTopics.get(topicId).PMP_Marketplace_Event_Id__c = mapTopicToEvent.get(topicId).Id; 


            // If translation records for event already exist - map them with existing Id for Update
            if(mapEventTolistTranslationRec.containsKey(mapTopicToEvent.get(topicId).Id)){
                List<PMP_Marketplace_Event_Translation__c> eventTranslations = mapEventTolistTranslationRec.get(mapTopicToEvent.get(topicId).Id);
                for(PMP_Marketplace_Event_Translation__c trans : eventTranslations){
                    if(trans.PMP_Field_Nm__c == 'Description'){
                        trans.PMP_English_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Topic_English_Dsc__c;
                        trans.PMP_Japanese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Topic_Japanese_Dsc__c;
                        trans.PMP_Chinese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Topic_Chinese_Dsc__c;
                    }else if(trans.PMP_Field_Nm__c == 'Tagline'){
                        trans.PMP_English_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Marketplace_Event_Tagline__c;
                        trans.PMP_Japanese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Event_Japanese_Tagline__c;
                        trans.PMP_Chinese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Event_Chinese_Tagline__c;
                    }
                    listUpsertTranslationRec.add(trans);
                }


            }else{
                // If no translation records already exist, then create the new Records
                PMP_Marketplace_Event_Translation__c eventTranslationDesc = new PMP_Marketplace_Event_Translation__c();
                eventTranslationDesc.PMP_Marketplace_Event_Id__c = mapTopicToEvent.get(topicId).Id; 
                eventTranslationDesc.PMP_Field_Nm__c =  'Description';
                eventTranslationDesc.PMP_English_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Topic_English_Dsc__c;
                eventTranslationDesc.PMP_Japanese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Topic_Japanese_Dsc__c;
                eventTranslationDesc.PMP_Chinese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Topic_Chinese_Dsc__c;

                PMP_Marketplace_Event_Translation__c eventTranslationTagline = new PMP_Marketplace_Event_Translation__c();
                eventTranslationTagline.PMP_Marketplace_Event_Id__c = mapTopicToEvent.get(topicId).Id; 
                eventTranslationTagline.PMP_Field_Nm__c =  'Tagline';
                eventTranslationTagline.PMP_English_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Marketplace_Event_Tagline__c;
                eventTranslationTagline.PMP_Japanese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Event_Japanese_Tagline__c;
                eventTranslationTagline.PMP_Chinese_Txt__c = mapMarketplaceTopics.get(topicId).PMP_Event_Chinese_Tagline__c;

                listUpsertTranslationRec.add(eventTranslationDesc);
                listUpsertTranslationRec.add(eventTranslationTagline);
            }

         }


         if(!listUpsertTranslationRec.isEmpty()){
            try{
                Upsert listUpsertTranslationRec;
            }catch(DmlException e){
                handleException('PMP_Marketplace_Topic_Helper.UpsertTranslatonRecords', e, listmarketplaceTopics );
            }
         }
        
    }

    public static void handleException(String message,DmlException e,List<SObject> errorRecords ){
        // System.debug(e);
        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                PMP_Utility.logError(e, message);
                for(Sobject record : errorRecords){
                    record.addError(e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(':'));
                }
            }else{
                throw e;
            }
    }*/
    
}