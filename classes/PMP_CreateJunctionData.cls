public without sharing class PMP_CreateJunctionData {
    
        public static final String specificationType = 'Other';
        public static final String staticResourceFileName = 'Attributes_English';//static resource for NUC
        public static final String staticResourceTestFileName = 'PMP_Attributes_Test';//test static resource for NUC
    public static List<Database.UpsertResult> createJunctionObjData(){
        
        String jsonStr;//to store JSON file as string
        Map<String, Object> specsByLanguageCode = new Map<String, Object>();//map containing all specs with language code as key (Map<'en_US', [Specifications]>)
        Map<String, PMP_Specification__c> existingSpecsByExternalKey = new Map<String,PMP_Specification__c>();//map to store existing specs by it's externalkey
        Map<String, PMP_Specification_Value__c> existingSpecValuesByExternalKey = new Map<String,PMP_Specification_Value__c>();//map to store existing specValues by it's externalkey
        Map<String, PMP_Category__c> categoriesByExternalKey = new Map<String, PMP_Category__c>();
        Map<String, PMP_Category_Specification_Association__c> existingCatSpecAssocByExternalKey = new Map<String, PMP_Category_Specification_Association__c>();
        Map<String, PMP_Specification_Value_Association__c> existingSpecSpecValueAssocByExternalKey = new Map<String, PMP_Specification_Value_Association__c>();
        Map<String,PMP_Category_Specification_Association__c> uploadableCatSpecAssocByExternalkey = new Map<String,PMP_Category_Specification_Association__c>();//map containing uploadable cat-spec association records
        Map<String,PMP_Specification_Value_Association__c> uploadableSpecValuesAssocByExternalkey = new Map<String,PMP_Specification_Value_Association__c>();//map containing uploadable spec-specValues association records
        List<PMP_Category_Specification_Association__c> uploadableCatSpecAssoc = new List<PMP_Category_Specification_Association__c>();//list of cat-specifications assoc to be uploaded
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();//list of spec-specificationValues assoc to be uploaded
        List<Database.UpsertResult> upsertResultData = new List<Database.UpsertResult>();//list containing upsert results of cat-spec assoc records
        
        //fetch existing specification record which has type 'Other'
        for(PMP_Specification__c spec : [SELECT Id,Name,PMP_Specification_Name__c,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Id__c,
                                         PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c 
                                         FROM PMP_Specification__c WHERE PMP_Specification_Type_Nm__c =: specificationType]){//populate existingSpecsByExternalKey map
            existingSpecsByExternalKey.put(spec.PMP_Partner_Product_Specification_Key__c,spec);
        }
        
        //fetch existing specificationValue record which has type 'Other'
        for(PMP_Specification_Value__c specValue : [SELECT Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c 
                                                    FROM PMP_Specification_Value__c WHERE PMP_Spec_Value_Type_Nm__c =: specificationType]){//populate existingSpecValuesByExternalKey map
           existingSpecValuesByExternalKey.put(specValue.PMP_Product_Specification_Value_Key__c,specValue);
        }
                
        //fetch all the categories for creating association 
        for(PMP_Category__c cat:[SELECT Id,PMP_Partner_Product_Category_Cd__c,PMP_Active_Ind__c,PMP_Partner_Product_Category_Key__c,Name FROM PMP_Category__c WHERE PMP_Active_Ind__c = true]){
            categoriesByExternalKey.put(cat.PMP_Partner_Product_Category_Key__c, cat);
        }
                                         
        //fetch existing category Spec association records
        for(PMP_Category_Specification_Association__c catSpecAssoc : [SELECT Id,Name,PMP_Active_Ind__c, PMP_Category_Specification_External_Key__c FROM PMP_Category_Specification_Association__c 
                                                                      WHERE PMP_Specification_Id__r.PMP_Specification_Type_Nm__c =: specificationType  FOR UPDATE]){
            existingCatSpecAssocByExternalKey.put(catSpecAssoc.PMP_Category_Specification_External_Key__c, catSpecAssoc); 
        }
        
        //fetch existing spec-specValue association records
        for(PMP_Specification_Value_Association__c specSpecValueAssoc : [SELECT id, PMP_Active_Ind__c, PMP_Category_Spec_Value_External_Key__c FROM PMP_Specification_Value_Association__c 
                                                                         WHERE PMP_Specification_Value_Id__r.PMP_Spec_Value_Type_Nm__c =: specificationType  FOR UPDATE]){
            existingSpecSpecValueAssocByExternalKey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
        }
        
        //fetch the Specification JSON file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceTestFileName];
            jsonStr = staticResourceFile.body.toString();
        }
        else{
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceFileName];
            jsonStr = staticResourceFile.body.toString(); 
        }

        specsByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);//deserializing string and storing it in a Map<String, Object>
        
        for(String languageCode : specsByLanguageCode.keySet()){
            List<Object> specNodes = (List<Object>)specsByLanguageCode.get(languageCode);//get the list of specifications associated with the current language code
            for(Integer specNodesIndex = 0; specNodesIndex < specNodes.size(); specNodesIndex++){//iterate over all specNodes in the list and create spec and specValue records
                Map<String, Object> specNodeByAttribute = (Map<String, Object>)specNodes[specNodesIndex];//fetch specNodes and use different attributes to create spec and specValue records
                
                if(!specNodeByAttribute.isEmpty() && specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Features)){//if spec node is not empty and it has child specs
                    List<Object> features = (List<Object>)specNodeByAttribute.get(PMP_StaticConstants_MasterData.Features);//get all the child specs
                    for(Integer specIndex = 0; specIndex < features.size(); specIndex++){//iterate over child specs and create spec or specValue records
                        Map<String, Object> featureByAttribute = (Map<String, Object>)features[specIndex];//store child specs in a map
                        if(!featureByAttribute.isEmpty()){
                            List<String> levelValues = new List<String>();
                            Integer leafLevel = 0;
                            if(featureByAttribute.containsKey(PMP_StaticConstants_MasterData.Spec_Identifier)){
                                if(featureByAttribute.containsKey(PMP_StaticConstants_MasterData.Level_1) && !String.isEmpty(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_1)))){
                                    levelvalues.add(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_1)));  
                                }
                                if(featureByAttribute.containsKey(PMP_StaticConstants_MasterData.Level_2) && !String.isEmpty(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_2)))){
                                    levelvalues.add(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_2)));  
                                } 
                                if(featureByAttribute.containsKey(PMP_StaticConstants_MasterData.Level_3) && !String.isEmpty(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_3)))){
                                    levelvalues.add(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_3)));  
                                } 
                                if(featureByAttribute.containsKey(PMP_StaticConstants_MasterData.Level_4) && !String.isEmpty(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_4)))){
                                    levelvalues.add(String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Level_4)));  
                                } 
                            }
                            leafLevel = (levelvalues.size() > 0) ? (levelvalues.size() - 1) : leafLevel;
                            String levelValue = levelvalues.size() > 0 ? levelvalues[leafLevel] : '';
                            for(Integer speclevelIndex=0; speclevelIndex<leafLevel; speclevelIndex++){
                                String specExternalKey = (String.valueOf(levelvalues[speclevelIndex])+PMP_StaticConstants_MasterData.Level+(speclevelIndex+1)).deleteWhitespace().toLowerCase();
                                String categoryExternalKey = (String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier))).deleteWhitespace().toLowerCase();
                                PMP_Category_Specification_Association__c categorySpecAssoc = new PMP_Category_Specification_Association__c();
                                if(categoriesByExternalKey.get(categoryExternalKey) != null && existingSpecsByExternalKey.get(specExternalKey) != null){
                                    categorySpecAssoc.PMP_Category_Id__c = categoriesByExternalKey.get(categoryExternalKey).Id;
                                    categorySpecAssoc.PMP_Specification_Id__c = existingSpecsByExternalKey.get(specExternalKey).Id;
                                    String name = String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Name) + PMP_StaticConstants_MasterData.Colon_Symbol + levelvalues[speclevelIndex]);
                                    categorySpecAssoc.Name = name.length() >= 80? name.substring(0, 79) : name;
                                    if(Boolean.valueOf((categoriesByExternalKey.get(categoryExternalKey)).PMP_Active_Ind__c) && Boolean.valueOf((existingSpecsByExternalKey.get(specExternalKey)).PMP_Active_Ind__c)){
                                        categorySpecAssoc.PMP_Active_Ind__c = true;
                                    }
                                    else{
                                        categorySpecAssoc.PMP_Active_Ind__c = false;
                                    }
                                    categorySpecAssoc.PMP_Category_Specification_External_Key__c = (String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier)) + 
                                                                                                    PMP_StaticConstants_MasterData.Pipe_Symbol + 
                                                                                                    (String.valueOf(levelvalues[speclevelIndex]) + PMP_StaticConstants_MasterData.Level + speclevelIndex+1).deleteWhitespace()).toLowerCase();
                                    if(!uploadableCatSpecAssocByExternalkey.containsKey(categorySpecAssoc.PMP_Category_Specification_External_Key__c)){
                                        uploadableCatSpecAssocByExternalkey.put(categorySpecAssoc.PMP_Category_Specification_External_Key__c,categorySpecAssoc);
                                    }
                                  }
                                }
                            String specExternalKey = (String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Spec_Identifier))).deleteWhitespace().toLowerCase();
                            String categoryExternalKey = (String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier))).deleteWhitespace().toLowerCase();
                            PMP_Category_Specification_Association__c categorySpecAssoc = new PMP_Category_Specification_Association__c();
                            if(categoriesByExternalKey.get(categoryExternalKey) != null && existingSpecsByExternalKey.get(specExternalKey) != null){
                                    categorySpecAssoc.PMP_Category_Id__c = categoriesByExternalKey.get(categoryExternalKey).Id;
                                    categorySpecAssoc.PMP_Specification_Id__c = existingSpecsByExternalKey.get(specExternalKey).Id;
                                    String name = String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Name) + PMP_StaticConstants_MasterData.Colon_Symbol + levelValue);
                                    categorySpecAssoc.Name = name.length() >= 80? name.substring(0, 79) : name;
                                    if(Boolean.valueOf((categoriesByExternalKey.get(categoryExternalKey)).PMP_Active_Ind__c) && Boolean.valueOf((existingSpecsByExternalKey.get(specExternalKey)).PMP_Active_Ind__c)){
                                        categorySpecAssoc.PMP_Active_Ind__c = true;
                                    }
                                    else{
                                        categorySpecAssoc.PMP_Active_Ind__c = false;
                                    }
                                    categorySpecAssoc.PMP_Category_Specification_External_Key__c = (String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier)) + 
                                                                                                    PMP_StaticConstants_MasterData.Pipe_Symbol + 
                                                                                                    String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Spec_Identifier))).toLowerCase();
                                    if(!uploadableCatSpecAssocByExternalkey.containsKey(categorySpecAssoc.PMP_Category_Specification_External_Key__c)){
                                        uploadableCatSpecAssocByExternalkey.put(categorySpecAssoc.PMP_Category_Specification_External_Key__c,categorySpecAssoc);
                                    }
                                }
                            if(featureByAttribute.containsKey(PMP_StaticConstants_MasterData.Preset_Values)){
                                Map<String, Object> valuesByAttribute = (Map<String, Object>)featureByAttribute.get(PMP_StaticConstants_MasterData.Preset_Values);
                                if(valuesByAttribute != null && valuesByAttribute.containsKey(PMP_StaticConstants_MasterData.Identifier) && valuesByAttribute.containsKey(PMP_StaticConstants_MasterData.Values)){
                                    String identifier;
                                    String value;
                                    if(valuesByAttribute.get(PMP_StaticConstants_MasterData.Identifier) == PMP_StaticConstants_MasterData.Yes && valuesByAttribute.get(PMP_StaticConstants_MasterData.Values) == PMP_StaticConstants_MasterData.Yes){
                                        value = String.valueOf(levelValue);
                                        identifier = String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Spec_Identifier));
                                    }
                                    else{
                                        identifier = String.valueOf(valuesByAttribute.get(PMP_StaticConstants_MasterData.Identifier));
                                        value = String.valueOf(valuesByAttribute.get(PMP_StaticConstants_MasterData.Values));
                                    }
                                    if(identifier.length()>0 && value.length()>0){
                                        String categoryKey = (String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier))).toLowerCase().deleteWhitespace();
                                        String specKey = (String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Spec_Identifier))).toLowerCase().deleteWhitespace();
                                        String specValueKey = (String.valueOf(featureByAttribute.get(PMP_StaticConstants_MasterData.Spec_Identifier)) + '_' + identifier.toLowerCase()).deleteWhitespace();
                                        String assocKey = categoryKey + PMP_StaticConstants_MasterData.Pipe_Symbol + specKey + PMP_StaticConstants_MasterData.Pipe_Symbol + specValueKey;
                                        if(categoriesByExternalKey.get(categoryKey) != null 
                                           && existingSpecsByExternalKey.get(specKey) != null
                                           && existingSpecValuesByExternalKey.get(specValueKey) != null){
                                            PMP_Specification_Value_Association__c specSpecValueAssoc = new PMP_Specification_Value_Association__c();
                                            specSpecValueAssoc.PMP_Specification_Id__c = existingSpecsByExternalKey.get(specKey).Id;
                                            specSpecValueAssoc.PMP_Category_Id__c = categoriesByExternalKey.get(categoryKey).Id;
                                            specSpecValueAssoc.PMP_Specification_Value_Id__c = existingSpecValuesByExternalKey.get(specValueKey).Id;
                                            specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c = assocKey; 
                                            specSpecValueAssoc.Name = value;
                                            
                                            if(Boolean.valueOf((categoriesByExternalKey.get(categoryKey)).PMP_Active_Ind__c) 
                                               && Boolean.valueOf((existingSpecsByExternalKey.get(specKey)).PMP_Active_Ind__c) 
                                               && Boolean.valueOf((existingSpecValuesByExternalKey.get(specValueKey)).PMP_Active_Ind__c)){
                                                   
                                                specSpecValueAssoc.PMP_Active_Ind__c = true;    
                                            }
                                            else{
                                                specSpecValueAssoc.PMP_Active_Ind__c = false;   
                                            }
                                            if(!uploadableSpecValuesAssocByExternalkey.containsKey(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c)){
                                                uploadableSpecValuesAssocByExternalkey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c,specSpecValueAssoc);   
                                            }
                                        }
                                    }
                                  }
                               }
                            }
                        }
                    }
                }
            }
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
        uploadableCatSpecAssocByExternalkey.clear();
        for(String externalId : uploadableSpecValuesAssocByExternalkey.keySet()){
            if(uploadableSpecValueAssoc.size() < 9000){//if uploadable specs are less than 9000, add it to a list 
                uploadableSpecValueAssoc.add(uploadableSpecValuesAssocByExternalkey.get(externalId));
            }
            else{//if more than 9000, call the future method to upload the records
                String uploadRecJSON = JSON.serialize(uploadableSpecValueAssoc);
                PMP_CreateJunctionData.uploadExcessSpecSpecValueAssRec(uploadRecJSON);
                uploadableSpecValueAssoc.clear();//clear off the list
            }
        }
        if(uploadableSpecValueAssoc.size() > 0){//process the remaining values
               String uploadRecJSON = JSON.serialize(uploadableSpecValueAssoc);
               PMP_CreateJunctionData.uploadExcessSpecSpecValueAssRec(uploadRecJSON);//again call the future method for the remianing specValues 
        }
        if(uploadableCatSpecAssoc.size() > 0){
            try{
                Schema.SObjectField upsertSpecKey = PMP_Category_Specification_Association__c.Fields.PMP_Category_Specification_External_Key__c;//fetch the cat-spec externalkey
                upsertResultData = Database.upsert(uploadableCatSpecAssoc,upsertSpecKey,false);//upsert the records
            }
            catch(Exception exp1){
                throw exp1;
            }
        }
      return upsertResultData;
    }
    
    // future Method to handle Governor Limits for DML on more than 10K records
    @future
    public static void uploadExcessSpecSpecValueAssRec(String uploadRecsJSON){
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();
        uploadableSpecValueAssoc = (List<PMP_Specification_Value_Association__c>)JSON.deserialize(uploadRecsJSON, List<PMP_Specification_Value_Association__c>.class);
        if(uploadableSpecValueAssoc.size()>0 && Schema.sObjectType.PMP_Specification_Value_Association__c.isCreateable() && Schema.sObjectType.PMP_Specification_Value_Association__c.isUpdateable()){
           try{
               upsert uploadableSpecValueAssoc PMP_Category_Spec_Value_External_Key__c;//upsert the spec-specValue assoc records
           }
           catch(Exception exp3){
                throw exp3;
           }
        }
    }
}