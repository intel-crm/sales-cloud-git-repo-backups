@isTest
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
    public PMP_SearchFeaturedCarouselController(){
        
    }
    
    //To get the all tabs information only not the offerings
//     @AuraEnabled(cacheable=true)
//     public static List<FeaturedProductTab> getFeaturedTabs(String langCode){
//         List<String> featCatIds=new List<String>();
        
//         // To get all featured category Pim Ids
//         for (PMP_SearchFeaturedCategory_Config__mdt cat:[select PIM_Category_Id__c from PMP_SearchFeaturedCategory_Config__mdt WHERE PMP_Is_Active_Ind__c = true]){
//             featCatIds.add(cat.PIM_Category_Id__c);
//         }
//         List<FeaturedProductTab> ftList= new List<FeaturedProductTab>();
        
//         // Logic End
//         List<PMP_Category__c> catList = new List<PMP_Category__c>();
//         if(Schema.sObjectType.PMP_Category__c.isAccessible() && Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
//             catList = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,
//                        (SELECT Id FROM Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE
//                         AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY LIMIT 1)
//                        FROM PMP_Category__c WHERE PMP_Active_Ind__c = true AND PMP_Partner_Product_Category_Cd__c IN:featCatIds
//                        ORDER BY PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
//         }
        
//         // System.debug('catList'+catList);
//         for (PMP_Category__c cat: catList){
            
//             FeaturedProductTab ft=new FeaturedProductTab();
//             ft.categoryId = cat.Id;
//             ft.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             ft.heading = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
//             SearchParams catPar = new SearchParams();
//             catPar.cat =cat.Id;
//             catPar.type = PMP_StaticConstants_Partner.product;
//             ft.searchParams = catPar;
//             ft.products = new List<Product>();
//             ft.cards = new List<Product>();
//             ft.ctaTitle= PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode); //'View All "'+PMP_SearchUtilityController.getLocalisedName(cat)+'" solutions';
//             if(!cat.Offering_Categories__r.isEmpty()){
//                 ftList.add(ft);
//             }
            
            
//         }
        
//         // system.debug('returnList : ' + ftList);
//         return ftList;
//     }
    
//     //Created getEvents method for fetching the map of event Id and name along with search type 'Offerings' and list of 'offerings'
//     public static Filter getEvents(Map<String, List<Id>> selectedFilter, String searchType, List<String> offerings){    //Extracting events
        
//         List<PMP_Marketplace_Event__c> eventList = new List<PMP_Marketplace_Event__c>();
//         if(Schema.sObjectType.PMP_Marketplace_Event__c.isAccessible()){
//             eventList = [SELECT Name from PMP_Marketplace_Event__c 
//                          WHERE (PMP_Marketplace_Event_Start_Dt__c <=: SYSTEM.NOW() AND PMP_Marketplace_Event_End_Dt__c >=: SYSTEM.NOW())
//                          ORDER BY PMP_Marketplace_Event_Start_Dt__c DESC];
//         }
//         Filter filter = new Filter();
//         filter.tags = new List<tag>();
//         filter.name ='Marketplace_Event';//Value of Filter
//         filter.label = System.Label.PMP_Marketplace_Event;
//         filter.type = 'tag';
        
//         Map<String,Tag> eventTagMap = new Map<String,Tag>();
//         // System.debug('eventList'+eventList);
//         for(PMP_Marketplace_Event__c eve: eventList){
//             // System.debug('eventList'+eventList);
//             Tag tag = new Tag();
//             tag.label = eve.Name;
//             tag.value = eve.Id;
//             tag.count = 0;
//             tag.children  = new List<Tag>();
//             filter.tags.add(tag);
//             eventTagMap.put(eve.Id,tag);
//         }
//         eventTagMap = getEventOffCount(eventTagMap, offerings);
        
//         for(PMP_Marketplace_Event__c eve: eventList){
//             if(eventTagMap.containsKey(eve.Id)){
//                 if(eventTagMap.get(eve.Id).count == 0){
//                     filter.tags.remove(filter.tags.indexOf(eventTagMap.get(eve.Id)));
//                 }
//             }
//         }           
        
