/****************************************************************************************************************************************
* Class Name  : Core_MDF_ShareRecordToGeoGroup 
* Version     : 1.0   
* Created Date: 14-10-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         14-10-2019                    Created Core_MDF_ShareRecordToGeoGroup for Geo based sharing Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ShareRecordToGeoGrp_New {
    
    /***************************************************************************************************** 
Method Name:        ShareRecordToGeoGroup
@return  :          void
@parameters:        List of Core_MDF_RecordGeoShare
Description:        This method is used to perform Geo Based Sharing for a record
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    
    public static Map<String,List<String>> programGroupMap = new Map<String,List<String>>();
    public static Map<String,List<String>> programGroupMapRO = new Map<String,List<String>>();
    public static Map<String,List<String>> programGroupBudgetTypeMap = new Map<String,List<String>>();
    public static Map<String,List<String>> programGroupBudgetTypeMapRO = new Map<String,List<String>>();
    
    public static void shareRecordToGeoGroup(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = addGroupstoRecordGeoShareLst(objectName,recordGeoShareLst);
        System.debug('updatedRecordGeoShareLst'+updatedRecordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();
        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        if(updatedRecordGeoShareLst != NULL && updatedRecordGeoShareLst.size()>0)
        {
            for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst)
            {
                System.debug('rec::'+rec);
                if(recordGeoShareMap.containsKey(rec.recordId)){
                    recordGeoShareMap.get(rec.recordId).addAll(rec.groupId);
                }
                else{
                    recordGeoShareMap.put(rec.recordId, rec.groupId.clone());
                }
                if(recordGeoShareMapRO.containsKey(rec.recordId)){
                    recordGeoShareMapRO.get(rec.recordId).addAll(rec.groupId_RO);
                }
                else{
                    recordGeoShareMapRO.put(rec.recordId, rec.groupId_RO.clone());
                }
            }    
        }
        System.debug('recordGeoShareMap::'+recordGeoShareMap);
        System.debug('recordGeoShareMapRO::'+recordGeoShareMapRO);
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Edit Access
        if(recordGeoShareMap != NULL && recordGeoShareMap.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Read Access
        if(recordGeoShareMapRO != NULL && recordGeoShareMapRO.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMapRO, 'Read');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInstRead);
        }
    }
    
    /***************************************************************************************************** 
Method Name:        addGroupstoRecordGeoShareLst
@return  :          void
@parameters:        List of Core_MDF_RecordGeoShare
Description:        This method is used to add the corresponding group id's for each record
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static List<Core_MDF_RecordGeoShare> addGroupstoRecordGeoShareLst(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        
        Set<string> programSet = new Set<string>();
        Map<String,String> pgmGeoSubGeoBudgetTypeGrpMap = new Map<String,String>();
        Map<String,String> pgmGeoSubGeoBudgetTypeGrpMapRO = new Map<String,String>();
        //Map to store if a program requires sub geo sharing
        Map<String,Boolean> pgmSubGeoShareReq = new Map<String,Boolean>();
        Set<String> grpNames = new Set<String>();
        Set<String> geoNames = new Set<String>();
        Set<String> budgetTypes = new Set<String>();
        //List to store all the objects that do not require Geo-based sharing
        List<String> objectsForAllGeoSharing = Label.Core_MDF_Objects_for_RO_All_Geo_Sharing.split(';');
        for(Core_MDF_RecordGeoShare shareRec : recordGeoShareLst)
        {
            programSet.add(shareRec.program);
        }
        //to get all the groups of the incoming programs
        for(Core_MDF_ProgramGeoGroupMap__mdt rec:[SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,
                                                  Core_MDF_Sub_Region__c,Core_MDF_Check_SubGeo__c,Core_MDF_Budget_Type_txt__c
                                                  From Core_MDF_ProgramGeoGroupMap__mdt where Core_MDF_Program__c in :programSet])
        {
            //to populate the Sub geo group maps with the group data
            if(rec.Core_MDF_Region__c!=null){
                if(rec.Core_MDF_Check_SubGeo__c)
                {
                    //to populate the geo+subgeo+budgetType group maps with the group data Eg: IPA ASMO LAR SPAI, IPA ASMO LAR SPAI RO
                    //if(rec.Core_MDF_Budget_Type_txt__c!=null)
                   // {
                        pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name__c);
                        pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name_RO__c); 
                        addToProgramBudgetTypeGrpMap(rec);
                        budgetTypes.add(rec.Core_MDF_Budget_Type_txt__c);
                   // }
                   // else
                   // {
                      //  pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name__c);//CCF_ASMO_NAR, ASMO NAR
                      //  pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name_RO__c);    
                   // }
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                    geoNames.add(rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c);
                    pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                }
                //to populate the geo group maps with the group data
                else
                {  
                    //to populate the geo+budgetType group maps with the group data Eg: IPA APJ SPAI, IPA APJ SPAI RO
                   // if(rec.Core_MDF_Budget_Type_txt__c!=null)
                   // {
                        pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name__c);
                        pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name_RO__c); 
                        addToProgramBudgetTypeGrpMap(rec);
                        budgetTypes.add(rec.Core_MDF_Budget_Type_txt__c);
                   // } 
                   // else
                  //  {
                    //    pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name__c); // CCF_APJ, APJ ALL
                    //    pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name_RO__c);// CCF_APJ, APJ ALL RO
                  //  }
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                    pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, false);
                    geoNames.add(rec.Core_MDF_Region__c);
                }
                
            }
            //for groups without geo eg. CCF ALL, DCF ALL
            else
            {
                grpNames.add(rec.Core_MDF_Group_Name__c);
                grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name__c);
                pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name_RO__c);
            }
        } 
        
        for(String key : pgmGeoSubGeoBudgetTypeGrpMap.keySet())
        {
            System.debug('key::'+key+' Value::'+pgmGeoSubGeoBudgetTypeGrpMap.get(key));
        }
        
        //Map to store the GroupName and their corresponding Id.
        Map<string,Id> grpNametoIdMap = new Map<string,Id>();
        for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN :grpNames])
        {
            grpNametoIdMap.put(grp.DeveloperName, grp.Id);
        }
        
        //To Loop thro each incoming record and store the groups that it should be shared with
        for(Core_MDF_RecordGeoShare record: recordGeoShareLst)
        {  
            //to store rw group id's
            List<Id> grpLst = new List<Id>();
            //to store ro group id's
            List<Id> grpLstRO = new List<Id>();
            if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+System.Label.Core_MDF_Underscore+record.geo))
            {
               // if(record.budgetType != null){
                    if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.budgetType))
                    {
                        grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.budgetType)));
                        grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.budgetType)));
                        
                    }
              //  }
              //  else
              //  {
               //     grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo)));
           //         grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.geo)));
               // }
            }
            else if(pgmSubGeoShareReq != null &&  pgmSubGeoShareReq.containsKey(record.geo) && pgmSubGeoShareReq.get(record.geo) 
                    && pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo)) 
            {
               // if(record.budgetType != null){
                    if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo+System.Label.Core_MDF_Underscore+record.budgetType))
                    {
                        grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo+System.Label.Core_MDF_Underscore+record.budgetType)));
                        grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo+System.Label.Core_MDF_Underscore+record.budgetType)));
                        
                    }
                //}
              //  else
              //  {
              //      grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo)));
               //     grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo)));
               // }
            }
            if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program))
            {
                grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program)));
                grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program)));
            }
            
            //In case of objects that need to be shared to all the Geo groups.
            if(objectsForAllGeoSharing.contains(objectName) && !programSet.contains(Label.Core_MDF_Retail_Channel_Program_Name) && !programSet.contains(Label.Core_MDF_IPA_Program_Name))
            {
                for(String grpNm : pgmGeoSubGeoBudgetTypeGrpMap.values())
                {
                    grpLst.add(grpNametoIdMap.get(grpNm));
                }
                for(String grpNmRO : pgmGeoSubGeoBudgetTypeGrpMapRO.values())
                {
                    grpLstRO.add(grpNametoIdMap.get(grpNmRO));
                }
            }  
            //In case of objects that need to be shared to all the Geo groups.
            if(objectsForAllGeoSharing.contains(objectName) && programSet.contains(Label.Core_MDF_IPA_Program_Name))
            {
                for(List<String> groupNames: programGroupBudgetTypeMap.values()) {
                    if(record.budgetType!=null)
                    {
                        for(String grpNameBudgetType : programGroupBudgetTypeMap.get(record.program+System.Label.Core_MDF_Underscore+record.budgetType))
                        {
                            grpLst.add(grpNametoIdMap.get(grpNameBudgetType));
                        }
                    }
                    else
                    {
                        for(String budgetType : budgetTypes)
                        {
                            for(String grpName : programGroupBudgetTypeMap.get(record.program+System.Label.Core_MDF_Underscore+budgetType))
                            {
                                grpLst.add(grpNametoIdMap.get(grpName));
                            }
                        } 
                    }
                    
                }
                
                for(List<String> groupNamesRO: programGroupBudgetTypeMapRO.values()) {
                    if(record.budgetType!=null)
                    {
                        for(String grpNameROBudgetType : programGroupBudgetTypeMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.budgetType))
                        {
                            grpLstRO.add(grpNametoIdMap.get(grpNameROBudgetType));
                        }
                    }
                    else
                    {
                        for(String budgetType : budgetTypes)
                        {
                            for(String grpNameRO : programGroupBudgetTypeMapRO.get(record.program+System.Label.Core_MDF_Underscore+budgetType))
                            {
                                grpLstRO.add(grpNametoIdMap.get(grpNameRO));
                            }
                        } 
                    }
                    
                }
                for(String geo : geoNames)
                {
                    grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+System.Label.Core_MDF_Underscore+geo)));
                    grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+geo)));
                }
                
            }
            
            //assigning the group lists to the record
            record.groupId = grpLst;
            record.groupId_RO = grpLstRO;
            for(Id grpId : grpLst)
            {
                System.debug('grpId::'+grpId);
            }
            for(Id grpIdRO : grpLstRO)
            {
                System.debug('grpIdRO::'+grpIdRO);
            }
        }
        return recordGeoShareLst;
    }
    /***************************************************************************************************** 
Method Name:        addToProgramGrpMap
@return  :          void
@parameters:        Record of Core_MDF_ProgramGeoGroupMap__mdt
Description:        This method is used to add all the Program specific groups for each record.
To be used in case of objects that need to be shared to all the Geo group
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    public static void addToProgramBudgetTypeGrpMap(Core_MDF_ProgramGeoGroupMap__mdt rec)
    {
        if(programGroupBudgetTypeMap.containsKey(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c)){
            programGroupBudgetTypeMap.get(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c).add(rec.Core_MDF_Group_Name__c);
        }
        else{
            programGroupBudgetTypeMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c, new List<String>{rec.Core_MDF_Group_Name__c});
        }
        if(programGroupBudgetTypeMapRO.containsKey(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c)){
            programGroupBudgetTypeMapRO.get(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c).add(rec.Core_MDF_Group_Name_RO__c);
        }
        else{
            programGroupBudgetTypeMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Budget_Type_txt__c, new List<String>{rec.Core_MDF_Group_Name_RO__c});
        }
        
    }
}