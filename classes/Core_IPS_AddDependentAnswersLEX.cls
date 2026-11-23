/****************************************************************************************************************************************
* Class Name  : Core_IPS_AddDependentAnswersLEX 
* Test Class  : Core_IPS_AddDependentAnswersLEX_Test
* Version     : 1.0 
* Created Date:  17/04/2022 
* Modification Log :
* Developer: Manisha Sajwan                     Date                          Description: 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps                          10/08/2022                      Main Controller for Core_IPS_Manage_Dependent_Answers_LEX LWC
*****************************************************************************************************************************************/

public with sharing class Core_IPS_AddDependentAnswersLEX {
    
    public static Id parentAnsId;
    public static Core_IPS_Answer__c parentAnswer;
    public static Core_IPS_Question__c EnvVariableRecord;
    public static List<selectDependentQuestion> DependentQuestion;
    public static List<selectParentAnswer> selectedParentAnswers;
    public static List<selectDependentAnswer> dependentAnswers;

  /***************************************************************************************************
    Method Name  : getParentAnswers
    Method Type  : helper method
    Version      : 1.0 
    Created Date : 10/08/2022 
    Function     : Fetch and Display the "Environment Detail Answers" records.
    Used in     : This method invoked by ICS_CX_SupportRequest_LandingPage_Lex.js file.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            10/08/2022               Created
    ****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<selectParentAnswer> getParentAnswers(String recordId){
     if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
     //removed Core_IPS_Product_Organization__r.ownerId field as part of vulnerability fixes-26/06/2026 By Rakshitha Sevella
     EnvVariableRecord = [SELECT Id, Name, Core_IPS_Question__c, Core_IPS_Status__c, Core_IPS_Product_Organization__c, /*Core_IPS_Product_Organization__r.ownerId,*/ 
                             (SELECT Id,Core_Supported_Product__c, Core_supported_product__r.name, Core_Required__c, Core_Agent_Only__c, Core_Status__c 
                                FROM Environment_Details_Operational__r WHERE Core_IPS_Question__c =: recordId AND Core_Supported_Product__c != NULL) 
                                  FROM Core_IPS_Question__c 
                                      WHERE Id =: recordId];
     }
      selectedParentAnswers = new List<selectParentAnswer>();
      
      if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
      for(Core_IPS_Answer__c sp: [SELECT Id, Name,Core_IPS_Answer__c, Core_IPS_Parent_Answer__c FROM Core_IPS_Answer__c WHERE Core_IPS_Question__c =: EnvVariableRecord.Id]){
                                     
            selectParentAnswer ansSel = new selectParentAnswer();
            ansSel.Name = sp.Core_IPS_Answer__c;
            ansSel.Id = sp.Id;
            selectedParentAnswers.add(ansSel);
        }
      }
        return selectedParentAnswers;
    }  
    
    @AuraEnabled(cacheable=true)
    public static boolean validateParentAnswers(String recordId){
        List<Core_IPS_Answer__c> parentAnswer;
        Core_IPS_Question__c ParentQuestion;
        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            ParentQuestion = [SELECT Id, Name, Core_IPS_Question__c FROM Core_IPS_Question__c WHERE Id =: recordId];
        }
        
        if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
            parentAnswer = [SELECT Id from Core_IPS_Answer__c where Core_IPS_Question__c =: ParentQuestion.Id]; 
        }
        
        
        if(parentAnswer.size() > 0){
            return true;
        }
        else
            return false;
    }
    
    
    /***************************************************************************************************
    Method Name  : getChildQuestions
    Method Type  : helper method
    Version      : 1.0 
    Created Date : 10/08/2022 
    Function     : Fetch and Display the "Environment Detail Questions" records.
    Used in     : This method invoked by Core_IPS_Manage_Dependent_Answers_LEX.js file.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            25/08/2022                  Created
    ****************************************************************************************************/
    
    @AuraEnabled(cacheable=false)
    public static List<selectDependentQuestion> getChildQuestions(String recordId){  
        
        DependentQuestion = new List<selectDependentQuestion>();
        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_Question__c css : [SELECT Id, Name, Core_IPS_Question__c FROM Core_IPS_Question__c WHERE Core_IPS_Parent_Question__c =: recordId AND (Core_IPS_Datatype__c = 'Picklist' OR Core_IPS_Datatype__c = 'Multiselect Picklist')] ){
               selectDependentQuestion selQuestion = new selectDependentQuestion();
               selQuestion.Name = css.Core_IPS_Question__c;
               selQuestion.Id = css.Id; 
               DependentQuestion.add(selQuestion); 
            }
        }
        
        return DependentQuestion;   
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean validateChildQuestions(String recordId){        
      List<selectDependentQuestion> DependentQuestion = getChildQuestions(recordId); 
      
        if(DependentQuestion.size() > 0 ){
            return true;
        }
        else
            return false;
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean validateChildAnswers(String recordId){
       List<Core_IPS_Question__c> childQuestion;
        List<Core_IPS_Answer__c> childAnswer;
       if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            childQuestion = [SELECT Id, Name, Core_IPS_Question__c FROM Core_IPS_Question__c WHERE Core_IPS_Parent_Question__c =: recordId];
       }
        
       Set<Id> quesId = new Set<Id>();
        for(Core_IPS_Question__c QAid : childQuestion){
           quesId.add(QAid.Id); 
        }
        if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
            childAnswer = [SELECT Id from Core_IPS_Answer__c where Core_IPS_Question__c IN : quesId];  
        }
        
        if(childAnswer.size() > 0){
            return true;
        }
        else
            return false;
    }
    
    /***************************************************************************************************
    Method Name  : getChildAnswers
    Method Type  : helper method
    Version      : 1.0 
    Created Date : 10/08/2022 
    Function     : Fetch and Display the "Environment Detail Answers" records.
    Used in     : This method invoked by Core_IPS_Manage_Dependent_Answers_LEX.js file.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            25/08/2022                  Created
    ****************************************************************************************************/
    
    @AuraEnabled(cacheable=false)
    public static List<selectDependentAnswer> getChildAnswers(String recordId, List<String> childQuestionIds){    
        
       dependentAnswers = new List<selectDependentAnswer>(); 
        
    //   Core_IPS_Question__c childQuestion = [SELECT Id, Name, Core_IPS_Question__c FROM Core_IPS_Question__c WHERE Id IN: childQuestionIds];
        if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
             for(Core_IPS_Answer__c sp: [SELECT Id, Name,Core_IPS_Answer__c,Core_IPS_Question__c, Core_IPS_Parent_Answer__c FROM Core_IPS_Answer__c WHERE Core_IPS_Question__c =: childQuestionIds]){                        
                selectDependentAnswer ansSel = new selectDependentAnswer();
                ansSel.Name = sp.Core_IPS_Answer__c;
                ansSel.Id = sp.Id;
                ansSel.questionId = sp.Core_IPS_Question__c; 
                ansSel.parentAnswer = sp.Core_IPS_Parent_Answer__c;
                dependentAnswers.add(ansSel);
            }
        }
        return dependentAnswers;   
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean saveDependentAnswers(String recordId, String selectedAnswers){ 
        List<String> answerIds = new List<String>();
        List<SelectedAnswerWrapper> answersToUpdate = (List<SelectedAnswerWrapper>)JSON.deserialize(selectedAnswers, List<SelectedAnswerWrapper>.class);
        for(SelectedAnswerWrapper answer : answersToUpdate) {
            answerIds.add(answer.Id);
        }
        List<Core_IPS_Answer__c> answersList = new List<Core_IPS_Answer__c>();
        Map<Id, Core_IPS_Answer__c> dependantAnswersMap = new Map<Id, Core_IPS_Answer__c>([SELECT Id, Name, Core_IPS_Question__c, Core_IPS_Answer__c, Core_IPS_Order_No__c, Core_IPS_Parent_Answer__c, Core_IPS_Status__c, Core_IPS_Question_Text__c  FROM Core_IPS_Answer__c WHERE Id IN :answerIds]);
        
        for(SelectedAnswerWrapper answer : answersToUpdate) {
            Core_IPS_Answer__c answerRecord = new Core_IPS_Answer__c();
            answerRecord = dependantAnswersMap.get(answer.Id);
            if(answer.isChecked == true) {
                answerRecord.Core_IPS_Parent_Answer__c = recordId;
            } else if(answer.isChecked == false) {
                answerRecord.Core_IPS_Parent_Answer__c = null;
            }
            answersList.add(answerRecord);
        }
        if(answersList.size() > 0) {
         update answersList;   
        }
        
      
        return true;   
    }
    
    /***************************************************************************************************
    Method Name  : updateParentAnswerOnChildAnswer
    Method Type  : helper method
    Version      : 1.0 
    Created Date : 10/08/2022 
    Function     : Update Parent Answer on the "Environment Detail Answers" records.
    Used in     : This method invoked by Core_IPS_Manage_Dependent_Answers_LEX.js file.
    Modification Log :
    * Developer                   Date                     Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            10/08/2022                  Created
    * Manisha Sajwan            22/08/2022                  Updated
    ****************************************************************************************************/
    
    @AuraEnabled
    public static boolean updateParentAnswerOnChildAnswer(String recordId, Id parentAnswerId, List<selectDependentAnswer> detailAnswers){   
        
        try{
            List<Core_IPS_Answer__c> childAnswerList = new List<Core_IPS_Answer__c>();
            for(selectDependentAnswer childAnswer : detailAnswers){
                  Core_IPS_Answer__c ans = new Core_IPS_Answer__c();
                  ans.Id = childAnswer.Id;
                  ans.Core_IPS_Parent_Answer__c = parentAnswerId;
                  childAnswerList.add(ans);
            }
            update childAnswerList;
            return true;
        }
        catch(Exception e){
            return false;
        } 
    }
   
    public class selectParentAnswer{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}        
    }
    
    public class selectDependentAnswer{
        @AuraEnabled
        public String questionId{get;set;}
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String parentAnswer{get;set;}
    }
    
    public class selectDependentQuestion{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
    }
    
     public class SelectedAnswerWrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public Boolean isChecked;
    }
}