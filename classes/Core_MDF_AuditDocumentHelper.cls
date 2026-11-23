/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditDocumentHelper 
* Version     : 1.0 
* Created Date: 10-10-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        10/10/2018                 Created Core_MDF_AuditDocumentHelper to manage audit document server operations.
* Accenture – Shridhar K        01/07/2019                 Added getCaseStatus method ftech case status to disable buttons.
* Accenture – Shridhar K        01/15/2019                 Updated method "updateCaseAndDocuments" to reset SLA start date when case status is set to Under Review.
* Accenture – Shridhar K        02/28/2019                 Updated getAuditDocuments method to share documents with all external users  
* Accenture – Shridhar K        03/21/2019                 Removed "getCaseStatus" method as Case Status is fetched in "getAuditDocuments"
* Accenture – Sugathri N        07/23/2019                 Updated getAuditDocuments method to enable documents upload from Claim also  
* Accenture – Sugathri N        08/20/2019                 Added deleteDocumentIds method to delete documents which are atached to user when claim is not created
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AuditDocumentHelper {
    
    /****************************************************************************************************************************************
Method Name:                                             getAuditDocuments
@return  :                                               List of audit document
@parameters:                                             Object record Id
Description:                                             Returns list required document.
Added By:                                                Accenture – Shridhar K  -  10/10/2018
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K        10/10/2018                 Created.
Accenture – Shridhar K        02/28/2019                 Added Content Document Link  
Accenture – Sugathri N        07/23/2019                 Added two String fields to enable documents upload and storing from Claim object as well  
*****************************************************************************************************************************************/ 
    @AuraEnabled
    public static sObjectDocumentWrapper getAuditDocuments(Id recordId, list<String> documentIdWithTitle){
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        list<String> tempString = new list<String>();
        
        String errorMessage = '';
        
        System.debug('caseId: '+recordId);
        System.debug('documentIdWithTitle:'+documentIdWithTitle);
        
        List<Id> contentDocIdList = new list<Id>();
        List<ContentDocumentLink> conDocLinkToBeUpdated = new List<ContentDocumentLink>();
        
        
        //Added claimId and caseId to fetch and store the documents both in claim and case if claim has case and vice versa by Sugathri 07/23/2019 
        String claimId;
        String caseId;
        String caseStatus; 
        String claimStatus;
        Boolean enableComponentOnDetail = true;
        Boolean submitButton;
        
        try{
            List<ContentDocumentLink> conDocLinksToBeInserted = new  List<ContentDocumentLink>();
            List<String> claimSubmitterPSList = Label.Core_MDF_External_Claim_Submitter.split(';');
            if(recordId != null){
                List<PermissionSetAssignment> usrPerList = [SELECT Id, AssigneeId, PermissionSet.Name
                                                            FROM PermissionSetAssignment
                                                            WHERE AssigneeId =:UserInfo.getUserId() AND 
                                                            PermissionSet.Name IN: claimSubmitterPSList];
                // adding a condition to disable the component for the Payment Admin users 
                if((usrPerList != null && usrPerList.size() > 0) || FeatureManagement.checkPermission(Label.Core_MDF_ClaimCaseReviewerManager))// || !(FeatureManagement.checkPermission(Label.Core_MDF_PaymentAdmin)))
                {
                    enableComponentOnDetail = true;
                }else{
                    enableComponentOnDetail = false;
                }
                
                String recId = String.valueof(recordId);
                if(recId.startsWith('0RB') && enableComponentOnDetail){
                    PartnerFundClaim pfc = new PartnerFundClaim();
                    pfc = [SELECT Id,Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_Status__c FROM PartnerFundClaim WHERE Id =:recId limit 1];
                    claimId = pfc.Id;
                    caseId = pfc.Core_MDF_Claim_Review_Case__c;                    
                    caseStatus = pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c;    
                    claimStatus = pfc.Core_MDF_Status__c;
                    // for Claim in Pending Doc/Paid /Cancelled -- Disable the Component  // One Label 
                    
                    List<String> claimStatusLst = System.Label.Core_MDF_Claim_Statuses_for_enabling_disabling_Buttons.split(';');
                    
                    if(caseId == '' || caseId == null) {
                        
                        // if(claimSts == claimStatus){  
                        if (claimStatusLst.contains(claimStatus)){                        
                            enableComponentOnDetail = false;
                        }
                        else{
                            enableComponentOnDetail = true;
                            submitButton = true;
                        }
                        
                    }
                    else{ 
                        if(caseStatus == System.Label.Core_MDF_Case_Status_Pending_Document){
                            enableComponentOnDetail = true;
                        }
                        else{enableComponentOnDetail = false;}
                    }
                }
                
                if(recId.startsWith('500')){
                    Case cse = new Case();
                    cse = [SELECT Id,Core_MDF_Claim_ID__c, Core_MDF_Status__c FROM Case WHERE Id =:recId];
                    claimId = cse.Core_MDF_Claim_ID__c;
                    caseId = cse.Id;
                    caseStatus = cse.Core_MDF_Status__c;
                }
                
                if(!documentIdWithTitle.isEmpty()){
                    for(String str: documentIdWithTitle){
                        tempString = str.split(';#');
                        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                        auditDoc.Core_MDF_Document_Id__c = tempString[0];
                        auditDoc.Core_MDF_Document_Title__c = tempString[1];
                        auditDoc.Core_MDF_Claim__c = claimId;
                        auditDoc.Core_MDF_Audit__c = caseId;
                        auditDocList.add(auditDoc);
                        
                        
                        contentDocIdList.add(Id.valueOf(tempString[0]));
                        
                        //Insert ContentDocumentLink
                        Id parentLinkedEntityId;
                        if(recId.startsWith('500')){
                            parentLinkedEntityId= claimId;
                            ContentDocumentLink conDocLink = new ContentDocumentLink();
                            conDocLink.ContentDocumentId = auditDoc.Core_MDF_Document_Id__c;
                            conDocLink.LinkedEntityId = claimId;
                            conDocLink.ShareType='I';
                            conDocLink.Visibility='AllUsers';
                            conDocLinksToBeInserted.add(conDocLink);
                            
                        }
                        if(recId.startsWith('0RB')){
                            
                            ContentDocumentLink conDocLink = new ContentDocumentLink();
                            conDocLink.ContentDocumentId = auditDoc.Core_MDF_Document_Id__c;
                            conDocLink.LinkedEntityId = claimId;
                            conDocLink.ShareType='I';
                            conDocLink.Visibility='AllUsers';
                            conDocLinksToBeInserted.add(conDocLink);
                            if(caseId != null){
                                ContentDocumentLink conDocLinkCase = new ContentDocumentLink();
                                conDocLinkCase.ContentDocumentId = auditDoc.Core_MDF_Document_Id__c;
                                conDocLinkCase.LinkedEntityId = caseId;
                                conDocLinkCase.ShareType='I';
                                conDocLinkCase.Visibility='AllUsers';
                                conDocLinksToBeInserted.add(conDocLinkCase);
                            }
                        }
                        
                        
                    }
                    
                    //System.debug('Inserted auditDocList:'+auditDocList);
                    
                    //Below lines are added by Shridhar 02/28/2019
                    //ContentDocumentLink is updated to share uploaded document with external user
                    //ShareType is set to 'I', to share the document.
                    // Inferred permission. The user’s permission is determined by the associated record.  
                    
                    for(ContentDocumentLink conDocLink: [SELECT Id, ShareType, LinkedEntityId, Visibility,ContentDocumentId FROM ContentDocumentLink 
                                                         WHERE ContentDocumentId IN: contentDocIdList]){                                                         
                                                             if(String.valueOf(conDocLink.LinkedEntityId).startsWith('500') || String.valueOf(conDocLink.LinkedEntityId).startsWith('0RB')){
                                                                 conDocLink.ShareType = 'I';
                                                                 conDocLink.Visibility = 'AllUsers';
                                                                 conDocLinkToBeUpdated.add(conDocLink);                                                      
                                                             }
                                                         }
                    
                    if(conDocLinkToBeUpdated.size() > 0){Database.update(conDocLinkToBeUpdated);
                                                        }                           
                    if(conDocLinksToBeInserted.size()>0){
                        Database.insert(conDocLinksToBeInserted);
                    }
                    
                    if(auditDocList.size()>0){Database.insert(auditDocList);                  
                                             }
                    
                }                                                                                           
                else{
                    auditDocList = [SELECT Id, Core_MDF_Audit__c, Core_MDF_Claim__c, Core_MDF_Document_Id__c, Core_MDF_Document_Title__c,Core_MDF_Proof_of_Branding__c, Core_MDF_Proof_of_Cost__c,
                                    Core_MDF_Proof_of_Execution__c, Core_MDF_Document_Types__c FROM Core_MDF_Audit_Document__c WHERE Core_MDF_Claim__c =: claimId OR (Core_MDF_Audit__c =: caseId and Core_MDF_Audit__c != null)];
                    System.debug('Existing auditDocList:'+auditDocList);
                }
                
                
                
                sObjectDocumentWrapper sobjDocWrap = new sObjectDocumentWrapper();     
                sobjDocWrap.documentList=auditDocList;
                System.debug('userinfo.getProfileid(): '+userinfo.getProfileid());
                System.debug('userinfo.getUserId(): '+userinfo.getUserId());                
                String profileName = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileid()].Name;
                
                if(profileName == 'Partner'){
                    sobjDocWrap.isPartner = TRUE;
                }else{
                    sobjDocWrap.isPartner = FALSE;
                }
                String sObjectName = recordId.getSObjectType().getDescribe().getName();
                sobjDocWrap.sObjName = sObjectName;
                sobjDocWrap.isEditable=Schema.sObjectType.Case.isUpdateable();
                sobjDocWrap.isReadable=Schema.sObjectType.Case.isAccessible();
                sobjDocWrap.caseStatus = caseStatus;
                sobjDocWrap.claimStatus = claimStatus;
                sobjDocWrap.enableComponentOnDetail = enableComponentOnDetail;
                sobjDocWrap.submitButton = submitButton;
                return sobjDocWrap;
            }else{
                return null;
            }
        }       
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Case_Review_Document_Log_Entry_Origin);                  
            System.debug('errorDetails Get Document: '+errorDetails);
        }    
        return null;
    }
    /****************************************************************************************************************************************
Method Name:                                             updateAuditDocument
@return  :                                               --
@parameters:                                             Object record Id, Core_MDF_Audit_Document__c list needs to be updated, isinert boolean
Description:                                             Updates Core_MDF_Audit_Document__c record to manage file type
Added By:                                                Accenture – Shridhar K  -  10/10/2018
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K        10/10/2018                 Created.
*****************************************************************************************************************************************/ 
    @AuraEnabled   
    public static boolean updateAuditDocument(list<Core_MDF_Audit_Document__c> auditDocList){
        
        boolean createErrorLog = false;
        String errorMessage = '';
        //System.debug('auditDocList:'+auditDocList[0].Id);   
        try{
            if(auditDocList.size() > 0){Database.update(auditDocList);
                                       }            
        }
        catch(Exception e){
            createErrorLog = true; String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Case_Review_Document_Log_Entry_Origin);
        }                                         
        //System.debug('errorDetails: '+errorDetails);
        return createErrorLog;
        
    }
    
    
    /****************************************************************************************************************************************
Method Name:                                             updateObjectAndDocuments
@return  :                                               --
@parameters:                                             Object record Id
Description:                                             Updates Case Status to Pending Review
Added By:                                                Accenture – Shridhar K  -  11/15/2018
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K        11/15/2018                 Created.
Accenture – Shridhar K        01/15/2019                 Added SLA Start date to reset the date when case status is set to Under Review.
Accenture - Sugathri N        07/23/2019                 Changed it to updateObjectAndDocuments to make it more generic
*****************************************************************************************************************************************/ 
    @AuraEnabled   
    public static boolean updateObjectAndDocuments(Id recordId, list<Core_MDF_Audit_Document__c> auditDocList){
        
        boolean createErrorLog = false;
        String errorMessage = '';   
        
        try{
            if(recordId != null){
                String recId = String.valueof(recordId);
                //Added claim condition to make it usable for claim also
                if(recId.startsWith('0RB')){
                    PartnerFundClaim pfc = [SELECT Id,Core_MDF_Claim_Review_Case__c FROM PartnerFundClaim WHERE Id =:recId];
                    if(pfc.Core_MDF_Claim_Review_Case__c != null){
                        Case tobeUpdated = [SELECT Id, Core_MDF_Status__c FROM Case WHERE id=:pfc.Core_MDF_Claim_Review_Case__c];
                        tobeUpdated.Core_MDF_Status__c = Label.Core_MDF_Case_Status_Under_Review; 
                        toBeUpdated.Core_MDF_More_Documentation_Required__c = false;                
                        //Modified by Ealisha - US499699: [Case: SLA Calculation] - Refresh "Days SLA Remaining" at 5 am PST
                        //toBeUpdated.Core_MDF_SLA_Start_Date__c = Core_MDF_ClaimReviewCaseProcessHelper.setSLAStartDate(); 
                        toBeUpdated.Core_MDF_SLA_Start_Date__c = System.now();
                        Database.update(toBeUpdated); 
                        Database.update(auditDocList);
                    }
                }
                if(recId.startsWith('500')){
                    Case toBeUpdatedCase = [SELECT Id, Core_MDF_Status__c FROM Case WHERE id=:recordId];
                    if(toBeUpdatedCase != null){                
                        toBeUpdatedCase.Core_MDF_Status__c = Label.Core_MDF_Case_Status_Under_Review;                 
                        toBeUpdatedCase.Core_MDF_More_Documentation_Required__c = false;                
                        //Modified by Ealisha - US499699: [Case: SLA Calculation] - Refresh "Days SLA Remaining" at 5 am PST
                        //toBeUpdatedCase.Core_MDF_SLA_Start_Date__c = Core_MDF_ClaimReviewCaseProcessHelper.setSLAStartDate();  
                        toBeUpdatedCase.Core_MDF_SLA_Start_Date__c = System.now(); 
                        Database.update(toBeUpdatedCase);  
                        Database.update(auditDocList);
                    }            
                }
            }
        }
        catch(Exception e){
            createErrorLog = true; String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Case_Review_Document_Log_Entry_Origin);
        }                                  
        return createErrorLog;
        
    }       
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    // changed it to sObjectDocumentWrapper to make it more generic by Sugathri 7/23/19
    public class SObjectDocumentWrapper{
        @AuraEnabled
        public String caseStatus{get;set;}
        @AuraEnabled
        public String claimStatus{get;set;}
        @AuraEnabled
        public List<Core_MDF_Audit_Document__c> documentList{get;set;}
        @AuraEnabled
        public Boolean isPartner{get;set;}
        @AuraEnabled
        public Boolean isEditable{get;set;}
        @AuraEnabled
        public Boolean isReadable{get;set;}  
        @AuraEnabled
        public String sObjName{get;set;}
        @AuraEnabled
        public Boolean submitButton{get;set;}
        @AuraEnabled
        public Boolean enableComponentOnDetail{get;set;}
        
    }
    
    /****************************************************************************************************************************************
Method Name:                                             updateClaimSubmitterMsg
@return  :                                               --
@parameters:                                             Case record Id, Claim Submitter Message comment
Description:                                             Updates Claim Submitter Message Field
Added By:                                                Accenture – Harika P  -  17/06/2019
Modified By:                  Date:                      Changes: 
Accenture – Harika P         17/06/2019                  Created.
*****************************************************************************************************************************************/     
    // For Saving the Claim Submitters Message
    @AuraEnabled   
    public static boolean updateClaimSubmitterMsg(Id recordId,string submitterMessage){
        boolean isSuccess = true;
        try{
            Case caseToBeUpdated = new Case();
            caseToBeUpdated.id = recordId;
            caseToBeUpdated.Core_MDF_Claim_Submitter_Message_txt__c = submitterMessage;
            Database.update(caseToBeUpdated);               
        }
        catch(Exception e){
            isSuccess = false;
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return isSuccess;
        
    }
    
    /****************************************************************************************************** 
Method Name:        deleteDocumentIds
@return  :          
@parameters:        docIds
Description:        delete the document selected by user
Added By:           Sugathri - 22/08/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static void deleteDocumentIds(list<string> docIds)
    {
        boolean createErrorLog = false;
        List<ContentDocumentLink> doclinkIdsDel = new List<ContentDocumentLink>();
        List<ContentDocument> docIdsDel = new List<ContentDocument>();
        try{
            if (docIds.size() > 0){
                doclinkIdsDel = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN: docIds
                                 AND LinkedEntityId = null];
                docIdsDel = [SELECT Id FROM ContentDocument WHERE Id IN: docIds];
                if (doclinkIdsDel.size() > 0){
                    Database.delete(doclinkIdsDel);
                }
                if (docIdsDel.size() > 0){
                    Database.delete(docIdsDel);
                }
            }
        }
        catch(Exception e){createErrorLog = true; String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_DeleteFile_Error);}     
        
    }
}