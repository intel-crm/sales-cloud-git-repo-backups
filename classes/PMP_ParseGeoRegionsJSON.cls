/**********************************************************************************************
* Class Name  :   PMP_ParseGeoRegionsJSON
* Version     : 1.0 
* Created Date: 22nd May,2019
* Modification Log :
* Developer                             Date                    Description
* ---------------------------------------------------------------------------------------------------
* Manasa                                22/05/2019               Created for Parsing the Geo regions 
																 and Sub - regions
*                                                                JSON and creating Specification 
*                                                                and Specification Value junction records.

********************************************************************************************************/
public class PMP_ParseGeoRegionsJSON {
    
    public static String strBaseKey;
    //Get the StaticResourceName from PMP_GeoRegion_Attribute_English class - which is getting from Custom metadata records
	public static List<Database.UpsertResult> ParseGeoRegionsJSON(String StaticResourceName)
    {
        //To fetch the PIM Spec Id = NPP_GeographicCoverage for specification called Geo-Regions
        PMP_Specification__c GeoRegion_Specification = [Select Id,PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c =: PMP_StaticConstants_MasterData.GeoRegion_PIMId];
        String GeoRegion_Specification_PIMId;
        
        if(GeoRegion_Specification != null)
        {
            GeoRegion_Specification_PIMId = GeoRegion_Specification.PMP_Partner_Product_Specification_Id__c;
            
        }
        
        
        //Variable Declaration
        final String GeoRegion_Spec = 'Geography';
        Map<String,PMP_Specification__c> specUploadMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> specValueUploadMap = new Map<String,PMP_Specification_Value__c>();
        List<PMP_Specification__c> uploadSpec = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> uploadSpecValues = new List<PMP_Specification_Value__c>();
        
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
        
        //Store the Geo-Region JSON file in Static Resource and access it as a String
        if(Test.isRunningTest())
        {
            //This file is used for test class
            StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Geo_Attribute_English_Test];
            //conversion of the static resource file into string and assigning to the jsonStr variable
            jsonStr = srObject.body.toString();
        }
        else
        {
            //This is the actual file which is uploaded by PIM
           StaticResource srObject = [select id,body from StaticResource Where Name = :StaticResourceName];
           //conversion of the static resource file into string and assigning to the jsonStr variable
            jsonStr = srObject.body.toString(); 
        }    
        
