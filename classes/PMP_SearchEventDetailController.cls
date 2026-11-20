public with sharing class PMP_SearchEventDetailController extends PMP_SearchWrapperStore{
    public static Boolean isWorking() {
        return true;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static List<Option> getPromotionLanguageOptions(){
        Schema.DescribeFieldResult fieldResult = PMP_Marketplace_Event__c.PMP_Event_Banner_Language__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        List<Option> options = new List<Option>();
        for (Schema.PicklistEntry pickListVal : ple){
            Option opt = new Option();
            opt.label = pickListVal.getLabel();
            opt.value = pickListVal.getValue();
            options.add(opt);
        }
        //System.debug('opt' + options);
        return options;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static List<Promotion> getPromotionData(String userLanguage){
        // system.debug('userlanguagefromURL' + userLanguage);
        if (userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN){
             // Added this check since Chinese langcode is modified
            userLanguage = PMP_StaticConstants_Partner.ZH_CN;
        }
        // system.debug('userLanguagemodified' + userLanguage);
        //List<Promotion> promotionData = new List<Promotion>();
        Map<String, Promotion> promoMap = new Map<String, Promotion>();
        List<PMP_Marketplace_Event__c> eventList = new List<PMP_Marketplace_Event__c>();
        if (Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
             //PMD Fix
            eventList = [Select Name, PMP_Event_Banner_Language_Mapping__c, PMP_Event_Banner_Language__c, PMP_Marketplace_Desc__c, PMP_Marketplace_Event_End_Dt__c, PMP_Marketplace_Event_Start_Dt__c, PMP_Marketplace_Event_Tagline__c, PMP_Event_Screen_Reader_Txt__c
                         FROM PMP_Marketplace_Event__c
                         WHERE (PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
                         ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
        }
        // system.debug('eventList' + eventList);

        for (PMP_Marketplace_Event__c event : eventList){
            Promotion promo = new Promotion();
            promo.imageUrl = PMP_StaticConstants_Partner.eventDefaultLogo;  //commented above line and added this as part of DE112070 fix
            if (event.PMP_Event_Banner_Language_Mapping__c != NULL){
                String baseLangCode = PMP_StaticConstants_Partner.languageCodeMap.get(event.PMP_Event_Banner_Language__c);
                // system.debug('baseLangCode' + baseLangCode);
                Map<String, String> langLogoMap = new Map<String, String>();
                langLogoMap = (Map<String, String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c, Map<String, String>.class);
                // system.debug('langLogoMap' + langLogoMap);

                if (langLogoMap.get(userLanguage) != NULL){
                    promo.imageUrl = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(userLanguage) + '?isOptimized=false';
                } else if (langLogoMap.get('en_US') != NULL){
                    promo.imageUrl = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get('en_US') + '?isOptimized=false';
                } else if (langLogoMap.get(baseLangCode) != NULL){
                    promo.imageUrl = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(baseLangCode) + '?isOptimized=false';
                }
            }
            promo.imagePosition = 'left'; // image position left or right
            promo.title = event.PMP_Marketplace_Event_Tagline__c;
            if (event.PMP_Marketplace_Desc__c != null){
                promo.body = event.PMP_Marketplace_Desc__c.unescapeHtml4();
            }
            string str = event.Name;
            str = str.toLowerCase();
            str = str.replace(' ', '-');
            str = str.replace('_', '-');

            promo.promotionName = '"PromotionBlade:' + str + '"';
            promo.ctaLink = event.Id;
            promo.eventScreenReader = event.PMP_Event_Screen_Reader_Txt__c;
            promo.ctaLabel = System.Label.PMP_Learn_More;
            promo.searchParams = new SearchParams();
            promo.searchParams.type = 'all';
            promo.searchParams.selectedFilters = new Map<String, List<String>>{ 'Marketplace_Event' => new List<String>{ event.Id } };
            promoMap.put(event.Id, promo);


        }*/
        /*List<PMP_Marketplace_Event_Translation__c> transList = [SELECT PMP_Marketplace_Event_Id__c,PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c,PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c,PMP_Field_Nm__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c
         FROM PMP_Marketplace_Event_Translation__c WHERE PMP_Marketplace_Event_Id__c IN :promoMap.KeySet()];*/
        /*List<PMP_Marketplace_Event_Translation__c> transList = new List<PMP_Marketplace_Event_Translation__c>();
        if (Schema.sObjectType.PMP_Marketplace_Event_Translation__c.isAccessible()){
             //PMD Fix
            transList = [SELECT PMP_Marketplace_Event_Id__c, PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c, PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c, PMP_Field_Nm__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c
                         FROM PMP_Marketplace_Event_Translation__c
                         WHERE PMP_Marketplace_Event_Id__c IN:promoMap.KeySet()];
        }
        for (PMP_Marketplace_Event_Translation__c trans : transList){

            Promotion promo = promoMap.get(trans.PMP_Marketplace_Event_Id__c);
            String temp = '';
            if ((userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN) && trans.PMP_Chinese_Txt__c != null){
                temp = trans.PMP_Chinese_Txt__c;
            } else if (userLanguage == PMP_StaticConstants_Partner.JA && trans.PMP_Japanese_Txt__c != null){
                temp = trans.PMP_Japanese_Txt__c;
            } else if (trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c != null && trans.PMP_Field_Nm__c == 'Description'){
                temp = trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Desc__c;
            } else if (trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c != null && trans.PMP_Field_Nm__c == 'Tagline'){
                temp = trans.PMP_Marketplace_Event_Id__r.PMP_Marketplace_Event_Tagline__c;
            }
            if (trans.PMP_Field_Nm__c == 'Description'){
                promo.body = temp;
            } else if (trans.PMP_Field_Nm__c == 'Tagline'){
                promo.title = temp;
            }

        }

        return promoMap.values();
    }*/

//IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static List<String> getEventOfferings(List<Id> eventIds, List<String> offerings){
        // System.debug('eventIds' + eventIds);
        // System.debug('offerings' + offerings);
        List<String> offIds = new List<String>();

        for (PMP_Marketplace_Event_Offering__c eveOff : [SELECT id, PMP_Offering_Id__c, PMP_Event_Id__c
                                                         from PMP_Marketplace_Event_Offering__c
                                                         WHERE PMP_Event_Id__c in:eventIds AND PMP_Offering_Id__c in:offerings]){
            offIds.add(eveOff.PMP_Offering_Id__c);

        }
        // System.debug('offIds' + offIds);

        return offIds;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static List<String> getEventPartners(List<Id> eventIds, List<String> partners){

        // System.debug('eventIds1' + eventIds);
        // System.debug('partners' + partners);
        List<String> partnerIds = new List<String>();


        for (PMP_Marketplace_Event_Partner__c evePartner : [SELECT id, PMP_Company_Id__c, PMP_Event_Id__c
                                                            FROM PMP_Marketplace_Event_Partner__c
                                                            WHERE PMP_Event_Id__c in:eventIds AND PMP_Company_Id__c in:partners]){
            partnerIds.add(evePartner.PMP_Company_Id__c);
        }

        return partnerIds;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    //public static Filter getEvents(Map<String, List<Id>> selectedFilter, String searchType, List<String> offerings, List<String> partners){
            //Extracting events
        /*List<PMP_Marketplace_Event__c> eventList = [SELECT Name from PMP_Marketplace_Event__c
         WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW())
         ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];*/
        /*List<PMP_Marketplace_Event__c> eventList = new List<PMP_Marketplace_Event__c>();
        if (Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
             //PMD Fix
            eventList = [SELECT Name
                         from PMP_Marketplace_Event__c
                         WHERE (PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
                         ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
        }
        Filter filter = new Filter();
        filter.tags = new List<tag>();
        filter.name = 'Marketplace_Event';//Value of Filter
        filter.label = System.Label.PMP_Marketplace_Event;
        filter.type = 'tag';

        Map<String, Tag> eventTagMap = new Map<String, Tag>();
        for (PMP_Marketplace_Event__c eve : eventList){
            Tag tag = new Tag();
            tag.label = eve.Name;
            tag.value = eve.Id;
            tag.count = 0;
            tag.children = new List<Tag>();
            filter.tags.add(tag);
            eventTagMap.put(eve.Id, tag);
        }
        eventTagMap = getEventCount(searchType, eventTagMap, partners, offerings);

        for (PMP_Marketplace_Event__c eve : eventList){
            if (eventTagMap.containsKey(eve.Id)){
                if (eventTagMap.get(eve.Id).count == 0){
                    filter.tags.remove(filter.tags.indexOf(eventTagMap.get(eve.Id)));
                }
            }
        }

        return filter;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static Map<String, Tag> getEventCount(String searchType, Map<String, Tag> eventTagMap, List<String> partners, List<String> offerings){
        // System.debug('searchType' + searchType);

        if (searchType == PMP_StaticConstants_Partner.product){

            return getEventOffCount(eventTagMap, offerings);

        } else if (searchType == PMP_StaticConstants_Partner.partner){
            return getEventPartnerCount(eventTagMap, partners);
        } else{

            return getEventOffCount(getEventPartnerCount(eventTagMap, partners), offerings);
        }
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    //public static Map<String, Tag> getEventOffCount(Map<String, Tag> eventTagMap, List<String> offerings){
        // System.debug('offerings' + offerings);
        /*List<AggregateResult> eventOffAggregate = [SELECT COUNT(PMP_Offering_Id__c)cnt,PMP_Event_Id__c
         from PMP_Marketplace_Event_Offering__c
         WHERE  PMP_Offering_Id__c in: offerings AND
         (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
         GROUP BY PMP_Event_Id__c]; */
        /*List<AggregateResult> eventOffAggregate = new List<AggregateResult>();
        if (Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()){
             //PMD Fix

            eventOffAggregate = [SELECT COUNT(PMP_Offering_Id__c)cnt, PMP_Event_Id__c
                                 from PMP_Marketplace_Event_Offering__c
                                 WHERE PMP_Offering_Id__c in:offerings AND (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
                                 GROUP BY PMP_Event_Id__c];
        }
        for (AggregateResult eventOff : eventOffAggregate){
            String eveId = (String) eventOff.get('PMP_Event_Id__c');
            if (eventTagMap.containsKey(eveId)){
                eventTagMap.get(eveId).count += (Integer) eventOff.get('cnt');
            }
        }

        return eventTagMap;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    //public static Map<String, Tag> getEventPartnerCount(Map<String, Tag> eventTagMap, List<String> partners){
        // System.debug('partners' + partners);
        /*List<AggregateResult> eventPartnerAggregate=[Select COUNT(PMP_Company_Id__c)cnt,PMP_Event_Id__c
         from PMP_Marketplace_Event_Partner__c
         where PMP_Company_Id__c in: partners AND
         (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
         GROUP BY PMP_Event_Id__c];*/
        /*List<AggregateResult> eventPartnerAggregate = new List<AggregateResult>();
        if (Schema.sObjectType.PMP_Marketplace_Event_Partner__c.isAccessible()){
             //PMD Fix

            eventPartnerAggregate = [Select COUNT(PMP_Company_Id__c)cnt, PMP_Event_Id__c
                                     from PMP_Marketplace_Event_Partner__c
                                     where PMP_Company_Id__c in:partners AND (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
                                     GROUP BY PMP_Event_Id__c];
        }
        for (AggregateResult eventOfPartner : eventPartnerAggregate){
            String eveId = (String) eventOfPartner.get('PMP_Event_Id__c');
            if (eventTagMap.containsKey(eveId)){
                eventTagMap.get(eveId).count += (Integer) eventOfPartner.get('cnt');
            }
        }

        return eventTagMap;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    //New EventDetailPageLogic Starts from here
    //For Event L1 page results
    /*@AuraEnabled(cacheable = true)
    public static CampaignEvents getCampaignCardDetails(String campaignId, String cardType, String langCode, Integer currentPage, Integer pageSize){

        CampaignEvents campaign1 = New CampaignEvents();

        //caching logic starts here
        //Caching only for Guest users

        //String cacheLanguage;
        Boolean isGuestUser = PMP_SearchUtilityController.isGuest();
        // system.debug('isGuestUser' + isGuestUser);

        //Add the guest user language to Cache as Key
        // cacheLanguage = langCode != NULL ? langCode.replace('_', '').replace('-', '') : '';

        String langKeys = PMP_StaticConstants_Partner.supportedLanguagesForPlatformCache;
        List<String> langList = new List<String>();
        for (String languageCode : langKeys.split('\\;')){
            langList.add(languageCode.replace('_', '').replace('-', ''));
        }
        String cacheKey = 'Event' + campaignId;

        String languageCode = langcode.replace('_', '').replace('-', '');
        if (langcode != NULL && !langList.isEmpty() && langList.contains(languageCode)){
            cacheKey = cacheKey + languageCode;
        }
        // Name of a partition and key
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');

        //Get the flag from Custom Metadata
        String cacheFlag = PMP_Utility.getValue('EventPage_CacheFlag');

        Boolean isValidCache = false;
        if (cacheFlag.equalsIgnoreCase('true') && isGuestUser){
            campaign1 = (CampaignEvents)Cache.Org.getPartition(partitionInput).get(cacheKey);
            if (campaign1 != null){
                // system.debug('data is returning from cache');
                isValidCache = true;
                return campaign1;
            }

        }

        //caching logic ends here
        if (!isValidCache && Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
            List<PMP_Marketplace_Event__c> events = [SELECT Id
                                                     FROM PMP_Marketplace_Event__c
                                                     WHERE Id = :campaignId AND PMP_Marketplace_Event_Status__c = true];
            if (events.size() > 0){
                List<Id> partnerIds = getEventPartnerId(campaignId);
                List<Id> offIds = getEventOfferingsId(campaignId);
                // CampaignEvents campaign1=New CampaignEvents();
                campaign1 = New CampaignEvents();// added to avoid null pointer exception

                // PMP_Marketplace_Event__c event1 =[Select id,name from PMP_Marketplace_Event__c where id=:campaignId];
                PMP_Marketplace_Event__c event1 = new PMP_Marketplace_Event__c();
                if (Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
                     // PMD Fix
                    event1 = [Select id, name
                              from PMP_Marketplace_Event__c
                              where id = :campaignId];
                }
                //other than partnerId's and langCode the other attributes are dummy values
                List<PMP_SearchPartnerController.Partner> partners = PMP_SearchPartnerController.getPartners(partnerIds, currentPage, pageSize, 'event', langCode, null, null, new List<String>());//PROD DEFECT FIX: added keyword=null parameter at the end

                List<PMP_SearchProductController.Product> products = PMP_SearchProductController.getProducts(offIds, currentPage, pageSize, 'event', langCode, null);//PROD DEFECT FIX: added keyword=null parameter at the end

                campaign1.name = event1.name;
                campaign1.partnerCards = partners;
                campaign1.productCards = products;
                if (partnerIds.size() > 0){
                    campaign1.partnerTotal = partnerIds.size();
                }
                if (offIds.size() > 0){
                    campaign1.productTotal = offIds.size();
                }
                // system.debug('campaign1.partnerCards' + campaign1.partnerCards);
                // system.debug('campaign1.productCards' + campaign1.productCards);
                // system.debug('campaign1' + campaign1);
                //add campaign into the cache
                try{
                    String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
                    //Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
                    if (cacheFlag.equalsIgnoreCase('true') && isGuestUser){
                        //Cache.Org.put(partitionInput + '.' + cacheKey, campaign1, cacheTTL);
                        //System.debug('Cache.Event::' + Cache.Org.get(partitionInput + '.' + cacheKey));
                    }
                } Catch (Cache.ItemSizeLimitExceededException error){
                    //System.debug('Error due to Item Size Exceeded***********' + error.getMessage() + 'at line ' + error.getLineNumber());
                    //PMP_Utility.logError(error,'EventPage');

                } Catch (Cache.Org.OrgCacheException error){
                    //System.debug('Error due to Partition Exception***********' + error.getMessage() + 'at line ' + error.getLineNumber());
                    //PMP_Utility.logError(error,'EventPage');

                }
            }
            //add campaign into the cache  -- end
        }
        return campaign1;
    }*/

    //For Event L1 Page Marquee
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*@AuraEnabled(cacheable = true)
    public static CampaignEvents getCampaignMarqueeDetails(String campaignId){

        CampaignEvents campaign1 = New CampaignEvents();
        //cache logic starts here
        // check if the user is  a guest user
        Boolean isGuestUser = PMP_SearchUtilityController.isGuest();
        // Name of a partition and key
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        //Get the flag from Custom Metadata
        String cacheFlag = PMP_Utility.getValue('EventPage_CacheFlag');

        //Prepare the key
        String cacheKey = 'EventMarquee' + campaignId;
        Boolean isValidCache = false;

        if (cacheFlag.equalsIgnoreCase('true') && isGuestUser){
            campaign1 = (CampaignEvents)Cache.Org.getPartition(partitionInput).get(cacheKey);

            if (campaign1 != NULL){
                isValidCache = true;
                return campaign1;
            }
        }
        //cache logic ends here

        if (!isValidCache){
            campaign1 = new CampaignEvents();
            campaign1.isInvalidEvent = false;
            if (Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
                 // PMD Fix
                List<PMP_Marketplace_Event__c> events = new List<PMP_Marketplace_Event__c>();*/
                // Commented as part of Topic Event Change - To redirect intel admin to Error page - Sathish
                /* if (PMP_SearchUtilityController.isIntelAdmin()){
                    events = [Select id, name, PMP_Event_Learn_More_Link_Txt__c, PMP_Event_Marquee_Desc_Txt__c
                              from PMP_Marketplace_Event__c
                              where id = :campaignId];
                } else{ */
                    /*events = [Select id, name, PMP_Event_Learn_More_Link_Txt__c, PMP_Event_Marquee_Desc_Txt__c
                              from PMP_Marketplace_Event__c
                              where id = :campaignId AND PMP_Marketplace_Event_Status__c = true];
                //}
                if (events.size() > 0){
                    // CampaignEvents campaign1=New CampaignEvents();
                    PMP_Marketplace_Event__c event1 = events[0];
                    campaign1.name = event1.name;
                    if (event1.PMP_Event_Marquee_Desc_Txt__c != null){
                        campaign1.description = event1.PMP_Event_Marquee_Desc_Txt__c;
                    } else{
                        campaign1.description = ' ';
                    }
                    String web = '';
                    if (event1.PMP_Event_Learn_More_Link_Txt__c != NULL){
                        web = (event1.PMP_Event_Learn_More_Link_Txt__c.startsWith('http') ? '' : 'https://') + event1.PMP_Event_Learn_More_Link_Txt__c;
                        campaign1.externalUrl = web;
                    }
                    // system.debug('campaign1' + campaign1);
                } else{
                    campaign1.isInvalidEvent = true;
                    campaign1.name = ' ';
                    campaign1.description = ' ';
                }
                //adding the marquee campaign details to cache - start
                if (!campaign1.isInvalidEvent && events.size() > 0){
                    try{
                        String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
                        Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
                        if (cacheFlag.equalsIgnoreCase('true') && isGuestUser){
                            Cache.Org.put(partitionInput + '.' + cacheKey, campaign1, cacheTTL);
                            //System.debug('Cache.Event::' + Cache.Org.get(partitionInput + '.' + cacheKey));
                        }
                    } Catch (Cache.ItemSizeLimitExceededException error){
                        //System.debug('Error due to Item Size Exceeded***********' + error.getMessage() + 'at line ' + error.getLineNumber());
                        //PMP_Utility.logError(error,'EventPage');

                    } Catch (Cache.Org.OrgCacheException error){
                        //System.debug('Error due to Partition Exception***********' + error.getMessage() + 'at line ' + error.getLineNumber());
                        //PMP_Utility.logError(error,'EventPage');

                    }
                }
                //adding the marquee campaign details to cache - End
            }
        }
        return campaign1;
    }*/

    // FOR STOREFRONT EVENT BANNER
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*@AuraEnabled(cacheable = true)
    public static List<CampaignEvents> getCampaignBannerDetails(String partnerId, Boolean isPartner, String userLanguage){
        // System.debug('***Langcode : ' + userLanguage);
        List<CampaignEvents> banners = new List<CampaignEvents>();

        if (isPartner){
            if (Schema.sObjectType.PMP_Marketplace_Event_Partner__c.isAccessible()){
                 // PMD Fix

                List<PMP_Marketplace_Event_Partner__c> partnerEvents = [select PMP_Company_Id__c, PMP_Event_Id__r.Name
                                                                        from PMP_Marketplace_Event_Partner__c
                                                                        WHERE PMP_Company_Id__c = :partnerId AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c = true
                                                                        ORDER BY PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c DESC];
                List<String> partnerEventName = new List<String>();
                for (PMP_Marketplace_Event_Partner__c events : partnerEvents){
                    partnerEventName.add(events.PMP_Event_Id__r.Name);
                }
                List<PMP_Marketplace_Event__c> requiredMpEvents = [Select Name, PMP_Event_Banner_Language_Mapping__c, PMP_Event_Banner_Language__c, PMP_Marketplace_Desc__c, PMP_Marketplace_Event_End_Dt__c, PMP_Marketplace_Event_Start_Dt__c, PMP_Marketplace_Event_Tagline__c, PMP_Event_Screen_Reader_Txt__c
                                                                   FROM PMP_Marketplace_Event__c
                                                                   where Name IN:partnerEventName];

                Map<String, PMP_Marketplace_Event__c> titleEventMap = new Map<String, PMP_Marketplace_Event__c>();

                for (PMP_Marketplace_Event__c event : requiredMpEvents){
                    titleEventMap.put(event.Name, event);
                }

                for (PMP_Marketplace_Event_Partner__c events : partnerEvents){
                    CampaignEvents camp = New CampaignEvents();
                    camp.title = System.Label.PMP_Event_Banner_Part_of_Intel_Spotlight + ' ' + events.PMP_Event_Id__r.Name;
                    camp.linkUrl = System.Label.PMP_Marketplace_Community_URL + PMP_StaticConstants_Partner.Event_URL + events.PMP_Event_Id__c;

                    camp.linkLabel = PMP_Utility.replaceLabelWithDynamicValue(System.Label.PMP_Event_Banner_Participants, events.PMP_Event_Id__r.Name);
                    //camp.linkLabel = System.Label.PMP_ViewAll+' '+events.PMP_Event_Id__r.Name+' '+System.Label.PMP_Event_Banner_Participants;
                    PMP_Marketplace_Event__c event = titleEventMap.get(events.PMP_Event_Id__r.Name);

                    camp.image = PMP_StaticConstants_Partner.eventDefaultLogo;
                    //camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + 'en_US0692h000001Nea4AAC';
                    if (event.PMP_Event_Banner_Language_Mapping__c != NULL){
                        String baseLangCode = PMP_StaticConstants_Partner.languageCodeMap.get(event.PMP_Event_Banner_Language__c);
                        // system.debug('baseLangCode' + baseLangCode);
                        Map<String, String> langLogoMap = new Map<String, String>();
                        langLogoMap = (Map<String, String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c, Map<String, String>.class);
                        // system.debug('langLogoMap' + langLogoMap);
                        if (langLogoMap.get(userLanguage) != NULL){
                            camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(userLanguage);
                        } else if (langLogoMap.get('en_US') != NULL){
                            camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get('en_US');
                        } else if (langLogoMap.get(baseLangCode) != NULL){
                            camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(baseLangCode);
                        }
                    }
                    camp.imageAlt = System.Label.PMP_CampaignImageAlt;

                    banners.add(camp);
                }
            }
        } else{

            if (Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()){
                 // PMD Fix

                List<PMP_Marketplace_Event_Offering__c> offeringEvents = [select PMP_Offering_Id__c, PMP_Event_Id__r.Name
                                                                          from PMP_Marketplace_Event_Offering__c
                                                                          WHERE PMP_Offering_Id__c = :partnerId AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c = true
                                                                          ORDER BY PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c DESC];
                List<String> offeringEventName = new List<String>();
                for (PMP_Marketplace_Event_Offering__c events : offeringEvents){
                    offeringEventName.add(events.PMP_Event_Id__r.Name);
                }
                List<PMP_Marketplace_Event__c> requiredMpEvents = [Select Name, PMP_Event_Banner_Language_Mapping__c, PMP_Event_Banner_Language__c, PMP_Marketplace_Desc__c, PMP_Marketplace_Event_End_Dt__c, PMP_Marketplace_Event_Start_Dt__c, PMP_Marketplace_Event_Tagline__c, PMP_Event_Screen_Reader_Txt__c
                                                                   FROM PMP_Marketplace_Event__c
                                                                   where Name IN:offeringEventName];

                Map<String, PMP_Marketplace_Event__c> titleEventMap = new Map<String, PMP_Marketplace_Event__c>();

                for (PMP_Marketplace_Event__c event : requiredMpEvents){
                    titleEventMap.put(event.Name, event);
                }


                for (PMP_Marketplace_Event_Offering__c events : offeringEvents){
                    CampaignEvents camp = New CampaignEvents();
                    camp.title = System.Label.PMP_Event_Banner_Part_of_Intel_Spotlight + ' ' + events.PMP_Event_Id__r.Name;
                    camp.linkUrl = System.Label.PMP_Marketplace_Community_URL + PMP_StaticConstants_Partner.Event_URL + events.PMP_Event_Id__c;
                    camp.linkLabel = PMP_Utility.replaceLabelWithDynamicValue(System.Label.PMP_Event_Banner_Participants, events.PMP_Event_Id__r.Name);
                    //camp.linkLabel = System.Label.PMP_ViewAll+' '+events.PMP_Event_Id__r.Name+' '+System.Label.PMP_Event_Banner_Participants;
                    PMP_Marketplace_Event__c event = titleEventMap.get(events.PMP_Event_Id__r.Name);
                    camp.image = PMP_StaticConstants_Partner.eventDefaultLogo;
                    //camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + 'en_US0692h000001Nea4AAC';
                    if (userLanguage == 'zh_Hans_CN'){
                        userLanguage = 'zh_CN';
                    }
                    if (event.PMP_Event_Banner_Language_Mapping__c != NULL){
                        String baseLangCode = PMP_StaticConstants_Partner.languageCodeMap.get(event.PMP_Event_Banner_Language__c);
                        // system.debug('baseLangCode' + baseLangCode);
                        Map<String, String> langLogoMap = new Map<String, String>();
                        langLogoMap = (Map<String, String>)JSON.deserialize(event.PMP_Event_Banner_Language_Mapping__c, Map<String, String>.class);
                        // system.debug('langLogoMap' + langLogoMap);
                        if (langLogoMap.get(userLanguage) != NULL){
                            camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(userLanguage);
                        } else if (langLogoMap.get('en_US') != NULL){
                            camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get('en_US');
                        } else if (langLogoMap.get(baseLangCode) != NULL){
                            camp.image = System.Label.PMP_CommunityURLSuffix + 'file-asset/' + langLogoMap.get(baseLangCode);
                        }
                    }
                    camp.imageAlt = System.Label.PMP_CampaignImageAlt;
                    banners.add(camp);
                }
            }
        }
        // system.debug('banners' + banners);
        return banners;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static List<Id> getEventPartnerId(String eventId){

        List<Id> partnerIds = new List<String>();

        for (PMP_Marketplace_Event_Partner__c evePartner : [SELECT id, PMP_Company_Id__c, PMP_Event_Id__c
                                                            FROM PMP_Marketplace_Event_Partner__c
                                                            WHERE PMP_Event_Id__c = :eventId AND PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = false AND PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published]){
            partnerIds.add(evePartner.PMP_Company_Id__c);
        }

        return partnerIds;
    }*/

    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public static List<Id> getEventOfferingsId(String eventId){
        boolean isIntelEmployee = PMP_Utility.isIntelEmployee();
        //String pubstatus = PMP_StaticConstants_Partner.Published;
        String approvedstatus = PMP_StaticConstants_Partner.Approved;
        Integer prereleasecount = PMP_StaticConstants_MasterData.Zero;
        string novalue = PMP_Utility.getValue('PMP_PreReleaseCheck_Nm');
        List<Id> offIds = new List<String>();
        if (isIntelEmployee == true){
            for (PMP_Marketplace_Event_Offering__c eveOff : [SELECT id, PMP_Offering_Id__c, PMP_Event_Id__c
                                                             from PMP_Marketplace_Event_Offering__c
                                                             WHERE PMP_Event_Id__c = :eventId AND PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = false AND PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND ((PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Offering.PUBLISHED and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false) OR (PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :approvedstatus and PMP_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c > :prereleasecount and PMP_Offering_Id__r.PMP_Pre_Release_Check_Nm__c != null) OR (PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :approvedstatus and PMP_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c = :prereleasecount and PMP_Offering_Id__r.PMP_Pre_Release_Check_Nm__c = :novalue and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c != null) OR (PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :approvedstatus and PMP_Offering_Id__r.PMP_Working_Copy_Id__c = null and PMP_Offering_Id__r.PMP_Pre_Release_Item_Count_Num__c = :prereleasecount and PMP_Offering_Id__r.PMP_Pre_Release_Check_Nm__c = null and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c > TODAY))]){
                offIds.add(eveOff.PMP_Offering_Id__c);
            }

        } else{
            for (PMP_Marketplace_Event_Offering__c eveOff : [SELECT id, PMP_Offering_Id__c, PMP_Event_Id__c
                                                             from PMP_Marketplace_Event_Offering__c
                                                             WHERE PMP_Event_Id__c = :eventId AND PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c = false AND PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Offering.PUBLISHED and PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = false]){
                offIds.add(eveOff.PMP_Offering_Id__c);
            }
        }
        return offIds;
    }*/

}