/****************************************************************************************************************
* Class Name  :   
* Version     : 1.0 
* Created Date: 6th June,2019
* Modification Log :
* Developer                                      Date                    Description
* --------------------------------------------------------------------------------------------------------------
* Manasa                               06/06/2019               Created for Parsing the Specification 
*                                                                        JSON 
*****************************************************************************************************************/
public class  PMP_IntelTech_CreateJunctionData {
	public static List<Database.UpsertResult> PMP_Inteltech_CreateJunctionDataMet()
    {
        
        //Variable Declaration
        final String IntelTech_Attribute_English = 'Intel_Technology_Attribute_English';//static resource name
        Map<String,Id> catMap = new Map<String,Id>();
        Map<String,Id> speciPIMMap = new Map<String,Id>();
        Map<String,Id> speciValMap = new Map<String,Id>();
        Map<Id,String> catNameMap = new Map<Id,String>();
        Map<Id,String> catPIMMap = new Map<Id,String>();
        Set<Id> category_assoc_IntelTech = new Set<Id>();
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
            
        //To fetch the PIM Spec Id for specification called NPP_IntelTechnologies
       PMP_Specification__c IntelTech_Specification = [Select Id,PMP_Partner_Product_Specification_Id__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c = :PMP_StaticConstants_MasterData.IntelTech_PIMId];
       String IntelTech_Specification_PIMId;
  		/*Added by raj on 02/28*/
        Map<String, PMP_Category_Specification_Association__c> existingCatSpecAssocByExternalKey = new Map<String, PMP_Category_Specification_Association__c>();
        Map<String, PMP_Specification_Value_Association__c> existingSpecSpecValueAssocByExternalKey = new Map<String, PMP_Specification_Value_Association__c>();
        for(PMP_Category_Specification_Association__c catSpecAssoc : [SELECT Id,Name,PMP_Active_Ind__c, PMP_Category_Specification_External_Key__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__r.PMP_Specification_Type_Nm__c = 'Technology']){
            existingCatSpecAssocByExternalKey.put(catSpecAssoc.PMP_Category_Specification_External_Key__c, catSpecAssoc); 
        }
        for(PMP_Specification_Value_Association__c specSpecValueAssoc : [select id, PMP_Active_Ind__c, PMP_Category_Spec_Value_External_Key__c from PMP_Specification_Value_Association__c where PMP_Specification_Value_Id__r.PMP_Spec_Value_Type_Nm__c = 'Technology']){
            existingSpecSpecValueAssocByExternalKey.put(specSpecValueAssoc.PMP_Category_Spec_Value_External_Key__c, specSpecValueAssoc);
        }
        /*End*/
       System.debug('IntelTech_Specification ='+IntelTech_Specification);
       //If the spec object is not null
       if(IntelTech_Specification != null)
        {
              IntelTech_Specification_PIMId = IntelTech_Specification.PMP_Partner_Product_Specification_Id__c;
            //Query - Get the list of category specification association object 
            List<PMP_Category_Specification_Association__c> category_associated = [SELECT PMP_Category_Id__c FROM PMP_Category_Specification_Association__c WHERE PMP_Specification_Id__c = :IntelTech_Specification.Id AND PMP_Active_Ind__c = true];
            System.debug('category_associated ='+category_associated);
            //Iterate on list of category specification association object 
               for(PMP_Category_Specification_Association__c csa : category_associated )
            {
                //Add into the Set category_assoc_IntelTech with the category ID
                category_assoc_IntelTech.add(csa.PMP_Category_Id__c);
              
            }
        
        }
        //Fetch the Category ids into a map for reference 
        for(PMP_Category__c cat:[Select Id,PMP_Active_Ind__c,PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Category_Key__c,Name from PMP_Category__c where id in :category_assoc_IntelTech])
        {
            //Adding category Key and Cat ID in CatMap
            catMap.put(cat.PMP_Partner_Product_Category_Key__c,cat.Id);
            //Adding Cat id , Cat name in catNameMap
            catNameMap.put(cat.Id,cat.Name);
            //Adding cat id, product cat id in catPIMMap
            catPIMMap.put(cat.Id,cat.PMP_Partner_Product_Category_Cd__c);
            //Adding cat id , active indicator in CatActiveMap
            CatActiveMap.put(cat.Id,cat.PMP_Active_Ind__c);
        }
        
        //Fetch the Specification ids into a map for reference, where parent / ancestorr ID contains "NPP_IntelTechnologies"
		//Added by Manasa - US439814
        for(PMP_Specification__c spec:[Select Name,PMP_Specification_Name__c,PMP_Active_Ind__c,Id,PMP_Partner_Product_Specification_Id__c,PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Ancestor_Specification_Cd__c like '%NPP_IntelTechnologies%' OR PMP_Partner_Product_Specification_Id__c = :PMP_StaticConstants_MasterData.IntelTech_PIMId])
        {
            //Adding spec key, spec id in speciPIMMap
            speciPIMMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec.Id);
            //Adding spec key, active indiactor in SpecActiveMap
            SpecActiveMap.put(spec.PMP_Partner_Product_Specification_Key__c,spec.PMP_Active_Ind__c);
            System.debug('speciPIMMap'+speciPIMMap);
        }

