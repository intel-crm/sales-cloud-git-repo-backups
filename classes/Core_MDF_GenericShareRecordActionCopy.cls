/****************************************************************************************************************************************
* Class Name  : Core_MDF_GenericShareRecordActionCopy 
* Version     : 1.0 
* Created Date: 09-22-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/22/2018          Generic Class to create Share records.
* Ganapati             8/24/2020          US781098: [KIIT]: [Tech Debt] - PFR SOQL Optimization - To optimize SOQL for group sharing
*****************************************************************************************************************************************/
public without sharing class Core_MDF_GenericShareRecordActionCopy {

    public static String readAccessLevel = '';
    /***************************************************************************************************** 
    Method Name:        createShareRecordList
    @return  :          List<sObject>
    @parameters:        typeName - API Name of the Object for which share records are going to be created,
                        objectIdUserGroupIdListMap - Map of object Id as Key and List of User Id/Group Id as Values
    Description:        Generic Share records creation
    Added By:           Accenture - SB - 07/22/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/

    public static List<sObject> createShareRecordList(RecordManualShareClass recordManualShare){
        List<sObject> dynObjectList = new List<sObject>();
        Boolean hasUserId = false;
        try{
            if(recordManualShare != NULL){
                //Store the Original Name
                recordManualShare.typeName = String.escapeSingleQuotes(recordManualShare.typeName);
                String originalObjectName = (recordManualShare.typeName != NULL ? recordManualShare.typeName : '');
                //Fetch all the object Ids in a List variable 'objectIdList'
                List<Id> objectIdList = new List<Id>();
                objectIdList.addAll(recordManualShare.objectIdUserGroupIdListMap.keySet());
                /* US781098 - start */
                List<Id> userGrpIdList = new List<Id>();
                for(List<Id> usrgrpIdLst : recordManualShare.objectIdUserGroupIdListMap.values()) {
                    userGrpIdList.addAll(usrgrpIdLst); // fetch all user or group ids in userGrpIdList
                }
                for(Id recId : userGrpIdList) {
                    if(String.valueOf(recId).startsWith('005')) { 
                        hasUserId = true;
                        break;
                    }
                }
                /* US781098 - start */
                if(String.isNotEmpty(recordManualShare.typeName)){ //if typeName is not empty
                    Map<Id, Id> objectIdOwnerIdMap = new Map<Id, Id>();
                    /* if hasUserId = false it means that userGrpIdList contains group ids and 
                     * Group cannot be an owner of the records so not required the below soql for 
                     * getting the ownerid for record.
                     * The below block only executes if userGrpIdList contains user ids
                    */
                    if(hasUserId) { /* US781098 - start */
                        //Query the same records to fetch the Owner Ids as we do not want to create Share records with the User
                        //who is an Owner.
                        // Core_MDF_GenericShareQueryFields - SELECT Id, OwnerId FROM
                        // Core_MDF_GenericShareQueryWhereClass - WHERE Id IN
                        String sQuery = Label.Core_MDF_GenericShareQueryFields + 
                                        ' ' + recordManualShare.typeName + ' ' +
                                        Label.Core_MDF_GenericShareQueryWhereClass + ' :objectIdList';
    
                        Map<Id,Sobject> results = new Map<Id,Sobject>(Database.query(String.escapeSingleQuotes(sQuery)));
                        //System.debug('results: ' + results);
                        //Core_MDF_Id_Label - Id, Core_MDF_OwnerId_Label - OwnerId
                        for(Sobject record : results.values()){
                            objectIdOwnerIdMap.put((Id)record.get(Label.Core_MDF_Id_Label),(Id)record.get(Label.Core_MDF_OwnerId_Label));
                        }
                    } /* US781098 - end */
                    //Append Share to the object Name
                    if(recordManualShare.typeName.endsWithIgnoreCase(Label.Core_MDF_ObjectEnding_Label))
                    {
                        recordManualShare.typeName = recordManualShare.typeName.removeEndIgnoreCase(Label.Core_MDF_c_Label) + Label.Core_MDF_Share_Label;
                    }
                    else{
                        recordManualShare.typeName += Label.Core_MDF_Share_Label;
                    }
                    List<String> standardObjectNameList = new List<String>();
                    // Map<metadataIs,metadataRecord
                    Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt> sofsMap = new Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt>([SELECT MasterLabel, DeveloperName
                                                                                                                                        FROM Core_MDF_Standard_Object_for_Sharing__mdt]);
                    //Fetch the Standard object names to differentiate between the Share record creation as some standard
                    //objects have different fields as compared to some other standard and all custom objects.
                    //Like AccountShare - Fields to populate are AccountId & AccountAccessLevel
                    //But, for PartnerFundAllocationShare - Fields to populate are ParentId & AccessLevel
                    
                    for(Core_MDF_Standard_Object_for_Sharing__mdt sofs : sofsMap.values())
                    {
                        standardObjectNameList.add(sofs.DeveloperName);
                    }
                    
                    Schema.SObjectType objToken = Schema.getGlobalDescribe().get(recordManualShare.typeName);
                    if(objToken != NULL)
                    {
                        //Iterate over the objectIdUserGroupIdListMap map to create share records
                        //First fetch each Object Id
                        for(Id objectId : recordManualShare.objectIdUserGroupIdListMap.keySet())
                        {
                            //Then, fetch all the User Ids with which the object record needs to be shared with.
                            for(String userGroupId : recordManualShare.objectIdUserGroupIdListMap.get(objectId))
                            {
                                //Dynamically instantiate the Object Share record.
                                sObject dynObject = objToken.newSObject();
                                if (dynObject != NULL) 
                                {
                                    // if userid is owner of record then we are skipping the sharing for that user else inserting sharing records for other users/Groups
                                    //Fields -> UserOrGroupId, ParentId, AccessLevel 
                                    if((hasUserId && objectIdOwnerIdMap != null && !objectIdOwnerIdMap.isEmpty() && objectIdOwnerIdMap.containsKey(objectId) && objectIdOwnerIdMap.get(objectId) != userGroupId) || !hasUserId ) {  //If the selected User is not Owner
                                        if(standardObjectNameList.contains(originalObjectName))
                                        { //if the metadata contains the object
                                            dynObject.put(originalObjectName + Label.Core_MDF_Id_Label, objectId); //e.g. Account, Campaign - AccountId, CampaignId
                                            System.debug('recordManualShare.accessLevelStr: ' + recordManualShare.accessLevelStr);
                                            if(String.isNotBlank(recordManualShare.accessLevelStr)){
                                                dynObject.put(originalObjectName + Label.Core_MDF_AccessLevel_Label, recordManualShare.accessLevelStr); //e.g. Account, Campaign - AccountAccessLevel, CampaignAccessLevel
                                            }
                                            
                                            if((Label.Core_MDF_Account_Label).equalsIgnoreCase(originalObjectName))
                                            { //for Account, 3 more extra fields need to be added to instantiate.
                                                dynObject.put(Label.Core_MDF_OpportunityAccessLevel_Label, Label.Core_MDF_None_Label);
                                                dynObject.put(Label.Core_MDF_CaseAccessLevel_Label, Label.Core_MDF_None_Label);
                                            }
                                        }
                                        else
                                        {
                                            dynObject.put(Label.Core_MDF_ParentId_Label, objectId); //PartnerFundAllocation, PartnerFundRequest - PartnerFundAllocationId, PartnerFundRequestId
                                            if(String.isNotBlank(recordManualShare.accessLevelStr)){
                                                dynObject.put(Label.Core_MDF_AccessLevel_Label, recordManualShare.accessLevelStr);
                                            }
                                        }
                                        dynObject.put(Label.Core_MDF_UserOrGroupId_Label, userGroupId); //Add the UserOrGroupId field
                                        dynObject.put('RowCause', recordManualShare.rowCauseStr); //Add the RowCause field
                                        dynObjectList.add(dynObject); //Add it to the List
                                    }
                                }                                
                            }
                        }
                        if(dynObjectList.size() > 0)
                        {
                            System.debug('dynObjectList:::'+dynObjectList);
                            List<Database.SaveResult> saveResultList = Database.insert(dynObjectList); //insert the record
                            if(saveResultList != NULL){
                                return dynObjectList; //return the list of Share records
                            }
                        }
                    }
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); }
        return dynObjectList;
    }

    public class RecordManualShareClass{
        String typeName;
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        String accessLevelStr;
        String rowCauseStr;

        public RecordManualShareClass(String typeNameStr, Map<Id,List<Id>> oIdUGIdListMap, String aLevelStr, String rcStr){
            this.typeName = typeNameStr;
            this.objectIdUserGroupIdListMap = oIdUGIdListMap;
            this.accessLevelStr = aLevelStr;
            if(String.isBlank(rcStr)){
                this.rowCauseStr = 'Manual';
            }
            else{
                this.rowCauseStr = rcStr;
            }
        }
        public RecordManualShareClass(String typeNameStr, Map<Id,List<Id>> oIdUGIdListMap, String aLevelStr){
            this.typeName = typeNameStr;
            this.objectIdUserGroupIdListMap = oIdUGIdListMap;
            this.accessLevelStr = aLevelStr;
            this.rowCauseStr = 'Manual';
        }
    }
 
}