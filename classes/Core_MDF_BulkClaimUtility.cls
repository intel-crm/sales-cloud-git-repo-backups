/*
* Class Name  : Core_MDF_BulkClaimUtility 
* Version     : 1.0 
* Created Date: 11-04-2019
* Modification Log :
* Developer               Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – JV         11/04/2019                    Created Core_MDF_BulkClaimUtility as a Without Sharing Server Class for Bulk Claim functionality
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public without sharing class Core_MDF_BulkClaimUtility {
    public class BulkClaimException extends Core_MDF_BulkClaimServerController.BulkClaimException{}
    /**
      * @description: This method is used to create the Claim Batch Record And Attach the Uploaded template related to it
      * @param channelProgramId: Channel Program Id of the Channel Program selected by the User while uploadin the template
      * @param blobData: Content of the File Uploaded by the User in Blob format 
      */
    public static Core_MDF_Claim_Batch__c createBatchRecordAndAttachUploadedTemplate(String fileName,String channelProgramId, Blob blobData){
        
        Core_MDF_Claim_Batch__c claimbatchinstance = new Core_MDF_Claim_Batch__c();
        claimbatchinstance.Core_MDF_Program_Id__c =  channelProgramId;
        Id ultimateAccountId = getUltimateAccountId();
        // To assign the ultimate account Id during test run
        if(Test.isRunningTest()){
            ultimateAccountId = [Select id from Account limit 1].id;
        }
        if(ultimateAccountId != null){
            claimbatchinstance.Core_MDF_Account__c = ultimateAccountId;
            Database.SaveResult sr = Database.insert(claimbatchinstance);
            //Attach the Uploaded file if Insertion success
            if(sr.isSuccess()){
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = blobData;
                cv.Title = fileName;
                cv.PathOnClient = fileName; 
                Database.insert(cv);
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = sr.getID();
                cdl.ShareType = 'V';
                Database.insert(cdl);

                ContentDocument cd = [SELECT Id,OwnerId FROM ContentDocument WHERE Id=:cdl.ContentDocumentId LIMIT 1];
                updateOwnerToFLAOUser(cd);
                
                return claimbatchinstance;
            }else{
                return null;
            }
        }else{
            throw new BulkClaimException(Label.Core_MDF_UltimateAccountAccessError);
        }
    }
    
    ///Get the ulimate account of the user and store in batch
     public static ID getUltimateAccountId()
    {
        ID ultimateAccountID = null;
        List<Core_MDF_Partner_Node_User_Mapping__c> accountUserMapping = [SELECT Id,Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_User__c 
                                                                          FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                          WHERE Core_MDF_User__c = :UserInfo.getUserId() LIMIT 1];
        
        if(accountUserMapping != NULL && accountUserMapping.size() > 0)
        {
            ultimateAccountID = accountUserMapping[0].Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c;
        }
        return ultimateAccountID;
    }
    
    /**
      * @description : This method is used to update the Owner to the Dummy FLAO User 
      *                corresponding to the Uploaded File
      * @param cd :  ContentDocument of the File 
      */
    public static void updateOwnerToFLAOUser(ContentDocument cd) {
        cd.OwnerId = Label.Core_MDF_Dummy_Account_Owner_Id;   
        Database.update(cd);
    }
     
    
}