/****************************************************************************************************************************************
* Class Name  : Core_MDF_ShareRecordToGeoGroup 
* Version     : 1.0   
* Created Date: 14-10-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         14-10-2019                    Created Core_MDF_ShareRecordToGeoGroup for Geo based sharing Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ShareRecordToGeoGroup {
    
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
    
    public static void shareRecordToGeoGroup(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = addGroupstoRecordGeoShareLst(objectName,recordGeoShareLst);
        System.debug('updatedRecordGeoShareLst'+updatedRecordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();
        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst)
        {
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
        
        //Map to store the Progam+Geo and their corresponding group.
        Map<String,String> pgmGeoGrpMap = new Map<String,String>();
        //Map to store the Progam+Geo+SubGeo and their corresponding group.
        Map<String,String> pgmSubGeoGrpMap = new Map<String,String>();
        //Map to store the Progam+Geo and their corresponding Read Only group.
        Map<String,String> pgmGeoGrpMapRO = new Map<String,String>();
        //Map to store the Progam+Geo+SubGeo and their corresponding Read Only group.
        Map<String,String> pgmSubGeoGrpMapRO = new Map<String,String>();
        //Map to store if a program requires sub geo sharing
        Map<String,Boolean> pgmSubGeoShareReq = new Map<String,Boolean>();
        //Map to store program & its corresponding Geo Groups
        Map<String,String> programToGroupName = new Map<String,String>();
        //Map to store program & its corresponding Read Only Geo Groups
        Map<String,String> programToGroupNameRO = new Map<String,String>();
        Set<String> grpNames = new Set<String>();
        //List to store all the objects that do not require Geo-based sharing
        List<String> objectsForAllGeoSharing = Label.Core_MDF_Objects_for_RO_All_Geo_Sharing.split(';');
        for(Core_MDF_RecordGeoShare shareRec : recordGeoShareLst)
        {
            programSet.add(shareRec.program);
        }
        //to get all the groups of the incoming programs
        for(Core_MDF_ProgramGeoGroupMap__mdt rec:[SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c,Core_MDF_Check_SubGeo__c
                                                  From Core_MDF_ProgramGeoGroupMap__mdt where Core_MDF_Program__c in :programSet])
        {
            //to populate the Sub geo group maps with the group data
            if(rec.Core_MDF_Region__c!=null){
                if(rec.Core_MDF_Check_SubGeo__c)
                {
                    pgmSubGeoGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name__c);//CCF_ASMO_NAR, ASMO NAR
                    pgmSubGeoGrpMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name_RO__c);
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                    pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                    addToProgramGrpMap(rec);
                }
                //to populate the geo group maps with the group data
                else
                {
                    pgmGeoGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name__c); // CCF_APJ, APJ ALL
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    pgmGeoGrpMapRO.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name_RO__c);// CCF_APJ, APJ ALL RO
                    grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                    pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, false);
                    addToProgramGrpMap(rec);
                }
                
            }
            //for groups without geo eg. CCF ALL, DCF ALL
            else
            {
                grpNames.add(rec.Core_MDF_Group_Name__c);
                grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                programToGroupName.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name__c);
                programToGroupNameRO.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name_RO__c);
            }
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
            if(pgmGeoGrpMap!=null && pgmGeoGrpMap.containsKey(record.program+System.Label.Core_MDF_Underscore+record.geo))
            {
                grpLst.add(grpNametoIdMap.get(pgmGeoGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo)));
                grpLstRO.add(grpNametoIdMap.get(pgmGeoGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.geo)));
                
            }
            else if(pgmSubGeoShareReq != null &&  pgmSubGeoShareReq.containsKey(record.geo) && pgmSubGeoShareReq.get(record.geo) 
                    && pgmSubGeoGrpMap.containsKey(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo)) 
            {
                grpLst.add(grpNametoIdMap.get(pgmSubGeoGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo)));
                grpLstRO.add(grpNametoIdMap.get(pgmSubGeoGrpMapRO.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo)));
                
            }
            if(programToGroupName!=null && programToGroupName.containsKey(record.program))
            {
                grpLst.add(grpNametoIdMap.get(programToGroupName.get(record.program)));
                grpLstRO.add(grpNametoIdMap.get(programToGroupNameRO.get(record.program)));
            }
            //In case of objects that need to be shared to all the Geo groups.
            if(objectsForAllGeoSharing.contains(objectName) && !programSet.contains(Label.Core_MDF_Retail_Channel_Program_Name))
            {
                for(List<String> groupName: programGroupMap.values()) {
                    for(String grpNm : groupName)
                    {
                        grpLst.add(grpNametoIdMap.get(grpNm));
                    }
                    
                }
                for(List<String> groupNameRO: programGroupMapRO.values()) {
                    for(String grpNmRO : groupNameRO)
                    {
                        grpLstRO.add(grpNametoIdMap.get(grpNmRO));
                    }
                }
            }
            //assigning the group lists to the record
            record.groupId = grpLst;
            record.groupId_RO = grpLstRO;
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
        
    public static void addToProgramGrpMap(Core_MDF_ProgramGeoGroupMap__mdt rec)
    {
        if(programGroupMap.containsKey(rec.Core_MDF_Program__c)){
            programGroupMap.get(rec.Core_MDF_Program__c).add(rec.Core_MDF_Group_Name__c);
        }
        else{
            programGroupMap.put(rec.Core_MDF_Program__c, new List<String>{rec.Core_MDF_Group_Name__c});
        }
        if(programGroupMapRO.containsKey(rec.Core_MDF_Program__c)){
            programGroupMapRO.get(rec.Core_MDF_Program__c).add(rec.Core_MDF_Group_Name_RO__c);
        }
        else{
            programGroupMapRO.put(rec.Core_MDF_Program__c, new List<String>{rec.Core_MDF_Group_Name_RO__c});
        }
        
    }
}