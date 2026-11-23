/*********************************************************************************************************
* Class Name  :   PMP_ParseChipSet_JSON
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                               Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Infosys - Manasa                      02/01/2019           Created for Parsing the Chipset 
*                                                            JSON and creating Specification 
*                                                            and Specification Value junction records.
* Infosys - Sangeetha Ganta             02/28/2019           User Story - US290905. Activation of Spec
*                                                            value based on JSON input
* Infosys - Sangeetha Ganta             03/26/2019           User Story - US301406. Specifications localization 
*                                                            from PIM in Japanese & Simplified Chinese
***********************************************************************************************************/

public class PMP_ParseChipSet_JSON
{ 
  	public static String strBaseKey; 
    public static List<Database.UpsertResult> parseChipSetJSON(String staticResourceName)
    {
        //To fetch the PIM Spec Id for specification called Chipsets
        
         PMP_Specification__c chipsetsSpecification = [Select Id,PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_MasterData.Chipsets_PIMId];
        String chipsetsSpecificationPIMId;
        
        if(chipsetsSpecification != null) 
        {
            chipsetsSpecificationPIMId = chipsetsSpecification.PMP_Partner_Product_Specification_Id__c;
        }        
        
        //Variable Declaration
        final String Chipset_Spec = 'Chipset';
        Map<String,PMP_Specification__c> specUploadMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> specValueUploadMap = new Map<String,PMP_Specification_Value__c>();
        List<PMP_Specification__c> uploadSpec = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> uploadSpecValues = new List<PMP_Specification_Value__c>();
        //US301406
        Map<String,PMP_Specification__c> getexistingSpecs = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> getexistingSpecValues = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification__c> transSpecUploadMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> transSpecValUploadMap = new Map<String,PMP_Specification_Value__c>();
        List<PMP_Specification__c> uploadTransSpec = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> uploadTransSpecValues = new List<PMP_Specification_Value__c>();
        //End
        Map<String,PMP_Specification_Value__c> existingEngSpecValuesMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification_Value__c> specValuesDeactiveMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification__c> existingEngSpecsMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification__c> specsDeactiveMap = new Map<String,PMP_Specification__c>();
        
        List<Database.UpsertResult> upsertResultDataSpec = new List<Database.UpsertResult>();//final upsert records (success and failure)
        List<Database.UpsertResult> upsertResultDataSpecTrans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultDataSpecValue = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultDataSpecValueTrans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData= new List<Database.UpsertResult>();
        
        //Parse the JSON stored as a static resource
        String jsonStr ='';
        
        //string strBaseKey;
        
        //Store the Chipsets JSON file in Static Resource and access it as a String
        
        if(Test.isRunningTest())
        {
            
             StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Chipsets_Attribute_Test];
            
            jsonStr = srObject.body.toString();  
        }
        else
        {
            
             StaticResource srObject = [select id,body from StaticResource Where Name = :staticResourceName];
            
            jsonStr = srObject.body.toString();
        }
        
        
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        /*Added by Manasa to get the leaf node level for the uploaded file - Start*/
        Integer leafLevel = PMP_Utility.getLeafNode(mapSpec);
        /*----------------------------END-----------------------------------------*/
        
        //for (string theKey:mapSpec.keySet()){[Removed for loop as part code scan fix]
            if(!Test.isRunningTest()){
                strBaseKey = new list<String>(mapSpec.keySet())[0];
            }
        	System.debug('^^^TheKey--->'+strBaseKey);//###toberemoved
            //US301406
            if(strBaseKey!=PMP_StaticConstants_MasterData.English_JSON)
            {
                //Added by Manasa - US439814
                List<PMP_Specification__c> existingSpecs = [Select id,Name,PMP_Specification_Name__c,PMP_Partner_Product_Specification_Key__c,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c];
                List<PMP_Specification_Value__c> existingSpecValues = [Select id,Name,PMP_Specification_Value_Nm__c,PMP_Product_Specification_Value_Key__c,PMP_Specification_Value_Chinese_Cd__c,PMP_Specification_Value_Japanese_Cd__c from PMP_Specification_Value__c];              
                if(existingSpecs.size()>0)
                {
                    for(PMP_Specification__c existingSpec : existingSpecs)
                    {
                        getexistingSpecs.put(existingSpec.PMP_Partner_Product_Specification_Key__c,existingSpec);
                        
                    }
                    
                }
                if(existingSpecValues.size()>0)
                {
                    for(PMP_Specification_Value__c existingSpecValue : existingSpecValues)
                    {
                        getexistingSpecValues.put(existingSpecValue.PMP_Product_Specification_Value_Key__c,existingSpecValue);
                    }
                }  
            }
            //End
            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
            {
                //to handle activation or inactivation of Specifications (Chipset)
                
                 List<PMP_Specification__c> existingEngSpecs =  [Select id,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Specification_Type_Nm__c = :Chipset_Spec];
                
                if(existingEngSpecs.size()>0)
                {
                    for(PMP_Specification__c spec : existingEngSpecs)
                    {
                        existingEngSpecsMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec); 
                    }
                    
                }            
                
