/****************************************************************************************************************************************
* Class Name  : PMP_ParseCategoryJSON 
* Version     : 1.0 
* Created Date: 09-07-2018
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     09/07/2018                    Created for reading PIM Category JSON and create Category data
* Infosys - Sangeetha Ganta     12/24/2018                    User Story - US244679. Sequencing of Categories
* Infosys - Sangeetha Ganta     02/26/2019                    User Story - US247100. Adding Tool Tip and updating Is Active Flag as per the JSON
* Infosys - Raj Yadav           03/26/2019                    User Story - US259835 - handle translations for categories
* Infosys - Sangeetha Ganta     04/15/2019                    Renaming the client business segment to Personal Computers
* Infosys - Raj Yadav			06/25/2020					  Refactored code for easy maintainance
*****************************************************************************************************************************************/
public with sharing class PMP_ParseCategoryJSON {   
    public static String languageCode;
    public static final String staticResourceTestFileName = 'PMP_Category_Hierarchy_Test';//static resource for NUC
    
    public static List<Database.UpsertResult> parseCategoryJSON(String staticResourceName){	
        
        String jsonStr;
        Map<String, String> localFieldsByFieldLabel = new Map<String, String>();//map containing language field api names by their label
        Map<String, Object> categoriesByLanguageCode = new Map<String, Object>();//map containing all categories with language code as key (Map<'en_US', [Categories]>)
        Map<String, PMP_Category__c> existingCategoriesByExternalKey = new Map<String, PMP_Category__c>();//map containing existing categories by external key
        Map<String, PMP_Category__c> uploadableCategoriesByExternalKey = new Map<String, PMP_Category__c>();//map containing uploadable categories by external key
        List<PMP_Category__c> uploadableCategories = new List<PMP_Category__c>();//list containing categories to be loaded
        List<Database.UpsertResult> categoryUpsertResultData = new List<Database.UpsertResult>();//list containing category upsert result data
        //list of partner segment nodes in JSON file, used to avoid insertion of these nodes in category table
        List<String> partnerSegmentPIMIds = new List<String>{'Intel_Segments_NPP_01','Intel_Segments_NPP_01_Busines_ Segments','Intel_Segments_Client_Computing','Intel_Segments_Data_Center','Intel_Segments_Embedded_IoT','Intel_Segments_Field_Programmable_Gate_Array'};
        
        //fetch the category JSON file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){  
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceTestFileName];
            jsonStr = staticResourceFile.body.toString();
        }
        else{
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name = :staticResourceName];
            jsonStr = staticResourceFile.body.toString();
        }
        categoriesByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        if(!Test.isRunningTest()){
            languageCode = new list<String>(categoriesByLanguageCode.keySet())[0];
        }
        /** fetch existing categories and populate a map to handle :
		* fallback scenario for languages other than english
		* deactivation of categories*/
        //iterate over existing categories and populate existingCategoriesByExternalKey map
        for(PMP_Category__c category: [SELECT id, Name, PMP_Partner_Offering_Category_Dsc__c, PMP_Tool_Tip_English_Txt__c, PMP_Partner_Product_Category_Key__c, 
                                       PMP_Partner_Product_Category_Cd__c from PMP_Category__c WHERE PMP_Active_Ind__c = true]){
        	existingCategoriesByExternalKey.put(category.PMP_Partner_Product_Category_Key__c, category);   
        }
        //fetch all the fields for the given languageCode
        for (PMP_Locale_To_FieldAPINm_Mapping__mdt localeFields: [SELECT PMP_Locale_Nm__c, PMP_Field_Nm__c, PMP_Object_Nm__c, PMP_Field_APINm__c FROM PMP_Locale_To_FieldAPINm_Mapping__mdt 
                                                                  WHERE PMP_Locale_Nm__c =: languageCode AND PMP_Object_Nm__c ='Category']){
        	localFieldsByFieldLabel.put(localeFields.PMP_Field_Nm__c, localeFields.PMP_Field_APINm__c);
        }
        //List containing all the category nodes present in hierarchy file
        List<Object> categoryNodes = (List<Object>)categoriesByLanguageCode.get(languageCode); 
        
        for(Integer categoryNodeIndex = 0; categoryNodeIndex < categoryNodes.size(); categoryNodeIndex++){            
            PMP_Category__c category = new PMP_Category__c();//create a new catetgory instance
            Map<String, Object> categoryNodeByAttribute = (Map<String, Object>)categoryNodes[categoryNodeIndex];//get the category with all it's attributes
            
            if(!categoryNodeByAttribute.isEmpty()){//if the category is not null, start populating the fields of category
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Identifier)){//if PIM Id is present for the category, populate the respective fields 
                    category.PMP_Partner_Product_Category_Cd__c = String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier));
                    category.PMP_Partner_Product_Category_Key__c = (String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Identifier))).toLowerCase();
                }
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Parent_Identifier)){//populate parent PIM Id of the catetgory
                    category.PMP_Partner_Product_Parent_Category_Cd__c = String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Parent_Identifier));
                }
                if(languageCode != PMP_StaticConstants_MasterData.English_JSON){//if the current file is a non-english file, populate local fields
                    PMP_Category__c existingCategory = existingCategoriesByExternalKey.get(category.PMP_Partner_Product_Category_Key__c);//fetch the existing category, for fallback scenario
                    if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Name)){//populating local Name fields of category
                        String localNameField = localFieldsByFieldLabel.get('Name');
                        String categoryName=String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Name));
                        if(String.isNotBlank(categoryName)){//if the categoryName is not null in the file, populate local field with that value
                            category.put(localNameField, categoryName);
                        }
                        else if(String.isBlank(categoryName) && existingCategory != null && String.isNotBlank(existingCategory.Name)){//if the name in the file is blank, populate local field with english data.
                            category.put(localNameField, existingCategory.Name);
                        }  
                    }
                    if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Description)){//populating local description fields of category
                        String localDescriptionField = localFieldsByFieldLabel.get('Description');
                        String categoryDescription=String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Description));
                        if(String.isNotBlank(categoryDescription)){//if the categoryDescription is not null in the file, populate local field with that value
                            category.put(localDescriptionField, categoryDescription);
                        }
                        else if(String.isBlank(categoryDescription) && existingCategory != null && String.isNotBlank(existingCategory.PMP_Partner_Offering_Category_Dsc__c)){//if the name in the file is blank, populate local field with english data.
                            category.put(localDescriptionField, existingCategory.PMP_Partner_Offering_Category_Dsc__c);
                        }
                    }
                    if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Tool_Tip)){//populating local tooltip fields of category
                        String localTooltipField = localFieldsByFieldLabel.get('Tooltip');
                        String categoryTooltip=String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Tool_Tip));
                        if(String.isNotBlank(categoryTooltip)){//if the categoryTooltip is not null in the file, populate local field with that value
                            category.put(localTooltipField, categoryTooltip);
                        }
                        else if(String.isBlank(categoryTooltip) && existingCategory != null && String.isNotBlank(existingCategory.PMP_Tool_Tip_English_Txt__c)){//if the name in the file is blank, populate local field with english data.
                            category.put(localTooltipField, existingCategory.PMP_Tool_Tip_English_Txt__c);
                        }
                    }
                }
                else if(languageCode == PMP_StaticConstants_MasterData.English_JSON){//if the current file is english file
                    if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Name)){//populate english name field
                        String categoryName=String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Name));
                        category.Name = categoryName;
                    }
                    if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Description)){//populate english description field
                        String categoryDescription=String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Description));
                        category.PMP_Partner_Offering_Category_Dsc__c = categoryDescription;
                    }
                    if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Tool_Tip)){//populate english tooltip field
                        String categoryTooltip=String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Tool_Tip));
                        category.PMP_Tool_Tip_English_Txt__c = categoryTooltip;
                    }
                }  
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Image_URL)){//populate image URL field, if the URL is present
                    category.PMP_Category_Image_URL_Txt__c = String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Image_URL));
                }
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Child_Mandatory_Flag)){//populate childmandatory flag
                    category.PMP_ChildMandatory_Ind__c = String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Child_Mandatory_Flag)) == PMP_StaticConstants_MasterData.Yes ? 
                        true : false;
                }
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Is_Active)){//populate active indicator flag
                    category.PMP_Active_Ind__c = Boolean.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Is_Active));
                }
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Sequence)){//populate sequence number for the category
                    String sequence = String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Sequence));
                    category.PMP_Category_Display_Sequence_Nbr__c = Integer.valueof(sequence.remove(PMP_StaticConstants_MasterData.Comma_Symbol));
                }
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Selection_Type)){//populate display type of category
                    if(category.PMP_Partner_Product_Category_Cd__c == PMP_StaticConstants_MasterData.Category_PIMId || 
                       category.PMP_Partner_Product_Category_Cd__c == PMP_StaticConstants_MasterData.Application_PIMId || 
                       category.PMP_Partner_Product_Category_Cd__c == PMP_StaticConstants_MasterData.Industry_PIMId){//assign display type as label for top level category,application and industry
                           category.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Label;
                       }
                    else if(String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Selection_Type)).contains(PMP_StaticConstants_MasterData.Radio)){
                        category.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Radiobutton;
                    }
                    else{
                        category.PMP_Display_Type_Nm__c = String.valueOf(categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Selection_Type)); 
                    }
                }
                if(categoryNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Intel_Segment)){
                    List<String> categoryPartnerSegments = new List<String>();
                    List<Object> partnerSegments = (List<Object>)categoryNodeByAttribute.get(PMP_StaticConstants_MasterData.Intel_Segment);
                    for(Integer segmentIdx= 0; segmentIdx<partnerSegments.size(); segmentIdx++) {
                        Map<String,Object> partnerSegmentByAttributes = (Map<String, Object>)partnerSegments[segmentIdx];
                        if(!partnerSegmentByAttributes.isEmpty() && partnerSegmentByAttributes.containsKey(PMP_StaticConstants_MasterData.Spec_Identifier)){
                            //if(partnerSegmentByAttributes.containsKey(PMP_StaticConstants_MasterData.Spec_Identifier)){
                                if(partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Client_Computing_PIMId 
                                   && partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                       categoryPartnerSegments.add(PMP_StaticConstants_MasterData.Personal_Computers);
                                   }
                                if(partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Data_Center_PIMId 
                                   && partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                       categoryPartnerSegments.add(PMP_StaticConstants_MasterData.Server);
                                   }
                                if(partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Embedded_IoT_PIMId 
                                   && partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                       categoryPartnerSegments.add(PMP_StaticConstants_MasterData.IoT);
                                   }
                                if(partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Programmable_Logic_PIMId 
                                   && partnerSegmentByAttributes.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                       categoryPartnerSegments.add(PMP_StaticConstants_MasterData.ProgrammableLogic);
                                }
                                String partnerSegmentForcategory = String.join(categoryPartnerSegments, PMP_StaticConstants_MasterData.SemiColon_Symbol);
                                category.PMP_Business_Segment_Nm__c= partnerSegmentForcategory;

                            //}
                        }
                    } 

                }
            }
            //if the category's PIM Id is partnerSegment's PIM Id, do not insert those records
            if(!partnerSegmentPIMIds.contains(category.PMP_Partner_Product_Category_Cd__c) && category.PMP_Partner_Product_Category_Key__c != null){
                   uploadableCategoriesByExternalKey.put(category.PMP_Partner_Product_Category_Key__c,category);
                   // System.debug('Test123 '+category.Name+'-->'+category.PMP_Business_Segment_Nm__c);
               }
        }
        
        //to handle deactivation of Categories
        if (!uploadableCategoriesByExternalKey.isEmpty()){//if existingCategories and uploadable category map is not empty,handle deactivation of category
            for(String keyId: existingCategoriesByExternalKey.Keyset()){
                if(!uploadableCategoriesByExternalKey.keyset().contains(keyId)){//iterate over existing categories and check if new file doesn't contain that category,deactivate it
                    PMP_Category__c category = existingCategoriesByExternalKey.get(keyId);
                    category.PMP_Active_Ind__c = false;
                    uploadableCategoriesByExternalKey.put(keyId,category);//push it into uploadableCategory map
                } 
            }
            uploadableCategories.addAll(uploadableCategoriesByExternalKey.values());//add all uploadable categories to the list
        }
        if(uploadableCategories.size()>0){//if there are categories to be uploaded
            try{
                Schema.SObjectField upsertKey = PMP_Category__c.Fields.PMP_Partner_Product_Category_Key__c;//fetch the category ExternalKey
                categoryUpsertResultData = Database.upsert(uploadableCategories,upsertKey,false);//upsert the categories
                PMP_Utility.logDmlErrors((Object[]) categoryUpsertResultData, 'PMP_ParseCategoryJSON-parseCategoryJSON');
            }
            catch(Exception exp){
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseCategoryJSON_Exception_Message + exp.getMessage());
                throw exp; // We have to throw the exception so that it will get caught in queable class
            }
            
        }
        return categoryUpsertResultData;//return upsert results data
    }
}