//         return filter;
        
        
//     }  
    
//     //Created getEventOffCount method for geting the count of the offerings associated with the particular event.
//     public static Map<String,Tag> getEventOffCount(Map<String,Tag> eventTagMap, List<String> offerings){
//         // System.debug('offerings'+offerings);
        
//         //Use List<AggregateResult> whenever using the group by in the query.
//         List<AggregateResult> eventOffAggregate = new List<AggregateResult>();
//         if(Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()){
//             eventOffAggregate = [SELECT COUNT(PMP_Offering_Id__c)cnt,PMP_Event_Id__c
//                                  from PMP_Marketplace_Event_Offering__c
//                                  WHERE  PMP_Offering_Id__c in: offerings AND
//                                  (PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
//                                  GROUP BY PMP_Event_Id__c];
//         }
//         for(AggregateResult eventOff : eventOffAggregate){
//             String eveId = (String)eventOff.get('PMP_Event_Id__c');
//             if(eventTagMap.containsKey(eveId)){
//                 eventTagMap.get(eveId).count += (Integer)eventOff.get('cnt');
//             }
//         }
//         return eventTagMap;
//     }   
    
//     //this method is used to get all the offering related to the catid passed in the input
//     @AuraEnabled(cacheable=true)
//     public static List<Product> getFeaturedOfferings(String catId, Integer prevLmt, Integer currentLmt, String langCode){
//         System.debug('....getFeaturedOfferings-->langCode......'+langCode);
//         Integer finalLimit = 15000;
//         Integer offset = 0;
//         if(prevLmt != null){
//             offset = prevLmt;
//         }
//         if(currentLmt != null){
//             finalLimit = currentLmt;
//         }
//         String userLang = langCode;// userInfo.getLanguage(); updated for the US959732
//         Map<String,Product> offProdMap=new Map<String,Product>();  //Map to assign offering Id with Product Wrapper 
        
//         List<Product> prodList = new List<Product>();
        
//         // System.debug('catId'+catId);
//          if(String.IsNotBlank(catId)){      
            
//             List<PMP_Partner_Offering_Category__c> allFeaturedOffIds = new List<PMP_Partner_Offering_Category__c>();
//             try{
//                 if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
//                     allFeaturedOffIds = [SELECT Name,PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__c,PMP_Offering_Id__r.PMP_Offering_Id__c,PMP_Offering_Id__r.Name,PMP_Offering_Id__r.PMP_Company_Id__c, PMP_Offering_Id__r.PMP_Company_Id__r.Name,
//                                          PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c, PMP_Category_Id__r.Name, PMP_Category_Id__c,PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c,PMP_Offering_Id__r.PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c,PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Marketing_Profile_Id__c,
//                                          PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Account_Dsc__c,PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Account_Specialty__c,PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Partner_Program_nm__c,PMP_Offering_Id__r.PMP_Category_nm__c,PMP_Offering_Id__r.PMP_Sub_Category_nm__c,PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c 
//                                          FROM PMP_Partner_Offering_Category__c WHERE PMP_Category_Id__c =: catId and PMP_Category_Id__r.PMP_Active_Ind__c = true
//                                          AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE 
//                                          AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY
//                                          ORDER BY PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST LIMIT :finalLimit OFFSET :offset];
//                 }
//             }catch(Exception e){
//                 System.debug('Error while fetching the records for Partner Offering Category object');
//             } 
//             Map<String,String> offL2CatIdMap = new Map<String, String>();
//             Map<String,String> L3Values=new Map<String, String>();
//             List<String> partnerIds = new List<String>();
//             List<id> offeringIds = new List<id>();
//             for(PMP_Partner_Offering_Category__c evOff : allFeaturedOffIds){
//                 if(evOff.PMP_Offering_Id__r.PMP_Company_Id__c!=null){
//                     partnerIds.add(evOff.PMP_Offering_Id__r.PMP_Company_Id__c);
//                     offeringIds.add(evOff.PMP_Offering_Id__c);
//                 }
//             }
//             Map<String,PMP_Partner_Offering_Translation__c> offNameMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
//             Map<String,PMP_Partner_Offering_Translation__c> offDescMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
//             List<PMP_Partner_Offering_Translation__c> offTransList = new List<PMP_Partner_Offering_Translation__c>();
//             if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
//                 offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
//                                 WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c IN :offeringIds];
//             }
             
