/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewChecklist 
* Created Date: 19-6-2019
* Modification Log :
* Developer             Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP            19-6-2019                     Created Core_MDF_ClaimReviewChecklist to handle the functionalities of Claim Case Review Checklist 
* NP(11630236)          16-9-2019                     DE53533:Line#19 added Order by Core_MDF_Checklist_Line_Number__c since the checklist items were not ordered
* NP(11630236)          20-9-2019                     Checklist Enhancement v1 stories : US458785, US458779, US458790, US458776
* NP(11630236)          30-9-2019                     DE55189 - User able to see warning message when all Checklists are NA - Line #201
* NP(11630236)          06-11-2019                    Checklist Enhancements v2 - US488875: [Checklist] HIGH: Assign additional Case Checklist permissions to Finance users - Added checkEditability()
* NP(11630236)          14-11-2019                    DE60015: Automatic Case status change to Compliant getting stuck because of Validation rule
* NP(11630236)          26-11-2019                    DE60363: Compare Impact Amount Summation with Reimbursable Amount (Local)
* NP(11630236)          07-01-2020                    US517787 - Set Case to Non-Compliant only when Claim amount and Adjustment amount is Equal
* NP(11630236)          16-01-2020                    US554852: PRB000093684 : Case # 00484218, fully denied claim with reimbursement amount $0.01
* NP(11630236)          29-01-2020                    Fire Compliant and Non-Compliant error messages on Checklist completion 100%
* HP(11829401)          29-07-2020                    US742525 : Adding Claim Case Reviewer Field to checklist lastModifiedById
* GS(11909027)          02-12-2020                    US848325: [Tech] Show the “Case Review Findings” when they create a “Claim Case Review Result” escalation
**************************************************************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimReviewChecklist {

    public static integer noncompliantError = 0;
    public static integer compliantError = 0;
    public static final String NON_COMPLIANT_STATUS = 'Non-Compliant';
    
    //Method returns all the Checlist Items specific to the Case ID
    @AuraEnabled
    public static Map<string,List<Core_MDF_Claim_Case_Checklist__c>> queryAllChecklistItems(id caseRecord){
        List<Core_MDF_Claim_Case_Checklist__c> checklistItemsList = new  List<Core_MDF_Claim_Case_Checklist__c>();
        set<string> categories = new set<string>();
        Map<string,List<Core_MDF_Claim_Case_Checklist__c>> resultMap = new Map<string,List<Core_MDF_Claim_Case_Checklist__c>>();

        try{
            for(Core_MDF_Claim_Case_Checklist__c checklistItem :[select Id, Core_MDF_Checklist_Line_Number__c, Core_MDF_Checklist_Item__c, Core_MDF_Checklist_Description__c, Core_MDF_Checklist_Category__c, Core_MDF_Case_ID__c,Core_MDF_Checklist_Status__c,Core_MDF_Claim_Case_Review_Findings__c,Core_MDF_Comment__c,Core_MDF_Impact_Amount__c, Core_MDF_Completion_Percentage__c,Core_MDF_AI_Checklist_Status_Nm__c,Core_MDF_AI_Generated_Comments_Txt__c
                                                            FROM Core_MDF_Claim_Case_Checklist__c
                                                                 where Core_MDF_Case_ID__c =: caseRecord ORDER BY Core_MDF_Checklist_Line_Number__c, Core_MDF_Checklist_Category__c ]){
                                                                     if(resultMap.containsKey(checklistItem.Core_MDF_Checklist_Category__c)){
                                                                         resultMap.get(checklistItem.Core_MDF_Checklist_Category__c).add(checklistItem);
                                                                     }
                                                                     else{
                                                                         checklistItemsList.add(checklistItem);
                                                                         resultMap.put(checklistItem.Core_MDF_Checklist_Category__c,checklistItemsList);
                                                                     }
                                                                 }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}       
        return resultMap;   
    }

    //Method records the Checklist inputs from the Claim Case Review/Manager and saves it to the Core_MDF_Claim_Case_Checklist__c object
    @AuraEnabled
    public static integer updateChecklistRecords(Map<string,string> checklistSelection, Map<string,string> impactAmount, Map<string,string> comments, id caseRecord){
        List<Core_MDF_Claim_Case_Checklist__c> toBeUpdated = new List<Core_MDF_Claim_Case_Checklist__c>();
        Set<string> checklistIdsToBeUpdated = new Set<string>();
        integer checklistCompletion;
        set<string> toBeUpdatedIds = new set<string>();
        string errorForImpactAmount; //Part of Checklist Enhancement v1
        boolean nonCompliantIndicator =false; //Part of Checklist Enhancement v1
        boolean compliantIndicator =false; //DE60015 - fix
        string errorFromCase;
        string errorMessageToBeDisplayed;
        
        
        toBeUpdatedIds.addAll(checklistSelection.keyset());
        toBeUpdatedIds.addAll(impactAmount.keyset());
        toBeUpdatedIds.addAll(comments.keyset());
      
        try{
            for(string key : toBeUpdatedIds){
            Core_MDF_Claim_Case_Checklist__c record = new Core_MDF_Claim_Case_Checklist__c(id=key); 
            if(checklistSelection.get(key) == 'compliant'){
                record.Core_MDF_Checklist_Status__c = 'Compliant';
                compliantIndicator=true;//DE60015 - fix
            }
            else if(checklistSelection.get(key) == 'noncompliant'){
                record.Core_MDF_Checklist_Status__c = 'Non-Compliant';
                nonCompliantIndicator =true;//DE60015 - fix
            }
            else if(checklistSelection.get(key) == 'na'){
                record.Core_MDF_Checklist_Status__c = 'NA';
            }
            if(impactAmount.get(key)!=null){
                record.Core_MDF_Impact_Amount__c = (impactAmount.get(key)==''?null : decimal.valueOf(impactAmount.get(key)));
                
            }
            if(comments.get(key)!=null){
                record.Core_MDF_Comment__c = comments.get(key);
            }

            toBeUpdated.add(record);
            checklistIdsToBeUpdated.add(key);
            }

            //system.debug('toBeUpdated' + toBeUpdated);

            if(toBeUpdated.size() > 0){
                Database.SaveResult[] updateList = Database.update(toBeUpdated,false);
                for(Database.SaveResult result: updateList){
                    if(!result.isSuccess()){
                        for(Database.Error objErr : result.getErrors()){
                            errorForImpactAmount=objErr.getMessage();
                        } 
                    }
                }
                
                if(errorForImpactAmount ==null){
                    checklistCompletion= calculateChecklistCompletion(caseRecord);
                    //Checklist Enhancements v1 - US458790: [Case: Checklists] Impact Amount Sum Error Message
                    //if(nonCompliantIndicator){errorFromCase = calculateAdjustmentAmount(caseRecord);} - Commented code as part of DE60015 - fix
                    errorFromCase = calculateAdjustmentAmount(caseRecord,compliantIndicator,nonCompliantIndicator);
                }
                
                if(errorForImpactAmount!= null || errorFromCase!=null){ 
                    errorMessageToBeDisplayed = errorForImpactAmount == null ? errorFromCase:errorForImpactAmount;
                    AuraHandledException e = new AuraHandledException(errorMessageToBeDisplayed);
                    e.setMessage(errorMessageToBeDisplayed);
                    if(!test.isRunningTest()){throw e;}
                }
                if(caseRecord != null){
                    updateClaimCaseReviewer(caseRecord);
                } 
            } 
        }

        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);throw new AuraHandledException(ex.getMessage());}
        return checklistCompletion;
    }

    //Method returns the Non-Compliant review reults to be displayed in the Claim Review Results Tab
    @AuraEnabled
    public static List<Core_MDF_Claim_Case_Checklist__c> getChecklistResults(id caseRecord){
        List<Core_MDF_Claim_Case_Checklist__c> result = new List<Core_MDF_Claim_Case_Checklist__c>();
        //List<String> reviewFindings = new List<String>();
        //Case cs = new Case();
        try{
            result = [select Core_MDF_Case_ID__c, Core_MDF_Checklist_Status__c, toLabel(Core_MDF_Claim_Case_Review_Findings__c)
                                                            FROM Core_MDF_Claim_Case_Checklist__c
                                                            where Core_MDF_Case_ID__c =: caseRecord 
                                                            and Core_MDF_Checklist_Status__c = 'Non-Compliant'];
            // Commented the below code, handling in updateClaimCaseReviewer method
            /*for (Core_MDF_Claim_Case_Checklist__c chklst : result){
                reviewFindings.add(chklst.Core_MDF_Claim_Case_Review_Findings__c);
            }
            cs.Id = caseRecord;
            cs.Core_MDF_Non_Compliance_Reason_txt__c = String.join(reviewFindings, '; ');
            Database.update(cs);*/
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return result;
    }

    //Method calculates the Checklist completion percentage
    @AuraEnabled
    public static integer calculateChecklistCompletion(id caseRecord){
        decimal filledChecklistItems=0; 
        decimal totalChecklistItems=0;
        decimal checklistPercentage=0;
        Case toBeUpdatedCase;
        
        List<Core_MDF_Claim_Case_Checklist__c> toBeUpdated = new List<Core_MDF_Claim_Case_Checklist__c>();
        List<Core_MDF_Claim_Case_Checklist__c> result = new List<Core_MDF_Claim_Case_Checklist__c>();
        

        try{
            result = [select Core_MDF_Checklist_Status__c 
                        FROM Core_MDF_Claim_Case_Checklist__c 
                        where Core_MDF_Case_ID__c=:caseRecord];
            for(Core_MDF_Claim_Case_Checklist__c caseRec : result){

                if(caseRec.Core_MDF_Checklist_Status__c != NULL){
                    filledChecklistItems = filledChecklistItems+1;
                }
                totalChecklistItems= totalChecklistItems+1;
            }
            
            if(filledChecklistItems!=0){checklistPercentage = (filledChecklistItems/totalChecklistItems)*100;}

            for(Core_MDF_Claim_Case_Checklist__c caseRec : result){
                Core_MDF_Claim_Case_Checklist__c record = new Core_MDF_Claim_Case_Checklist__c(id=caseRec.id); 
                record.Core_MDF_Completion_Percentage__c = integer.valueOf(checklistPercentage);
                toBeUpdated.add(record);
            }

                if(toBeUpdated.size() > 0){
                    Database.SaveResult[] updateList = Database.update(toBeUpdated,false); 
                }
            //system.debug('integer.valueOf(checklistPercentage)' + integer.valueOf(checklistPercentage));
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return integer.valueOf(checklistPercentage);
    }

    //Method gets the Case Status which would determine the editability of Checklist items
    @AuraEnabled
    public static string getCaseStatus(id caseRecord){
        Case caseResult = new Case();
        string caseStatus;

        try{
            caseResult = [select Core_MDF_Status__c from Case where id=:caseRecord limit 1];
            caseStatus = caseResult.core_mdf_status__c;
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return caseStatus;     
    }

    //Checklist Enhancements v1 - US458776: [Case: Edit] Automatic Status for Checklist Results
    @AuraEnabled
    public static boolean calculateCaseStatus(id caseRecord , boolean performUpdate){

        decimal compliantCount = 0; decimal nonCompliantCount = 0;
        Case toBeUpdatedCase;
        boolean caseStatusChange = false;

        List<Core_MDF_Claim_Case_Checklist__c> toBeUpdated = new List<Core_MDF_Claim_Case_Checklist__c>();
        List<Core_MDF_Claim_Case_Checklist__c> result = new List<Core_MDF_Claim_Case_Checklist__c>();
        try{
            toBeUpdatedCase = new Case(id=caseRecord);

            result = [select Core_MDF_Checklist_Status__c 
                        FROM Core_MDF_Claim_Case_Checklist__c 
                        where Core_MDF_Case_ID__c=:caseRecord];
            
            for(Core_MDF_Claim_Case_Checklist__c caseRec : result){
                Core_MDF_Claim_Case_Checklist__c record = new Core_MDF_Claim_Case_Checklist__c(id=caseRec.id); 
                compliantCount += caseRec.Core_MDF_Checklist_Status__c == 'Compliant'? 1:0;
                nonCompliantCount += caseRec.Core_MDF_Checklist_Status__c == 'Non-Compliant'? 1:0;
            }
            
            //DE55189 - User able to see warning message when all Checklists are NA
            if(nonCompliantCount==0 && compliantCount > 0){toBeUpdatedCase.Core_MDF_Review_Case_Status__c = 'Compliant';}
            if(compliantCount==0 && nonCompliantCount > 0){toBeUpdatedCase.Core_MDF_Review_Case_Status__c = 'Non-compliant';}
            

            if(toBeUpdatedCase.Core_MDF_Review_Case_Status__c != null){
                caseStatusChange=true;
                if(performUpdate){
                    Database.SaveResult updateCase = Database.update(toBeUpdatedCase,false);
                }
                } 
        }

        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return caseStatusChange;
    }

    //Checklist Enhancements v1 - US458785: [Case: Edit] Adjustment Amount (Local Currency) from Checklist Impact Amount (Local) and Reimbursement Rate
    @AuraEnabled
    public static string calculateAdjustmentAmount(id caseRecord, boolean compliant, boolean nonCompliant){
        decimal impactAmountSummation=0;
        decimal adjustmentAmount; 
        decimal adjustmentAmountUSD;
        decimal reimbursementRate;
        string exceptionMessage; 
        
        //US517787 - Set Case to Non-Compliant only when Claim amount and Adjustment amount is Equal
        decimal compliantCount = 0; decimal nonCompliantCount = 0;
        decimal requestedAmountUSD;
        integer checklistCompletion;
        

        List<Core_MDF_Claim_Case_Checklist__c> toBeUpdated = new List<Core_MDF_Claim_Case_Checklist__c>();
        List<Core_MDF_Claim_Case_Checklist__c> result = new List<Core_MDF_Claim_Case_Checklist__c>();

        try{
            result = [select Core_MDF_Impact_Amount_Summation_nbr__c,Core_MDF_Impact_Amount__c,Core_MDF_Checklist_Status__c, Core_MDF_Completion_Percentage__c
                    FROM Core_MDF_Claim_Case_Checklist__c 
                    where Core_MDF_Case_ID__c=:caseRecord];
        
            for(Core_MDF_Claim_Case_Checklist__c caseRec : result){
                impactAmountSummation += caseRec.Core_MDF_Impact_Amount__c==null?0:caseRec.Core_MDF_Impact_Amount__c;
                compliantCount += caseRec.Core_MDF_Checklist_Status__c == 'Compliant'? 1:0;
                nonCompliantCount += caseRec.Core_MDF_Checklist_Status__c == 'Non-Compliant'? 1:0;
                checklistCompletion = integer.valueof(caseRec.Core_MDF_Completion_Percentage__c);
            }

            for(Core_MDF_Claim_Case_Checklist__c caseRec : result){
                    Core_MDF_Claim_Case_Checklist__c record = new Core_MDF_Claim_Case_Checklist__c(id=caseRec.id); 
                    record.Core_MDF_Impact_Amount_Summation_nbr__c = impactAmountSummation;
                    toBeUpdated.add(record);
            }
            
            Case caseResult = [select id,Core_MDF_Reimbursement_Rate__c,Core_MDF_Excess_Requested_Amt__c,Core_MDF_Adjustment_Amount_Local__c,Core_MDF_ReimbursableTransactionAmount__c,Core_MDF_Claim_Conversion_Exchange_Rate__c,Core_MDF_Requested_Amount_USD_Amt__c
                               from Case where id=:caseRecord limit 1];
                
                reimbursementRate= caseResult.Core_MDF_Reimbursement_Rate__c / 100;
                adjustmentAmount = impactAmountSummation * reimbursementRate;
                caseResult.Core_MDF_Adjustment_Amount_Local__c = adjustmentAmount;
         
                //caseResult.Core_MDF_Calc_Reimb_transaction_amt__c = caseResult.Core_MDF_ReimbursableTransactionAmount__c * reimbursementRate;
                
                //US554852: PRB000093684 : Case # 00484218, fully denied claim with reimbursement amount $0.01
               
                requestedAmountUSD = (impactAmountSummation * caseResult.Core_MDF_Claim_Conversion_Exchange_Rate__c).setScale(2);
                caseResult.Core_MDF_Adjustment_Amount_USD_Amt__c = (requestedAmountUSD * reimbursementRate).setScale(2,System.RoundingMode.HALF_UP);
                //caseResult.Core_MDF_Total_Impact_Amt_USD__c = (requestedAmountUSD * reimbursementRate).setScale(2,System.RoundingMode.HALF_UP);
            //DE60015 - fix; DE60363 - fix
            //if(checklistCompletion == 100 && ((compliant && !nonCompliant)|| (compliantCount!=0 && nonCompliantCount==0))){
            //Defect#DE112061 Fix - Incorrect Error message when one Checklist item is changed
            //WW49 - NP - Commenting the below condition since Fully compliant cases cannot have Adjustment amount (#311 - #317)
            /*if(checklistCompletion == 100 && (compliantCount!=0 && nonCompliantCount==0)){
                decimal excessAmount = caseResult.Core_MDF_Excess_Requested_Amt__c == null? 0 : caseResult.Core_MDF_Excess_Requested_Amt__c;
                if(caseResult.Core_MDF_Adjustment_Amount_USD_Amt__c >= (caseResult.Core_MDF_Requested_Amount_USD_Amt__c-excessAmount)|| caseResult.Core_MDF_Adjustment_Amount_USD_Amt__c < 0){
                    exceptionMessage = 'Adjustment Amount (USD) Can Not Be More or Equal To Requested Amount (USD) - Excess Requested Amount (USD) Or Less Than Zero for Complaint Cases';
                }
            }
            system.debug('compliantCount' + compliantCount + 'nonCompliantCount' + nonCompliantCount);*/
            //US517787 - Set Case to Non-Compliant only when Claim amount and Adjustment amount is Equal
            //if(checklistCompletion == 100 && ((nonCompliant && !compliant) || (compliantCount==0 && nonCompliantCount!=0))){
            //Defect#DE112061 Fix - Incorrect Error message when one Checklist item is changed
            if(checklistCompletion == 100 && (compliantCount==0 && nonCompliantCount!=0)){
                if((caseResult.Core_MDF_Adjustment_Amount_Local__c != caseResult.Core_MDF_ReimbursableTransactionAmount__c * reimbursementRate) && (caseResult.Core_MDF_Adjustment_Amount_Local__c < caseResult.Core_MDF_ReimbursableTransactionAmount__c * reimbursementRate)){
         
                    exceptionMessage = 'Please note that the Adjustment Amount is less than the Claim amount. Kindly make sure this is a valid Non-Compliant.';
                }
            }
            
            if(toBeUpdated.size()>0){
                Database.SaveResult[] updateChecklistRecords = Database.update(toBeUpdated,false);
                Database.SaveResult updateCase = Database.update(caseResult,false);
                    if(!updateCase.isSuccess()){
                        for(Database.Error objErr : updateCase.getErrors()){
                            //DE60015 - fix
                            exceptionMessage = exceptionMessage == null?objErr.getMessage():exceptionMessage;
                        } 
                    }
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return exceptionMessage;
    }

    //Checklist Enhancements v2 - US488875: [Checklist] HIGH: Assign additional Case Checklist permissions to Finance users
    @AuraEnabled
    public static boolean checkEditability(){
        List<PermissionSetAssignment> isAClaimCaseReviewOrManager = new List<PermissionSetAssignment>();

        try{
            isAClaimCaseReviewOrManager= [select PermissionSet.Name from PermissionSetAssignment 
                                        where Assignee.Id = :UserInfo.getUserId() 
                                        AND (PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer' OR PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager')
                                        ];
        
        }

        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        if(isAClaimCaseReviewOrManager.size()>0){return true;}
        else{return false;}
        
    }
    
    //As per US742525, setting Claim Case Reviewer Field value with last updated user on checklist record
    public static void updateClaimCaseReviewer(id caseRecord){
        Case caseResult = new Case();
        List<Core_MDF_Claim_Case_Checklist__c> result = new List<Core_MDF_Claim_Case_Checklist__c>();
        List<String> standardProfiles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_StandardProfiles').split(';');
        List<String> reviewFindings = new List<String>();
        Id lastModId;
        boolean needUpdate = false;
        try{
            if(caseRecord != null){
                result = [select LastModifiedDate, LastModifiedBy.Profile.Name, LastModifiedById, Core_MDF_Checklist_Status__c, 
                          toLabel(Core_MDF_Claim_Case_Review_Findings__c), Core_MDF_Case_ID__r.Core_MDF_Claim_Case_Reviewer_Lookup__c, 
                          Core_MDF_Case_ID__c FROM Core_MDF_Claim_Case_Checklist__c where Core_MDF_Case_ID__c=:caseRecord ORDER BY LastModifiedDate];
                for (Core_MDF_Claim_Case_Checklist__c chklst : result){
                    // checking if checklist status is Non-Compliant
                    if((NON_COMPLIANT_STATUS).equals(chklst.Core_MDF_Checklist_Status__c)){
                        reviewFindings.add(chklst.Core_MDF_Claim_Case_Review_Findings__c);
                    }
                    // Checking if Claim Case Reviewer Field is NULL
                    if((chklst.Core_MDF_Case_ID__r.Core_MDF_Claim_Case_Reviewer_Lookup__c == null) && 
                       (!standardProfiles.contains(chklst.LastModifiedBy.Profile.Name)) && (lastModId == null)){
                           lastModId = chklst.LastModifiedById;
                       }
                }
                
                caseResult.Id = caseRecord;
                // Below Code for updating Non-Compliance Reason field
                if(reviewFindings.size() >0){
                    caseResult.Core_MDF_Non_Compliance_Reason_txt__c = String.join(reviewFindings, '; ');
                    needUpdate=true;
                }
                //TWC742-820 - Non-Compliance Reason field in Case Report is not getting cleared
                else{
                    caseResult.Core_MDF_Non_Compliance_Reason_txt__c = '';
                    needUpdate=true;
                }
                // Below Code for updating Claim Case Reviewer Field
                if(lastModId != null){
                    caseResult.Core_MDF_Claim_Case_Reviewer_Lookup__c = lastModId;
                }
                // Case update
                if(lastModId != null || needUpdate){
                    Database.update(caseResult);
                }
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
     /* US848325: [Tech] Show the “Case Review Findings” when they create a “Claim Case Review Result” escalation
      * Method returns case Id from Escalation record id
      */ 
    @AuraEnabled
    public static String getCaseIdFromEscalation(String recId){
        String caseId = '';
        try{
            if(String.isNotBlank(recId)) {
                Core_MDF_Escalation__c escObj = [SELECT Id, Core_MDF_Case_ID_Number_id__c FROM Core_MDF_Escalation__c WHERE Id = :recId];
                caseId = (escObj != null)?escObj.Core_MDF_Case_ID_Number_id__c:'';
            }
        } catch(exception ex) { Core_MDF_CCP_UtilityClass.logError(ex); }
        return caseId;
    }  
    
    
    //Audit functionality Method to get AI Status from Scorecard for displaying appropriate message
    @AuraEnabled
   public static Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper  getAIAuditStatusFromScorecard(Id caseRecordId){
        Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper  aiWrapper = Core_MDF_Scorecard_Helper.getScoreCardDetailsAndAccess(caseRecordId);
        system.debug('CHECKLIST AI STATUS:' + aiWrapper);
        return aiWrapper;
    }
}