/*************************************************************************************************************************************************************************
* Class Name  : PMP_Utility 
* Version     : 1.0 
* Created Date: 4/22/2019
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Manasa              M-01    : Original version     4/22/2019                          Utility class for commonly used methods
**************************************************************************************************************************************************************************/
public without sharing class PMP_Utility { 
    public static Id orgWideAddress= NULL;
    /**
* @description Method to to access static data from custom metaData
* @param key
* @return String
**/
    @AuraEnabled( cacheable=true ) 
    public static String getValue(String key) {
        String s = '';
        
        List<PMP_Static_Data__mdt> staticData = new List<PMP_Static_Data__mdt>();
        
        staticData =[Select Id,DeveloperName,Value__c From PMP_Static_Data__mdt WHERE DeveloperName =: key LIMIT 1];
        //Added as part of Medium Severity Fix TWC729-5510
        String staticDataValue = staticData[0].Value__c;
        
        if (staticData.isEmpty()) {
            return s;
        } else {
            return staticDataValue;
        }
    }
    
    /** 
* @description get the content download URL value from content document object
* @param contentDocumentIds - List of cotent document Ids
* Method Parameters - List<ID> 
*/
    /*  public static List<ContentDistribution> getContentDownloadUrls(List<ID> contentDocumentIds){
List<ContentDistribution> contDistribution = new List<ContentDistribution>();

contDistribution = [SELECT Id, Name, ContentVersionId, ContentDocumentId, RelatedRecordId, 
DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
WHERE ContentDocumentId IN :contentDocumentIds];

return contDistribution;
}*/
    /** 
* @description get the content download URL value from content document object
* @param contentDocumentIds - List of cotent document Ids
* Method Parameters - List<ID> 
*/
    /*  public static List<ContentDistribution> getContentDownloadUrlData(List<ID> contentDocumentIds){
List<ContentDistribution> ContentDistributionData = new List<ContentDistribution>();
Set<Id> uniqueContentIdSet = new Set<Id>();

for(ContentDistribution distributionData : [SELECT Id, Name, ContentVersionId, ContentDocumentId, RelatedRecordId, 
DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
WHERE ContentDocumentId IN :contentDocumentIds]) {
if(!uniqueContentIdSet.contains(distributionData.ContentDocumentId)){
uniqueContentIdSet.add(distributionData.ContentDocumentId);
ContentDistributionData.add(distributionData);
}
}

return ContentDistributionData;
}*/
    
    /** 
* @description Returns true if logged in user is Intel Admin
* @param Boolean
* Method Parameters - NA 
*/
    //Added by shahrukh
    
  /*  @AuraEnabled(cacheable=true)
    public static Boolean isLoggedInUserAdmin(){
        // Default value for isAdmin
        boolean isAdmin = false;      
        // Fetching the admin group name from a custom setting
        String adminGroupName = getValue('PMP_Admin_GroupName');        
        // If admin group name is not null
        if (adminGroupName != null) {
            // Fetching the group where all admins are declared
            Group adminGroup = [SELECT Id FROM Group WHERE DeveloperName = :adminGroupName LIMIT 1];       
            // If admin group is found
        if(adminGroup!=null){
                // Fetching all group members from the admin group
                List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :adminGroup.Id];           
                // Iterating over all group members to check if the logged in user is an admin
                for (GroupMember groupMember : groupMembers) {
                    if (groupMember.UserOrGroupId == UserInfo.getUserId()) {
                        isAdmin = true;
                            break;
                        }
                    }
                }
        }
                   
        return isAdmin;
            }*/
    //OPTIMISATION WW44
    @AuraEnabled(cacheable=true)
   public static Boolean isLoggedInUserAdmin(){
       String adminGroupName = getValue('PMP_Admin_GroupName');
       if(String.isBlank(adminGroupName)){
        return false;
       }
       Integer countRecords = [SELECT Count() FROM GroupMember WHERE Group.DeveloperName = :adminGroupName AND UserOrGroupId = :UserInfo.getUserId()];
           return countRecords > 0;
}
    
    /** 
* @description Returns true if logged in user is anonymous
* @param Boolean
* Method Parameters - NA 
*/
    //Added by shahrukh
    //OPTIMISATION WW44
    //Method used in PMP_OfferingDetailsController, which is commented
   /* public static Boolean isLoggedInUserAnonymous(){
        
        boolean isUserAnonymous = false; //Declaring a boolean with default value false
        
        string profName = getValue('PMP_Anonymous_UserProfile');
        
        
        
        if(profName!=null){
            List<Profile> profList;
            
            profList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]; //Getting Logged in Users Profile Name
            
            
            If(profList!=null && !profList.isEmpty() && profList[0].Name==profName){   
                isUserAnonymous = true;
            }
        } 
        
        return isUserAnonymous; // Returing the boolean parameter
    }*/
    /**
* method added by raj to get locale fields for taxonomy data
* @description-fetch locale fields(Name,Description etc) for the requested object
* @param objectName for which locale fields are required
* @return Map<String,String>
* Method Parameters - String
*/
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getLocaleFields(String objectName,string selectedLanguage){
        String language = selectedLanguage != null? selectedLanguage : userinfo.getLanguage();//getting the logged in user's language
        Map<String, String> apiNameByLabel = new Map<String, String>();//Map to store field api name by field label 
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();//to store metadata records
        
        language = language =='ja'?language+'_JP':language;
        
        if(language != null){//if user language is there fetch the metadata records of the requested object for the user language from metadata
            localeFields = getLocaleToFieldMdtRecordsByObject(language,objectName);
            if(localeFields.isEmpty()){//if there are no records in the metadata for the current user language,fetch english records(to make english default)
                localeFields = getLocaleToFieldMdtRecordsByObject('en_US',objectName);
            }
        }
        
        if(!localeFields.isEmpty()){//if metadata records are not empty,iterate over the records
            for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){//populating the apiNameByLabel map with the field name as key and field api name as value
                apiNameByLabel.put(localField.PMP_Field_Nm__c, localField.PMP_Field_APINm__c);//Ex: <PMP_Field_Nm__c = PMP_Field_APINm__c>
            }
        }
        
        return apiNameByLabel;
    }
    
    /**
* method added by raj to get language fields for taxonomy data based on object name
* @description-fetch language fields(Name,Description etc) for the requested object and language
* @param objectName for which language fields are required
* @param language for which the fields are required
* @return List<PMP_Locale_To_FieldAPINm_Mapping__mdt>
* Method Parameters - String
* Method Parameters - String
*/
    @AuraEnabled(cacheable=true)
    public static List<PMP_Locale_To_FieldAPINm_Mapping__mdt> getLocaleToFieldMdtRecordsByObject(String language, String objectName){
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeToFieldMdtRecords = new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();//to store metadata records
        
        language = language =='ja'?language+'_JP':language;
        
        if(!String.isEmpty(language) && !String.isEmpty(objectName)){//if language and object name is there fetch the metadata records for the requested object
            
            localeToFieldMdtRecords = [SELECT PMP_Locale_Nm__c, PMP_Field_Nm__c, PMP_Object_Nm__c, PMP_Field_APINm__c,PMP_Language_Nm__c FROM PMP_Locale_To_FieldAPINm_Mapping__mdt 
                                       WHERE PMP_Locale_Nm__c =: language AND PMP_Object_Nm__c =: objectName];
            
        }
        
        return localeToFieldMdtRecords;
    }
    
    /**
* method added by raj to get language fields for taxonomy data based on field name
* @description-fetch language fields(Name,Description etc) for the requested object and language
* @param fieldName for which language fields are required
* @param language for which the fields are required
* @return List<PMP_Locale_To_FieldAPINm_Mapping__mdt>
* Method Parameters - String
* Method Parameters - String
*/
    public static List<PMP_Locale_To_FieldAPINm_Mapping__mdt> getLocaleToFieldMdtRecordsByField(String language, String fieldName){
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeToFieldMdtRecords = new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();//to store metadata records
        
        //language = language =='ja'?language+'_JP':language;
        language = language =='ja'?language+'_JP': ( language =='zh_Hans_CN' ? PMP_StaticConstants_Partner.ZH_CN : language); //Added as a part of new L3 storefront page
            
            if(!String.isEmpty(language) && !String.isEmpty(fieldName)){//if language and object name is there fetch the metadata records for the requested field
                
                localeToFieldMdtRecords = [SELECT PMP_Locale_Nm__c, PMP_Field_Nm__c, PMP_Object_Nm__c, PMP_Field_APINm__c FROM PMP_Locale_To_FieldAPINm_Mapping__mdt 
                                           WHERE PMP_Locale_Nm__c =: language AND PMP_Field_Nm__c =: fieldName];
                if(localeToFieldMdtRecords.isEmpty()){//if there are no records in the metadata for the current user language,fetch english records(to make english default)
                    localeToFieldMdtRecords = [SELECT PMP_Locale_Nm__c, PMP_Field_Nm__c, PMP_Object_Nm__c, PMP_Field_APINm__c FROM PMP_Locale_To_FieldAPINm_Mapping__mdt 
                                               WHERE PMP_Locale_Nm__c =: 'en_US' AND PMP_Field_Nm__c =: fieldName];
                }
                
            }
        
        return localeToFieldMdtRecords;
    }
    
    /**
* method added by raj to get leaf node for the JSON files
* @description-find the leaf node for the JSON file
* @param mapSpec specMap of the JSON file(i.e <en_US = [List of Spec]>)
* @return Integer
* Method Parameters - Map<String,Object>
*/
    public static Integer getLeafNode(Map<String,Object> mapSpec){
        
        Integer leafLevel = 0;//Initially let leaf level to be 0
        
        for(string theKey:mapSpec.keySet()){//iterate over keyset of the map
            List<Object> lstSpec = (List<Object>)mapSpec.get(theKey); //get the List of objects associated with key
            for(integer specIndex=0;specIndex<lstSpec.size();specIndex++){//iterating over the spec list related to thekey
                Map<String, Object> specMap = (Map<String, Object>)lstSpec[specIndex];
                if(specMap != null && !specMap.isEmpty() && specMap.containsKey(PMP_StaticConstants_MasterData.Level) && String.isNotBlank(String.valueOf(specMap.get(PMP_StaticConstants_MasterData.Level))) && (Integer.valueOf(specMap.get(PMP_StaticConstants_MasterData.Level)) > leafLevel)){//if the specMap is not null check for the level
                    
                    
                    leafLevel = Integer.valueOf(specMap.get(PMP_StaticConstants_MasterData.Level));//update leafLevel with the current level
                    
                    
                }
            }
        }
        return leafLevel;
    }
    
    
    /*  public static ContentVersion createContentVersion (ContentDistribution content, Blob thumbNailImage) {

ContentVersion contentVersion = new ContentVersion();//content version instance
contentVersion.Title = content.Name;// title of content version
contentVersion.PathOnClient = content.Name + Datetime.now().getTime() + '.png'; // set path on client
contentVersion.VersionData = thumbNailImage; // set the thumbnail image as the data
contentVersion.Origin = 'H'; // set the origin


insert contentVersion; // insert content version

return ContentVersion;
}*/
    
    /**
* @description create a log failed callout entry record when a callout failed
* Param - recordId - failed callout record id
* Param - origin - from which class the callout initiated/failed
* Param - projectName - whihc project implemented the callout
* Param - objectName - what is the object name of failed record
* Param - status - what is the status of failed record
* Param - response - what is the response for the failed record
* Param - parentId - what is the parent Id of failed record
* Param - parentName - what is the Parent Name of failed record

* Method Parameters - Id,String,String,String, String, HTTPResponse,String, String
* @return void
*/  
    
    public static void creatFailedCalloutLogEntryRecord(Id recordId,String origin,String projectName,String objectName,
                                                        String status,HTTPResponse response, String parentId, String parentName){ 
                                                            Core_Log_Failed_Callout_Entry__c logEntry = new Core_Log_Failed_Callout_Entry__c();
                                                            logEntry.Core_sObjectId__c = recordId;        
                                                            logEntry.Core_Origin__c = origin;
                                                            logEntry.Core_Project__c = projectName;
                                                            logEntry.Core_Object_Name__c = objectName;
                                                            logEntry.Core_Retry_Count__c=1;
                                                            logEntry.Core_Entry_Time__c = System.Now();
                                                            logEntry.Core_Status__c = status;
                                                            logEntry.Core_Response_code__c=response.getStatusCode();
                                                            logEntry.Core_Response_status__c=response.getStatus();
                                                            logEntry.Core_Parent_Name__c= parentName;
                                                            logEntry.Core_Parent_Id__c= parentId;
                                                            insert logEntry;
                                                        }
    
    
    /**
* @description returns List of translation records for the offering
* @Param offeringId 
*/
     //OPTIMISATION - WW44
    //Method used in offerings code which is commented down, so commenting below method.
   /* public static List<PMP_Partner_Offering_Translation__c> getOfferingTranslationRecords(id offeringId){
        List<PMP_Partner_Offering_Translation__c> offTranslationList = new List<PMP_Partner_Offering_Translation__c>();
        if (Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()) {
            offTranslationList = [Select id, Name, PMP_Chinese_Txt__c, PMP_English_Txt__c, PMP_Japanese_Txt__c,PMP_Field_Nm__c
                                  from PMP_Partner_Offering_Translation__c
                                  Where PMP_Partner_Offering_Id__c =: offeringId];
        }    
        return offTranslationList;
    }*/
    /** 
* @description Returns true if logged in user is an Intel employee
* @param Boolean
* Method Parameters - NA 
*/
    //Added by shahrukh
  //OPTIMISATION WW44
   /* @AuraEnabled(cacheable=true)
    public static Boolean isIntelEmployee(){        
        boolean isIntelEmployee = false;        
        List<PermissionSetAssignment> lstcurrentUserPerSet;   
        lstcurrentUserPerSet  =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                    FROM PermissionSetAssignment
                                    WHERE AssigneeId = :Userinfo.getUserId() ];        
        if(!lstcurrentUserPerSet.isEmpty()){
            for (PermissionSetAssignment psa: lstcurrentUserPerSet)
            {
                if(psa.PermissionSet.Name.equals('PMP_Internal_Intel_Read_Only') || psa.PermissionSet.Name.equals('PMP_Internal_Intel_Admin') || psa.PermissionSet.Name.equals('PMP_Internal_Intel_FAE')){
                    isIntelEmployee = true;
                }                 
            }        
            
        }        
        return isIntelEmployee; // Returing the boolean parameter
    }*/
    @AuraEnabled(cacheable=true)