//             for(PMP_Partner_Offering_Translation__c trans: offTransList){
//                 if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
//                     offNameMap.put(trans.PMP_Partner_Offering_Id__c,trans);
//                 }else if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
//                     offDescMap.put(trans.PMP_Partner_Offering_Id__c,trans);
//                 }
                
//             }
//             //Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from Query 
//             List<PMP_Company__c> partners = new List<PMP_Company__c>();
//             if(Schema.sObjectType.PMP_Company__c.isAccessible()){
//                 partners = [SELECT id, PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, toLabel(PMP_Company_Lead_Gen_Language_Nm__c) from PMP_Company__c where id in :partnerIds];
//             }
//             //for contact partner visibility
//             Map<String, Boolean> contactVisMap = new Map<String,Boolean>();
//             contactVisMap = PMP_SearchUtilityController.isContactPartnerVisible(partners);
//             // system.debug('contactVisMap'+ contactVisMap);
//             //for contact partner visibility
            
//             Map<String, List<Options>> partnerLangOptionMap = new Map<String, List<Options>>();
            
//             for(PMP_Company__c partner : partners){
//                 List<Options> languagePrefs = new List<Options>();
//                 if(partner.PMP_Company_Lead_Gen_Language_Nm__c!=null){                       
//                     for(String prefLang : partner.PMP_Company_Lead_Gen_Language_Nm__c.split(';')){
//                         Options option = new Options();
//                         option.label = prefLang;
//                         option.value = prefLang;
//                         option.selected = true;
//                         languagePrefs.add(option);
                        
//                     }
//                 }
//                 partnerLangOptionMap.put(partner.Id, languagePrefs);
                
//             }
            
            
//           //  List<String> offIds = New List<String>();
//            // for (PMP_Partner_Offering_Category__c offCat :allFeaturedOffIds){    //offeringIds list already have offering Id's in line no:347
//            //      offIds.add(offCat.PMP_Offering_Id__c);           
//            // }
//             //Event related offerings eyebrow
//         	Map<String,String> eventofferingId= new Map<String,String>();
//             List<PMP_Marketplace_Event_Offering__c> offeringEvents = new List<PMP_Marketplace_Event_Offering__c>();
//             if(Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()){
//                 offeringEvents =[select PMP_Offering_Id__c,PMP_Event_Id__r.Name from PMP_Marketplace_Event_Offering__c  
//                                  WHERE PMP_Offering_Id__c IN :offeringIds AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c =true ORDER BY PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c DESC];
//             }
//             for(PMP_Marketplace_Event_Offering__c events: offeringEvents){
//             	if(!eventofferingId.containsKey(events.PMP_Offering_Id__c)){
//             		eventofferingId.put(events.PMP_Offering_Id__c,events.PMP_Event_Id__r.Name);
//             	}
//         	}
            
//             List<String> categoryListForL1L2L3= new List<String>();//update
            
//             for(PMP_Partner_Offering_Category__c evOff : allFeaturedOffIds){
//                 offL2CatIdMap.put(evOff.id, evOff.PMP_Offering_Id__r.PMP_Sub_Category_nm__c);
//                 If(evOff.PMP_Offering_Id__r.PMP_Sub_Category_nm__c!=null){
//                     categoryListForL1L2L3.addAll(evOff.PMP_Offering_Id__r.PMP_Sub_Category_nm__c.split(','));//TWC1824-260 - to handle multiple L2 subcategories
//                 }
//                 If(evOff.PMP_Offering_Id__r.PMP_Category_nm__c!=null){
//                     categoryListForL1L2L3.add(evOff.PMP_Offering_Id__r.PMP_Category_nm__c);//update
//                 }
//                 //added as part of l3 category
//                 String str= evOff.PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c;
//                 if(str!=null){
//                     String[] categories= str.split('\\|');
//                     if(categories.size()>3){
//                         String value= categories[3];
//                         L3Values.put(evOff.PMP_Offering_Id__c,value); 
//                     }
//                     else if(categories.size()==3){
//                         L3Values.put(evOff.PMP_Offering_Id__c,evOff.name); 
//                     }
                    
