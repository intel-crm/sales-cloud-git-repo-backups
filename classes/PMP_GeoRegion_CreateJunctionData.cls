/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_GeoRegion_CreateJunctionData
* Created Date: 22nd May,2019
* Modification Log :
* Developer                         Version             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta          1.0                22/05/2019              Class to create association records for GeoRegions
* Infosys - Raj Yadav                2.0                11/06/2020              Refactored class for easy maintainance 
******************************************************************************************************************************************************************************************************/
public with sharing class PMP_GeoRegion_CreateJunctionData {

    public static String testCheck;
        public static final String ultimateParentPIMId = 'NPP_GeographicCoverage';//UltimateParentId
        public static final String specificationType = 'Geography';
        public static final String staticResourceFileName = 'Geo_Attribute_English';//static resource for GeoRegions
        public static final String staticResourceTestFileName = 'Geo_Attribute_English_Test';//test static resource for GeoRegions
    
    public static List<Database.UpsertResult> createAssociationRecords(){
        
        String jsonStr;//to store JSON file as string
        Integer leafLevel;//to store the leaf level of the file which is being processed
        Map<String, Object> specsByLanguageCode = new Map<String, Object>();//map containing all specs with language code as key (Map<'en_US', [Specifications]>)
        Set<Id> associatedCategories = new Set<Id>();//set consisting category Ids related to GeoRegions spec
        Map<String,PMP_Category_Specification_Association__c> uploadableCatSpecAssocByExternalkey = new Map<String,PMP_Category_Specification_Association__c>();//map containing uploadable cat-spec association records
        Map<String,PMP_Specification_Value_Association__c> uploadableSpecValuesAssocByExternalkey = new Map<String,PMP_Specification_Value_Association__c>();//map containing uploadable spec-specValues association records
        List<PMP_Category_Specification_Association__c> uploadableCatSpecAssoc = new List<PMP_Category_Specification_Association__c>();//list of cat-specifications assoc to be uploaded
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();//list of spec-specificationValues assoc to be uploaded
        Map<String, PMP_Specification__c> existingSpecsByExternalKey = new Map<String,PMP_Specification__c>();//map to store existing specs by it's externalkey
        Map<String, PMP_Specification_Value__c> existingSpecValuesByExternalKey = new Map<String,PMP_Specification_Value__c>();//map to store existing specValues by it's externalkey
        List<Database.UpsertResult> upsertResultData = new List<Database.UpsertResult>();//list containing upsert results of cat-spec assoc records
        PMP_Specification__c ultimateParentRecord = new PMP_Specification__c();//specification instance to store ultimateParentRecord
        if(Schema.sObjectType.PMP_Specification__c.isAccessible()){//fetching the ultimate parent record for GeoRegions
            ultimateParentRecord = [SELECT Id,Name,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c 
                                                             WHERE PMP_Partner_Product_Specification_Id__c =: ultimateParentPIMId AND PMP_Active_Ind__c = true LIMIT 1];
        }
        /*Added by raj on 02/28, to handle activation and deactivation of association records*/
        Map<String, PMP_Category_Specification_Association__c> existingCatSpecAssocByExternalKey = new Map<String, PMP_Category_Specification_Association__c>();
        Map<String, PMP_Specification_Value_Association__c> existingSpecSpecValueAssocByExternalKey = new Map<String, PMP_Specification_Value_Association__c>();
        for(PMP_Category_Specification_Association__c catSpecAssoc : [SELECT Id,Name,PMP_Active_Ind__c, PMP_Category_Specification_External_Key__c FROM PMP_Category_Specification_Association__c 
                                                                      WHERE PMP_Specification_Id__r.PMP_Specification_Type_Nm__c =: specificationType FOR UPDATE]){
            existingCatSpecAssocByExternalKey.put(catSpecAssoc.PMP_Category_Specification_External_Key__c, catSpecAssoc); 
        }
        /*End*/
        
        for(PMP_Specification_Value_Association__c specSpecValueAssoc : [SELECT id, PMP_Active_Ind__c, PMP_Category_Spec_Value_External_Key__c FROM PMP_Specification_Value_Association__c 
                                                                         WHERE PMP_Specification_Value_Id__r.PMP_Spec_Value_Type_Nm__c =: specificationType AND PMP_Active_Ind__c = true]){
            existingSpecSpecValueAssocByExternalKey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
        }
        if(ultimateParentRecord != null && Schema.sObjectType.PMP_Category_Specification_Association__c.isAccessible()){//if parent record is there fetch the category-spec Association record for GeoRegions, using ultimate parent's record Id 
            List<PMP_Category_Specification_Association__c> associatedCategoriesRecords = [SELECT Id,Name,PMP_Active_Ind__c,PMP_Category_Id__c FROM PMP_Category_Specification_Association__c 
                                                                                           WHERE PMP_Specification_Id__c =: ultimateParentRecord.Id AND PMP_Active_Ind__c = true];
               for(PMP_Category_Specification_Association__c csa : associatedCategoriesRecords ){//iterate over the association records and populate associatedCategories set
                associatedCategories.add(csa.PMP_Category_Id__c);
            }
        }
        //map containing category records by recordId
        Map<Id,PMP_Category__c> categoriesById= new Map<Id,PMP_Category__c>([SELECT Id,PMP_Active_Ind__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c,Name 
                                                                             FROM PMP_Category__c WHERE Id in :associatedCategories and PMP_Active_Ind__c = true]);
        
        for(PMP_Specification__c spec : [SELECT Id,Name,PMP_Specification_Name__c,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Id__c,
                                         PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c 
                                         FROM PMP_Specification__c WHERE (PMP_Specification_Type_Nm__c =: specificationType 
                                         OR PMP_Partner_Product_Specification_Id__c =: ultimateParentPIMId) AND PMP_Active_Ind__c = true]){//populate existingSpecsByExternalKey map
            existingSpecsByExternalKey.put(spec.PMP_Partner_Product_Specification_Key__c,spec);
        }
        
        for(PMP_Specification_Value__c specValue : [SELECT Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c 
                                                    FROM PMP_Specification_Value__c WHERE PMP_Spec_Value_Type_Nm__c =: specificationType AND PMP_Active_Ind__c = true]){//populate existingSpecValuesByExternalKey map
           existingSpecValuesByExternalKey.put(specValue.PMP_Product_Specification_Value_Key__c,specValue);
        }
        
        //fetch the GeoRegions JSON file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceTestFileName];
            jsonStr = staticResourceFile.body.toString();
        }
        else{
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceFileName];
            jsonStr = staticResourceFile.body.toString(); 
        }
        
        specsByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);//deserializing string and storing it in a Map<String, Object>
        leafLevel = PMP_Utility.getLeafNode(specsByLanguageCode);//fetch the leaf level of the current list of specifications.
        
        for(String languageCode : specsByLanguageCode.keySet()){
            List<Object> specNodes = (List<Object>)specsByLanguageCode.get(languageCode);//get the list of specifications associated with the current language code
            for(Integer specNodesIndex = 0; specNodesIndex < specNodes.size(); specNodesIndex++){//iterate over all specNodes in the list and create spec and specValue records
                Map<String, Object> specNodeByAttribute = (Map<String, Object>)specNodes[specNodesIndex];//fetch specNodes and use diiferent attributes to create spec and specValue records
                
                if(!specNodeByAttribute.isEmpty() && specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.ChildCategories)){//if spec node is not empty and it has child specs
                    List<Object> childSpecifications = (List<Object>)specNodeByAttribute.get(PMP_StaticConstants_MasterData.ChildCategories);//get all the child specs
                    for(Integer specIndex = 0; specIndex < childSpecifications.size(); specIndex++){//iterate over child specs and create spec or specValue records
                        Map<String, Object> childSpecsByAttribute = (Map<String, Object>)childSpecifications[specIndex];//store child specs in a map
                        
                        if(Test.isRunningTest() && testCheck =='Test'){
                            specNodeByAttribute.put(PMP_StaticConstants_MasterData.Level,leafLevel);
                        }
                        //if childspecAttribute map has level attribute and level is not equals to leaf level then create category-spec association records 
                        if( specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Level) && specNodeByAttribute.get(PMP_StaticConstants_MasterData.Level) != leafLevel){
                            for(Id categoryId : associatedCategories){
                                PMP_Category_Specification_Association__c categorySpecAssoc = new PMP_Category_Specification_Association__c();
                                PMP_Category__c categoryRecord = categoriesById.get(categoryId);//get the category record
                                categorySpecAssoc.PMP_Category_Id__c = categoryId;//associate the related category record Id
                                if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue) && childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecDisplayValue) != null){
                                    String catSpecAssocName = categoryRecord.Name + 
                                                              PMP_StaticConstants_MasterData.Colon_Symbol +
                                                              childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecDisplayValue);
                                    //populate assoc record's name as realated categoryName:specificationName
                                    categorySpecAssoc.Name = catSpecAssocName.length() > 80 ? catSpecAssocName.substring(0, 80) : catSpecAssocName;
                                }
                                //associate specification from existing specification records 
                                if(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue) != null){
                                    //fetch the specification record
                                    PMP_Specification__c specificationRecord = existingSpecsByExternalKey.get(String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
                                    //populate assoc rescords external key as PIMCategoryId|specificationExternalkey
                                    categorySpecAssoc.PMP_Category_Specification_External_Key__c = categoryRecord != null ?
                                                                                                    String.valueOf(categoryRecord.PMP_Partner_Product_Category_Cd__c + 
                                                                                                    PMP_StaticConstants_MasterData.Pipe_Symbol + 
                                                                                                    childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase(): null;
                                    categorySpecAssoc.PMP_Specification_Id__c = specificationRecord != null ? specificationRecord.Id : null;
                                    //if both category and specification record is active, make association record active
                                    if(categoryRecord != null && categoryRecord.PMP_Active_Ind__c && specificationRecord != null && specificationRecord.PMP_Active_Ind__c){
                                        categorySpecAssoc.PMP_Active_Ind__c = true;
                                    }
                                    else{
                                        categorySpecAssoc.PMP_Active_Ind__c = false;
                                    }
                                }
                                //if the association record is proper, push it into uploadableMap
                                if(!uploadableCatSpecAssocByExternalkey.containsKey(categorySpecAssoc.PMP_Category_Specification_External_Key__c) && 
                                   categorySpecAssoc.PMP_Category_Specification_External_Key__c != null && categorySpecAssoc.PMP_Category_Id__c != null &&
                                   categorySpecAssoc.PMP_Specification_Id__c != null){
                                    uploadableCatSpecAssocByExternalkey.put(categorySpecAssoc.PMP_Category_Specification_External_Key__c, categorySpecAssoc);
                                }
                            }
                        }
                        
                        else{
                            PMP_Specification_Value__c specificationValueRecord;
                            PMP_Specification__c specificationRecord ;
                            for(Id categoryId : associatedCategories){//iterate over all the associated categories
                                PMP_Category__c categoryRecord = categoriesById.get(categoryId);//get the category record
                                PMP_Specification_Value_Association__c specSpecValueAssoc = new PMP_Specification_Value_Association__c();
                                specSpecValueAssoc.PMP_Category_Id__c = categoryId;
                                if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue) != null){
                                    specificationValueRecord = existingSpecValuesByExternalKey.get(String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
                                    specificationRecord = existingSpecsByExternalKey.get(String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase());
                                    specSpecValueAssoc.PMP_Specification_Value_Id__c = specificationValueRecord != null ? specificationValueRecord.Id : null;
                                    specSpecValueAssoc.PMP_Specification_Id__c = specificationRecord != null ? specificationRecord.Id : null;
                                    if(categoryRecord != null){//if category record is available
                                        specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c = String.valueOf(categoryRecord.PMP_Partner_Product_Category_Cd__c + PMP_StaticConstants_MasterData.Pipe_Symbol +
                                                                                                                    specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier) + PMP_StaticConstants_MasterData.Pipe_Symbol + 
                                                                                                                    childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).toLowerCase();
                                    }
                                }
                                if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue) && childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecDisplayValue) != null){
                                    String specSpecValueAssocName = String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                    specSpecValueAssoc.Name = specSpecValueAssocName.length() > 80 ? specSpecValueAssocName.substring(0, 80) : specSpecValueAssocName;
                                }
                                //if both spec and specValue is active, make assoc record also as Active else false
                                if(categoryRecord !=null && categoryRecord.PMP_Active_Ind__c == true && specificationRecord != null && specificationValueRecord != null && specificationRecord.PMP_Active_Ind__c == true && specificationValueRecord.PMP_Active_Ind__c == true){
                                   specSpecValueAssoc.PMP_Active_Ind__c = true; 
                                }
                                else{
                                   specSpecValueAssoc.PMP_Active_Ind__c = false;
                                }
                                //if the spec-specValue assoc record is proper, push it into uploadable 
                                if(!uploadableSpecValuesAssocByExternalkey.containsKey(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c) && specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c != null && 
                                   specSpecValueAssoc.PMP_Specification_Id__c != null && specSpecValueAssoc.PMP_Specification_Value_Id__c != null){
                                    uploadableSpecValuesAssocByExternalkey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c,specSpecValueAssoc); 
                                }
                            }
                        }
                    }
                }
            }
        }
        /*Added by raj on 02/28, to handle activation-deactication of association records*/
        if(!existingCatSpecAssocByExternalKey.isEmpty() && !uploadableCatSpecAssocByExternalkey.isEmpty()){
            for(String keyId : existingCatSpecAssocByExternalKey.keySet()){
                if(!uploadableCatSpecAssocByExternalkey.keySet().contains(keyId)){
                    PMP_Category_Specification_Association__c csa = existingCatSpecAssocByExternalKey.get(keyId);
                    csa.PMP_Active_Ind__c = false;
                    uploadableCatSpecAssocByExternalkey.put(csa.PMP_Category_Specification_External_Key__c, csa);
                }
            }
        }
       
        if(!existingSpecSpecValueAssocByExternalKey.isEmpty() && !uploadableSpecValuesAssocByExternalkey.isEmpty()){
            for(String keyId : existingSpecSpecValueAssocByExternalKey.keySet()){
                if(!uploadableSpecValuesAssocByExternalkey.keySet().contains(keyId)){
                    PMP_Specification_Value_Association__c specSpecValueAssoc = existingSpecSpecValueAssocByExternalKey.get(keyId);
                    specSpecValueAssoc.PMP_Active_Ind__c = false;
                    uploadableSpecValuesAssocByExternalkey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
                }    
            }    
        }
        
        uploadableCatSpecAssoc.addAll(uploadableCatSpecAssocByExternalkey.values());//adding all the cat-spec records to a list
        
        for(String externalId : uploadableSpecValuesAssocByExternalkey.keySet()){
            if(uploadableSpecValueAssoc.size() < 9000){//if uploadable specs are less than 9000, add it to a list 
                uploadableSpecValueAssoc.add(uploadableSpecValuesAssocByExternalkey.get(externalId));
            }
            else{//if more than 9000, call the future method to upload the records
                String uploadRecJSON = JSON.serialize(uploadableSpecValueAssoc);
                PMP_GeoRegion_CreateJunctionData.uploadExcessSpecSpecValueAssRec(uploadRecJSON);
                uploadableSpecValueAssoc.clear();//clear off the list
            }
        }
        
        if(uploadableSpecValueAssoc.size() > 0){//process the remaining values
               String uploadRecJSON = JSON.serialize(uploadableSpecValueAssoc);
               PMP_GeoRegion_CreateJunctionData.uploadExcessSpecSpecValueAssRec(uploadRecJSON);//again call the future method for the remianing specValues 
        }
        if(uploadableCatSpecAssoc.size() > 0){
            try{
                Schema.SObjectField upsertSpecKey = PMP_Category_Specification_Association__c.Fields.PMP_Category_Specification_External_Key__c;//fetch the cat-spec externalkey
                upsertResultData = Database.upsert(uploadableCatSpecAssoc,upsertSpecKey,false);//upsert the records
                PMP_Utility.logDmlErrors((Object[]) upsertResultData, 'PMP_GeoRegion_CreateJunctionData-createAssociationRecords');
            }
            catch(Exception exp1){
                throw exp1;
            }
        }
        return upsertResultData;
    }
    
    // future Method to handle Governor Limits for DML on more than 10K recordsO
    
    @future
    public static void uploadExcessSpecSpecValueAssRec(String uploadRecsJSON){
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();
        uploadableSpecValueAssoc = (List<PMP_Specification_Value_Association__c>)JSON.deserialize(uploadRecsJSON, List<PMP_Specification_Value_Association__c>.class);
        if(uploadableSpecValueAssoc.size()>0){
           try{
               upsert uploadableSpecValueAssoc PMP_Category_Spec_Value_External_Key__c;//upsert the spec-specValue assoc records
           }
           catch(Exception exp3){
                throw exp3;
           }
        }
    }
}