        //Fetch the Spec values into a map for reference
        for(PMP_Specification_Value__c specv:[Select Id,Name,PMP_Active_Ind__c,PMP_Product_Specification_Value_Key__c,PMP_Product_Specification_Value_Cd__c from PMP_Specification_Value__c])
        {
            //Adding  spec value key, spec value id into speciValMap
           speciValMap.put(specv.PMP_Product_Specification_Value_Key__c,specv.id);
            //Adding spec value key, active indicator into SpecValActiveMap
           SpecValActiveMap.put(specv.PMP_Product_Specification_Value_Key__c,specv.PMP_Active_Ind__c);
            System.debug('speciValMap'+speciValMap);
        }       
        
        //Parse the JSON stored as a static resource
        String jsonStr ='';
        string strBaseKey;
        
        //Store the IntelTech JSON file in Static Resource and access it as a String
        if(Test.isRunningTest())
        {
            //This static resource file is used for test class
           StaticResource srObject = [select id,body from StaticResource Where Name = :PMP_StaticConstants_MasterData.Intel_Technology_Attribute_English_Test];
          //Convert the file body into string
            jsonStr = srObject.body.toString(); 
        }
        else
        {
           //This is the static resource file, which we get form Custom metadata object record
          StaticResource srObject = [select id,body from StaticResource Where Name = :IntelTech_Attribute_English];
           //Convert the file body into string
            jsonStr = srObject.body.toString(); 
        }
        //Storing the desearialization of static resource into a MAP
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        /*Added by Manasa to get the leaf node level for the uploaded file - Start*/
            Integer leafLevel = PMP_Utility.getLeafNode(mapSpec);
        /*----------------------------END-----------------------------------------*/
        for (string theKey:mapSpec.keySet())
        {
            //Storing the language key in strBaseKey variable to getting diffrent language based files
            strBaseKey = theKey;
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
                            System.debug('**Line 133 test class'+lstChildCategories);
                            //Iterate on lstChildCategories based on the length
                            for(integer specIndex=0;specIndex<lstChildCategories.size();specIndex++)
                            {
                                //Assign the list of object based on Index to the map specOrSpecValMap
                                Map<String, Object> specOrSpecValMap = (Map<String, Object>)lstChildCategories[specIndex];
                                System.debug('**Line138 test class'+specOrSpecValMap);
                                //If the map contains Level and the Level not equal to Level '5'/ 'leaf' node
                                if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) != leafLevel)
                                {
                                    
                                    // If level value is not 'leaf' then create category specification association record
                                    for(Id categoryId : category_assoc_IntelTech)
                                    {
                                       PMP_Category_Specification_Association__c csa = new PMP_Category_Specification_Association__c();
                                        //if category id not null
                                       if(catPIMMap.get(categoryId) != null)
                                       {
                                           //Assign spec external key with catid , specraw value
                                          csa.PMP_Category_Specification_External_Key__c = String.valueOf(catPIMMap.get(categoryId) + PMP_StaticConstants_MasterData.Pipe_Symbol + specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).toLowerCase(); 
                                       }
                                       
                                        //Assign cat id of category spec association with cat id
                                       csa.PMP_Category_Id__c = categoryId;
                                        //Assign cat name of category spec association with cat id, spec display value
                                       csa.Name = catNameMap.get(categoryId) + PMP_StaticConstants_MasterData.Colon_Symbol + specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue);
                 
       								    //If spec raw value not equals null
       								    System.debug('160 for testclass'+specOrSpecValMap);
                                        if(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue) != null && speciPIMMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase()) != null)
                                        {
                                            System.debug('inside 133 line');
                                            //Assign spec id with spec raw value
                                          csa.PMP_Specification_Id__c = speciPIMMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());  
                                           //if the category spec assosicated is active or is "YES"
                                            if(Boolean.valueOf(catActiveMap.get(categoryId)) == true && Boolean.valueOf(SpecActiveMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase())) == true){
                                               //assign active indicator as TRUE
                                                csa.PMP_Active_Ind__c = true;
                                            }
                                            else
                                            {
                                                //assign active indicator as FALSE
                                                csa.PMP_Active_Ind__c = false; 
                                            }
                                        }  
                                        System.debug('176 for testclass'+uploadCatSpecMap.containsKey(csa.PMP_Category_Specification_External_Key__c));
                                        System.debug('177 for testclass'+csa.PMP_Category_Specification_External_Key__c);
                                        System.debug('178 for testclass'+csa.PMP_Category_Id__c);
                                        System.debug('179 for testclass'+csa.PMP_Specification_Id__c);
                                        //if spec external key, spec id, cat id not equals null
                                        if(!uploadCatSpecMap.containsKey(csa.PMP_Category_Specification_External_Key__c) && csa.PMP_Category_Specification_External_Key__c != null && csa.PMP_Category_Id__c!= null && csa.PMP_Specification_Id__c != null)
                                        {
                                            uploadCatSpecMap.put(csa.PMP_Category_Specification_External_Key__c,csa);
                                        }
                                    }                                           
                                    
                                }
                                //If the map contains Level and the Level equal to Level '2'/ 'leaf' node
                                else
                                {
                                    
                                    if(specMap.containsKey(PMP_StaticConstants_MasterData.Level) && specMap.get(PMP_StaticConstants_MasterData.Level) == leafLevel)
                                    {
                                        // If level value is 'leaf' then create Spec and specification value association record
                                       for(Id categoryId : category_assoc_IntelTech)
                                        {
                                            //Create new spec value association
                                           PMP_Specification_Value_Association__c ssa = new PMP_Specification_Value_Association__c();
                                           
                                            //ParentIdentifier not quals null
                                            System.debug('201 for testclass'+specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier));
                                            System.debug('202 for testclass'+speciPIMMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier))));
                                            if(speciPIMMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase()) != null)
                                            {
                                                //assign spec id with ParentIdentifier
                                                
                                              ssa.PMP_Specification_Id__c = speciPIMMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase());
                                                System.debug('207 for testclass'+ssa.PMP_Specification_Id__c);
                                               
                                            }
                                           //Assign pec value association cat id with cat id
                                           ssa.PMP_Category_Id__c = categoryId;
                                           //If spec raw value not equal null
                                           if(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue) != null && speciValMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase()) != null)
                                           {
                                               //Assign spec value id with spec raw value
                                              ssa.PMP_Specification_Value_Id__c = speciValMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase());
              
                                           }
                                            //If cat id not equal null
                                            if(catPIMMap.get(categoryId) != null)
                                           {
                                               //assign spec value external key with cat id, parentidentifier, raw value
                                               ssa.PMP_Category_Spec_Value_External_Key__c = String.valueOf(catPIMMap.get(categoryId) + PMP_StaticConstants_MasterData.Pipe_Symbol + specOrSpecValMap.get(PMP_StaticConstants_MasterData.ParentIdentifier) + '|' + specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).toLowerCase(); 
                                           }
                                            //declare name string and assign with spec display value
                                           String Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue));
                                            //If name string is not null, length greater than "80"
                                            if(Name != null && Name.length()>80)
                                            {
                                               Name =  Name.substring(0,80);
                                                //Assign spec spec value association with substring name 
                                               ssa.Name = Name;
                                            }
                                            //If name string is null, length less than "80"
                                            else
                                            {
                                                //Assign spec spec value association with spec display value
                                               ssa.Name = String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecDisplayValue)); 
                                            }
                                             //If parentIdentifier , spec value not null
                                            if(Boolean.valueOf(catActiveMap.get(categoryId)) == true && SpecActiveMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase()) != null && specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue) != null && SpecValActiveMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase()) != null && Boolean.valueOf(SpecActiveMap.get(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.ParentIdentifier)).deleteWhiteSpace().toLowerCase())) == true && Boolean.valueOf(SpecValActiveMap.get(String.valueOf(specOrSpecValMap.get(PMP_StaticConstants_MasterData.SpecRawValue)).deleteWhiteSpace().toLowerCase())) == true)
                                            {
                                                //Assign active indicator TRUE
                                                ssa.PMP_Active_Ind__c = true;
                                            }
                                           //If parentIdentifier , spec value null
                                            else
                                            {
                                                //Assign active indicator FALSE
                                                ssa.PMP_Active_Ind__c = false;
                                            }
                                            
          									//If spec value external key , spec id , spec value id not null
          									system.debug('specId256---->'+ssa.PMP_Specification_Id__c);
                                            system.debug('specVId257---->'+ssa.PMP_Specification_Value_Id__c);
                                            system.debug('specsepcVmap'+ssa.PMP_Category_Spec_Value_External_Key__c);
                                            if(!uploadSpecSpecVMap.containsKey(ssa.PMP_Category_Spec_Value_External_Key__c) && ssa.PMP_Category_Spec_Value_External_Key__c!= null && ssa.PMP_Specification_Id__c!= null && ssa.PMP_Specification_Value_Id__c != null)
                                            {
                                                
                                                //Put spec ecternal key, spec spec value association object into a MAP
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
        System.debug('**uploadCatSpecMap**'+uploadCatSpecMap);
        //Iterate on Categories spec assocoation map's Key
        for(String key1 : uploadCatSpecMap.keySet())
        {
            //Add all the key's in Category and spec Juntion Object list
            uploadCatSpecJO.add(uploadCatSpecMap.get(key1));
        }
        //Iterate on Spec spec value assocoation map's Key
        for(String key2 : uploadSpecSpecVMap.keySet())
        {
            //if Spe and spec value Juntion Object list size is less than "9000"
            if(uploadSpecSpecValJO.size()<9000)
            {
                //Add all the key's in Spe and spec value Juntion Object list
               uploadSpecSpecValJO.add(uploadSpecSpecVMap.get(key2)); 
            }
            //if Spe and spec value Juntion Object list size is greater than "9000"
            else
            {
                //Serialize Spec Spec value Juntion object and storing in a string variable
                String uploadRecJSON = JSON.serialize(uploadSpecSpecValJO);
                //Call Core_PMP_UploadExcessSpecSpecValueAssRec method - passing the string variable as parameter 
                PMP_IntelTech_CreateJunctionData.Core_PMP_UploadExcessSpecSpecValueAssRec(uploadRecJSON);
                //Clear all the Spec Spec value list values
                uploadSpecSpecValJO.clear();
                
            }
            
        }
        //Spec Spec Value Juntion object not null/empty
        if(uploadSpecSpecValJO.size()>0)
        {
            //Serialize Spec Spec value Juntion object and storing in a string variable
            String uploadRecJSON = JSON.serialize(uploadSpecSpecValJO);
            //Call Core_PMP_UploadExcessSpecSpecValueAssRec method - passing the string variable as parameter 
            PMP_IntelTech_CreateJunctionData.Core_PMP_UploadExcessSpecSpecValueAssRec(uploadRecJSON);
        }
        //Cat Spec Value Juntion object not null/empty
        if(uploadCatSpecJO.size()>0)
        {
           try
           {
               //upsert uploadCatSpecJO PMP_Category_Specification_External_Key__c;
                Schema.SObjectField upsertSpecJOKey = PMP_Category_Specification_Association__c.Fields.PMP_Category_Specification_External_Key__c;
               //DML - upsert Cat spec JO 
                upsertResultData_SpecJO = Database.upsert(uploadCatSpecJO,upsertSpecJOKey,false);
           }
            catch(Exception exp1)
            {
                
                throw exp1;
            }
        }
      //Return Cat Spec JO  
     return  upsertResultData_SpecJO;  
}
    // Future Method written to handle Governor Limits for DML on more than 10K records
    @future
    public static void Core_PMP_UploadExcessSpecSpecValueAssRec(String uploadRecsJSON)
    {
        List<PMP_Specification_Value_Association__c> uploadSpecSpecValJO = new List<PMP_Specification_Value_Association__c>();
        uploadSpecSpecValJO = (List<PMP_Specification_Value_Association__c>)JSON.deserialize(uploadRecsJSON, List<PMP_Specification_Value_Association__c>.class);
        
        if(uploadSpecSpecValJO.size()>0)
        {
           try
           {
               upsert uploadSpecSpecValJO PMP_Category_Spec_Value_External_Key__c;
                
           }
            catch(Exception exp3)
            {
                
                throw exp3;
            }
        }
       
    }
}