//                 }
//             }
//             categoryListForL1L2L3.addAll(L3Values.values());//update
//             List<PMP_Category__c> catL1L2L3List = [SELECT id, Name,PMP_Parent_Category_Id__r.Name, PMP_Category_Chinese_Nm__c, PMP_Category_Japanese_Nm__c from PMP_Category__c where Name IN:categoryListForL1L2L3];
//             Map<String,String> catL1L2L3NameIdMap= new Map<String,String>();
//             Map<String,String> catL1L2L3NameTrans=new Map<String,String>();

//             for(PMP_Category__c cat: catL1L2L3List){
//                 If(L3Values.Values().Contains(cat.Name)){
//                  catL1L2L3NameIdMap.put(cat.PMP_Parent_Category_Id__r.Name+'-'+cat.Name,cat.Id);
//             	}
//                 else {
//                     catL1L2L3NameIdMap.put(cat.Name,cat.Id);
//                 }
                
//                 //added the below line for translation values
//             catL1L2L3NameTrans.put(cat.Name, PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD,langCode)); 
//            // PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
        
//             }
//             List<PMP_Category__c> catL2List = new List<PMP_Category__c>();
//             if(Schema.sObjectType.PMP_Category__c.isAccessible()){
//                 catL2List = [SELECT id, Name from PMP_Category__c where Name IN:offL2CatIdMap.values()];
//             }
//             Map<String,String> catNameIdMap = new Map<String, String>();
//             for(PMP_Category__c cat : catL2List){
//                 catNameIdMap.put(cat.Name, cat.Id);
//             }
            
            
//             Boolean isSysAdmin=PMP_SearchUtilityController.isSysAdmin(); // added as part of the story US853176
//             Boolean isGuest=PMP_SearchUtilityController.isGuest();// added as part of the story US853176
//             for (PMP_Partner_Offering_Category__c offCat :allFeaturedOffIds)
//             {
//                 Product prod=new Product();
//                 prod.cardType = PMP_StaticConstants_Partner.product;
//                 prod.title = offCat.PMP_Offering_Id__r.Name;
                
//                 prod.partner = new Partner();
//                 prod.partner.partnerId = offCat.PMP_Offering_Id__r.PMP_Company_Id__c;
//                 prod.partner.partnerName = offCat.PMP_Offering_Id__r.PMP_Company_Id__r.Name;
//                 prod.partnerName = offCat.PMP_Offering_Id__r.PMP_Company_Id__r.Name;
//                 prod.partner.autoPartnerId = offCat.PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Marketing_Profile_Id__c;
//                 prod.imageUrl = PMP_StaticConstants_Partner.staticProductUrl ;
//                 prod.id = offCat.PMP_Offering_Id__c;
//                 prod.autoOffId = offCat.PMP_Offering_Id__r.PMP_Offering_Id__c;
//                 prod.featured = offCat.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c;
//                 prod.eyebrow = offCat.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c;
//                 prod.attributes=new List<Attribute>();
                
//                 //Added for 2.0 Changes - new attributes
//                 prod.partnerId = offCat.PMP_Offering_Id__r.PMP_Company_Id__c;
//                 prod.partner.partnerStatus = offCat.PMP_Offering_Id__r.PMP_Company_Id__r.PMP_IPA_Badge_Tier_Txt__c;
//                 // prod.partner.longDescription= offCat.PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Account_Dsc__c;
                
