/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Case 
* Version     : 1.0 
* Created Date: 04-02-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        04/02/2019                    Created Core_MDF_ProcessCCP_Case 
* Intel - NP                    01/08/2019                    Added lines of code to prevent Case from being Compliant/Non-Compliant 
*                                                             if Checklist is incomplete    
* Accenture - Harika            30/07/2020                    US742525 Populating Claim Case Reviewer Field Value if any edits happen on case
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_Case {

    //Roshan - TWC3117-18451
    private static final String STATUS_UNDER_REVIEW = Core_MDF_CCP_ConstantClass.CASE_OPEN_STATUS;
    private static final String STATUS_REVIEW_COMPLETED = Core_MDF_CCP_ConstantClass.REVIEW_COMPLETED;
    private static final String NOTE_DIVIDER = '________________________________';

    /*******************************************************************************************************************************************
Method Name:                                             caseReviewerCheck
@return  :                                               Void
@parameters:                                             caseList - List of cases and Case Old Map                                
Description:                                             This method will check assigned user is Case reviewer/Case Reviewer Manager or not 
Added By:                                                Accenture – Shridhar K  -  03/28/2019
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K        03/28/2019                   Created. 
*****************************************************************************************************************************************/    
    public static void caseReviewerCheck(List<Case> caseList, Map<Id,Case> oldMap, Boolean isInsert, Boolean isUpdate){
        if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Case_Trigger') == null || !Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Case_Trigger').Core_Active__c || 
           (Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && !Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
               try{
                   List<Id> ccpCaseRecordTypeIdList = new List<Id>();
                   Map<id,decimal> caseIdToChecklistCompletion = new Map<id,decimal>();
                   
                   for(String recTypeDevName: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Case_RecordType_DevName').Split(';')){
                       ccpCaseRecordTypeIdList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId());
                   }
                   Set<Id> reviewrManagerSet = new Set<Id>();
                   Set<Id> caseReviwerSet = new Set<Id>();
                   Map<id,case> ccpCaseList = new Map<id,case>();
                   List<String> standardProfiles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_StandardProfiles').split(';');
                   List<Id> caseIdSet = new List<Id>();
                   
                   Boolean profileCheck = FALSE;
                   List<Case> caseListForUpdate = new List<Case>();
                   Id reviewerId = UserInfo.getUserId();
                   Id caseReviewerId;
                   //Co-Marketing RecordTypeId Check
                   for(Case cs: caseList){
                       if(ccpCaseRecordTypeIdList.contains(cs.RecordTypeId)){
                        
                            if (isUpdate) { maintainClosureNotes(cs, oldMap); }  //Roshan - TWC3117-12884
                           
                           //Added for Checklist completion check  
                           if(isUpdate && (cs.Core_MDF_Review_Case_Status__c == 'Compliant' || cs.Core_MDF_Review_Case_Status__c =='Non-compliant' || cs.Core_MDF_Review_Case_Status__c=='Review Completed')){
                               ccpCaseList.put(cs.id,cs);}
                       
                           //US527005: Added for Data entry correction reason to be shown as concatenated value- added by Ealisha
                           if((cs.Core_MDF_Data_Entry_Correction__c && (cs.Core_MDF_Data_Correction_Note_Txt__c != null || cs.Core_MDF_Data_Entry_Correction_Cd__c != null ))){                        
                               
                               cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c = 
                                   ((cs.Core_MDF_Data_Entry_Correction_Cd__c != null) ? cs.Core_MDF_Data_Entry_Correction_Cd__c + '^ ' : '' );
                               cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c = 
                                   (cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c != null) ?  
                                   (cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c + cs.Core_MDF_Data_Correction_Note_Txt__c) : '';                            
                               
                           }
                           else{
                               cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c = '';
                               
                           }
                           
                           // Added below lines to check if any of the audit field is updated 
                           if(isUpdate && (cs.Core_MDF_Claim_Case_Reviewer_Lookup__c == NULL) && 
                              ((oldMap.get(cs.Id).Core_MDF_Review_Case_Status__c != cs.Core_MDF_Review_Case_Status__c && 
                                oldMap.get(cs.Id).Core_MDF_Review_Case_Status__c != 'Non-compliant') || oldMap.get(cs.Id).Core_MDF_Claim_Review_Closure_Note__c != cs.Core_MDF_Claim_Review_Closure_Note__c ||
                               oldMap.get(cs.Id).Core_MDF_Internal_Case_Closure_Notes__c != cs.Core_MDF_Internal_Case_Closure_Notes__c || oldMap.get(cs.Id).Core_MDF_Data_Entry_Correction__c != cs.Core_MDF_Data_Entry_Correction__c ||
                               oldMap.get(cs.Id).Core_MDF_Data_Entry_Correction_Cd__c != cs.Core_MDF_Data_Entry_Correction_Cd__c || oldMap.get(cs.Id).Core_MDF_Data_Correction_Note_Txt__c != cs.Core_MDF_Data_Correction_Note_Txt__c ||
                               oldMap.get(cs.Id).Core_MDF_More_Documentation_Required__c != cs.Core_MDF_More_Documentation_Required__c || oldMap.get(cs.Id).Core_MDF_ReasonForMoreDocumentation__c != cs.Core_MDF_ReasonForMoreDocumentation__c)){
                              
                                   caseReviwerSet.add(reviewerId);
                                   caseListForUpdate.add(cs);
                                   profileCheck = TRUE;  
                               }
                           
                           if((isInsert && cs.Core_MDF_Claim_Case_Reviewer_Lookup__c != null) || 
                              (isUpdate && cs.Core_MDF_Claim_Case_Reviewer_Lookup__c != null && oldMap.containsKey(cs.Id) && oldMap.get(cs.Id).Core_MDF_Claim_Case_Reviewer_Lookup__c != cs.Core_MDF_Claim_Case_Reviewer_Lookup__c)){
                                 
                                  caseReviwerSet.add(cs.Core_MDF_Claim_Case_Reviewer_Lookup__c);
                                  caseListForUpdate.add(cs);
                              }
                           
                           //US1107779: [WW42] - [PIC Review Process] - New intermediate Status in Case
                           if(isUpdate && cs.Core_MDF_Status__c=='PIC Review Completed' && oldMap.get(cs.Id).Core_MDF_PIC_Review_Completed_Ind__c && oldMap.get(cs.Id).Core_MDF_Status__c != cs.Core_MDF_Status__c){
                               cs.AddError('This case has already completed PIC Review');
                           }
                       }
                       
                   }
                   
                   if(caseReviwerSet.size() > 0){
                       for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId,PermissionSet.Name FROM PermissionSetAssignment
                                                             WHERE AssigneeId IN :caseReviwerSet
                                                             AND (PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer' OR 
                                                                  PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' OR
                                                                  PermissionSet.Name = 'Core_MDF_CCP_Internal_PIC_Reviewer')]){
                                                                      reviewrManagerSet.add(usrPer.AssigneeId);
                                                                  }
                   }
                   
                   if(profileCheck){
                       Id profileId=userinfo.getProfileId();
                       // checking the logged in user profile name
                       String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
                       if(!standardProfiles.contains(profileName)){
                           caseReviewerId = reviewerId;
                       }
                   }
                   
                   for(Case record : caseListForUpdate){
                       if(record.Core_MDF_Claim_Case_Reviewer_Lookup__c == NULL && caseReviewerId != NULL){
                           record.Core_MDF_Claim_Case_Reviewer_Lookup__c = caseReviewerId;
                       }
                       
                       if(record.Core_MDF_Claim_Case_Reviewer_Lookup__c != NULL && !reviewrManagerSet.contains(record.Core_MDF_Claim_Case_Reviewer_Lookup__c)){
                           record.AddError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Case_Change_Reviewer_Error_Msg'));
                       }
                   }
                   
                   
                   //Added for Checklist completion check 
                   if(ccpCaseList.size()>0){
                       caseIdToChecklistCompletion = validateChecklistCompletion(ccpCaseList.keyset());
                       for(case record:ccpCaseList.values()){record.Core_MDF_Checklist_Completion__c = integer.valueOf(caseIdToChecklistCompletion.get(record.id));}
                   }
               }
               catch(Exception e){
                   String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Case_Review_Doc_Log_Entry_Orign'));                  
               }
           }
    }

    //Roshan - TWC3117-18451 - append date and maintain history for closure note fields
    public static void maintainClosureNotes(Case newCase, Map<Id, Case> oldMap) {

        Case oldCase = oldMap.get(newCase.Id);
        Boolean isClosing = oldCase.Core_MDF_Status__c == STATUS_UNDER_REVIEW && newCase.Core_MDF_Status__c == STATUS_REVIEW_COMPLETED;
        Boolean isReopening = oldCase.Core_MDF_Status__c == STATUS_REVIEW_COMPLETED && newCase.Core_MDF_Status__c == STATUS_UNDER_REVIEW;

        if (newCase.Core_MDF_Status__c != STATUS_UNDER_REVIEW && !isClosing) { return; }

        // Claim Review Closure Note logic
        if (isClosing) {
            // case is closed: append the date and maintain the history fields
            String note = String.isNotBlank(newCase.Core_MDF_AddClaimReviewClosure_Note_txt__c) ? newCase.Core_MDF_AddClaimReviewClosure_Note_txt__c : oldCase.Core_MDF_Claim_Review_Closure_Note__c;
            if (String.isNotBlank(note)) {
                String datedEntry = stampNoteWithCurrentDate(note);
                newCase.Core_MDF_Claim_Review_Closure_Note__c = datedEntry;
                newCase.Core_MDF_ClaimReviewClosureHistory_txt__c = prependNoteEntry(oldCase.Core_MDF_ClaimReviewClosureHistory_txt__c, datedEntry);
            }
            newCase.Core_MDF_AddClaimReviewClosure_Note_txt__c = null;
        } else if (isReopening || newCase.Core_MDF_AddClaimReviewClosure_Note_txt__c != oldCase.Core_MDF_AddClaimReviewClosure_Note_txt__c) {
            // TWC3117-18342 - Preserve closure notes created before Core_MDF_ClaimReviewClosureHistory_txt__c was created
            if (isReopening && String.isBlank(oldCase.Core_MDF_ClaimReviewClosureHistory_txt__c) && String.isNotBlank(oldCase.Core_MDF_Claim_Review_Closure_Note__c)) {
                newCase.Core_MDF_ClaimReviewClosureHistory_txt__c = oldCase.Core_MDF_Claim_Review_Closure_Note__c.trim();
            }
            newCase.Core_MDF_Claim_Review_Closure_Note__c = String.isBlank(newCase.Core_MDF_AddClaimReviewClosure_Note_txt__c) ? null : newCase.Core_MDF_AddClaimReviewClosure_Note_txt__c.trim();
        }

        // Internal Case Closure Note logic
        //Roshan - TWC3117-19150
        // String internalHistory = removeCurrentDraftNote(oldCase.Core_MDF_Internal_Case_Closure_Notes__c, oldCase.Core_MDF_AddInternalCaseClosureNotes_txt__c);
        if (isClosing) {
            // case is closed: append the date
            //Roshan - TWC3117-19150
            // newCase.Core_MDF_Internal_Case_Closure_Notes__c = String.isBlank(newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c) ? internalHistory : prependNoteEntry(internalHistory, stampNoteWithCurrentDate(newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c));
            if (String.isNotBlank(newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c)) {
                newCase.Core_MDF_Internal_Case_Closure_Notes__c = stampNoteWithCurrentDate(newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c);
            }
            newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c = null;
        } else if (newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c != oldCase.Core_MDF_AddInternalCaseClosureNotes_txt__c) {
            // update new note if provided
            //Roshan - TWC3117-19150
            // newCase.Core_MDF_Internal_Case_Closure_Notes__c = prependNoteEntry(internalHistory, String.isBlank(newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c) ? null : newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c.trim());
            newCase.Core_MDF_Internal_Case_Closure_Notes__c = String.isBlank(newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c) ? null : newCase.Core_MDF_AddInternalCaseClosureNotes_txt__c.trim();
        }
    }

    // appends the current date in UTC to a note: "28/08/2026: <note>".
    private static String stampNoteWithCurrentDate(String note) { return Datetime.now().formatGMT('dd/MM/yyyy') + ':\n' + note.trim(); }

    // add current note to the top of history fields, separated from older entries by a divider line
    private static String prependNoteEntry(String existingHistory, String entry) {
        if (String.isBlank(entry)) { return existingHistory; }
        if (String.isBlank(existingHistory)) { return entry.trim(); }
        return entry.trim() + '\n' + NOTE_DIVIDER + '\n' + existingHistory.trim();
    }

    //Roshan - TWC3117-19150
    // returns the historic note without the current draft and divider
    // private static String removeCurrentDraftNote(String accumulatedNote, String draftNote) {
    //     if (String.isBlank(accumulatedNote) || String.isBlank(draftNote)) { return accumulatedNote; }
    //     if (accumulatedNote.trim() == draftNote.trim()) { return null; }

    //     String currentNoteWithDivider = draftNote.trim() + '\n' + NOTE_DIVIDER + '\n';
    //     return accumulatedNote.trim().startsWith(currentNoteWithDivider) ? accumulatedNote.trim().substring(currentNoteWithDivider.length()) : accumulatedNote;
    // }
    
    //Method calculates the Checklist completion percentage of a given case
    public static Map<id,decimal> validateChecklistCompletion(set<id> caseList){
        
        List<Core_MDF_Claim_Case_Checklist__c> checklistList = new List<Core_MDF_Claim_Case_Checklist__c>();
        Map<id,decimal> caseIDToChecklistCompletionPercentage = new Map<id,decimal>();
        
        try{
            checklistList = [select Core_MDF_Completion_Percentage__c,Core_MDF_Case_ID__c from Core_MDF_Claim_Case_Checklist__c where Core_MDF_Case_ID__c =: caseList];
            for(Core_MDF_Claim_Case_Checklist__c record : checklistList){caseIDToChecklistCompletionPercentage.put(record.Core_MDF_Case_ID__c,record.Core_MDF_Completion_Percentage__c);} 
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return caseIDToChecklistCompletionPercentage;
    }
    
    /*****************************************************************************************************                              
    Method Name   :        createRecoveryDashboardRecords                                
    @return       :        void                          
    @parameters   :        List<Id> caseIdList
    Description   :        When the case Closed, create Recovery Summary record with child Scorecard of Case
    Added By      :        JB - Accenture - 08/10/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         08/10/2023      When the case Closed, create Recovery Summary record with child Scorecard of Case
    ******************************************************************************************************/
    @InvocableMethod
    public static void createRecoveryDashboardRecords(List<Case> caseList){
        //Set<Id> nodeAccIds = new Set<Id>();
        //List<Case> rmfCaseList = new List<Case>();
        //On Review completion of RMF Cases, notifying RMF account managers
        if(!caseList.isEmpty()){
            //notifyRMFAcctManagersOnReviewCompletion(caseList);
            //notifyRecoveryAdminsOnReviewCompletion(caseList);
        }
        if(Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Recovery_Dashboard') == null || !Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_Recovery_Dashboard').Core_Active__c || 
           (Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c !=null && !Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))){
            
            try{
                List<Id> caseIdList = new List<Id>();
                for(Case c : caseList){
                    caseIdList.add(c.Id);
                        /*if(c.Core_MDF_Channel_Program_txt__c == Label.Core_MDF_Retail_Program_Name){
                            nodeAccIds.add(c.AccountId);
                            rmfCaseList.add(c);
                       }*/
                }

                Map<Id, String> caseIdToQuarter = new Map<Id, String>();
                Map<Id, String> scoreCardIdToPartnershipScoreKeyMap = new Map<Id, String>();
                Map<Id, String> scoreCardIdToPartnershipScoreDetailKeyMap = new Map<Id, String>();
                Map<Id, Core_MDF_Scorecard__c> scoreCardIdToRecordMap = new Map<Id, Core_MDF_Scorecard__c>();
                Map<String, Core_MDF_Scorecard__c> psKeyToScoreCardMap = new Map<String, Core_MDF_Scorecard__c>();
                Map<String, Core_MDF_Scorecard__c> psdKeyToScoreCardMap = new Map<String, Core_MDF_Scorecard__c>();
                Set<String> nodeAccountProgramSet = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
                Set<String> previousQuarterPSDSet = new Set<String>();
                Map<String, String> currentToPreviousQtrPsdKey = new Map<String, String>();
                Map<String, String> psdKeyToPsKeyMap = new Map<String, String>();
                
                
                //Get scorcard records based on Case id
                for(Core_MDF_Scorecard__c scorecard : [SELECT Id, Core_MDF_Case_Id__c, Core_MDF_Quarter__c, Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c, Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Case_Id__r.Account.Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c,
                                                        Core_MDF_Claim_Amt__c, Core_MDF_Manual_Recovery_Amount_USD_Amt__c, Core_MDF_Score_Nbr__c, Core_MDF_Case_Id__r.Core_Account_Geo__c, Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c, Core_MDF_Case_Id__r.AccountId, Core_MDF_Virtual_Corp_Account_Id__c,
                                                        Core_MDF_Max_Possible_Amt__c, Core_MDF_Weighted_PV_Amt__c
                                                        FROM Core_MDF_Scorecard__c 
                                                        WHERE Core_MDF_Case_Id__c IN: caseIdList]){   
                                                     
                    String psKey = '' + scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c + scorecard.Core_MDF_Virtual_Corp_Account_Id__c + scorecard.Core_MDF_Quarter__c;
                    String psdKey = '' + scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c + scorecard.Core_MDF_Virtual_Corp_Account_Id__c + scorecard.Core_MDF_Quarter__c + (nodeAccountProgramSet.contains(scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c) ? String.valueOf(scorecard.Core_MDF_Case_Id__r.AccountId) : '') + scorecard.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c + scorecard.Core_MDF_Case_Id__r.Core_Account_Geo__c;
                    scoreCardIdToPartnershipScoreKeyMap.put(scorecard.Id, psKey);

                    String previousQuarter = getPreviousQuarter(scorecard.Core_MDF_Quarter__c);
                    String previousQuarterPsdKey = psdKey.replace(scorecard.Core_MDF_Quarter__c, previousQuarter);
                    previousQuarterPSDSet.add(previousQuarterPsdKey);
                    currentToPreviousQtrPsdKey.put(psdKey, previousQuarterPsdKey);
                    psdKeyToPsKeyMap.put(psdKey, psKey);
                                                            
                    //Swati-Added to Skip PSD/RD creation for RMF when budget is RSA MD starting Q2 2026
                    Boolean isRetailMarketingFunds = scoreCard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
                    Boolean isBudgetRsaMd      = scoreCard.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.RMF_RSA_MD_BUDGET_TYPE;
                    Boolean isAfter_Q2_2026 = Date.today() >= Date.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exclude_RSA_MD'));
                    Boolean skipRSA_MD = isRetailMarketingFunds && isBudgetRsaMd && isAfter_Q2_2026;
                    if (!skipRSA_MD) {
                        // Skip creating PSD/RD for RMF when budget is RSA MD starting Q2 2026 
                        scoreCardIdToPartnershipScoreDetailKeyMap.put(scorecard.Id, psdKey);
                        scoreCardIdToRecordMap.put(scorecard.Id, scorecard);
                    }//END -Swati
                    
                    psKeyToScoreCardMap.put(psKey, scorecard);
                    psdKeyToScoreCardMap.put(psdKey, scorecard);
                }

                Set<String> partnershipScoreKeySet = new Set<String>(scoreCardIdToPartnershipScoreKeyMap.values());
                                List<String> existingKeyList = new List<String>();
                List<Core_MDF_Partnership_Score__c> psList = [SELECT Id, Core_MDF_Channel_Program_Id__c, Core_MDF_Account_Id__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_External_Id__c, Core_MDF_Virtual_Corp_Account_Id__c FROM Core_MDF_Partnership_Score__c WHERE Core_MDF_External_Id__c IN: partnershipScoreKeySet];
    
                Map<String, Id> keyToParternshipScoreIdMap = new Map<String,Id>();
                Map<Id, String> psIdTopsKeyMap = new Map<Id, String>();
                for(Core_MDF_Partnership_Score__c ps : psList){
                    existingKeyList.add(ps.Core_MDF_External_Id__c);
                    keyToParternshipScoreIdMap.put(ps.Core_MDF_External_Id__c, ps.Id);
                    psIdTopsKeyMap.put(ps.Id, ps.Core_MDF_External_Id__c);
                }
                
                //Remove existing Parternship Score keys
                partnershipScoreKeySet.removeAll(existingKeyList);
                
                //Add Partnership Score for new keys
                List<Core_MDF_Partnership_Score__c> psListToInsert = new List<Core_MDF_Partnership_Score__c>();
                for(String key : partnershipScoreKeySet){
                    psListToInsert.add(new Core_MDF_Partnership_Score__c(Core_MDF_External_Id__c = key, Core_MDF_Channel_Program_Id__c = psKeyToScoreCardMap.get(key).Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c, Core_MDF_Account_Id__c = psKeyToScoreCardMap.get(key).Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Virtual_Corp_Account_Id__c = psKeyToScoreCardMap.get(key).Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Quarter_Year_Nm__c = psKeyToScoreCardMap.get(key).Core_MDF_Quarter__c));
                }
                
                //Insert Parternship Score record
                if(!psListToInsert.isEmpty()){
                    Schema.SObjectField externalID = Core_MDF_Partnership_Score__c.Core_MDF_External_Id__c;
                    Database.UpsertResult [] saveResult = Database.upsert(psListToInsert, externalID, false);
                
                    for(Core_MDF_Partnership_Score__c ps : psListToInsert){
                        if(String.isNotBlank(ps.Id)){
                            keyToParternshipScoreIdMap.put(ps.Core_MDF_External_Id__c, ps.Id);
                            psIdTopsKeyMap.put(ps.Id, ps.Core_MDF_External_Id__c);
                        }
                    }
                }

                Set<String> finalPSDKeySet = new Set<String>();
                Set<String> psdKeySet = new Set<String>(scoreCardIdToPartnershipScoreDetailKeyMap.values());
                finalPSDKeySet.addAll(psdKeySet);
                finalPSDKeySet.addAll(previousQuarterPSDSet);//Previous Quarter PSD Key

                Set<String> existingPsdKeySet = new Set<String>();
                Map<String, Id> psdKeyToPsdId = new Map<String, Id>();
                Map<String, Core_MDF_Partnership_Score_Detail__c> psdKeyToPsdRecordMap = new Map<String, Core_MDF_Partnership_Score_Detail__c>();
                for(Core_MDF_Partnership_Score_Detail__c psd : [SELECT Id, Core_MDF_Partnership_Score_Id__c, Core_MDF_Balance_Amount_Amt__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c,Core_MDF_External_ID__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_External_ID__c IN: finalPSDKeySet]){
                    if(psdKeyToScoreCardMap.keySet().contains(psd.Core_MDF_External_ID__c)){
                        existingPsdKeySet.add(psd.Core_MDF_External_ID__c);
                    }
                    psdKeyToPsdId.put(psd.Core_MDF_External_ID__c, psd.Id);
                    psdKeyToPsdRecordMap.put(psd.Core_MDF_External_ID__c, psd);
                                    }

                //Remove existing Parternship Score Detail keys
                psdKeySet.removeAll(existingPsdKeySet);

                //Add Partnership Score Detail for new keys
                List<Core_MDF_Partnership_Score_Detail__c> psdListToInsert = new List<Core_MDF_Partnership_Score_Detail__c>();
                for(String psdKey : psdKeySet){
                    Id psId = keyToParternshipScoreIdMap.get(psdKeyToPsKeyMap.get(psdKey));
                    Id parentPsdId = psdKeyToPsdId.containsKey(currentToPreviousQtrPsdKey.get(psdKey)) ? psdKeyToPsdId.get(currentToPreviousQtrPsdKey.get(psdKey)) : null;
                    Core_MDF_Partnership_Score_Detail__c previousQuarterPsd = psdKeyToPsdRecordMap.containsKey(currentToPreviousQtrPsdKey.get(psdKey)) ? psdKeyToPsdRecordMap.get(currentToPreviousQtrPsdKey.get(psdKey)) : new Core_MDF_Partnership_Score_Detail__c();
                    Core_MDF_Scorecard__c scoreCard = psdKeyToScoreCardMap.get(psdKey);
                                                           
                    Core_MDF_Partnership_Score_Detail__c newPsd = new Core_MDF_Partnership_Score_Detail__c();
                    newPsd.Core_MDF_External_ID__c = '' + psIdTopsKeyMap.get(psId) + (nodeAccountProgramSet.contains(scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c) ? String.valueOf(scorecard.Core_MDF_Case_Id__r.AccountId) : '') + scorecard.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c + scorecard.Core_MDF_Case_Id__r.Core_Account_Geo__c;
                    newPsd.Core_MDF_Partnership_Score_Id__c = psId;
                    if(previousQuarterPsd != null){ // Populate previous Quarter values
                        //newPsd.Core_MDF_Carry_Over_Amt__c = previousQuarterPsd.Core_MDF_Balance_Amount_Amt__c;
                        newPsd.Core_MDF_Partnership_Score_Detail_Id__c = previousQuarterPsd.Id;
                    }
                    
                    newPsd.Core_MDF_Node_Account_Id__c = (nodeAccountProgramSet.contains(scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c) ? scorecard.Core_MDF_Case_Id__r.AccountId : null);
                    newPsd.Core_MDF_Budget_Type_nm__c = scoreCard.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c;
                    newPsd.Core_MDF_Region_Cd__c = scoreCard.Core_MDF_Case_Id__r.Core_Account_Geo__c;
                    psdListToInsert.add(newPsd);
                }

                //Upsert Parternship Score Detail record
                Schema.SObjectField externalID = Core_MDF_Partnership_Score_Detail__c.Core_MDF_External_Id__c;
                if(!psdListToInsert.isEmpty()){
                    Database.UpsertResult [] saveResult = Database.upsert(psdListToInsert, externalID, false);
                
                    for(Core_MDF_Partnership_Score_Detail__c psd : psdListToInsert){
                        if(String.isNotBlank(psd.Id)){
                            psdKeyToPsdId.put(psd.Core_MDF_External_ID__c, psd.Id);
                        }
                    }
                }

                //Check for the existing Recovery Dashboard record with Same or Differnet Quarter
                Map<Id, Core_MDF_Recovery_Dashboard__c> scorecardIdTorecoveryDashboardMap = new Map<Id, Core_MDF_Recovery_Dashboard__c>();
                for(Core_MDF_Recovery_Dashboard__c recoveryDashboard : [SELECT Id, Core_MDF_Partnership_Score_Id__c, Core_MDF_Scorecard_Id__c, Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c, Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Scorecard_Id__r.Core_MDF_Quarter__c, Core_MDF_Active_Ind__c 
                                                                        FROM Core_MDF_Recovery_Dashboard__c 
                                                                        WHERE Core_MDF_Scorecard_Id__c != null AND Core_MDF_Scorecard_Id__c IN: scoreCardIdToRecordMap.values() ORDER BY CreatedDate]){
                    scorecardIdTorecoveryDashboardMap.put(recoveryDashboard.Core_MDF_Scorecard_Id__c, recoveryDashboard);
                }

                //Create (or) Update Recovery Dashboard Records
                List<Core_MDF_Recovery_Dashboard__c> recoveryDashboardListToUpsert = new List<Core_MDF_Recovery_Dashboard__c>();
                for(Core_MDF_Scorecard__c scorecard : scoreCardIdToRecordMap.values()){
                    String psKey = '' + scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c + scorecard.Core_MDF_Virtual_Corp_Account_Id__c + scorecard.Core_MDF_Quarter__c;
                    String psdInitialKey = '' + scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c + scorecard.Core_MDF_Virtual_Corp_Account_Id__c + scorecard.Core_MDF_Quarter__c;
                    String psdKey = '' + psdInitialKey + (nodeAccountProgramSet.contains(scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c) ? String.valueOf(scorecard.Core_MDF_Case_Id__r.AccountId) : '') + scorecard.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c + scorecard.Core_MDF_Case_Id__r.Core_Account_Geo__c;
                    
                    Core_MDF_Recovery_Dashboard__c recoveryDashboard = new Core_MDF_Recovery_Dashboard__c(Core_MDF_Is_Active_Ind__c = true, Core_MDF_Partnership_Score_Id__c = keyToParternshipScoreIdMap.get(psKey), Core_MDF_Partnership_Score_Detail_Id__c = psdKeyToPsdId.get(psdKey), Core_MDF_Scorecard_Id__c = scorecard.Id, Core_MDF_Score_Nbr__c = scorecard.Core_MDF_Score_Nbr__c, Core_MDF_Claim_Amt__c = scorecard.Core_MDF_Claim_Amt__c, Core_MDF_Manual_Recovery_Amount_USD_Amt__c = scorecard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c, Core_MDF_Max_Possible_Amt__c = scorecard.Core_MDF_Max_Possible_Amt__c, Core_MDF_Weighted_PV_Amt__c = scorecard.Core_MDF_Weighted_PV_Amt__c);
                    
                    //If the record exist already add Id field to Update existing Recovery Dashboard
                    if(scorecardIdTorecoveryDashboardMap.containsKey(scorecard.Id)){
                        recoveryDashboard.Id = scorecardIdTorecoveryDashboardMap.get(scorecard.Id).Id;
                    }

                    recoveryDashboardListToUpsert.add(recoveryDashboard);
                }

                if(!recoveryDashboardListToUpsert.isEmpty()){
                    Database.upsert(recoveryDashboardListToUpsert, false);
                }
                //On Review completion of RMF Cases, notifying RMF account managers
                /*if(!rmfCaseList.isEmpty() && !nodeAccIds.isEmpty()){
                    notifyRMFAcctManagersOnReviewCompletion(rmfCaseList,nodeAccIds);
                }*/
    
                /*//Check for the existing Recovery Dashboard record
                Map<String, Core_MDF_Recovery_Dashboard__c> keyTorecoveryDashboardMap = new Map<String, Core_MDF_Recovery_Dashboard__c>();
                for(Core_MDF_Recovery_Dashboard__c recoveryDashboard : [SELECT Id, Core_MDF_Partnership_Score_Id__c, Core_MDF_Scorecard_Id__c, Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c, Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Scorecard_Id__r.Core_MDF_Quarter__c, Core_MDF_Active_Ind__c 
                                                                            FROM Core_MDF_Recovery_Dashboard__c 
                                                                            WHERE Core_MDF_Scorecard_Id__c IN: scoreCardIdToRecordMap.values()]){
                    String key = '' + recoveryDashboard.Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c + recoveryDashboard.Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + recoveryDashboard.Core_MDF_Scorecard_Id__r.Core_MDF_Quarter__c + recoveryDashboard.Core_MDF_Scorecard_Id__c;
                    keyTorecoveryDashboardMap.put(key, recoveryDashboard);
                }
                
                

                //Iternate over the Scorecard to prepare Recovery Dashboard record to Upsert
                List<Core_MDF_Recovery_Dashboard__c> recoveryDashboardListToUpsert = new List<Core_MDF_Recovery_Dashboard__c>();
                for(Core_MDF_Scorecard__c scorecard : scoreCardIdToRecordMap.values()){
                    String key = '' + scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c + scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + scorecard.Core_MDF_Quarter__c;
                    String keyWithscoreCardId = key + scorecard.Id;
                    if(keyToParternshipScoreIdMap.containsKey(key) && String.isNotBlank(keyToParternshipScoreIdMap.get(key))){
                        if(!keyTorecoveryDashboardMap.containsKey(keyWithscoreCardId)){
                            recoveryDashboardListToUpsert.add(new Core_MDF_Recovery_Dashboard__c(Core_MDF_Partnership_Score_Id__c = keyToParternshipScoreIdMap.get(key), Core_MDF_Scorecard_Id__c = scorecard.Id));
                        }
                    }
                }
                
                
                //Upsert Recovery Dashboard record
                if(!recoveryDashboardListToUpsert.isEmpty()){
                    Database.upsert(recoveryDashboardListToUpsert, false);
                }*/
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        }
    }

    /*****************************************************************************************************                              
    Method Name   :        getPreviousQuarter                                
    @return       :        String                          
    @parameters   :        String
    Description   :        Get previous quarter based on the input quarter
    Added By      :        JB - Accenture - 11/10/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         11/10/2023      Get previous quarter based on the input quarter
    ******************************************************************************************************/
    public static String getPreviousQuarter(String quarter){
        List<String> qysplit = quarter.split(' ');
        List<String> qsplit = qysplit[0].split('');
        Integer quarterInteger = integer.valueof(qsplit[1]);
        Integer yearInteger = integer.valueof(qysplit[1]);
        yearInteger =  quarterInteger == 1  ? yearInteger - 1 : yearInteger;
        quarterInteger = quarterInteger == 1 ? 4 : quarterInteger - 1;
        return 'Q' + quarterInteger + ' ' + yearInteger;
    }
