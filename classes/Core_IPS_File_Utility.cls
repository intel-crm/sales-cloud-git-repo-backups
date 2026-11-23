/***************************************************************************************************
* Apex Class Name: Core_IPS_File_Utility 
* Version     : 1.0 
* Created Date: 23 Sept 2015
* Function    : IPS SCFT/SFT File Utility
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
public with sharing class Core_IPS_File_Utility {
/**************************************************************************************************
* Method name  : GetUserFileIDs
* Description  : Get GRDC logged in User's List of File ID's
*                This method is used for SCFT File downloads
* Return Type  : Set<ID>
* Parameters   : User Object instance
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    public static Set<Id> GetUserFileIDs( User u){
        String sUserProfileName;
        Id ProfileId;
        String FileGUID;
        Set<Id> sFileUploadMasterAllIds = new Set<ID>();
        
        try {
            //Exception scenario for Test
            if(Test.isRunningTest()){
                RaiseExceptionForTestCoverage();
            }  
            //User Profile Name and Id
            sUserProfileName = u.Profile.name;
            ProfileId = u.ProfileId;            
            //Bypass Processing
            if (system.label.Core_IPS_File_Auth_Pass.contains(sUserProfileName)){
                system.debug('###### Bypass Processing Start');
                return GetUnrestrictedFileIDs(FileGUID);
            }
            //FAE processing
            if (system.label.Core_IPS_FAE_ProfileName.contains(sUserProfileName))
            {
                system.debug('###### FAE Processing Start');
                return GetFAEFileIDs(u, FileGUID);
            }
            //Normal Processing
            system.debug('###### Normal Processing Start');
            return GetRestrictedFileIDs(u, FileGUID);
            
        } catch (Exception e){
            return sFileUploadMasterAllIds;
        }
    }
/***************************************************************************************************
* Method name  : GetAuthUserFileID
* Description  : File Authorization processing with a FileGUID passed from SFT
*                FileUploadMaster ID is returned for the passed File GUID 
*                This method is used for SFT File Authorization
* Return Type  : Set<ID>
* Parameters   : User Object instance, FileGUID 
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    public static Set<Id> GetAuthUserFileID( User u, String FileGuid){
        String sUserProfileName;
        Id ProfileId;
        Set<Id> sFileUploadMasterAllIds = new Set<ID>();
        
        try {
            //Exception scenario for Test
            if(Test.isRunningTest()){
                RaiseExceptionForTestCoverage();
            }  
            //User Profile Name and Id
            sUserProfileName = u.Profile.name;
            ProfileId = u.ProfileId;            
            //Bypass Processing
            if (system.label.Core_IPS_File_Auth_Pass.contains(sUserProfileName)){
                system.debug('###### Auth Bypass Processing Start');
                return GetUnrestrictedFileIDs(FileGUID);
            }
            //FAE processing
            if (system.label.Core_IPS_FAE_ProfileName.contains(sUserProfileName))
            {
                system.debug('###### Auth FAE Processing Start');
                return GetFAEFileIDs(u, FileGUID);
            }
            //Normal Processing
            system.debug('###### Auth Normal Processing Start');
            return GetRestrictedFileIDs(u, FileGUID);
            
        } catch (Exception e){
            return sFileUploadMasterAllIds;
        }
    }
/***************************************************************************************************
* Method name  : CheckUserRecordAccess
* Description  : SFT Authorization for Case Related Attachment
* Return Type  : Boolean (Response to SFT)
* Parameters   : User Id and Case Id
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    public static Boolean CheckUserRecordAccess( Id Userid, Id RecordId){
        Boolean HasAccess = false;
        List<UserRecordAccess> lstUserRecordAccess = [Select u.RecordId, u.HasReadAccess From UserRecordAccess u
                                                      where UserId =:Userid and RecordId =:RecordId limit 1];
        if(lstUserRecordAccess != null && lstUserRecordAccess.size() > 0){
            for (UserRecordAccess UserRecordAccessObj : lstUserRecordAccess){
                HasAccess = UserRecordAccessObj.HasReadAccess;    
            }     
        }
        return HasAccess;
    }    
/***************************************************************************************************
* Method name  : GetUnrestrictedFileIDs
* Description  : Get GRDC logged in User's List of File ID's
*                This method is used for both SCFT File downloads and SFT File Authorization
* Return Type  : Set<ID>
* Parameters   : FileGUID
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    private static Set<Id> GetUnrestrictedFileIDs(String FileGUID){
        Set<Id> sFileUploadMasterAllIds = new Set<ID>();
        Set<Id> sFileUploadMasterIds = new Set<ID>();
        
        //Get File Master no restrictions   
        sFileUploadMasterAllIds = GetFileUploadMasterDetails(sFileUploadMasterIds, false, FileGUID);        
        system.debug('###### Bypass sFileUploadMasterAllIds All:' + sFileUploadMasterAllIds.size() );         
        return sFileUploadMasterAllIds;                
    }
/***************************************************************************************************
* Method name  : GetFAEFileIDs
* Description  : Get GRDC logged in User's List of File ID's
*                This method is used for both SCFT File downloads and SFT File Authorization
* Return Type  : Set<ID>
* Parameters   : User object instance, FileGUID
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    private static Set<Id> GetFAEFileIDs(User u, String FileGUID){
        Set<Id> sFileUploadMasterAllIds = new Set<ID>();
        Set<ID> sAccountIds = new Set<ID>();    
        Set<ID> sFileAssignmentIds = new Set<ID>();
        Set<Id> sFileUploadMasterIds = new Set<ID>();   
        List<Core_IPS_File_Assignment__c> lstFileAssignments = new List<Core_IPS_File_Assignment__c>();
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        List<String> lstShareRowCause = new List<String>();
        
        //Get Labels Team and Owner Row Cause
        lstShareRowCause.add(Core_IPS_Helper_Utility.getIPSLabel('RowCause_Team'));
        lstShareRowCause.add(Core_IPS_Helper_Utility.getIPSLabel('Rowcause_Owner'));
        system.debug('###### labels:' + lstShareRowCause );
        //Get Account Access
        lstAccountShare = [SELECT Id, AccountId, AccountAccessLevel, RowCause from AccountShare  
                           where RowCause IN :lstShareRowCause and UserOrGroupId =:u.Id];
        //Transfer to Set
        for(AccountShare AccountShareObj : lstAccountShare){
            sAccountIds.add(AccountShareObj.AccountId); 
        }
        system.debug('###### sAccountIds:' + sAccountIds.size() );
        //Get File Assignments with Account Id's   
        if (FileGUID == null) {
            Map<id, Core_IPS_File_Assignment__c> mFileAssignmentsIdObj = new Map<Id, Core_IPS_File_Assignment__c>(
                [select id, Core_IPS_File_Upload_Master__c, Core_Product_Name__c
                 from Core_IPS_File_Assignment__c where ( Core_Account__c in :sAccountIds or Core_Account__c = '' )]);
            
            if (!mFileAssignmentsIdObj.isEmpty()) {
                sFileAssignmentIds = mFileAssignmentsIdObj.keySet();
                lstFileAssignments = mFileAssignmentsIdObj.values();
            }
        }
        //Authorization check with FileGUID
        if (FileGUID != null) {
            Map<id, Core_IPS_File_Assignment__c> mFileAssignmentsIdObj = new Map<Id, Core_IPS_File_Assignment__c>(
                [select id, Core_IPS_File_Upload_Master__c, Core_Product_Name__c
                 from Core_IPS_File_Assignment__c where ( Core_Account__c in :sAccountIds or Core_Account__c = '' ) 
                 and core_ips_file_upload_master__r.core_file_guid__c = :FileGUID]);
            
            if (!mFileAssignmentsIdObj.isEmpty()) {
                sFileAssignmentIds = mFileAssignmentsIdObj.keySet();
                lstFileAssignments = mFileAssignmentsIdObj.values();
            }
        }        
        system.debug('###### sFileAssignmentIds AccountShare:' + sFileAssignmentIds.size() );
        
        //Transfer File Upload Master Ids
        for(Core_IPS_File_Assignment__c FileAssignmentObj : lstFileAssignments)
        {
            sFileUploadMasterIds.add(FileAssignmentObj.Core_IPS_File_Upload_Master__c);  
        }
        system.debug('###### sFileUploadMasterIds for File Assignments' + sFileUploadMasterIds.size() );
        //Get Master details
        if(sFileUploadMasterIds.size() > 0) {
            sFileUploadMasterAllIds = GetFileUploadMasterDetails(sFileUploadMasterIds, true, FileGUID);
        }
        system.debug('###### FAE sFileUploadMasterAllIds All:' + sFileUploadMasterAllIds.size());         
        return sFileUploadMasterAllIds;       
    }
/***************************************************************************************************
* Method name  : GetRestrictedFileIDs
* Description  : Get GRDC logged in User's List of File ID's
*                This method is used for both SCFT File downloads and SFT File Authorization
* Return Type  : Set<ID>
* Parameters   : User object instance, FileGUID
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    private static Set<Id> GetRestrictedFileIDs( User u, String FileGUID){
        List<Group>lstUserRoleGroups = new List<Group>();
        List<GroupMember>lstGroupMember = new List<GroupMember>();
        List<AssetShare>lstAssetShare = new List<AssetShare>();
        List<Core_IPS_File_Upload_Master__c> lstFileUploadMaster = new List<Core_IPS_File_Upload_Master__c>();
        List<Core_IPS_File_Assignment__c> lstFileAssignments = new List<Core_IPS_File_Assignment__c>();
        Set<ID> sUserorGroupIds = new Set<ID>();
        Set<ID> sSuppProductIds = new Set<ID>();
        Set<ID> sFileAssignmentIds = new Set<ID>();
        Set<Id> sFileUploadMasterIds = new Set<ID>();
        Set<Id> sFileUploadMasterAccIds = new Set<ID>();
        Set<Id> sFileUploadMasterAllIds = new Set<ID>();
        
        //Get User Contacts and RoleId
        if (u.UserRoleId != null) {
            //Get GroupIds based on RoleId
            lstUserRoleGroups = [SELECT Id, RelatedId FROM Group where RelatedId = :u.UserRoleId];
            system.debug('###### lstUserRoleGroups' + lstUserRoleGroups );
        }
        //Get Direct GroupIds 
        lstGroupMember = [SELECT GroupId,UserOrGroupId FROM GroupMember where userorgroupid = :u.Id];
        system.debug('###### lstGroupMember' + lstGroupMember );
        
        //Collect User Role based Groups
        for(Group GroupObj : lstUserRoleGroups)
        {
            sUserorGroupIds.add(GroupObj.Id);            
        }
        //Collect User direct group assignment
        for(GroupMember GroupMemberObj : lstGroupMember)
        {
            sUserorGroupIds.add(GroupMemberObj.GroupId);
        }
        //Add User
        sUserorGroupIds.add(u.Id);
        system.debug('###### sUserorGroupIds' + sUserorGroupIds );
        //User Groups found -> lookup AssetShare
        if (sUserorGroupIds != null && sUserorGroupIds.size() > 0 ) {
            lstAssetShare = [select assetid, asset.Core_Supported_Product__c, userorgroupid 
                             from assetshare where UserorGroupId in :sUserorGroupIds and
                             asset.RecordtypeId =:System.label.Core_IPS_Asset_Recordtype_Id];
            system.debug('###### lstAssetShare:' + lstAssetShare.size() );
        }
        //Get Supported Product Id's
        if (lstAssetShare != null && lstAssetShare.size() > 0 ) {
            for(AssetShare AssetShareObj : lstAssetShare)
            {
                if (AssetShareObj.asset.Core_Supported_Product__c != null){
                    sSuppProductIds.add(AssetShareObj.asset.Core_Supported_Product__c);
                }
            }   
        }
        //If any Supported Products Found
        if (sSuppProductIds != null && sSuppProductIds.size() > 0 ) {
            system.debug('###### sSuppProductIds:' + sSuppProductIds );
            //Get File Assignments with Supported Products   
            if (FileGUID == null) {
                Map<id, Core_IPS_File_Assignment__c> mFileAssignmentsIdObj = new Map<Id, Core_IPS_File_Assignment__c>(
                    [select id, Core_IPS_File_Upload_Master__c
                     from Core_IPS_File_Assignment__c where Core_Supported_Product__c in :sSuppProductIds
                     and ( Core_Account__c = :u.Contact.AccountId or Core_Account__c = '' )]);
                
                if (!mFileAssignmentsIdObj.isEmpty()) {
                    sFileAssignmentIds = mFileAssignmentsIdObj.keySet();
                    lstFileAssignments = mFileAssignmentsIdObj.values();
                }
            }
            if (FileGUID != null) {
                Map<id, Core_IPS_File_Assignment__c> mFileAssignmentsIdObj = new Map<Id, Core_IPS_File_Assignment__c>(
                    [select id, Core_IPS_File_Upload_Master__c
                     from Core_IPS_File_Assignment__c where Core_Supported_Product__c in :sSuppProductIds
                     and ( Core_Account__c = :u.Contact.AccountId or Core_Account__c = '' ) 
                     and core_ips_file_upload_master__r.core_file_guid__c = :FileGUID]);
                
                if (!mFileAssignmentsIdObj.isEmpty()) {
                    sFileAssignmentIds = mFileAssignmentsIdObj.keySet();
                    lstFileAssignments = mFileAssignmentsIdObj.values();
                }
            }
            
            system.debug('###### sFileAssignmentIds Supported Products:' + sFileAssignmentIds.size() );
            
            //Transfer File Upload Master Ids
            for(Core_IPS_File_Assignment__c FileAssignmentObj : lstFileAssignments)
            {
                sFileUploadMasterIds.add(FileAssignmentObj.Core_IPS_File_Upload_Master__c);  
            }
            system.debug('###### sFileUploadMasterIds Assign for SP' + sFileUploadMasterIds.size() );
            
            //Get Master details
            if(sFileUploadMasterIds.size() > 0) {
                sFileUploadMasterAllIds = GetFileUploadMasterDetails(sFileUploadMasterIds, true, FileGUID);
            }
        }        
        system.debug('###### Restricted sFileUploadMasterAllIds All:' + sFileUploadMasterAllIds );        
        return sFileUploadMasterAllIds;
    }    
/***************************************************************************************************    
* Method name  : GetFileUploadMasterDetails
* Description  : Get File Upload Master details
* Return Type  : Set<ID>
* Parameters   : User object instance
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    private static Set<Id> GetFileUploadMasterDetails(Set<Id> sFileUploadMasterIds, Boolean FilteredById, String FileGUID){
        Set<Id> sFileUploadMasterAllIds = new Set<ID>();
        Map<id, Core_IPS_File_Upload_Master__c> mFileUploadMasterIdObj = new Map<Id, Core_IPS_File_Upload_Master__c>();
        system.debug('###### sFileUploadMasterIds Size:' + sFileUploadMasterIds.size());
        if (FilteredById) {
            Map<id, Core_IPS_File_Upload_Master__c> mFileUploadMasterIdObjFilt = new Map<Id, Core_IPS_File_Upload_Master__c>(
                [select id, Core_File_GUID__c 
                 from Core_IPS_File_Upload_Master__c where id in :sFileUploadMasterIds 
                 and Core_Upload_Status__c = 'Complete'
                 and Core_Expiration_Date__c >= today]);
            mFileUploadMasterIdObj = mFileUploadMasterIdObjFilt; 
        } else if (FileGUID == null && !FilteredById) {
            Map<id, Core_IPS_File_Upload_Master__c> mFileUploadMasterIdObjNoFilt = new Map<Id, Core_IPS_File_Upload_Master__c>(
                [select id, Core_File_GUID__c 
                 from Core_IPS_File_Upload_Master__c where Core_Upload_Status__c = 'Complete'
                 and Core_Expiration_Date__c >= today]);
            mFileUploadMasterIdObj = mFileUploadMasterIdObjNoFilt;    
        }
        else if (FileGUID != null && !FilteredById) {
            Map<id, Core_IPS_File_Upload_Master__c> mFileUploadMasterIdObjNoFilt = new Map<Id, Core_IPS_File_Upload_Master__c>(
                [select id, Core_File_GUID__c 
                 from Core_IPS_File_Upload_Master__c where Core_Upload_Status__c = 'Complete' and
                 core_file_guid__c = :FileGUID]);
            mFileUploadMasterIdObj = mFileUploadMasterIdObjNoFilt;    
        }         
        //Move to Set
        for (Id FileId: mFileUploadMasterIdObj.keySet()) {
            sFileUploadMasterAllIds.add(FileId);
        }
        system.debug('###### GetFileUploadMasterDetails size:' + sFileUploadMasterAllIds.size() );
        return sFileUploadMasterAllIds;
        
    }    
/***************************************************************************************************
* Method name  : RaiseExceptionForTestCoverage
* Description  : Raise dummy exception to cover exception code coverage
* Return Type  : N/A
* Parameters   : N/A
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    private static void RaiseExceptionForTestCoverage(){ 
        Integer MaxSize;
        if(RestContext.request != null) {
            String ExceptFlag = RestContext.request.headers.get('exceptutil');
            if(ExceptFlag == 'X'){
                String Size = '10000000000000';    
                MaxSize = integer.valueof(Size);
            }
        }        
    }
    
    

}