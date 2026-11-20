/****************************************************************************************************************************************
* Class Name  : PMP_ParseSpecificationJSON 
* Version     : 1.0 
* Created Date: 11-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     11/13/2018                    Created for Parsing the Specification JSON and creating Specification 
*                                                             and Specification Value records.
* Infosys - Sangeetha Ganta     12/26/2018                    User Story - US247116. Load Specification data as per new JSON file
* Infosys - Sangeetha Ganta     03/11/2019                    User Story - US296295. Sequencing of specification values
* Infosys - Sangeetha Ganta     03/26/2019                    User Story - US301406. Specifications localization from PIM in Japanese & 
*                                                             Simplified Chinese
*****************************************************************************************************************************************/

public without sharing class PMP_ParseSpecificationJSON {
    
    public static String strBaseKey; 
    Public static final String Other_Spec = 'Other';
    public static List<Database.UpsertResult> ParseSpecificationJSON(String StaticResourceName)
    {
        //Constants
        
        
        //Variable Declaration
        List<PMP_Specification__c> uploadSpec = new List<PMP_Specification__c>();
        Map<String,PMP_Specification__c> specUploadMap = new Map<String,PMP_Specification__c>();
        
        List<PMP_Specification_Value__c> uploadSpecValues = new List<PMP_Specification_Value__c>();
        Map<String,PMP_Specification_Value__c> specValueUploadMap = new Map<String,PMP_Specification_Value__c>();
        
        //US301406
        Map<String,PMP_Specification__c> getexistingSpecs = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification__c> transSpecUploadMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification_Value__c> transSpecValUploadMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,String> getParentPIMSpecId = new Map<String,String>();
        Map<String,PMP_Specification_Value__c> getexistingSpecValues = new Map<String,PMP_Specification_Value__c>();
        List<PMP_Specification__c> uploadTransSpec = new List<PMP_Specification__c>();
        List<PMP_Specification_Value__c> uploadTransSpecValues = new List<PMP_Specification_Value__c>();
        Map<String,PMP_Specification_Value__c> existingEngSpecValuesMap = new Map<String,PMP_Specification_Value__c>();
        Map<String,PMP_Specification_Value__c> SpecValuesDeactiveMap = new Map<String,PMP_Specification_Value__c>();
        //List<PMP_Specification__c> existingEngSpecs = new List<PMP_Specification__c>();
        Map<String,PMP_Specification__c> existingEngSpecsMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification__c> SpecsDeactiveMap = new Map<String,PMP_Specification__c>();
        Map<String,PMP_Specification__c> finalSpecUploadMap = new Map<String,PMP_Specification__c>();
        
        List<Database.UpsertResult> upsertResultData_Spec = new List<Database.UpsertResult>();//final upsert records (success and failure)
        List<Database.UpsertResult> upsertResultData_Spec_Trans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec_Value = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData_Spec_Value_Trans = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData= new List<Database.UpsertResult>();
        integer tempSequence = 0;
        integer specvalueSequence = 0;
        
        //Parse the JSON stored as a static resource
        String jsonStr = '';
        
        if(Test.isRunningTest())
        {    
            StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Attributes_Test]; 
            jsonStr = srObject.body.toString();
        }
        else
        {
            StaticResource srObject = [select id,body from StaticResource Where Name = :StaticResourceName];
            jsonStr = srObject.body.toString(); 
        }
        
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        
        //for (string theKey:mapSpec.keySet()){[Removed for loop as part code scan fix]
            if(!Test.isRunningTest()){
                strBaseKey = new list<String>(mapSpec.keySet())[0];
            }
            //System.debug('^^^TheKey--->'+strBaseKey);//###toberemoved
            
            if(mapSpec.size() > 0 && strBaseKey == PMP_StaticConstants_MasterData.English_JSON)        
            {
                //to handle activation or inactivation of Specifications (other than Processor and Chipsets)
                List<PMP_Specification__c> existingEngSpecs =  [Select id,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Specification_Type_Nm__c = :Other_Spec];
                
                if(existingEngSpecs.size()>0)
                {
                    for(PMP_Specification__c Spec : existingEngSpecs)
                    {
                        existingEngSpecsMap.put(Spec.PMP_Partner_Product_Specification_Key__c,Spec); 
                    }
                    
                }            
                
                //to handle activation or inactivation of Spec Values (other than Processor and Chipsets)
                List<PMP_Specification_Value__c> existingEngSpecValues = [Select id,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c from PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c = :PMP_StaticConstants_MasterData.Other_Spec_Value];
                
                if(existingEngSpecValues.size()>0)
                {
                    for(PMP_Specification_Value__c SpecVal : existingEngSpecValues )
                    {
                        existingEngSpecValuesMap.put(SpecVal.PMP_Product_Specification_Value_Key__c,SpecVal); 
                    }
                    
                }
                List<Object> lstSpec = (List<Object>)mapSpec.get(strBaseKey); 
                
                for(integer catIndex=0;catIndex<lstSpec.size();catIndex++)
                {            
                    
                    Map<String, Object> specMap = (Map<String, Object>)lstSpec[catIndex];
                    if(specMap != null && !specMap.isEmpty())
                    {
                        
                        if(specMap.containsKey(PMP_StaticConstants_MasterData.Features))
                        {
                            
                            List<Object> lstFeature = (List<Object>)specMap.get(PMP_StaticConstants_MasterData.Features);
                            //List<String> catsegment = new List<String>();
                            
                            for(integer specIndex=0;specIndex<lstFeature.size();specIndex++)
                            {
                                if(lstFeature !=null)
                                {
                                    Map<String,Object> featureMap = (Map<String, Object>)lstFeature[specIndex];
                                    
                                    if(featureMap != null && !featureMap.isEmpty())
                                    {
                                        List<String> levelValues = new List<String>();
                                        integer highestlevel = 0;
                                        integer templevel = 0;
                                        List<String> pimParentSpec = new List<String>();
                                        List<String> pimParentKey = new List<String>(); 
                                        integer featureMapSequence = 0;
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Spec_Identifier)) 
                                        {
                                            
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_1))
                                            {
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_1)));  
                                            }
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_2))
                                            {
                                                
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_2)));
                                                
                                            }
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_3))
                                            {
                                                
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_3)));
                                                
                                            }
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_4)){
                                                
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_4)));
                                                
                                            }
                                        }
                                        for(integer nodeIndex=0;nodeIndex<levelvalues.size();nodeIndex++)
                                        {
                                            if(!String.isBlank(levelvalues[nodeIndex]))
                                            {
                                                highestlevel = nodeIndex;
                                            }
                                        }
                                        //for rest of the levels other than leaf node create specification with respective spec ids having level in id name
                                        
                                        for(integer speclevelIndex=0;speclevelIndex<highestlevel;speclevelIndex++)
                                        {
                                            PMP_Specification__c spec2 = new PMP_Specification__c();
                                            String specid = String.valueOf(levelvalues[speclevelIndex]);
                                            spec2.Name=String.valueOf(levelvalues[speclevelIndex]);
                                            //Added by Manasa - US439814
                                            spec2.PMP_Specification_Name__c = String.valueOf(levelvalues[speclevelIndex]);
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Is_Active))
                                            {
                                                spec2.PMP_Active_Ind__c = Boolean.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Is_Active));
                                            }
                                            spec2.PMP_Specification_Type_Nm__c = Other_Spec;
                                            //Added by Manasa - US439814
                                            String specmapkey2 = spec2.PMP_Specification_Name__c.toLowerCase();
                                            pimParentSpec.add(specmapkey2);
                                            String MYKEY2 = String.join(pimParentSpec,PMP_StaticConstants_MasterData.Pipe_Symbol);
                                            pimParentKey.add(MYKEY2);
                                            if(!specUploadMap.containsKey(MYKEY2))
                                            {
                                                templevel = speclevelIndex+1;
                                                spec2.PMP_Partner_Product_Specification_Id__c = specid.deleteWhitespace()+PMP_StaticConstants_MasterData.Level+templevel;
                                                if(speclevelIndex>0)
                                                {
                                                    
                                                    String Parent = pimParentKey[speclevelIndex-1];
                                                    
                                                    if(specUploadMap.containsKey(Parent) && specUploadMap.get(Parent) != null)
                                                    {
                                                        PMP_Specification__c ParentSpec = specUploadMap.get(Parent);
                                                        spec2.PMP_Product_Parent_Specification_Id__c = ParentSpec.PMP_Partner_Product_Specification_Id__c;
                                                    }
                                                }    
                                                
                                                spec2.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Label;
                                                /*Raj Modified here*/
                                                String extKey2 = (spec2.PMP_Partner_Product_Specification_Id__c.deleteWhitespace()).toLowerCase();
                                                
                                                spec2.PMP_Partner_Product_Specification_Key__c = extKey2;
                                                specUploadMap.put(MYKEY2,spec2);
                                            }
                                            
                                        }
                                        
                                        //Create a Specification with given Spec Identifier
                                        
                                        PMP_Specification__c spec1 = new PMP_Specification__c();
                                        spec1.PMP_Partner_Product_Specification_Id__c = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier));
                                        spec1.Name=String.valueOf(levelvalues[highestlevel]);
                                        //Added by Manasa - US439814
                                        spec1.PMP_Specification_Name__c = String.valueOf(levelvalues[highestlevel]);
                                        spec1.PMP_Mandatory_Offering_Category_Nm__c = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Mandatory_for_Category));
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Is_Active))
                                        {
                                            spec1.PMP_Active_Ind__c = Boolean.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Is_Active)); 
                                        }
                                        spec1.PMP_Specification_Type_Nm__c = Other_Spec;
                                        //Added by Manasa - US439814
                                        String specmapkey1 = spec1.PMP_Specification_Name__c.toLowerCase();
                                        pimParentSpec.add(specmapkey1);
                                        String MYKEY1 = String.join(pimParentSpec,PMP_StaticConstants_MasterData.Pipe_Symbol);
                                        pimParentKey.add(MYKEY1);
                                        if(highestlevel>0)
                                        {
                                            
                                            String Parent = pimParentKey[highestlevel-1];
                                            if(specUploadMap.containsKey(Parent) && specUploadMap.get(Parent) != null){
                                                PMP_Specification__c ParentSpec = specUploadMap.get(Parent);
                                                spec1.PMP_Product_Parent_Specification_Id__c = ParentSpec.PMP_Partner_Product_Specification_Id__c;
                                                
                                            }
                                        }
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Type))
                                        {
                                            
                                            if((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type))).contains(PMP_StaticConstants_MasterData.Radio)){
                                                spec1.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Radiobutton;
                                            }
                                            else if((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type))).contains(PMP_StaticConstants_MasterData.Check)){
                                                spec1.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                            }
                                            else if((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type))).contains(PMP_StaticConstants_MasterData.Auto_Populated_From_PIM)){
                                                spec1.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Label;
                                            }
                                            else{
                                                spec1.PMP_Display_Type_Nm__c = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type));
                                            }
                                            
                                        }
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Sequence))
                                        {
                                            
                                            String sequence = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Sequence));
                                            if(sequence.contains(PMP_StaticConstants_MasterData.Comma_Symbol)){
                                                sequence = sequence.remove(PMP_StaticConstants_MasterData.Comma_Symbol);
                                                spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = Integer.valueof(sequence);
                                            }
                                            else{
                                                spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = Integer.valueof(sequence);
                                            }
                                            featureMapSequence = Integer.valueOf(spec1.PMP_Partner_Product_Display_Sequence_Nbr__c);
                                        }
                                        
                                        if(!specUploadMap.containsKey(MYKEY1))
                                        {
                                            /*Raj modified here*/
                                            String extKey1 = (spec1.PMP_Partner_Product_Specification_Id__c.deleteWhitespace()).toLowerCase();
                                            
                                            spec1.PMP_Partner_Product_Specification_Key__c = extKey1;
                                            /*End*/
                                            specUploadMap.put(MYKEY1,spec1);
                                            
                                        }
                                        //Setting the Offering Spec Values for above specification
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Preset_Values))
                                        {
                                            Map<String, Object> specValueMap = (Map<String, Object>)featureMap.get(PMP_StaticConstants_MasterData.Preset_Values);
                                            if(specValueMap != null)
                                            {
                                                if(specValueMap.containsKey(PMP_StaticConstants_MasterData.Identifier) && specValueMap.containsKey(PMP_StaticConstants_MasterData.Values))
                                                {
                                                    String identifier = String.valueOf(specValueMap.get(PMP_StaticConstants_MasterData.Identifier));
                                                    String value = String.valueOf(specValueMap.get(PMP_StaticConstants_MasterData.Values));
                                                    
                                                    
                                                    //Checking the string length since split can consider empty string and list size can be 1
                                                    
                                                    if(identifier.length()>0 && value.length()>0)
                                                    {               
                                                        PMP_Specification_Value__c osv = new PMP_Specification_Value__c();
                                                        osv.PMP_Spec_Value_Type_Nm__c = PMP_StaticConstants_MasterData.Other_Spec_Value;
                                                        osv.PMP_Active_Ind__c = true;
                                                        //osv.Name = value;                                                               
                                                        //osv.PMP_Specification_Value_Nm__c = value;
                                                        //osv.PMP_Product_Specification_Value_Cd__c = String.valueOf(identifier);
                                                        
                                                        //To handle the scenario where the spec value identifier reads as Yes in JSON file
                                                        if(identifier == PMP_StaticConstants_MasterData.Yes && value == PMP_StaticConstants_MasterData.Yes)
                                                        {
                                                            osv.Name = String.valueOf(levelvalues[highestlevel]);                                                           
                                                            osv.PMP_Specification_Value_Nm__c = String.valueOf(levelvalues[highestlevel]);
                                                            osv.PMP_Product_Specification_Value_Cd__c = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier));  
                                                        }
                                                        else if(identifier == 'Yes_Boolean' || identifier == 'No_Boolean'){
                                                            osv.Name = value.split('_')[0];                                                               
                                                            osv.PMP_Specification_Value_Nm__c = value.split('_')[0];
                                                            osv.PMP_Product_Specification_Value_Cd__c = String.valueOf(identifier);
                                                        }
                                                        else
                                                        {
                                                            osv.Name = value;                                                               
                                                            osv.PMP_Specification_Value_Nm__c = value;
                                                            osv.PMP_Product_Specification_Value_Cd__c = String.valueOf(identifier);
                                                        }
                                                        osv.PMP_Specification_Product_Cd__c = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier));
                                                        String specvalmapkey = osv.PMP_Product_Specification_Value_Cd__c;
                                                        String keyspec = specvalmapkey.deleteWhitespace();
                                                        
                                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Type))
                                                        {
                                                            
                                                            if((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type))).contains(PMP_StaticConstants_MasterData.Radio)){
                                                                osv.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Radiobutton;
                                                            }
                                                            else if((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type))).contains(PMP_StaticConstants_MasterData.Check)){
                                                                osv.PMP_Display_Type_Nm__c = PMP_StaticConstants_MasterData.Checkbox;
                                                            }
                                                            else{
                                                                osv.PMP_Display_Type_Nm__c = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Type));
                                                            }
                                                            
                                                        }
                                                        
                                                        //Defining the sequence for spec values
                                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Sequence))
                                                        {
                                                            //System.debug('featureMapSequence = '+featureMapSequence);
                                                            //System.debug('tempSequence ='+tempSequence);
                                                            //System.debug('specvalueSequence');
                                                            if(featureMapSequence != tempSequence)
                                                            {
                                                                specvalueSequence = 1;
                                                                tempSequence = featureMapSequence;
                                                            } 
                                                            else
                                                            {
                                                                specvalueSequence ++;
                                                            }
                                                            
                                                            osv.PMP_Specification_Value_Sequence_Nbr__c = featureMapSequence + specvalueSequence;
                                                        }
                                                        /*Raj Modified here*/
                                                        String externalKey = (String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)) + '_' + keyspec.toLowerCase()).deleteWhitespace();
                                                        osv.PMP_Product_Specification_Value_Key__c = externalKey;//raj to modify here
                                                        if(!specValueUploadMap.containsKey(externalKey))
                                                        {
                                                            
                                                            specValueUploadMap.put(externalKey,osv);
                                                            
                                                        }
                                                        /*End*/
                                                        
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
                
            }
            
            //US301406
            if(mapSpec.size() > 0 && strBaseKey != PMP_StaticConstants_MasterData.English_JSON)
            {
                List<PMP_Specification__c> existingSpecs = [Select id,Name,PMP_Specification_Name__c,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c from PMP_Specification__c where Name != null];
                List<PMP_Specification_Value__c> existingSpecValues = [Select id,Name,PMP_Specification_Value_Nm__c,PMP_Product_Specification_Value_Key__c,PMP_Specification_Value_Chinese_Cd__c,PMP_Specification_Value_Japanese_Cd__c from PMP_Specification_Value__c where Name != null];              
                if(existingSpecs.size()>0)
                {
                    for(PMP_Specification__c existingSpec : existingSpecs)
                    {
                        getexistingSpecs.put(existingSpec.PMP_Partner_Product_Specification_Id__c,existingSpec);
                        getParentPIMSpecId.put(existingSpec.PMP_Partner_Product_Specification_Id__c,existingSpec.PMP_Product_Parent_Specification_Id__c);
                        
                    }
                    
                }
                if(existingSpecValues.size()>0)
                {
                    for(PMP_Specification_Value__c existingSpecValue : existingSpecValues)
                    {
                        getexistingSpecValues.put(existingSpecValue.PMP_Product_Specification_Value_Key__c,existingSpecValue);
                    }
                }
                
                List<Object> lstSpec = (List<Object>)mapSpec.get(strBaseKey);
                for(integer catIndex=0;catIndex<lstSpec.size();catIndex++)
                {            
                    
                    Map<String, Object> specMap = (Map<String, Object>)lstSpec[catIndex];
                    if(specMap != null && !specMap.isEmpty())
                    {
                        
                        if(specMap.containsKey(PMP_StaticConstants_MasterData.Features))
                        {
                            List<Object> lstFeature = (List<Object>)specMap.get(PMP_StaticConstants_MasterData.Features);
                            //List<String> catsegment = new List<String>();
                            
                            for(integer specIndex=0;specIndex<lstFeature.size();specIndex++)
                            {
                                if(lstFeature !=null)
                                {
                                    Map<String,Object> featureMap = (Map<String, Object>)lstFeature[specIndex];
                                    
                                    if(featureMap != null && !featureMap.isEmpty())
                                    {
                                        List<String> levelValues = new List<String>();
                                        integer highestlevel = 0;
                                        //integer templevel = 0;
                                        //List<String> pimParentSpec = new List<String>();
                                        //List<String> pimParentKey = new List<String>(); 
                                        //integer featureMapSequence = 0;
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Spec_Identifier)) 
                                        {
                                            
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_1))
                                            {
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_1)));  
                                            }
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_2))
                                            {
                                                
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_2)));
                                                
                                            }
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_3))
                                            {
                                                
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_3)));
                                                
                                            }
                                            if(featureMap.containsKey(PMP_StaticConstants_MasterData.Level_4))
                                            {
                                                
                                                levelvalues.add(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Level_4)));
                                                
                                            }
                                        }
                                        
                                        for(integer nodeIndex=0;nodeIndex<levelvalues.size();nodeIndex++)
                                        {
                                            if(!String.isBlank(levelvalues[nodeIndex]))
                                            {
                                                highestlevel = nodeIndex;
                                            }
                                        }
                                        //Setting the Chinese and Japanese Specification names
                                        for(integer speclevelIndex=0;speclevelIndex<=highestlevel;speclevelIndex++)
                                        {
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                            {
                                                if(highestlevel == 2)
                                                {
                                                    PMP_Specification__c speclevel2 = getexistingSpecs.get(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    if (speclevel2 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[2])==null||String.isBlank(String.valueOf(levelvalues[2]))) && speclevel2.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel2.PMP_Specification_Chinese_Nm__c =speclevel2.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel2);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[2])!=null && String.isNotBlank(String.valueOf(levelvalues[2])))
                                                        {
                                                            speclevel2.PMP_Specification_Chinese_Nm__c  = String.valueOf(levelvalues[2]);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel2);
                                                        }
                                                        
                                                    }
                                                }
                                                if(highestlevel == 1)
                                                {
                                                    PMP_Specification__c speclevel1 = getexistingSpecs.get(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    //System.debug('I am here'+speclevel1);
                                                    String parentPIMSpecId = getParentPIMSpecId.get((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier))));
                                                    if (speclevel1 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[1])==null||String.isBlank(String.valueOf(levelvalues[1]))) && speclevel1.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel1.PMP_Specification_Chinese_Nm__c =speclevel1.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel1);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[1])!=null && String.isNotBlank(String.valueOf(levelvalues[1])))
                                                        {
                                                            speclevel1.PMP_Specification_Chinese_Nm__c  = String.valueOf(levelvalues[1]);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel1);
                                                        }
                                                        
                                                    }
                                                    PMP_Specification__c speclevel0 = getexistingSpecs.get(parentPIMSpecId);
                                                    if (speclevel0 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[0])==null||String.isBlank(String.valueOf(levelvalues[0]))) && speclevel0.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel0.PMP_Specification_Chinese_Nm__c =speclevel0.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(parentPIMSpecId),speclevel0);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[0])!=null && String.isNotBlank(String.valueOf(levelvalues[0])))
                                                        {
                                                            speclevel0.PMP_Specification_Chinese_Nm__c  = String.valueOf(levelvalues[0]);
                                                            transSpecUploadMap.put(String.valueOf(parentPIMSpecId),speclevel0);
                                                        }
                                                        
                                                    }
                                                }
                                                if(highestlevel == 0)
                                                {
                                                    
                                                    //System.debug('Spec0-->'+String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    PMP_Specification__c speclevel00 = getexistingSpecs.get(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    if (speclevel00 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[0])==null||String.isBlank(String.valueOf(levelvalues[0]))) && speclevel00.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel00.PMP_Specification_Chinese_Nm__c =speclevel00.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel00);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[0])!=null && String.isNotBlank(String.valueOf(levelvalues[0])))
                                                        {
                                                            speclevel00.PMP_Specification_Chinese_Nm__c  = String.valueOf(levelvalues[0]);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel00);
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                            if(strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                            {
                                                if(highestlevel == 2)
                                                {
                                                    PMP_Specification__c speclevel2 = getexistingSpecs.get(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    if (speclevel2 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[2])==null||String.isBlank(String.valueOf(levelvalues[2]))) && speclevel2.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel2.PMP_Specification_Japanese_Nm__c =speclevel2.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel2);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[2])!=null && String.isNotBlank(String.valueOf(levelvalues[2])))
                                                        {
                                                            speclevel2.PMP_Specification_Japanese_Nm__c  = String.valueOf(levelvalues[2]);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel2);
                                                        }
                                                        
                                                    }
                                                }
                                                if(highestlevel == 1)
                                                {
                                                    PMP_Specification__c speclevel1 = getexistingSpecs.get(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    //System.debug('speclevel1 ='+speclevel1);
                                                    String parentPIMSpecId = getParentPIMSpecId.get((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier))));
                                                    if (speclevel1 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[1])==null||String.isBlank(String.valueOf(levelvalues[1]))) && speclevel1.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel1.PMP_Specification_Japanese_Nm__c =speclevel1.PMP_Specification_Name__c;
                                                            //System.debug('Line 519'+speclevel1.PMP_Specification_Japanese_Nm__c);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel1);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[1])!=null && String.isNotBlank(String.valueOf(levelvalues[1])))
                                                        {
                                                            speclevel1.PMP_Specification_Japanese_Nm__c  = String.valueOf(levelvalues[1]);
                                                            //System.debug('Line 526__>'+speclevel1.PMP_Specification_Japanese_Nm__c);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel1);
                                                        }
                                                        
                                                    }
                                                    PMP_Specification__c speclevel0 = getexistingSpecs.get(parentPIMSpecId);
                                                    if (speclevel0 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[0])==null||String.isBlank(String.valueOf(levelvalues[0]))) && speclevel0.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel0.PMP_Specification_Japanese_Nm__c =speclevel0.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(parentPIMSpecId),speclevel0);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[0])!=null && String.isNotBlank(String.valueOf(levelvalues[0])))
                                                        {
                                                            speclevel0.PMP_Specification_Japanese_Nm__c  = String.valueOf(levelvalues[0]);
                                                            transSpecUploadMap.put(String.valueOf(parentPIMSpecId),speclevel0);
                                                        }
                                                        
                                                    }
                                                }
                                                if(highestlevel == 0)
                                                {
                                                    PMP_Specification__c speclevel00 = getexistingSpecs.get(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)));
                                                    if (speclevel00 != null)
                                                    {
                                                        //Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
                                                        if((String.valueOf(levelvalues[0])==null||String.isBlank(String.valueOf(levelvalues[0]))) && speclevel00.PMP_Specification_Name__c!=null)
                                                        {
                                                            speclevel00.PMP_Specification_Japanese_Nm__c =speclevel00.PMP_Specification_Name__c;
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel00);
                                                        }
                                                        //mapping the JSON value to the field
                                                        else if(String.valueOf(levelvalues[0])!=null && String.isNotBlank(String.valueOf(levelvalues[0])))
                                                        {
                                                            speclevel00.PMP_Specification_Japanese_Nm__c  = String.valueOf(levelvalues[0]);
                                                            transSpecUploadMap.put(String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)),speclevel00);
                                                        }
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                        }       
                                        
                                        //Setting the Spec Values in Japanese and Chinese
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Preset_Values))
                                        {
                                            Map<String, Object> specValueMap = (Map<String, Object>)featureMap.get(PMP_StaticConstants_MasterData.Preset_Values);
                                            if(specValueMap != null)
                                            {
                                                if(specValueMap.containsKey(PMP_StaticConstants_MasterData.Identifier) && specValueMap.containsKey(PMP_StaticConstants_MasterData.Values))
                                                {
                                                    String identifier = String.valueOf(specValueMap.get(PMP_StaticConstants_MasterData.Identifier));
                                                    
                                                    
                                                    String value = String.valueOf(specValueMap.get(PMP_StaticConstants_MasterData.Values));
                                                    
                                                    
                                                    //Checking the string length since split can consider empty string and list size can be 1
                                                    
                                                    if(identifier.length()>0)
                                                    {
                                                        if(identifier == PMP_StaticConstants_MasterData.Yes && value == PMP_StaticConstants_MasterData.Yes)
                                                        {   
                                                            String externalKey = featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier) + '_' + ((String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier))).deleteWhitespace()).toLowerCase();
                                                            
                                                            PMP_Specification_Value__c specValue = getexistingSpecValues.get(externalKey);
                                                            if(specValue!= null && strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                                            {
                                                                if((String.valueOf(levelvalues[highestlevel])==null||String.isBlank(String.valueOf(levelvalues[highestlevel]))) && specValue.PMP_Specification_Value_Nm__c!=null){
                                                                    specValue.PMP_Specification_Value_Chinese_Cd__c = specValue.PMP_Specification_Value_Nm__c;
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }
                                                                //mapping the JSON value to the field
                                                                else if(String.valueOf(levelvalues[highestlevel])!=null && String.isNotBlank(String.valueOf(levelvalues[highestlevel]))){
                                                                    specValue.PMP_Specification_Value_Chinese_Cd__c =  String.valueOf(levelvalues[highestlevel]);
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }
                                                                
                                                            }
                                                            if(specValue!= null && strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                                            {
                                                                if((String.valueOf(levelvalues[highestlevel])==null||String.isBlank(String.valueOf(levelvalues[highestlevel]))) && specValue.PMP_Specification_Value_Nm__c!=null){
                                                                    specValue.PMP_Specification_Value_Japanese_Cd__c = specValue.PMP_Specification_Value_Nm__c;
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }
                                                                //mapping the JSON value to the field
                                                                else if(String.valueOf(levelvalues[highestlevel])!=null && String.isNotBlank(String.valueOf(levelvalues[highestlevel]))){
                                                                    specValue.PMP_Specification_Value_Japanese_Cd__c =  String.valueOf(levelvalues[highestlevel]);
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }                                                   
                                                            }                                               
                                                            
                                                        }
                                                        else
                                                        {   
                                                            String externalKey = featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier) + '_' + (identifier.deleteWhitespace()).toLowerCase();
                                                            //System.debug('&&&externalkey'+externalKey);
                                                            PMP_Specification_Value__c specValue = getexistingSpecValues.get(externalKey);
                                                            if(specValue!= null && strBaseKey == PMP_StaticConstants_MasterData.Chinese_JSON)
                                                            {
                                                                
                                                                if((value==null||String.isBlank(value)) && specValue.PMP_Specification_Value_Nm__c!=null){
                                                                    
                                                                    specValue.PMP_Specification_Value_Chinese_Cd__c = specValue.PMP_Specification_Value_Nm__c;
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }
                                                                //mapping the JSON value to the field
                                                                else if(value!=null && String.isNotBlank(value)){
                                                                    specValue.PMP_Specification_Value_Chinese_Cd__c =  value;
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }
                                                                
                                                            }
                                                            if(specValue!= null && strBaseKey == PMP_StaticConstants_MasterData.Japanese_JSON)
                                                            {
                                                                if((value==null||String.isBlank(String.valueOf(value))) && specValue.PMP_Specification_Value_Nm__c!=null){
                                                                    specValue.PMP_Specification_Value_Japanese_Cd__c = specValue.PMP_Specification_Value_Nm__c;
                                                                    transSpecValUploadMap.put(externalKey,specValue);
                                                                }
                                                                //mapping the JSON value to the field
                                                                else if(value!=null && String.isNotBlank(value)){
                                                                    specValue.PMP_Specification_Value_Japanese_Cd__c =  value;
                                                                    transSpecValUploadMap.put(externalKey,specValue);
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
                        }
                    }
                }
            }   
            
        //}[Removed for loop as part code scan fix]   
        
        //to handle deactivation of Spec Values
        if ((existingEngSpecValuesMap != null && !existingEngSpecValuesMap.isEmpty()) && (specValueUploadMap != null && !specValueUploadMap.isEmpty()))
        {
            for(String keyId: existingEngSpecValuesMap.Keyset())
            {
                //if 2nd map does not have that key
                // System.debug('keyId1 ='+keyId);
                if(!specValueUploadMap.keyset().contains(keyId))
                {
                    // System.debug('keyId ='+keyId);
                    PMP_Specification_Value__c SpecValue = existingEngSpecValuesMap.get(keyId);
                    SpecValue.PMP_Active_Ind__c = false;
                    SpecValuesDeactiveMap.put(keyId,SpecValue);
                    // System.debug('SpecValuesDeactiveMap'+SpecValuesDeactiveMap);
                }
                
            }
            if(SpecValuesDeactiveMap != null && !SpecValuesDeactiveMap.isEmpty())
            {
                for(String key : SpecValuesDeactiveMap.keySet())
                {
                    uploadSpecValues.add(SpecValuesDeactiveMap.get(key));
                    
                } 
            }
        }
        
        for(String key : specUploadMap.keySet())
        {
            //uploadSpec.add(specUploadMap.get(key));
            finalSpecUploadMap.put(specUploadMap.get(key).PMP_Partner_Product_Specification_Key__c,specUploadMap.get(key));
        }
        //to handle deactivation of Specifications
        if ((existingEngSpecsMap != null && !existingEngSpecsMap.isEmpty()) && (finalSpecUploadMap != null && !finalSpecUploadMap.isEmpty()))
        {
            for(String keyId: existingEngSpecsMap.Keyset())
            {
                //if 2nd map does not have that key
                if(!finalSpecUploadMap.keyset().contains(keyId))
                {
                    // System.debug('keyIdSpec ='+keyId);
                    PMP_Specification__c Spec = existingEngSpecsMap.get(keyId);
                    Spec.PMP_Active_Ind__c = false;
                    SpecsDeactiveMap.put(keyId,Spec);
                    //System.debug('SpecsDeactiveMap'+SpecsDeactiveMap);
                }
                
            }
            if(SpecsDeactiveMap != null && !SpecsDeactiveMap.isEmpty())
            {
                for(String key : SpecsDeactiveMap.keySet())
                {
                    uploadSpec.add(SpecsDeactiveMap.get(key));
                    
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
                upsertResultData_Spec = Database.upsert(uploadSpec,upsertSpecKey,false);
            }
            catch(Exception exp1)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp1.getMessage());
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
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_ParseSpecificationJSON_Exception_Message+exp2.getMessage());
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
                Schema.SObjectField upsertSpecTransKey = PMP_Specification__c.Fields.Id;
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
                Schema.SObjectField upsertSpecValTransKey = PMP_Specification_Value__c.Fields.Id;
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
        
        return upsertResultData;
    }
    
    
}