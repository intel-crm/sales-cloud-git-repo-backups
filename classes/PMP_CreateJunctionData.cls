/****************************************************************************************************************************************
* Class Name  : PMP_CreateJunctionData 
* Version     : 1.0 
* Created Date: 15-11-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     15/11/2018                    Created for Parsing the Specification JSON and creating Specification 
and Specification Value records.
* Infosys - Sangeetha Ganta     12/26/2018                    User Story - US247116. Load Specification Junction data as per new JSON file
* Infosys - Sangeetha Ganta     02/27/2019                    User Story - US274100. Activate the Category Spec Association based on the 
*                                                             category active indicator
* Infosys - Sangeetha Ganta     02/28/2019                    User story - US290905. Activate the Specification Association based on the 
*                                                             specification active indicator
*Infosys - Sangeetha Ganta     02/28/2019                    User Story - US349982. Inactivation of  spec values for specific 
*                                                            Category in PIM to sync in SF
*****************************************************************************************************************************************/
public class PMP_CreateJunctionData {
    
    public static List<Database.UpsertResult> createJunctionObjData()
    {
        //Variable Declaration
        Map<String,Id> catMap = new Map<String,Id>();
        Map<String,Id> speciMap = new Map<String,Id>();
        Map<String,Id> speciPIMMap = new Map<String,Id>();
        Map<String,Id> speciValMap = new Map<String,Id>();
        Map<String,String> specNameMap = new Map<String,String>();
        Map<String,Boolean> catActiveIndMap = new Map<String,Boolean>();
        Map<String,Boolean> specActiveIndMap = new Map<String,Boolean>();
        Map<String,Boolean> specValActiveIndMap = new Map<String,Boolean>();
        
        
        Map<String,String> pimIdSpecMap = new Map<String,String>();
        Map<String,Id> level1SpecMap = new Map<String,Id>();
        Map<String,Id> level2GrtSpecMap = new Map<String,Id>();
        
        List<Database.UpsertResult> upsertResultDataSpecJO = new List<Database.UpsertResult>();//final upsert records (success and failure)
        List<Database.UpsertResult> upsertResultDataSpecValueJO = new List<Database.UpsertResult>();
        List<Database.UpsertResult> upsertResultData= new List<Database.UpsertResult>();
        
        Map<String,PMP_Category_Specification_Association__c> uploadCatSpecMap = new Map<String,PMP_Category_Specification_Association__c>();
        Map<String,PMP_Specification_Value_Association__c> uploadSpecSpecVMap = new Map<String,PMP_Specification_Value_Association__c>();
        List<PMP_Category_Specification_Association__c> uploadCatSpecJO = new List<PMP_Category_Specification_Association__c>();
        List<PMP_Specification_Value_Association__c> uploadSpecSpecValJO = new List<PMP_Specification_Value_Association__c>();
        Set<Id> deactiveSpecValues = new Set<Id>();
        
        //US349982
        Map<String,PMP_Specification_Value_Association__c> existingEngSpecValuesAscMap = new Map<String,PMP_Specification_Value_Association__c>();
        Map<String,PMP_Specification_Value_Association__c> specValuesDeactiveAscMap = new Map<String,PMP_Specification_Value_Association__c>();
        /*Added by raj*/
        Map<String, PMP_Category_Specification_Association__c> existingCatSpecAssocByExternalKey = new Map<String, PMP_Category_Specification_Association__c>();
        for(PMP_Category_Specification_Association__c catSpecAssoc : [SELECT Id,Name,PMP_Active_Ind__c, PMP_Category_Specification_External_Key__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__r.PMP_Specification_Type_Nm__c = 'Other']){
           	existingCatSpecAssocByExternalKey.put(catSpecAssoc.PMP_Category_Specification_External_Key__c, catSpecAssoc); 
        }
        /*End*/
        
        //Fetch the Offering Category ids into a map for reference
        for(PMP_Category__c cat:[Select Id,PMP_Partner_Product_Category_Cd__c,PMP_Active_Ind__c,PMP_Partner_Product_Category_Key__c,Name from PMP_Category__c])
        {
            catMap.put(cat.PMP_Partner_Product_Category_Key__c,cat.Id);
            catActiveIndMap.put(cat.PMP_Partner_Product_Category_Key__c,cat.PMP_Active_Ind__c);
        }  
        //Added by Manasa - US439814
        for(PMP_Specification__c spec:[Select Name,PMP_Specification_Name__c,Id,PMP_Active_Ind__c,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c])
        {
			//Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
            String temp2 = spec.PMP_Specification_Name__c;
            speciMap.put(temp2,spec.Id);
            specActiveIndMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec.PMP_Active_Ind__c);
            speciPIMMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec.Id);
			//Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
            specNameMap.put(spec.PMP_Partner_Product_Specification_Id__c,spec.PMP_Specification_Name__c);
            
            
            pimIdSpecMap.put(temp2,spec.PMP_Partner_Product_Specification_Id__c);
            String temp4 = spec.PMP_Partner_Product_Specification_Id__c;
            level1SpecMap.put(temp4,spec.Id);
			//Added by Manasa - US439814 - Used custom Name field instead of Standard Name field
            String temp5 = spec.PMP_Specification_Name__c+PMP_StaticConstants_MasterData.Pipe_Symbol+ spec.PMP_Product_Parent_Specification_Id__c;
            level2GrtSpecMap.put(temp5,spec.Id);
        }
        
        for(PMP_Specification_Value__c specv:[Select Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c from PMP_Specification_Value__c])
        {
            speciValMap.put(specv.PMP_Product_Specification_Value_Key__c, specv.id);
            specValActiveIndMap.put(specv.PMP_Product_Specification_Value_Key__c, specv.PMP_Active_Ind__c);
            if(specv.PMP_Product_Specification_Value_Key__c == 'amazonwebservices(aws)'){
              System.debug('specValActiveIndMap**'+specValActiveIndMap);  
            }
            
        }
        
        
        
        //For SpecValues which are already set as inactive , taking them in a map
        for(PMP_Specification_Value__c specv:[Select Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c from PMP_Specification_Value__c where PMP_Spec_Value_Type_Nm__c = :PMP_StaticConstants_MasterData.Other_Spec_Value and PMP_Active_Ind__c = false])
        {
            deactiveSpecValues.add(specv.Id);
            System.debug('deactiveSpecValues ='+deactiveSpecValues);
        }
        
        //to deactivate Spec Spec value association when spec value is inactive
        for(PMP_Specification_Value_Association__c spa :[Select Id,PMP_Active_Ind__c,PMP_Specification_Value_Id__c,PMP_Category_Spec_Value_External_Key__c from PMP_Specification_Value_Association__c where PMP_Specification_Value_Id__c IN :deactiveSpecValues])
        {
            spa.PMP_Active_Ind__c = false;
            uploadSpecSpecVMap.put(spa.PMP_Category_Spec_Value_External_Key__c,spa);
            
        }
        
        //US349982 - to deactivate Spec Spec value association if the association is not there as per latest JSON
        for(PMP_Specification_Value_Association__c ssa : [Select Id,PMP_Active_Ind__c,PMP_Specification_Value_Id__c,PMP_Category_Spec_Value_External_Key__c from PMP_Specification_Value_Association__c where PMP_Specification_Value_Id__r.PMP_Spec_Value_Type_Nm__c = :PMP_StaticConstants_MasterData.Other_Spec_Value] )
        {
            existingEngSpecValuesAscMap.put(ssa.PMP_Category_Spec_Value_External_Key__c,ssa);
        }
        
        
        //Parse the JSON stored as a static resource
        String jsonStr = '';
        if(Test.isRunningTest()){
              
           StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Attributes_Test]; 
          
            jsonStr = srObject.body.toString();
        }
        else
        {
            
           StaticResource srObject = [select id,body from StaticResource Where Name = 'Attributes_English'];
           
            jsonStr = srObject.body.toString();
        }
        string strBaseKey;
        
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        
        for (string theKey:mapSpec.keySet())
        {
            strBaseKey = theKey;
            
            if(mapSpec.size() > 0)        
            {
                List<Object> lstSpec = (List<Object>)mapSpec.get(strBaseKey); 
                
                for(integer i=0;i<lstSpec.size();i++)
                {            
                    
                    Map<String, Object> specMap = (Map<String, Object>)lstSpec[i];
                    
                    if(specMap != null && !specMap.isEmpty())
                    {
                        
                        if(specMap.containsKey(PMP_StaticConstants_MasterData.Features))
                        {
                            
                            List<Object> lstFeature = (List<Object>)specMap.get(PMP_StaticConstants_MasterData.Features);
                            List<String> catsegment = new List<String>();
                            
                            for(integer j=0;j<lstFeature.size();j++)
                            {
                                if(lstFeature !=null)
                                {
                                    Map<String,Object> featureMap = (Map<String, Object>)lstFeature[j];
                                    
                                    if(featureMap != null && !featureMap.isEmpty())
                                    {
                                        List<String> levelValues = new List<String>();
                                        List<String> pimParentSpec = new List<String>();
                                        integer highestlevel = 0;
                                        integer templevel = 0;
                                        
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
                                        //for rest of the levels other than leaf node create specification with respective spec ids having level in id name
                                        
                                        for(integer speclevelIndex=0;speclevelIndex<highestlevel;speclevelIndex++)
                                        {
                                            templevel = speclevelIndex+1;
                                            String specid = String.valueOf(levelvalues[speclevelIndex]);
                                            String skey1 = (specid.deleteWhitespace()+PMP_StaticConstants_MasterData.Level+templevel).toLowerCase();
                                            
                                            String ckey = (String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Identifier))).toLowerCase();
                                            
                                            PMP_Category_Specification_Association__c csa1 = new PMP_Category_Specification_Association__c();
                                            if(catMap.get(ckey) != null && speciPIMMap.get(skey1) != null)
                                            {
                                                csa1.PMP_Category_Id__c = catMap.get(ckey);
                                                csa1.PMP_Specification_Id__c = speciPIMMap.get(skey1);
                                                csa1.Name = String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Name)) + PMP_StaticConstants_MasterData.Colon_Symbol + String.valueOf(levelvalues[speclevelIndex]);
                                                //Based of the Active Indicator for Category/Spec, the association active indicator will have value
                                                if(Boolean.valueOf(catActiveIndMap.get(ckey)) == true && Boolean.valueOf(specActiveIndMap.get(skey1)) == true)
                                                {
                                                    csa1.PMP_Active_Ind__c = true;
                                                }
                                                else{
                                                    csa1.PMP_Active_Ind__c = false;
                                                }
                                                
                                                csa1.PMP_Category_Specification_External_Key__c = (String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Identifier)) + PMP_StaticConstants_MasterData.Pipe_Symbol + (specid.deleteWhitespace()+PMP_StaticConstants_MasterData.Level+templevel)).toLowerCase();
                                                
                                                if(!uploadCatSpecMap.containsKey(csa1.PMP_Category_Specification_External_Key__c))
                                                {
                                                    uploadCatSpecMap.put(csa1.PMP_Category_Specification_External_Key__c,csa1);
                                                }
                                            }
                                            
                                        } 
                                        String skey2 = (String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier))).toLowerCase();
                                        
                                        String ckey = (String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Identifier))).toLowerCase();
                                        
                                        PMP_Category_Specification_Association__c csa2 = new PMP_Category_Specification_Association__c();
                                        if(catMap.get(ckey) != null && speciPIMMap.get(skey2) != null)
                                        {
                                            csa2.PMP_Category_Id__c = catMap.get(ckey);
                                            csa2.PMP_Specification_Id__c = speciPIMMap.get(skey2);
                                            csa2.Name = String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Name)) + PMP_StaticConstants_MasterData.Colon_Symbol + String.valueOf(levelvalues[highestlevel]);
                                            //Based of the Active Indicator for Category/Spec, the association active indicator will have value
                                            if(Boolean.valueOf(catActiveIndMap.get(ckey)) == true && Boolean.valueOf(specActiveIndMap.get(skey2)) == true)
                                            {
                                                csa2.PMP_Active_Ind__c = true;
                                            }
                                            else
                                            {
                                                csa2.PMP_Active_Ind__c = false;
                                            }
                                            csa2.PMP_Category_Specification_External_Key__c = (String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Identifier)) + PMP_StaticConstants_MasterData.Pipe_Symbol + String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier))).toLowerCase();
                                            
                                            if(!uploadCatSpecMap.containsKey(csa2.PMP_Category_Specification_External_Key__c))
                                            {
                                                uploadCatSpecMap.put(csa2.PMP_Category_Specification_External_Key__c,csa2);
                                            }
                                        }
                                        
                                        
                                        //Setting the Offering Spec Values for above specification
                                        if(featureMap.containsKey(PMP_StaticConstants_MasterData.Preset_Values))
                                        {
                                            Map<String, Object> specValueMap = (Map<String, Object>)featureMap.get(PMP_StaticConstants_MasterData.Preset_Values);
                                            
                                            if(specValueMap != null)
                                            {
                                                
                                                if(specValueMap.containsKey(PMP_StaticConstants_MasterData.Identifier) && specValueMap.containsKey(PMP_StaticConstants_MasterData.Values))
                                                {
                                                    //To handle the scenario where the spec value identifier reads as Yes in JSON file
                                                    String identifier;
                                                    String value;
                                                    if(specValueMap.get(PMP_StaticConstants_MasterData.Identifier) == PMP_StaticConstants_MasterData.Yes && specValueMap.get(PMP_StaticConstants_MasterData.Values) ==PMP_StaticConstants_MasterData.Yes)
                                                    {                                                       
                                                        value = String.valueOf(levelvalues[highestlevel]);
                                                        identifier = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier));  
                                                    }
                                                    else
                                                    {
                                                        identifier = String.valueOf(specValueMap.get(PMP_StaticConstants_MasterData.Identifier));
                                                        value = String.valueOf(specValueMap.get(PMP_StaticConstants_MasterData.Values));
                                                        
                                                    }                         
                                                    
                                                    if(identifier.length()>0 && value.length()>0)   
                                                    {               
                                                        String cskey = (String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Identifier))).toLowerCase();
                                                        String spkey = (String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier))).toLowerCase();

                                                        String val1 = identifier.deleteWhitespace();
                                                        if(val1.length()>0)
                                                        {
                                                            String sskey = String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)) + '_' + (identifier.deleteWhitespace()).toLowerCase();
                                                            String mainkey = String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Child_Identifier)).toLowercase() 
                                                                			+ PMP_StaticConstants_MasterData.Pipe_Symbol 
                                                                			+ String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)).toLowerCase() 
                                                                			+ PMP_StaticConstants_MasterData.Pipe_Symbol 
                                                                			+ String.valueOf(featureMap.get(PMP_StaticConstants_MasterData.Spec_Identifier)) + '_' + identifier.deleteWhitespace().toLowerCase();
                                                            
                                                            PMP_Specification_Value_Association__c ssa = new PMP_Specification_Value_Association__c();
                                                            ssa.PMP_Specification_Id__c = speciPIMMap.get(spkey);
                                                            ssa.PMP_Category_Id__c =catMap.get(cskey);
                                                            ssa.PMP_Specification_Value_Id__c = speciValMap.get(sskey);
                                                            ssa.PMP_Category_Spec_Value_External_Key__c = mainkey; 
                                                            ssa.Name = value;
                                                            //US290905
                                                            //Based of the Active Indicator for SpecValue/Spec, the association active indicator will have value
                                                           
                                                            if(specValActiveIndMap.get(sskey) != null && Boolean.valueOf(specValActiveIndMap.get(sskey)) == true && Boolean.valueOf(specActiveIndMap.get(spkey)) == true)
                                                            {
                                                                ssa.PMP_Active_Ind__c = true;
                                                            }
                                                            else
                                                            {
                                                                ssa.PMP_Active_Ind__c = false;
                                                            }
                                                            
                                                            
                                                            if(!uploadSpecSpecVMap.containsKey(mainkey))
                                                            {	
                                                                uploadSpecSpecVMap.put(mainkey,ssa);
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
        
        //to handle deactivation of Spec Values Association
        if ((existingEngSpecValuesAscMap != null || !existingEngSpecValuesAscMap.isEmpty()) && (uploadSpecSpecVMap != null || !uploadSpecSpecVMap.isEmpty()))
        {
            for(String keyId: existingEngSpecValuesAscMap.Keyset())
            {
                //if 2nd map does not have that key
                if(!uploadSpecSpecVMap.keyset().contains(keyId))
                {
                    System.debug('keyId ='+keyId);
                    PMP_Specification_Value_Association__c specValueAsc = existingEngSpecValuesAscMap.get(keyId);
                    specValueAsc.PMP_Active_Ind__c = false;
                    specValuesDeactiveAscMap.put(keyId,specValueAsc);
                    System.debug('specValuesDeactiveAscMap'+specValuesDeactiveAscMap);
                }
                
            }
            if(specValuesDeactiveAscMap != null || !specValuesDeactiveAscMap.isEmpty())
            {
                for(String key : specValuesDeactiveAscMap.keySet())
                {
                    uploadSpecSpecValJO.add(specValuesDeactiveAscMap.get(key));
                    
                } 
            }
        }
        /*Added by raj*/
        if(!existingCatSpecAssocByExternalKey.isEmpty() && !uploadCatSpecMap.isEmpty()){
            for(String keyId : existingCatSpecAssocByExternalKey.keySet()){
                if(!uploadCatSpecMap.keySet().contains(keyId)){
                    PMP_Category_Specification_Association__c csa = existingCatSpecAssocByExternalKey.get(keyId);
                    csa.PMP_Active_Ind__c = false;
                    uploadCatSpecMap.put(csa.PMP_Category_Specification_External_Key__c, csa);
                }
            }
        }
        /*End*/
        for(String key1 : uploadCatSpecMap.keySet())
        {
            uploadCatSpecJO.add(uploadCatSpecMap.get(key1));
        }
        
        for(String key2 : uploadSpecSpecVMap.keySet())
        {	
            uploadSpecSpecValJO.add(uploadSpecSpecVMap.get(key2));
        }       
        if(uploadCatSpecJO.size()>0)
        {
            try
            {
                //upsert uploadCatSpecJO PMP_Category_Specification_External_Key__c;
                Schema.SObjectField upsertSpecJOKey = PMP_Category_Specification_Association__c.Fields.PMP_Category_Specification_External_Key__c;
                upsertResultDataSpecJO = Database.upsert(uploadCatSpecJO,upsertSpecJOKey,false);
            }
            catch(Exception exp1)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_CreateJunctionData_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
        
        if(uploadSpecSpecValJO.size()>0)
        {
            
            try
            {
                //upsert uploadSpecSpecValJO PMP_Category_Spec_Value_External_Key__c;
                Schema.SObjectField upsertSpecValJOKey = PMP_Specification_Value_Association__c.Fields.PMP_Category_Spec_Value_External_Key__c;
                upsertResultDataSpecValueJO = Database.upsert(uploadSpecSpecValJO,upsertSpecValJOKey,false);
            }
            catch(Exception exp2)
            {
                // System.debug(PMP_StaticConstants_MasterData.Core_PMP_CreateJunctionData_Exception_Message+exp2.getMessage());
                throw exp2;
            }
        }
        
        if(upsertResultDataSpecJO.size()>0)
        {
            for(Database.UpsertResult res :upsertResultDataSpecJO)
            {
                upsertResultData.add(res);
            }
        }
        if(upsertResultDataSpecValueJO.size()>0)
        {
            for(Database.UpsertResult res :upsertResultDataSpecValueJO)
            {
                upsertResultData.add(res);
            }
            
            
        }
        
        return upsertResultData;
        
    }
    
}