public static Boolean isIntelEmployee(){

    Integer recCount = [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()
        AND PermissionSet.Name IN ('PMP_Internal_Intel_Read_Only','PMP_Internal_Intel_Admin','PMP_Internal_Intel_FAE')];

    return recCount > 0;
}
    /**
* Added by raj to check whether the user belongs to same partner as offering
* @description Returns true if the offering and user belongs to same partner
* @param - offering for which the check is to be done
* @method parameter - PMP_Partner_Offering__c
* @return Boolean
*/
    //OPTIMISATION WW44
    //commenting below method since its used in offerings-commented code
    /*
    public static Boolean isUserUnderSamePartner(PMP_Partner_Offering__c offering){
        
        Boolean isSamePartner = false;
        //system.debug('offering ' + offering);
        List<User> user = getLoggedInUser();
        //Modified as a part of OPID Resrtucture
        Set<Id> accIds = new Set<Id>();
        List<PMP_OPID_MPI_Rel__c> allJunctionRecs =  getJunctionAccToMpiByCompanyId(offering.PMP_Company_Id__c);
        //system.debug('allJunctionRecs' + allJunctionRecs);
        for(PMP_OPID_MPI_Rel__c singleJuncRec : allJunctionRecs){
            accIds.add(singleJuncRec.PMP_One_Partner_ID__c);
        }
        if((accIds.size() > 0) && (!String.isEmpty(user[0].Core_IPA_One_Partner_Id__c))){
            for(Id acc : accIds){
                if(user[0].Core_IPA_One_Partner_Id__c  == acc){
                    isSamePartner = true;
                    break;
                }
            }
        }                                       
        // Existing Logic               
        /*List<PMP_Company__c> company = [select Id,PMP_Account_Id__c, PMP_One_Partner_ID__c  from PMP_Company__c where Id=:offering.PMP_Company_Id__c];

if(!String.isEmpty(user[0].Core_IPA_One_Partner_Id__c) && !String.isEmpty(company[0].PMP_One_Partner_ID__c)){
if(user[0].Core_IPA_One_Partner_Id__c  == company[0].PMP_One_Partner_ID__c){
isSamePartner = true;
}
}
        
        return isSamePartner;
    }*/
    
    /**
* Added by raj to get the logged in user's languge
* @description Returns logged in user's language
* @return String
*/ 
    //OPTIMISATION WW44
    //commenting below method since its used in offerings-commented code
    /*
    public static String getLoggedInUsersLanguage(){
        String language = userInfo.getLanguage();
        
        return language;
    }*/
    
    /**
* Added by Abhishek - This method checks if the offering requires translation based on 
* business segment picklist values.      
* @return boolean
*/
//OPTIMISATION WW44
    //commenting below method since its not found to be used anywhere
    /*    public static boolean isTranslationRequired(PMP_Partner_Offering__c offering){
        
        List<PMP_Business_Segments__mdt> bizValuesFromMetaData = new List<PMP_Business_Segments__mdt>();
        
        bizValuesFromMetaData = [SELECT DeveloperName FROM PMP_Business_Segments__mdt where DeveloperName != null];
        
        List<String> finalBizSegmentValues;
        boolean translationRequired = false;
        if(offering.PMP_Business_Segment_Nm__c != null){
            finalBizSegmentValues = offering.PMP_Business_Segment_Nm__c.split(';');
        }
        
        if(offering.PMP_Business_Segment_Nm__c != null && !bizValuesFromMetaData.isEmpty()){
            //if(!bizValuesFromMetaData.isEmpty() ){ 
                for(PMP_Business_Segments__mdt bizValueRec :bizValuesFromMetaData){
                    
                    if(finalBizSegmentValues.contains(bizValueRec.DeveloperName ) ){
                        
                        translationRequired = true;  
                        break;
                    }
                }
            //}
        }
        return translationRequired;
    }*/
    /** 
* @description Returns true if ContactPartner Button should be displayed to the current user.
* Depends on permission set assigned to user
* @param Boolean
* Method Parameters - NA 
* @Autonr - Abhishek
*/
    
    
    public static Boolean showContactPartnerButton(){
        
        boolean showContactPartner = true;
        List<PermissionSetAssignment> lstcurrentUserPerSet;
        
        
        //query the permission sets assigned to the user        
        lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId
                                FROM PermissionSetAssignment
                                WHERE AssigneeId = :Userinfo.getUserId() ];
        
        //get the permission sets for which the button needs to be hidden from 'PMP_Static_Data__mdt' custom metadata                                                 
        string permissionsSetsToHide = getValue('Permission_Sets_To_Hide_CTP_Button');
        List<String> permissionSetList = permissionsSetsToHide.split(',');
        
        //iterate over the user permission sets and set the visiblity flag to false if the assigned permission set name is present in the list
        //of permission sets to be excluded
        if(!lstcurrentUserPerSet.isEmpty()){
            for (PermissionSetAssignment psa: lstcurrentUserPerSet)
            {
                //system.debug(psa.PermissionSet.Name);
                // if(psa.PermissionSet.Name.equals('PMP_Internal_Intel_Read_Only') || psa.PermissionSet.Name.equals('PMP_Internal_Intel_Admin') || psa.PermissionSet.Name.equals('PMP_Internal_Intel_FAE')){
                if(permissionSetList.contains(psa.PermissionSet.Name)){
                    showContactPartner = false ;
                }    
                
            }        
        }
        
        return showContactPartner ; // Returing the boolean parameter
    }
    //Sandhya : To get the Base Community URL
    @AuraEnabled(cacheable = true)
    Public static String getBaseCommunityUrl(){
        String communityURL;
        Network myNetwork;
        
        myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
        
        
        if(myNetwork!=Null){
            communityURL = Network.getLoginUrl(myNetwork.Id);
            //remove the word login from the community URL and append with offering 
            communityURL = communityURL.substringBeforeLast('/') ;
        }        
        //Sandhya : we need to check if SFDC outofthe box method will return "/s" at the end         
        if(!communityURL.endsWith('/s')){
            communityURL = communityURL + '/s';
        } 
        return communityURL;
    }
    
    Public static String getObjectFields(DescribeSObjectResult objFields){
        
        List<String> objFieldNames = new List<String>(objFields.fields.getMap().keySet() );    
        String objQuery =    ' SELECT ' +        String.join( objFieldNames, ',' ) +    ' FROM ' + objFields.getName() ;
        return objQuery;
    }
    /**
* Added by raj to get ContentDocumentLink instance
* @description-method return ContentDocumentLink Instance
* @Param-docId,contentDocumentId of the file to be linked
* @Param-LinkId,Id of the record to be linked with file
* @return-ContentDocumentLink
* MethodParameters-Id, Id
**/
  /*  public static ContentDocumentLink getContentDocumentLinkInstance(Id docId, Id LinkId){
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.ShareType = 'I';
        cdl.LinkedEntityId = LinkId;
        cdl.Visibility = 'AllUsers';
        
        return cdl; 
    }*/
    
    /**
* Added by raj to get sequence number for specification
* @description-method returns sequence number for specifications
* @Param-specNodeByAttribute,childSpecsByAttribute of the specification for which sequence number is to be constructed
* @return-Integer
* MethodParameters-Map<String, Object>, Map<String, Object>
**/
    public static Integer getSpecificationSequenceNumber(Map<String, Object> specNodeByAttribute, Map<String, Object> childSpecsByAttribute){
        
        String parentSpecLevel = String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Level));//get the level of parent specification
        String parentSpecSequence = String.valueOf(specNodeByAttribute.get(PMP_StaticConstants_MasterData.Sequence)).remove(',');//get the sequence number of parent specification
        String specSequence = String.valueOf(childSpecsByAttribute.get(PMP_StaticConstants_MasterData.SpecValueSequence)).remove(',');//get the sequence number of the child specification
        
        return Integer.valueOf(parentSpecLevel + parentSpecSequence + specSequence);//concatenate all three [parentSpecLevel + parentSpecSequence + specSequence] and return integer value of it
    }
    
    /** 
* @Author           - Prakash
* @Description      - Method to return a query string contains all the fields of an object
* @Param            - sObjectName - Name on the object from which we are preparing a query
* @Param            - isFinalSelectClause - for any related fields to be added , set to true
* Method Parameters - String , Boolean
* @return String
*/
    public static string queryAllFields(String sObjectName,Boolean isFinalSelectClause){
        String objectName = sObjectName ;
        //System.debug('objectName:'+objectName);
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // get the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
            query += ' ' + s + ', ';
        }
        // Strip off the last comma if it exists.
        if (query.subString(query.Length()-2,query.Length()-1) == ','){
            query = query.subString(0,query.Length()-2);
        }
        // Add FROM statement if no more fields to be added in select clause like fields from related object
        if(isFinalSelectClause) {
            query += ' FROM ' + objectName;
        }
        
        return query;
    }
    /**
* @description 
* @author Abhishek | 6/17/2020 
* @param Set<id> accIdSet 
* @param List<string> allowedPermissionSets 
* @return set<id> 
**/
    //OPTIMISATION WW44
    //Method not found to be used anywhere
    /*public static Set<Id> fetchUsersFromPagMember(Set<Id> accIdSet, List<String> allowedPermissionSets) {
        Set<Id> userIds = new Set<Id>();
        
        if(!accIdSet.isEmpty()){
            Set<Id> partnerAccIdSet = getPartnerAccountIds(accIdSet);
            
            if(!partnerAccIdSet.isEmpty() || Test.isRunningTest()){
                Set<Id> intelAccountIds = getIntelAccountIds(partnerAccIdSet);
                userIds = getUserIds(intelAccountIds, allowedPermissionSets);
                }
        }
        
        return userIds;
    }
    
    private static Set<Id> getPartnerAccountIds(Set<Id> accIdSet) {
        Set<Id> partnerAccIdSet = new Set<Id>();
        
        for (Core_Account_Group_Member__c member : [SELECT Core_Partner_Account_Id__c 
                                                    FROM Core_Account_Group_Member__c 
                                                    WHERE Core_Intel_Account_Id__c IN :accIdSet 
                                                    AND Core_Inactive_Ind__c = false]) {
            partnerAccIdSet.add(member.Core_Partner_Account_Id__c);
        }
        
        return partnerAccIdSet;
    }

    private static Set<Id> getIntelAccountIds(Set<Id> partnerAccIdSet) {
        Set<Id> intelAccountIds = new Set<Id>();
        
        for (Core_Account_Group_Member__c mem : [SELECT Core_Intel_Account_Id__c 
                                                FROM Core_Account_Group_Member__c 
                                                WHERE Core_Partner_Account_Id__c IN :partnerAccIdSet]) {
            intelAccountIds.add(mem.Core_Intel_Account_Id__c);
        }
        
        return intelAccountIds;
    }

    private static Set<Id> getUserIds(Set<Id> intelAccountIds, List<String> allowedPermissionSets) {
        Set<Id> userIds = new Set<Id>();
        
        if (!allowedPermissionSets.isEmpty()) {
            for (PermissionSetAssignment pa : [SELECT AssigneeId 
                                                FROM PermissionSetAssignment 
                                                WHERE Assignee.AccountId IN :intelAccountIds 
                                                AND PermissionSet.Name IN :allowedPermissionSets]) {
                userIds.add(pa.AssigneeId);
            }
        }
        
        return userIds;
    }*/
    
    /**
* @description 
* @author Abhishek | 6/17/2020 
* @param List<PMP_Company__c> compInfoList 
* @param List<string> allowedPermissionSets 
* @return map<id, id> 
**/
    public static Map<Id, Id> fetchUsersMapFromPagMember(List<PMP_Company__c> compInfoList, List<String> allowedPermissionSets) {
        Map<Id, Id> userCompanyMap = new Map<Id, Id>();
        
        // Step 1: Initialize necessary collections
        Set<Id> intelAccountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, Id> accIdCompInfoMap = new Map<Id, Id>();
        Map<Id, Id> intelAccCompInfoMap = new Map<Id, Id>();
        
        // Step 2: Populate accIdCompInfoMap with Account to Company Mapping
        if(!compInfoList.isEmpty()){
            Set<Id> companyIds = new Set<Id>();
            for(PMP_Company__c compInfo : compInfoList){
                companyIds.add(compInfo.Id);                
            }
            accIdCompInfoMap = PMP_Utility.getMapAccountToMpiByAllCompanyId(companyIds);
        }
            
        // Step 3: Process Core Account Group Members
        if (!accIdCompInfoMap.isEmpty()) {
            Set<Id> partnerAccIds = new Set<Id>(accIdCompInfoMap.keySet());
            List<Core_Account_Group_Member__c> pagMemberList = [SELECT Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
                                                                FROM Core_Account_Group_Member__c 
                                                                WHERE Core_Partner_Account_Id__c IN :partnerAccIds 
                                                                AND Core_Inactive_Ind__c = false];
                
                for(Core_Account_Group_Member__c mem : pagMemberList){
                    intelAccountIds.add(mem.Core_Intel_Account_Id__c);
                    intelAccCompInfoMap.put(mem.Core_Intel_Account_Id__c, accIdCompInfoMap.get(mem.Core_Partner_Account_Id__c));
                }
            
            // Step 4: Process PermissionSetAssignments
                if(!allowedPermissionSets.isEmpty()){
                List<PermissionSetAssignment> permissionAssignmentList = [SELECT AssigneeId, Assignee.AccountId 
                                                                        FROM PermissionSetAssignment 
                                                                        WHERE Assignee.AccountId IN :intelAccountIds 
                                                                        AND PermissionSet.Name IN :allowedPermissionSets];
                    for(PermissionSetAssignment pa : permissionAssignmentList){
                        userCompanyMap.put(pa.AssigneeId, intelAccCompInfoMap.get(pa.Assignee.AccountId) );
                        userIds.add(pa.AssigneeId);
                    }
                }
        }
        
        return userCompanyMap;
    }
    
    
    /** 
* @Author           - Prakash
* @Description      - Method to return Alert to Email Setting data based on passed alert name
* @Param            - eventName - event name to pick email setting data
* Method Parameters - String
* @return String
*/
   //IPA 2.0-US-TWC729-7981 
    /*public static PMP_Alert_To_Email_Setting__mdt getAlertToEmailSettingData(String eventName) {
        PMP_Alert_To_Email_Setting__mdt settingData = new PMP_Alert_To_Email_Setting__mdt();
        //querying metadata to get the email template name and permission sets required for External user to send email
        
        settingData = [SELECT  Id,
                       DeveloperName,
                       MasterLabel,
                       PMP_Allowed_Permission_Set__c, 
                       PMP_Email_Template_Name__c
                       
                       FROM  PMP_Alert_To_Email_Setting__mdt
                       WHERE DeveloperName =: eventName limit 1];
        
        return settingData;
    }*/
    
    /** 
* @Author           - Prakash
* @Description      - Method to return email template
* @Param            - templateName - Name of the template
* Method Parameters - String
* @return EmailTemplate
*/
    
    public static EmailTemplate getEmailTemplate(String templateName) {
        
        EmailTemplate templateData = new EmailTemplate();
        //querying email template details based on name
        
        templateData = [SELECT Id,Name,
                        Subject,
                        Body 
                        FROM EmailTemplate 
                        WHERE DeveloperName =: templateName];
        
        return templateData;
        
    }
    
    /**
*  @description      : Whenever an exception is passed as an argument, it will call the getErrorDetails method and
*                      pass the string returned to create the Log Entry record through the logErrorInLogObject method.
*  @name             : logError
*  @param            : Exception
*  @throws exception : NONE
**/
    public static void logError(Exception e,string projectName){
        
        string scope =  e.getStackTraceString().substringBefore(':');
        
        string classWithMethod = scope.substringafter('Class.');
        
        string className = classWithMethod.substringbefore('.');
        
        string details = 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
            'Exception Message = ' + e.getMessage() + ';\n' +
            'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
            'StackTrace = ' + e.getStackTraceString();
        
        String subject = 'An exception has been thrown for'+ ':' + scope;
        
        Map<String, String> exceptionMap = new Map<String, String>();
        exceptionMap.put('Core_Details__c', details);
        exceptionMap.put('Core_Message__c', subject);
        exceptionMap.put('Core_Origin__c', className);
        exceptionMap.put('Core_Project__c',projectName);
        exceptionMap.put('Core_Scope__c',scope);
        exceptionMap.put('Core_Severity__c', 'Critical');
        createLogEntry(exceptionMap);
    }
    
