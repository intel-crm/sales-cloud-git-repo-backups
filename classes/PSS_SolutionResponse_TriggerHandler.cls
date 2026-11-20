/**************************************************************************************
Apex Class Name : PSS_SolutionResponse_TriggerHandler
Version     : 1.0 
Created Date: 12th Feb, 2021
Description : Trigger handler for PSS_SolutionResultTrigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  12/02/2021               Original Version
*************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionResponse_TriggerHandler  extends TriggerHandler{
    
    /*Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static boolean isRecursive = FALSE;
    public static boolean callImpactPath = True;
    public static boolean elapseTimeCalculation = True;
    public static boolean intelProductReccursiveStop = True;
    
    
    public override void afterInsert(){
        
        if((mapFunctionalityNameTriggerExecution.containsKey('PSS_solution_trigger') &&
           mapFunctionalityNameTriggerExecution.get('PSS_solution_trigger').Core_Active__c) || Test.isRunningTest()){
        //Impact Path Scoring logic
        //Whenever new survey result record gets created create records of junction object PSS_Solution_with_Impact_Path_Scoring__c.
        //This will remove the risk of multiple records of junction object being created at solution level
        Map<Id, ArdiraSurvey__Survey_Result__c> newMap = (Map<Id, ArdiraSurvey__Survey_Result__c>) Trigger.newMap;
        Map<ID, PSS_Impact_Path_Scoring_Criteria__c> impactPathCriteriaMap = new Map<ID, PSS_Impact_Path_Scoring_Criteria__c>([SELECT Id, Name 
        
                                                                                                           FROM PSS_Impact_Path_Scoring_Criteria__c]);
        List<PSS_Solution_with_Impact_Path_Scoring__c> solWithImpactPathList = new List<PSS_Solution_with_Impact_Path_Scoring__c>();
        for(Id surveyResultId:newMap.keySet()){
            
            for(id impactPathId: impactPathCriteriaMap.keySet()){ 
                PSS_Solution_with_Impact_Path_Scoring__c solWithImpactPathObj = new PSS_Solution_with_Impact_Path_Scoring__c();
                solWithImpactPathObj.PSS_Ardira_Survey_Result__c = surveyResultId;
                solWithImpactPathObj.PSS_Impact_Path_Scoring_Criteria__c = impactPathId;
                solWithImpactPathList.add(solWithImpactPathObj);
            }
        }
        if(Schema.sObjectType.PSS_Solution_with_Impact_Path_Scoring__c.isCreateable()) {
           insert solWithImpactPathList;
        }
        //Create Intel Sales group user Sharing records
        PSS_SolutionResponseTriggerHelper.createSharingRecords((List<ArdiraSurvey__Survey_Result__c>) Trigger.new);      
       }
    }
    
    public override void beforeInsert(){
        List<ArdiraSurvey__Survey_Result__c> solutionList = (List<ArdiraSurvey__Survey_Result__c>) Trigger.New;
        List<Id> contactIdList = new List<Id>();
        Map<Id, Id> contactToUserMap = new Map<Id, Id>();
        //fo bulk operations fetch all the Submitter Contacts associated with the partner solutions
        for(ArdiraSurvey__Survey_Result__c res : solutionList){
            if(res.ArdiraSurvey__Assigned_To_Contact__c != NULL)
            	contactIdList.add(res.ArdiraSurvey__Assigned_To_Contact__c);
        }
        
        if(contactIdList != NULL && !contactIdList.isEmpty()){
            //for the fetched contacts get the respective user ids
            for(User u:[SELECT Id,ContactId FROM User where ContactId IN : contactIdList ]){
                contactToUserMap.put(u.ContactId, u.Id);
            }
            if(contactToUserMap != NULL && !contactToUserMap.isEmpty()){
                for(ArdiraSurvey__Survey_Result__c res: solutionList){
                    //if the assigned to contact != assigned to user that means Admin has created the solution
                    //Hence update the Assigned to field with the partner user
                    if(String.isNotBlank(res.ArdiraSurvey__Assigned_To_Contact__c) &&
                       res.ArdiraSurvey__Assigned_To_User__c != contactToUserMap.get(res.ArdiraSurvey__Assigned_To_Contact__c)){
                           res.ArdiraSurvey__Assigned_To_User__c = contactToUserMap.get(res.ArdiraSurvey__Assigned_To_Contact__c);
                       }
                    
                }
            }
        }
        //Added by Hanuma Pantham - US1053946
        if((mapFunctionalityNameTriggerExecution.containsKey('Solution_Mem_Handler') &&
           mapFunctionalityNameTriggerExecution.get('Solution_Mem_Handler').Core_Active__c) || Test.isRunningTest()){
               PSS_SolutionOPIDRollup.updateAccountDetails(solutionList);
           }
        PSS_SolutionResponseTriggerHelper.populateSearchableFields(solutionList, null);
    }
    
    public override void afterUpdate(){
        List<ArdiraSurvey__Survey_Result__c> newList = (List<ArdiraSurvey__Survey_Result__c>) Trigger.New;
        Map<Id, ArdiraSurvey__Survey_Result__c> surveyResultOldMap = (Map<Id, ArdiraSurvey__Survey_Result__c>) Trigger.oldMap;
        Map<Id, ArdiraSurvey__Survey_Result__c> surveyResultNewMap = (Map<Id, ArdiraSurvey__Survey_Result__c>) Trigger.newMap;
        List<ArdiraSurvey__Survey_Result__c> approvedResults = new List<ArdiraSurvey__Survey_Result__c>();
        Map<Id, ArdiraSurvey__Survey_Result__c> oldMap = (Map<Id, ArdiraSurvey__Survey_Result__c>) Trigger.oldMap;
        if((mapFunctionalityNameTriggerExecution.containsKey('PSS_solution_trigger') &&
        mapFunctionalityNameTriggerExecution.get('PSS_solution_trigger').Core_Active__c ) || Test.isRunningTest()){
        //Create Intel Sales group user Sharing records
        //PSS_SolutionResponseTriggerHelper.createSharingRecords((List<ArdiraSurvey__Survey_Result__c>) Trigger.new);
        }
        
    }    
    public override void beforeUpdate(){
         
        Map<Id, ArdiraSurvey__Survey_Result__c> oldMap = (Map<Id, ArdiraSurvey__Survey_Result__c>) Trigger.oldMap;
        List<ArdiraSurvey__Survey_Result__c> newList = (List<ArdiraSurvey__Survey_Result__c>) Trigger.New;
        List<ArdiraSurvey__Survey_Result__c> approvedResults = new List<ArdiraSurvey__Survey_Result__c>();
        List<ArdiraSurvey__Survey_Result__c> statusChangeresults = new List<ArdiraSurvey__Survey_Result__c>();
        

        List<Id> contactIdList = new List<Id>();
        Map<Id, Id> contactToUserMap = new Map<Id, Id>();
        //fo bulk operations fetch all the Submitter Contacts associated with the partner solutions
        for(ArdiraSurvey__Survey_Result__c res : newList){
            if(res.ArdiraSurvey__Assigned_To_Contact__c != NULL && 
              (res.PSS_Partner_Solution_Lifecycle_Status_Nm__c != PSS_StaticConstants.SOLUTION_APPROVED_STATUS &&
              res.PSS_Partner_Solution_Lifecycle_Status_Nm__c != PSS_StaticConstants.SOLUTION_CONVERTED_STATUS))
            	contactIdList.add(res.ArdiraSurvey__Assigned_To_Contact__c);
        }
        
        if(contactIdList != NULL && !contactIdList.isEmpty()){
            //for the fetched contacts get the respective user ids
            for(User u:[SELECT Id,ContactId FROM User where ContactId IN : contactIdList LIMIT 1]){
                contactToUserMap.put(u.ContactId, u.Id);
            }
            if(contactToUserMap != NULL && !contactToUserMap.isEmpty()){
                for(ArdiraSurvey__Survey_Result__c res: newList){
                    //if the assigned to contact != assigned to user that means Admin has created the solution
                    //Hence update the Assigned to field with the partner user
                    if(String.isNotBlank(res.ArdiraSurvey__Assigned_To_Contact__c) &&
                       res.ArdiraSurvey__Assigned_To_User__c != contactToUserMap.get(res.ArdiraSurvey__Assigned_To_Contact__c) ) {
                           res.ArdiraSurvey__Assigned_To_User__c = contactToUserMap.get(res.ArdiraSurvey__Assigned_To_Contact__c);
                           //system.debug('assigned user-->'+res.ArdiraSurvey__Assigned_To_User__c);
                       }
                }
            }
        }
        
        Set<Id> surveyIds = new Set<Id>();
        //PSS_DummyClass.populateSearchableFields(newList,oldMap);
        if(mapFunctionalityNameTriggerExecution.containsKey('PSS_solution_trigger') &&
           mapFunctionalityNameTriggerExecution.get('PSS_solution_trigger').Core_Active__c){
               
               //ADDED LOGIC TO STORE THE TIME SPENT ON PARTICULAR STATUS VALUE//
               If(!isRecursive){//STOP RECURSIVE ACTION WHEN CONSECUTIVELY CHANGED FROM ON-HOLD --> UPDATE REQUIRED --> (WORKFLOW UPDATES)
                   for(ArdiraSurvey__Survey_Result__c newObject : newList){
                       
                       ArdiraSurvey__Survey_Result__c oldObject = oldMap.get(newObject.Id);
                       
                       if((newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c !=oldObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c) &&
                          (oldObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_ONHOLD_STATUS) && elapseTimeCalculation){
                              //system.debug('Here::');
                              newObject.PSS_Total_Minutes_On_Hold__c = oldObject.PSS_Total_Minutes_On_Hold__c!=null ? 
                                  oldObject.PSS_Total_Minutes_On_Hold__c + newObject.PSS_Elapsed_Time_For_On_Hold_Nm__c 
                                  : newObject.PSS_Elapsed_Time_For_On_Hold_Nm__c;
                              //system.debug('Here::'+newObject.PSS_Total_Minutes_On_Hold__c);       
                              newObject.PSS_LastSetToOnHold_Dt__c = null;
                              elapseTimeCalculation = false;
                          }
                       
                       else if((newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c !=oldObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c) && 
                               (oldObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_UPDATE_REQUIRED_STATUS) && elapseTimeCalculation){
                                   
                                   newObject.PSS_Total_Minutes_Update_Required__c = oldObject.PSS_Total_Minutes_Update_Required__c!=null ? 
                                       oldObject.PSS_Total_Minutes_Update_Required__c + newObject.PSS_Elapsed_Time_For_Update_Required_Nm__c
                                       : newObject.PSS_Elapsed_Time_For_Update_Required_Nm__c ;
                                   
                                   newObject.PSS_Last_Set_To_Updated_Required_Dt__c = null;
                                   elapseTimeCalculation = false;
                               }
                       
                
                // added by priyanka - US912162
                if((newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c !=oldObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c) && 
                    (newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW || newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c== PSS_StaticConstants.SOLUTION_REJECTED_STATUS)){
                    //TWC1824-654 Ge-TM : Implement Separate profile for ge-TM Admin.
                    //replaced condition to check for Getm Admin
                    if(oldObject.PSS_Solution_Submitter_UserId_Id__c == NULL || 
                        (oldObject.PSS_Solution_Submitter_UserId_Id__c != NULL && !PMP_SearchUtilityController.isIntelAdmin())){
                        newObject.PSS_Solution_Submitter_UserId_Id__c =UserInfo.getUserId();
                    }
                     
                }
                // added by priyanka - US912162 end
                    
                if(oldMap.get(newObject.id).PSS_Partner_Solution_Lifecycle_Status_Nm__c != newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c && 
                    newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS) {
                    approvedResults.add(newObject);
                }
                
                if(oldMap.get(newObject.id).PSS_Partner_Solution_Lifecycle_Status_Nm__c != newObject.PSS_Partner_Solution_Lifecycle_Status_Nm__c){
                    statusChangeresults.add(newObject);
                    surveyIds.add(newObject.ArdiraSurvey__Survey__c);
                }
                
                
                
                
            }
            //isRecursive = TRUE;
                    
            if(!statusChangeresults.isEmpty()){	
                PSS_SolutionResponseTriggerHelper.populateArdiraStatusAndStage(statusChangeresults,surveyIds);
            }
            if(intelProductReccursiveStop && PSS_StaticConstants.opIDTriggerLogicStop){
                intelProductReccursiveStop = false;
            PSS_SolutionResponseTriggerHelper.populateIntelProducts(newList, oldMap);
            PSS_SolutionResponseTriggerHelper.populateSolutionFieldsFromQuestionResult(newList);
			PSS_SolutionResponseTriggerHelper.populateApprovedDate(newList,oldMap);
            PSS_SolutionResponseTriggerHelper.populateSearchableFields(newList, oldMap);
    
            }
            
            //count no of strategic attributes selected in solution
            for(ArdiraSurvey__Survey_Result__c surveyResponse:newList){
                surveyResponse.PSS_No_Of_Strategic_Attributes_Applicabl__c = PSS_Utility.geNumberOfValuesSelected(surveyResponse.PSS_Strategic_Attributes_Nm__c);
            }
           
            PSS_SolutionResultTriggerHelper.convertSolutionToOffering(newList,oldMap);
            if(approvedResults.size() > 0) {
               PSS_BenefitAssignmentTriggerHelper.assignBenefitToAccount(approvedResults);
            }        
            
            //END OF TIME TRIGGER THE LOGIC
        }
      }
       
    }*/
}