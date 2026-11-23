public without sharing class Core_MDF_ClmBatchStgAuditDocHelper {
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
        String caseAuditType;
        // Added instances of Claim and case
        PartnerFundClaim pfc = new PartnerFundClaim();
        Case cse = new Case();
        
        try{
            List<ContentDocumentLink> conDocLinksToBeInserted = new  List<ContentDocumentLink>();
            List<String> claimSubmitterPSList = Label.Core_MDF_External_Claim_Submitter.split(';');
            if(recordId != null){
                List<PermissionSetAssignment> usrPerList = [SELECT Id, AssigneeId, PermissionSet.Name
                                                            FROM PermissionSetAssignment
                                                            WHERE AssigneeId =:UserInfo.getUserId() AND 
                                                            PermissionSet.Name IN: claimSubmitterPSList];
                // adding a condition to disable the component for the Payment Admin users 
                //US867474 - [RMF] - PRC Mystery Shopper to receive Audit Notifications and submit additional POP
                if((usrPerList != null && usrPerList.size() > 0) || 
                   FeatureManagement.checkPermission(Label.Core_MDF_ClaimCaseReviewerManager)||FeatureManagement.checkPermission(Label.Core_MDF_CCP_RMF_Internal_Claim_Operations)){
                    enableComponentOnDetail = true;}
                else{
                    enableComponentOnDetail = false;}
                
                String recId = String.valueof(recordId);
                system.debug(recId + 'recId');
                system.debug (enableComponentOnDetail);
                if(recId.startsWith('0RB') && enableComponentOnDetail){
                    //PartnerFundClaim pfc = new PartnerFundClaim();
                    pfc = [SELECT Id,RecordType.DeveloperName, Core_MDF_Program__c, Core_MDF_Budget_Type_Nm__c, /*Request.Core_MDF_Budget_Type_txt__c,*/Core_MDF_Claim_Review_Case__c,
                           Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_Status__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Document_Hold_Eligibility_Ind__c,Core_MDF_Audit_Hold__c,Core_MDF_Audit_Type__c 
                           FROM PartnerFundClaim 
                           WHERE Id =:recId 
                           limit 1];
                    claimId = pfc.Id;
                    caseId = pfc.Core_MDF_Claim_Review_Case__c;                    
                    caseStatus = pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c;    
                    claimStatus = pfc.Core_MDF_Status__c;
                    // for Claim in Pending Doc/Paid /Cancelled -- Disable the Component  // One Label 
                    List<String> claimStatusLst = System.Label.Core_MDF_Claim_Statuses_for_enabling_disabling_Buttons.split(';');
                    
                    if(caseId == '' || caseId == null) {
                        
                        //  If claim status in the list or Check if claim status is not in the list, document hold eligibility is true,document hold is false and review hold is false, then update enableComponentOnDetail as false
                        if (claimStatusLst.contains(claimStatus) || (isClmReleasedFromDocHold(pfc))){  enableComponentOnDetail = false; }
                        
                        else{
                            enableComponentOnDetail = true;
                            // If claim is on Document Hold, then update submitButton (For Doc Hold Claims, submit button will be enabled) as false else true                           
                           submitButton = pfc.Core_MDF_Document_Hold_Ind__c ? false:true;
                        }   
                    }
                    else{ 
                        // checking if case status is 'Pending Documents' and isClaimToBeDeniedDueToNoDocs is false
                        if(caseStatus == System.Label.Core_MDF_Case_Status_Pending_Document && !(isClaimToBeDeniedDueToNoDocs(pfc))){
                            enableComponentOnDetail = true;
                        }
                        else{
                            enableComponentOnDetail = false;
                        }
                    }
                }
             //US949927, NK : Budget type consolidation for case
                if(recId.startsWith('500')){
                    //Case cse = new Case();
                    cse = [SELECT Id,Core_MDF_Channel_Program_txt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Claim_ID__c, Core_MDF_Status__c,Core_MDF_AuditType_nm__c FROM Case WHERE Id =:recId];
                    claimId = cse.Core_MDF_Claim_ID__c;
                    caseId = cse.Id;
                    caseStatus = cse.Core_MDF_Status__c;
                    caseAuditType = cse.Core_MDF_AuditType_nm__c;
                }
                
                
                if(!documentIdWithTitle.isEmpty()){
                    for(String str: documentIdWithTitle){
                        tempString = str.split(';#');
                        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                        auditDoc.Core_MDF_Document_Id__c = tempString[0];
                        auditDoc.Core_MDF_Document_Title__c = tempString[1];
                        auditDoc.Core_MDF_Claim__c = claimId;
                        auditDoc.Core_MDF_Audit__c = caseId;
                        auditDoc.Core_MDF_Document_Types__c='';
                        auditDoc.Core_MDF_App_Document_Types_nm__c='';
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
                    
                    //Below lines are added by Shridhar 02/28/2019
                    //ContentDocumentLink is updated to share uploaded document with external user
                    //ShareType is set to 'I', to share the document.
                    // Inferred permission. The user’s permission is determined by the associated record.  
                    
                    for(ContentDocumentLink conDocLink: [SELECT Id, ShareType, LinkedEntityId, Visibility,ContentDocumentId FROM ContentDocumentLink 
                                                         WHERE ContentDocumentId IN: contentDocIdList]){                                                         
                                                             if(String.valueOf(conDocLink.LinkedEntityId).startsWith('500') || String.valueOf(conDocLink.LinkedEntityId).startsWith('0RB')){conDocLink.ShareType = 'I'; conDocLink.Visibility = 'AllUsers'; conDocLinkToBeUpdated.add(conDocLink);                                                      
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
                   if(String.isNotBlank(claimId) || String.isNotBlank(caseId)){
						auditDocList = [SELECT Id, Core_MDF_Audit__c, Core_MDF_App_Document_Types_nm__c, Core_MDF_Applicable_Document_Types_txt__c, Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Claim__c, Core_MDF_Document_Id__c, Core_MDF_Document_Title__c,
                                    Core_MDF_Document_Types__c FROM Core_MDF_Audit_Document__c WHERE (Core_MDF_Claim__c != null AND Core_MDF_Claim__c =: claimId) OR (Core_MDF_Audit__c != null AND Core_MDF_Audit__c =: caseId)];
					}
                    System.debug('Existing auditDocList:'+auditDocList);
                }
                
               System.debug('Existing auditDocList1:'+auditDocList); 
                
                sObjectDocumentWrapper sobjDocWrap = new sObjectDocumentWrapper();     
                sobjDocWrap.documentList=auditDocList;
                System.debug('userinfo.getProfileid(): '+userinfo.getProfileid());
                System.debug('userinfo.getUserId(): '+userinfo.getUserId());                
               //string profileName = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileid()].Name;
                if(usrPerList != null && usrPerList.size() > 0 ){
                 sobjDocWrap.isPartner = TRUE; 
                }
                else{
                    sobjDocWrap.isPartner = FALSE;
                }

                String sObjectName = recordId.getSObjectType().getDescribe().getName();
                sobjDocWrap.sObjName = sObjectName;
                
                //US1107779: [WW42] - [PIC Review Process] - New intermediate Status in Case
                sobjDocWrap.isEditable = Schema.sObjectType.Case.isUpdateable() && !FeatureManagement.checkPermission('Core_MDF_CCP_PIC_Reviewer');

                //US867474 - [RMF] - PRC Mystery Shopper to receive Audit Notifications and submit additional POP
                if (!sobjDocWrap.isEditable && FeatureManagement.checkPermission(Label.Core_MDF_CCP_RMF_Internal_Claim_Operations)){
                    sobjDocWrap.isEditable = true; sobjDocWrap.isClaimSubmitter = true;
                }
                
                sobjDocWrap.isReadable= Schema.sObjectType.Case.isAccessible();
                sobjDocWrap.caseStatus = caseStatus;
                sobjDocWrap.claimStatus = claimStatus;
                sobjDocWrap.enableComponentOnDetail = enableComponentOnDetail;
                sobjDocWrap.submitButton = submitButton;
                sobjDocWrap.pfcRec = pfc;
                sobjDocWrap.cseRec = cse;
                sobjDocWrap.caseAuditType = caseAuditType;
                return sobjDocWrap;
            }else{return null;}
        }       
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }    
        return null;
    }

    @AuraEnabled   
    public static boolean updateAuditDocument(list<Core_MDF_Audit_Document__c> auditDocList){
        
        boolean createErrorLog = false;
        String errorMessage = '';

        try{
            if(auditDocList.size() > 0){
                Database.update(auditDocList);
                updateLastPOPDocDateOnClaim(auditDocList);
            }            
        }
        catch(Exception e){
            createErrorLog = true; Core_MDF_CCP_UtilityClass.logError(e);}                                         
        
        return createErrorLog;
        
    }
    
    @AuraEnabled   
    public static boolean updateObjectAndDocuments(Id recordId, list<Core_MDF_Audit_Document__c> auditDocList){
        
        boolean createErrorLog = false;
        String errorMessage = '';   
        Map<Id,PartnerFundClaim> clmsOnDocHoldMap = new Map<Id,PartnerFundClaim>();
        Boolean pfcOnDocHold = false;
        try{
            if(recordId != null){
                String recId = String.valueof(recordId);
                //Added claim condition to make it usable for claim also
                if(recId.startsWith('0RB')){
                    PartnerFundClaim pfc = [SELECT Id,Core_MDF_Claim_Review_Case__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c, 
                                            Core_MDF_Audit_Hold__c, Core_MDF_Audit_Type__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Status__c,
                                            Core_MDF_Document_Hold_Ind__c,Core_MDF_Document_Hold_Eligibility_Ind__c,Core_MDF_RMF_Last_POP_Submission_Dt__c,
                                            Core_MDF_Manaul_Audit_Staging_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c, 
                                            Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c, 
                                            Core_MDF_VAT_Hold_Ind__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Bank_Doc_Hold_Ind__c
                                            FROM PartnerFundClaim 
                                            WHERE Id =:recId];
                    
                    if(pfc.Core_MDF_Claim_Review_Case__c != null && 
                       pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c == Label.Core_MDF_Case_Status_Pending_Document){
                           
                           Case tobeUpdated = [SELECT Id, Core_MDF_Status__c,Core_MDF_More_Documentation_Required__c,Core_MDF_SLA_Start_Date__c 
                                               FROM Case 
                                               WHERE Id =: pfc.Core_MDF_Claim_Review_Case__c];
                           tobeUpdated.Core_MDF_Status__c = Label.Core_MDF_Case_Status_Under_Review;
                           toBeUpdated.Core_MDF_More_Documentation_Required__c = false;
                           //Modified by Ealisha - US499699: [Case: SLA Calculation] - Refresh "Days SLA Remaining" at 5 am PST
                           //toBeUpdated.Core_MDF_SLA_Start_Date__c = Core_MDF_ClaimReviewCaseProcessHelper.setSLAStartDate(); 
                           toBeUpdated.Core_MDF_SLA_Start_Date__c = System.now(); 
                           Database.update(toBeUpdated); Database.update(auditDocList);
                    }
                    // checking if document hold is true, then update the auditdoclist and put the claim in clmsOnDocHoldMap
                    else if(pfc.Core_MDF_Document_Hold_Ind__c){
                        Database.update(auditDocList);
                        pfcOnDocHold = true;
                        // storing the claim in a map for calling releaseDocHoldOrProcessManualAudit method
                        clmsOnDocHoldMap.put(pfc.Id,pfc);
                    }
                }
                
                if(recId.startsWith('500')){
                    Case toBeUpdatedCase = [SELECT Id, Core_MDF_Status__c,
                                            Core_MDF_More_Documentation_Required__c, Core_MDF_SLA_Start_Date__c
                                            FROM Case 
                                            WHERE Id =: recordId];
                    if(toBeUpdatedCase != null && toBeUpdatedCase.Core_MDF_Status__c == Label.Core_MDF_Case_Status_Pending_Document){                
                        toBeUpdatedCase.Core_MDF_Status__c = Label.Core_MDF_Case_Status_Under_Review;                 
                        toBeUpdatedCase.Core_MDF_More_Documentation_Required__c = false;                
                        //Modified by Ealisha - US499699: [Case: SLA Calculation] - Refresh "Days SLA Remaining" at 5 am PST
                        //toBeUpdatedCase.Core_MDF_SLA_Start_Date__c = Core_MDF_ClaimReviewCaseProcessHelper.setSLAStartDate(); 
                        toBeUpdatedCase.Core_MDF_SLA_Start_Date__c = System.now(); 
                        Database.update(toBeUpdatedCase);  
                        Database.update(auditDocList);
                    }            
                }
                if(auditDocList != NULL && auditDocList.size()>0 && !pfcOnDocHold){
                    updateLastPOPDocDateOnClaim(auditDocList);
                }
                // if clmsOnDocHoldMap is not null then call releaseDocHoldOrProcessManualAudit method
				if(clmsOnDocHoldMap != NULL && clmsOnDocHoldMap.size()>0){
                    system.debug('clmsOnDocHoldMap::'+clmsOnDocHoldMap);
                    releaseDocHoldOrProcessManualAudit(clmsOnDocHoldMap);
                }                
            }
        }
        catch(Exception e){
            createErrorLog = true; Core_MDF_CCP_UtilityClass.logError(e);}                                  
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
        // to fetch PartnerFundClaim data
        @AuraEnabled
        public PartnerFundClaim pfcRec;
        // to fetch Case data
        @AuraEnabled
        public Case cseRec;
        //US867474 - [RMF] - PRC Mystery Shopper to receive Audit Notifications and submit additional POP
        @AuraEnabled
        public Boolean isClaimSubmitter{get;set;}
        //US1056918 - [OEM Integration] - [POP Selection] - Create Case when Docs not Submitted and Mark Case Non Compliant
        @AuraEnabled
        public String caseAuditType{set;get;}
        
    }

    public static void updateLastPOPDocDateOnClaim(list<Core_MDF_Audit_Document__c> auditDocList){
        Map<Id,PartnerFundClaim> pfcMap = new Map<Id,PartnerFundClaim>();
        try{
            for(Core_MDF_Audit_Document__c auditDoc : [SELECT Id, CreatedDate, Core_MDF_Claim__c, Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c
                                                       FROM Core_MDF_Audit_Document__c WHERE Id IN: auditDocList  ORDER BY CreatedDate Desc]){
                                                                        
                Date auditCreatedDate = date.newinstance(auditDoc.CreatedDate.year(), auditDoc.CreatedDate.month(), auditDoc.CreatedDate.day());
                if((auditDoc.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c == null || auditCreatedDate > auditDoc.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c) && !pfcMap.containsKey(auditDoc.Core_MDF_Claim__c)){
                    PartnerFundClaim pfc = new PartnerFundClaim();
                    pfc.Id = auditDoc.Core_MDF_Claim__c;
                    pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = auditCreatedDate;
                    pfcMap.put(pfc.Id,pfc);
                }   
				system.debug('pfcMap::'+pfcMap);                                                         
            }
            if(pfcMap != null && pfcMap.size() >0){Database.update(pfcMap.values());} 
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }    
    
    // Method to release claims from Document Hold
    public static void releaseDocHoldOrProcessManualAudit(Map<Id,PartnerFundClaim> clmsOnDocHoldMap){
        system.debug('clmsOnDocHoldMap::'+clmsOnDocHoldMap);
        // This map is used for storing the manual audit claims
        Map<Id,PartnerFundClaim> pfcToBeSelForManualAudit = new Map<Id,PartnerFundClaim>();
        // This map is used for storing the claims which needs to be released from document hold
        Map<Id,PartnerFundClaim> pfcToBeReleasedMap = new Map<Id,PartnerFundClaim>();
        // This map is used for storing the last pop sumbission date for document hold claims
        Map<Id,PartnerFundClaim> lastPOPDocDateMap = new Map<Id,PartnerFundClaim>();
        try{
            // returns the last pop submission date for document hold claims
            lastPOPDocDateMap = updateLastPOPDocDateForCMPClaim(clmsOnDocHoldMap.keySet());
            for(PartnerFundClaim pfc : clmsOnDocHoldMap.values()){
                // checking if claim id is available in lastPOPDocDateMap and assign the value to Last POP Submission field
                if(lastPOPDocDateMap != null && lastPOPDocDateMap.containsKey(pfc.id) && lastPOPDocDateMap.get(pfc.Id) != null){
                    pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = lastPOPDocDateMap.get(pfc.Id).Core_MDF_RMF_Last_POP_Submission_Dt__c;
                }
                // checking if claim is previously selected for manual audit, then uncheck document hold, and put claim on audit hold
                if(pfc.Core_MDF_Manaul_Audit_Staging_Ind__c){
                    pfc.Core_MDF_Document_Hold_Ind__c = false;
                    pfc.Core_MDF_Audit_Type__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual');
                    pfc.Core_MDF_Audit_Hold__c = true;
                    pfc.Core_MDF_FlaggedForAudit__c = true;
                    pfc.Core_MDF_Manaul_Audit_Staging_Ind__c = false;                    
                    pfcToBeSelForManualAudit.put(pfc.Id,pfc);
                }else{
                    system.debug('coming to else part in AuditDocHelper');
                    pfcToBeReleasedMap.put(pfc.Id,pfc);
                }
            }
            // if pfcToBeSelForManualAudit is not null then update claims
            if(pfcToBeSelForManualAudit != null && pfcToBeSelForManualAudit.size() >0){Database.update(pfcToBeSelForManualAudit.values());} 
            // if pfcToBeReleasedMap is not null then call releaseHold method
            if(pfcToBeReleasedMap != null && pfcToBeReleasedMap.size() > 0) { 
                Core_MDF_Claim_Utility.releaseHold(pfcToBeReleasedMap.values(),new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Document_Hold')});
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    // This method is used to return the pfc map for storing last pop sumbission date whose claims are on document hold
    public static Map<Id,PartnerFundClaim> updateLastPOPDocDateForCMPClaim(Set<Id>docHoldClaims){
        Map<Id,PartnerFundClaim> pfcWithLastPOPDocDateMap = new Map<Id,PartnerFundClaim>();
        try{
            for(Core_MDF_Audit_Document__c auditDoc : [SELECT Id, CreatedDate, Core_MDF_Claim__c, Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c
                                                       FROM Core_MDF_Audit_Document__c WHERE Core_MDF_Claim__c IN: docHoldClaims ORDER BY CreatedDate Desc]){
                                                                        
                Date auditCreatedDate = date.newinstance(auditDoc.CreatedDate.year(), auditDoc.CreatedDate.month(), auditDoc.CreatedDate.day());
                if((auditDoc.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c == null || auditCreatedDate > auditDoc.Core_MDF_Claim__r.Core_MDF_RMF_Last_POP_Submission_Dt__c) && !pfcWithLastPOPDocDateMap.containsKey(auditDoc.Core_MDF_Claim__c)){
                    PartnerFundClaim pfc = new PartnerFundClaim();
                    pfc.Id = auditDoc.Core_MDF_Claim__c;
                    pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = auditCreatedDate;
                    pfcWithLastPOPDocDateMap.put(pfc.Id,pfc);
                }                                                           
            }             
        }        
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        } 
        return pfcWithLastPOPDocDateMap;
    }
    
    // Method to check if claim is on document hold or not
    public static boolean isClmReleasedFromDocHold(PartnerFundClaim claimObj){
        return (claimObj.Core_MDF_Document_Hold_Eligibility_Ind__c && !claimObj.Core_MDF_Document_Hold_Ind__c) ? true:false;
    }
    
    // Method to check if claim is on both Document Hold and Audit hold and Audit type is 'Document Hold' 
    // Below condition will met only if doc sub due date is passed and from WF, updating audit fields so that no further updates on document cmp are allowed on claim
    public static boolean isClaimToBeDeniedDueToNoDocs(PartnerFundClaim claimObj){
        return (claimObj.Core_MDF_Document_Hold_Ind__c && claimObj.Core_MDF_Audit_Hold__c && claimObj.Core_MDF_Audit_Type__c == 'Document Hold') ? true:false;
    }
  
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
        catch(Exception e){
            createErrorLog = true; 
            Core_MDF_CCP_UtilityClass.logError(e);
        }     
        
    }
   
    @AuraEnabled
    public static metadataWrapper fetchMetaDataRecords(Id recordId,string recData, string budType, string sObjectType) {
        // Creating instance of metadataWrapper
        metadataWrapper popWrapper = new metadataWrapper();
        // When the method is called from Details screen of Claim/ Case, below if condition will execute.
        // If it is called from Claim Creation page then else condition will execute
       /* if(sObjectType == 'Core_MDF_Claim_Batch_Stage__c'){
            popWrapper.metadataWrapperList = [SELECT Core_MDF_RecordType_DeveloperName_txt__c, 
                                          Core_MDF_Budget_Type_txt__c, 
                                          Core_MDF_ReqforPOPSubmission_ind__c, 
                                          Core_MDF_Active_ind__c, Core_MDF_Order_nbr__c, Core_MDF_Document_Type_nm__c, toLabel(Core_MDF_Document_Type_nm__c) Document_Type_Label, Core_MDF_Req_Doc_Types_ind__c 
                                          FROM Core_MDF_POP_Document_Types__mdt WHERE Core_MDF_Program_nm__c =: recData AND 
                                          Core_MDF_Budget_Type_txt__c =:budType AND 
                                          Core_MDF_Active_ind__c= true Order by Core_MDF_Order_nbr__c ];
        }
        else{ */
        if(recordId != null){
            popWrapper.metadataWrapperList = [SELECT Core_MDF_Program_nm__c,Core_MDF_RecordType_DeveloperName_txt__c, 
                                              Core_MDF_Budget_Type_txt__c, 
                                              Core_MDF_Active_ind__c, Core_MDF_ReqforPOPSubmission_ind__c, 
                                              Core_MDF_Order_nbr__c, Core_MDF_Document_Type_nm__c, toLabel(Core_MDF_Document_Type_nm__c) Document_Type_Label, Core_MDF_Req_Doc_Types_ind__c FROM 
                                              Core_MDF_POP_Document_Types__mdt WHERE Core_MDF_Program_nm__c =:recData
                                              AND Core_MDF_Budget_Type_txt__c =:budType 
                                              AND Core_MDF_Active_ind__c= true Order by Core_MDF_Order_nbr__c ];
        }else{
            popWrapper.metadataWrapperList = [SELECT Core_MDF_RecordType_DeveloperName_txt__c, 
                                              Core_MDF_Budget_Type_txt__c, 
                                              Core_MDF_ReqforPOPSubmission_ind__c, 
                                              Core_MDF_Active_ind__c, Core_MDF_Order_nbr__c, Core_MDF_Document_Type_nm__c, toLabel(Core_MDF_Document_Type_nm__c) Document_Type_Label, Core_MDF_Req_Doc_Types_ind__c 
                                              FROM Core_MDF_POP_Document_Types__mdt WHERE Core_MDF_RecordType_DeveloperName_txt__c =: recData AND 
                                              Core_MDF_Budget_Type_txt__c =:budType AND 
                                              Core_MDF_Active_ind__c= true Order by Core_MDF_Order_nbr__c ];
        }
       // }
        return popWrapper;
    }
    // wrapper class with @AuraEnabled
    public class MetadataWrapper{
        @AuraEnabled
        public List<Core_MDF_POP_Document_Types__mdt> metadataWrapperList;
    } 
}