//                 // prod.description = offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c;
//                 // prod.longDescription = offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c;
//                 // added for translation fix -- balaji  
//                 String temp = '';
//                 String descrip = '';
//                 String tagline = '';
//                 string userLanguage = langCode;
                
//                 if(offDescMap.containsKey(offCat.PMP_Offering_Id__c)){
                    
//                     // system.debug('userLanguage'+userLanguage +'static constant'+PMP_StaticConstants_Partner.JA);
// 					//userLanguage == 'zh-Hans-CN' added for the US959732
//                     if (userLanguage == PMP_StaticConstants_Partner.ZH_CN || userLanguage == PMP_StaticConstants_Partner.ZH_HANS_CN && offDescMap.get(offCat.PMP_Offering_Id__c).PMP_Chinese_Txt__c != null){
//                         temp = offDescMap.get(offCat.PMP_Offering_Id__c).PMP_Chinese_Txt__c;
//                     }
//                     else if (userLanguage == PMP_StaticConstants_Partner.JA && offDescMap.get(offCat.PMP_Offering_Id__c).PMP_Japanese_Txt__c != null){
                        
//                         temp = offDescMap.get(offCat.PMP_Offering_Id__c).PMP_Japanese_Txt__c;
//                     }
//                     else if (offDescMap.get(offCat.PMP_Offering_Id__c).PMP_English_Txt__c != null){
                        
//                         temp = offDescMap.get(offCat.PMP_Offering_Id__c).PMP_English_Txt__c;
//                     }
//                     if (offDescMap.get(offCat.PMP_Offering_Id__c).PMP_Field_Nm__c == PMP_StaticConstants_Offering.Description)
//                     {
//                         descrip = temp;
//                     }
//                     else if (offDescMap.get(offCat.PMP_Offering_Id__c).PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')
//                     {
//                         tagline = temp;
//                     }
                    
//                 }
//                 String longDesc = descrip;
//                 prod.longDescription = longDesc != NULL ? longDesc : longDesc.stripHtmlTags();
//                 String shortDesc = descrip;
//                 prod.description = shortDesc != NULL ? shortDesc : shortDesc.stripHtmlTags();
//                 // added for translation fix -- balaji  ends               
                
                
//                 //prod.partnerByLine =offCat.PMP_Offering_Id__r.PMP_Category_nm__c ;
//                 prod.eyebrowTagline=System.Label.PMP_Featured;//if offCat.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c true, display featured
//                 if(eventofferingId.keySet().Contains(offCat.PMP_Offering_Id__c) && offCat.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c == false){
//                 	prod.eyebrow = true;
//             		prod.eyebrowTagline = eventofferingId.get(offCat.PMP_Offering_Id__c);
//             	}
//                 //for contact partner visibility
                
                
//                 if(isSysAdmin){ //updated as part of the story US853176
//                     prod.isContactPartnerVisible = true;
//                 }
//                 else{
//                     if(contactVisMap.containsKey(offCat.PMP_Offering_Id__r.PMP_Company_Id__c)){
//                         prod.isContactPartnerVisible = contactVisMap.get(offCat.PMP_Offering_Id__r.PMP_Company_Id__c);
//                     }
//                 }
//                 prod.contactPartnerVisible = prod.isContactPartnerVisible;
//                 //End of 2.0 Changes
//                 prod.categories = new List<String>();
//                 /*if(offCat.PMP_Offering_Id__r.PMP_Category_nm__c!=null)
// prod.categories.add(offCat.PMP_Offering_Id__r.PMP_Category_nm__c);
// if(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c!=null){
// if(L3Values.containsKey(offCat.PMP_Offering_Id__c))
// prod.categories.add(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c+' - '+L3Values.get(offCat.PMP_Offering_Id__c));
// else prod.categories.add(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c);
// }*/
                
                
//                 if(offCat.PMP_Offering_Id__r.PMP_Category_nm__c!=null){
//                     String catIdL1=catL1L2L3NameIdMap.get(offCat.PMP_Offering_Id__r.PMP_Category_nm__c);
//                     if(catIdL1!=null){
//                         CategoryLevel l1= new CategoryLevel();
//                         l1.Name=catL1L2L3NameTrans.get(offCat.PMP_Offering_Id__r.PMP_Category_nm__c); l1.Id=catIdL1;
//                         prod.categoryL1=l1;
//                     }
//                 }
                 

