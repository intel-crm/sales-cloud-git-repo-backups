@isTest
/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_ParseProcessorJSON
* Created Date: 9th Jan,2019
* Modification Log :
* Developer                         Version                             Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Manasa                   1.0                                09/01/2019                          Created for Parsing the Processor JSON and creating Specification
* Infosys - Raj Yadav                2.0                                12/06/2020                          Refactored class for easy maintainance 
******************************************************************************************************************************************************************************************************/
public with sharing class PMP_ParseProcessorJSON {
    //IPA 2.0- US-TWC729-7980
    /*public static String languageCode; 
    public static final String ultimateParentPIMId = 'NPP_Processors';
    public static final String ultimateParentEnglishName = 'Processors';
    public static final String ultimateParentChineseName = '处理器';
    public static final String ultimateParentJapaneseName = 'プロセッサー';
    public static final String specificationType = 'Processor';
    public static final String staticResourceTestFileName = 'PMP_Processors_Attribute_Test';//test static resource for Processor
    public static List<Database.UpsertResult> parseProcessorJSON(String staticResourceName){
        
        String jsonStr;//to store JSON file as string
        //String fileLanguage;//to store languge code of the file which is being processed
        Integer leafLevel;//to store the leaf level of the file which is being processed
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();//to store PMP_Locale_To_FieldAPINm_Mapping__mdt metadata records
        Map<String, Object> specsByLanguageCode = new Map<String, Object>();//map containing all specs with language code as key (Map<'en_US', [Specifications]>)
        Map<String, PMP_Specification__c> existingSpecsByExternalKey = new Map<String,PMP_Specification__c>();//map to store existing specs by it's externalkey
        Map<String, PMP_Specification_Value__c> existingSpecValuesByExternalKey = new Map<String,PMP_Specification_Value__c>();//map to store exsting specValues by it's externalkey
        Map<String, String> fieldAPINameByObjectName = new Map<String, String>();//map to store field api names by object name
        Map<String,PMP_Specification__c> uploadableSpecsByExternalKey= new Map<String,PMP_Specification__c>();//map to store specs by external key which is to be uploaded
        Map<String,PMP_Specification_Value__c> uploadableSpecValuesByExternalKey= new Map<String,PMP_Specification_Value__c>();//map to store specValues by external key which is to be uploaded
        List<PMP_Specification__c> uploadableSpecifications = new List<PMP_Specification__c>();//list of specifications to be uploaded
        List<PMP_Specification_Value__c> uploadableSpecificationValues = new List<PMP_Specification_Value__c>();//list of specificationValues to be uploaded
        List<Database.UpsertResult> specUpsertResultData = new List<Database.UpsertResult>();//list containing upsert results for specifications
        List<Database.UpsertResult> specValueUpsertResultData = new List<Database.UpsertResult>();//list containing upsert results for specificationValues
        List<Database.UpsertResult> upsertResultData = new List<Database.UpsertResult>();//list containing upsert result
        
        //fetch the Processor JSON file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceTestFileName];
            jsonStr = staticResourceFile.body.toString();
        }
        else{
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceName];
            jsonStr = staticResourceFile.body.toString(); 
        }
        
        specsByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);//deserializing string and storing it in a Map<String, Object>
        leafLevel = PMP_Utility.getLeafNode(specsByLanguageCode);//fetch the leaf level of the current list of specifications.
        */
        /** fetch existing Processor specs and specValues and populate two maps to handle :
        * fallback scenario for languages other than english
        * activation and deactivation of specs and specValues*/
        //iterate over existing specs and populate existingSpecsByExternalKey map
        /*for(PMP_Specification__c spec : [SELECT id, Name, PMP_Specification_Name__c, PMP_Partner_Product_Specification_Key__c, PMP_Partner_Product_Specification_Id__c,
                                         PMP_Product_Parent_Specification_Id__c, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c, PMP_Active_Ind__c 
                                         FROM PMP_Specification__c WHERE PMP_Specification_Type_Nm__c =: specificationType]){
                                             existingSpecsByExternalKey.put(spec.PMP_Partner_Product_Specification_Key__c, spec);
                                         }
        //iterate over existing specValues and populate existingSpecValuesByExternalKey map
        for(PMP_Specification_Value__c specValue : [SELECT id, Name, PMP_Specification_Value_Nm__c, PMP_Product_Specification_Value_Key__c, PMP_Specification_Value_Chinese_Cd__c,
                                                    PMP_Specification_Value_Japanese_Cd__c, PMP_Active_Ind__c 
                                                    FROM PMP_Specification_Value__c WHERE PMP_Spec_Value_Type_Nm__c =: specificationType]){
                                                        existingSpecValuesByExternalKey.put(specValue.PMP_Product_Specification_Value_Key__c, specValue);
                                                    }
        if(!Test.isRunningTest()){
            languageCode = new list<String>(specsByLanguageCode.keySet())[0];
        }
        if(Schema.sObjectType.PMP_Locale_To_FieldAPINm_Mapping__mdt.isAccessible()){//fetch all the name fields for different different languages
            localeFields = [SELECT PMP_Locale_Nm__c, PMP_Field_Nm__c, PMP_Object_Nm__c, PMP_Field_APINm__c 
                        FROM PMP_Locale_To_FieldAPINm_Mapping__mdt WHERE PMP_Locale_Nm__c =: languageCode AND PMP_Field_Nm__c ='Name'];
        }
        
        if(!localeFields.isEmpty()){
            for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){//iterate over metadata records and populate fieldAPINameByObjectName map
                fieldAPINameByObjectName.put(localField.PMP_Object_Nm__c, localField.PMP_Field_APINm__c);
            }
        }
        
        if(!specsByLanguageCode.isEmpty()){
            List<Object> specNodes = (List<Object>)specsByLanguageCode.get(languageCode);//get the list of specifications associated with the current language code
            
            for(Integer specNodesIndex = 0; specNodesIndex < specNodes.size(); specNodesIndex++){//iterate over all specNodes in the list and create spec and specValue records
                Map<String, Object> specNodeByAttribute = (Map<String, Object>)specNodes[specNodesIndex];//fetch specNodes and use diiferent attributes to create spec and specValue records
                
                if(!specNodeByAttribute.isEmpty() && specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.ChildCategories)){//if spec node is not empty and it has child specs
                    List<Object> childSpecifications = (List<Object>)specNodeByAttribute.get(PMP_StaticConstants_MasterData.ChildCategories);//get all the child specs
                    
                    for(Integer specIndex = 0; specIndex < childSpecifications.size(); specIndex++){//iterate over child specs and create spec or specValue records
                        Map<String, Object> childSpecsByAttribute = (Map<String, Object>)childSpecifications[specIndex];//store child specs in a map
                        
                        //if childspecAttribute map has level attribute and level is not equals to leaf level then create specification records, else create specValue records 
                        if(specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Level) && specNodeByAttribute.get(PMP_StaticConstants_MasterData.Level) != leafLevel){
                            PMP_Specification__c specification = new PMP_Specification__c();//create an instance of specification object
                            specification.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;//set display type as checkbox
                            specification.PMP_Specification_Type_Nm__c = specificationType;//set specification Type as Processor
                            specification.PMP_Active_Ind__c = true;//set specification active indicator as true by default
                            if(languageCode == PMP_StaticConstants_MasterData.English_JSON){
                                //if current spec contains imageURL attribute, store it in image URL field of spec record
                                specification.PMP_Image_url__c = childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Image_URL)?
                                                                    String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Image_URL)):null;
                                //if current spec contains productCatalogURL attribute, store it in product URL field of spec record
                                specification.PMP_Product_url__c = childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Product_Catalog_URL)?
                                                                    String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Product_Catalog_URL)):null;
                            }
                            //Check if the current spec is the top node(i.e direct child of ultimate parent)for all three files,if yes set parent PIMId as NPP_Processor
                            if((specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentName) == ultimateParentEnglishName) || 
                               (specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentName) == ultimateParentChineseName) || 
                               (specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentName) == ultimateParentJapaneseName)){   
                                   specification.PMP_Product_Parent_Specification_Id__c = ultimateParentPIMId;
                               }
                            else{//else get the parent PIMId from the files received 
                                specification.PMP_Product_Parent_Specification_Id__c = String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier));  
                            }
                            //if specNodeByAttribute map contains sequence and childSpecsByAttribute contains SpecValueSequence use them to create sequence number of specification 
                            if(specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Sequence) && childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecValueSequence)){
                                //fetch sequence number of the spec from utility method 
                                specification.PMP_Partner_Product_Display_Sequence_Nbr__c = PMP_Utility.getSpecificationSequenceNumber(specNodeByAttribute, childSpecsByAttribute);
                            }
                            //if the current spec is having specRaw value and display value,populate external key, PIM Id, and name fields 
                            if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue)){
                                specification.PMP_Partner_Product_Specification_Key__c = (String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(); 
                                specification.PMP_Partner_Product_Specification_Id__c = String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                String specificationName = String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                if(languageCode != PMP_StaticConstants_MasterData.English_JSON){
                                    PMP_Specification__c spec = existingSpecsByExternalKey.get(specification.PMP_Partner_Product_Specification_Key__c);//get the existing(if exists) record for current spec
                                    String localField = String.valueOf(fieldAPINameByObjectName.get('Specification'));//get the current language field of specification object
                                    if(String.isNotBlank(specificationName)){//if the displayValue is not null in the file, populate local field with that value
                                        specification.put(localField, specificationName);
                                    }
                                    //if the name in the file is blank, populate local field with english data.
                                    else if(String.isBlank(specificationName) && spec != null && String.isNotBlank(spec.PMP_Specification_Name__c)){
                                        specification.put(localField, spec.PMP_Specification_Name__c);
                                    }
                                }
                                else{//if the current file is english file, store the english name in standard as well as custom name field.
                                    specification.Name = specificationName.length() > 80 ? specificationName.substring(0, 80) : specificationName;//if the name is more than 80 chars, only 80 chars will get save in standard field
                                    specification.PMP_Specification_Name__c = specificationName;//storing the full name in custom name field
                                }
                            }
                            //if externalKey of the current spec is not blank, store the spec in uploadableSpecsByExternalKey map 
                            if(String.isNotBlank(specification.PMP_Partner_Product_Specification_Key__c)){
                                uploadableSpecsByExternalKey.put(specification.PMP_Partner_Product_Specification_Key__c, specification);
                            }
                        }
                        else{//processing items which are at leaf level, and creating specValue records 
                            PMP_Specification_Value__c specificationValue = new PMP_Specification_Value__c();//create an instance if specifcation Value object
                            specificationValue.PMP_Display_Type_Nm__c= PMP_StaticConstants_MasterData.Checkbox;//set display type as checkbox
                            specificationValue.PMP_Spec_Value_Type_Nm__c = specificationType;//set specificationValue Type as Processor
                            //if current spec contains status attribute, store it in product status field of secValue
                            specificationValue.PMP_Product_Status__c = (childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Status))? 
                                String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Status)):null;
                            //if current spec contains restriction Level attribute, store it in the restriction level field
                            specificationValue.PMP_Product_Restriction_Lvl__c = (childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Restriction_Level))? 
                                String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Restriction_Level)): '0';
                            if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.NPP_Is_Active) && languageCode == PMP_StaticConstants_MasterData.English_JSON){//if node contains isActive indicator, store it in isActive field of specValue record
                                specificationValue.PMP_Active_Ind__c = (String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.NPP_Is_Active)) == PMP_StaticConstants_MasterData.Yes)?
                                    true : false;
                            }
                            if(languageCode == PMP_StaticConstants_MasterData.English_JSON){
                                //if current spec contains imageURL attribute, store it in image URL field of specValue record
                                specificationValue.PMP_Image_URL__c = childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Image_URL)?
                                    String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Image_URL)):null;
                                //if current spec contains productCatalogURL attribute, store it in product URL field of specValue record
                                specificationValue.PMP_Product_URL__c = childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Product_Catalog_URL)?
                                    String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Product_Catalog_URL)):null;
                            }
                            if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.Off_Roadmap) && languageCode == PMP_StaticConstants_MasterData.English_JSON){//if node contains Off_Roadmap indicator, store it in Off_Roadmap field of specValue record
                                specificationValue.PMP_Partner_Off_Roadmap_Ind__c = (String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.Off_Roadmap)) == PMP_StaticConstants_MasterData.Yes)?
                                                                                                                                                                                true : false;
                            }
                            specificationValue.PMP_Specification_Product_Cd__c = String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.ParentIdentifier));
                            //if the current spec is having specRaw value and display value,populate external key, PIM Id, and name fields 
                            if(childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue)){
                                specificationValue.PMP_Product_Specification_Value_Cd__c = String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                specificationValue.PMP_Product_Specification_Value_Key__c = (String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase();
                                //display sequence will be constructed as [parentSpec Level + parentSpec Sequence + spec Sequence]
                                specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueOf(String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecValueSequence)).remove(','));
                                String specValueName = String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                if(languageCode != PMP_StaticConstants_MasterData.English_JSON){
                                    PMP_Specification_Value__c specValue = existingSpecValuesByExternalKey.get(specificationValue.PMP_Product_Specification_Value_Key__c);//get the existing(if exists) record for current spec
                                    String localField = String.valueOf(fieldAPINameByObjectName.get('Specification Value'));//get the current language field of specificationValue object
                                    if(String.isNotBlank(specValueName)){//if the displayValue is not null in the file, populate local field with that value
                                        specificationValue.put(localField, specValueName);
                                    }
                                    //if the name in the file is blank, populate local field with english data.
                                    else if(String.isBlank(specValueName) && specValue != null && String.isNotBlank(specValue.PMP_Specification_Value_Nm__c)){
                                        specificationValue.put(localField, specValue.PMP_Specification_Value_Nm__c);
                                    }
                                }
                                else{//if the current file is english file, store the english name in standard as well as custom name field.
                                    
                                    specificationValue.Name = specValueName.length() > 80 ? specValueName.substring(0, 80) : specValueName;//if the name is more than 80 chars, only 80 chars will get save in standard field
                                    specificationValue.PMP_Specification_Value_Nm__c = specValueName;//storing the full name in custom name field
                                }
                            }
                            //if externalKey of the current specValue is not blank, store the specValue in uploadableSpecValuesByExternalKey map 
                            if(String.isNotBlank(specificationValue.PMP_Product_Specification_Value_Key__c)){
                                uploadableSpecValuesByExternalKey.put(specificationValue.PMP_Product_Specification_Value_Key__c, specificationValue);
                            }
                        }
                    }
                }
            } 
        }
        
        if(!uploadableSpecsByExternalKey.isEmpty()){//if existingSpecs and uploadable specs map is not empty,handle deactivation of specs
            for(String externalId : existingSpecsByExternalKey.keySet()){//iterate over existing Processor specs and check if new file doesn't contain that spec,deactivate it
                if(!uploadableSpecsByExternalKey.keySet().contains(externalId)){
                    PMP_Specification__c spec = existingSpecsByExternalKey.get(externalId);
                    spec.PMP_Active_Ind__c = false;
                    uploadableSpecsByExternalKey.put(externalId,spec);//push it into uploadable spec map
                }
            }
            uploadableSpecifications.addAll(uploadableSpecsByExternalKey.values());//add all uploadable specifications to the list
        }
        
        if(!uploadableSpecValuesByExternalKey.isEmpty()){//if existingSpecValues and uploadable specValues map is not empty,handle deactivation of specValues
            for(String externalId : existingSpecValuesByExternalKey.keySet()){//iterate over existing Processor specValues and check if new file doesn't contain that specValue,deactivate it
                if(!uploadableSpecValuesByExternalKey.keySet().contains(externalId)){
                    PMP_Specification_Value__c specValue = existingSpecValuesByExternalKey.get(externalId);
                    specValue.PMP_Active_Ind__c = false;
                    uploadableSpecValuesByExternalKey.put(externalId,specValue);//push it into uploadable speValuec map
                }
            }
            uploadableSpecificationValues.addAll(uploadableSpecValuesByExternalKey.values());//add all uploadable specificationValues to the list
        }
        if(!uploadableSpecifications.isEmpty()){//if there are specifications to be uploaded
            try{
                Schema.SObjectField upsertSpecKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;//fetch the spec ExternalKey
                specUpsertResultData = Database.upsert(uploadableSpecifications,upsertSpecKey,false);//upsert the specifications
            }
            catch(Exception exp1){
                throw exp1;
            }
        }
        if(!uploadableSpecificationValues.isEmpty()){//if there are specifiationValues to be uploaded
            try{
                Schema.SObjectField upsertSpecValKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;//fetch the specValue ExternalKey
                specValueUpsertResultData = Database.upsert(uploadableSpecificationValues,upsertSpecValKey,false);//upsert the specification values
            }
            catch(Exception exp2){
                throw exp2;
            }
        }
        
        if(!specUpsertResultData.isEmpty()){//if spec upsert result is not empty, add the results to main result list
            upsertResultData.addAll(specUpsertResultData);
        }
        
        if(!specValueUpsertResultData.isEmpty()){
            upsertResultData.addAll(specValueUpsertResultData);//if specValue upsert result is not empty, add the results to main list
        }
        return upsertResultData;
        
    }*/
}