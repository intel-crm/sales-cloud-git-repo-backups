/*****************************************************************************************************
* Class Name  :   PMP_ParseFPGAJSON
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                 Date                    Description
* -----------------------------------------------------------------------------------------------------
* Sangeetha                 09/01/2019               Created for Parsing the FPGA 
*                                                  JSON and creating Specification 
*                                                  and Specification Value junction records.
* Infosys - Sangeetha       02/28/2019             User Story - US290905. Activation of Spec
*                                                  based on JSON input
* Raj                       07/11/2019             User Story - US398165 Specifications localization 
*                                                               from PIM in Japanese & Simplified Chinese   
*********************************************************************************************************/

public class PMP_ParseFPGAJSON
{ 
	public static String strBaseKey;
    public static List<Database.UpsertResult> ParseFpgaJSON(String StaticResourceName)
    {
       PMP_Specification__c FPGA_Specification = new PMP_Specification__c();
       //To fetch the PIM Spec Id for specification called FPGA
       
       FPGA_Specification = [Select Id,PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_MasterData.FPGA_PIMId];
       
       String FPGA_Specification_PIMId;
       
       if(FPGA_Specification != null)
       {
          FPGA_Specification_PIMId = FPGA_Specification.PMP_Partner_Product_Specification_Id__c;
         
       }
        
        //Variable Declaration
        final String FPGA_Spec = 'FPGA';
        Map<String,PMP_Specification__c> specUploadMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> specValueUploadMap = new Map<String,PMP_Specification_Value__c>();
        List<PMP_Specification__c> uploadSpec = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> uploadSpecValues = new List<PMP_Specification_Value__c>();
        Map<String,PMP_Specification__c> existingEngSpecsMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification__c> SpecsDeactiveMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> existingEngSpecValuesMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification_Value__c> SpecValuesDeactiveMap = new Map<String,PMP_Specification_Value__c>();
        /*--Added by raj for US398165 to load chinese and japanese data for FPGAs--*/
        Map<String,PMP_Specification__c> getexistingSpecs = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> getexistingSpecValues = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification__c> transSpecUploadMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> transSpecValUploadMap = new Map<String,PMP_Specification_Value__c>();
        List<PMP_Specification__c> uploadTransSpec = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> uploadTransSpecValues = new List<PMP_Specification_Value__c>();
        /*------------------------------------------------------------------------*/
        
       //Parse the JSON stored as a static resource
        String jsonStr ='';
        
        //Store the FPGA JSON file in Static Resource and access it as a String
        if(Test.isRunningTest())
        {
            StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.FPGA_Attribute_Test];
            jsonStr = srObject.body.toString();
        }
        else
        {
            StaticResource srObject = [select id,body from StaticResource Where Name = :StaticResourceName];
            jsonStr = srObject.body.toString();
        }
        
        
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        /*Added by raj to get the leaf node level for the uploaded file*/
        Integer leafLevel = PMP_Utility.getLeafNode(mapSpec);
        /*-----------------------End-------------------------------*/
        //for (string theKey:mapSpec.keySet()){[Removed for loop as part code scan fix]
            if(!Test.isRunningTest()){
                strBaseKey = new list<String>(mapSpec.keySet())[0];
            }
        	System.debug('^^^TheKey--->'+strBaseKey);//###toberemoved
            //Added by raj to fetch existing english data for US398165(FPGA)
            if(strBaseKey!=PMP_StaticConstants_MasterData.English_JSON)
            {
                List<PMP_Specification__c> existingSpecs = new List<PMP_Specification__c>();
                List<PMP_Specification_Value__c> existingSpecValues = new List<PMP_Specification_Value__c>();
                   //Added by Manasa - US439814
                   existingSpecs  = [Select id,Name,PMP_Specification_Name__c,PMP_Partner_Product_Specification_Key__c,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c];
                
                
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
            //End
            
            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
            {
                //to handle activation or inactivation of Specifications (FPGA)
                List<PMP_Specification__c> existingEngSpecs = new List<PMP_Specification__c>();
                
                
                existingEngSpecs =  [Select id,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Specification_Type_Nm__c = :FPGA_Spec];
                
                if(existingEngSpecs.size()>0)
                {
                    for(PMP_Specification__c Spec : existingEngSpecs)
                    {
                        existingEngSpecsMap.put(Spec.PMP_Partner_Product_Specification_Key__c,Spec); 
                    }
                    
                }
                //to handle activation or inactivation of Spec Values (FPGA)
                List<PMP_Specification_Value__c> existingEngSpecValues = new List<PMP_Specification_Value__c>();
                
                
                existingEngSpecValues = [Select id,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c from PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c = :FPGA_Spec];
                
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
                                    
                                    // If level value is not 'specValueLevel3/leaf' then create specification record
                                    PMP_Specification__c specification = new PMP_Specification__c();
                                    specification.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                    specification.PMP_Specification_Type_Nm__c = FPGA_Spec;
                                    //US290905 - Add the active flag value
                                    if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.NPP_Is_Active))
                                    {
                                        if(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.NPP_Is_Active)) == PMP_StaticConstants_MasterData.Yes)
                                            {
                                                specification.PMP_Active_Ind__c = true;
                                            }
                                        else
                                            {
                                                specification.PMP_Active_Ind__c = false;
                                            }
                                    }
                                    //Image URL - Added by Raj US359430 - start
                                        
                                    if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Image_URL))
                                        {
                                                specification.PMP_Image_url__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Image_URL));
                                                System.debug('Image URL 106-->'+specification.PMP_Image_URL__c);
                                        }
                                        //Image URL - Added by Raj US359430 - end
                                        
                                        //Product catalog URL - Added by Raj US359430 - start
                                        
                                         if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Product_Catalog_URL))
                                        {
                                                specification.PMP_Product_url__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Product_Catalog_URL));
                                                System.debug('product URL 115-->'+specification.PMP_Product_URL__c);
                                        }
                                        //Product catalog URL - Added by Raj US359430 - end 
                                     
                                    if(specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.FPGA)
                                    {   
                                        specification.PMP_Product_Parent_Specification_Id__c = FPGA_Specification_PIMId;
                                    }
                                    else
                                    {
                                        specification.PMP_Product_Parent_Specification_Id__c = String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier));  
                                    }                                   
                                    if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue))
                                    {
                                    	specification.PMP_Partner_Product_Specification_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhitespace()).toLowerCase();
                                    	specification.PMP_Partner_Product_Specification_Id__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                        //fetch sequence number of the spec from utility method 
                                    	specification.PMP_Partner_Product_Display_Sequence_Nbr__c = PMP_Utility.getSpecificationSequenceNumber(specMap, specOrSpecValMap);
                                        
                                        //specification.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                        String SpecificationName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                        
                                        if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                        {
                                            specification.Name = SpecificationName;   
                                            //Added by Manasa - US439814
                                            specification.PMP_Specification_Name__c = SpecificationName;
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
                                                Spec.PMP_Specification_Chinese_Nm__c = SpecificationName;
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
                                                Spec.PMP_Specification_Japanese_Nm__c = SpecificationName;
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
                                    // If level value is 'specValueLevel3/leaf' then create specification value record
                                    if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) == leafLevel)
                                    {
                                     PMP_Specification_Value__c specificationValue = new PMP_Specification_Value__c();
                                     specificationValue.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                     specificationValue.PMP_Spec_Value_Type_Nm__c = FPGA_Spec;
                                     //US440994
                                     specificationValue.PMP_Product_Status__c = specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Status)? 
                                                                                    string.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Status)):null;   
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
                                                System.debug('Image URL 164-->'+specificationValue.PMP_Image_URL__c);
                                        }
                                        //Image URL - Added by Raj US359430 - end
                                        
                                        //Product catalog URL - Added by Raj US359430 - start
                                        
                                         if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.Product_Catalog_URL))
                                        {
                                                specificationValue.PMP_Product_URL__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.Product_Catalog_URL));
                                                System.debug('product URL 173-->'+specificationValue.PMP_Product_URL__c);
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
                                                System.debug('sequence ='+sequence);
                                                specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueof(sequence);
                                            }    
                                        }
                                        
                                     specificationValue.PMP_Product_Specification_Value_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhitespace()).toLowerCase();
                                     /*specificationValue.PMP_Specification_Value_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                        String Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                        if(Name.length()>80)
                                        {
                                           Name =  Name.substring(0,80);
                                            specificationValue.Name = Name;
                                        }
                                        else
                                        {
                                           specificationValue.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                        }*/
                                     String specValueName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                            {
                                                specificationValue.PMP_Specification_Value_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                specificationValue.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
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
                                        if(specificationValue.PMP_Product_Specification_Value_Key__c !=null){
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
                    PMP_Specification__c Spec = existingEngSpecsMap.get(keyId);
                    Spec.PMP_Active_Ind__c = false;
                    SpecsDeactiveMap.put(keyId,Spec);
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
                    PMP_Specification_Value__c SpecValue = existingEngSpecValuesMap.get(keyId);
                    SpecValue.PMP_Active_Ind__c = false;
                    SpecValuesDeactiveMap.put(keyId,SpecValue);
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
        for(String key : transSpecUploadMap.keySet())
        {
            uploadTransSpec.add(transSpecUploadMap.get(key));
        }
        
        for(String key : transSpecValUploadMap.keySet())
        {
            uploadTransSpecValues.add(transSpecValUploadMap.get(key));
            
        }
        
        List<Database.UpsertResult> upsertResultData= new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec = new List<Database.UpsertResult>();//final upsert records (success and failure)
        List<Database.UpsertResult> upsertResultData_Spec_Value = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec_Trans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec_Value_Trans = new List<Database.UpsertResult>();
        
        if(uploadSpec.size()>0)
        {
           try
           {
               //upsert uploadSpec PMP_Partner_Product_Specification_Key__c;
               Schema.SObjectField upsertSpecKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
               upsertResultData_Spec = Database.upsert(uploadSpec,upsertSpecKey,false);
           }
            catch(Exception exp1)
            {
                System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseFpgaJSON_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
           
        if(uploadSpecValues.size()>0)
        {
           try
           {
                //upsert uploadSpecValues PMP_Product_Specification_Value_Key__c;
                Schema.SObjectField upsertSpecValKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                upsertResultData_Spec_Value = Database.upsert(uploadSpecValues,upsertSpecValKey,false);
           }
            catch(Exception exp2)
            {
                System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseFpgaJSON_Exception_Message+exp2.getMessage());
            }
        }
        
        if(uploadTransSpec.size()>0)
        {
            try
            {
                //update uploadTransSpec;
                Schema.SObjectField upsertSpecTransKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
                upsertResultData_Spec_Trans = Database.upsert(uploadTransSpec,upsertSpecTransKey,false);
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
                upsertResultData_Spec_Value_Trans = Database.upsert(uploadTransSpecValues,upsertSpecValTransKey,false);
            }
            catch(Exception exp2)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp2.getMessage());
                throw exp2;
            }
        }
        
        if(upsertResultData_Spec_Value_Trans.size()>0)
        {
           upsertResultData.addAll(upsertResultData_Spec_Value_Trans);
        }
        if(upsertResultData_Spec_Trans.size()>0)
        {
           upsertResultData.addAll(upsertResultData_Spec_Trans);
        }
        if(upsertResultData_Spec_Value.size()>0)
        {
           upsertResultData.addAll(upsertResultData_Spec_Value);
        }
        if(upsertResultData_Spec.size()>0)
        {
           upsertResultData.addAll(upsertResultData_Spec);
        }
        
        
        return upsertResultData; //return upsert results data
    }
}