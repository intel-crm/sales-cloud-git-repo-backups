/****************************************************************************************************************************************
* Class Name  : Core_MDF_GenericShareRecordActionClass
* Version     : 1.0
* Created Date: 7-22-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/22/2018          Generic Class to create Share records.
* Ganapati             9/29/2020          US781098: [KIIT]: [Tech Debt] - PFR SOQL Optimization - To optimize SOQL for group sharing
*****************************************************************************************************************************************/
public without sharing class Core_MDF_GenericShareRecordActionClass {

    public static String readAccessLevel = '';
    
    // ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
    // Static cache added at class level — shared across all 3 methods
    private static Map<String, Schema.SObjectType> sObjectTypeCache = new Map<String, Schema.SObjectType>();

    // Private helper replaces getGlobalDescribe() in all 3 methods
    private static Schema.SObjectType getSObjectTypeToken(String objectName) {
    	if (String.isBlank(objectName)) { return null; }
    	String key = objectName.toLowerCase();
    	if (!sObjectTypeCache.containsKey(key)) {
        	try {
            	Schema.DescribeSObjectResult[] results = Schema.describeSObjects(new List<String>{ objectName });
            	if (results != null && !results.isEmpty()) {
                	sObjectTypeCache.put(key, results[0].getSObjectType());
            	}
        	} catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); }
    	}
    	return sObjectTypeCache.containsKey(key) ? sObjectTypeCache.get(key) : null;
	}
    
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
                    if(recId != NULL && String.valueOf(recId).startsWith('005')) {
                        hasUserId = true;
                        break;
                    }
                }
                /* US781098 - End */
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
                        String sQuery = Label.Core_MDF_GenericShareQueryFields + 
                                        ' ' + recordManualShare.typeName + ' ' +
                                        Label.Core_MDF_GenericShareQueryWhereClass + ' :objectIdList';

                        Map<Id,Sobject> results = new Map<Id,Sobject>(Database.query(String.escapeSingleQuotes(sQuery)));
                        for(Sobject record : results.values()){
                            objectIdOwnerIdMap.put((Id)record.get(Label.Core_MDF_Id_Label),(Id)record.get(Label.Core_MDF_OwnerId_Label));
                        }
                    }
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
                    //Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt> sofsMap = new Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt>([SELECT MasterLabel, DeveloperName
                      //                                                                                                                  FROM Core_MDF_Standard_Object_for_Sharing__mdt]);
                    List<String> SplitStandardObject = Label.Core_MDF_Standard_Object_for_SharingLabel.split(',');//Replaced Core_MDF_Standard_Object_for_Sharing__mdt with label
                    //Fetch the Standard object names to differentiate between the Share record creation as some standard
                    //objects have different fields as compared to some other standard and all custom objects.
                    //Like AccountShare - Fields to populate are AccountId & AccountAccessLevel
                    //But, for PartnerFundAllocationShare - Fields to populate are ParentId & AccessLevel
                    
                   /* for(Core_MDF_Standard_Object_for_Sharing__mdt sofs : sofsMap.values())
                    {
                        standardObjectNameList.add(sofs.DeveloperName);
                        
                    }*/
                    
                    for (String value : SplitStandardObject) { //Replaced Core_MDF_Standard_Object_for_Sharing__mdt with label
                        value = value.trim();
                        standardObjectNameList.add(value);                        
                    }
                    
	    	// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
            Schema.SObjectType objToken = getSObjectTypeToken(recordManualShare.typeName);
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
                                if (dynObject != NULL && userGroupId != NULL) 
                                {
                                    //Fields -> UserOrGroupId, ParentId, AccessLevel 
                                    /* US781098 - Added null check for objectIdOwnerIdMap */
                                    if((hasUserId && objectIdOwnerIdMap != null && !objectIdOwnerIdMap.isEmpty()
                                        && objectIdOwnerIdMap.containsKey(objectId)
                                        && objectIdOwnerIdMap.get(objectId) != userGroupId) || !hasUserId ) {  //If the selected User is not Owner
                                        if(standardObjectNameList.contains(originalObjectName))
                                        { //if the metadata contains the object
                                            dynObject.put(originalObjectName + Label.Core_MDF_Id_Label, objectId); //e.g. Account, Campaign - AccountId, CampaignId
                                            if(String.isNotBlank(recordManualShare.accessLevelStr)){
                                                dynObject.put(originalObjectName + Label.Core_MDF_AccessLevel_Label, recordManualShare.accessLevelStr); //e.g. Account, Campaign - AccountAccessLevel, CampaignAccessLevel
                                                }
                                            
                                            if((Label.Core_MDF_Account_Label).equalsIgnoreCase(originalObjectName))
                                            { //for Account, 3 more extra fields need to be added to instantiate.
                                                dynObject.put(Label.Core_MDF_OpportunityAccessLevel_Label, Label.Core_MDF_None_Label);
                                                if(String.isNotBlank(recordManualShare.caseAccessLevel))
                                                {
                                                    dynObject.put(Label.Core_MDF_CaseAccessLevel_Label, recordManualShare.caseAccessLevel);
                                                }
                                                else {
                                                    dynObject.put(Label.Core_MDF_CaseAccessLevel_Label, Label.Core_MDF_None_Label);
                                                }
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
                        if(dynObjectList.size() > 0 && recordManualShare.insertShareRecords)
                        {
                  
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
        String caseAccessLevel;
        Boolean insertShareRecords = true;

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
        public RecordManualShareClass(String typeNameStr, Map<Id,List<Id>> oIdUGIdListMap, String aLevelStr, Boolean insertShareRecords){
            this.typeName = typeNameStr;
            this.objectIdUserGroupIdListMap = oIdUGIdListMap;
            this.accessLevelStr = aLevelStr;
            this.rowCauseStr = 'Manual';
            this.insertShareRecords = insertShareRecords;
            
        }
        public RecordManualShareClass(String typeNameStr, Map<Id,List<Id>> oIdUGIdListMap, String aLevelStr,String rcStr, String caseAccessLevel){
            this.typeName = typeNameStr;
            this.objectIdUserGroupIdListMap = oIdUGIdListMap;
            this.accessLevelStr = aLevelStr;
            this.rowCauseStr = rcStr;
            this.caseAccessLevel =caseAccessLevel;
        }
    }
    
public static List<sObject> getShareRecordList(RecordManualShareClass recordManualShare){
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
                    if(recId != NULL && String.valueOf(recId).startsWith('005')) {
                        hasUserId = true;
                        break;
                    }
                }
                /* US781098 - End */
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
                        String sQuery = Label.Core_MDF_GenericShareQueryFields + 
                                        ' ' + recordManualShare.typeName + ' ' +
                                        Label.Core_MDF_GenericShareQueryWhereClass + ' :objectIdList';

                        Map<Id,Sobject> results = new Map<Id,Sobject>(Database.query(String.escapeSingleQuotes(sQuery)));
                        for(Sobject record : results.values()){
                            objectIdOwnerIdMap.put((Id)record.get(Label.Core_MDF_Id_Label),(Id)record.get(Label.Core_MDF_OwnerId_Label));
                        }
                    }
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
                    //Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt> sofsMap = new Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt>([SELECT MasterLabel, DeveloperName
                      //                                                                                                                  FROM Core_MDF_Standard_Object_for_Sharing__mdt]);
                    List<String> SplitStandardObject = Label.Core_MDF_Standard_Object_for_SharingLabel.split(',');//Replaced Core_MDF_Standard_Object_for_Sharing__mdt with label                    //Fetch the Standard object names to differentiate between the Share record creation as some standard
                    //objects have different fields as compared to some other standard and all custom objects.
                    //Like AccountShare - Fields to populate are AccountId & AccountAccessLevel
                    //But, for PartnerFundAllocationShare - Fields to populate are ParentId & AccessLevel
                    
                   /* for(Core_MDF_Standard_Object_for_Sharing__mdt sofs : sofsMap.values())
                    {
                        standardObjectNameList.add(sofs.DeveloperName);
                        
                    }*/
                    
                    for (String value : SplitStandardObject) { //Replaced Core_MDF_Standard_Object_for_Sharing__mdt with label
                        value = value.trim();
                        standardObjectNameList.add(value);                      
                    }
                    
	    	// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
            Schema.SObjectType objToken = getSObjectTypeToken(recordManualShare.typeName);
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
                                if (dynObject != NULL && userGroupId != NULL) 
                                {
                                    //Fields -> UserOrGroupId, ParentId, AccessLevel 
                                    /* US781098 - Added null check for objectIdOwnerIdMap */
                                    if((hasUserId && objectIdOwnerIdMap != null && !objectIdOwnerIdMap.isEmpty()
                                        && objectIdOwnerIdMap.containsKey(objectId)
                                        && objectIdOwnerIdMap.get(objectId) != userGroupId) || !hasUserId ) {  //If the selected User is not Owner
                                        if(standardObjectNameList.contains(originalObjectName))
                                        { //if the metadata contains the object
                                            dynObject.put(originalObjectName + Label.Core_MDF_Id_Label, objectId); //e.g. Account, Campaign - AccountId, CampaignId
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
                            return dynObjectList;
                        }
                    }
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); }
        return dynObjectList;
    }
 
    public static List<sObject> createShareRecordListforBatch(RecordManualShareClass recordManualShare){
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
               
                List<Id> userGrpIdList = new List<Id>();
                for(List<Id> usrgrpIdLst : recordManualShare.objectIdUserGroupIdListMap.values()) {
                    userGrpIdList.addAll(usrgrpIdLst); // fetch all user or group ids in userGrpIdList
                    }
                for(Id recId : userGrpIdList) {
                    if(recId != NULL && String.valueOf(recId).startsWith('005')) {
                        hasUserId = true;
                        break;
                    }
                }

               if(String.isNotEmpty(recordManualShare.typeName)){ //if typeName is not empty
                    Map<Id, Id> objectIdOwnerIdMap = new Map<Id, Id>();
                    if(hasUserId) { 
                        //Query the same records to fetch the Owner Ids as we do not want to create Share records with the User
                        //who is an Owner.
                        String sQuery = Label.Core_MDF_GenericShareQueryFields + 
                                        ' ' + recordManualShare.typeName + ' ' +
                                        Label.Core_MDF_GenericShareQueryWhereClass + ' :objectIdList';

                        Map<Id,Sobject> results = new Map<Id,Sobject>(Database.query(String.escapeSingleQuotes(sQuery)));
                        for(Sobject record : results.values()){
                            objectIdOwnerIdMap.put((Id)record.get(Label.Core_MDF_Id_Label),(Id)record.get(Label.Core_MDF_OwnerId_Label));
                        }
                    }
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
                    //Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt> sofsMap = new Map<Id,Core_MDF_Standard_Object_for_Sharing__mdt>([SELECT MasterLabel, DeveloperName
                    //                                                                                                                    FROM Core_MDF_Standard_Object_for_Sharing__mdt]);
                    
                    List<String> SplitStandardObject = Label.Core_MDF_Standard_Object_for_SharingLabel.split(',');//Replaced Core_MDF_Standard_Object_for_Sharing__mdt with label

                    //Fetch the Standard object names to differentiate between the Share record creation as some standard
                    //objects have different fields as compared to some other standard and all custom objects.
                    //Like AccountShare - Fields to populate are AccountId & AccountAccessLevel
                    //But, for PartnerFundAllocationShare - Fields to populate are ParentId & AccessLevel
                    
                    /* for(Core_MDF_Standard_Object_for_Sharing__mdt sofs : sofsMap.values())
                    {
                        standardObjectNameList.add(sofs.DeveloperName);
                        
                    }*/
                    
                    for (String value : SplitStandardObject) { //Replaced Core_MDF_Standard_Object_for_Sharing__mdt with label
                        value = value.trim();
                        standardObjectNameList.add(value);
                                                
                    }
                    
	    	// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
            Schema.SObjectType objToken = getSObjectTypeToken(recordManualShare.typeName);
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
                                if (dynObject != NULL && userGroupId != NULL) 
                                {
                                    //Fields -> UserOrGroupId, ParentId, AccessLevel 
                                    /* US781098 - Added null check for objectIdOwnerIdMap */
                                    if((hasUserId && objectIdOwnerIdMap != null && !objectIdOwnerIdMap.isEmpty()
                                        && objectIdOwnerIdMap.containsKey(objectId)
                                        && objectIdOwnerIdMap.get(objectId) != userGroupId) || !hasUserId ) {  //If the selected User is not Owner

                                        if(standardObjectNameList.contains(originalObjectName))
                                        { //if the metadata contains the object
                                            dynObject.put(originalObjectName + Label.Core_MDF_Id_Label, objectId); //e.g. Account, Campaign - AccountId, CampaignId
                                          
                                            
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

                            String shareObjectName = originalObjectName.Substring(0,originalObjectName.length()-1);
                            shareObjectName += 'Share';
                            //createShareBulkString(dynObjectList, shareObjectName);
                           
                        }
                    }
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); }
        return dynObjectList;
    }


    public static void createShareBulkString(List<sObject> dynObjectList, String shareObjectName){
        
        if(dynObjectList.size()>0){
            
            String requestString = '"ParentId","UserOrGroupId","RowCause","AccessLevel"'+'\r\n';
           
            for(sObject sOb : dynObjectList){
                Core_MDF_Payment__Share paymentObj = (Core_MDF_Payment__Share)sOb;
                requestString += '"'+paymentObj.ParentId + '","'+paymentObj.UserOrGroupId+ '","'+paymentObj.RowCause+ '","'+paymentObj.AccessLevel+'"'+'\r\n';
            }
            if(String.isNotBlank(shareObjectName) && String.isNotBlank(requestString)) {
                insertShareBulkRecords(requestString,shareObjectName);
            }
        }
    }

    public static void insertShareBulkRecords(String reqString, String shareObjectName){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        
        String endPointUrl = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest';
        //request.setEndpoint('callout:Bulk_API');
        request.setEndpoint(endPointUrl);
       
        request.setHeader('content-type', 'application/json' );
        String body = '{'+  
            '"lineEnding": "CRLF",'+ 
            '"operation": "insert",'+ 
            '"object": "'+shareObjectName+'",'+ 
            '"contentType": "CSV"'+
            '}';
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id');
            
            //second request to store data
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
           
            String endPointUrl1 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId+'/batches';
            request1.setEndpoint(endPointUrl1);
            request1.setHeader('content-type', 'text/csv' );
           
            request1.setBody(reqString);
            request1.setTimeout(20000);
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
            if(resp1.getStatusCode() <= 299) {
                
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
               
                String endPointUrl2 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId;
                request2.setEndpoint(endPointUrl2);
                request2.setHeader('content-type', 'application/json' );
               
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
            } 
        }
    }
}