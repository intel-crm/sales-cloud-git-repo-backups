/****************************************************************************************************************************************
* Class Name  : PMP_SearchFeaturedCarouselController 
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By : Tanzanite Team Infosys
* Developer       Date                     Description
* ----------------------------------------------------------------------------
* Nikhil          29/06/2019               Updated getFeaturedTabs method to use new Offering Translation object
*****************************************************************************************************************************************/
public with sharing class PMP_SearchFeaturedCarouselController extends PMP_SearchWrapperStore{
    
    //To get the all tabs information only not the offerings
    @AuraEnabled(cacheable=true)
    public static List<FeaturedProductTab> getFeaturedTabs(String langCode){
        List<String> featCatIds=new List<String>();
        
        // To get all featured category Pim Ids
        for (PMP_SearchFeaturedCategory_Config__mdt cat:[select PIM_Category_Id__c from PMP_SearchFeaturedCategory_Config__mdt WHERE PMP_Is_Active_Ind__c = true]){
            featCatIds.add(cat.PIM_Category_Id__c);
        }
        List<FeaturedProductTab> ftList= new List<FeaturedProductTab>();
        
        // Logic End
        List<PMP_Category__c> catList = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,(SELECT Id FROM Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published 
                                                                                                                                                   AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY LIMIT 1) FROM PMP_Category__c WHERE PMP_Active_Ind__c = true AND PMP_Partner_Product_Category_Cd__c IN:featCatIds ORDER BY PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        
        
        System.debug('catList'+catList);
        for (PMP_Category__c cat: catList){
            
            FeaturedProductTab ft=new FeaturedProductTab();
            ft.categoryId = cat.Id;
            ft.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
            SearchParams catPar = new SearchParams();
            catPar.cat =cat.Id;
            catPar.type = PMP_StaticConstants_Partner.product;
            ft.searchParams = catPar;
            ft.products = new List<Product>();
            ft.ctaTitle= PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode); //'View All "'+PMP_SearchUtilityController.getLocalisedName(cat)+'" solutions';
            if(!cat.Offering_Categories__r.isEmpty()){
                ftList.add(ft);
            }
            
            
        }
        
        //Adding Event tab
        //Fetching only one record to check if any offering is present in any active event
        List<PMP_Marketplace_Event_Offering__c> eventOfferingList = [select Id, Name, PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c, PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c, PMP_Offering_Id__r.Id 
                                                                     from PMP_Marketplace_Event_Offering__c 
                                                                     Where (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND  PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c > = :SYSTEM.NOW()) 
                                                                     AND (PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY)
                                                                     AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published 
                                                                     LIMIT 1];
        
        //Created Map of Event Id and list of Event records
        Map<String,List<PMP_Marketplace_Event__c>> eveEveOfferingMap = new Map<String,List<PMP_Marketplace_Event__c>>();
        
        //Fetching the list of active events.
        List<PMP_Marketplace_Event__c> eventList = [SELECT Name, PMP_Marketplace_Event_End_Dt__c, PMP_Marketplace_Event_Start_Dt__c, (SELECT Id FROM Marketplace_Event_Company_Offerings__r LIMIT 1),
                                                    (SELECT Id FROM Marketplace_Event_Partners__r LIMIT 1)
                                                    FROM PMP_Marketplace_Event__c WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW()) ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
        
        
        
        //Fetching single event offering record to make event tab visible.
        System.debug('eventOfferingList'+eventOfferingList);
        if(!eventOfferingList.isEmpty()){
 
            FeaturedProductTab fet=new FeaturedProductTab();
            
            fet.categoryId = PMP_StaticConstants_Partner.EVENT_TAB_ID;
            fet.label = System.Label.PMP_Marketplace_Event;
            //created new attribute eventTitle then ctaTitle for event view more.
            fet.eventTitle = System.Label.PMP_Marketplace_Event+' offerings'; //offerings should be replaced with custom label
            SearchParams fetPar = new SearchParams();
            
            fetPar.type = PMP_StaticConstants_Partner.product;
            //Putting the value of Event Id and list of event names in selected filters.
            fetPar.selectedFilters = new Map<String,List<String>>();  
            List<String> eventIds = new List<String>();   
            //Adding all event ids in list of ids for key = 'Marketplace_Event'
            for(PMP_Marketplace_Event__c event : eventList){
                if(event.Marketplace_Event_Company_Offerings__r.size() > 0 || event.Marketplace_Event_Partners__r.size() > 0) {
                    eventIds.add(event.id);
                }
            } 
            //Putting the eventIds against the 'Marketplace_Event' filter name.
            fetPar.selectedFilters.put('Marketplace_Event', eventIds);
            fet.searchParams = fetPar;
            fet.products = new list<Product>();
            //fet.ctaTitle = System.Label.PMP_Marketplace_Event+' offerings';//'View All "'+PMP_SearchUtilityController.getLocalisedName(cat)+'" solutions';
            ftList.add(fet);
        }
        
        return ftList;
    }
    
     //Created getEvents method for fetching the map of event Id and name along with search type 'Offerings' and list of 'offerings'
     public static Filter getEvents(Map<String, List<Id>> selectedFilter, String searchType, List<String> offerings){    //Extracting events
        
        
        List<PMP_Marketplace_Event__c> eventList = [SELECT Name from PMP_Marketplace_Event__c 
                                                    WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW())
                                                    ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
        
        Filter filter = new Filter();
        filter.tags = new List<tag>();
        filter.name ='Marketplace_Event';//Value of Filter
        filter.label = System.Label.PMP_Marketplace_Event;
        filter.type = 'tag';
        
        Map<String,Tag> eventTagMap = new Map<String,Tag>();
           System.debug('eventList'+eventList);
        for(PMP_Marketplace_Event__c eve: eventList){
            System.debug('eventList'+eventList);
            Tag tag = new Tag();
            tag.label = eve.Name;
            tag.value = eve.Id;
            tag.count = 0;
            tag.children  = new List<Tag>();
            filter.tags.add(tag);
            eventTagMap.put(eve.Id,tag);
        }
        eventTagMap = getEventOffCount(eventTagMap, offerings);
        
        for(PMP_Marketplace_Event__c eve: eventList){
            if(eventTagMap.containsKey(eve.Id)){
                if(eventTagMap.get(eve.Id).count == 0){
                    filter.tags.remove(filter.tags.indexOf(eventTagMap.get(eve.Id)));
                }
            }
        }           
        
        return filter;
        
        
    }  
    
    //Created getEventOffCount method for geting the count of the offerings associated with the particular event.
    public static Map<String,Tag> getEventOffCount(Map<String,Tag> eventTagMap, List<String> offerings){
        System.debug('offerings'+offerings);
        
        //Use List<AggregateResult> whenever using the group by in the query.
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
    
    //this method is used to get all the offering related to the catid passed in the input
    @AuraEnabled(cacheable=true)
    public static List<Product> getFeaturedOfferings(String catId, Integer prevLmt, Integer currentLmt, String langCode){
        
        Integer finalLimit = 15000;
        Integer offset = 0;
        if(prevLmt != null){
            offset = prevLmt;
        }
        if(currentLmt != null){
            finalLimit = currentLmt;
        }
        
        Map<String,Product> offProdMap=new Map<String,Product>();  //Map to assign offering Id with Product Wrapper 
        
        List<Product> prodList = new List<Product>();
        
        
        
        //Adding event offerings
        System.debug('catId'+catId);
        if(catId == PMP_StaticConstants_Partner.EVENT_TAB_ID){
            System.debug('In event tab');
            Set<String> disOffIds = new Set<String>();
            
            
            
         List<AggregateResult> distinctEveOffIds = [SELECT PMP_Offering_Id__c  FROM PMP_Marketplace_Event_Offering__c 
                                                    WHERE (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND  PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c > = :SYSTEM.NOW()) 
                                                    AND (PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY)
                                                    AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published 
                                                    Group by PMP_Offering_Id__c 
                                                    LIMIT :finalLimit OFFSET :offset];  
            System.debug('distinct size'+distinctEveOffIds.size());
            //System.debug('start date'+distinctEveOffIds.PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c);
            //if(distinctEveOffIds.size() > 0)
            if(!distinctEveOffIds.isEmpty()){
                for(AggregateResult pmevt:distinctEveOffIds){
                    String specId = (String)pmevt.get('PMP_Offering_Id__c');
                    disOffIds.add(specId);
                    System.debug('Distinct Id: '+specId);
                } 
            
            }
            System.debug('specId'+disOffIds);
            List<PMP_Marketplace_Event_Offering__c> eventOffIds = new List<PMP_Marketplace_Event_Offering__c>();
            try{
                eventOffIds = [SELECT Id, Name, PMP_Offering_Id__c,PMP_Offering_Id__r.Name, PMP_Offering_Id__r.PMP_Company_Id__c,PMP_Offering_Id__r.PMP_Company_Id__r.Name, PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c 
                               FROM PMP_Marketplace_Event_Offering__c 
                               WHERE PMP_Offering_Id__c IN : disOffIds
                               ORDER BY PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST 
                              ];
                system.debug('eventOffIds'+eventOffIds);
            }catch(Exception e){
                System.debug('Error while fetching the records for Event Offering object');
            }
            
            for (PMP_Marketplace_Event_Offering__c offevent :eventOffIds)
            {
                Product prod = new Product();
                prod.type = PMP_StaticConstants_Partner.product;
                prod.title = offevent.PMP_Offering_Id__r.Name;
                
                prod.partner = new Partner();
                prod.partner.id = offevent.PMP_Offering_Id__r.PMP_Company_Id__c;
                prod.partner.Name = offevent.PMP_Offering_Id__r.PMP_Company_Id__r.Name;
                
                prod.imageUrl = PMP_StaticConstants_Partner.staticProductUrl ;
                prod.id = offevent.PMP_Offering_Id__c;
                prod.featured = offevent.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c;
                prod.attributes=new List<Attribute>();
                prodList.add(prod);
                System.debug('Event Product id is :'+prod.id);
                System.debug('Event Product value is :'+prod);
                offProdMap.put(prod.Id,prod);
                System.debug('Event Product value is :'+prod);
            }
            
        }else{
            
            List<PMP_Partner_Offering_Category__c> allFeaturedOffIds = new List<PMP_Partner_Offering_Category__c>();
            try{
                allFeaturedOffIds = [SELECT PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,PMP_Offering_Id__r.Name,PMP_Offering_Id__r.PMP_Company_Id__c, PMP_Offering_Id__r.PMP_Company_Id__r.Name,
                                     PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c, PMP_Category_Id__r.Name, PMP_Category_Id__c
                                     FROM PMP_Partner_Offering_Category__c WHERE PMP_Category_Id__c =: catId and PMP_Category_Id__r.PMP_Active_Ind__c = true
                                     AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published 
                                     AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY
                                     ORDER BY PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST LIMIT :finalLimit OFFSET :offset];
            }catch(Exception e){
                System.debug('Error while fetching the records for Partner Offering Category object');
            } 
            
  
            
            for (PMP_Partner_Offering_Category__c offCat :allFeaturedOffIds)
            {
                Product prod=new Product();
                prod.type = PMP_StaticConstants_Partner.product;
                prod.title = offCat.PMP_Offering_Id__r.Name;
                
                prod.partner = new Partner();
                prod.partner.id = offCat.PMP_Offering_Id__r.PMP_Company_Id__c;
                prod.partner.Name = offCat.PMP_Offering_Id__r.PMP_Company_Id__r.Name;
                
                prod.imageUrl = PMP_StaticConstants_Partner.staticProductUrl ;
                prod.id = offCat.PMP_Offering_Id__c;
                prod.featured = offCat.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c;
                prod.attributes=new List<Attribute>();
                prodList.add(prod);
                offProdMap.put(prod.Id,prod);
            }
        }
        //Logic to fetch Offering name from Translation
        Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>();        
        List<PMP_Partner_Offering_Translation__c> offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                                                                  WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c IN :offProdMap.keySet()];
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
                offProdMap.get(trans.PMP_Partner_Offering_Id__c).title = PMP_SearchUtilityController.getLocalisedName(trans, '', langCode).unescapeHtml4();
                
            }else if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
                offProdMap.get(trans.PMP_Partner_Offering_Id__c).description = PMP_SearchUtilityController.getLocalisedName(trans, '', langCode);
            }
        }
        //Changes End   
        
        
        // Offering Image logic starts
        Map<String,String> offContProdMap=new Map<String,String>();
        List<String> conDocList = new List<String>();
        
        List<PMP_Partner_Offering_Resource__c> offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c in :offProdMap.keySet() and PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.THUMBNAIL_IMAGE and PMP_Partner_Offering_Image__c!=null and PMP_Resource_Sequence_Nbr__c = 0];      
        for(PMP_Partner_Offering_Resource__c offRes : offResList){
            offContProdMap.put(offRes.PMP_Offering_Id__c, offRes.PMP_Partner_Offering_Image__c);
            conDocList.add(offRes.PMP_Partner_Offering_Image__c);
        }
        
        //List<ContentDistribution> conDistList = PMP_SearchOfferingImageUtility.getContentDistList(conDocList); 
        Map<String, String> offAssetUrlMap = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocList);
        if(!conDocList.isEmpty()){
            for(String offId : offContProdMap.keySet()){
                if(offAssetUrlMap.containsKey(offContProdMap.get(offId))){
                    String assetName = offAssetUrlMap.get(offContProdMap.get(offId));
                    offProdMap.get(offId).imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';
                }
                
            }
        }
        
        
        /* if(!conDistList.isEmpty()){
for (ContentDistribution cd : conDistList){           
offProdMap.get(offContProdMap.get(cd.ContentDocumentId)).imageUrl = cd.ContentDownloadUrl;         
}       
}   */
        // Image logic ends 
        
        //To populate attributes related to offerings
        List<String> offIdList = new List<String>();
        offIdList.addAll(offProdMap.keySet());
        Map<String,List<Attribute>> offAttMap=PMP_SearchAttributeController.getOfferingAttributes(offIdList, langCode);
        for (String offId : offAttMap.keySet())
        {
            offProdMap.get(offId).attributes = offAttMap.get(offId);
        }
        //Change End
        
        //Logic to check prerelease item
        Map<String,Boolean> preIndMap = PMP_SearchProductController.isPreReleased(offIdList);
        for(String offId: preIndMap.keySet()){
            offProdMap.get(offId).prerelease = preIndMap.get(offId);
        }
        
        
        //
        //Changes End
        return offProdMap.values();
        // Return Map to get unique values.
    }
}