        //Storing the desearialization of static resource into a MAP
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        /*Added by Manasa to get the leaf node level for the uploaded file - Start*/
            Integer leafLevel = PMP_Utility.getLeafNode(mapSpec);
        /*----------------------------END-----------------------------------------*/
        //for (string theKey:mapSpec.keySet()){[Removed for loop as part code scan fix]
            if(!Test.isRunningTest()){
                strBaseKey = new list<String>(mapSpec.keySet())[0];
            }
        	System.debug('^^^TheKey--->'+strBaseKey);//###toberemoved
            //If the language key is not English language
            if(strBaseKey!=PMP_StaticConstants_MasterData.English_JSON)
            {
                //Query - getting the existing specs
			    //Added by Manasa - US439814
                List<PMP_Specification__c> existingSpecs = [Select id,Name,PMP_Specification_Name__c,PMP_Partner_Product_Specification_Key__c,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c];
                //Query - getting the existing specs values
                List<PMP_Specification_Value__c> existingSpecValues = [Select id,Name,PMP_Specification_Value_Nm__c,PMP_Product_Specification_Value_Key__c,PMP_Specification_Value_Chinese_Cd__c,PMP_Specification_Value_Japanese_Cd__c from PMP_Specification_Value__c];              
                //If existing specs size >0, we are getting the PMP_Partner_Product_Specification_Key__c and adding it into a MAP (getexistingSpecs)
                if(existingSpecs.size()>0)
                {
                    //Iterate on existingSpecs
                    for(PMP_Specification__c existingSpec : existingSpecs)
                    {
                        //Put the key(PMP_Partner_Product_Specification_Key__c) and value(existingSpec) in getexistingSpecs map
                        getexistingSpecs.put(existingSpec.PMP_Partner_Product_Specification_Key__c,existingSpec);
                        
                    }
                    
                }
                //If existing specs values size >0, we are getting the PMP_Product_Specification_Value_Key__c and adding it into a MAP (getexistingSpecValues)
                if(existingSpecValues.size()>0)
                {
                    //Iterate on existingSpecValues
                    for(PMP_Specification_Value__c existingSpecValue : existingSpecValues)
                    {
                        //Put the key(PMP_Product_Specification_Value_Key__c) and value(existingSpecValue) in getexistingSpecValues map
                        getexistingSpecValues.put(existingSpecValue.PMP_Product_Specification_Value_Key__c,existingSpecValue);
                    }
                }
            }
            //If the language key is English language
            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
            {
                //to handle activation or inactivation of Specifications (Geo-Region)
                List<PMP_Specification__c> existingEngSpecs =  [Select id,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Specification_Type_Nm__c = :GeoRegion_Spec];
                 //If existingEngSpecs size >0, we are getting the PMP_Partner_Product_Specification_Key__c and adding it into a MAP (existingEngSpecsMap)
                if(existingEngSpecs.size()>0)
                {
                    //Iterate on existingEngSpecs
                    for(PMP_Specification__c Spec : existingEngSpecs)
                    {
                         //Put the key(PMP_Partner_Product_Specification_Key__c) and value(Spec) in existingEngSpecsMap map
                        existingEngSpecsMap.put(Spec.PMP_Partner_Product_Specification_Key__c,Spec); 
                    }
                    
                }            
                
                //to handle activation or inactivation of Spec Values (Geo-Region)
                List<PMP_Specification_Value__c> existingEngSpecValues = [Select id,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c from PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c = :PMP_StaticConstants_MasterData.GeoRegion_Spec_Value];
                //If existingEngSpecValues size >0, we are getting the PMP_Product_Specification_Value_Key__c and adding it into a MAP (existingEngSpecValuesMap)
                if(existingEngSpecValues.size()>0)
                {
                    //Iterate on existingEngSpecValues
                    for(PMP_Specification_Value__c SpecVal : existingEngSpecValues )
                    {
                        //Put the key(PMP_Product_Specification_Value_Key__c) and value(SpecVal) in existingEngSpecValuesMap map
                        existingEngSpecValuesMap.put(SpecVal.PMP_Product_Specification_Value_Key__c,SpecVal); 
                    }
                    
                }
            }
            //Map size >0, iterate on the child categories (in the static resource file) and create the data, for insertion
            if(mapSpec.size() > 0)        
            {
                //get the List of objects associated with language key
                List<Object> lstSpec = (List<Object>)mapSpec.get(strBaseKey); 
                //Iterate on the length of the List of objects associated with language key
                for(integer catIndex=0;catIndex<lstSpec.size();catIndex++)
                {
                    //Assigning the List of object based on index to the map specMap
                    Map<String, Object> specMap = (Map<String, Object>)lstSpec[catIndex];
                    //Iterate on specMap
                    if(specMap != null && !specMap.isEmpty())
                    {
                        //If the specMap contains key as Child categories, then proceed into the IF
                        if(specMap.containsKey(PMP_StaticConstants_MasterData.ChildCategories))
                        {
                           //Get the list of objects associated with the child categories
                            List<Object> lstChildCategories = (List<Object>)specMap.get(PMP_StaticConstants_MasterData.ChildCategories);
                            
                            //Iterate on lstChildCategories based on the length
                            for(integer specIndex=0;specIndex<lstChildCategories.size();specIndex++)
                            {
                                //Assign the list of object based on Index to the map specOrSpecValMap
                                Map<String, Object> specOrSpecValMap = (Map<String, Object>)lstChildCategories[specIndex];
                                
                                //If the map contains Level and the Level not equal to Level ''/ 'leaf' node
                                if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) != leafLevel)
                                {
                                    
                                    // If level value is not 'leaf' then create specification record
                                    PMP_Specification__c specification = new PMP_Specification__c();
                                    // If level value is not 'leaf' then create specification record - assign PMP_Display_Type_Nm__c
                                    specification.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                     // If level value is not 'leaf' then create specification record - assign PMP_Specification_Type_Nm__c
                                    specification.PMP_Specification_Type_Nm__c = GeoRegion_Spec;
                                   	specification.PMP_Active_Ind__c = true;//set specification active indicator as true by default
                                    //If the map has parentName as English or Chinese or Japnese geography as name
                                    if((specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Geography) || (specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Chinese_Geography) || (specMap.get(PMP_StaticConstants_MasterData.ParentName) == PMP_StaticConstants_MasterData.Japanese_Geography))
                                    {   
                                        //Assign Geo region PIM ID to Parent spec ID
                                        specification.PMP_Product_Parent_Specification_Id__c = GeoRegion_Specification_PIMId;
                                    }
                                    //If the map doesn't has parentName as English or Chinese or Japnese geography as name
                                    else
                                    {
                                        //Assign ParentIdentifier to Parent Spec ID
                                        specification.PMP_Product_Parent_Specification_Id__c = String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier));  
                                    }    
                                    //IF the file contains SpecRaw value and Spec Display Value
                                    if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue))
                                    {
                                        //Assign PMP_Partner_Product_Specification_Key__c with spec Raw value
                                        specification.PMP_Partner_Product_Specification_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase();
                                        //Assign PMP_Partner_Product_Specification_Id__c with SpecRaw value
                                        specification.PMP_Partner_Product_Specification_Id__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                        //fetch sequence number of the spec from utility method 
                                    	specification.PMP_Partner_Product_Display_Sequence_Nbr__c = PMP_Utility.getSpecificationSequenceNumber(specMap, specOrSpecValMap);
                                        //String declaration , assigning with specDisplay Value
                                        String SpecificationName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                        //If language key equals English
                                        if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                        {
                                            //Assign Name with spec display value
                                            specification.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));   
											//Added by Manasa - US439814
											specification.PMP_Specification_Name__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                        }
                                        //If language key equals chinese 
                                        if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                        {
                                            //Getting the exisiting specs based on the spec raw value , assign it to the specification object variable
                                            PMP_Specification__c Spec = getexistingSpecs.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                            //check if specName in english not euqals null, to assign chinese name 
											//Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                            if((SpecificationName==null||String.isBlank(SpecificationName)) && Spec!= null && Spec.PMP_Specification_Name__c!=null)
                                            {
                                                //Assign name based on language 
                                                Spec.PMP_Specification_Chinese_Nm__c = Spec.PMP_Specification_Name__c;
                                                //Put the spec Raw value and specification into translated map
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }
                                            //check if specName not euqals null, to assign chinese name 
                                            else if(SpecificationName!=null && String.isNotBlank(SpecificationName) && Spec!= null)
                                            {
                                                //Assign name based on language 
                                                Spec.PMP_Specification_Chinese_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                //Put the spec Raw value and specification into translated map
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }  
                                        }
                                        //If language key euqlas japanese
                                        if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                        {
                                            //Getting the exisiting specs based on the spec raw value , assign it to the specification object variable
                                            PMP_Specification__c Spec = getexistingSpecs.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                            //check if specName in english not euqals null, to assign japnese name
											//Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                            if((SpecificationName==null||String.isBlank(SpecificationName)) && Spec!= null && Spec.PMP_Specification_Name__c!=null)
                                            {
                                                //Assign name based on language 
                                                Spec.PMP_Specification_Japanese_Nm__c = Spec.PMP_Specification_Name__c;
                                                //Put the spec Raw value and specification into translated map
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }
                                            //check if specName not euqals null, to assign japnese name 
                                            else if(SpecificationName!=null && String.isNotBlank(SpecificationName) && Spec!= null)
                                            {
                                                //Assign name based on language 
                                                Spec.PMP_Specification_Japanese_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                //Put the spec Raw value and specification into translated map
                                                transSpecUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),Spec);
                                            }   
                                        }
                                    }
                                    
                                    //Add the specification to Map to avoid duplicacy of specification records
                                    if(specification.PMP_Partner_Product_Specification_Key__c !=null){
                                        specUploadMap.put(specification.PMP_Partner_Product_Specification_Key__c,specification);  
                                    }
                                    
                                }
                                /********************************Commented as we are not loading countries yet********************START********************************/
                                //If the map contains Level and the Level equal to 'leaf' node
                                /*else
                                {
                                    
                                    // If level value is 'leaf' then create specification value record
                                    if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) == leafLevel)
                                    {
                                        //Create new spec value 
                                        PMP_Specification_Value__c specificationValue = new PMP_Specification_Value__c();
                                        //Assign Display type to the record
                                        specificationValue.PMP_Display_Type_Nm__c= PMP_StaticConstants_MasterData.Checkbox;
                                        //Assign spec value type to the record
                                        specificationValue.PMP_Spec_Value_Type_Nm__c = PMP_StaticConstants_MasterData.GeoRegion_Spec_Value;
                                        
                                        //SpecIsActive is the attribute for Geo-regions for Active indicator field 
                                        if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecIsActive))
                                        {
                                            //If Active field equals YES
                                            if(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecIsActive)) == PMP_StaticConstants_MasterData.Yes)
                                            {
                                                //Assign true to Active Indicator field
                                                specificationValue.PMP_Active_Ind__c = true;
                                            }
                                            //If Active field equals NO
                                            else
                                            {
                                                //Assign false to Active Indicator field
                                               specificationValue.PMP_Active_Ind__c = false;
                                            }
                                        }
                                        //If map has spec raw value and spec display value
                                        if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecRawValue) && specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecDisplayValue))
                                        {
                                            //Assign PMP_Product_Specification_Value_Cd__c with the spec raw value
                                            specificationValue.PMP_Product_Specification_Value_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue));
                                            //If Map has sequence value
                                            if(specOrSpecValMap.containsKey(PMP_StaticConstants_MasterData.SpecValueSequence))
                                            {
                                                //Declare string for squence value
                                                String sequence = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecValueSequence));
                                                //if squence value contains ","
                                                if(sequence.contains(PMP_StaticConstants_MasterData.Comma_Symbol))
                                                {
                                                    //Remove the "," symbol and assigning to the string
                                                    sequence = sequence.remove(PMP_StaticConstants_MasterData.Comma_Symbol);
                                                    //Assign the Integer value of the sequence value to PMP_Specification_Value_Sequence_Nbr__c
                                                    specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueof(sequence);
                                                }
                                                //if squence value doesn't contains ","
                                                else
                                                {
                                                    System.debug('sequence ='+sequence);
                                                    //Assign the Integer value of the sequence value to PMP_Specification_Value_Sequence_Nbr__c
                                                    specificationValue.PMP_Specification_Value_Sequence_Nbr__c = Integer.valueof(sequence);
                                                }    
                                            }
                                            //Assign PMP_Product_Specification_Value_Key__c with spec Raw value
                                            specificationValue.PMP_Product_Specification_Value_Key__c = (String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase();
                                           
                                            //declare string for spec display value 
                                            String specValueName = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                            //if language key is ENGLISH
                                            if(strBaseKey == PMP_StaticConstants_MasterData.English_JSON)
                                            {
                                                //Assign PMP_Specification_Value_Nm__c with spec display value
                                                specificationValue.PMP_Specification_Value_Nm__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                //declare string for spec value display
                                                String Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                //If Name Length is greater than "80"
                                                if(Name.length()>80)
                                                {
                                                    //Assiging the substring value to Name
                                                    Name =  Name.substring(0,80);
                                                    specificationValue.Name = Name;
                                                }
                                                //If Name Length is less than "80"
                                                else
                                                {
                                                    //Assign the spec display valvue to Name
                                                    specificationValue.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                                }
                                                
                                            }
                                            //If language key is chinese
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                            {
                                                //assigne specValue with spec raw value
                                                PMP_Specification_Value__c SpecValue = getexistingSpecValues.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                                //If specValue Emglish name not equal null
                                                if((specValueName==null||String.isBlank(specValueName)) && SpecValue!= null && SpecValue.Name!=null)
                                                {
                                                    //Assign PMP_Specification_Value_Chinese_Cd__c
                                                    SpecValue.PMP_Specification_Value_Chinese_Cd__c = SpecValue.PMP_Specification_Value_Nm__c;
                                                    //Put raw value along with specValue into a MAP
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                }
                                                //If specValue name not equal null
                                                else if(specValueName!=null && String.isNotBlank(specValueName) && SpecValue!= null)
                                                {
                                                    //Assign PMP_Specification_Value_Chinese_Cd__c
                                                    SpecValue.PMP_Specification_Value_Chinese_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                    //Put raw value along with specValue into a MAP
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                }
                                            }
                                            //If language key is japanese
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                            {
                                                //assign specValue with spec raw value
                                                PMP_Specification_Value__c SpecValue = getexistingSpecValues.get((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase());
                                                //If specValue English name not equal null
                                                if((specValueName==null||String.isBlank(specValueName)) && SpecValue!= null && SpecValue.Name!=null)
                                                {
                                                    //Assign PMP_Specification_Value_Japanese_Cd__c
                                                    SpecValue.PMP_Specification_Value_Japanese_Cd__c = SpecValue.PMP_Specification_Value_Nm__c;
                                                    //Put raw value along with specValue into a MAP
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                }
                                                //If specValue  name not equal null
                                                else if(specValueName!=null && String.isNotBlank(specValueName) && SpecValue!= null)
                                                {
                                                    //Assign PMP_Specification_Value_Japanese_Cd__c
                                                    SpecValue.PMP_Specification_Value_Japanese_Cd__c = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                                    //Put raw value along with specValue into a MAP
                                                    transSpecValUploadMap.put((String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace()).toLowerCase(),SpecValue);
                                                } 
                                            }
                                        }
                                        //Assign into Map according to the key and spec value
                                        //If key, spec value not equals null
                                        if(specificationValue.PMP_Product_Specification_Value_Key__c !=null && (specificationValue.PMP_Specification_Value_Nm__c != null || String.isNotBlank(specificationValue.PMP_Specification_Value_Nm__c))){
                                            specValueUploadMap.put(specificationValue.PMP_Product_Specification_Value_Key__c,specificationValue); 
                                        }
                                        
                                    }                                       
                                }*/
                                /********************************Commented as we are not loading countries yet*********************END*******************************/
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
            //if deactivate map is not null/empty
            if(SpecsDeactiveMap != null || !SpecsDeactiveMap.isEmpty())
            {
                //Iterate on deactivate Map's key
                for(String key : SpecsDeactiveMap.keySet())
                {
                    //Adding deactivate map's key into a list
                    uploadSpec.add(SpecsDeactiveMap.get(key));
                    
                } 
            }
        }
        /********************************Commented as we are not loading countries yet****************************************************/
        //to handle deactivation of Spec Values
      /*if ((existingEngSpecValuesMap != null || !existingEngSpecValuesMap.isEmpty()) && (specValueUploadMap != null || !specValueUploadMap.isEmpty()))
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
            //If spec value deactivate map not null/empty
            if(SpecValuesDeactiveMap != null || !SpecValuesDeactiveMap.isEmpty())
            {
                //Iterate on spec value deactivate Map's key
                for(String key : SpecValuesDeactiveMap.keySet())
                {
                    //Adding spec value deactivate map's key into a list
                    uploadSpecValues.add(SpecValuesDeactiveMap.get(key));
                    
                } 
            }
        }*/
        System.debug('**specUploadMap**'+specUploadMap);
       // System.debug('**specValueUploadMap**'+specValueUploadMap);
        
        //iterate specUploadMap , where leaf node doesn't exsists 
        for(String key : specUploadMap.keySet())
        {
            //Adding in a list based on specUploadMap's key
            uploadSpec.add(specUploadMap.get(key));
        }
        /********************************Commented as we are not loading countries yet****************************************************/
        //Iterate specValueUploadMap, where leaf node exists 
      /*for(String key : specValueUploadMap.keySet())
        {
            //Adding in a list based on specValueUploadMap's key
            uploadSpecValues.add(specValueUploadMap.get(key));
        }*/
        
        System.debug('**uploadSpec**'+uploadSpec);
        System.debug('**uploadSpecValues**'+uploadSpecValues);
        
        //Not empty check, on list of spec's 
        if(uploadSpec.size()>0)
        {
            try
            {
                //upsert uploadSpec PMP_Partner_Product_Specification_Key__c;
                Schema.SObjectField upsertSpecKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
                //DML - upsert of all the specs 
                upsertResultData_Spec = Database.upsert(uploadSpec,upsertSpecKey,false);
            }
            catch(Exception exp1)
            {
                throw exp1;
            }
        }
        /********************************Commented as we are not loading countries yet****************************************************/
        //Not empty check, on list of spec values
      /*if(uploadSpecValues.size()>0)
        {
            try
            {
                Schema.SObjectField upsertSpecValKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                //DML - upsert of all the spec values
               upsertResultData_Spec_Value = Database.upsert(uploadSpecValues,upsertSpecValKey,false);
            }
            catch(Exception exp2)
            {
                throw exp2;
            }
        }*/
        
        //Iterate on translated specs' key
        for(String key : transSpecUploadMap.keySet())
        {
            //Assign to a list based on transSpecUploadMap's key
            uploadTransSpec.add(transSpecUploadMap.get(key));
        }
        /********************************Commented as we are not loading countries yet****************************************************/
         //Iterate on translated spec values' key
      /*for(String key : transSpecValUploadMap.keySet())
        {
            //Assign to a list based on transSpecValUploadMap's key
            uploadTransSpecValues.add(transSpecValUploadMap.get(key));
            
        }*/
        System.debug('**uploadTransSpec**'+uploadTransSpec);
       // System.debug('**uploadTransSpecValues**'+uploadTransSpecValues);
        
        //If uploadTransSpec is not empty 
        if(uploadTransSpec.size()>0)
        {
            try
            {
                //update uploadTransSpec;
                Schema.SObjectField upsertSpecTransKey = PMP_Specification__c.Fields.PMP_Partner_Product_Specification_Key__c;
                //DML - upsert all specs
                upsertResultData_Spec_Trans = Database.upsert(uploadTransSpec,upsertSpecTransKey,false);
            }
            catch(Exception exp1)
            {
                System.debug('EXCEPTION+++++++433++++++++++'+exp1.getMessage());
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
        /********************************Commented as we are not loading countries yet****************************************************/
        //If uploadTransSpecValues is not empty
      /*if(uploadTransSpecValues.size()>0)
        {
            try
            {
                //update uploadTransSpecValues;
                Schema.SObjectField upsertSpecValTransKey = PMP_Specification_Value__c.Fields.PMP_Product_Specification_Value_Key__c;
                //DML - upsert all spec values
                upsertResultData_Spec_Value_Trans = Database.upsert(uploadTransSpecValues,upsertSpecValTransKey,false);

            }
            catch(Exception exp2)
            {
                System.debug('EXCEPTION+++++++450++++++++++'+exp2.getMessage());
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp2.getMessage());
                throw exp2;
            }
        }
        
       //IF spec value translated list not empty
        if(upsertResultData_Spec_Value_Trans.size()>0)
        {
            //Iterate on translated spec value list 
            for(Database.UpsertResult res :upsertResultData_Spec_Value_Trans)
            {
                //Add into Database.UpsertResult list 
                upsertResultData.add(res);
            }
        }*/
        
        //IF spec translated list not empty
        if(upsertResultData_Spec_Trans.size()>0)
        {
            //Iterate on translated spec value list 
            for(Database.UpsertResult res :upsertResultData_Spec_Trans)
            {
                //Add into Database.UpsertResult list 
                upsertResultData.add(res);
            }
        }
        //IF spec list not empty
       if(upsertResultData_Spec.size()>0)
        {
            //Iterate on spec list 
            for(Database.UpsertResult res :upsertResultData_Spec)
            {
                //Add into Database.UpsertResult list 
                upsertResultData.add(res);
            }
        }
		/********************************Commented as we are not loading countries yet****************************************************/
        //IF spec value list not empty
      /*if(upsertResultData_Spec_Value.size()>0)
        {
            //Iterate on spec value list
            for(Database.UpsertResult res :upsertResultData_Spec_Value)
            {
                //Add into Database.UpsertResult list 
                upsertResultData.add(res);
            }
        }*/
        return upsertResultData;
    }
}