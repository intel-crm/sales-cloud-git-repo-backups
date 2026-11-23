/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_RefineFilterController
* Description : this class  contains all the logic to fetch the refine filter taxonomies
* Version     : 1.0 
* Created Date: 01-June-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/


public without sharing class  PMP_RefineFilterController extends PMP_SearchWrapperStore{
    
    /*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_RefineFilterController
* Method Name : getRefineFilterTaxonomies
* Description : this method is called from UI to get the refinefiltertaxonomies which returns Map<string, RefineFilterTaxonomy>
* Version     : 1.0 
* Created Date: 3-June-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/
    
    @AuraEnabled(cacheable = true)
    public static Map<string, RefineFilterTaxonomy> getRefineFilterTaxonomies(String langCode,List<String> refineFilters){
        Map<string, RefineFilterTaxonomy> response = new Map<string, RefineFilterTaxonomy>();
        response.putAll(PMP_RefineFilterController.fetchTopLevelCategories(langCode,refineFilters));//get category taxonomies
        response.putAll(PMP_RefineFilterController.fetchTopLevelSpecifications(langCode,refineFilters));//get the specification taxonomies
        System.debug('response:'+response);
        return response;//return the response to UI
    }
    
    /*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_RefineFilterController
* Method Name : fetchTopLevelCategories
* Description : this method returns the toplevel categories for for the given pimids
* Version     : 1.0 
* Created Date: 3-June-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/
    
    public static Map<String,RefineFilterTaxonomy> fetchTopLevelCategories(String langCode,List<String> pimIds){
        Map<string,RefineFilterTaxonomy> response= new Map<string,RefineFilterTaxonomy>();
        Map<String, RefineFilterTaxonomyRecord> catTaxRecordMap = new Map<String, RefineFilterTaxonomyRecord>();
        Map<String, RefineFilterTaxonomy> catTaxonomyMap = new Map<String, RefineFilterTaxonomy>();
        
        List<PMP_Category__c> categories = new List<PMP_Category__c>();
        //query to fetch the toplevel categories for the given pimids from UI.
        if (Schema.sObjectType.PMP_Category__c.isAccessible()){
            categories=[SELECT Id, Name, PMP_Partner_Product_Category_Cd__c,
                        PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,
                        PMP_Parent_Category_Id__c,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Dsc__c,PMP_Category_Japanese_Dsc__c,
                        PMP_Parent_Category_Id__r.name, PMP_Partner_Product_Parent_Category_Cd__c,PMP_Ancestor_Category_Cd__c,PMP_Category_Display_Sequence_Nbr__c 
                        FROM PMP_Category__c WHERE (PMP_Partner_Product_Parent_Category_Cd__c IN: pimIds OR PMP_Partner_Product_Category_Cd__c IN:pimIds) AND PMP_Active_Ind__c = TRUE
                        ORDER BY PMP_Category_Display_Sequence_Nbr__c];
        }
        
        for(PMP_Category__c cat:categories){
            
            //if parent category is null then if toplevel category ex (Categories/Industry/Usecase), 
            //then add this as taxonomy and rest of the their childs as taxonomy records.
            if (cat.PMP_Parent_Category_Id__c == null){
                RefineFilterTaxonomy taxanomy = new RefineFilterTaxonomy();
                taxanomy.name = cat.Name.deleteWhitespace();
                taxanomy.apiName = cat.Id;
                taxanomy.pimId=cat.PMP_Partner_Product_Category_Cd__c;
                taxanomy.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                taxanomy.records = new Map<String, RefineFilterTaxonomyRecord>();
                catTaxonomyMap.put(cat.Id, taxanomy);
            }
            //form the RefineFilterTaxonomyRecords which needs to be added as child for the refinefiltertaxonomies
            else{
                RefineFilterTaxonomyRecord taxonomyRecord = new RefineFilterTaxonomyRecord();
                taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                taxonomyRecord.id = cat.Id;
                taxonomyRecord.objectname = 'PMP_Category__c';
                taxonomyRecord.parentId = cat.PMP_Parent_Category_Id__c;
                catTaxRecordMap.put(cat.Id, taxonomyRecord);
            }
            
        }
        
        for (RefineFilterTaxonomyRecord tag : catTaxRecordMap.values()){
            if (catTaxonomyMap.containsKey(tag.parentId) && tag.parentId != null){
                // associate all the child taxonomy records to parent taxonomy
                // ex: add advance analytics and artificial intelligence as the child records of usecase
                catTaxonomyMap.get(tag.parentId).records.put(tag.Id, tag);
                tag.filtertaxonomy = catTaxonomyMap.get(tag.parentId).name;
            } 
        }
        
        for (RefineFilterTaxonomyRecord tag : catTaxRecordMap.values()){
            if (catTaxonomyMap.containsKey(tag.parentId)){
                if (!response.containsKey(tag.parentId)){
                    //form the map of taxonomy pimid and taxonomy map which is expected from UI.
                    response.put(catTaxonomyMap.get(tag.parentId).pimId, catTaxonomyMap.get(tag.parentId));
                }
            }
        }
        
        system.debug('response:'+response);
        return response;
    }
    
    /*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_RefineFilterController
* Method Name : fetchTopLevelSpecifications
* Description : this method returns the toplevel specifications for for the given spec pimids
* Version     : 1.0 
* Created Date: 3-June-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/
    
    public static Map<String,RefineFilterTaxonomy> fetchTopLevelSpecifications(String langCode, List<String> pimIds){
        Map<string, RefineFilterTaxonomy> response = new Map<string, RefineFilterTaxonomy>();
        Map<String, RefineFilterTaxonomyRecord> specTaxRecordMap = new Map<String, RefineFilterTaxonomyRecord>();
        Map<String, RefineFilterTaxonomyRecord> specValueTaxRecordMap = new Map<String, RefineFilterTaxonomyRecord>();
        Map<String, RefineFilterTaxonomy> specTaxonomyMap = new Map<String, RefineFilterTaxonomy>();
        
        
        //localization change
        Map<string, string> localisedFieldName = New Map<string, string>();
        List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> specValueList = new List<PMP_Specification_Value__c>();
        
        
        List<PMP_Language_to_Field_API_Mapping__mdt> languageMetadata = New List<PMP_Language_to_Field_API_Mapping__mdt>();
        //query return the localised feild names for the objects
        languageMetadata = [SELECT PMP_Object_Nm__c, PMP_Field_Nm__c, PMP_Language_Cd__c, PMP_Field_APINm__c
                            FROM PMP_Language_to_Field_API_Mapping__mdt WHERE PMP_Object_Nm__c =: PMP_StaticConstants_Partner.SPEC_OBJ_API OR 
                            PMP_Object_Nm__c=: PMP_StaticConstants_Partner.SPECVAL_OBJ_API];
        for (PMP_Language_to_Field_API_Mapping__mdt meta : languageMetadata){
            localisedFieldName.put(meta.PMP_Object_Nm__c + '|' + meta.PMP_Field_Nm__c + '|' + meta.PMP_Language_Cd__c, meta.PMP_Field_APINm__c);
        }
        string specNameLocal = localisedFieldName.get('PMP_Specification__c|Name|' + langCode);//get the localised field name for specification
        string specValNameLocal =   localisedFieldName.get('PMP_Specification_Value__c|Name|' +langCode);//get the localised field name for spec value
        
        Map<string, string> pimIdSpecIdMap = New Map<string, string>();
        Map<string, PMP_Specification__c> pimIdSpecMap = New Map<string, PMP_Specification__c>();
        Set<String> pimProductIds= new Set<String>();
        
        //query returns all the active toplevel specifications for the given pimids
        if (Schema.sObjectType.PMP_Specification__c.isAccessible()){
            specList= [SELECT id, Name, PMP_Partner_Product_Display_Sequence_Nbr__c,PMP_Partner_Product_Specification_Key__c, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                       PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c, PMP_Ancestor_Specification_Cd__c, PMP_Parent_Specification_Id__c, PMP_Specification_Name__c
                       FROM PMP_Specification__c
                       WHERE PMP_Active_Ind__c = TRUE AND (PMP_Product_Parent_Specification_Id__c IN: pimIds OR PMP_Partner_Product_Specification_Id__c IN: pimIds)
                       ORDER BY PMP_Partner_Product_Display_Sequence_Nbr__c];
        }
        
        for (PMP_Specification__c spec :specList){
            //if parent specification ex (Processor/Topology/AI Model Training etc) then add this as taxonomy 
            //and rest of the their childs as taxonomy records in the else block.
            if (spec.PMP_Product_Parent_Specification_Id__c == null){
                RefineFilterTaxonomy taxanomy = new RefineFilterTaxonomy();
                taxanomy.name = spec.Name.deleteWhitespace();// added to remove space
                taxanomy.apiName = spec.Id;
                taxanomy.pimId=spec.PMP_Partner_Product_Specification_Id__c;
                if (spec.get(specNameLocal) != null){
                    taxanomy.label = (string) spec.get(specNameLocal);// get the spec label based on locale
                } else{
                    taxanomy.label = spec.Name;
                }
                taxanomy.records = new Map<String, RefineFilterTaxonomyRecord>();
                specTaxonomyMap.put(spec.Id, taxanomy);
                //collect all the spec taxonomies to find if any spec values being associated to it, using this is specval logic below
                pimIdSpecIdMap.put(spec.PMP_Partner_Product_Specification_Id__c,spec.Id);
            } else{
                RefineFilterTaxonomyRecord taxonomyRecord = new RefineFilterTaxonomyRecord();
                if (spec.get(specNameLocal) != null){
                    taxonomyRecord.label = (string) spec.get(specNameLocal);
                } else{
                    taxonomyRecord.label = spec.Name;
                }
                taxonomyRecord.id = spec.Id;
                // set the object from which this tax record is formed
                taxonomyRecord.objectname = 'PMP_Specification__c';
                //populate the parentid to associate this to parent taxonomy
                taxonomyRecord.parentId=spec.PMP_Parent_Specification_Id__c;
                specTaxRecordMap.put(spec.Id, taxonomyRecord);
                
            }
        }
        
        
        //this query returns all the active specValues for the given specification pimiids
        if (Schema.sObjectType.PMP_Specification_Value__c.isAccessible()){
            specValueList=[SELECT id, Name, PMP_Specification_Value_Sequence_Nbr__c, PMP_Specification_Value_Chinese_Cd__c,PMP_Specification_id__c,
                           PMP_Spec_Pre_Release_Ind__c,PMP_Specification_Value_Japanese_Cd__c,PMP_Specification_Value_Nm__c,
                           PMP_Name_Chinese__c,PMP_Name_Japanese__c,PMP_Specification_Product_Cd__c
                           FROM PMP_Specification_Value__c  
                           WHERE PMP_Active_Ind__c = TRUE and PMP_Specification_Product_Cd__c in: pimIdSpecIdMap.keySet() ORDER BY PMP_Specification_Value_Sequence_Nbr__c];
        }
        for(PMP_Specification_Value__c specVal : specValueList){
            RefineFilterTaxonomyRecord taxonomyRecord = new RefineFilterTaxonomyRecord();
            if (specVal.get(specValNameLocal) != null){
                taxonomyRecord.label = (string)specVal.get(specValNameLocal); // get the specvalue based on locale
            } else{
                taxonomyRecord.label = specVal.Name;
            }
            taxonomyRecord.id = specVal.Id;
            // set the object from which this tax record is formed    
            taxonomyRecord.objectname = 'PMP_Specification_Value__c';
            //populate the parentid to associate this to parent taxonomy
            taxonomyRecord.parentId = pimIdSpecIdMap.get(specVal.PMP_Specification_Product_Cd__c);
            specTaxRecordMap.put(specVal.id, taxonomyRecord);
        }
        for (RefineFilterTaxonomyRecord tag : specTaxRecordMap.values()){
            if (specTaxonomyMap.containsKey(tag.parentId) && tag.parentId != null){
                // associate all the child taxonomy records to parent taxonomy
                // ex: add federated training and machine learning as the child records of AI Model training taxonomy
                specTaxonomyMap.get(tag.parentId).records.put(tag.Id, tag);  
                tag.filtertaxonomy = specTaxonomyMap.get(tag.parentId).name;
            } 
        }
        
        for (RefineFilterTaxonomyRecord tag : specTaxRecordMap.values()){
            if (specTaxonomyMap.containsKey(tag.parentId)){
                if (!response.containsKey(tag.parentId)){
                    //form the map of taxonomy pimid and taxonomy map which is expected from UI.
                    response.put(specTaxonomyMap.get(tag.parentId).pimId, specTaxonomyMap.get(tag.parentId));
                }
            }
        }
        return response;
    }
}