//                 if(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c!=null){
// 		    //TWC1824-260 - to handle multiple L2 subcategories
//                     List<CategoryLevel> cLevelList= new List<CategoryLevel>();
//                     List<String> subCategories=offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c.split(',');
//                     for(String subCat: subCategories){
//                         String catIdL2=catL1L2L3NameIdMap.get(subCat);
//                         if(catIdL2!=null){
//                             CategoryLevel l2= new CategoryLevel();
//                             l2.Name=catL1L2L3NameTrans.get(subCat); l2.Id=catIdL2;
//                             cLevelList.add(l2);
//                         }
//                     }
//                     prod.categoryL2=cLevelList;
                    
//                     if(L3Values.containsKey(offCat.PMP_Offering_Id__c)){
//                        // String catIdL3=catL1L2L3NameIdMap.get(L3Values.get(offCat.PMP_Offering_Id__c));
//                         String catIdL3 =catL1L2L3NameIdMap.get(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c+'-'+L3Values.get(offCat.PMP_Offering_Id__c));
//                         if(catIdL3!=null){
//                             CategoryLevel l3= new CategoryLevel();
//                             l3.Name=catL1L2L3NameTrans.get(L3Values.get(offCat.PMP_Offering_Id__c)); l3.Id=catIdL3;
//                             prod.categoryL3=l3;
                            
//                         }
//                     }
                    
//                 }
                
                
//                 if(catNameIdMap.containsKey(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c)){
//                     prod.compareCategoryId =catNameIdMap.get(offCat.PMP_Offering_Id__r.PMP_Sub_Category_nm__c);
//                 }
//                 prod.isGuest =isGuest;// added as part of the story US853176
//                 prod.leadLangPreference = PMP_SearchUtilityController.getLanguageMessage(partnerLangOptionMap.get(offCat.PMP_Offering_Id__r.PMP_Company_Id__c ));
//                 prodList.add(prod);
//                 offProdMap.put(prod.Id,prod);
//             }
//         }
//         //Logic to fetch Offering name from Translation
//         Map<String,PMP_Partner_Offering_Translation__c> offDescMap = new Map<String,PMP_Partner_Offering_Translation__c>();
        
//         Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>();  
//         List<PMP_Partner_Offering_Translation__c> offTransList = new List<PMP_Partner_Offering_Translation__c>();
//         if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
//             offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
//                             WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c IN :offProdMap.keySet()];
//         }
            
//         String descrip;
//         for(PMP_Partner_Offering_Translation__c trans: offTransList){
//             if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
//                 offProdMap.get(trans.PMP_Partner_Offering_Id__c).title = PMP_SearchUtilityController.getLocalisedName(trans, '', userLang).unescapeHtml4().stripHtmlTags();
                
//             }else if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
//                 // here need to add and check
//                 //userLang == 'zh-Hans-CN' added for the US959732
//                 if(userLang == PMP_StaticConstants_Partner.ZH_CN || userLang == PMP_StaticConstants_Partner.ZH_HANS_CN && trans.PMP_Chinese_Txt__c != null){
//                     descrip = trans.PMP_Chinese_Txt__c;
//                 }else if(userLang == PMP_StaticConstants_Partner.JA  && trans.PMP_Japanese_Txt__c != null){
//                     descrip = trans.PMP_Japanese_Txt__c;
//                 } else if (trans.PMP_English_Txt__c != null){
                    
//                     descrip = trans.PMP_English_Txt__c;
//                 }
                
//                 offProdMap.get(trans.PMP_Partner_Offering_Id__c).description = descrip.unescapeHtml4().stripHtmlTags();
                
