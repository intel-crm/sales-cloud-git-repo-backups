public with sharing class PMP_SearchEventDetailController extends PMP_SearchWrapperStore{
    
    
    public static List<Option> getPromotionLanguageOptions(){
        Schema.DescribeFieldResult fieldResult = PMP_Marketplace_Event__c.PMP_Event_Banner_Language__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<Option> options = new List<Option>();        
        for( Schema.PicklistEntry pickListVal : ple){
            Option opt = new Option();
            opt.label = pickListVal.getLabel();
            opt.value = pickListVal.getValue();
            options.add(opt);
        }
        return options;
    }
    
    public static List<Promotion> getPromotionData(String userLanguage){
        
        List<Promotion> promotionData = new List<Promotion>();
        Map<String,Promotion> promoMap = new Map<String,Promotion>();
        
        List<PMP_Marketplace_Event__c> eventList = [Select Name,PMP_Event_Banner_Language_Mapping__c,PMP_Event_Banner_Language__c, PMP_Marketplace_Desc__c, PMP_Marketplace_Event_End_Dt__c, PMP_Marketplace_Event_Start_Dt__c, PMP_Marketplace_Event_Tagline__c 
                                                    FROM PMP_Marketplace_Event__c WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW()) ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
        system.debug('DateTime :'+ SYSTEM.NOW());
        for(PMP_Marketplace_Event__c event: eventList){
            Promotion promo = new Promotion();
            promo.imageUrl= 'https://via.placeholder.com/810x456/0071C5/FFFFFF?text=Promotion'; // optional image
            
            if(event.PMP_Event_Banner_Language_Mapping__c != NULL){
                String baseLangCode = PMP_StaticConstants_Partner.languageCodeMap.get(event.PMP_Event_Banner_Language__c);
                Map<String,String> langLogoMap = new Map<String,String>();
                try{
                    langLogoMap = (Map<String,String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c,Map<String,String>.class);
                    
                }catch(Exception e){
                    System.debug('Error while parsing JSON');
                }
                if(langLogoMap.get(userLanguage) != NULL){
                    promo.imageUrl = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(userLanguage) + '?isOptimized=false';
                }else if(langLogoMap.get('en_US') != NULL){
                    promo.imageUrl = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get('en_US') + '?isOptimized=false';
                }else if(langLogoMap.get(baseLangCode) != NULL){
                    promo.imageUrl = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(baseLangCode) + '?isOptimized=false';
                }
            }
            promo.imagePosition= 'left'; // image position left or right
            promo.title= event.PMP_Marketplace_Event_Tagline__c;
            if(event.PMP_Marketplace_Desc__c != null){
                promo.body= event.PMP_Marketplace_Desc__c.unescapeHtml4();
            }
            promo.ctaLink= '#';
            promo.ctaLabel= System.Label.PMP_Learn_More;
            promo.searchParams = new SearchParams();
            promo.searchParams.type = 'all';
            promo.searchParams.selectedFilters = new Map<String,List<String>>{'Marketplace_Event'=>new List<String>{event.Id}};
            promoMap.put(event.Id,promo);
            
        }
        
        List<PMP_Marketplace_Event_Translation__c> transList = [SELECT PMP_Marketplace_Event_Id__c,PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c,PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c,PMP_Field_Nm__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c
                                                                FROM PMP_Marketplace_Event_Translation__c WHERE PMP_Marketplace_Event_Id__c IN :promoMap.KeySet()];
        
        for(PMP_Marketplace_Event_Translation__c trans: transList){
            
            Promotion promo = promoMap.get(trans.PMP_Marketplace_Event_Id__c);            
            String temp = '';
            if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && trans.PMP_Chinese_Txt__c != null){
                temp = trans.PMP_Chinese_Txt__c;
            }
            else if (userLanguage == PMP_StaticConstants_Partner.JA && trans.PMP_Japanese_Txt__c != null){
                temp = trans.PMP_Japanese_Txt__c;
            }
            else if (trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c != null && trans.PMP_Field_Nm__c == 'Description'){
                temp = trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c;
            }
            else if (trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c != null && trans.PMP_Field_Nm__c == 'Tagline'){
                temp = trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c;
            }
            if (trans.PMP_Field_Nm__c == 'Description')
            {
                promo.body = temp;
            }
            else if (trans.PMP_Field_Nm__c == 'Tagline')
            {
                promo.title = temp;
            }  
            
        }
        
        return promoMap.values();
    }
    
    public static List<String> getEventOfferings(List<Id> eventIds, List<String> offerings){   
        System.debug('eventIds'+eventIds);
        System.debug('offerings'+offerings);
        List<String> offIds = new List<String>();
        
        for(PMP_Marketplace_Event_Offering__c eveOff : [SELECT id, PMP_Offering_Id__c,PMP_Event_Id__c
                                                        from PMP_Marketplace_Event_Offering__c
                                                        WHERE PMP_Event_Id__c in:eventIds AND PMP_Offering_Id__c in:offerings])
       {
            offIds.add(eveOff.PMP_Offering_Id__c);    
           
        }
    System.debug('offIds'+offIds);
        
        return offIds;
    }
    
    public static List<String> getEventPartners(List<Id> eventIds, List<String> partners){
        
        System.debug('eventIds1'+eventIds);
        System.debug('partners'+partners);
        List<String> partnerIds = new List<String>();
        
        
        for(PMP_Marketplace_Event_Partner__c evePartner : [SELECT id,PMP_Company_Id__c,PMP_Event_Id__c
                                                           FROM PMP_Marketplace_Event_Partner__c
                                                           WHERE PMP_Event_Id__c in:eventIds AND PMP_Company_Id__c in:partners])
        {
            partnerIds.add(evePartner.PMP_Company_Id__c);
        }
        
        return partnerIds;
    }
    
    public static Filter getEvents(Map<String, List<Id>> selectedFilter, String searchType, List<String> offerings, List<String> partners){    //Extracting events
        
        
        List<PMP_Marketplace_Event__c> eventList = [SELECT Name from PMP_Marketplace_Event__c 
                                                    WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW())
                                                    ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
        
        Filter filter = new Filter();
        filter.tags = new List<tag>();
        filter.name ='Marketplace_Event';//Value of Filter
        filter.label = System.Label.PMP_Marketplace_Event;
        filter.type = 'tag';
        
        Map<String,Tag> eventTagMap = new Map<String,Tag>();
        for(PMP_Marketplace_Event__c eve: eventList){
            Tag tag = new Tag();
            tag.label = eve.Name;
            tag.value = eve.Id;
            tag.count = 0;
            tag.children  = new List<Tag>();
            filter.tags.add(tag);
            eventTagMap.put(eve.Id,tag);
        }
        eventTagMap = getEventCount(searchType, eventTagMap, partners, offerings);
        
        for(PMP_Marketplace_Event__c eve: eventList){
            if(eventTagMap.containsKey(eve.Id)){
                if(eventTagMap.get(eve.Id).count == 0){
                    filter.tags.remove(filter.tags.indexOf(eventTagMap.get(eve.Id)));
                }
            }
        }           
        
        return filter;
        
        
    }
    
    public static Map<String,Tag> getEventCount(String searchType, Map<String,Tag> eventTagMap, List<String> partners, List<String> offerings){
        System.debug('searchType'+searchType);
        
        if(searchType == PMP_StaticConstants_Partner.product){
            
            return getEventOffCount(eventTagMap, offerings);
            
        }
        else if(searchType == PMP_StaticConstants_Partner.partner)
        {
            return getEventPartnerCount(eventTagMap, partners);
        }
        else
        {
            
            return  getEventOffCount(getEventPartnerCount(eventTagMap, partners), offerings);
        }
        
        
        
        
    }
    
    public static Map<String,Tag> getEventOffCount(Map<String,Tag> eventTagMap, List<String> offerings){
        System.debug('offerings'+offerings);
        
        List<AggregateResult> eventOffAggregate = [SELECT COUNT(PMP_Offering_Id__c)cnt,PMP_Event_Id__c
                                                   from PMP_Marketplace_Event_Offering__c
                                                   WHERE  PMP_Offering_Id__c in: offerings AND
                                                   (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
                                                   GROUP BY PMP_Event_Id__c];
        
        for(AggregateResult eventOff : eventOffAggregate){
            String eveId = (String)eventOff.get('PMP_Event_Id__c');
            if(eventTagMap.containsKey(eveId)){
                eventTagMap.get(eveId).count += (Integer)eventOff.get('cnt');
            }
        }
        return eventTagMap;
    }
    
    public static Map<String,Tag> getEventPartnerCount(Map<String,Tag> eventTagMap, List<String> partners){
        System.debug('partners'+partners);
        List<AggregateResult> eventPartnerAggregate=[Select COUNT(PMP_Company_Id__c)cnt,PMP_Event_Id__c
                                                     from PMP_Marketplace_Event_Partner__c 
                                                     where PMP_Company_Id__c in: partners AND
                                                     (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
                                                     GROUP BY PMP_Event_Id__c];
        for(AggregateResult eventOfPartner : eventPartnerAggregate){
            String eveId = (String)eventOfPartner.get('PMP_Event_Id__c');
            if(eventTagMap.containsKey(eveId)){
                eventTagMap.get(eveId).count += (Integer)eventOfPartner.get('cnt');
            }
        }
        return eventTagMap;
    }
    
}