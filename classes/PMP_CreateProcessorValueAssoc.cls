/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_CreateProcessorValueAssoc
* Version     : 1.0 
* Created Date: 8th Dec, 2020
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            08/12/2020               Created for Parsing leaf nodes of Processor JSON and create Spec-Specvalue Association
******************************************************************************************************************************************************************************************************/
public With Sharing class PMP_CreateProcessorValueAssoc {

    public static String languageCode;
        public static final String staticResourceFileName = 'Processors_Attribute_English';//static resource for processor
        public static final String staticResourceTestFileName = 'PMP_Processors_Attribute_Test';//static resource for testing this class
    
    @future
    public static void processLeafNodes(){
        
        Map<String, Object> specsByLanguageCode = new Map<String, Object>();//map containing all specs with language code as key (Map<'en_US', [Specifications]>)
        List<Map<String, Object>> leafNodes = new List<Map<String, Object>>();
        String jsonStr;//to store JSON file as string
        Integer leafLevel;//to store the leaf level of the file which is being processed
        
        //fetch the NUC JSON file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceTestFileName];
            jsonStr = staticResourceFile.body.toString();
        }
        else{
           	StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceFileName];
            jsonStr = staticResourceFile.body.toString(); 
        }
        
        specsByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);//deserializing string and storing it in a Map<String, Object>
        jsonStr = null;
        leafLevel = PMP_Utility.getLeafNode(specsByLanguageCode);//fetch the leaf level of the current list of specifications.
        
        languageCode = new list<String>(specsByLanguageCode.keySet())[0];
        
        List<Object> specNodes = (List<Object>)specsByLanguageCode.get(languageCode);//get the list of specifications associated with the current language code
        
        for(Integer specNodesIndex = 0; specNodesIndex < specNodes.size(); specNodesIndex++){//iterate over all specNodes in the list and create spec and specValue records
            Map<String, Object> specNodeByAttribute = (Map<String, Object>)specNodes[specNodesIndex];//fetch specNodes and use diiferent attributes to create spec and specValue records
            //if childspecAttribute map has level attribute and level is not equals to leaf level then create category-spec association records 
            if(specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Level) && specNodeByAttribute.get(PMP_StaticConstants_MasterData.Level) == leafLevel){
                
                leafNodes.add(specNodeByAttribute);
                
               
            }
        }
      
        List<List<Map<String, Object>>> leafNodeBatches = new List<List<Map<String, Object>>>();
        String parentsToProcess= PMP_Utility.getValue('Taxonomy_Parents_To_Process');
		Integer noOfParentsToBeProcessed = Integer.ValueOf(parentsToProcess); //modify this as per the requirement
		Integer noOfPartitions = leafNodes.size()/noOfParentsToBeProcessed;
        if(math.mod(leafNodes.size(), noOfParentsToBeProcessed) != 0){
            noOfPartitions += 1;
        }
           
        for(Integer i = 0; i<noOfPartitions; i++){
        	List<Map<String, Object>> batch = new List<Map<String, Object>>();
            for(Integer j = noOfParentsToBeProcessed*i; j<noOfParentsToBeProcessed*(i+1); j++){
                if(j == leafNodes.size()){
                    break;
                }
                
                batch.add(leafNodes[j]);
            }
            
            leafNodeBatches.add(batch);
        }
        
        System.enqueueJob(new PMP_ProcessorUpload_Queueable(leafNodeBatches));
    }
    
    public static void createSpecValueAssociations(List<Map<String, Object>> specNodeByAttributes){
        
        final String ultimateParentPIMId = 'NPP_Processors';//UltimateParentId
        final String specificationType = 'Processor';
        Set<Id> associatedCategories = new Set<Id>();//set consisting category Ids related to Processor spec
        Map<String, PMP_Specification_Value_Association__c> uploadableSpecValuesAssocByExternalkey = new Map<String , PMP_Specification_Value_Association__c>();
        Map<String, PMP_Specification__c> existingSpecsByExternalKey = new Map<String,PMP_Specification__c>();//map to store existing specs by it's externalkey
        Map<String, PMP_Specification_Value__c> existingSpecValuesByExternalKey = new Map<String,PMP_Specification_Value__c>();//map to store existing specValues by it's externalkey
        PMP_Specification__c ultimateParentRecord = new PMP_Specification__c();//specification instance to store ultimateParentRecord
        List<PMP_Specification_Value_Association__c> uploadableSpecValueAssoc = new List<PMP_Specification_Value_Association__c>();
        //List<PMP_Specification_Value_Association__c> assocToBeDeactivated = new List<PMP_Specification_Value_Association__c>();
        Map<String, PMP_Specification_Value_Association__c> existingSpecSpecValueAssocByExternalKey = new Map<String, PMP_Specification_Value_Association__c>();
        Set<String> parentSpecs = new Set<String>();//set containing all the parent spec which is to be associated with values
        
        for(PMP_Specification__c spec : [SELECT Id,Name,PMP_Specification_Name__c,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Id__c,
                                         PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c 
                                         FROM PMP_Specification__c WHERE (PMP_Specification_Type_Nm__c =: specificationType 
                                                                          OR PMP_Partner_Product_Specification_Id__c =: ultimateParentPIMId)]){//populate existingSpecsByExternalKey map
                                                                              existingSpecsByExternalKey.put(spec.PMP_Partner_Product_Specification_Key__c,spec);
                                                                          }
        for(PMP_Specification_Value__c specValue : [SELECT Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c 
                                                    FROM PMP_Specification_Value__c WHERE PMP_Spec_Value_Type_Nm__c =: specificationType]){//populate existingSpecValuesByExternalKey map
                                                        existingSpecValuesByExternalKey.put(specValue.PMP_Product_Specification_Value_Key__c,specValue);
                                                    }
        
        if(Schema.sObjectType.PMP_Specification__c.isAccessible()){//fetching the ultimate parent record for Processor
            ultimateParentRecord = [SELECT Id,Name,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c 
                                    WHERE PMP_Partner_Product_Specification_Id__c =: ultimateParentPIMId AND PMP_Active_Ind__c = true LIMIT 1 FOR UPDATE];
        }
        if(ultimateParentRecord != null && Schema.sObjectType.PMP_Category_Specification_Association__c.isAccessible()){//if parent record is there fetch the category-spec Association record for Processor, using ultimate parent's record Id 
            List<PMP_Category_Specification_Association__c> associatedCategoriesRecords = [SELECT Id,Name,PMP_Active_Ind__c,PMP_Category_Id__c FROM PMP_Category_Specification_Association__c 
                                                                                           WHERE PMP_Specification_Id__c =: ultimateParentRecord.Id AND PMP_Active_Ind__c = true];
            for(PMP_Category_Specification_Association__c csa : associatedCategoriesRecords ){//iterate over the association records and populate associatedCategories set
                associatedCategories.add(csa.PMP_Category_Id__c);
            }
        }
        //map containing category records by recordId
        Map<Id,PMP_Category__c> categoriesById= new Map<Id,PMP_Category__c>([SELECT Id,PMP_Active_Ind__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c,Name 
                                                                             FROM PMP_Category__c WHERE Id in: associatedCategories and PMP_Active_Ind__c = true]);
          
        
        for(Integer i = 0; i<specNodeByAttributes.size(); i++){
            Map<String, Object> specNodeByAttribute = specNodeByAttributes[i];
            parentSpecs.add(String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier)));
            
            if(specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.ChildCategories)){//if spec node has child specs
                List<Object> childSpecifications = new List<Object>();
                childSpecifications = (List<Object>)specNodeByAttribute.get(PMP_StaticConstants_MasterData.ChildCategories);//get all the child specs
                for(Integer specIndex = 0; specIndex < childSpecifications.size(); specIndex++){//iterate over child specs and create spec or specValue records
                    Map<String, Object> childSpecsByAttribute = new Map<String, Object>();
                    childSpecsByAttribute = (Map<String, Object>)childSpecifications[specIndex];//store child specs in a map
                    //List<Id> cat = new List<Id>(associatedCategories);
                    for(Id categoryId : associatedCategories){//iterate over all the associated categories
                        if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue) != null){
                            PMP_Category__c categoryRecord = new PMP_Category__c();
                            PMP_Specification_Value__c specificationValueRecord = new PMP_Specification_Value__c();
                            PMP_Specification__c specificationRecord = new PMP_Specification__c();    
                            categoryRecord = categoriesById.get(categoryId);//get the category record
                            specificationValueRecord = existingSpecValuesByExternalKey.get(String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
                            specificationRecord = existingSpecsByExternalKey.get(String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase());
                            PMP_Specification_Value_Association__c specSpecValueAssoc = new PMP_Specification_Value_Association__c();
                            specSpecValueAssoc.PMP_Category_Id__c = categoryId;
                            specSpecValueAssoc.PMP_Specification_Value_Id__c = specificationValueRecord != null ? specificationValueRecord.Id : null;
                            specSpecValueAssoc.PMP_Specification_Id__c = specificationRecord != null ? specificationRecord.Id : null;
                            specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c = String.valueOf(categoryRecord.PMP_Partner_Product_Category_Cd__c + PMP_StaticConstants_MasterData.Pipe_Symbol +
                                                                                                        specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier) + PMP_StaticConstants_MasterData.Pipe_Symbol + 
                                                                                                        childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).toLowerCase();
                            
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
        if(!parentSpecs.isEmpty()){
         	for(PMP_Specification_Value_Association__c sva : [SELECT Id,PMP_Category_Spec_Value_External_Key__c, PMP_Active_Ind__c FROM PMP_Specification_Value_Association__c 
                                                              WHERE (PMP_Active_Ind__c = true and PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c IN :parentSpecs) OR
                                                              (PMP_Active_Ind__c = true and PMP_Specification_Id__r.PMP_Active_Ind__c = false and PMP_Specification_Id__r.PMP_Specification_Type_Nm__c =: specificationType)]){
            													existingSpecSpecValueAssocByExternalKey.put(sva.PMP_Category_Spec_Value_External_Key__c, sva);
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
        uploadableSpecValueAssoc.addAll(uploadableSpecValuesAssocByExternalkey.values());
        //system.debug('uploadableSpecValueAssoc123' + uploadableSpecValueAssoc);
        uploadableSpecValuesAssocByExternalkey.clear();
        Schema.SObjectField upsertSpecKey = PMP_Specification_Value_Association__c.Fields.PMP_Category_Spec_Value_External_Key__c;//fetch the cat-spec externalkey
       	Database.upsert(uploadableSpecValueAssoc,upsertSpecKey,false);//upsert the records
      
    }
}