/**
* Method Name : logSaveResultErrors
* Return Type : Void
* Description : Logs DML errors by extracting class and method from projectName like "Class-Method"
**/

public static void logDmlErrors(Object[] results, String projectName) {
    String className = projectName.contains('-') ? projectName.substringBefore('-') : 'UnknownClass';
    String methodName = projectName.contains('-') ? projectName.substringAfter('-') : 'UnknownMethod';

    List<Core_Log_Entry__c> logsToInsert = new List<Core_Log_Entry__c>();

    for (Integer i = 0; i < results.size(); i++) {
        Object res = results[i];
        Boolean success = true;
        Database.Error[] errorArray;

        // Determine type and extract errors
        if (res instanceof Database.SaveResult) {
            Database.SaveResult sr = (Database.SaveResult) res;
            success = sr.isSuccess();
            errorArray = sr.getErrors();
        } else if (res instanceof Database.DeleteResult) {
            Database.DeleteResult dr = (Database.DeleteResult) res;
            success = dr.isSuccess();
            errorArray = dr.getErrors();
        } else if (res instanceof Database.UpsertResult) {
            Database.UpsertResult ur = (Database.UpsertResult) res;
            success = ur.isSuccess();
            errorArray = ur.getErrors();
        } else if (res instanceof Database.UndeleteResult) {
            Database.UndeleteResult udr = (Database.UndeleteResult) res;
            success = udr.isSuccess();
            errorArray = udr.getErrors();
        } else {
            continue; // Skip unknown types
        }

        // Log only the first error if any
        if (!success && errorArray != null && errorArray.size() > 0) {
            Database.Error err = errorArray[0]; // First error only

            String details = 'Class & Method Name = ' + className + '.' + methodName + ';\n' +
                             'Exception Message = ' + err.getMessage() + ';\n' +
                             'Status Code = ' + err.getStatusCode() + ';\n' +
                             'Fields = ' + String.valueOf(err.getFields());

            String subject = 'A database exception occurred in: ' + className + '.' + methodName;

            logsToInsert.add(new Core_Log_Entry__c(
                Core_Details__c   = details.left(32000),
                Core_Message__c   = subject.left(255),
                Core_Origin__c    = className.left(255),
                Core_Project__c   = 'PMP',
                Core_Scope__c     = projectName.left(255),
                Core_Severity__c  = 'High',
                Core_When__c      = System.now()
            ));
        }
    }

    // Insert all logs at once
    if (!logsToInsert.isEmpty()) {
        try {
            insert logsToInsert;
        } catch (Exception e) {
            System.debug('Failed to insert log entries: ' + e.getMessage());
        }
    }
}


    /**
*  @description      : Create Log Object by passing the logObject field names and values in the Map
*  @name             : createLogEntry
*  @param            : String, Map
*  @throws exception : NONE
**/
    public static void createLogEntry(Map<String, String> exceptionMap){
        Core_Log_Entry__c cle = new Core_Log_Entry__c();
        
        DateTime dtWhen = system.now();
        Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
        if(exceptionMap!= null && exceptionMap.size() > 0){    
            for(String key:exceptionMap.keySet()){        
                if(logFields.containsKey(key)){
                    Schema.DescribeFieldResult field= logFields.get(key).getDescribe();    
                    Integer length = field.getLength();
                    String value = String.valueOf(exceptionMap.get(key));                        
                    cle.put(key, value.left(length));                        
                }
            }
            
            
            if(cle != null){
                cle.put('Core_When__c',dtWhen);
                database.insert(cle);    
            }
        }                              
        
        
    }
    /**
*  @description      : get email template by passing templates DeveloperName
*  @name             : fetchEmailTemplate
*  @param            : String
*  @throws exception : NONE
**/
    //OPTIMISATION - WW44
    //commenting below method, already same return type method present-getEmailTemplate and this method not found to be used anywhere
   /* public static EmailTemplate fetchEmailTemplate(string TemplateName){
        
        EmailTemplate template;
        
        template = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName =:  TemplateName ];
        
        return template;
    }*/
    
    
    public static void insertEmailLogRecords(List<PRM_EmailLog__c> logList, List<Messaging.SendEmailResult> resultList) {
        Map<String, PRM_EmailLog__c> targetIdLog = populateTargetIdLog(logList, resultList);
        processSendEmailResults(resultList, targetIdLog);
        upsertEmailLogs(logList);
            }
            
    private static Map<String, PRM_EmailLog__c> populateTargetIdLog(List<PRM_EmailLog__c> logList, List<Messaging.SendEmailResult> resultList) {
        Map<String, PRM_EmailLog__c> targetIdLog = new Map<String, PRM_EmailLog__c>();
        
        for (PRM_EmailLog__c log : logList) {
            if (resultList != null) {
                log.PRM_Email_API_Response__c = 'Mail sent successfully !!';
            }
            if (log.PRM_Contact__c != null) {
                targetIdLog.put(log.PRM_Contact__c, log);
            } else if (log.PRM_User__c != null) {
                targetIdLog.put(log.PRM_User__c, log);
            }
        }
        
        return targetIdLog;
    }
    
    private static void processSendEmailResults(List<Messaging.SendEmailResult> resultList, Map<String, PRM_EmailLog__c> targetIdLog) {
        if (resultList != null) {
            for (Messaging.SendEmailResult result : resultList) {
                if (!result.isSuccess()) {
                    updateEmailLogs(result, targetIdLog);
                }
            }
        }
    }
    
    private static void updateEmailLogs(Messaging.SendEmailResult result, Map<String, PRM_EmailLog__c> targetIdLog) {
                    for( Messaging.SendEmailError error : result.getErrors()) {
                        String targetId= error.getTargetObjectId();
                        String errorMsg= error.getMessage();
            if (targetId != null && targetIdLog.containsKey(targetId)) {
                            PRM_EmailLog__c log = targetIdLog.get(targetId);
                            log.PRM_EmailDeliverabilityStatus__c = false;
                            log.PRM_Email_API_Response__c = errorMsg ;
                        }
                    } 
                }
    
    private static void upsertEmailLogs(List<PRM_EmailLog__c> logList) {
        if (logList != null && !logList.isEmpty()) {
            upsert logList; 
        }
    }
    
    
    
    
    /**
* @description method to create the email log instance.
* @author Balaji M | 6/17/2020 
* @param Messaging.SingleEmailMessage renderedMail 
* @param Messaging.SingleEmailMessage mail 
* @param String lang 
* @param String templateName 
* @return PRM_EmailLog__c 
**/
    public static PRM_EmailLog__c createEmailLogInstance(Messaging.SingleEmailMessage renderedMail,Messaging.SingleEmailMessage mail,String lang,String templateName, Messaging.SingleEmailMessage renderedMailOriginalCopy)
    {   
        
        // intialize  PRM_EmailLog__c obj for email log with input params
        PRM_EmailLog__c log = new PRM_EmailLog__c();
        String successMsg ='Pending';
        //String toEmailId;
        log.PRM_EmailDeliverabilityStatus__c = true ;
        log.PRM_Timestamp__c = DateTime.now();
        log.Language__c = lang ;
        log.Email_Template_Name__c = templateName ;
        log.PRM_Email_API_Response__c = successMsg ;
        log.PRM_Type__c='IPA'; 
        // assinging the PRM_EmailContent__c and PRM_Subject__c with renderedMail Param with help of renderStoredEmailTemplate method.
        // adding renderedMailOriginalCopy records id  along with the subject and email content
        if(renderedMailOriginalCopy != null){
            log.PRM_EmailContent__c =  renderedMail.getHtmlBody()  + renderedMailOriginalCopy.getTargetObjectId(); 
            log.PRM_Subject__c = renderedMail.getSubject().left(220)+ renderedMailOriginalCopy.getTargetObjectId();
        }
        else{
            log.PRM_EmailContent__c =  renderedMail.getHtmlBody(); 
            log.PRM_Subject__c = renderedMail.getSubject().left(220);    
        }        
        
        // checking for mail getTargetObjectId() not null and then Assigning PRM_User__c with the Respective getTargetObjectId.
        if(mail.getTargetObjectId() != null)
        {
            //system.debug('@@Inside IF');
            String objType = String.valueof(mail.getTargetObjectId().getSObjectType());
            //system.debug('@@After Sobject type');
            if (objType == 'User') {
                log.PRM_User__c = mail.getTargetObjectId();
            }
            else if(objType == 'Contact'){
                log.PRM_Contact__c = mail.getTargetObjectId();
            } 
        }
        // checking for mail getWhatId() and assign the whatid to respective object.
        Id whatId= mail.getWhatId();
        if(mail.getWhatId() != null){
            String objType = String.valueof(whatId.getSObjectType());
            if(objType == 'PMP_Partner_Offering__c'){
                log.PMP_Partner_Offering__c= mail.getWhatId();             
            }
            else if(objType == 'PMP_Company__c'){
                log.PMP_Company__c= mail.getWhatId();              
            }
         /*IPA2.0: US-TWC729-7976*/
            /*else if(objType == 'ArdiraSurvey__Survey_Result__c'){
                log.PSS_Partner_Solution__c= mail.getWhatId();
            }*/
            
        }
        
        
        
        return log;
    }
    
    /**
* @description Method to filter out the Inactive user in the map before 
* @author Balaji M | 6/17/2020 
* @param Map<Id Id> userWhatIDMap 
* @return Map<Id, Id> 
**/
    public static Map<Id, Id> removeInactiveUsers(Map<Id,Id> userWhatIDMap){
        List<User> inactiveUsers= [Select id, name from User where id IN :userWhatIDMap.keySet() and IsActive = false];
        //OPTIMISATION - WW44
        //Unnecessary looping ,already this filter present in above soql.
       // for(ID userId :userWhatIDMap.keySet()){//removeall
            for(User u :inactiveUsers){
                userWhatIDMap.remove(u.id);
            }
        //}
        return userWhatIDMap;
        
    }    
    
    /**
* @description Method to create email instances using the Email Template Id. Everyone should use this
* @author Prakash | 4/29/2020 
* @param String emailTemplateID 
* @param Map<Id,Id> userIdWhatIdMap
* @return List<Messaging.SingleEmailMessage>
**/
    public static List<Messaging.SingleEmailMessage> createEmailInstances(String emailTemplateID,Map<Id,Id> userIdWhatIdMap) {
        OrgWideEmailAddress owa = getOrgWideEmailAddress();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        //Map<Id, ArdiraSurvey__Survey_Result__c> solMap = getSolutionMap(userIdWhatIdMap);//IPA2.0: US-TWC729-7976 
        String subject = 'Subject for Test Class';
        String htmlBody = 'Email Body content for TestClass';

        for (Id userId : userIdWhatIdMap.keySet()) {
            Messaging.SingleEmailMessage emailMessage = createSingleEmailMessage(emailTemplateID, userIdWhatIdMap.get(userId), userId, owa, subject, htmlBody);
            addCcAddressesIfRequired(emailMessage, userId/*, solMap*/);
            emailMessages.add(emailMessage);
        }

        return emailMessages;
    }

    private static OrgWideEmailAddress getOrgWideEmailAddress() {
        return [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.PMP_Intel_partner_Alliance_Address LIMIT 1];
    }
  /*IPA2.0: US-TWC729-7976*/
    //private static Map<Id, ArdiraSurvey__Survey_Result__c> getSolutionMap(Map<Id, Id> userIdWhatIdMap) {
        //Map<Id,ArdiraSurvey__Survey_Result__c> solMap = new Map<Id,ArdiraSurvey__Survey_Result__c>();                          

       /* 
       if (!userIdWhatIdMap.isEmpty() && userIdWhatIdMap.values()[0] != null) {
            String sobjectType = String.valueOf(userIdWhatIdMap.values()[0].getSObjectType());
            if (sobjectType == 'ArdiraSurvey__Survey_Result__c' && !PSS_SendEmailAlertsForSolutions.solListForMRS_RRK.isEmpty()) {
            solMap.putAll(PSS_SendEmailAlertsForSolutions.solListForMRS_RRK);
            PSS_SendEmailAlertsForSolutions.solListForMRS_RRK.clear();
        }
        }
        */
        
        //return solMap;
    //}

    private static Messaging.SingleEmailMessage createSingleEmailMessage(String emailTemplateID, Id whatId, Id userId, OrgWideEmailAddress owa, String subject, String htmlBody) {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setWhatId(whatId);
        emailMessage.setTargetObjectId(userId);
        emailMessage.setTemplateId(emailTemplateID);
        emailMessage.setSaveAsActivity(false);

        if (owa != null) {
            emailMessage.setOrgWideEmailAddressId(owa.Id);
            }
            
            if(Test.isRunningTest()){
            emailMessage.setSubject(subject);
            emailMessage.setHtmlBody(htmlBody);
            }
            
        return emailMessage;
    }
    //IPA2.0: US-TWC729-7976       
    private static void addCcAddressesIfRequired(Messaging.SingleEmailMessage emailMessage, Id userId/*, Map<Id, ArdiraSurvey__Survey_Result__c> solMap*/) {
        /*if (!solMap.isEmpty() && solMap.containsKey(emailMessage.getWhatId()))*/ 
            //ArdiraSurvey__Survey_Result__c solution = solMap.get(emailMessage.getWhatId());
            /*if (solution.PSS_Solution_Submitter_UserId_Id__r.ContactId == userId || 
                solution.PSS_Solution_Submitter_UserId_Id__c == userId) {*/
                emailMessage.setCcAddresses(System.Label.PSS_Iot_MarketReady_Email.split(';'));
            }
                
            
            
    
    
    /**
* @description method to handle the logging activites for Email and to fire the email
* @author Balaji M | 6/17/2020 
* @param String emailtempName 
* @param Map<id id> userWhatIDMap 
* @return void 
**/
    public static void sendEmailAndLogData(String emailtempName, Map<Id, Id> userWhatIDMap) {
        try{
            EmailTemplate  template = PMP_Utility.getEmailTemplate(emailtempName);
            Map<Id, Id> whatIdMap = buildWhatIdMap(userWhatIDMap);
                
            if (!whatIdMap.isEmpty()) {
                List<Messaging.SingleEmailMessage> emailsToBeSent = createEmailInstances(template.Id, whatIdMap);
                List<PRM_EmailLog__c> emailLogList = createEmailLogInstances(emailsToBeSent, template, whatIdMap);
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToBeSent,false);
                insertEmailLogRecords(emailLogList, results);
            }
        } catch (Exception e) {
            PMP_Utility.logError(e,'PMP_Utility-SendEmailAndLogData');
        }
    }

    private static Map<Id, Id> buildWhatIdMap(Map<Id, Id> userWhatIDMap) {
        Map<Id, Id> whatIdMap = new Map<Id, Id>();
        List<User> userContactList = [SELECT Id, ContactId, Contact.Core_Do_Not_Contact__c, Contact.Core_isEmailBounced_Ind__c 
                                    FROM User WHERE Id IN :userWhatIDMap.keySet()];
        
        for (User user : userContactList) {
            if (user.ContactId != null && !user.Contact.Core_Do_Not_Contact__c && !user.Contact.Core_isEmailBounced_Ind__c) {
                whatIdMap.put(user.ContactId, userWhatIDMap.get(user.Id));
            } else if (user.ContactId == null) {
                whatIdMap.put(user.Id, userWhatIDMap.get(user.Id));
            }
        }
        
        return whatIdMap;
    }

    private static List<PRM_EmailLog__c> createEmailLogInstances(List<Messaging.SingleEmailMessage> emailsToBeSent, EmailTemplate template, Map<Id, Id> whatIdMap) {
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        List<Id> userWhatIDKeyList = new List<Id>(whatIdMap.keySet());
        Messaging.SingleEmailMessage renderedMailWorkingCopy = Messaging.renderStoredEmailTemplate(template.Id, userWhatIDKeyList[0], whatIdMap.get(userWhatIDKeyList[0]));
        Messaging.SingleEmailMessage renderedMailSample = Messaging.renderStoredEmailTemplate(template.Id, null, null);
        
        for (Messaging.SingleEmailMessage singleEmail : emailsToBeSent) {
            if (singleEmail.getTargetObjectId() == userWhatIDKeyList[0]) {
                emailLogList.add(PMP_Utility.createEmailLogInstance(renderedMailWorkingCopy, singleEmail, 'English', template.Name, null));
            } else {
                emailLogList.add(PMP_Utility.createEmailLogInstance(renderedMailSample, singleEmail, 'English', template.Name, renderedMailWorkingCopy));
            }
        }
        
        return emailLogList;
    }

    Public static Core_Apex_EmailNotification__c getApexEmailRecord(string recordName){
        Core_Apex_EmailNotification__c emailNotification;
        
        
        emailNotification = [Select Name, Core_Allowed_Permission_Nm__c,
                             Core_Date_Reference_Txt__c,
                             Core_Description_Txt__c,
                             Core_Email_Template_Nm__c,
                             Core_IsActive_Ind__c,
                             Core_IsRecurring_Ind__c,
                             Core_NumberOfDays_Nbr__c,
                             Core_Object_Nm__c,
                             Core_Query_String_Txt__c 
                             From Core_Apex_EmailNotification__c Where Name =: recordName limit 1];
        
        Return emailNotification;
        
        
    }
    
    /**
* @description method to return company information for the opid
* @author Gireesh K: US707407 | 06/July/2020 
* @param Id opid 
* @return PMP_Company__c 
* @disclaimer: Make sure to check conditions for the following fields:PMP_Benefit_Update_Ind__c, PMP_Partner_Inactive_Ind__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Partner_Benefit_Type__c
* @used at: PMP_CreateOfferingTab1Service, Core_UtilityController
**/   
    public static List<PMP_Company__c> getCompanyInfoForOpid(Id opid){
        //System.debug('opid:'+opid);
        
        List<PMP_Company__c> companylist = new List<PMP_Company__c>();
        
        //Modified as a part of OPID Restucture
        List<PMP_OPID_MPI_Rel__c> allJunctionRecs= new List<PMP_OPID_MPI_Rel__c>();
        //List<Id> companyIds = new List<Id>();
        if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){
            allJunctionRecs = [ select Id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,Is_Active__c
                               from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =: opid and Is_Active__c = true limit 1];
        }
        
        if(Schema.sObjectType.PMP_Company__c.isAccessible() && allJunctionRecs.size()>0 && !allJunctionRecs.isEmpty()){
            companylist = [SELECT id, Name, PMP_Benefit_Update_Ind__c, PMP_Partner_Inactive_Ind__c, PMP_Company_Lifecycle_Status_Nm__c, 
                           PMP_Partner_Benefit_Type__c from PMP_Company__c where id =: allJunctionRecs[0].PMP_Marketing_Profile_Id__c and
                           PMP_Is_Published_Ind__c=true and PMP_Benefit_Update_Ind__c=false];
        }  
        //Existing Logic
        /*if(Schema.sObjectType.PMP_Company__c.isAccessible()){
companylist = [SELECT id, Name, PMP_Benefit_Update_Ind__c, PMP_Partner_Inactive_Ind__c, PMP_Company_Lifecycle_Status_Nm__c, 
PMP_Partner_Benefit_Type__c from PMP_Company__c where 
PMP_Is_Published_Ind__c=true and PMP_One_Partner_ID__c =:opid and PMP_Benefit_Update_Ind__c=false];
} */   
        return companylist;
    }
    
    
    /**
* @description method to return loggedin user with OPID
* @author Gireesh K: US707407 | 06/July/2020 
* @param null
* @return User
* @used at: PMP_CreateOfferingTab1Service, Core_UtilityController
**/   
    public static List<User> getLoggedInUser(){
        return [select id,Name,Core_IPA_One_Partner_Id__c , Email,ContactId, AccountId, IsPortalEnabled FROM User Where id = :userInfo.getUserId()];
    }
    
    /**
* Added by raj to get sorting rank for a value
* @description-method returns rankByValue Map, eg: Map<'Gold', 2>
* @Param-sortType, specifies the type of mapping
* @return-Map<String, Integer>
* MethodParameters-String
**/
    /*public static Map<String, Integer> getRankByValue(String sortType){
Map<String, Integer> rankByTier = new Map<String, Integer>();

for(PMP_CustomSort_Mapping__mdt so : [SELECT Value__c, Rank__c, Sort_Type__c FROM PMP_CustomSort_Mapping__mdt where Sort_Type__c =: sortType]){
rankByTier.put(so.Value__c, (Integer)so.Rank__c);
}

return rankByTier;
}*/
    
    /**
* Added by raj to get the partners in a sorted manner
* @description-method returns List of sorted partners (eg: Titanium > Gold > Member)
* @Param-partners, contains the list of partners
* @return-List<PMP_SearchPartnerController.Partner>
* MethodParameters-(List<PMP_SearchPartnerController.Partner>
**/
    /*public static List<PMP_SearchPartnerController.Partner> getSortedPartners(List<PMP_SearchPartnerController.Partner> partners){
Map<Integer, List<PMP_SearchPartnerController.Partner>> valuesByRank = new Map<Integer, List<PMP_SearchPartnerController.Partner>>();
List<PMP_SearchPartnerController.Partner> sortedPartners = new List<PMP_SearchPartnerController.Partner>();
for(PMP_SearchPartnerController.Partner partner: partners){
if(valuesByRank.containsKey(partner.partnerRank)){
valuesByRank.get(partner.partnerRank).add(partner);
}
else{
valuesByRank.put(partner.partnerRank, new List<PMP_SearchPartnerController.Partner>{partner});
}
}

List<Integer> valueRanks = new List<Integer>();
valueRanks.addAll(valuesByRank.keySet());
valueRanks.sort();

for(Integer rank : valueRanks){
sortedPartners.addAll(valuesByRank.get(rank));
}

return sortedPartners;
}*/
    
    /**
* @description method to get the {0} replace with the dynamic values for CUSTOM LABEL
* @author Balaji M | 8/28/2020 
* @param String labelValue
* @param String dynamicValue
* @return String labelValue 
**/
    //OPTIMISATION - WW44
    //Commenting the below method since its used in PMP_TaxonomyStore, which is commented
  /*  public static String getReplacedWithDynamicValue(String labelValue, String dynamicValue){
        String regex = '\\{.*?\\}';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(labelvalue);
        
        if(regexMatcher.find()) {
            labelvalue = labelvalue.replaceAll(regex, dynamicValue);
        }
        else{
            //system.debug('not matched');
        }
        return labelvalue;
    }*/
    
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : sendEmailAndLogDataWithBulkification
* Description : This method will send the emails and logs the emails.
* Params      : emailtempName (String) , Map<id,List<id>> userWhatIDMap
* Version     : 1.0 
* Created Date: 24-Nov-2020
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
   //OPTIMISATION - WW44
   //Method not found to be used anywhere 
    /*public static void sendEmailAndLogDataWithBulkification(String emailtempName, Map<Id, List<Id>> userWhatIDMap) {
        try{
            EmailTemplate  template = PMP_Utility.getEmailTemplate(emailtempName);
            Map<Id, List<Id>> whatIdMap = buildWhatIdMap(userWhatIDMap);
            
            if (!whatIdMap.isEmpty()) {
                List<Messaging.SingleEmailMessage> emailsToBeSent = createEmailInstancesWithBulkification(template.Id, whatIdMap);
                List<PRM_EmailLog__c> emailLogList = createEmailLogInstances(emailsToBeSent, template, whatIdMap, emailtempName);
                insertEmailLogRecords(emailLogList, null);
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToBeSent,false);
                insertEmailLogRecords(emailLogList, results);
            }
        } catch (Exception e) {
            PMP_Utility.logError(e,'PMP_Utility-SendEmailAndLogDataWithBulkification');
        }
    }*/
    
   /* private static Map<Id, List<Id>> buildWhatIdMap(Map<Id, List<Id>> userWhatIDMap) {
        Map<Id, List<Id>> whatIdMap = new Map<Id, List<Id>>();
        List<User> userContactList = [SELECT Id, ContactId, Contact.Core_Do_Not_Contact__c, Contact.Core_isEmailBounced_Ind__c 
                                    FROM User WHERE Id IN :userWhatIDMap.keySet()];
        
        for (User user : userContactList) {
            if (user.ContactId != null && !user.Contact.Core_Do_Not_Contact__c && !user.Contact.Core_isEmailBounced_Ind__c) {
                whatIdMap.put(user.ContactId, userWhatIDMap.get(user.Id));
            } else if (user.ContactId == null) {
                whatIdMap.put(user.Id, userWhatIDMap.get(user.Id));
            }
        }
        
        return whatIdMap;
    }
*/
   /* private static List<PRM_EmailLog__c> createEmailLogInstances(List<Messaging.SingleEmailMessage> emailsToBeSent, EmailTemplate template, Map<Id, List<Id>> whatIdMap, String emailtempName) {
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        List<Id> userWhatIDKeyList = new List<Id>(whatIdMap.keySet());
        Messaging.SingleEmailMessage renderedMailWorkingCopy = Messaging.renderStoredEmailTemplate(template.Id, userWhatIDKeyList[0], whatIdMap.get(userWhatIDKeyList[0])[0]);
        Messaging.SingleEmailMessage renderedMailSample = Messaging.renderStoredEmailTemplate(template.Id, null, null);
        Boolean isFirstRecord = true;
        
        for (Messaging.SingleEmailMessage singleEmail : emailsToBeSent) {
             //ipa 2.0 email templates eol
  /*if (isFirstRecord || emailtempName.contains('PMP_OfferingExpiryFinalReminder') || emailtempName.contains('PMP_OfferingExpiryFirstReminder') || emailtempName.contains('PMP_OfferingExpirySecondReminder')) {
                emailLogList.add(PMP_Utility.createEmailLogInstance(renderedMailWorkingCopy, singleEmail, 'English', template.Name, null));
                isFirstRecord = false;
            } else {*/
              /*  emailLogList.add(PMP_Utility.createEmailLogInstance(renderedMailSample, singleEmail, 'English', template.Name, renderedMailWorkingCopy));
           // }
        }
        
        return emailLogList;
    }*/

    
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : createEmailInstancesWithBulkification
* Description : This method returns the list of emails to send 
* Params      : emailTemplateID (String) , Map<id,List<id>> userWhatIDMap, 
* Version     : 1.0 
* Created Date: 24-Nov-2020
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
    
    //OPTIMISATION WW44
    //Below method used in same class, but that method is commented now since it was not found to be used anywhere
   /* public static List<Messaging.SingleEmailMessage> createEmailInstancesWithBulkification(String emailTemplateID,Map<Id,List<Id>> userIdWhatIdMap) {
        
        OrgWideEmailAddress owa = New OrgWideEmailAddress ();    
        
        
        owa =  [select id, Address, DisplayName from OrgWideEmailAddress Where Address = :System.Label.PMP_Intel_partner_Alliance_Address limit 1]; 
        
        List<Messaging.SingleEmailMessage> tmpltmails =  new List<Messaging.SingleEmailMessage>();
        String subject = 'Subject for Test Class';
        String htmlBody = 'Email Body content for TestClass';
        // creating email instances for the userIdWhatIdMap
        for(Id u : userIdWhatIdMap.keySet()){
            for(Id targetId:userIdWhatIdMap.get(u)){
                Messaging.SingleEmailMessage templmail = new Messaging.SingleEmailMessage(); 
                templmail.setWhatId(targetId);
                templmail.setTargetObjectId(u);
                templmail.setTemplateId(emailTemplateID);
                templmail.setSaveAsActivity(false);
                if(owa!=Null){
                    templmail.setOrgWideEmailAddressId(owa.Id);
                }
                
                if(Test.isRunningTest()){
                    templmail.setSubject(subject);
                    templmail.setHtmlBody(htmlBody);
                }
                
                tmpltmails.add(templmail);   
            }           
        }
        return tmpltmails;
        
    }*/
    