//                 //offProdMap.get(trans.PMP_Partner_Offering_Id__c).description = PMP_SearchUtilityController.getLocalisedName(trans, '', userLang).unescapeHtml4().stripHtmlTags();
//             }
//         }
//         //Changes End   
        
        
//         // Offering Image logic starts
//         Map<String,String> offContProdMap=new Map<String,String>();
//         List<String> conDocList = new List<String>();
        
//         List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
//         if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
//             offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c in :offProdMap.keySet() 
//                           and (PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.THUMBNAIL_IMAGE OR PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.IMAGE)
//                           and PMP_Partner_Offering_Image__c!=null and PMP_Resource_Sequence_Nbr__c = 0 ORDER BY PMP_Resource_Type_Nm__c ASC];      
//         }
//         for(PMP_Partner_Offering_Resource__c offRes : offResList){
//             offContProdMap.put(offRes.PMP_Offering_Id__c, offRes.PMP_Partner_Offering_Image__c);
//             conDocList.add(offRes.PMP_Partner_Offering_Image__c);
//         }
        
//         //List<ContentDistribution> conDistList = PMP_SearchOfferingImageUtility.getContentDistList(conDocList); 
//         Map<String, String> offAssetUrlMap = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocList);
//         if(!conDocList.isEmpty()){
//             for(String offId : offContProdMap.keySet()){
//                 if(offAssetUrlMap.containsKey(offContProdMap.get(offId))){
//                     String assetName = offAssetUrlMap.get(offContProdMap.get(offId));
//                     offProdMap.get(offId).imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';
//                 }
                
//             }
//         }
        
        
//         /* if(!conDistList.isEmpty()){
// for (ContentDistribution cd : conDistList){           
// offProdMap.get(offContProdMap.get(cd.ContentDocumentId)).imageUrl = cd.ContentDownloadUrl;         
// }       
// }   */
//         // Image logic ends 
        
//         //To populate attributes related to offerings
//         List<String> offIdList = new List<String>();
//         offIdList.addAll(offProdMap.keySet());
//         Map<String,List<Attribute>> offAttMap= PMP_SearchAttributeController.getOfferingAttributes(offIdList, langCode);
//         for (String offId : offAttMap.keySet())
//         {
//             offProdMap.get(offId).partnerAttributes = offAttMap.get(offId);
//             offProdMap.get(offId).partner.attributes = offAttMap.get(offId);
//         }
//         //Change End
        
//         //Logic to check prerelease item
//         Map<String,Boolean> preIndMap = PMP_SearchProductController.isPreReleased(offIdList);
//         for(String offId: preIndMap.keySet()){
//             offProdMap.get(offId).prerelease = preIndMap.get(offId);
//             // offProdMap.get(offId).eyebrow = preIndMap.get(offId);
//         }
        
//         //
//         //Changes End
//         return offProdMap.values();
//         // Return Map to get unique values.
//     }
    
    
//     @AuraEnabled(cacheable=true)
//     public static List<FeaturedProductTab> getFeaturedTabList(String langCode){
//         // System.debug('..getFeaturedTabList-->lang...'+langCode);
//         String userLang = langCode;
//         List<String> featCatIds=new List<String>();
              
//         //cache logic for US787332 starts
//         List<FeaturedProductTab> finalList= new List<FeaturedProductTab>();
//         //Caching only for Guest users
//         String cacheLanguage;
//         Boolean isGuestUser = PMP_SearchUtilityController.isGuest();
//         // system.debug('isGuestUser'+isGuestUser);
        
//         //Add the guest user language to Cache as Key
//         if(langCode != null){
//             if(langCode.contains('_')){           
//                 cacheLanguage = langCode.replace('_', '');               
//             }else if(langCode.contains('-')){
//                  cacheLanguage = langCode.replace('-', ''); 
//             }
//             else{
//                 cacheLanguage = langCode;                
//             }
//         }
//           // Name of a partition and key
//         String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        
//        //Get the flag from Custom Metadata
//         String cacheFlag = PMP_Utility.getValue('Cache_Flag');
         
//         //Prepare the key
//         String cacheKey = 'Featured'+cacheLanguage; 
  
