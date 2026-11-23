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
    
    public static void shareRecordToGeoGroup(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = addGroupstoRecordGeoShareLst(recordGeoShareLst);
        System.debug('updatedRecordGeoShareLst'+updatedRecordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst)
        {
            if(rec.groupId != NULL)
            {
                if(recordGeoShareMap.containsKey(rec.recordId)){
                    recordGeoShareMap.get(rec.recordId).add(rec.groupId);
                }
                else{
                    recordGeoShareMap.put(rec.recordId, new List<Id>{rec.groupId});
                }
            }
        }
        System.debug('recordGeoShareMap'+recordGeoShareMap);
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group
        if(recordGeoShareMap.size()>0)
        {
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList(objectName, recordGeoShareMap);
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
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
    public static List<Core_MDF_RecordGeoShare> addGroupstoRecordGeoShareLst(List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        
        Set<string> programSet = new Set<string>();
        
        //Map to store the Progam+Geo and their corresponding group.
        Map<String,String> pgmGeoGrpMap = new Map<String,String>();
        Map<String,String> pgmSubGeoGrpMap = new Map<String,String>();
        Map<String,Boolean> pgmSubGeoShareReq = new Map<String,Boolean>();
        Map<String,String> programToGroupName = new Map<String,String>();
        Set<String> grpNames = new Set<String>();
        
        for(Core_MDF_RecordGeoShare shareRec : recordGeoShareLst)
        {
            programSet.add(shareRec.program);
        }
        
        for(Core_MDF_ProgramGeoGroupMap__mdt rec:[SELECT Core_MDF_Group_Name__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c,Core_MDF_Check_SubGeo__c
                                                  From Core_MDF_ProgramGeoGroupMap__mdt where Core_MDF_Program__c in :programSet])
        {
            if(rec.Core_MDF_Region__c!=null){
                if(rec.Core_MDF_Check_SubGeo__c)
                {
                    pgmSubGeoGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                }
                else
                {
                    pgmGeoGrpMap.put(rec.Core_MDF_Program__c+System.Label.Core_MDF_Underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, false);
                }
            }
            else
            {
                grpNames.add(rec.Core_MDF_Group_Name__c);
                programToGroupName.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name__c);
            }
        }  
        //Map to store the GroupName and their corresponding Id.
        Map<string,Id> grpNametoIdMap = new Map<string,Id>();
        for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN :grpNames])
        {
            grpNametoIdMap.put(grp.DeveloperName, grp.Id);
        }
        for(Core_MDF_RecordGeoShare record: recordGeoShareLst)
        {  
            if(programToGroupName!=null && programToGroupName.containsKey(record.program))
            {
                record.groupId = grpNametoIdMap.get(programToGroupName.get(record.program));
            }
            else if(pgmSubGeoShareReq != null &&  pgmSubGeoShareReq.containsKey(record.geo) && pgmSubGeoShareReq.get(record.geo)) 
            {
                record.groupId = grpNametoIdMap.get(pgmSubGeoGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo+System.Label.Core_MDF_Underscore+record.subGeo));
            }
            else
            {
                record.groupId = grpNametoIdMap.get(pgmGeoGrpMap.get(record.program+System.Label.Core_MDF_Underscore+record.geo));
            }
            
        }
        
        return recordGeoShareLst;
    }
    
}