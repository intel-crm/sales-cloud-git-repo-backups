/****************************************************************************************************************
* Class Name  :   PMP_Processor_CreateJunctionData
* Version     : 1.0 
* Created Date: 2nd Jan,2019
* Modification Log :
* Developer                                      Date                    Description
* --------------------------------------------------------------------------------------------------------------
* Sangeetha Ganta                               02/01/2019               Created for Parsing the Specification 
*                                                                        JSON and creating Specification and 
*                                                                        Specification Value junction records.
* Infosys - Sangeetha Ganta                     02/28/2019               User story - US290905. Active/Deactivate
*                                                                        Spec Value Association
*****************************************************************************************************************/

public class PMP_Processor_CreateJunctionData 
{

    public static List<Database.UpsertResult> PMP_Processor_CreateJunctionDataMet()
    {
        
        //Variable Declaration
        final String Processors_Attribute_English = 'Processors_Attribute_English';
        Map<String,Id> catMap = new Map<String,Id>();
        Map<String,Id> speciPIMMap = new Map<String,Id>();
        Map<String,Id> speciValMap = new Map<String,Id>();
        Map<Id,String> catNameMap = new Map<Id,String>();
        Map<Id,String> catPIMMap = new Map<Id,String>();
        Set<Id> category_assoc_Processors = new Set<Id>();
        Map<String,Boolean> SpecValActiveMap = new Map<String,Boolean>();
        Map<String,Boolean> SpecActiveMap = new Map<String,Boolean>();
        Map<String,Boolean> CatActiveMap = new Map<String,Boolean>();
        Map<String,PMP_Category_Specification_Association__c> uploadCatSpecMap = new Map<String,PMP_Category_Specification_Association__c>();
        Map<String,PMP_Specification_Value_Association__c> uploadSpecSpecVMap = new Map<String,PMP_Specification_Value_Association__c>();
        Map<String,PMP_Specification_Value_Association__c> uploadSpecSpecVMap1 = new Map<String,PMP_Specification_Value_Association__c>();
        List<PMP_Category_Specification_Association__c> uploadCatSpecJO = new List<PMP_Category_Specification_Association__c>();
        List<PMP_Specification_Value_Association__c> uploadSpecSpecValJO = new List<PMP_Specification_Value_Association__c>();
        
        Set<String> uploadSpecSpecValKeys = new Set<String>();
        
        List<Database.UpsertResult> upsertResultData_SpecJO = new List<Database.UpsertResult>();//final upsert records (success and failure)
            
        //To fetch the PIM Spec Id for specification called Processor
       PMP_Specification__c Processors_Specification = [Select Id,PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c = :PMP_StaticConstants_MasterData.Processor_PIMId];
       String Processors_Specification_PIMId;
  
      // System.debug('Processors_Specification ='+Processors_Specification);
       if(Processors_Specification != null)
        {
              Processors_Specification_PIMId = Processors_Specification.PMP_Partner_Product_Specification_Id__c;
            //raj modified here on 02/28
            List<PMP_Category_Specification_Association__c> category_associated = [SELECT PMP_Category_Id__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__c = :Processors_Specification.Id and PMP_Active_Ind__c = true];
           // System.debug('category_associated ='+category_associated);
               for(PMP_Category_Specification_Association__c csa : category_associated )
            {
                category_assoc_Processors.add(csa.PMP_Category_Id__c);
              
            }
        
        }
        /*Added by raj on 02/28*/
        Map<String, PMP_Category_Specification_Association__c> existingCatSpecAssocByExternalKey = new Map<String, PMP_Category_Specification_Association__c>();
        Map<String, PMP_Specification_Value_Association__c> existingSpecSpecValueAssocByExternalKey = new Map<String, PMP_Specification_Value_Association__c>();
        for(PMP_Category_Specification_Association__c catSpecAssoc : [SELECT Id,Name,PMP_Active_Ind__c, PMP_Category_Specification_External_Key__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__r.PMP_Specification_Type_Nm__c = 'Processor']){
           	existingCatSpecAssocByExternalKey.put(catSpecAssoc.PMP_Category_Specification_External_Key__c, catSpecAssoc); 
        }
        for(PMP_Specification_Value_Association__c specSpecValueAssoc : [select id, PMP_Active_Ind__c, PMP_Category_Spec_Value_External_Key__c from PMP_Specification_Value_Association__c where PMP_Specification_Value_Id__r.PMP_Spec_Value_Type_Nm__c = 'Processor']){
            existingSpecSpecValueAssocByExternalKey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
        }
        /*End*/
        //Fetch the Category ids into a map for reference
        for(PMP_Category__c cat:[Select Id,PMP_Active_Ind__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c,Name from PMP_Category__c where id in :category_assoc_Processors])
        {
            catMap.put(cat.PMP_Partner_Product_Category_Key__c,cat.Id);//not used anywhere
            catNameMap.put(cat.Id,cat.Name);
            catPIMMap.put(cat.Id,cat.PMP_Partner_Product_Category_Cd__c);
            CatActiveMap.put(cat.Id,cat.PMP_Active_Ind__c);
        }
        
        //Fetch the Specification ids into a map for reference
        //Added by Manasa - US439814
        for(PMP_Specification__c spec:[Select Name,PMP_Specification_Name__c,PMP_Active_Ind__c,Id,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Ancestor_Specification_Cd__c like '%NPP_Processors%' OR PMP_Partner_Product_Specification_Id__c = :PMP_StaticConstants_MasterData.Processor_PIMId])
        {
            
            speciPIMMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec.Id);
            SpecActiveMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec.PMP_Active_Ind__c);
           // System.debug('speciPIMMap'+speciPIMMap);
        }

        
        for(PMP_Specification_Value__c specv:[Select Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c from PMP_Specification_Value__c])
        {
           speciValMap.put(specv.PMP_Product_Specification_Value_Key__c,specv.id);
           SpecValActiveMap.put(specv.PMP_Product_Specification_Value_Key__c,specv.PMP_Active_Ind__c);
           // System.debug('speciValMap'+speciValMap);
        }       
        
        //Parse the JSON stored as a static resource
        String jsonStr ='';
        string strBaseKey;
        
        //Store the Processors JSON file in Static Resource and access it as a String
        if(Test.isRunningTest())
        {
           StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Processors_Attribute_Test];
           jsonStr = srObject.body.toString(); 
        }
        else
        {
          StaticResource srObject = [select id,body from StaticResource Where Name = :Processors_Attribute_English];
          jsonStr = srObject.body.toString(); 
        }
        
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        /*Added by Manasa to get the leaf node level for the uploaded file - Start*/
            Integer leafLevel = PMP_Utility.getLeafNode(mapSpec);
        /*----------------------------END-----------------------------------------*/
        for (string theKey:mapSpec.keySet())
        {
            strBaseKey = theKey;
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
                                    
                                    // If level value is not 'leaf' then create category specification association record
                                    for(Id categoryId : category_assoc_Processors)
                                    {
                                       PMP_Category_Specification_Association__c csa = new PMP_Category_Specification_Association__c();
                                       if(catPIMMap.get(categoryId) != null)
                                       {
                                          csa.PMP_Category_Specification_External_Key__c = String.valueOf(catPIMMap.get(categoryId) + PMP_StaticConstants_MasterData.Pipe_Symbol + specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).toLowerCase(); 
                                       }
                                       
                                       csa.PMP_Category_Id__c = categoryId;
                                       csa.Name = catNameMap.get(categoryId) + PMP_StaticConstants_MasterData.Colon_Symbol + specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue);
                                       
                                        if(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue) != null && speciPIMMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase()) != null)
                                        {
                                          csa.PMP_Specification_Id__c = speciPIMMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());  
                                           //US290905
                                            if(Boolean.valueOf(catActiveMap.get(categoryId)) == true && Boolean.valueOf(SpecActiveMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase())) == true){
                                                csa.PMP_Active_Ind__c = true;
                                            }
                                            else
                                            {
                                                csa.PMP_Active_Ind__c = false;
                                            }
                                        }
                                       
                                        if(!uploadCatSpecMap.containsKey(csa.PMP_Category_Specification_External_Key__c) && csa.PMP_Category_Specification_External_Key__c != null && csa.PMP_Category_Id__c!= null && csa.PMP_Specification_Id__c != null)
                                        {
                                            uploadCatSpecMap.put(csa.PMP_Category_Specification_External_Key__c,csa);
                                        }
                                    }                                           
                                    
                                }
                                else
                                {
                                    // If level value is 'leaf' then create Spec and specification value association record
                                    if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) == leafLevel)
                                    {
                                       for(Id categoryId : category_assoc_Processors)
                                        {
                                           PMP_Specification_Value_Association__c ssa = new PMP_Specification_Value_Association__c();
                                           
                                            if(speciPIMMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase()) != null)
                                            {
                                              ssa.PMP_Specification_Id__c = speciPIMMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase()); 
                                               
                                            }
                                           
                                           ssa.PMP_Category_Id__c = categoryId;
                                           
                                           if(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue) != null && speciValMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase()) != null)
                                           {
                                              ssa.PMP_Specification_Value_Id__c = speciValMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
              
                                           }
                                            if(catPIMMap.get(categoryId) != null)
                                           {
                                               ssa.PMP_Category_Spec_Value_External_Key__c = String.valueOf(catPIMMap.get(categoryId) + PMP_StaticConstants_MasterData.Pipe_Symbol + specOrSpecValMap.get(PMP_StaticConstants_MasterData.ParentIdentifier) + '|' + specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).toLowerCase(); 
                                           }
                                           String Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                            if(Name != null && Name.length()>80)
                                            {
                                               Name =  Name.substring(0,80);
                                               ssa.Name = Name;
                                            }
                                            else
                                            {
                                               ssa.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                            }
                                             //US290905
                                            if(Boolean.valueOf(catActiveMap.get(categoryId)) == true && SpecActiveMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase()) != null && specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue) != null && SpecValActiveMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase()) != null && Boolean.valueOf(SpecActiveMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase())) == true && Boolean.valueOf(SpecValActiveMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase())) == true)
                                            {
                                                ssa.PMP_Active_Ind__c = true;
                                            }
                                            else
                                            {
                                                ssa.PMP_Active_Ind__c = false;
                                            }
                      
          
                                            if(!uploadSpecSpecVMap.containsKey(ssa.PMP_Category_Spec_Value_External_Key__c) && ssa.PMP_Category_Spec_Value_External_Key__c!= null && ssa.PMP_Specification_Id__c!= null && ssa.PMP_Specification_Value_Id__c != null)
                                            {
                                                
                                                
                                                  uploadSpecSpecVMap.put(ssa.PMP_Category_Spec_Value_External_Key__c,ssa);   
                                                   
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
        /*Added by raj on 02/28*/
        if(!existingCatSpecAssocByExternalKey.isEmpty() && !uploadCatSpecMap.isEmpty()){
       		for(String keyId : existingCatSpecAssocByExternalKey.keySet()){
                if(!uploadCatSpecMap.keySet().contains(keyId)){
                    PMP_Category_Specification_Association__c csa = existingCatSpecAssocByExternalKey.get(keyId);
                    csa.PMP_Active_Ind__c = false;
                    uploadCatSpecMap.put(csa.PMP_Category_Specification_External_Key__c, csa);
                }
            }
        }
        if(!existingSpecSpecValueAssocByExternalKey.isEmpty() && !uploadSpecSpecVMap.isEmpty()){
            for(String keyId : existingSpecSpecValueAssocByExternalKey.keySet()){
                if(!uploadSpecSpecVMap.keySet().contains(keyId)){
                    PMP_Specification_Value_Association__c specSpecValueAssoc = existingSpecSpecValueAssocByExternalKey.get(keyId);
                    specSpecValueAssoc.PMP_Active_Ind__c = false;
                    uploadSpecSpecVMap.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
                }    
            }    
        }
        /*End*/
        for(String key1 : uploadCatSpecMap.keySet())
        {
            uploadCatSpecJO.add(uploadCatSpecMap.get(key1));
        }
        System.debug('uploadSpecSpecValJO size 229-->'+uploadSpecSpecVMap.size());
        for(String key2 : uploadSpecSpecVMap.keySet())
        {
            if(uploadSpecSpecValJO.size()<9000)
            {
               uploadSpecSpecValJO.add(uploadSpecSpecVMap.get(key2)); 
            }
            else
            {
                String uploadRecJSON = JSON.serialize(uploadSpecSpecValJO);
                PMP_Processor_CreateJunctionData.Core_PMP_UploadExcessSpecSpecValueAssRec(uploadRecJSON);
                uploadSpecSpecValJO.clear();
                
            }
            
        }
        if(uploadSpecSpecValJO.size()>0)
        {
            String uploadRecJSON = JSON.serialize(uploadSpecSpecValJO);
            PMP_Processor_CreateJunctionData.Core_PMP_UploadExcessSpecSpecValueAssRec(uploadRecJSON);
        }
        System.debug('uploadCatSpecJO 250-->'+uploadCatSpecJO.size());
        if(uploadCatSpecJO.size()>0)
        {
           try
           {
               //upsert uploadCatSpecJO PMP_Category_Specification_External_Key__c;
                Schema.SObjectField upsertSpecJOKey = PMP_Category_Specification_Association__c.Fields.PMP_Category_Specification_External_Key__c;
                upsertResultData_SpecJO = Database.upsert(uploadCatSpecJO,upsertSpecJOKey,false);
           }
            catch(Exception exp1)
            {
                //System.debug(PMP_StaticConstants_MasterData.Core_PMP_Processor_CreateJunctionData_Exception_Message+exp1.getMessage());
                throw exp1;
            }
        }
        System.debug('upsertResultData_SpecJO 265-->'+upsertResultData_SpecJO.size());
     return  upsertResultData_SpecJO;  
}
    // Future Method written to handle Governor Limits for DML on more than 10K records
    @future
    public static void Core_PMP_UploadExcessSpecSpecValueAssRec(String uploadRecsJSON)
    {
        List<PMP_Specification_Value_Association__c> uploadSpecSpecValJO = new List<PMP_Specification_Value_Association__c>();
        uploadSpecSpecValJO = (List<PMP_Specification_Value_Association__c>)JSON.deserialize(uploadRecsJSON, List<PMP_Specification_Value_Association__c>.class);
        System.debug('uploadSpecSpecValJO 274 -->'+uploadSpecSpecValJO.size());
        if(uploadSpecSpecValJO.size()>0)
        {
           try
           {
               upsert uploadSpecSpecValJO PMP_Category_Spec_Value_External_Key__c;
                
           }
            
            catch(Exception exp3)
            {
                System.debug(PMP_StaticConstants_MasterData.Core_PMP_Processor_CreateJunctionData_Exception_Message+exp3.getMessage());
                throw exp3;
            }
        }
       
    }
     
}