//         if (Cache.Org.contains(partitionInput+'.'+cacheKey)&& cacheFlag.equalsIgnoreCase('true') && isGuestUser) {
//         	finalList = (List<FeaturedProductTab>)Cache.Org.getPartition(partitionInput).get(cacheKey);
//             if(finalList.Size()>0){
//                  return finalList;
//             }
//         }
//         else{
//         //cache logic end
        
//         // To get all featured category Pim Ids
//         for (PMP_SearchFeaturedCategory_Config__mdt cat:[select PIM_Category_Id__c from PMP_SearchFeaturedCategory_Config__mdt WHERE PMP_Is_Active_Ind__c = true]){
//             featCatIds.add(cat.PIM_Category_Id__c);
//         }
        
//         List<FeaturedProductTab> ftList= new List<FeaturedProductTab>();
        
//         // Logic End
//         List<PMP_Category__c> catList = new List<PMP_Category__c>();
//         if(Schema.sObjectType.PMP_Category__c.isAccessible() && Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
//             catList = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,
//                        (SELECT Id FROM Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE 
//                         AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY LIMIT 1)
//                        FROM PMP_Category__c WHERE PMP_Active_Ind__c = true AND PMP_Partner_Product_Category_Cd__c IN:featCatIds
//                        ORDER BY PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
//         }
//         for (PMP_Category__c cat: catList){
            
//             FeaturedProductTab ft=new FeaturedProductTab();
//             ft.categoryId = cat.Id;
            
//             ft.heading = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, userLang);     
//      //       ft.cards = new List<Product>();
//             ft.cards = PMP_SearchFeaturedCarouselController.getFeaturedOfferings(ft.categoryId, null, 16, langCode);
//             ft.ctaLabel= System.label.PMP_ViewAll+' '+ PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, userLang);
//             if(!cat.Offering_Categories__r.isEmpty() && ft.cards.size() > 0){
//        //         ftList.add(ft);
//                   finalList.add(ft);
//             }    
//         }
        
//      //   for(FeaturedProductTab ft :ftList){
//      //       ft.cards = PMP_SearchFeaturedCarouselController.getFeaturedOfferings(ft.categoryId, null, 16, langCode);
//      //   }                                       //commented and added in 566
//      //   List<FeaturedProductTab> finalList= new List<FeaturedProductTab>(); 
        
//    /*     for(FeaturedProductTab ft :ftList){
//             if(ft.cards.size() > 0){
//                 finalList.add(ft);
//             }
//         }*/            //commented and added the logic in 570

//         //cache logic for US787332
//         try{
//         	String cacheTTLStr = PMP_Utility.getValue('Cache_TTL');
//         	Integer cacheTTL = Integer.valueOf(cacheTTLStr); // 48hrs
//             if(cacheFlag.equalsIgnoreCase('true') && isGuestUser){
//        		    Cache.Org.put(partitionInput+'.'+cacheKey, finalList,cacheTTL);
//                 System.debug('Cache.Featured::'+Cache.Org.get(partitionInput+'.'+cacheKey));
//         	}
//            }
//            Catch(Cache.ItemSizeLimitExceededException error){
//                 System.debug('Error due to Item Size Exceeded***********'+error.getMessage() +'at line '+error.getLineNumber()); 
//            }Catch(Cache.Org.OrgCacheException error){
//                 System.debug('Error due to Partition Exception***********'+error.getMessage() +'at line '+error.getLineNumber());   
//            }
//         }// cache logic end
        
//         return finalList;
//     }
    
//     @AuraEnabled(cacheable=true)
//     public static Map<String, List<Attribute>> getProductAttribute(String partnerId, String langCode) {
//         String userLang = userInfo.getLanguage();
//         Map<String, List<Attribute>> response = new Map<String, List<Attribute>>();
        
//         if(String.isNotBlank(partnerId)) {
//             //response = PMP_SearchAttributeController.getPartnerAttributes(new List<String> { partnerId }, userLang);
//         }
        
//         return response;
//     }
    
}