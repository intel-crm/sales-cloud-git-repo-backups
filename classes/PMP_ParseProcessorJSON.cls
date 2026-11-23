/**********************************************************************************************
* Class Name  :   PMP_ParseProcessorJSON
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                             Date                    Description
* ---------------------------------------------------------------------------------------------------
* Manasa                                02/01/2019               Created for Parsing the Processor 
*                                                                JSON and creating Specification 
*                                                                and Specification Value junction records.
* Infosys - Sangeetha Ganta             02/28/2019               User Story - US290905. Activation of Spec
*                                                                value based on JSON input
* Infosys - Sangeetha Ganta             03/26/2019           User Story - US301046. Specifications localization 
*                                                            from PIM in Japanese & Simplified Chinese
********************************************************************************************************/
public class PMP_ParseProcessorJSON
{ 
    public static String strBaseKey;
    public static List<Database.UpsertResult> ParseProcessorJSON(String StaticResourceName)
    {
        //To fetch the PIM Spec Id for specification called Processors
        PMP_Specification__c Processor_Specification = new PMP_Specification__c();
        
        Processor_Specification = [Select Id,PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_MasterData.Processor_PIMId];
        
        String Processor_Specification_PIMId;
        
        if(Processor_Specification != null)
        {
            Processor_Specification_PIMId = Processor_Specification.PMP_Partner_Product_Specification_Id__c;
            
        }
        
        
        //Variable Declaration
        final String Processor_Spec = 'Processor';
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
        Map<String,PMP_Specification_Value__c> existingEngSpecValuesMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification_Value__c> SpecValuesDeactiveMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification__c> existingEngSpecsMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification__c> SpecsDeactiveMap = new Map<String,PMP_Specification__c>();
        
        List<Database.UpsertResult> upsertResultData_Spec = new List<Database.UpsertResult>();//final upsert records (success and failure)
        List<Database.UpsertResult> upsertResultData_Spec_Trans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec_Value = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec_Value_Trans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData= new List<Database.UpsertResult>();
        
        //Parse the JSON stored as a static resource
        String jsonStr ='';
        
        //Store the Processor JSON file in Static Resource and access it as a String
        if(Test.isRunningTest())
        {
            StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Processors_Attribute_Test];
            jsonStr = srObject.body.toString();
        }
        else
        {
           StaticResource srObject = [select id,body from StaticResource Where Name = :StaticResourceName];
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
                List<PMP_Specification__c> existingSpecs = new List<PMP_Specification__c>();
                List<PMP_Specification_Value__c> existingSpecValues = new List<PMP_Specification_Value__c>();
                
                //Added by Manasa - US439814
                existingSpecs = [Select id,Name,PMP_Specification_Name__c,PMP_Partner_Product_Specification_Key__c,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c];
                
                
                
                existingSpecValues = [Select id,Name,PMP_Specification_Value_Nm__c,PMP_Product_Specification_Value_Key__c,PMP_Specification_Value_Chinese_Cd__c,PMP_Specification_Value_Japanese_Cd__c from PMP_Specification_Value__c];              
                
                
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
            
            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
            {
                //to handle activation or inactivation of Specifications (Processor)
                List<PMP_Specification__c> existingEngSpecs = new List<PMP_Specification__c>();
                
                existingEngSpecs =  [Select id,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Specification_Type_Nm__c = :Processor_Spec];
                
                if(existingEngSpecs.size()>0)
                {
                    for(PMP_Specification__c Spec : existingEngSpecs)
                    {
                        existingEngSpecsMap.put(Spec.PMP_Partner_Product_Specification_Key__c,Spec); 
                    }
                    
                }            
                
                //to handle activation or inactivation of Spec Values (Processor)
                List<PMP_Specification_Value__c> existingEngSpecValues = new List<PMP_Specification_Value__c>();
                
                existingEngSpecValues = [Select id,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c from PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c = :PMP_StaticConstants_MasterData.Processor_Spec_Value];
                
                if(existingEngSpecValues.size()>0)
                {
                    for(PMP_Specification_Value__c SpecVal : existingEngSpecValues )
                    {
                        existingEngSpecValuesMap.put(SpecVal.PMP_Product_Specification_Value_Key__c,SpecVal); 
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
                                    
                                    // If level value is not 'specValueLevel3/Leaf' then create specification record
                                    PMP_Specification__c specification = new PMP_Specification__c();
                                    specification.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                    specification.PMP_Specification_Type_Nm__c = Processor_Spec;
                                    specification.PMP_Active_Ind__c = true;//set specification active indicator as true by default
                                    //US301406
                                    if((specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Processor) || (specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Chinese_Processors) || (specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Japanese_Processors))
                                    {   
                                        specification.PMP_Product_Parent_Specification_Id__c = Processor_Specification_PIMId;
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
                                        String SpecificationName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                        if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                        {
                                            specification.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));   
                                            //Added by Manasa - US439814
                                            specification.PMP_Specification_Name__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));   
                                        }
                                        if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                        {
                                            //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                            PMP_Specification__c Spec = getexistingSpecs.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                            if((SpecificationName==null||String.isBlank(SpecificationName)) && Spec!= null && Spec.PMP_Specification_Name__c!=null)
                                            {
                                                Spec.PMP_Specification_Chinese_Nm__c = Spec.PMP_Specification_Name__c;
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }
                                            else if(SpecificationName!=null && String.isNotBlank(SpecificationName) && Spec!= null)
                                            {
                                                Spec.PMP_Specification_Chinese_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }  
                                        }
                                        
                                        if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                        {
                                            //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                            PMP_Specification__c Spec = getexistingSpecs.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                            if((SpecificationName==null||String.isBlank(SpecificationName)) && Spec!= null && Spec.PMP_Specification_Name__c!=null)
                                            {
                                                Spec.PMP_Specification_Japanese_Nm__c = Spec.PMP_Specification_Name__c;
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }
                                            else if(SpecificationName!=null && String.isNotBlank(SpecificationName) && Spec!= null)
                                            {
                                                Spec.PMP_Specification_Japanese_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
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
                                    // If level value is 'specValueLevel3/Leaf' then create specification value record
                                    if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) == leafLevel)
                                    {
                                        PMP_Specification_Value__c specificationValue = new PMP_Specification_Value__c();
                                        specificationValue.PMP_Display_Type_Nm__c= PMP_StaticConstants_MasterData.Checkbox;
                                        specificationValue.PMP_Spec_Value_Type_Nm__c = PMP_StaticConstants_MasterData.Processor_Spec_Value;
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
                                        //Image URL - Added by Manasa US359439 - start
                                        
                                         if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Image_URL))
                                        {
                                                specificationValue.PMP_Image_URL__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Image_URL));
                                           // System.debug('Image URL 228-->'+specificationValue.PMP_Image_URL__c);
                                        }
                                        //Image URL - Added by Manasa US359439 - end
                                        
                                        //Product catalog URL - Added by Manasa US359439 - start
                                        
                                         if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Product_Catalog_URL))
                                        {
                                                specificationValue.PMP_Product_URL__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Product_Catalog_URL));
                                           // System.debug('product URL 228-->'+specificationValue.PMP_Product_URL__c);
                                        }
                                        //Product catalog URL - Added by Manasa US359439 - end 
                                        
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
                                                   // System.debug('sequence ='+sequence);
                                                    specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueof(sequence);
                                                }    
                                            }
                                            
                                            specificationValue.PMP_Product_Specification_Value_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase();
                                            //US301406
                                            String specValueName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                            {
                                                specificationValue.PMP_Specification_Value_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                String Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                if(Name.length()>80)
                                                {
                                                    Name =  Name.substring(0,80);
                                                    specificationValue.Name = Name;
                                                }
                                                else
                                                {
                                                    specificationValue.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                                }
                                                
                                            }
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                            {
                                                PMP_Specification_Value__c SpecValue = getexistingSpecValues.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                                if((specValueName==null||String.isBlank(specValueName)) && SpecValue!= null && SpecValue.Name!=null)
                                                {
                                                    SpecValue.PMP_Specification_Value_Chinese_Cd__c = SpecValue.PMP_Specification_Value_Nm__c;
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                }
                                                else if(specValueName!=null && String.isNotBlank(specValueName) && SpecValue!= null)
                                                {
                                                    SpecValue.PMP_Specification_Value_Chinese_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                }
                                            }
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                            {
                                                PMP_Specification_Value__c SpecValue = getexistingSpecValues.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                                if((specValueName==null||String.isBlank(specValueName)) && SpecValue!= null && SpecValue.Name!=null)
                                                {
                                                    SpecValue.PMP_Specification_Value_Japanese_Cd__c = SpecValue.PMP_Specification_Value_Nm__c;
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                }
                                                else if(specValueName!=null && String.isNotBlank(specValueName) && SpecValue!= null)
                                                {
                                                    SpecValue.PMP_Specification_Value_Japanese_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                } 
                                            }
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
                   // System.debug('keyId ='+keyId);
                    PMP_Specification__c Spec = existingEngSpecsMap.get(keyId);
                    Spec.PMP_Active_Ind__c = false;
                    SpecsDeactiveMap.put(keyId,Spec);
                   // System.debug('SpecsDeactiveMap'+SpecsDeactiveMap);
                }
                
            }
            if(SpecsDeactiveMap != null || !SpecsDeactiveMap.isEmpty())
            {
                for(String key : SpecsDeactiveMap.keySet())
                {
                    uploadSpec.add(SpecsDeactiveMap.get(key));
                    
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
                    //System.debug('keyId ='+keyId);
                    PMP_Specification_Value__c SpecValue = existingEngSpecValuesMap.get(keyId);
                    SpecValue.PMP_Active_Ind__c = false;
                    SpecValuesDeactiveMap.put(keyId,SpecValue);
                    //System.debug('SpecValuesDeactiveMap'+SpecValuesDeactiveMap);
                }
                
            }
            if(SpecValuesDeactiveMap != null || !SpecValuesDeactiveMap.isEmpty())
            {
                for(String key : SpecValuesDeactiveMap.keySet())
                {
                    uploadSpecValues.add(SpecValuesDeactiveMap.get(key));
                    
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
        System.debug('uploadSpec 393-->'+uploadSpec.size());
        if(uploadSpec.size()>0)
        {
            try
            {
                //upsert uploadSpec PMP_Partner_Product_Specification_Key__c;
                Schema.SObjectField upsertSpecKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
               //Commented for testing    
               upsertResultData_Spec = Database.upsert(uploadSpec,upsertSpecKey,false);
            }
            catch(Exception exp1)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseProcessorJSON_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
        System.debug('uploadSpecValues 409 line -->'+uploadSpecValues.size());
        if(uploadSpecValues.size()>0)
        {
            try
            {
                //upsert uploadSpecValues PMP_Product_Specification_Value_Key__c;
                Schema.SObjectField upsertSpecValKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                //Commented for testing    
                upsertResultData_Spec_Value = Database.upsert(uploadSpecValues,upsertSpecValKey,false);
            }
            catch(Exception exp2)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseProcessorJSON_Exception_Message+exp2.getMessage());
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
                //Commented for testing    
                upsertResultData_Spec_Trans = Database.upsert(uploadTransSpec,upsertSpecTransKey,false);
            }
            catch(Exception exp1)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
        System.debug('uploadTransSpecValues 453-->'+uploadTransSpecValues.size());
        if(uploadTransSpecValues.size()>0)
        {
            try
            {
                //update uploadTransSpecValues;
                Schema.SObjectField upsertSpecValTransKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                //Commented for testing 
                 upsertResultData_Spec_Value_Trans = Database.upsert(uploadTransSpecValues,upsertSpecValTransKey,false);

            }
            catch(Exception exp2)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp2.getMessage());
                throw exp2;
            }
        }
        //Commented for testing start
        if(upsertResultData_Spec_Value_Trans.size()>0)
        {
            for(Database.UpsertResult res :upsertResultData_Spec_Value_Trans)
            {
                upsertResultData.add(res);
            }
        }
        if(upsertResultData_Spec_Trans.size()>0)
        {
            for(Database.UpsertResult res :upsertResultData_Spec_Trans)
            {
                upsertResultData.add(res);
            }
        }
       if(upsertResultData_Spec.size()>0)
        {
            for(Database.UpsertResult res :upsertResultData_Spec)
            {
                upsertResultData.add(res);
            }
        }
        if(upsertResultData_Spec_Value.size()>0)
        {
            for(Database.UpsertResult res :upsertResultData_Spec_Value)
            {
                upsertResultData.add(res);
            }
        }
        //Commented for testing end
        System.Debug('upsertResultData 500 line-->'+upsertResultData.size());
        return upsertResultData;
    }
}