/*****************************************************************************************************                              
Method Name   :        notifyRMFAcctManagersOnReviewCompletion                               
@return       :        void                         
@parameters   :        List<Case>
Description   :        to notify RMF Account managers on Review Completion
Added By      :        AN - Accenture - 06/05/2024
Modified By   :        Date:           Changes:                                 
******************************************************************************************************/
    /*public static void notifyRMFAcctManagersOnReviewCompletion(List<Case> caseList){
        Set<Id> nodeAccIds = new Set<Id>();
        List<Case> rmfCaseList = new List<Case>();
        List<Core_MDF_GenericClassToSendMail.MailParams> emailInputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();  
        //node account to user Id Map 
        Map<Id,List<Id>> nodeAccIdUserIdMap = new Map<Id,List<Id>>();
        try{
            for(Case c : caseList){
                if(c.Core_MDF_Channel_Program_txt__c == Label.Core_MDF_Retail_Program_Name){
                    nodeAccIds.add(c.AccountId);
                    rmfCaseList.add(c);
                }
            }
            //To get RMF account managers having IUPGM with the node accounts 
            nodeAccIdUserIdMap = Core_MDF_PIC_SendEmailToClaimOwner.getRMFAccManagers(nodeAccIds);
            
            if(!rmfCaseList.isEmpty()){
                for(Case rmfcs:rmfCaseList){       
                    if(nodeAccIdUserIdMap != null && nodeAccIdUserIdMap.containsKey(rmfcs.AccountId)){
                        Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                        sendEmailToExt.recordId = rmfcs.Id;
                        sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotifyRMFActMgrOnReviewComp');
                        sendEmailToExt.userIdList = nodeAccIdUserIdMap.get(rmfcs.AccountId);
                        sendEmailToExt.sendDiff = false;
                        emailInputList.add(sendEmailToExt);
                    }
                }
            }
            
            
            if(emailInputList!=null && emailInputList.size()>0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(emailInputList);
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(Core_MDF_CCP_UtilityClass.getErrorDetails(e),'Exception occured in notifyRMFAcctManagersOnReviewCompletion method');
        }      
        
    }*/
    /*****************************************************************************************************                              
    Method Name   :        notifyRecoveryAdminsOnReviewCompletion                               
    @return       :        void                         
    @parameters   :        List<Case>
    Description   :        to notify Recovery Administators on Review Completion
    Added By      :        AN - Accenture - 06/05/2024
    Modified By   :        Date:           Changes:                                 
    ******************************************************************************************************/
    public static void notifyRecoveryAdminsOnReviewCompletion(List<Case> caseList){
        try{
            List<Id> nodeAccSet = new List<Id>();
            List<Core_MDF_GenericClassToSendMail.MailParams> emailInputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();  
            for(Case cs:caseList){
                nodeAccSet.add(cs.AccountId);
            }
            
            Map<Id,List<Id>> accToRecoveryAdmUsrIdMap = new Map<Id,List<Id>>();
            accToRecoveryAdmUsrIdMap = getnodeAccToRecoveryAdmUserId(nodeAccSet);
            
            if(!caseList.isEmpty()){
                for(Case cs:caseList){       
                    if(accToRecoveryAdmUsrIdMap != null && accToRecoveryAdmUsrIdMap.containsKey(cs.AccountId)){
                        Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                        sendEmailToExt.recordId = cs.Id;
                        sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotifyRMFActMgrOnReviewComp');
                        sendEmailToExt.userIdList = accToRecoveryAdmUsrIdMap.get(cs.AccountId);
                        sendEmailToExt.sendDiff = false;
                        emailInputList.add(sendEmailToExt);
                    }
                }
            }
            
            if(emailInputList!=null && emailInputList.size()>0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(emailInputList);
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(Core_MDF_CCP_UtilityClass.getErrorDetails(e),'Exception occured in notifyRecoveryAdminsOnReviewCompletion method');
        }

    }
    /*****************************************************************************************************                              
    Method Name   :        getnodeAccToRecoveryAdmUserId                               
    @return       :        void                         
    @parameters   :        Set<Id>
    Description   :        to get recovery admins of the node account
    Added By      :        AN - Accenture - 06/05/2024
    Modified By   :        Date:           Changes:                                 
    ******************************************************************************************************/
    public static Map<Id,List<Id>> getnodeAccToRecoveryAdmUserId(List<Id> accIdSet){
        Map<Id,Set<Id>> accIdUserIdSetMap = new Map<Id,Set<Id>>();
        Map<Id,String> accIdProgramNameMap = new Map<Id,String>();
        Set<Id> userIdSet = new Set<Id>();
        Map<Id,List<Id>> accIdRecoveryAdmUserIdSetMap = new Map<Id,List<Id>>();
        List<Id> userWithRequiredPermissionSet = new List<Id>();
        List<String> permissionSetNameList = new List<String>{'Core_MDF_CCP_CCF_External_Recovery_Administrator','Core_MDF_CCP_DCF_External_Recovery_Administrator','Core_MDF_CCP_IPA_External_Recovery_Administrator','Core_MDF_CCP_RMF_External_Recovery_Administrator'};
        if(accIdSet != NULL && accIdSet.Size() > 0){
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                                                              FROM Core_MDF_Partner_Node_User_Mapping__c
                                                              WHERE Core_MDF_Account__c IN: accIdSet AND
                                                              Core_MDF_User__r.IsActive = TRUE AND
                                                              Core_MDF_Active_Ind__c = TRUE]){
                userIdSet.add(pnum.Core_MDF_User__c);
                accIdProgramNameMap.put(pnum.Core_MDF_Account__c,pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){
                    accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                }else{
                    accIdUserIdSetMap.put(pnum.Core_MDF_Account__c,new Set<Id>{pnum.Core_MDF_User__c});
                }
            }
        }
        
            
        //if(permissionSetNameList != NULL && permissionSetNameList.Size() > 0){
        for(Id accId:accIdSet){
           
            for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                               FROM PermissionSetAssignment
                                               WHERE AssigneeId IN: accIdUserIdSetMap.get(accId) AND
                                               PermissionSet.Name IN: permissionSetNameList]){
                                                 
                
                if(String.valueOf(accIdProgramNameMap.get(accId)) == 'Client CoMarketing Fund' && String.valueOf(psa.PermissionSet.Name) == 'Core_MDF_CCP_CCF_External_Recovery_Administrator' || 
                   String.valueOf(accIdProgramNameMap.get(accId)) == 'Data Center CoMarketing Fund' && String.valueOf(psa.PermissionSet.Name) == 'Core_MDF_CCP_DCF_External_Recovery_Administrator' || 
                   String.valueOf(accIdProgramNameMap.get(accId)) == 'Intel Partner Alliance' &&  String.valueOf(psa.PermissionSet.Name) == 'Core_MDF_CCP_IPA_External_Recovery_Administrator' || 
                   String.valueOf(accIdProgramNameMap.get(accId)) == 'Retail Marketing Funds' &&  String.valueOf(psa.PermissionSet.Name) == 'Core_MDF_CCP_RMF_External_Recovery_Administrator')
                userWithRequiredPermissionSet.add(psa.AssigneeId); 
                if(accIdRecoveryAdmUserIdSetMap.containsKey(accId)){
                    accIdRecoveryAdmUserIdSetMap.get(accId).add(psa.AssigneeId);
                }else{
                    accIdRecoveryAdmUserIdSetMap.put(accId,new List<Id>{psa.AssigneeId});
                }                                 
            }
        }
       
        //return userWithRequiredPermissionSet;
        
        return accIdRecoveryAdmUserIdSetMap;
    }
   
}