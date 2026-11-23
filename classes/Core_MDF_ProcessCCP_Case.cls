/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Case 
* Version     : 1.0 
* Created Date: 04-02-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        04/02/2019                    Created Core_MDF_ProcessCCP_Case 
* Intel - NP					01/08/2019					  Added lines of code to prevent Case from being Compliant/Non-Compliant 
*															  if Checklist is incomplete	
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_Case {
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
        
        try{
            List<Id> ccpCaseRecordTypeIdList = new List<Id>();
            Map<id,decimal> caseIdToChecklistCompletion = new Map<id,decimal>();
            
            for(String recTypeDevName: Label.Core_MDF_CCP_Case_RecordType_DevName.Split(';')){
                ccpCaseRecordTypeIdList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId());
            }
            
            Set<Id> reviewrManagerSet = new Set<Id>();
            Set<Id> caseReviwerSet = new Set<Id>();
            Map<id,case> ccpCaseList = new Map<id,case>();
            
            //Co-Marketing RecordTypeId Check
            for(Case cs: caseList){
                if(ccpCaseRecordTypeIdList.contains(cs.RecordTypeId)){
                    if(cs.Core_MDF_Claim_Case_Reviewer_Lookup__c != null){
                        caseReviwerSet.add(cs.Core_MDF_Claim_Case_Reviewer_Lookup__c);      
                    }
                    //Added for Checklist completion check  
                    if(isUpdate && (cs.Core_MDF_Review_Case_Status__c == 'Compliant' || cs.Core_MDF_Review_Case_Status__c =='Non-compliant')){
                        system.debug('Inside If');
                        ccpCaseList.put(cs.id,cs);}
                    
                    //US527005: Added for Data entry correction reason to be shown as concatenated value- added by Ealisha
                    if((cs.Core_MDF_Data_Entry_Correction__c && (cs.Core_MDF_Data_Correction_Note_Txt__c != null || cs.Core_MDF_Data_Entry_Correction_Cd__c != null ))){                        
                        system.debug('populate data entry correction reason');
                        cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c = 
                            ((cs.Core_MDF_Data_Entry_Correction_Cd__c != null) ? cs.Core_MDF_Data_Entry_Correction_Cd__c + '^ ' : '' );
                        cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c = 
                            (cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c != null) ?  
                            (cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c + cs.Core_MDF_Data_Correction_Note_Txt__c) : '';                            
                                            
                    }
                    else{
                        cs.Core_MDF_Data_Entry_CorrectionReason_Txt__c = '';
                    }
                }
            }
            
            //Added for Checklist completion check 
            if(ccpCaseList.size()>0){
                caseIdToChecklistCompletion = validateChecklistCompletion(ccpCaseList.keyset());
                for(case record:ccpCaseList.values()){
                    record.Core_MDF_Checklist_Completion__c = integer.valueOf(caseIdToChecklistCompletion.get(record.id));
                    system.debug('Inside If' + integer.valueOf(caseIdToChecklistCompletion.get(record.id)));
                }
            }
            
            //system.debug('caseIdToChecklistCompletion' +caseIdToChecklistCompletion);
            //Below lines of code will not executed for other than Co-Marketing cases
            if(caseReviwerSet.size() > 0){
                for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :caseReviwerSet
                                                      AND (PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer' OR PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager')]){
                                                          reviewrManagerSet.add(usrPer.AssigneeId);
                                                      }
                
                for(Case cs: caseList){
                    if(ccpCaseRecordTypeIdList.contains(cs.RecordTypeId) &&
                       cs.Core_MDF_Claim_Case_Reviewer_Lookup__c != NULL &&
                       (isInsert || (isUpdate && cs.Core_MDF_Claim_Case_Reviewer_Lookup__c != oldMap.get(cs.Id).Core_MDF_Claim_Case_Reviewer_Lookup__c))&& 
                       (!reviewrManagerSet.contains(cs.Core_MDF_Claim_Case_Reviewer_Lookup__c))){
                           cs.AddError(Label.Core_MDF_Case_Change_Reviewer_Error_Message);
                       }
                }
            }  
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Case_Review_Document_Log_Entry_Origin);                  
        }
        
    }
    
    
    
    //Method calculates the Checklist completion percentage of a given case
    public static Map<id,decimal> validateChecklistCompletion(set<id> caseList){
        
        List<Core_MDF_Claim_Case_Checklist__c> checklistList = new List<Core_MDF_Claim_Case_Checklist__c>();
        Map<id,decimal> caseIDToChecklistCompletionPercentage = new Map<id,decimal>();
        
        try{
            checklistList = [select Core_MDF_Completion_Percentage__c,Core_MDF_Case_ID__c from Core_MDF_Claim_Case_Checklist__c where Core_MDF_Case_ID__c =: caseList];
            
            for(Core_MDF_Claim_Case_Checklist__c record : checklistList){
                caseIDToChecklistCompletionPercentage.put(record.Core_MDF_Case_ID__c,record.Core_MDF_Completion_Percentage__c);
            }
            
            system.debug('caseIDToChecklistCompletionPercentage' + caseIDToChecklistCompletionPercentage);
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return caseIDToChecklistCompletionPercentage;
    }
}