                //to handle activation or inactivation of Spec Values (Chipset)
                
                List<PMP_Specification_Value__c> existingEngSpecValues = [Select id,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c from PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c = :PMP_StaticConstants_MasterData.Chipset_Spec_Value];
                
                if(existingEngSpecValues.size()>0)
                {
                    for(PMP_Specification_Value__c specVal : existingEngSpecValues )
                    {
                        existingEngSpecValuesMap.put(specVal.PMP_Product_Specification_Value_Key__c,specVal); 
                    }
                    
                }
            }
            
            if(mapSpec.size() > 0)        
            {
                List<Object> lstSpec = (List<Object>)mapSpec.get(strBaseKey); //get the List of objects associated with key en_US
                for(integer catIndex=0;catIndex<lstSpec.size();catIndex++)
                {
                    Map<String, Object> specMap = (Map<String, Object>)lstSpec[catIndex];
                    if(specMap != null && !specMap.isEmpty())
                    {
                        if(specMap.containsKey(PMP_StaticConstants_MasterData.ChildCategories))
                        {
                            List<Object> lstChildCategories = (List<Object>)specMap.get(PMP_StaticConstants_MasterData.ChildCategories);
                            
                            for(integer specIndex=0;specIndex<lstChildCategories.size();specIndex++)
                            {
                                Map<String, Object> specOrSpecValMap = (Map<String, Object>)lstChildCategories[specIndex];
                                if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) != leafLevel)
                                {
                                    
                                    // If level value is not 'specValueLevel3/leaf' then create specification record
                                    PMP_Specification__c specification = new PMP_Specification__c();
                                    specification.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                    specification.PMP_Specification_Type_Nm__c = Chipset_Spec;
                                    specification.PMP_Active_Ind__c = true;//set specification active indicator as true by default
                                    //US301406
                                    if((specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Chipsets) || (specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Chinese_Chipsets) || (specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Japanese_Chipsets))
                                    {   
                                        specification.PMP_Product_Parent_Specification_Id__c = chipsetsSpecificationPIMId;
                                    }
                                    else
                                    {
                                        specification.PMP_Product_Parent_Specification_Id__c = String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier));  
                                    }                                   
                                    if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue))
                                    {
                                        specification.PMP_Partner_Product_Specification_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase();
                                        specification.PMP_Partner_Product_Specification_Id__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                        //fetch sequence number of the spec from utility method 
                                    	specification.PMP_Partner_Product_Display_Sequence_Nbr__c = PMP_Utility.getSpecificationSequenceNumber(specMap, specOrSpecValMap);
                                        // US301406
                                        String specificationName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                        if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                        {
                                            specification.Name = specificationName;
                                            //Added by Manasa - US439814
                                            specification.PMP_Specification_Name__c = specificationName;
                                            System.debug('**CustomName**'+specification.PMP_Specification_Name__c);
                                        }
                                        if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                        {
                                            //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                            PMP_Specification__c spec = getexistingSpecs.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                            if((specificationName==null||String.isBlank(specificationName)) && spec!= null && spec.Name!=null)
                                            {
                                                spec.PMP_Specification_Chinese_Nm__c = spec.PMP_Specification_Name__c;
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),spec);
                                            }
                                            else if(specificationName!=null && String.isNotBlank(specificationName) && spec!= null)
                                            {
                                                spec.PMP_Specification_Chinese_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),spec);
                                            }
                                            
                                            
                                        }
                                        
                                        if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                        {
                                            //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                            PMP_Specification__c spec = getexistingSpecs.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                            if((specificationName==null||String.isBlank(specificationName)) && spec!= null && spec.Name!=null)
                                            {
                                                spec.PMP_Specification_Japanese_Nm__c = spec.PMP_Specification_Name__c;
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),spec);
                                            }
                                            else if(specificationName!=null && String.isNotBlank(specificationName) && spec!= null)
                                            {
                                                spec.PMP_Specification_Japanese_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),spec);
                                            }
                                        }
                                        
                                    }
                                    
                                    //Add the specification to Map to avoid duplicacy of specification records
                                    if(specification.PMP_Partner_Product_Specification_Key__c !=null){
                                        specUploadMap.put(specification.PMP_Partner_Product_Specification_Key__c,specification); 
                                    }
                                    
                                }
                                else
                                {
                                    // If level value is 'specValueLevel3/leaf' then create specification value record
                                    if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) == leafLevel)
                                    {
                                        PMP_Specification_Value__c specificationValue = new PMP_Specification_Value__c();
                                        specificationValue.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                        specificationValue.PMP_Spec_Value_Type_Nm__c = PMP_StaticConstants_MasterData.Chipset_Spec_Value;
                                        //US440994
                                        specificationValue.PMP_Product_Status__c = specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Status)? 
                                                                                    string.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Status)):null;
                                        //US290905
                                        if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.NPP_Is_Active))
                                        {
                                            if(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.NPP_Is_Active)) == PMP_StaticConstants_MasterData.Yes)
                                            {
                                                specificationValue.PMP_Active_Ind__c = true;
                                            }
                                            else
                                            {
                                                specificationValue.PMP_Active_Ind__c = false;
                                            }
                                            
                                        }
                                        //Image URL - Added by Raj US359430 - start
                                        
                                         if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Image_URL))
                                        {
                                                specificationValue.PMP_Image_URL__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Image_URL));
                                                System.debug('Image URL 232-->'+specificationValue.PMP_Image_URL__c);
                                        }
                                        //Image URL - Added by Raj US359430 - end
                                        
                                        //Product catalog URL - Added by Raj US359430 - start
                                        
                                         if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Product_Catalog_URL))
                                        {
                                                specificationValue.PMP_Product_URL__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Product_Catalog_URL));
                                                System.debug('product URL 241-->'+specificationValue.PMP_Product_URL__c);
                                        }
                                        //Product catalog URL - Added by Raj US359430 - end 
                                        if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Off_Roadmap) && specOrSpecValMap.get(PMP_StaticConstants_MasterData.Off_Roadmap) == PMP_StaticConstants_MasterData.Yes)
                                        {
                                            specificationValue.PMP_Partner_Off_Roadmap_Ind__c = true;
                                        }
                                        else
                                        {                                       
                                            specificationValue.PMP_Partner_Off_Roadmap_Ind__c = false;
                                        }
                                        if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue))
                                        {
                                            specificationValue.PMP_Product_Specification_Value_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                            if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecValueSequence))
                                            {                                           
                                                String sequence = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecValueSequence));
                                                if(sequence.contains(PMP_StaticConstants_MasterData.Comma_Symbol))
                                                {
                                                    sequence = sequence.remove(PMP_StaticConstants_MasterData.Comma_Symbol);
                                                    specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueof(sequence);
                                                }
                                                else
                                                {
                                                    System.debug('heyyyy'+sequence);
                                                    specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueof(sequence);
                                                }    
                                            }
                                            
                                            //specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueOf(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecValueSequence)));
                                            specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueOf(Math.roundToLong(Decimal.valueOf(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecValueSequence)).replaceAll(',', ''))));
                                            specificationValue.PMP_Product_Specification_Value_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase();
                                            //US301406
                                            String specValueName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                            {
                                                specificationValue.PMP_Specification_Value_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                specificationValue.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                            }
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                            {
                                                PMP_Specification_Value__c specValue = getexistingSpecValues.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                                if((specValueName==null||String.isBlank(specValueName)) && specValue!= null && specValue.Name!=null)
                                                {
                                                    specValue.PMP_Specification_Value_Chinese_Cd__c = specValue.PMP_Specification_Value_Nm__c;
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),specValue);
                                                }
                                                else if(specValueName!=null && String.isNotBlank(specValueName) && specValue!= null)
                                                {
                                                    specValue.PMP_Specification_Value_Chinese_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),specValue);
                                                }
                                                
                                            }
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                            {
                                                PMP_Specification_Value__c specValue = getexistingSpecValues.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                                if((specValueName==null||String.isBlank(specValueName)) && specValue!= null && specValue.Name!=null)
                                                {
                                                    specValue.PMP_Specification_Value_Japanese_Cd__c = specValue.PMP_Specification_Value_Nm__c;
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),specValue);
                                                }
                                                else if(specValueName!=null && String.isNotBlank(specValueName) && specValue!= null)
                                                {
                                                    specValue.PMP_Specification_Value_Japanese_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),specValue);
                                                }
                                            }
                                            //End
                                        } 
                                        if(specificationValue.PMP_Product_Specification_Value_Key__c !=null && (specificationValue.PMP_Specification_Value_Nm__c != null || String.isNotBlank(specificationValue.PMP_Specification_Value_Nm__c))){
                                            specValueUploadMap.put(specificationValue.PMP_Product_Specification_Value_Key__c,specificationValue);  
                                        }
                                        
                                    } 
                                    
                                }                                   
                            }   
                            
                            
                        }                           
                        
                    }   
                    
                }
                
            }   
        //}[Removed for loop as part code scan fix]
        //to handle deactivation of Specifications
        if ((existingEngSpecsMap != null || !existingEngSpecsMap.isEmpty()) && (specUploadMap != null || !specUploadMap.isEmpty()))
        {
            for(String keyId: existingEngSpecsMap.Keyset())
            {
                //if 2nd map does not have that key
                if(!specUploadMap.keyset().contains(keyId))
                {
                    PMP_Specification__c spec = existingEngSpecsMap.get(keyId);
                    spec.PMP_Active_Ind__c = false;
                    specsDeactiveMap.put(keyId,spec);
                }
                
            }
            if(specsDeactiveMap != null || !specsDeactiveMap.isEmpty())
            {
                for(String key : specsDeactiveMap.keySet())
                {
                    uploadSpec.add(specsDeactiveMap.get(key));
                    
                } 
            }
        }
        
        //to handle deactivation of Spec Values
        if ((existingEngSpecValuesMap != null || !existingEngSpecValuesMap.isEmpty()) && (specValueUploadMap != null || !specValueUploadMap.isEmpty()))
        {
            for(String keyId: existingEngSpecValuesMap.Keyset())
            {
                //if 2nd map does not have that key
                if(!specValueUploadMap.keyset().contains(keyId))
                {
                    PMP_Specification_Value__c specValue = existingEngSpecValuesMap.get(keyId);
                    specValue.PMP_Active_Ind__c = false;
                    specValuesDeactiveMap.put(keyId,specValue);
                }
                
            }
            if(specValuesDeactiveMap != null || !specValuesDeactiveMap.isEmpty())
            {
                for(String key : specValuesDeactiveMap.keySet())
                {
                    uploadSpecValues.add(specValuesDeactiveMap.get(key));
                    
                } 
            }
        }
        for(String key : specUploadMap.keySet())
        {
            uploadSpec.add(specUploadMap.get(key));
        }
        
        for(String key : specValueUploadMap.keySet())
        {
            uploadSpecValues.add(specValueUploadMap.get(key));
        }
        if(uploadSpec.size()>0)
        {
            try
            {
                //upsert uploadSpec PMP_Partner_Product_Specification_Key__c;
                Schema.SObjectField upsertSpecKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
                //Comment the below line for testing
                upsertResultDataSpec = Database.upsert(uploadSpec,upsertSpecKey,false);
            }
            catch(Exception exp1)
            {
                //System.debug('Error occured from class PMP_ParseChipSet_JSON due to '+exp1.getMessage());
                throw exp1;
            }
        }
        
        if(uploadSpecValues.size()>0)
        {
            try
            {
                //upsert uploadSpecValues PMP_Product_Specification_Value_Key__c;
                Schema.SObjectField upsertSpecValKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                //Comment the below line for testing
                upsertResultDataSpecValue = Database.upsert(uploadSpecValues,upsertSpecValKey,false);
            }
            catch(Exception exp2)
            {
                //System.debug('Error occured from class PMP_ParseChipSet_JSON due to '+exp2.getMessage());
                throw exp2;
            }
        }
        
        //US301406
        for(String key : transSpecUploadMap.keySet())
        {
            uploadTransSpec.add(transSpecUploadMap.get(key));
        }
        
        for(String key : transSpecValUploadMap.keySet())
        {
            uploadTransSpecValues.add(transSpecValUploadMap.get(key));
            
        }
        
        if(uploadTransSpec.size()>0)
        {
            try
            {
                //update uploadTransSpec;
                Schema.SObjectField upsertSpecTransKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
                //Comment the below line for testing
                upsertResultDataSpecTrans = Database.upsert(uploadTransSpec,upsertSpecTransKey,false);
            }
            catch(Exception exp1)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
        
        if(uploadTransSpecValues.size()>0)
        {
            try
            {
                //update uploadTransSpecValues;
                Schema.SObjectField upsertSpecValTransKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                //Comment the below line for testing
                upsertResultDataSpecValueTrans = Database.upsert(uploadTransSpecValues,upsertSpecValTransKey,false);
            }
            catch(Exception exp2)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp2.getMessage());
                throw exp2;
            }
        }
        
        //Comment the below lines for testing
        if(upsertResultDataSpecValueTrans.size()>0)
        {
            for(Database.UpsertResult res :upsertResultDataSpecValueTrans)
            {
                upsertResultData.add(res);
            }
        }
        if(upsertResultDataSpecTrans.size()>0)
        {
            for(Database.UpsertResult res :upsertResultDataSpecTrans)
            {
                upsertResultData.add(res);
            }
        }
       if(upsertResultDataSpec.size()>0)
        {
            for(Database.UpsertResult res :upsertResultDataSpec)
            {
                upsertResultData.add(res);
            }
        }
        if(upsertResultDataSpecValue.size()>0)
        {
            for(Database.UpsertResult res :upsertResultDataSpecValue)
            {
                upsertResultData.add(res);
            }
        }
        
        return upsertResultData;
    }
}