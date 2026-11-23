public class Core_MDF_CreateShareRecords {

    public static List<sObject> createShareRecordList(String objType, Map<Id,List<Id>> objIdUsrGrpIdListMap, String accessLevel, String rowCause){
        List<sObject> shareRecList = new List<sObject>();
        Boolean hasUserId = false;
        objType = String.escapeSingleQuotes(objType);
        string objectName = (objType != Null ? objType : '');
        List<Id> objectIdList = new List<Id>();
        objectIdList.addAll(objIdUsrGrpIdListMap.keySet());
        List<Id> usrOrGrpIdList = new List<Id>();
        for(List<Id> usrOrGrpIdLst : objIdUsrGrpIdListMap.values()) {
            usrOrGrpIdList.addAll(usrOrGrpIdLst);
        }
        //checking if incoming id list has users
        for(Id recId : usrOrGrpIdList) {
                    if(recId != NULL && String.valueOf(recId).startsWith('005')) {
                        hasUserId = true;
                        break;
                    }
                }
        if(String.isNotEmpty(objType)){
            Map<Id, Id> objectIdOwnerIdMap = new Map<Id, Id>();
            // collecting owner ids if share list has users
            if(hasUserId) {
                String sQuery = Label.Core_MDF_GenericShareQueryFields + 
                                        ' ' + objType + ' ' +
                                        Label.Core_MDF_GenericShareQueryWhereClass + ' :objectIdList';
                Map<Id,Sobject> results = new Map<Id,Sobject>(Database.query(String.escapeSingleQuotes(sQuery)));
                for(Sobject record : results.values()){
                            objectIdOwnerIdMap.put((Id)record.get(Label.Core_MDF_Id_Label),(Id)record.get(Label.Core_MDF_OwnerId_Label));
                        }
            }
            //for custom objects append Share to the object Name
            if(objType.endsWithIgnoreCase(Label.Core_MDF_ObjectEnding_Label))
                    {
                           objType = objType.removeEndIgnoreCase(Label.Core_MDF_c_Label) + Label.Core_MDF_Share_Label;
                    }
            //for standard objects append Share to the object Name
                    else{
                        objType += Label.Core_MDF_Share_Label;
                    }
            List<String> standardObjectNameList = new List<String>();
            Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt> sofsMap = new Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt>([SELECT MasterLabel, DeveloperName
                                                                                                                                        FROM Core_MDF_Standard_Object_for_Sharing__mdt]);
         for(Core_MDF_Standard_Object_for_Sharing__mdt sofs : sofsMap.values())
                    {
                        standardObjectNameList.add(sofs.DeveloperName);
                    }
                    
                    Schema.SObjectType objToken = Schema.getGlobalDescribe().get(objType);
                    if(objToken != NULL)
                    {
                        //Iterate over the objectIdUserGroupIdListMap map to create share records
                        //First fetch each Object Id
                        for(Id objectId : objIdUsrGrpIdListMap.keySet())
                        {
                            //Then, fetch all the User Ids with which the object record needs to be shared with.
                            for(String userGroupId : objIdUsrGrpIdListMap.get(objectId))
                            {
                                //Dynamically instantiate the Object Share record.
                                sObject dynObject = objToken.newSObject();
                                if (dynObject != NULL && userGroupId != NULL) 
                                {
                                    //Check if the selected User is not Owner
                                    if((hasUserId && objectIdOwnerIdMap != null && !objectIdOwnerIdMap.isEmpty()
                                        && objectIdOwnerIdMap.containsKey(objectId)
                                        && objectIdOwnerIdMap.get(objectId) != userGroupId) || !hasUserId ) {  
                                        // check if it is standard object
                                       if(standardObjectNameList.contains(objectName))
                                        { 
                                            dynObject.put(objectName + Label.Core_MDF_Id_Label, objectId); 
                                            if(String.isNotBlank(accessLevel)){
                                                dynObject.put(objectName + Label.Core_MDF_AccessLevel_Label, accessLevel); 
                                            }
                                            
                                            if((Label.Core_MDF_Account_Label).equalsIgnoreCase(objectName))
                                            { //for Account, 2 more extra fields need to be added to instantiate.
                                                dynObject.put(Label.Core_MDF_OpportunityAccessLevel_Label, Label.Core_MDF_None_Label);
                                                dynObject.put(Label.Core_MDF_CaseAccessLevel_Label, Label.Core_MDF_None_Label);
                                            }
                                        }
                                        else
                                        {
                                            dynObject.put(Label.Core_MDF_ParentId_Label, objectId);
                                            if(String.isNotBlank(accessLevel)){
                                                dynObject.put(Label.Core_MDF_AccessLevel_Label, accessLevel);
                                               }
                                        }
                                        dynObject.put(Label.Core_MDF_UserOrGroupId_Label, userGroupId); //Add the UserOrGroupId field
                                        dynObject.put('RowCause', rowCause); //Add the RowCause field
                                        shareRecList.add(dynObject); //Add it to the List
                                            
                                    }
                                }                                
                            }
                        }
                    }
                }
        return shareRecList;
    }
    
public static List<sObject> shareRecordListForGeoGroup(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst){
    	List<sObject> shareRecordList = new List<sObject>();
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = Core_MDF_ShareRecordToGeoGroup.addGroupstoRecordGeoShareLst(objectName,recordGeoShareLst);
        System.debug('updatedRecordGeoShareLst'+updatedRecordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();
        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        if(updatedRecordGeoShareLst != NULL && updatedRecordGeoShareLst.size()>0)
        {
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
        }
        System.debug('recordGeoShareMap::'+recordGeoShareMap);
        System.debug('recordGeoShareMapRO::'+recordGeoShareMapRO);
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Edit Access
        if(recordGeoShareMap != NULL && recordGeoShareMap.size()>0)
        {
            List<sObject> shareRecList = createShareRecordList(objectName,recordGeoShareMap, 'Edit', 'Manual');
            if(shareRecList!=Null && shareRecList.size()>0){
            shareRecordList.addAll(shareRecList);
            }
            //Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Read Access
        if(recordGeoShareMapRO != NULL && recordGeoShareMapRO.size()>0)
        {
            List<sObject> shareRecList = createShareRecordList(objectName,recordGeoShareMapRO, 'Read','Manual');
            if(shareRecList!=Null && shareRecList.size()>0){
            shareRecordList.addAll(shareRecList);
            }
            //Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMapRO, 'Read');
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInstRead);
        }
    Return shareRecordList;
    }
}