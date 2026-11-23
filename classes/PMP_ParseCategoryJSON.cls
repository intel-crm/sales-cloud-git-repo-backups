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
*****************************************************************************************************************************************/

public class PMP_ParseCategoryJSON 
{   
    public static String strBaseKey;
    public static List<Database.UpsertResult> parseCategoryJSON(String staticResourceName)
    {
        //Variable Declaration
        List<PMP_Category__c> uploadCategories = new List<PMP_Category__c>();
        Map<String,PMP_Category__c> uploadCategoryMap = new Map<String,PMP_Category__c>();
        Map<String,PMP_Category__c> existingEngCatMap = new Map<String,PMP_Category__c>();
        Map<String,PMP_Category__c> catDeactiveMap = new Map<String,PMP_Category__c>();
        String jsonStr = '';
        
        if(Test.isRunningTest()){
            //JSON files for test class
            //Test_Category_Hierarchy   
             StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Test_Category_Hierarchy]; 
            
            jsonStr = srObject.body.toString();
        }
        //JSON files:
        //Category_Hierarchy_English for english
        //Category_Hierarchy_Chinese for chinese
        //Category_Hierarchy_Japanese for japanese
        else{
            
             StaticResource srObject = [select id,body from StaticResource Where Name = :staticResourceName];
            
            jsonStr = srObject.body.toString();
        }
        Map<String,Object> mapCategory = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        Map<String,Object> englishDataMap=new Map<String,Object>();//added by raj for US259835
        //for (string theKey:mapCategory.keySet()){ [Removed for loop as part code scan fix]
            if(!Test.isRunningTest()){
                strBaseKey = new list<String>(mapCategory.keySet())[0];
            }
        	System.debug('^^^TheKey--->'+strBaseKey);//###toberemoved
            //added by raj for US259835
            if(strBaseKey!=PMP_StaticConstants_MasterData.English_JSON){
                
                 List<PMP_Category__c> categories=[SELECT id,PMP_Partner_Product_Category_Cd__c,Name,PMP_Partner_Offering_Category_Dsc__c,PMP_Tool_Tip_English_Txt__c from PMP_Category__c];
               
                for(PMP_Category__c cat:categories){
                    englishDataMap.put(cat.PMP_Partner_Product_Category_Cd__c,cat);
                }
            }
            if(mapCategory.size() > 0)        
            {
                if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                {
                    //to handle activation or inactivation of Categories
                    List<PMP_Category__c> existingEngCats = [Select id,PMP_Active_Ind__c,PMP_Partner_Product_Category_Key__c from PMP_Category__c];
                    if(existingEngCats.size()>0)
                    {
                        for(PMP_Category__c cat : existingEngCats) 
                        {
                            existingEngCatMap.put(cat.PMP_Partner_Product_Category_Key__c,cat); 
                        }
                        
                    }  
                }
                
                List<Object> lstCategory = (List<Object>)mapCategory.get(strBaseKey); 
                
                for(integer catIndex=0;catIndex<lstCategory.size();catIndex++)
                {            
                    PMP_Category__c category = new PMP_Category__c();
                    
                    Map<String, Object> catMap = (Map<String, Object>)lstCategory[catIndex];
                    
                    if(catMap != null && !catMap.isEmpty())
                    {
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Child_Identifier))
                        {
                            
                            category.PMP_Partner_Product_Category_Cd__c = String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Identifier));
                            category.PMP_Partner_Product_Category_Key__c = (String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Identifier))).toLowerCase();
                            
                        }
                        //Category Name
                        //modified by raj
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Child_Name))
                        {   
                            PMP_Category__c cat=(PMP_Category__c)englishDataMap.get(String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Identifier)));
                            String childName=String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Name));
                            //checking the language of the JSON 
                            if(strBaseKey==PMP_StaticConstants_MasterData.Chinese_JSON){
                                //checking for the fallback scenario and mapping the english value to the field
                                if((childName==null||String.isBlank(childName)) && cat!=null && cat.Name!=null){
                                    category.PMP_Category_Chinese_Nm__c=cat.Name;
                                }
                                //mapping the JSON value to the field
                                else if(childName!=null && String.isNotBlank(childName)){
                                    category.PMP_Category_Chinese_Nm__c=childName;
                                }
                            }
                            else if(strBaseKey==PMP_StaticConstants_MasterData.Japanese_JSON){
                                if((childName==null||String.isBlank(childName)) && cat!=null && cat.Name!=null){
                                    category.PMP_Category_Japanese_Nm__c=cat.Name;
                                }
                                else if(childName!=null && String.isNotBlank(childName)){
                                    category.PMP_Category_Japanese_Nm__c=childName;
                                }
                            }
                            else if(strBaseKey==PMP_StaticConstants_MasterData.English_JSON){
                                category.Name = childName;
                            }
                        }
                        //Category Description
                        //modified by raj
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Child_Description))
                        {   PMP_Category__c cat=(PMP_Category__c)englishDataMap.get(String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Identifier)));
                         String childDescription=String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Description));
                         //checking the language of the JSON 
                         if(strBaseKey==PMP_StaticConstants_MasterData.Chinese_JSON){
                             //checking for the fallback scenario and mapping the english value to the field
                             if(String.isBlank(childDescription) && cat!=null && String.isNotBlank(cat.PMP_Partner_Offering_Category_Dsc__c)){
                                 category.PMP_Category_Chinese_Dsc__c=cat.PMP_Partner_Offering_Category_Dsc__c;
                             }
                             //mapping the JSON value to the field
                             else{
                                 category.PMP_Category_Chinese_Dsc__c=childDescription;
                             }
                         }
                         else if(strBaseKey==PMP_StaticConstants_MasterData.Japanese_JSON){
                             if(String.isBlank(childDescription) && cat!=null && String.isNotBlank(cat.PMP_Partner_Offering_Category_Dsc__c)){
                                 category.PMP_Category_Japanese_Dsc__c=cat.PMP_Partner_Offering_Category_Dsc__c;
                             }
                             else{
                                 category.PMP_Category_Japanese_Dsc__c=childDescription;
                             }
                         }
                         else if(strBaseKey==PMP_StaticConstants_MasterData.English_JSON){
                             category.PMP_Partner_Offering_Category_Dsc__c = childDescription;
                         }
                        }
                        //Category Image URL
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Child_Image_URL))
                        {
                            
                            category.PMP_Category_Image_URL_Txt__c = String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Image_URL));
                        }
                        //Category Tool Tip
                        //modified by raj
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Tool_Tip))
                        {   PMP_Category__c cat=(PMP_Category__c)englishDataMap.get(String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Identifier)));
                         String toolTip=String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Tool_Tip));
                         //checking the language of the JSON
                         if(strBaseKey==PMP_StaticConstants_MasterData.Chinese_JSON){
                             //checking for the fallback scenario,and mapping the english value to the field
                             if(String.isBlank(toolTip)&& cat!=null && String.isNotBlank(cat.PMP_Tool_Tip_English_Txt__c)){
                                 category.PMP_Tool_Tip_Chinese_Txt__c=cat.PMP_Tool_Tip_English_Txt__c;
                             }
                             //mapping the JSON value to the field
                             else{
                                 category.PMP_Tool_Tip_Chinese_Txt__c=toolTip;
                             }
                         }
                         else if(strBaseKey==PMP_StaticConstants_MasterData.Japanese_JSON){
                             if(String.isBlank(toolTip) && cat!=null && String.isNotBlank(cat.PMP_Tool_Tip_English_Txt__c)){
                                 category.PMP_Tool_Tip_Japanese_Txt__c=cat.PMP_Tool_Tip_English_Txt__c;
                             }
                             else{
                                 category.PMP_Tool_Tip_Japanese_Txt__c=toolTip;
                             }
                         }
                         else if(strBaseKey==PMP_StaticConstants_MasterData.English_JSON){
                             category.PMP_Tool_Tip_English_Txt__c = toolTip;
                         }
                         
                        }
                        /*This block added by Raj to store child mandatory indicator as part of US621683*/
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Child_Mandatory_Flag)){
                            category.PMP_ChildMandatory_Ind__c = String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Child_Mandatory_Flag)) == PMP_StaticConstants_MasterData.Yes ? 
                                									true : false;
                        }
                        /*Changes for US621683 Ends*/
                        //Category Active Indicator
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Is_Active))
                        {
                            
                            category.PMP_Active_Ind__c = Boolean.valueOf(catMap.get(PMP_StaticConstants_MasterData.Is_Active));
                        }
                        //Category Sequence
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Sequence))
                        {
                            
                            String sequence = String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Sequence));
                            if(sequence.contains(PMP_StaticConstants_MasterData.Comma_Symbol)){
                                sequence = sequence.remove(PMP_StaticConstants_MasterData.Comma_Symbol);
                                category.PMP_Category_Display_Sequence_Nbr__c = Integer.valueof(sequence);
                            }
                            else{
                               category.PMP_Category_Display_Sequence_Nbr__c = Integer.valueof(sequence);
                             }
                            
                        }
                        //Category display type
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Selection_Type))
                        {
                            
                            if(String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Selection_Type)).contains(PMP_StaticConstants_MasterData.Radio))
                            {
                                category.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Radiobutton;
                            }
                            else
                            {
                                category.PMP_Display_Type_Nm__c = String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Selection_Type)); 
                            }
                            
                            //Assign display type as 'label' for Category,Application and Industry
                            if(category.PMP_Partner_Product_Category_Cd__c == PMP_StaticConstants_MasterData.Category_PIMId || category.PMP_Partner_Product_Category_Cd__c == PMP_StaticConstants_MasterData.Application_PIMId || category.PMP_Partner_Product_Category_Cd__c == PMP_StaticConstants_MasterData.Industry_PIMId)
                            {
                                category.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Label;
                            }
                            
                        }
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Parent_Identifier))
                        {
                            
                            category.PMP_Partner_Product_Parent_Category_Cd__c = String.valueOf(catMap.get(PMP_StaticConstants_MasterData.Parent_Identifier));
                        }
                        if(catMap.containsKey(PMP_StaticConstants_MasterData.Intel_Segment))
                        {
                            
                            
                            List<Object> lstsegment = (List<Object>)catMap.get(PMP_StaticConstants_MasterData.Intel_Segment);
                            List<String> catsegment = new List<String>();
                            
                            for(integer segIndex=0;segIndex<lstsegment.size();segIndex++)
                            {
                                if(lstsegment !=null)
                                {
                                    Map<String,Object> segmentMap = (Map<String, Object>)lstsegment[segIndex];
                                    
                                    
                                    if(segmentMap != null && !segmentMap.isEmpty())
                                    {
                                        
                                        if(segmentMap.containsKey(PMP_StaticConstants_MasterData.Spec_Identifier)){
                                            
                                            if(segmentMap.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Client_Computing_PIMId && segmentMap.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                                //catsegment.add(PMP_StaticConstants_MasterData.Client);
                                                catsegment.add(PMP_StaticConstants_MasterData.Personal_Computers);
                                            }
                                            if(segmentMap.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Data_Center_PIMId && segmentMap.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                                catsegment.add(PMP_StaticConstants_MasterData.Server);
                                            }
                                            if(segmentMap.get(PMP_StaticConstants_MasterData.Spec_Identifier) == PMP_StaticConstants_MasterData.Embedded_IoT_PIMId && segmentMap.get(PMP_StaticConstants_MasterData.Spec_Value) == PMP_StaticConstants_MasterData.Yes){
                                                catsegment.add(PMP_StaticConstants_MasterData.IoT);
                                            }
                                            
                                            
                                            String segment = String.join(catsegment, PMP_StaticConstants_MasterData.SemiColon_Symbol);
                                            
                                            category.PMP_Business_Segment_Nm__c= segment;
                                            
                                            
                                        }
                                    }
                                }   
                            }
                        }
                        //check if the JSON has Business Segments as categories and related child. Do not add to the list (Do not insert)
                        if(category.PMP_Partner_Product_Category_Cd__c != PMP_StaticConstants_MasterData.Business_Segments_PIMId && category.PMP_Partner_Product_Category_Cd__c != PMP_StaticConstants_MasterData.Intel_Segments_NPP_01_Busines_Segments && category.PMP_Partner_Product_Category_Cd__c != PMP_StaticConstants_MasterData.Client_Computing_PIMId && category.PMP_Partner_Product_Category_Cd__c != PMP_StaticConstants_MasterData.Data_Center_PIMId && category.PMP_Partner_Product_Category_Cd__c!= PMP_StaticConstants_MasterData.Embedded_IoT_PIMId && category.PMP_Partner_Product_Category_Key__c!= null) 
                        {
                            uploadCategoryMap.put(category.PMP_Partner_Product_Category_Key__c,category);
                        }      
                        
                        
                    }
                    
                }
            }
        //}[Removed for loop as part code scan fix]
        //to handle deactivation of Categories
        if ((existingEngCatMap != null || !existingEngCatMap.isEmpty()) && (uploadCategoryMap != null || !uploadCategoryMap.isEmpty()))
        {
            for(String keyId: existingEngCatMap.Keyset())
            {
                //if 2nd map does not have that key
                if(!uploadCategoryMap.keyset().contains(keyId))
                {
                    PMP_Category__c category = existingEngCatMap.get(keyId);
                    category.PMP_Active_Ind__c = false;
                    catDeactiveMap.put(keyId,category);
                }
                
            }
            if(catDeactiveMap != null || !catDeactiveMap.isEmpty())
            {
                for(String key : catDeactiveMap.keySet())
                {
                     uploadCategories.add(catDeactiveMap.get(key));
                    
                } 
            }
        }
        for(String key : uploadCategoryMap.keySet())
        {
            uploadCategories.add(uploadCategoryMap.get(key));
        }
        List<Database.UpsertResult> upsertResultData = new List<Database.UpsertResult>();//final upsert records (success and failure)
        if(uploadCategories.size()>0){
            try{
                 //upsert uploadCategories PMP_Partner_Product_Category_Key__c; 
                 Schema.SObjectField upsertKey = PMP_Category__c.Fields.PMP_Partner_Product_Category_Key__c;
                 upsertResultData = Database.upsert(uploadCategories,upsertKey,false);
                 
            }
            catch(Exception exp){
                System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseCategoryJSON_Exception_Message + exp.getMessage());
                throw exp; // We have to throw the exception so that it will get caught in queable class
            }
            
        }
        return upsertResultData;//return upsert results data
    }              
}