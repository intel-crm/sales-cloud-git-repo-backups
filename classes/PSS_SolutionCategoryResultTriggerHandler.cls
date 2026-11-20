/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionCategoryResultTriggerHandler 
* Version     : 1.0 
* Created Date: 6/16/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Apoorva              M-01    : Original version       4/06/2021                         handler class for PSS_SolutionCategoryResultTrigger
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionCategoryResultTriggerHandler  extends TriggerHandler{
    
    /*Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

    public override void afterInsert(){
       
        if((mapFunctionalityNameTriggerExecution.containsKey('PSS_SolutionCategoryResult_Switch') &&
        mapFunctionalityNameTriggerExecution.get('PSS_SolutionCategoryResult_Switch').Core_Active__c) || Test.isRunningTest()){
            List<ArdiraSurvey__Survey_Category_Result__c> newCatList = (List<ArdiraSurvey__Survey_Category_Result__c>) Trigger.New;
            List<ArdiraSurvey__Survey_Category_Result__c> catListToProcess = new List<ArdiraSurvey__Survey_Category_Result__c>();
            catListToProcess= PSS_SolutionCategoryResultTriggerHelper.getRecordsToProcess(newCatList);
            
            if(!catListToProcess.isEmpty()){
                PSS_SolutionCategoryResultTriggerHelper.calculateCategoryScore(catListToProcess);
            }
        
        }
    }
    
    public override void beforeUpdate(){
        if((mapFunctionalityNameTriggerExecution.containsKey('PSS_SolutionCategoryResult_Switch') &&
        mapFunctionalityNameTriggerExecution.get('PSS_SolutionCategoryResult_Switch').Core_Active__c) || Test.isRunningTest()){
       
            List<ArdiraSurvey__Survey_Category_Result__c> newCatList = (List<ArdiraSurvey__Survey_Category_Result__c>) Trigger.New;
            List<ArdiraSurvey__Survey_Category_Result__c> catListToProcess = new List<ArdiraSurvey__Survey_Category_Result__c>();
            catListToProcess= PSS_SolutionCategoryResultTriggerHelper.getRecordsToProcess(newCatList);
            
            if(!catListToProcess.isEmpty()){
                PSS_SolutionCategoryResultTriggerHelper.calculateCategoryScore(catListToProcess);
            }  
        }
      
    }*/
    
}