/*******************************************************************************************************************************************************************************************************
* Method Name : getActiveUsers
* Description : This method returns the active users
* Params      : List<Id> userIds, 
* Version     : 1.0 
* Created Date: 25-Nov-2020
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
    
    public static List<Id> getActiveUsers(Set<Id> userIds) {
        List<Id> activeUsers = new List<Id>(new Map<Id, User>([select id from User where (isActive=true or (IsActive=false and Partner_License_Reclaimed__c=true)) and Id in :userIds]).keySet());
        return activeUsers;  
    }  
    public static List<PermissionSetAssignment> getActiveUserOfPermissionSet(Set<Id> intelAccountIds,List<String> allowedPermissionSets){
        List<PermissionSetAssignment> permissionAssignmentList =[SELECT Assignee.email, Id,AssigneeId,Assignee.IsActive,Assignee.AccountId FROM PermissionSetAssignment WHERE Assignee.AccountId  in:intelAccountIds
                                                                 AND PermissionSet.Name =:allowedPermissionSets  and Assignee.IsActive=true];
        return permissionAssignmentList;
        
    }
    
    public static List<Core_Account_Group_Member__c> getPagMembers(Set<Id> accIdCompInfoMap){
        List<Core_Account_Group_Member__c> pagMemberList= new List<Core_Account_Group_Member__c>();
        pagMemberList = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where 
                         Core_Partner_Account_Id__c IN :accIdCompInfoMap and Core_Inactive_Ind__c=false];
        return pagMemberList;
        
    }
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : clearTaxonomyPlatformCache
* Description : this method will clear the taxonomy platform cache whenever new taxonomy data is loaded
* Created Date: 11-Jan-2021
* Modification Log :
* Created By  : Onyx Team [Sooriya - Implementation of Platform Cache :- US851334]
********************************************************************************************************************************************************************************************************/
    
    public static void clearTaxonomyPlatformCache(){     
        
        try{
            //Get the flag from Custom Metadata
            String cacheFlag = PMP_Utility.getValue('Taxonomy_CacheFlag');
            
            if(cacheFlag.equalsIgnoreCase('true')) {
                // Name of a partition and key
                String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
                
                //List of keys
                List<String> cacheKeyList = New List<String> {'BaseTaxonomyenUS','BaseTaxonomyja','BaseTaxonomyzhHansCN'};
                    
                    for(String keyStr : cacheKeyList ){
                        String cacheKey ='';
                        cacheKey = partitionInput+'.'+keyStr; 
                        Cache.Org.remove(cacheKey);
                    }
            }  
        }catch(Exception ex){
            PMP_Utility.logError(ex,'PMP_Taxonomy_Cache_Removal');
        }
    }   
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : replaceLabelWithDynamicValue
* Description : this method will replace the '{0}' in label with dynamic values(including all special characters)
* Created Date: 4-April-2021
* Modification Log :
* Created By  : Onyx Team [Sooriya - DE112070 Using especialy in PMP_SearchEventDetailController to handle special characters replacement]
********************************************************************************************************************************************************************************************************/  
    //OPTIMISATION WW44
    //below method used in PMP_SearchEventDetailController, and code is commented
    /*public static String replaceLabelWithDynamicValue(String labelValue, String dynamicValue){
        String regex = '\\{.*?\\}';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(labelvalue);
        
        if(regexMatcher.find()) {
            labelvalue = labelvalue.replaceAll(regex, Matcher.quoteReplacement(dynamicValue));
        }
        else{
            //system.debug('not matched');
        }
        return labelvalue;
    }
    */
    
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : fetchUsersMapForBasicAccessPartners
* Description : this method to fetch all PA users for basic access partners
* Created Date: 19-April-2021
* Modification Log :
* Created By  : Onyx Team [Priyanka - Ge-TM - email scenario implementation for inactive users :- US946136]
********************************************************************************************************************************************************************************************************/
    
    public static map<id,id> fetchUsersMapForBasicAccessPartners(List<PMP_Company__c> compInfoList, List<string> allowedPermissionSets ){ 
        Set<id> intelAccountIds = New set<id>();
        Map<id,id> accIdCompInfoMap = new Map<id,id>();
        map<id,id> userCompanyMap = New Map<id,id>();
        if(!compInfoList.isEmpty()){
            //Modified as a part of OPID Restructure
            Set<Id> companyIds = new Set<Id>();     
            for(PMP_Company__c compInfo : compInfoList){
                companyIds.add(compInfo.Id);
            }
            accIdCompInfoMap = getMapAccountToMpiByAllCompanyId(companyIds);
            intelAccountIds.addAll(accIdCompInfoMap.keySet());
            //Existing Logic
            /*for(PMP_Company__c compInfo : compInfoList){
// map of company info id and its parent account id.
accIdCompInfoMap.put(compInfo.PMP_Account_Id__c,compInfo.id);
intelAccountIds.add(compInfo.PMP_Account_Id__c);

}*/
            List<PermissionSetAssignment> permissionAssignmentList = New List<PermissionSetAssignment>();
            if(!allowedPermissionSets.isEmpty()){
                
                permissionAssignmentList = [SELECT Assignee.email, Id,AssigneeId,Assignee.AccountId FROM PermissionSetAssignment WHERE Assignee.AccountId  in:intelAccountIds
                                            AND PermissionSet.Name =:allowedPermissionSets and Assignee.IsActive=true ];
                for(PermissionSetAssignment pa : permissionAssignmentList){
                    userCompanyMap.put(pa.AssigneeId, accIdCompInfoMap.get(pa.Assignee.AccountId));
                }
                
            }
            
        }
        
        return userCompanyMap;  
    }
    
    /**
* Method added by sooriya 
* @description- Utility method to generate the string representation of a file's size, such as 2 KB, 4.1 MB, etc
* @param sizeValue - file size value (eg.2000,34532)
* @return String - modified string value (eg.2KB, 300MB)
* This method is used in PMP_OfferingResourceHelper apex class
*/
    //OPTIMISATION - WW44
    //Method used in offerings code and that is commented, so commenting below method.
    /*public static String FileSizeToString(Long sizeValue){
        String resizedValue = '';
        try{
            //Bytes
            if (sizeValue < 1024){
                resizedValue = string.valueOf(sizeValue) + ' Bytes';
            }
            //KB
            else if (sizeValue >= 1024 && sizeValue < (1024*1024)){
                Decimal kb = Decimal.valueOf(sizeValue);
                kb = kb.divide(1024,2);
                resizedValue = string.valueOf(kb) + ' KB';
            }
            //MB
            else if (sizeValue >= (1024*1024) && sizeValue < (1024*1024*1024)){
                Decimal mb = Decimal.valueOf(sizeValue);
                mb = mb.divide((1024*1024),2);
                resizedValue =  string.valueOf(mb) + ' MB';
            }
            //GB
            else{
                Decimal gb = Decimal.valueOf(sizeValue);
                gb = gb.divide((1024*1024*1024),2);
                resizedValue = string.valueOf(gb) + ' GB';
            } 
            
            return resizedValue;
        }
        catch (Exception ex){
            PMP_Utility.logError(ex,'PMP_UtilityFileSizeToString');   
        }
        return resizedValue;
    }*/
    
    /*******
* Method Name : getAccountRelatedMPIRecord
* return type : Map<Id,PMP_Company__c>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get PMP_Company__c information associated to passed account Id's Via the junction object. Part of OPID restructure
**************** Starts Here **********/
    //OPTIMISATION - WW44
    //Method not used, so commenting below method.
  /*  public Map<Id,PMP_Company__c> getAccountRelatedMPIRecord(Set<Id> accountIds)
    {
        Map<Id,PMP_OPID_MPI_Rel__c> junctionObjectRelatedToChangedAccounts = new Map <Id,PMP_OPID_MPI_Rel__c>([Select Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c  from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c IN : accountIds AND Is_Active__c= true]);
        Map<Id,Id> OPIDToMPID = new Map<Id,Id>();
        Set<Id> allMPIIds = new Set<Id>();
        for(Id singleJunctionId : junctionObjectRelatedToChangedAccounts.keySet())
        {
            PMP_OPID_MPI_Rel__c singleJunctionObj = junctionObjectRelatedToChangedAccounts.get(singleJunctionId);
            OPIDToMPID.put(singleJunctionObj.PMP_One_Partner_ID__c,singleJunctionObj.PMP_Marketing_Profile_Id__c);
            allMPIIds.add(singleJunctionObj.PMP_Marketing_Profile_Id__c);
        }
        Map<Id,PMP_Company__c> AllMPIRecords =new Map<Id,PMP_Company__c>([SELECT Id,PMP_Company_Review_Txt__c,PMP_Account_Address_Txt__c,PMP_Account_Application__c,PMP_Biz_Org_Type_Txt__c,PMP_Partner_City_Txt__c,PMP_Company_Resource__c,PMP_Partner_Country_Txt__c,CreatedById,PMP_Account_Dsc__c,PMP_Disti_Components_Nm__c,PMP_Disti_Sys_Solutions_Nm__c,PMP_Disti_Country_Coverage_Txt__c,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Enhanced_Login_Users_Txt__c,PMP_Field_Application_Engineer_Id__c,PMP_Workflow_Three_Day_Trigger_Dt__c,PMP_Account_Industry__c,PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Company_Information_Language_Nm__c,PMP_Intel_Admin_Id__c,PMP_Intel_Admin_Email_Txt__c,PMP_Intel_Admin_Nm__c,PMP_IPA_Badge_Tier_Txt__c,PMP_Badge_Tier_Sequence_Nbr__c,PMP_Is_Distributor_Ind__c,PMP_Is_Published_Ind__c,PMP_Is_Updated_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Translated_Languages__c,PMP_Translated_Languages_Txt__c,LastModifiedById,PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Status_Update_Dt__c,PMP_Last_Updated_Date_Dt__c,PMP_Company_Lead_Gen_Language_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,PMP_Marketing_Profile_Id__c,PMP_Partner_Benefit_Type__c,PMP_Partner_Inactive_Ind__c,PMP_Benefit_Update_Ind__c,PMP_One_Partner_ID__c,OwnerId,PMP_Partner_Logo_Cnt__c,PMP_Partner_Logo_Count__c,Name,PMP_Partner_Program_nm__c,PMP_Partner_Segment_Nm__c,PMP_Partner_Submitter_UserId__c,PMP_Data_Load_Identifier_Txt__c,PMP_Partner_Primary_Street_Txt__c,PMP_Account_Program_Membership__c,PMP_Published_Copy_Id__c,PMP_Account_Region__c,PMP_Workflow_One_Week_Trigger_Dt__c,PMP_Partner_Secondary_Street_Txt__c,PMP_Account_Specialty__c,PMP_Partner_State_Txt__c,PMP_Account_Sub_Region__c,PMP_Account_Tag_Line__c,PMP_Company_Lifecycle_Status_Nm__c,PMP_Translation_Lifecycle_Status_nm__c,PMP_View_Partners__c,PMP_View_Partners_Txt__c,PMP_Account_Website__c,PMP_Working_Copy_Id__c,PMP_Partner_Zipcode_Txt__c From PMP_Company__c WHERE Id IN : allMPIIds]);
        Map<Id,PMP_Company__c> accountToMPI = new Map<Id,PMP_Company__c>();
        for(Id singleAccount: accountIds)
        {
            Id singleMPIId = OPIDToMPID.get(singleAccount);
            PMP_Company__c singleMPIrecord = AllMPIRecords.get(singleMPIId);
            accountToMPI.put(singleAccount,singleMPIrecord);
        }
        return accountToMPI;
    } */  
    /******* Ends Here *************/
    
    /*******
* Method Name : getAllAccountRelatedToMPI
* return type : Map<Id,List<Account>>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get List of account information associated to passed MPI records Via the junction object. Part of OPID restructure
**************** Starts Here **********/
    public Map<Id,List<Account>> getAllAccountRelatedToMPI (List<PMP_Company__c> CompanyRecords)
    {
        Map<Id,List<Account>> CompanyIdToListOfAccount = new  Map<Id,List<Account>>();
        Set<Id> allMPIIds = new Set<Id>();
        for(PMP_Company__c singleCompanyRecord : CompanyRecords)
        {
            allMPIIds.add(singleCompanyRecord.Id);
        }
        List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_Marketing_Profile_Id__c IN : allMPIIds];
        Map<Id,Id> AccountIdsToMPIMapping = new Map<Id,Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords)
        {
            AccountIdsToMPIMapping.put(singleJunctionRecord.PMP_One_Partner_ID__c, singleJunctionRecord.PMP_Marketing_Profile_Id__c);
        }
        List<Account> AllOPIDRecords = [SELECT Id,Name FROM Account WHERE Id IN : AccountIdsToMPIMapping.keySet()];
        for(Account singleOPIDs : AllOPIDRecords)
        {
            Id MPID = AccountIdsToMPIMapping.get(singleOPIDs.Id);
            if(CompanyIdToListOfAccount.containsKey(MPID) && CompanyIdToListOfAccount.get(MPID) != null)
            {
                List<Account> accountList = CompanyIdToListOfAccount.get(MPID);
                accountList.add(singleOPIDs);
                CompanyIdToListOfAccount.put(MPID,accountList); 
            }
            else
            {
                CompanyIdToListOfAccount.put(MPID, new List<Account> {singleOPIDs});
            }
        }
        return CompanyIdToListOfAccount;
    }
    /******* Ends Here *************/
    
    /*******
* Method Name : getAllAccountRelatedToMPIActive
* return type : Map<Id,List<Account>>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get List of account information associated to passed MPI records Via the junction object. Part of OPID restructure
**************** Starts Here **********/
     //OPTIMISATION - WW44
    //Method not used, so commenting below method.
  /*  public Map<Id,List<Account>> getAllAccountRelatedToMPIActive (List<PMP_Company__c> CompanyRecords)
    {
        Map<Id,List<Account>> CompanyIdToListOfAccount = new  Map<Id,List<Account>>();
        Set<Id> allMPIIds = new Set<Id>();
        for(PMP_Company__c singleCompanyRecord : CompanyRecords)
        {
            allMPIIds.add(singleCompanyRecord.Id);
        }
        if(!allMPIIds.isempty()){
            List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE Is_Active__c=true AND PMP_Is_PagAccount_Ind__c=true AND PMP_Marketing_Profile_Id__c IN : allMPIIds];
            
            Map<Id,Id> AccountIdsToMPIMapping = new Map<Id,Id>();
            for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords)
            {
                AccountIdsToMPIMapping.put(singleJunctionRecord.PMP_One_Partner_ID__c, singleJunctionRecord.PMP_Marketing_Profile_Id__c);
            }
            
            List<Account> AllOPIDRecords = [SELECT Id,Name FROM Account WHERE Id IN : AccountIdsToMPIMapping.keySet()];
            for(Account singleOPIDs : AllOPIDRecords)
            {
                Id MPID = AccountIdsToMPIMapping.get(singleOPIDs.Id);
                if(CompanyIdToListOfAccount.containsKey(MPID) && CompanyIdToListOfAccount.get(MPID) != null)
                {
                    List<Account> accountList = CompanyIdToListOfAccount.get(MPID);
                    accountList.add(singleOPIDs);
                    CompanyIdToListOfAccount.put(MPID,accountList); 
                }
                else
                {
                    CompanyIdToListOfAccount.put(MPID, new List<Account> {singleOPIDs});
                }
            }
        }
        return CompanyIdToListOfAccount;
    }*/
    /******* Ends Here *************/
    
    
    /*******
* Method Name : getAllAccountRelatedToMPI
* return type : Map<Id,Map<Id>>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Set of account Id's associated to passed MPI records Via the junction object. Part of OPID restructure
**************** Starts Here **********/
    //OPTIMISATION WW44
    //Commenting below method , since other method with diff input type param and return type is used in code from 
    //this same class, but this return type method not found to be used
    /*public Map<Id,Set<Id>> getAllAccountRelatedToMPI (List<Id> allMPIIds)
    {
        Map<Id,Set<Id>> CompanyIdToListOfAccount = new  Map<Id,Set<Id>>();
        List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_Marketing_Profile_Id__c IN : allMPIIds];
        Map<Id,Id> AccountIdsToMPIMapping = new Map<Id,Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords)
        {
            AccountIdsToMPIMapping.put(singleJunctionRecord.PMP_One_Partner_ID__c, singleJunctionRecord.PMP_Marketing_Profile_Id__c);
        }
        for(Id singleOPIDs : AccountIdsToMPIMapping.keySet())
        {
            Id MPID = AccountIdsToMPIMapping.get(singleOPIDs);
            if(CompanyIdToListOfAccount.containsKey(MPID) && CompanyIdToListOfAccount.get(MPID) != null)
            {
                Set<Id> accountIdList = CompanyIdToListOfAccount.get(MPID);
                accountIdList.add(singleOPIDs);
                CompanyIdToListOfAccount.put(MPID,accountIdList); 
            }
            else
            {
                CompanyIdToListOfAccount.put(MPID, new Set<Id> {singleOPIDs});
            }
        }
        return CompanyIdToListOfAccount;
    }*/
    /******* Ends Here *************/ 
    
    
    /*******
* Method Name : getAllAccountRelatedToMPIActive
* return type : Map<Id,Map<Id>>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Set of account Id's associated to passed MPI records Via the junction object. Part of OPID restructure
**************** Starts Here **********/
     //OPTIMISATION - WW44
    //Method not used, so commenting below method.
   /* public Map<Id,Set<Id>> getAllAccountRelatedToMPIActive (List<Id> allMPIIds)
    {
        Map<Id,Set<Id>> CompanyIdToListOfAccount = new  Map<Id,Set<Id>>();
        List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE Is_Active__c=True AND PMP_Is_PagAccount_Ind__c=True AND PMP_Marketing_Profile_Id__c IN : allMPIIds];
        Map<Id,Id> AccountIdsToMPIMapping = new Map<Id,Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords)
        {
            AccountIdsToMPIMapping.put(singleJunctionRecord.PMP_One_Partner_ID__c, singleJunctionRecord.PMP_Marketing_Profile_Id__c);
        }
        for(Id singleOPIDs : AccountIdsToMPIMapping.keySet())
        {
            Id MPID = AccountIdsToMPIMapping.get(singleOPIDs);
            if(CompanyIdToListOfAccount.containsKey(MPID) && CompanyIdToListOfAccount.get(MPID) != null)
            {
                Set<Id> accountIdList = CompanyIdToListOfAccount.get(MPID);
                accountIdList.add(singleOPIDs);
                CompanyIdToListOfAccount.put(MPID,accountIdList); 
            }
            else
            {
                CompanyIdToListOfAccount.put(MPID, new Set<Id> {singleOPIDs});
            }
        }
        return CompanyIdToListOfAccount;
    }*/
    /******* Ends Here *************/ 
    
    
    /*******
* Method Name : getAllAccountRelatedToMPIActiveList
* return type : Map<Id,Map<Id>>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Set of account Id's associated to passed MPI records Via the junction object. Part of OPID restructure
**************** Starts Here **********/
        //OPTIMISATION - WW44
    //Method not used, so commenting below method.
  /*  public Map<Id,Set<Id>> getAllAccountRelatedToMPIActiveList (List<Id> allMPIIds)
    {
        Map<Id,Set<Id>> CompanyIdToListOfAccount = new  Map<Id,Set<Id>>();
        List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE Is_Active__c=True AND PMP_Marketing_Profile_Id__c IN : allMPIIds];
        Map<Id,Id> AccountIdsToMPIMapping = new Map<Id,Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords)
        {
            AccountIdsToMPIMapping.put(singleJunctionRecord.PMP_One_Partner_ID__c, singleJunctionRecord.PMP_Marketing_Profile_Id__c);
        }
        for(Id singleOPIDs : AccountIdsToMPIMapping.keySet())
        {
            Id MPID = AccountIdsToMPIMapping.get(singleOPIDs);
            if(CompanyIdToListOfAccount.containsKey(MPID) && CompanyIdToListOfAccount.get(MPID) != null)
            {
                Set<Id> accountIdList = CompanyIdToListOfAccount.get(MPID);
                accountIdList.add(singleOPIDs);
                CompanyIdToListOfAccount.put(MPID,accountIdList); 
            }
            else
            {
                CompanyIdToListOfAccount.put(MPID, new Set<Id> {singleOPIDs});
            }
        }
        return CompanyIdToListOfAccount;
    }*/
    /******* Ends Here *************/ 
    
    /*******
* Method Name : getAllAccountRelatedToMPINotActive
* return type : Map<Id,Map<Id>>
* created by  : Onyx Team, Tilak Mallesh, on 30/09/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Set of account Id's associated to passed MPI records Via the junction object. Part of OPID restructure
**************** Starts Here **********/
    //OPTIMISATION - WW44
    //Method usage commented , so commenting below method.
   /* public Map<Id,Set<Id>> getAllAccountRelatedToMPINotActive (List<Id> allMPIIds)
    {
        Map<Id,Set<Id>> CompanyIdToListOfAccount = new  Map<Id,Set<Id>>();
        List<PMP_OPID_MPI_Rel__c> allJunctionRecords = [SELECT Id,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE Is_Active__c = False AND PMP_Marketing_Profile_Id__c IN : allMPIIds];
        //system.debug('Values of allJunctionRecords : '+allJunctionRecords);
        Map<Id,Id> AccountIdsToMPIMapping = new Map<Id,Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionRecord : allJunctionRecords)
        {
            AccountIdsToMPIMapping.put(singleJunctionRecord.PMP_One_Partner_ID__c, singleJunctionRecord.PMP_Marketing_Profile_Id__c);
        }
        for(Id singleOPIDs : AccountIdsToMPIMapping.keySet())
        {
            Id MPID = AccountIdsToMPIMapping.get(singleOPIDs);
            if(CompanyIdToListOfAccount.containsKey(MPID) && CompanyIdToListOfAccount.get(MPID) != null)
            {
                Set<Id> accountIdList = CompanyIdToListOfAccount.get(MPID);
                accountIdList.add(singleOPIDs);
                CompanyIdToListOfAccount.put(MPID,accountIdList); 
            }
            else
            {
                CompanyIdToListOfAccount.put(MPID, new Set<Id> {singleOPIDs});
            }
        }
        //system.debug('Values of CompanyIdToListOfAccount '+CompanyIdToListOfAccount);
        return CompanyIdToListOfAccount;
    }
    /******* Ends Here *************/ 
    /*******
* Method Name : getJunctionAccountToMpiByAccountId
* return type : List<PMP_OPID_MPI_Rel__c>
* created by  : Onyx Team, Sathish , on 10/05/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get junction records associated to accountIds - Part of OPID restructure
********/
    public static List<PMP_OPID_MPI_Rel__c> getJunctionAccountToMpiByAccountId(set<Id> accountIds){
        List<PMP_OPID_MPI_Rel__c> junctionObjects = new List<PMP_OPID_MPI_Rel__c>();
        if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible() && accountIds!=null && !accountIds.isEmpty()){
            junctionObjects = [ select Id,PMP_One_Partner_ID__c,
                               PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,Is_Active__c,PMP_RelLastDeactivated__c
                               from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c in :accountIds and Is_Active__c = true];
        }
        return junctionObjects;             
    }
    
    
    /*******
* Method Name : getJunctionAccountToMpiByCompanyId
* return type : List<PMP_OPID_MPI_Rel__c>
* created by  : Onyx Team, Sathish , on 10/05/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get junction records associated to CompanyIds - Part of OPID restructure
********/
    public static List<PMP_OPID_MPI_Rel__c> getJunctionAccountToMpiByCompanyId(set<Id> companyIds){
        List<PMP_OPID_MPI_Rel__c> junctionObjects = new List<PMP_OPID_MPI_Rel__c>();
        
        if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible() && companyIds!=null && !companyIds.isEmpty()){
            junctionObjects = [ select Id,PMP_One_Partner_ID__c,
                               PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,Is_Active__c
                               from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c in :companyIds and Is_Active__c = true];
        }
        return junctionObjects;             
    }
    
    
    
    /*******
* Method Name : getMapAccountToMpiByAllCompanyId
* return type : Map<Id,Id>
* created by  : Onyx Team, Sathish , on 11/14/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Map account to Company either by working or published Copy companyIds - Part of OPID restructure
********/
    public static Map<Id,Id> getMapAccountToMpiByAllCompanyId(set<Id> companyIds){
        // check if companyId's have any working Copy's
        /* List<PMP_OPID_MPI_Rel__c> junctionObjects = new List<PMP_OPID_MPI_Rel__c>();
Map<Id,Id> mapPublishedToWorkingCopyIds = new Map<Id,Id>();
List<PMP_Company__c> workingCopycompanies = [select Id,PMP_Published_Copy_Id__c from PMP_company__c where PMP_Is_Published_Ind__c=false and Id in:companyIds];
set<Id> allPublishedCopyIds = new Set<Id>();
for(PMP_company__c company : workingCopycompanies){
mapPublishedToWorkingCopyIds.put(company.PMP_Published_Copy_Id__c, company.Id);
companyIds.add(company.PMP_Published_Copy_Id__c);
}

if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){
junctionObjects = [ select Id,PMP_One_Partner_ID__c,
PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,Is_Active__c
from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c in :companyIds and Is_Active__c = true];
}
Map<Id,Id> mapAccountToMpiIds = new Map<Id,Id>();
for(PMP_OPID_MPI_Rel__c junction:junctionObjects){
if(mapPublishedToWorkingCopyIds.containsKey(junction.PMP_Marketing_Profile_Id__c)){
mapAccountToMpiIds.put(junction.PMP_One_Partner_ID__c,mapPublishedToWorkingCopyIds.get(junction.PMP_Marketing_Profile_Id__c));
}else{
mapAccountToMpiIds.put(junction.PMP_One_Partner_ID__c,junction.PMP_Marketing_Profile_Id__c);
}
}
return mapAccountToMpiIds;*/
        Map<id,id> accIdCompInfoMap = new Map<id,id>();
        List<PMP_Company__c> listCompanies = [select id,PMP_Opid_Sfid_Txt__c from PMP_Company__c where id in:companyIds];
        for(PMP_company__c company:listCompanies){
            if(company.PMP_Opid_Sfid_Txt__c!=null){
                List<String> listAccounts = company.PMP_Opid_Sfid_Txt__c.split(';');
                for(String acc : listAccounts){
                    accIdCompInfoMap.put(acc,company.id);
                }
            }    
        }
        return accIdCompInfoMap;
    }
    
    
    
    /*******
* Method Name : getPublishedMpiIds
* return type : List<Id>
* created by  : Onyx Team, Sathish , on 10/05/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Mpi records associated for given junction Objects - Part of OPID restructure
********/
    public static List<Id> getListMpiIds(List<PMP_OPID_MPI_Rel__c> junctionObjects){
        List<Id> mpiIds = new List<Id>();
        Set<Id> setMpi = new Set<Id>();
        for(PMP_OPID_MPI_Rel__c record:junctionObjects ){
            setMpi.add(record.PMP_Marketing_Profile_Id__c);
        }
        mpiIds.addAll(setMpi);
        return mpiIds;
    }
    
    
    
    
    
    /*******
* Method Name : getMapMpiToListAccountActive
* return type : Map<Id,Set<Id>>
* created by  : Onyx Team, Sathish , on 10/05/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Map Mpi(Both working and Published copy) Id to list accounts associated for MPI for given junction Objects - Part of OPID restructure
********/
    public static Map<Id,Set<Id>> getMapMpiToListAccountActive(List<PMP_OPID_MPI_Rel__c> junctionObjects){
        // Modified as part of OPID Restructure
        Map<Id,Set<Id>> mapMpiToAccountListActive = new Map<Id,Set<Id>>();
        for(PMP_OPID_MPI_Rel__c opidMpiRelationObject:junctionObjects )
        {
            if(!mapMpiToAccountListActive.isEmpty() && mapMpiToAccountListActive.containsKey(opidMpiRelationObject.PMP_Marketing_Profile_Id__c)){
                Set<Id> accounts = mapMpiToAccountListActive.get(opidMpiRelationObject.PMP_Marketing_Profile_Id__c);
                accounts.add(opidMpiRelationObject.PMP_One_Partner_ID__c);
                mapMpiToAccountListActive.put(opidMpiRelationObject.PMP_Marketing_Profile_Id__c,accounts);
                if(opidMpiRelationObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c!=null){
                    mapMpiToAccountListActive.put(opidMpiRelationObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,accounts);
                }
            } else{
                Set<Id> accounts = new Set<Id>();
                accounts.add(opidMpiRelationObject.PMP_One_Partner_ID__c);
                mapMpiToAccountListActive.put(opidMpiRelationObject.PMP_Marketing_Profile_Id__c,accounts);
                if(opidMpiRelationObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c!=null) {
                    mapMpiToAccountListActive.put(opidMpiRelationObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,accounts);
                }
            }
        }
        return mapMpiToAccountListActive;
    }
    
    
    
    
    /*******
* Method Name : getAllMpiIds
* return type : Set<Id>
* created by  : Onyx Team, Sathish , on 10/05/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get all the published and working copy record Id's - Part of OPID restructure
********/
    
    public static Set<Id> getAllMpiIds(List<PMP_OPID_MPI_Rel__c> junctionObjects){
        // Modified as part of OPID Restructure
        Set<Id> partnerCompanyMpiIds = new Set<Id>();
        
        for(PMP_OPID_MPI_Rel__c opidMpiRelationObject : junctionObjects)
        {
            partnerCompanyMpiIds.add(opidMpiRelationObject.PMP_Marketing_Profile_Id__c);
            if(opidMpiRelationObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c!=null){
                partnerCompanyMpiIds.add(opidMpiRelationObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c);
            }
        }
        return partnerCompanyMpiIds;
    }
    
    
    
    /*******
* Method Name : getAllAccountRelatedToMPI_WCandPC
* return type : Map<Id,List<PMP_Company__c>>
* created by  : Onyx Team, Tilak Mallesh, on 08/10/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get Set of account Id's associated to related MPI WC and PC Via the junction object. Part of OPID restructure
**************** Starts Here **********/
    public Map<Id,List<PMP_Company__c>> getAllAccountRelatedToMPI_WCandPC(List<PMP_OPID_MPI_Rel__c> JunctionRecords)
    {
        Map<Id,List<PMP_Company__c>> CompanyIdToListOfAccount = new  Map<Id,List<PMP_Company__c>>();
        Set<Id> companyProfileIds = new Set<Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionObject : JunctionRecords) 
        {
            companyProfileIds.add(singleJunctionObject.PMP_Marketing_Profile_Id__c);
        }
        Map<Id,PMP_Company__c> mapComponayProfile = new Map<Id,PMP_Company__c>([Select Id,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Is_Working_Copy_Ind__c,PMP_Working_Copy_Id__r.Id,PMP_Working_Copy_Id__r.PMP_Is_Published_Ind__c From PMP_Company__c where Id IN: companyProfileIds]);
        map<Id,List<PMP_Company__c>> MPiIdToAllMPIs = new Map<Id,List<PMP_Company__c>>();
        for(Id singleMPIRecordsId: mapComponayProfile.keySet())
        {
            PMP_Company__c singleMPIRecords = mapComponayProfile.get(singleMPIRecordsId);
            //system.debug('Values of singleMPIRecords : '+singleMPIRecords);
            if(singleMPIRecords.PMP_Working_Copy_Id__r.Id != null)
            {
                sObject sobjectRecordForWorkingCopy = singleMPIRecords.PMP_Working_Copy_Id__r.Id.getSObjectType().newSObject(singleMPIRecords.PMP_Working_Copy_Id__r.Id);
                MPiIdToAllMPIs.put(singleMPIRecordsId, new List<PMP_Company__c>{singleMPIRecords});
                //System.debug('after adding Production copy record '+JSON.serializePretty(MPiIdToAllMPIs));
                PMP_Company__c workingCopyRecord = (PMP_Company__c) sobjectRecordForWorkingCopy;
                workingCopyRecord.PMP_Is_Working_Copy_Ind__c = singleMPIRecords.PMP_Working_Copy_Id__r.PMP_Is_Working_Copy_Ind__c;
                //System.debug('Value of workingCopyRecord ::'+workingCopyRecord);
                //MPiIdToAllMPIs.put(singleMPIRecordsId,workingCopyRecord.Id);
                if(MPiIdToAllMPIs.containsKey(singleMPIRecordsId))
                {
                    List<PMP_Company__c> MPIRecords = MPiIdToAllMPIs.get(singleMPIRecordsId);
                    MPIRecords.add(workingCopyRecord);
                    MPiIdToAllMPIs.put(singleMPIRecordsId,MPIRecords); 
                }
            }
            if(singleMPIRecords.PMP_Working_Copy_Id__r.Id == null)
            {
                MPiIdToAllMPIs.put(singleMPIRecordsId, new List<PMP_Company__c>{singleMPIRecords});
            }
            //System.debug('after adding working copy record '+JSON.serializePretty(MPiIdToAllMPIs));
        }
        for(PMP_OPID_MPI_Rel__c singleJunctionObject : JunctionRecords) 
        {
            CompanyIdToListOfAccount.put(singleJunctionObject.PMP_One_Partner_ID__c,MPiIdToAllMPIs.get(singleJunctionObject.PMP_Marketing_Profile_Id__c));
        }
        //System.debug('Value of CompanyIdToListOfAccount ::'+JSON.serializePretty(CompanyIdToListOfAccount));
        return CompanyIdToListOfAccount;
    }
    /******* Ends Here *************/ 
    
    /*******
* Method Name : getJunctionAccToMpiByCompanyId
* return type : List<PMP_OPID_MPI_Rel__c>
* created by  : Onyx Team, Priyadharshini , on 10/12/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get junction records associated to CompanyIds - Part of OPID restructure
********/  
    public static List<PMP_OPID_MPI_Rel__c> getJunctionAccToMpiByCompanyId(Id companyId){
        List<PMP_OPID_MPI_Rel__c> junctionObjects = new List<PMP_OPID_MPI_Rel__c>();
        if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible() && companyId !=null){
            junctionObjects = [ select Id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c
                               from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c =:companyId and Is_Active__c = true];
        }
        return junctionObjects; 
    } 
    
    /****************************************************************************************************************************
* Method Name : sendEmailToIOTReady
* return type : Void
* created by  : Onyx Team,Priyanka on 02/25/2022.
* Description : Below method is used to send email to iot.market.ready@intel.com if submitter is NULL/Inactive/DND 
for solution approval email scenario. If the requirement is extended for offerings and storefront emails also , 
this method can be reused.
********************************************************************************************************************************/  
    //OPTIMISATION - WW44
    //Method used in commented code for solutions, so commenting below method.
  /*  public static void sendEmailToIOTReady(String emailtempName,List<Id> objectIds){
        try{
            EmailTemplate  template = PMP_Utility.getEmailTemplate(emailtempName);
            OrgWideEmailAddress owa = New OrgWideEmailAddress ();    
            if(orgWideAddress==NULL){
                owa =  [select id, Address, DisplayName from OrgWideEmailAddress Where Address = :System.Label.PMP_Intel_partner_Alliance_Address limit 1]; 
            }
            List<Messaging.SingleEmailMessage> tmpltmails =  new List<Messaging.SingleEmailMessage>();
            String subject = 'Subject for Test Class';
            String htmlBody = 'Email Body content for TestClass';
            // creating email instances for the all whatIds
            for(Id whatId : objectIds){
                Messaging.SingleEmailMessage templmail = new Messaging.SingleEmailMessage(); 
                templmail.setWhatId(whatId);
                // as the field is mandatory to load template. but this user merge field are not being referred in the template 
                // no merge fields referred with respect to user in PSS_SolutionApproved vf template
                templmail.setTargetObjectId(userInfo.getUserId()); 
                templmail.setTemplateId(template.Id);
                templmail.setSaveAsActivity(false);
                if(orgWideAddress!=Null){
                    templmail.setOrgWideEmailAddressId(orgWideAddress);
                }
                else{
                    templmail.setOrgWideEmailAddressId(owa.Id);
                }
                templmail.setTreatTargetObjectAsRecipient(false);//dont sent email to setTargetObjectId
                if(Test.isRunningTest()){
                    templmail.setSubject(subject);
                    templmail.setHtmlBody(htmlBody);
                }
                
                templmail.setToAddresses(System.Label.PSS_Iot_MarketReady_Email.split('\\;'));//label will have iot.market.ready@intel.com as email address
                tmpltmails.add(templmail);            
            }
            
            // firing the emails       
            Messaging.SendEmailResult[] results = Messaging.sendEmail(tmpltmails,false); //send email for the prepared template.
        }
        catch(Exception e){
            PMP_Utility.logError(e,'PMP_Utility-sendEmailToIOTReady');
        }
    }*/
    
    /*******
* Method Name : isIntelAdmin
* return type : Boolean
* created by  : Onyx Team, Krishna ch , on 28/03/2022, for auto published emails are.
* Description : this method will return the list of admin users.
********/  
    //OPTIMISATION - WW44
    //Method not used anymore so commenting
   /* public static List<Id> intelAdminGrpMembers(){
        
        List<Id> grpUserId= new List<Id>();
        
        string adminGroup = getValue('PMP_Admin_GroupName');
        
        if(adminGroup!=null){
            Group grp;
            
            grp=[SELECT Id FROM Group where DeveloperName=:adminGroup LIMIT 1]; //Querying the group where all admins are declared
            
            
            if (grp!=Null){
                List<GroupMember> groupMembers;
                
                groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id]; //Querying all the group members from above group 
                
                // List<Id> userIds=new List<Id>();
                
                if(groupMembers!=Null){
                    for (GroupMember groupMember: groupMembers){ // Iterating over all the group members to check if logged in user is admin
                        
                        grpUserId.add(groupMember.UserOrGroupId);
                    }
                }
                
            }
        }      
        
        return grpUserId;
    }*/
    
    /*******
* Method Name : sendWelcomeEmailForMP
* return type : Void
* created by  : MP Team
* Description : this method will send welcome email for New Storefront after Entilement is approved.
********/  
    public static void sendWelcomeEmailForMP(Set<Id> setContacIdForIPAWelcomeEmail) {
        Set<String> setOpidsForMPEmail = new Set<String>();
        Map<Id, Id> intelAccCompInfoMap = new Map<Id, Id>();
        List<PRM_EmailLog__c> existingEmailLogs = new List<PRM_EmailLog__c>();
        list<id> setallcontactsunderopid = new list<id>();
        List<id> intelAccountIds = new list<id>();
        set<id> finalcontactswithoutemail = new set<id>();
        Map<Id, Id> accIdCompInfoMap = new Map<Id, Id>();
        Map<Id, Id> userCompanyMap = new Map<Id, Id>();
        
            List<id> contactsWithEmail = new list<id>();
        
        
        if (setContacIdForIPAWelcomeEmail != null && !setContacIdForIPAWelcomeEmail.isEmpty()) {
            for (Contact con : [SELECT Core_IPA_One_Partner_Id__c, Id, Core_AGS_Integration_Status__c FROM Contact WHERE Id IN :setContacIdForIPAWelcomeEmail]) {
                setOpidsForMPEmail.add(con.Core_IPA_One_Partner_Id__c);
            }
            
            if (setOpidsForMPEmail != null && !setOpidsForMPEmail.isEmpty()) {
                System.debug('setOpidsForMPEmail: ' + setOpidsForMPEmail);
                List<String> lstCompaniesForWelcomeEmail = new List<String>();
                Set<String> setCompaniesForWelcomeEmail = new Set<String>();
                //fetch pags and then query active contacts where accts in intelaccs
                
                
                for (PMP_Company__c comp : [
                    SELECT Id, Name, PMP_Published_Copy_Id__c, PMP_Is_Working_Copy_Ind__c,PMP_Opid_Sfid_Txt__c,
                    PMP_Working_Copy_Id__c, PMP_Company_Lifecycle_Status_Nm__c
                    FROM PMP_Company__c
                    WHERE PMP_Opid_Sfid_Ref_Txt__c IN :setOpidsForMPEmail
                    AND PMP_Benefit_Update_Ind__c =false
                ]) {
                    if (comp.PMP_Company_Lifecycle_Status_Nm__c == 'Draft' && comp.PMP_Is_Working_Copy_Ind__c == true) {
                        String key = comp.PMP_Published_Copy_Id__c + '|' + 'New_CompanyInfo_CreationEmail';
                        lstCompaniesForWelcomeEmail.add(key);
                        
                        if (comp.PMP_Published_Copy_Id__c != null)
                            setCompaniesForWelcomeEmail.add(comp.PMP_Published_Copy_Id__c);
                        if (comp.PMP_Working_Copy_Id__c != null)
                            setCompaniesForWelcomeEmail.add(comp.PMP_Working_Copy_Id__c);
                        
                        System.debug(comp.PMP_Published_Copy_Id__c + ' comp.PMP_Published_Copy_Id__c');
                    }
                    
                    if(comp.PMP_Opid_Sfid_Txt__c!=null){
                        List<String> listAccounts = comp.PMP_Opid_Sfid_Txt__c.split(';');
                        for(String acc : listAccounts){
                             if (comp.PMP_Published_Copy_Id__c != null)
                            accIdCompInfoMap.put(acc,comp.PMP_Published_Copy_Id__c);
                        }
                    }    
                    
                }
                // Fetch Contacts and collect OPIDs
                List<Core_Account_Group_Member__c> pagMemberList = [SELECT Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
                                                                    FROM Core_Account_Group_Member__c 
                                                                    WHERE Core_Partner_Account_Id__c IN :setOpidsForMPEmail 
                                                                    AND Core_Inactive_Ind__c = false];
                system.debug('pagMemberList--'+pagMemberList);
                for(Core_Account_Group_Member__c mem : pagMemberList){
                    intelAccountIds.add(mem.Core_Intel_Account_Id__c);
                    // accIdCompInfoMap.put(acc,comp.id);//accid,compid
                    intelAccCompInfoMap.put(mem.Core_Intel_Account_Id__c, accIdCompInfoMap.get(mem.Core_Partner_Account_Id__c));
                }
                for(PRM_Account_Contact_Relationship__c acr: [select PRM_Contact_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in: intelAccountIds and PRM_InActive_Ind__c=false and PRM_Status_Nm__c='Complete']){
                    setallcontactsunderopid.add(acr.PRM_Contact_Id__c);
                }				
                // Fetch Companies
                
                if (!setCompaniesForWelcomeEmail.isEmpty()) {
                    System.debug('setCompaniesForWelcomeEmail: ' + setCompaniesForWelcomeEmail);
                    
                    // Fetch existing email logs
                    for (PRM_EmailLog__c eLog : [
                        SELECT Id, PRM_Subject__c, PRM_Contact__c, PRM_User__c,
                        PRM_EmailDeliverabilityStatus__c, PRM_ToEmailID__c,
                        Email_Template_Name__c, PRM_Contact__r.Core_Preferred_Language__c
                        FROM PRM_EmailLog__c
                        WHERE PMP_Company__c IN :setCompaniesForWelcomeEmail
                        AND PRM_Contact__c IN : setallcontactsunderopid
                        //and contact in : setContacIdForIPAWelcomeEmail
                        AND Email_Template_Name__c ='PMP_CompanyInfoDraftEmail_Profile'
                        ORDER BY CreatedDate
                    ]) {
                       // if(!setallcontactsunderopid.contains(elog.PRM_Contact__c)){
                          //  finalcontactswithoutemail.add(elog.PRM_Contact__c);
                       // }	
                       contactsWithEmail.add(eLog.PRM_Contact__c);				
                        existingEmailLogs.add(eLog);
                        //contactswithemails.add(log.con)
                    }
                   // Set<Id> finalcontactswithoutemail = new Set<Id>();
finalcontactswithoutemail.addAll(setallcontactsunderopid);
finalcontactswithoutemail.removeAll(contactsWithEmail);
                }
            }
        }
        if(finalcontactswithoutemail!=null){
            
            List<User> userContactList = [SELECT Id, ContactId,AccountId, Contact.Core_Do_Not_Contact__c, Contact.Core_isEmailBounced_Ind__c,IsActive
                                          FROM User WHERE ContactId IN :finalcontactswithoutemail and IsActive = True];
            system.debug('userContactList++'+userContactList);
            for (user u:userContactList){               
                userCompanyMap.put(u.id, intelAccCompInfoMap.get(u.AccountId) );//u.contactid.accountid
            }
            
            /* if(!allowedPermissionSets.isEmpty()){
List<PermissionSetAssignment> permissionAssignmentList = [SELECT AssigneeId, Assignee.AccountId 
FROM PermissionSetAssignment 
WHERE Assignee.AccountId IN :intelAccountIds 
AND PermissionSet.Name IN :allowedPermissionSets];
for(PermissionSetAssignment pa : permissionAssignmentList){
userIds.add(pa.AssigneeId);
}
}*/
            //this might be having working copy id - so on the top when filtering with published copy id , existing email logs not coming
            if(!userCompanyMap.isempty())
            PMP_Utility.sendEmailAndLogData('PMP_CompanyInfoDraftEmail_Profile', userCompanyMap);  
            /* if (!lstCompaniesForWelcomeEmail.isEmpty() && existingEmailLogs.isEmpty()) {
PMP_SendEmailAlertsForCompanyInfo.PMP_SendEmailAlertsForCompanyInfo(lstCompaniesForWelcomeEmail);
}*/
        }
    }
}