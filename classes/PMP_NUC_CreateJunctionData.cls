/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NUC_CreateJunctionData
* Version     : 1.0 
* Created Date: 4th Feb, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            02/04/2019               Created for Parsing the NUC JSON and creating Specification and Specification Value records.
******************************************************************************************************************************************************************************************************/
public class PMP_NUC_CreateJunctionData {

    public static List<Database.UpsertResult> createNUCJunctionDataMet(){
        
        final String NUCsUltimateParentPIMId = 'NPP_NUC';//just for reference, will be getting correct PIMId in attrbute files
        final String NUC_Attribute_English = 'NUC_Attribute_English';//static resource for NUC
        String jsonStr;//to store JSON file as string
        Integer leafLevel;//to store the leaf level of the file which is being processed
        Map<String, Object> specsByLanguageCode = new Map<String, Object>();//map containing all specs with language code as key (Map<'en_US', [Specifications]>)
        Set<Id> associatedCategories = new Set<Id>();//set consisting category Ids related to NUC spec
        Map<String,PMP_Category_Specification_Association__c> uploadableCatSpecsByExternalkey = new Map<String,PMP_Category_Specification_Association__c>();//map containing uploadable cat-spec association records
        Map<String,PMP_Specification_Value_Association__c> uploadableSpecValuesAssocByExternalkey = new Map<String,PMP_Specification_Value_Association__c>();//map containing uploadable spec-specValues association records
        List<PMP_Category_Specification_Association__c> uploadableCatSpecAssoc = new List<PMP_Category_Specification_Association__c>();//list of cat-specifications assoc to be uploaded
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();//list of spec-specificationValues assoc to be uploaded
        Map<String, PMP_Specification__c> existingNUCSpecsByExternalKey = new Map<String,PMP_Specification__c>();//map to store existing specs by it's externalkey
        Map<String, PMP_Specification_Value__c> existingNUCSpecValuesByExternalKey = new Map<String,PMP_Specification_Value__c>();//map to store exsting specValues by it's externalkey
        List<Database.UpsertResult> upsertResultData_SpecJO = new List<Database.UpsertResult>();//list containing upsert results of cat-spec assoc records
        //fetching the ultimate parent record for NUC
        PMP_Specification__c NUCsUltimateParentRecord = [SELECT Id,Name,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c =: NUCsUltimateParentPIMId LIMIT 1];
        /*Added by raj on 02/28*/
        Map<String, PMP_Category_Specification_Association__c> existingCatSpecAssocByExternalKey = new Map<String, PMP_Category_Specification_Association__c>();
        Map<String, PMP_Specification_Value_Association__c> existingSpecSpecValueAssocByExternalKey = new Map<String, PMP_Specification_Value_Association__c>();
        for(PMP_Category_Specification_Association__c catSpecAssoc : [SELECT Id,Name,PMP_Active_Ind__c, PMP_Category_Specification_External_Key__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__r.PMP_Specification_Type_Nm__c = 'NUC']){
            existingCatSpecAssocByExternalKey.put(catSpecAssoc.PMP_Category_Specification_External_Key__c, catSpecAssoc); 
        }
        for(PMP_Specification_Value_Association__c specSpecValueAssoc : [select id, PMP_Active_Ind__c, PMP_Category_Spec_Value_External_Key__c from PMP_Specification_Value_Association__c where PMP_Specification_Value_Id__r.PMP_Spec_Value_Type_Nm__c = 'NUC']){
            existingSpecSpecValueAssocByExternalKey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
        }
        /*End*/
        if(NUCsUltimateParentRecord != null){//if parent record is there fetch the category-spec Association record for NUC, using ultimate parent's record Id 
            List<PMP_Category_Specification_Association__c> associatedCategoriesRecords = [SELECT Id,Name,PMP_Active_Ind__c,PMP_Category_Id__c FROM PMP_Category_Specification_Association__c 
                                                                                           WHERE PMP_Specification_Id__c =: NUCsUltimateParentRecord.Id AND PMP_Active_Ind__c = true];
               for(PMP_Category_Specification_Association__c csa : associatedCategoriesRecords ){//iterate over the association records and populate associatedCategories set
                associatedCategories.add(csa.PMP_Category_Id__c);
            }
        }
        //map containing category records by recordId
        Map<Id,PMP_Category__c> categoriesById= new Map<Id,PMP_Category__c>([SELECT Id,PMP_Active_Ind__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c,Name 
                                                                             FROM PMP_Category__c WHERE Id in :associatedCategories]);
        
        for(PMP_Specification__c spec : [SELECT Id,Name,PMP_Specification_Name__c,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Id__c,
                                         PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c 
                                         FROM PMP_Specification__c WHERE PMP_Specification_Type_Nm__c = 'NUC' 
                                         OR PMP_Partner_Product_Specification_Id__c = :NUCsUltimateParentPIMId]){//populate existingNUCSpecsByExternalKey map
            existingNUCSpecsByExternalKey.put(spec.PMP_Partner_Product_Specification_Key__c,spec);
        }
        for(PMP_Specification_Value__c specValue : [SELECT Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c 
                                              		FROM PMP_Specification_Value__c WHERE PMP_Spec_Value_Type_Nm__c = 'NUC']){//populate existingNUCSpecValuesByExternalKey map
           existingNUCSpecValuesByExternalKey.put(specValue.PMP_Product_Specification_Value_Key__c,specValue);
        }
        
        //fetch the NUC JSON file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){
            StaticResource NUCsStaticResource = [select id,body from StaticResource Where Name = 'NUC_Attribute_Test'];//test resource name can be moved to static constant masterdata
            jsonStr = NUCsStaticResource.body.toString();
        }
        else {
           	StaticResource NUCsStaticResource = [select id,body from StaticResource Where Name = :NUC_Attribute_English];
            jsonStr = NUCsStaticResource.body.toString(); 
        }
        
        specsByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);//deserializing string and storing it in a Map<String, Object>
        leafLevel = PMP_Utility.getLeafNode(specsByLanguageCode);//fetch the leaf level of the current list of specifications.
        
        for(String languageCode : specsByLanguageCode.keySet()){//this for loop can be avoided if we are sure that only one language will come in one file
            List<Object> specNodes = (List<Object>)specsByLanguageCode.get(languageCode);//get the list of specifications associated with the current language code
            for(Integer specNodesIndex = 0; specNodesIndex < specNodes.size(); specNodesIndex++){//iterate over all specNodes in the list and create spec and specValue records
                Map<String, Object> specNodeByAttribute = (Map<String, Object>)specNodes[specNodesIndex];//fetch specNodes and use diiferent attributes to create spec and specValue records
                
                if(!specNodeByAttribute.isEmpty() && specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.ChildCategories)){//if spec node is not empty and it has child specs
                	List<Object> childSpecifications = (List<Object>)specNodeByAttribute.get(PMP_StaticConstants_MasterData.ChildCategories);//get all the child specs
                    for(Integer specIndex = 0; specIndex < childSpecifications.size(); specIndex++){//iterate over child specs and create spec or specValue records
                        Map<String, Object> childSpecsByAttribute = (Map<String, Object>)childSpecifications[specIndex];//store child specs in a map
                        
                        //if childspecAttribute map has level attribute and level is not equals to leaf level then create category-spec association records 
                        if(specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Level) && specNodeByAttribute.get(PMP_StaticConstants_MasterData.Level) != leafLevel){
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
                        			PMP_Specification__c specificationRecord = existingNUCSpecsByExternalKey.get(String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
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
                                if(!uploadableCatSpecsByExternalkey.containsKey(categorySpecAssoc.PMP_Category_Specification_External_Key__c) && 
                                   categorySpecAssoc.PMP_Category_Specification_External_Key__c != null && categorySpecAssoc.PMP_Category_Id__c != null &&
                                   categorySpecAssoc.PMP_Specification_Id__c != null){
                                    uploadableCatSpecsByExternalkey.put(categorySpecAssoc.PMP_Category_Specification_External_Key__c, categorySpecAssoc);
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
                                    specificationValueRecord = existingNUCSpecValuesByExternalKey.get(String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
                        			specificationRecord = existingNUCSpecsByExternalKey.get(String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase());
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
        /*Added by raj on 02/28*/
        if(!existingCatSpecAssocByExternalKey.isEmpty() && !uploadableCatSpecsByExternalkey.isEmpty()){
       		for(String keyId : existingCatSpecAssocByExternalKey.keySet()){
                if(!uploadableCatSpecsByExternalkey.keySet().contains(keyId)){
                    PMP_Category_Specification_Association__c csa = existingCatSpecAssocByExternalKey.get(keyId);
                    csa.PMP_Active_Ind__c = false;
                    uploadableCatSpecsByExternalkey.put(csa.PMP_Category_Specification_External_Key__c, csa);
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
        /*End*/
        uploadableCatSpecAssoc.addAll(uploadableCatSpecsByExternalkey.values());//adding all the cat-spec records to a list
        for(String externalId : uploadableSpecValuesAssocByExternalkey.keySet()){
            if(uploadableSpecValueAssoc.size() < 9000){//if uploadable specs are less than 9000, add it to a list 
                uploadableSpecValueAssoc.add(uploadableSpecValuesAssocByExternalkey.get(externalId));
            }
            else{//if more than 9000, call the future method to upload the records
                String uploadRecJSON = JSON.serialize(uploadableSpecValueAssoc);
                PMP_NUC_CreateJunctionData.uploadExcessSpecSpecValueAssRec(uploadRecJSON);
                uploadableSpecValueAssoc.clear();//clear off the list
            }
        }
        
        if(uploadableSpecValueAssoc.size() > 0){//process the remaining values
               String uploadRecJSON = JSON.serialize(uploadableSpecValueAssoc);
               PMP_NUC_CreateJunctionData.uploadExcessSpecSpecValueAssRec(uploadRecJSON);//again call the future method for the remianing specValues 
        }
        
        if(uploadableCatSpecAssoc.size() > 0){
            try{
                Schema.SObjectField upsertSpecKey = PMP_Category_Specification_Association__c.Fields.PMP_Category_Specification_External_Key__c;//fetch the cat-spec externalkey
                upsertResultData_SpecJO = Database.upsert(uploadableCatSpecAssoc,upsertSpecKey,false);//upsert the records
            }
            catch(Exception exp1){
                throw exp1;
            }
        }
        return upsertResultData_SpecJO;
    }
    
    // future Method to handle Governor Limits for DML on more than 10K records
    @future
    public static void uploadExcessSpecSpecValueAssRec(String uploadRecsJSON){
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();
        uploadableSpecValueAssoc = (List<PMP_Specification_Value_Association__c>)JSON.deserialize(uploadRecsJSON, List<PMP_Specification_Value_Association__c>.class);
        if(uploadableSpecValueAssoc.size()>0){
           try{
               upsert uploadableSpecValueAssoc PMP_Category_Spec_Value_External_Key__c;//upsert the cat-spec assoc records
           }
           catch(Exception exp3){
                throw exp3;
           }
        }
    }
}