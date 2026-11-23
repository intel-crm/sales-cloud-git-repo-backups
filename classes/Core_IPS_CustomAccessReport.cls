Public class Core_IPS_CustomAccessReport{
    
    Public static void getRecords(Id oldUserId, Id newUserId){
        
        System.debug('Object Query');
    
        List<Case> cs=[Select Id,owner.type,Core_Partner_Supported_Account__r.Name,Contact.Name,Core_IPS_Issue_source__c,AssetId,status,Core_Customer_Reference_ID__c,Core_Platform_Name__c,asset.name,productId,product.name,Core_Case_issue_category__c,Core_IPS_Supported_Product__c,Core_IPS_Supported_Product__r.name,Core_case_issue_sub_category__c,Core_IPS_Product_Org1__c,ContactId,core_ips_project_case__c, core_ips_project_case__r.name,recordtypeId,recordtype.DeveloperName,Core_Partner_Supported_Account__c FROM case where ownerid=:oldUserId or createdbyid=:oldUserId];
    
        system.debug('Related Case Records ::'+cs);
    
        List<Asset> asset=[SELECT AccountId,ContactId,Core_Code_Name__c,Core_IPS_AssetOrganization__c,Core_IPS_Asset__c,Core_IPS_Case__c,Core_IPS_Global_Assets__c,Core_IPS_Project_Name__c,Core_IPS_Project__c,Core_IPS_Supported_Product_EOIS__c,core_Product_Application__c,Core_Product_EPM_ID__c,Core_Product_Organization__c,Core_Project_Asset_Status__c,Core_Supported_Product__c,Core_Support_Org_Name__c,Description,Id,Name,OwnerId,Price,Product2Id,ProductCode,PurchaseDate,Quantity,RecordTypeId,Status FROM Asset where ownerid=:oldUserId or createdbyid=:oldUserId];
    
        system.debug('Related Asset Records ::'+asset);
    
        List<Core_IPS_Case_Interested_Party__c> parties=[SELECT Active__c,Agent_Name__c,Case__c,Contact__c,Core_IPS_Account_Name__c,CreatedById,Email__c,First_Name__c,Id,IsDeleted,Last_Name__c,Name,RecordTypeId,Test__c,Type__c,User__c FROM Core_IPS_Case_Interested_Party__c where  createdbyid=:oldUserId];
    
        system.debug('Related Interested Party Records ::'+parties);
    
        List<CaseComment> cscmt= [SELECT CommentBody,CreatedById,CreatedDate,Id,IsDeleted,IsPublished,LastModifiedById,LastModifiedDate,ParentId FROM CaseComment where createdbyid=:oldUserId];
    
        system.debug('Related CaseComment Records ::'+cscmt);
    
        List<Core_IPS_Project__c> proj=[SELECT Core_IPS_GroupId__c,Core_IPS_Group_Name__c,Core_IPS_Legacy_Collab_Team_ID__c,Core_IPS_ProjectGroupID__c,Core_IPS_Project_ID__c,Core_IPS_Unique_Project_Number__c,Core_MPNDA__c,Core_Number_of_Accounts__c,Core_Number_of_Opportunities__c,Core_Number_of_Products__c,Core_Number_of_Users__c,Core_Project_Description__c,Core_Status__c,CreatedById,Id,IsDeleted,Name,OwnerId,RecordTypeId FROM Core_IPS_Project__c WHERE ownerid=:oldUserId or createdbyid=:oldUserId];
    
        system.debug('Related Project Records ::'+proj);
    
        List<Core_IPS_Case_Attachments__c> attach=[SELECT Core_Case__c,Core_Category__c,Core_FileSizeInBytes__c,Core_FileUploadedBy__c,Core_File_Description__c,Core_File_GUID__c,Core_File_Hyperlink__c,Core_File_Name__c,Core_File_Size__c,Core_File_URL__c,Core_IPS_File_Upload__c,Core_Is_Migrated__c,Core_Last_Status_Updated_At__c,Core_Promote_Status__c,Core_Type__c,Core_Upload_idsid__c,Core_Upload_Status__c,Core_Upload_UserId__c,CreatedById,CreatedDate,Id,IsDeleted,Name FROM Core_IPS_Case_Attachments__c WHERE createdbyid=:oldUserId];
    
        system.debug('Related Attachments Records ::'+attach);
    
    }
    
    
    Public static void getSharedRecords(Id oldUserId, Id newUserId){
        
        System.debug('Object Query');
        List<String> rowCauseList=new List<String>{'Team','Owner','Read','Edit'};
        List<AssetShare> assetShr=[Select Id,AssetId,UserOrGroupId from AssetShare where UserOrGroupId =:oldUserId];
        
        system.debug('Asset share Records ::'+assetShr);
        
        List<CaseShare> csShr=[Select Id,CaseId,UserOrGroupId from CaseShare where RowCause NOT IN: rowCauseList AND UserOrGroupId =:oldUserId];
        
        system.debug('Case share Records ::'+csShr);
        
        List<accountshare> accShr=[select accountId, caseaccesslevel, userOrGroupId, rowcause from accountshare where rowcause in :rowCauseList and userOrGroupId=:oldUserId];
        system.debug('Account share Records ::'+accShr);
        
        List<Group> grp=[SELECT DeveloperName,Id,Name,OwnerId FROM Group where id In (Select GroupId from GroupMember where UserOrGroupId=:oldUserId)];
        system.debug('User belong to group::'+grp);
    }        
    
}