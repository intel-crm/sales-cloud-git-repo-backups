/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchContextualFilterController 
* Version     : 1.0 
* Created Date: 30-03-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Nikhil                   30-03-2019                    Method 'getRelatedContextualFilters' to build tree hierarchy and return contextual filters related to category
* Infosys - Nikhil                   30-03-2019                    Method 'getContextualFilterCount' to return map with count updated based on offerings found 
* Infosys - Nikhil                   30-03-2019                    Method 'contfilterResults' to return final offerings based on selected contextual filters
* Infosys - Nikhil                   30-03-2019                    Method 'contFilterOfferings' to return offerings based on selected specification or specification id

*******************************************************************************************************************************************************************************************************************************/

public with sharing class PMP_SearchContextualFilterController extends PMP_SearchWrapperStore{
    
    //Update by nikhil to increase performance
    
    // public static List<Filter> getAllContextualFilters(List<String> offerings, String langCode){
        
    //     List<Filter> filters = new List<Filter>();
    //     Map<String,Tag> specTagMap = new Map<String,Tag>();   
    //     Map<String,Filter> filterMap = new Map<String,Filter>();
    //     Map<String,Filter> returnMap = new Map<String,Filter>();
        
    //     String userLanguage = langCode;
    //     String specNameAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Specification__c','Name',userLanguage);
    //     if(String.isEmpty(specNameAPI)){
    //         specNameAPI = 'PMP_Specification_Name__c';
    //     }
    //     String specValNameAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Specification_Value__c','Name',userLanguage);
    //     if(String.isEmpty(specValNameAPI)){
    //         specValNameAPI = 'PMP_Specification_Value_Nm__c';
    //     }
        
    //     // System.debug('contextual count bef'+ Limits.getQueryRows());
    //     List<AggregateResult> offSpecs = [SELECT COUNT(PMP_Offering_Id__c)cnt, PMP_Specification_Id__c, PMP_Specification_Id__r.PMP_Parent_Specification_Id__c, PMP_Specification_Value_Id__c,
    //                                       PMP_Specification_Id__r.PMP_Specification_Name__c, PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,                           
    //                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c ,PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
    //                                       FROM PMP_Partner_Offering_Specification__c WHERE PMP_Offering_Id__c IN :offerings AND PMP_Specification_Id__c !=null AND PMP_Specification_Id__r.PMP_Active_Ind__c = TRUE 
    //                                       AND PMP_Specification_Id__r.PMP_Display_Type_Nm__c in :PMP_StaticConstants_Partner.DISPLAY_TYPES WITH SECURITY_ENFORCED
    //                                       GROUP BY PMP_Specification_Id__c, PMP_Specification_Value_Id__c, PMP_Specification_Id__r.PMP_Specification_Name__c ,
    //                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c,PMP_Specification_Id__r.PMP_Parent_Specification_Id__c,
    //                                       PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
    //                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c];
    //     // System.debug('contextual count aft'+ Limits.getQueryRows());
    //     for(AggregateResult offSpec: offSpecs){
    //         String specId = (String)offSpec.get('PMP_Specification_Id__c');
    //         String specParId = String.valueOf(offSpec.get('PMP_Parent_Specification_Id__c'));
    //         String specValId = (String)offSpec.get('PMP_Specification_Value_Id__c');
    //         if(!specTagMap.containsKey(specId) && String.isEmpty(specValId))
    //         {
    //             Tag tag = new Tag();
    //             tag.label = String.valueOf(offSpec.get(specNameAPI));
    //             if(String.isEmpty(tag.label)){
    //                 tag.label = (String)offSpec.get('PMP_Specification_Name__c');
    //             }
    //             tag.count = (Integer)offSpec.get('cnt');
    //             tag.value = specId;
    //             tag.parent = specParId;
    //             tag.children = new List<Tag>();
    //             specTagMap.put(tag.value,tag);
    //         }
            
    //         if(String.isNotEmpty(specValId)){
                
    //             if(!specTagMap.containsKey(specValId)){
                    
    //                 Tag tag = new Tag();
    //                 tag.label = String.valueOf(offSpec.get(specValNameAPI));
    //                 if(String.isEmpty(tag.label)){
    //                     tag.label = (String)offSpec.get('PMP_Specification_Value_Nm__c');
    //                 }
    //                 tag.count = (Integer)offSpec.get('cnt');
    //                 tag.value = specValId;
    //                 tag.parent = specId;
    //                 tag.children = new List<Tag>();
    //                 specTagMap.put(tag.value, tag);
    //             }  
    //         }
            
            
    //     } 
        
    //     //Added by Subash for US513622
    //     Set<String> specificationTypes = new Set<String>();
    //     for(PMP_Contextual_Filter_Model_Mapping__mdt specType : [SELECT PIM_Specification_Id__c, PMP_Is_Mulitlevel__c FROM PMP_Contextual_Filter_Model_Mapping__mdt WHERE PMP_Is_Mulitlevel__c = TRUE WITH SECURITY_ENFORCED]) {
            
    //         if(String.isNotBlank(specType.PIM_Specification_Id__c)) {
    //             specificationTypes.add(specType.PIM_Specification_Id__c.toLowerCase());
    //         }
    //     }
                
    //     List<PMP_Specification__c> specList = [SELECT Id,Name,PMP_Specification_Name__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Parent_Specification_Id__c =null and PMP_Active_Ind__c=true WITH SECURITY_ENFORCED];
        
    //     for(PMP_Specification__c spec: specList){
            
    //         Filter filter = new Filter();
            
    //         //Added by Subash for US513622
    //         if(spec.PMP_Partner_Product_Specification_Id__c != NULL && specificationTypes.contains(spec.PMP_Partner_Product_Specification_Id__c.toLowerCase())) {
    //             filter.type = 'multilevel';
    //             Filter.showClearLink = TRUE;
    //             Filter.autoexpand = TRUE;
    //         } else {
    //             filter.type = 'tag';
    //         }
            
    //         filter.name = spec.Id;
    //         filter.label = String.valueOf(spec.get(specNameAPI));
    //         if(String.isEmpty(filter.label)){
    //             filter.label = spec.PMP_Specification_Name__c;
    //         }
    //         filter.tags = new List<Tag>();
    //         filterMap.put(spec.id,filter);
            
    //     }
    //     //To build tree structure and populating the count
    //     for(Tag tag: specTagMap.values()){
            
    //         if(specTagMap.containsKey(tag.parent) && tag.parent != null){
    //             specTagMap.get(tag.parent).children.add(tag);
    //         }
    //         if(filterMap.containsKey(tag.parent) ){
    //             filterMap.get(tag.parent).tags.add(tag);
    //             if(!returnMap.containsKey(tag.parent)){
    //                 returnMap.put(tag.parent,filterMap.get(tag.parent));
    //             }
                
    //         }
    //     }
        
    //     return returnMap.values();
    // }
    
    /****************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Id> contFilterOfferings(List<String> filterIds,List<Id> offerings){
        
        List<PMP_Partner_Offering_Specification__c> offSpecList = new List<PMP_Partner_Offering_Specification__c>();
        
       // if(Schema.SObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
            offSpecList=[select PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c = :offerings
                         and PMP_Product_Specification_Cd__c!=null 
                         and (PMP_Specification_Id__c=:filterIds or PMP_Specification_Value_Id__c=:filterIds) WITH SECURITY_ENFORCED];
       // }
        
        Set<Id> offIdsSet=new Set<Id>();
        List<Id> offIdsList=new List<Id>(); 
        for (PMP_Partner_Offering_Specification__c offSpec: offSpecList)
        {
            offIdsSet.add(offSpec.PMP_Offering_Id__c);
        }
        offIdsList.addAll(offIdsSet);
        return offIdsList;
    }
    
    /*************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Id> contfilterResults(Map<String,List<Id>> selectedFilterMap,List<Id> offerings){
        
        //List<PMP_Partner_Offering_Specification__c> offSpecList = new List<PMP_Partner_Offering_Specification__c>();
        //String query = 'select PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where (PMP_Offering_Id__c IN :offerings and PMP_Product_Specification_Cd__c!=null)';
        //List<PMP_Specification__c> specList = [SELECT Id, Name FROM PMP_Specification__c WHERE PMP_Parent_Specification_Id__c =null and PMP_Active_Ind__c=true];
        List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
        if(Schema.sObjectType.PMP_Specification__c.isAccessible()){ // PMD Fix
        specList = [SELECT Id, Name FROM PMP_Specification__c WHERE PMP_Parent_Specification_Id__c =null and PMP_Active_Ind__c=true];
        }
        for(PMP_Specification__c spec: specList){
            if(selectedFilterMap.containsKey(spec.Name.deleteWhitespace()) && !selectedFilterMap.get(spec.Name.deleteWhitespace()).isEmpty()){
                offerings=contFilterOfferings(selectedFilterMap.get(spec.Name.deleteWhitespace()),offerings);
                //List<String> optionsSelected = selectedFilterMap.get(spec.id);
                //query += ' AND (PMP_Specification_Id__c IN :optionsSelected  or PMP_Specification_Value_Id__c IN :optionsSelected )';
                
            }
            
        }
    
        
        
       /* system.debug('query : '+ query);
        offSpecList = Database.query(query);
        
        List<Id> offIdsList=new List<Id>();
        Set<Id> offIdsSet = new Set<Id>();
        for (PMP_Partner_Offering_Specification__c offSpec: offSpecList)
        {
            offIdsSet.add(offSpec.PMP_Offering_Id__c);
        }
        offIdsList.addAll(offIdsSet);
        return offIdsList;*/
        return offerings;
        
    }
    
    
    /******************************************************************************************/
    //Method to get Partner contextual filter related to Offerings
    // @AuraEnabled(cacheable=true)
    // public static Filter getOfferingPartnerFilter(List<String> offerings){
        
    //     List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
        
    //     //if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
    //         offList = [SELECT Id , PMP_Company_Id__r.Name, PMP_Company_Id__c FROM PMP_Partner_Offering__c WHERE Id in :offerings AND PMP_Company_Id__r.PMP_Is_Published_Ind__c = true WITH SECURITY_ENFORCED ORDER BY PMP_Company_Id__r.Name]; 
            
    //     //}
    //     // system.debug('OFFLIST in Partner con' + offList);
    //     Map<String,Tag> compTagMap = new Map<String,Tag>();
    //     Filter filter = new Filter();
    //     filter.name = 'Partner'; //Do not replace with custom label
    //     filter.type = 'partnerfilter';
    //     filter.label = System.Label.PMP_Partner;
    //     filter.tags = new List<Tag>();
    //     for (PMP_Partner_Offering__c off: offList){
    //         if (!comptagMap.containsKey(off.PMP_Company_Id__c)){
    //             Tag tag = new Tag();
    //             tag.label = off.PMP_Company_Id__r.Name;
    //             tag.value = off.PMP_Company_Id__c;
    //             tag.count = 1;
    //             tag.children = new List<Tag>();
    //             compTagMap.put(off.PMP_Company_Id__c, tag);
    //         }
    //         else
    //         {
    //             compTagMap.get(off.PMP_Company_Id__c).count+=1;
    //         }
            
    //     }
    //     filter.count = compTagMap.keySet().size();
    //     filter.tags = compTagMap.values();
    //     return filter;
    // }
    /******************************************************************************************/
    
    //getting the partner contextual filters
    // @AuraEnabled(cacheable=true)
    // public static List<Filter> getPartnerContextualFilters(List<Id> partners, String langCode){
        
    //     List<Filter> filters = new List<Filter>();
        
    //     List<String> pimIds = new List<String>();
    //     pimIds.add(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
    //     pimIds.add(PMP_StaticConstants_Partner.PIM_APPLICATION_ID);
    //     filters.addAll(getPartnerCategoryFilters(pimIds,partners, langCode));
        
    //     Filter specialty = getPartnerSpecialtyFilter(partners);
    //     if(!specialty.tags.isEmpty()){
    //         filters.add(specialty);
    //     }
        
        
        
    //     Filter regFilter = getRegionPartner(PMP_StaticConstants_Partner.REGION_PIM_ID ,partners, langCode);
    //     if(!regFilter.tags.isEmpty()){
    //         filters.add(regFilter); 
    //     }
           
    //     return filters;
        
    // } 
    
    /********************************************************************************************/
    //Update by nikhil to increase performance
    public static Filter getRegionPartner(String pimId ,List<String> partners, String langCode){
        
        Filter filter = new Filter();
        filter.tags = new List<Tag>();
        Map<String,Tag> specTagMap = new Map<String,Tag>();
        
        PMP_Specification__c region = new PMP_Specification__c();
        List<AggregateResult> compRegList = new List<AggregateResult>();
        
        String userLanguage = langCode;
        String specAPIName = PMP_SearchUtilityController.getFieldApiName(PMP_StaticConstants_Partner.SPEC_OBJ_API, 'Name', userLanguage);
        if(String.isEmpty(specAPIName)){
            specAPIName = PMP_StaticConstants_Partner.SPEC_NAME_FIELD;
        }
        try{
            //if(Schema.sObjectType.PMP_Specification__c.isAccessible()){
                region = [SELECT Id,PMP_Specification_Name__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: pimId AND PMP_Active_Ind__c = TRUE WITH SECURITY_ENFORCED LIMIT 1];
                
           // }
            
            //if(Schema.sObjectType.PMP_Company_Region__c.isAccessible()){
                compRegList = [select COUNT(PMP_Company_Id__c)cnt, PMP_Specification_Id__c, PMP_Specification_Id__r.PMP_Specification_Name__c,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
                               PMP_Specification_Id__r.PMP_Parent_Specification_Id__c FROM PMP_Company_Region__c WHERE PMP_Company_Id__c in :partners AND PMP_Specification_Id__r.PMP_Active_Ind__c = TRUE WITH SECURITY_ENFORCED
                               GROUP BY PMP_Specification_Id__c, PMP_Specification_Id__r.PMP_Specification_Name__c,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
                               PMP_Specification_Id__r.PMP_Parent_Specification_Id__c];
                
            //}
            if(!compRegList.isEmpty()){
                
                filter.name = region.Id;
                filter.label = (String)region.get(specAPIName);
                if(String.isEmpty(filter.label)){
                    filter.label = region.PMP_Specification_Name__c;
                }
                filter.type='tag';
                filter.tags= new List<Tag>();
                
                for (AggregateResult reg:compRegList)
                {
                    String specId = (String)reg.get('PMP_Specification_Id__c');
                    if(!specTagMap.containsKey(specId)){
                        Tag tag = new Tag();
                        tag.label = String.valueOf(reg.get(specAPIName));
                        if(String.isEmpty(tag.label)) {
                            tag.label = (String)reg.get(PMP_StaticConstants_Partner.SPEC_NAME_FIELD);//  added for PMD fix     
                        }
                            
                        tag.value = specId;
                        tag.count = (Integer)reg.get('cnt');
                        
                        tag.parent = (String)reg.get('PMP_Parent_Specification_Id__c');
                        tag.children = new List<Tag>();
                        
                        specTagMap.put(specId,tag);
                        if(tag.parent == region.Id){
                            filter.tags.add(tag);                              
                        }
                            
                    }
                    
                } 
                
                //To Map Parent Child Relationship
                for(Tag tag :specTagMap.values()){
                    if(specTagMap.containsKey(tag.parent)){
                        specTagMap.get(tag.parent).children.add(tag);
                    }
                }
                
            }
            
        }catch(Exception e){
            System.debug(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
            throw new AuraHandledException(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
        }
        return Filter;
    }
    
    //Updated By Nikhil 29-Jul-2019
    /*public static Filter getPartnerCategoryFilters(String pimId, List<String> partners){

Filter filter = new Filter();
filter.tags= new List<Tag>();
PMP_Category__c cat = new PMP_Category__c();

Final String ansPimId = pimId + '%';

String query;
String ancestors;
try{
List<PMP_Partner_Category__c> partnerCatList = new List<PMP_Partner_Category__c>();

if(Schema.sObjectType.PMP_Category__c.isAccessible()){
cat = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c 
FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c = :pimId AND PMP_Active_Ind__c = true LIMIT 1];
}


filter.name = cat.Id;     //value
filter.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');
filter.type='tag';


if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){
partnerCatList = [SELECT Id,Name, PMP_Category_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c,PMP_Category_Id__r.Name, PMP_Category_Id__r.PMP_Parent_Category_Id__c 
FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c IN : partners AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE :ansPimId AND PMP_Category_Id__r.PMP_Active_Ind__c = true];

}

if(!partnerCatList.isEmpty()){
Map<String,Integer> countMap = new Map<String,Integer>();
for (PMP_Partner_Category__c partCat: partnerCatList)
{
if (!countMap.containsKey(partCat.PMP_Category_Id__c)){
countMap.put(partCat.PMP_Category_Id__c , 1);
}
else{
Integer count = countMap.get(partCat.PMP_Category_Id__c) + 1;
countMap.put(partCat.PMP_Category_Id__c , count);                    
}
}

Map<String,Tag> catTagMap = new Map<String,Tag>();

for (PMP_Partner_Category__c partCat:partnerCatList)
{
if(pimId == partCat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c){     //to check if parent is given category
if(!catTagMap.containsKey(partCat.PMP_Category_Id__c)){
Tag tag = new Tag();
tag.label = PMP_SearchUtilityController.getLocalisedName(partCat, '', '');
tag.value = partCat.PMP_Category_Id__c;
tag.count = 0;
if (countMap.containsKey(partCat.PMP_Category_Id__c))
tag.count = countMap.get(partCat.PMP_Category_Id__c);

tag.children = new List<Tag>();
filter.tags.add(tag);
catTagMap.put(partCat.PMP_Category_Id__c,tag);
}
} 
}
for (PMP_Partner_Category__c partCat:partnerCatList)
{

if(catTagMap.containsKey(partCat.PMP_Category_Id__r.PMP_Parent_Category_Id__c) && !catTagMap.containsKey(partCat.PMP_Category_Id__c)){
Tag tag = new Tag();
tag.label = PMP_SearchUtilityController.getLocalisedName(partCat, '', '');
tag.value = partCat.PMP_Category_Id__c;
tag.count = 0;
if (countMap.containsKey(partCat.PMP_Category_Id__c))
tag.count = countMap.get(partCat.PMP_Category_Id__c);

tag.children = new List<Tag>();
catTagMap.put(partCat.PMP_Category_Id__c,tag);   //To avoid Duplicate Sub-Region Nodes
if (catTagMap.containsKey(partCat.PMP_Category_Id__r.PMP_Parent_Category_Id__c)){
catTagMap.get(partCat.PMP_Category_Id__r.PMP_Parent_Category_Id__c).children.add(tag);
}
} 
}

}
}catch(Exception e){
System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
}

return filter;
}*/
    
    //Update by nikhil to increase performance
   /* public static List<Filter> getOfferingCategoryFilters(List<String> pimIds, List<String> offerings, String langCode){
        String userLanguage = langCode;
        // system.debug('userLanguage'+userLanguage);
        String catNameAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Category__c','Name',userLanguage); 
        // system.debug('catNameAPI'+catNameAPI);
        if(String.isEmpty(catNameAPI)){
            catNameAPI = 'Name';
        }
        
        Map<String,Tag> catTagMap = new Map<String,Tag>();
        // system.debug('catTagMap'+catTagMap);
        List<Filter> filters = new List<Filter>();
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        // System.debug('catList'+catList);
        String offCatQuery = '';
        Map<String,Filter> filterMap = new Map<String,Filter>();
        // System.debug('filterMap'+filterMap);
        List<AggregateResult> offeringCatList = new List<AggregateResult>();
        
        try{
           // if(Schema.sObjectType.PMP_Category__c.isAccessible()){
                catList = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,
              PMP_Category_Display_Sequence_Nbr__c           
                           FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c IN :pimIds AND PMP_Active_Ind__c = true WITH SECURITY_ENFORCED
                          Order By PMP_Category_Display_Sequence_Nbr__c];
                // System.debug('catList'+catList);
           // }
            offCatQuery = 'SELECT COUNT(PMP_Offering_Id__c)cnt, PMP_Category_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,'+                
        'PMP_Category_Id__r.PMP_Parent_Category_Id__c FROM PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c IN : offerings AND PMP_Category_Id__r.PMP_Active_Ind__c = true AND (';
            
            // System.debug('offCatQuery'+offCatQuery);
            for(PMP_Category__c cat: catList){
                Filter filter = new Filter();
                filter.name = cat.Id;     //value
                filter.label = String.valueOf(cat.get(catNameAPI));
                if(String.isEmpty(filter.label)){
                    filter.label = cat.Name;
                }
                filter.type='tag';
                if(catList.indexOf(cat) == 0){
                    offCatQuery += 'PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(cat.PMP_Partner_Product_Category_Cd__c) + '%\'';
                }else{
                    offCatQuery += ' OR PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(cat.PMP_Partner_Product_Category_Cd__c) + '%\'';
                }
                filter.tags = new List<Tag>();
                filterMap.put(cat.Id,filter);
            }
            offCatQuery += ') GROUP BY PMP_Category_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,'+
                'PMP_Category_Id__r.PMP_Parent_Category_Id__c';
            // system.debug('query :' + offCatQuery);
            
            
           // if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
           /*before PMD SOQL INJECTION FIX
                offeringCatList = Database.query(offCatQuery);
			before PMD SOQL INJECTION FIX
            
            string strquery = offCatQuery; //// added to avoid SOQL injection -- PMD Fix
            offeringCatList = Database.query(strquery);
           // } 
             
       
            
            
            if(!offeringCatList.isEmpty()){
                /* ------------To sort categories based on sequence Number US705467/US705466 ----------
                 Note: This is a workaround, as sf does not allow order by in aggregate queries
                 (PMP_Category_Display_Sequence_Nbr__c is numeric field and group by is not allowed for numeric fields )
                 Need to replace the offeringCatList with sortedOffCatList 
                
                List<AggregateResult> sortedOffCatList = sortAggregateCategories(offeringCatList);
                        
                
              //--------------------End of US705467/US705466 --------------  
                for (AggregateResult offCat:sortedOffCatList)
                {
                    String catId = (String)offCat.get('PMP_Category_Id__c');
                    if(!catTagMap.containsKey(catId)){
                        Tag tag = new Tag();
                        tag.label = String.valueOf(offCat.get(catNameAPI));
                        if(String.isEmpty(tag.label)){
                            tag.label = (String)offCat.get(PMP_StaticConstants_Partner.CAT_NAME_FIELD);// added as part of PMD Fix          
                        }
                            
                        tag.value = catId;
                        tag.count = (Integer)offCat.get('cnt');
                        
                        tag.parent = (String)offCat.get('PMP_Parent_Category_Id__c');
                        tag.children = new List<Tag>();
                        
                        catTagMap.put(catId,tag);
                        if(filterMap.containsKey(tag.parent)){
                            filterMap.get(tag.parent).tags.add(tag);
                        }
                    }
                    
                } 
                
                //To Map Parent Child Relationship
                for(Tag tag :catTagMap.values()){
                    if(catTagMap.containsKey(tag.parent)){
                        catTagMap.get(tag.parent).children.add(tag);
                    }
                }
                
            }
            
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
        }
        for(Filter filter :filterMap.values()){
            if(!filter.tags.isEmpty()){
                filters.add(filter);
            }
        }
        
        //filters.add(PMP_SearchFilterLazyLoading.getCategoryTags(langCode, offerings, pimIds[0], filterMap.get(catList[0].Id), catList));
        return filters;
    }
    
    //Update by nikhil to increase performance
    public static List<Filter> getPartnerCategoryFilters(List<String> pimIds, List<String> partners, String langCode){
        String userLanguage = langCode;
        // system.debug('userLanguage'+userLanguage);
        String catNameAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Category__c','Name',userLanguage); 
        if(String.isEmpty(catNameAPI)){
            catNameAPI = 'Name';
        }
        Map<String,Tag> catTagMap = new Map<String,Tag>();
        List<Filter> filters = new List<Filter>();
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        String ptnrCatQuery = '';
        Map<String,Filter> filterMap = new Map<String,Filter>();
        List<AggregateResult> ptnrCatList = new List<AggregateResult>();
        
        try{
           // if(Schema.sObjectType.PMP_Category__c.isAccessible()){
                catList = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c 
                           FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c IN :pimIds AND PMP_Active_Ind__c = true WITH SECURITY_ENFORCED];
           // }
            ptnrCatQuery = 'SELECT COUNT(PMP_Partner_Id__c)cnt, PMP_Category_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,'+
                'PMP_Category_Id__r.PMP_Parent_Category_Id__c FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c IN : partners AND PMP_Category_Id__r.PMP_Active_Ind__c = true AND (';
            
            for(PMP_Category__c cat: catList){
                Filter filter = new Filter();
                filter.name = cat.Id;     //value
                filter.label = String.valueOf(cat.get(catNameAPI));
                if(String.isEmpty(filter.label)){
                    filter.label = cat.Name;
                }
                filter.type='tag';
                if(catList.indexOf(cat) == 0){
                    ptnrCatQuery += 'PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(cat.PMP_Partner_Product_Category_Cd__c) + '%\'';
                }else{
                    ptnrCatQuery += ' OR PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE \'' + String.escapeSingleQuotes(cat.PMP_Partner_Product_Category_Cd__c) + '%\'';
                }
                filter.tags = new List<Tag>();
                filterMap.put(cat.Id,filter);
            }
            ptnrCatQuery += ') GROUP BY PMP_Category_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,'+
                'PMP_Category_Id__r.PMP_Parent_Category_Id__c';
            
            
            
           // if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){
                string strquery = ptnrCatQuery; // added to avoid SOQL injection -- PMD fix
                ptnrCatList = Database.query(strquery);
           // } 
            
            if(!ptnrCatList.isEmpty()){
                /* ------------To sort categories based on sequence Number US705467/US705466 ----------
                 Note: This is a workaround, as sf does not allow order by in aggregate queries
                 (PMP_Category_Display_Sequence_Nbr__c is numeric field and group by is not allowed for numeric fields )
                 Need to replace the ptnrCatList with sortedPtnrCatList 
        
        List<AggregateResult> sortedPtnrCatList = sortAggregateCategories(ptnrCatList);
                //--------------------End of US705467/US705466 -------------- 
        
        //To Add all the immediate child of given category
                
                for (AggregateResult ptnrCat: sortedPtnrCatList)
                {
                    String catId = (String)ptnrCat.get('PMP_Category_Id__c');
                    if(!catTagMap.containsKey(catId)){
                        Tag tag = new Tag();
                        tag.label = String.valueOf(ptnrCat.get(catNameAPI));
                        if(String.isEmpty(tag.label)){
                            tag.label = (String)ptnrCat.get(PMP_StaticConstants_Partner.CAT_NAME_FIELD);// added as part of PMD fix
                        }
                           
                        tag.value = catId;
                        tag.count = (Integer)ptnrCat.get('cnt');
                        
                        tag.parent = (String)ptnrCat.get('PMP_Parent_Category_Id__c');
                        tag.children = new List<Tag>();
                        
                        catTagMap.put(catId,tag);
                        if(filterMap.containsKey(tag.parent)){
                            filterMap.get(tag.parent).tags.add(tag);
                        }
                    }
                    
                } 
                
                //To Map Parent Child Relationship
                for(Tag tag :catTagMap.values()){
                    if(catTagMap.containsKey(tag.parent)){
                        catTagMap.get(tag.parent).children.add(tag);
                    }
                }
                
            }
            
        }catch(Exception e){
            System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
        }
        for(Filter filter :filterMap.values()){
            if(!filter.tags.isEmpty()){
                filters.add(filter);
            }
        }
        return filters;
    }
*/    
    
    //Created by Nikhil 12-Aug-2019 //Modified by Nikhil 26-Aug-2019
    /*public static Filter getPartnerSpecialtyFilter(List<String> partners){
        
        //Mapping between spec value and translated label. We will use valueLabelMap to fetch translation
        Map<String,String> valueLabelMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
        }
        
        //Created by Kartik
        //We will use valueIdMap to fetch metadata record id for each specialty
        Map<String,Id> valueIdMap = new Map<String,Id>();
      
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE WITH SECURITY_ENFORCED];
        for(PMP_Partner_Specialty__c specData: specialtyList){
            valueIdMap.put(specData.Name, specData.Id); 
        }
        //End
        
        List<String> specList = new List<String>();
        Map<String,Tag> specTagMap = new Map<String,Tag>();
        Map<String, Integer> valueCountMap = new Map<String, Integer>();
        Filter filter = new Filter();
        filter.tags = new List<Tag>();
        filter.name = 'Specialty_Partner';       //Value of Filter
        filter.label = System.Label.PMP_Specialty;
        filter.type = 'tag';
        List<PMP_Company__c> companyList = new List<PMP_Company__c>();
        
            companyList = [SELECT PMP_Account_Specialty__c from PMP_Company__c WHERE id in :partners AND PMP_Account_Specialty__c != null WITH SECURITY_ENFORCED ];
        
        
        for(PMP_Company__c partner:companyList){
            specList.addAll(partner.PMP_Account_Specialty__c.split(';'));
        }
        for(String spec : specList){
            if(valueLabelMap.containsKey(spec) && !spec.equals(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                //if(!spec.equals(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                    if(!specTagMap.containsKey(spec)){
                        Tag tag = new Tag();
                        tag.label = valueLabelMap.get(spec);
                        tag.value = valueIdMap.get(spec);    //Added by Kartik
                        tag.count= 1;
                        tag.children  = new List<Tag>();
                        filter.tags.add(tag);
                        specTagMap.put(spec,tag);
                    }else{
                        specTagMap.get(spec).count += 1;
                    }
                //}
            }
        }
        return filter;
    }*/
    
    
    
    
    //Created by Kartik 07-Jan-2020
    /*@AuraEnabled(cacheable=true)
    public static Filter getPartnerSpecialtyFilterOfferings(List<String> offerings){
        
        Map<String,String> valueLabelMap = new Map<String,String>();
        //Map is passing label and value of the picklist
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();  
        //Schema.DescribeFieldResult is used to read the values of the picklist
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //Storing the picklist values in a list
        for( Schema.PicklistEntry pickListVal : ple){
            valueLabelMap.put(pickListVal.getValue(),pickListVal.getLabel());
        }
        //adding the label and values in the map.
        List<String> specList = new List<String>();
        //Wrapper class data fetching
        Map<String,Tag> specTagMap = new Map<String,Tag>();
        Map<String, Integer> valueCountMap = new Map<String, Integer>(); //Map for count
        Filter filter = new Filter();
        filter.tags = new List<Tag>();
        filter.name = 'Specialty_Offering';       //Value of Filter
        filter.label = System.Label.PMP_Specialty; //replace with custom label
        filter.type = 'tag';
        
        //Added as part of US603233 - 03/05/2020
        //valueIdMap is used to fetch metadata record id for each specialty
        Map<String,Id> valueIdMap = new Map<String,Id>();
        
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE WITH SECURITY_ENFORCED];
        for(PMP_Partner_Specialty__c specData: specialtyList){
            valueIdMap.put(specData.Name, specData.Id); 
        }
        //End
        
        List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();

            offList = [SELECT PMP_Company_Id__r.PMP_Account_Specialty__c FROM PMP_Partner_Offering__c WHERE Id in :offerings AND PMP_Company_Id__r.PMP_Account_Specialty__c != null WITH SECURITY_ENFORCED]; 

        
        for(PMP_Partner_Offering__c offering:offList){    
            if(offering.PMP_Company_Id__r.PMP_Account_Specialty__c != null){
                specList.addAll(offering.PMP_Company_Id__r.PMP_Account_Specialty__c.split(';'));
            }
        }
        for(String spec : specList){
            if(valueLabelMap.containsKey(spec) && !spec.equals(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                //if(!spec.equals(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)){
                    if(!specTagMap.containsKey(spec)){
                        //If satisfies the condition add to Map.
                        Tag tag = new Tag();
                        tag.label = valueLabelMap.get(spec);
                        //tag.value = spec.replace(' ','_');
                        tag.value = valueIdMap.get(spec);    //Added by Kartik
                        tag.count= 1;
                        tag.children  = new List<Tag>();
                        filter.tags.add(tag);
                        specTagMap.put(spec,tag);
                    }else{
                        //If already satisfying the condition, take the count 
                        specTagMap.get(spec).count += 1;
                    }
                //}
            }
        }
        return filter;
    }
    */
    //Created by Kartik
    //Method to fetch offerings based on the Specialty selected//
    
    public static List<Id> getOfferingSpecialtyResults(List<String> optionList){
        List<Id> offeringIds = new List<Id>();
        List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        List<Id> result = null;
        
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c where id in:optionList AND PMP_Is_Active_Ind__c = TRUE WITH SECURITY_ENFORCED];
        optionList = new List<String>();
        for(PMP_Partner_Specialty__c specM : specialtyList){
            optionList.add(specM.Name);
        }
        
        if (!optionList.isEmpty()){
            String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE PMP_Company_Id__r.PMP_Account_Specialty__c INCLUDES (';
            
            
            for(String option :optionList){
                if(optionList.indexOf(option) == optionList.size()-1){
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\''+ ',';
                }
                
                
            }
            query += ')';
            string strquery = query; // added to avoid SOQL injection - PMD Fix
            offeringList = Database.query(strquery);
            
            for(PMP_Partner_Offering__c offering : offeringList){
                offeringIds.add(offering.Id); 
            }
            result = offeringIds;
        }
        return result;
    }
    
    //Method to fetch offerings based on the Partner program selected
    public static List<Id> getOfferingPartnerProgramResults(List<String> optionList1){
        
        //List<Id> offIds=new List<Id>();
        List<Id> offeringIds= new List<Id>();
        List<Id> result = null;
        List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        
        if (!optionList1.isEmpty()){
            String query =  'SELECT id FROM PMP_Partner_Offering__c WHERE PMP_Company_Id__r.PMP_Partner_Program_nm__c  INCLUDES (';
            
            for(String option :optionList1){
                //Checking the indexof substring
                if(optionList1.indexOf(option) == optionList1.size()-1){
              
                    query += '\'' + String.escapeSingleQuotes(option) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option) + '\''+ ',';
                }
                
                
            }
            query += ') OR PMP_Company_Id__r.PMP_Account_Specialty__c  INCLUDES (';
            for(String option :optionList1){
                if(optionList1.indexOf(option) == optionList1.size()-1){
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\'';
                }else{
                    query += '\'' + String.escapeSingleQuotes(option.replace('_',' ')) + '\''+ ',';
                }
                
                
            }
            query+=')';
            
            string strquery = query;// added to avoid SOQL injection -- PMD Fix
            offeringList = Database.query(strquery);
            
            
            
            for( PMP_Partner_Offering__c offering : offeringList )
            {
                offeringIds.add(offering.Id);
            }
            result = offeringIds;
        }
        return result;
    }
    
    //Add Partner Program Filter
    /*public static Filter getOfferingPartnerProgramFilter(List<String> offerings,String langCode){
        
        Map<String,Integer> countMap = new Map<String,Integer>(); //build count
        List<String> progSpecList = new List<String>(); //List of Values
        
        List<PMP_Partner_Offering__c> offList = [SELECT id, PMP_Company_Id__r.PMP_Partner_Program_nm__c,PMP_Company_Id__r.PMP_Account_Specialty__c from PMP_Partner_Offering__c where id in: offerings WITH SECURITY_ENFORCED];
        
        for(PMP_Partner_Offering__c off : offList){
            if(off.PMP_Company_Id__r.PMP_Partner_Program_nm__c!=null){
                progSpecList.addAll(off.PMP_Company_Id__r.PMP_Partner_Program_nm__c.split(';'));
                
            }
            if(off.PMP_Company_Id__r.PMP_Account_Specialty__c!=null && off.PMP_Company_Id__r.PMP_Account_Specialty__c.contains(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program))
            {
                progSpecList.add(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program);
            }
        }
        // system.debug('specList' + progSpecList);
        
        for(String progSpec: progSpecList){
            if(countMap.get(progSpec) == null){
                countMap.put(progSpec,1);
                
            }else{
                Integer count = countMap.get(progSpec)+1;//increment count
                countMap.put(progSpec,count);//updating the count
            }
            
        }
        
        Filter filter = new Filter();
        filter.tags = new List<Tag>();
        filter.name = 'Partner_Program_Offering';//Value of Filter
        filter.label = System.Label.PMP_Partner_Programs; //replace with custom label
        filter.type = 'tag';
        
        
     /*   String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name',langCode);
        if(String.isEmpty(partnerProgName)){
            partnerProgName = 'PMP_Partner_Program_Name__c';
        }
        List<PMP_SearchPartnerProgram_Config__mdt> ppList = new List<PMP_SearchPartnerProgram_Config__mdt>();
        
        ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
                  PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c,
                  PMP_Partner_Program_Desc__c, PMP_Partner_Program_Desc_Chinese__c, PMP_Partner_Program_Desc_Japanese__c
                  FROM PMP_SearchPartnerProgram_Config__mdt
                  WHERE Active__c = true WITH SECURITY_ENFORCED ORDER BY PMP_Partner_Program_Name__c ];
        
        
        for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){
            Tag tag = new Tag();
            tag.label = String.valueOf(pp.get(partnerProgName)); //translated value
            tag.value = pp.PMP_Partner_Program_value__c;
            
            tag.children = new List<Tag>();
            if(countMap.get(pp.PMP_Partner_Program_value__c)!=null){
                tag.count = countMap.get(pp.PMP_Partner_Program_value__c);
                filter.tags.add(tag);
            } 
        } 
        
        List<PMP_Partner_Program__c> ppList = new List<PMP_Partner_Program__c>();
        
        if(Schema.sObjectType.PMP_Partner_Program__c.isAccessible()){
        	ppList = [select id,Name, PMP_Is_Active_Ind__c, PMP_Partner_Program_Value_Txt__c, PMP_Partner_Program_Desc__c, PMP_Partner_Program_Desc_Chinese__c, 
                  	  PMP_Partner_Program_Desc_Japanese__c, PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c from PMP_Partner_Program__c 
                      WHERE PMP_Is_Active_Ind__c = true ORDER BY Name];
        }
        
        for(PMP_Partner_Program__c pp : ppList){
            String progname=PMP_SearchUtilityController.getLocalisedName(pp, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
            Tag tag = new Tag();
            tag.label = progname; //translated value
            tag.value = pp.PMP_Partner_Program_Value_Txt__c;
            
            tag.children = new List<Tag>();
            if(countMap.get(pp.PMP_Partner_Program_Value_Txt__c)!=null){
                tag.count = countMap.get(pp.PMP_Partner_Program_Value_Txt__c);
                filter.tags.add(tag);
            } 
        } 
        
        Tag tag = new Tag();
        tag.label =System.Label.PMP_Partner_Directory_title3; //translated value
        tag.value =PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program.replace(' ','_');
        
        tag.children = new List<Tag>();
        if(countMap.get(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program)!=null){
            tag.count = countMap.get(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program);
            filter.tags.add(tag);
            
        } 
        
        return filter;
    }*/
    
/*@Description: To sort the aggregate query of Offering category or Partner category object
                based on the PMP_Category_Display_Sequence_Nbr__c field of the Category Object.
                US705467/US705466
                     
*/    
    public static List<AggregateResult> sortAggregateCategories(List<AggregateResult> nonSortedList){
        Map<id,AggregateResult> catAggMap = New Map<id,AggregateResult>();
        List<AggregateResult> sortedCatList = New List<AggregateResult>();
        //fetch all categories, order by sequence number 
        List<PMP_Category__c> allCatList = [Select id,PMP_Category_Display_Sequence_Nbr__c 
                                            from PMP_Category__c Where PMP_Active_Ind__c = true WITH SECURITY_ENFORCED
                                            Order By PMP_Category_Display_Sequence_Nbr__c ];
        
        
        //iterate over the nonSortedList and populate catAggMap. 
        //Category.id will be the key for the map and Aggregate result will be the value.
        for (AggregateResult offCat:nonSortedList){
            catAggMap.put((id)offCat.get('PMP_Category_Id__c'),offCat);
        }
        //iterate over the sorted Category List(allCatList), and populte the new list.
        // (sortedOffCatList)this new list is now sorted as per the sequence number
        for(PMP_Category__c cat : allCatList){
            if(catAggMap.containsKey(cat.id)){
                sortedCatList.add(catAggMap.get(cat.id));
            }
          
        }
        return sortedCatList;
    }
    
    /* Method to fetch the partner specialities taxonomy*/
/*    @AuraEnabled(cacheable=true)
    public static Map<string,Taxonomy> getpartnerSpecialties(String langCode){
        Map<string,Taxonomy> response= new Map<string,Taxonomy>();
       // Map<id,TaxonomyRecord> listings = new Map<id,TaxonomyRecord>(); 
         Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>(); 
       
        Taxonomy taxanomy= new Taxonomy();
        taxanomy.name='partnerSpecialties';
        taxanomy.apiName='PMP_Partner_Specialty__c';//PMP_Partner_Specialty__c
        taxanomy.label='Partners by Specialty';
        taxanomy.viewAllLabel='View all partners by Specialty';
        taxanomy.svgIconUrl=null;
        taxanomy.topLevelIds=null;
        taxanomy.records=listings;
        
        List<PMP_Specialty_Images__mdt> metaDataList = new List<PMP_Specialty_Images__mdt>();
        metaDataList = [select PMP_Account_Specialty_Name__c,PMP_Specialty_Name_Chinese__c,PMP_Specialty_Name_Japanese__c, URL__c from PMP_Specialty_Images__mdt];
        Map<String,String> metadataMap = new Map<String,String>();
        for(PMP_Specialty_Images__mdt md: metaDataList){
            metadataMap.put(md.PMP_Account_Specialty_Name__c, md.URL__c);
        }
        
        system.debug('.....metadataMap.........'+metadataMap);
        
        List<Id> topLevelIds= new List<Id>();
        //List<PMP_Specialty_Images__mdt> metaDataList = new List<PMP_Specialty_Images__mdt>();
        List<PMP_Partner_Specialty__c> specialtyList = [SELECT name,PMP_Partner_Specialty_Chinese_Nm__c, PMP_Partner_Specialty_Japanese_Nm__c, Id, PMP_Partner_Specialty_Chinese_Dsc__c, PMP_Partner_Specialty_English_Dsc__c, PMP_Partner_Specialty_Japanese_Dsc__c, PMP_Is_Active_Ind__c FROM PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE order by name];
        
        List<PMP_Company__C> partners = new  List<PMP_Company__C>();
        partners = [select toLabel(PMP_Account_Specialty__c) from PMP_Company__c where PMP_Account_Specialty__c != null AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published];
        system.debug('....partners.....'+partners);    
        List<String> accountSpecilaities= new List<String>();
        for(PMP_Company__C c: partners){
            accountSpecilaities.add(c.PMP_Account_Specialty__c);
        }
        System.debug('...accountSpecilaities.....'+accountSpecilaities);
        
        //System.debug('....specialtyList....'+specialtyList);
        
        for(PMP_Partner_Specialty__c md : specialtyList){
            if(accountSpecilaities.contains(md.name))
            {
                if (topLevelIds.size()<5){
                    topLevelIds.add(md.id);
                }
                TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
                //taxonomyRecord.label = 'label';
                //taxonomyRecord.viewAllLabel='view all'+'Dummy Name';
                taxonomyRecord.id=md.id;
                // taxonomyRecord.description=md.PMP_Partner_Specialty_English_Dsc__c;
                taxonomyRecord.children=null;
                taxonomyRecord.svgIconUrl=(string) metadataMap.get(md.name);
                taxonomyRecord.parentId=null;
                taxonomyRecord.viewAllLabel='view all label';
                
                
                if (langCode == PMP_StaticConstants_Partner.ZH_CN && String.isNotEmpty(md.PMP_Partner_Specialty_Chinese_Nm__c)){
                    taxonomyRecord.label=md.PMP_Partner_Specialty_Chinese_Nm__c;
                    taxonomyRecord.description=md.PMP_Partner_Specialty_Chinese_Dsc__c;
                    // taxonomyRecord.viewAllLabel='view all label';
                }
                else if (langCode == PMP_StaticConstants_Partner.JA && String.isNotEmpty(md.PMP_Partner_Specialty_Japanese_Nm__c)){
                    taxonomyRecord.label=md.PMP_Partner_Specialty_Japanese_Nm__c;
                    taxonomyRecord.description=md.PMP_Partner_Specialty_Japanese_Dsc__c;
                    //taxonomyRecord.viewAllLabel='view all label';
                    
                    
                    
                }
                else if(String.isNotEmpty(md.name)){
                    taxonomyRecord.label=md.name;
                    taxonomyRecord.description=md.PMP_Partner_Specialty_English_Dsc__c;
                    // taxonomyRecord.viewAllLabel='view all label';
                }
                listings.put(md.id,taxonomyRecord);
            }   
            
        }
        taxanomy.records=listings;
        System.debug('..topLevelIds..'+topLevelIds);
        taxanomy.topLevelIds=topLevelIds;
        response.put('partnerSpecialties',taxanomy);
        
        System.debug('.....response.....'+response);
        return response;
        
    }*/
        
    /* Method to fetch the partner tier taxonomy*/
/*    @AuraEnabled(cacheable=true)
    public static Map<string,Taxonomy> getPartnertierFilters(String langCode){

        Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
        Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>(); 
      
        
        Taxonomy taxonomy= new Taxonomy();
        taxonomy.name='partnerTierFilters';
        taxonomy.apiName='Partner_Tier';
        taxonomy.label='Partners Tier';
        taxonomy.viewAllLabel='View all partners by Tier';
        taxonomy.svgIconUrl=null;
        taxonomy.topLevelIds=null;
        taxonomy.records=listings;
       
       Map<String,String> valueLabelMap = new Map<String,String>();
       
       Schema.DescribeFieldResult fieldResult = Account.Core_IPA_Badge_Tier__c.getDescribe();      
       List<Schema.PicklistEntry> tiers = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry tierValue : tiers){
            valueLabelMap.put(tierValue.getValue(),tierValue.getLabel());
       }
        system.debug('.valueLabelMap..'+valueLabelMap);
        
        for(String tierFilter : valueLabelMap.keyset()){
            System.debug('..tierFilter..'+tierFilter);
            TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
            taxonomyRecord.label =valueLabelMap.get(tierFilter) ;
            taxonomyRecord.viewAllLabel='view all Label';
            taxonomyRecord.id=valueLabelMap.get(tierFilter);
            taxonomyRecord.children=null;
            taxonomyRecord.svgIconUrl='';
            taxonomyRecord.parentId=null;
            taxonomyRecord.taxonomy='partnertierFilters';
            taxonomyRecord.viewAllLabel='view all label';
            taxonomyRecord.description=tierFilter;         
            listings.put(taxonomyRecord.id,taxonomyRecord);
            
        }
        taxonomy.records=listings;
        response.put('partnerTierFilters',taxonomy);
        system.debug('.....response.....'+response);
        return response;
    } */
    
    /* Method to fetch the partner segment taxonomy*/
/*    @AuraEnabled(cacheable=true)
    public static Map<string,Taxonomy> getPartnerSegmentFilters(String langCode){

        Map<string,Taxonomy> response= new Map<string,Taxonomy>(); 
        Map<String,TaxonomyRecord> listings = new Map<String,TaxonomyRecord>(); 
      
        
        Taxonomy taxonomy= new Taxonomy();
        taxonomy.name='partnerSegmentFilters';
        taxonomy.apiName='Partner_Segment';
        taxonomy.label='Partner Segment ';
        taxonomy.viewAllLabel='View all partners by Segment';
        taxonomy.svgIconUrl=null;
        taxonomy.topLevelIds=null;
        taxonomy.records=listings;
       
       Map<String,String> valueLabelMap = new Map<String,String>();
       
       Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Partner_Segment_Nm__c.getDescribe();      
       List<Schema.PicklistEntry> segments = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry segmentValue : segments){
            valueLabelMap.put(segmentValue.getValue(),segmentValue.getLabel());
       }
        system.debug('.valueLabelMap..'+valueLabelMap);
        
        for(String segmentFilter : valueLabelMap.keyset()){
            System.debug('..segmentFilter..'+segmentFilter);
            TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
            taxonomyRecord.label =valueLabelMap.get(segmentFilter) ;
            taxonomyRecord.viewAllLabel='view all Label';
            taxonomyRecord.id=valueLabelMap.get(segmentFilter);
            taxonomyRecord.children=null;
            taxonomyRecord.svgIconUrl='';
            taxonomyRecord.parentId=null;
            taxonomyRecord.taxonomy='partnerSegmentFilters';
            taxonomyRecord.viewAllLabel='view all label';
            taxonomyRecord.description=segmentFilter;         
            listings.put(taxonomyRecord.id,taxonomyRecord);
            
        }
        taxonomy.records=listings;
        response.put('partnerSegmentFilters',taxonomy);
        system.debug('.....response.....'+response);
        return response;
    }*/
    
}