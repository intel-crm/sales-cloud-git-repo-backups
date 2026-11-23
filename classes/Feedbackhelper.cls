public with sharing class Feedbackhelper {
    
  
/*Using multiple parameter in apex controller */

@AuraEnabled

public static In_App_Feedback__c submitScoreAction(integer EasytoUse,  integer hasFeatures, integer fastandResponsive, integer isSecured, string additionalQuestions,string logs){

In_App_Feedback__c scoreCardObj = new In_App_Feedback__c();

scoreCardObj.Is_Easy_to_Use__c=EasytoUse;

scoreCardObj.Has_Features__c=hasFeatures;

scoreCardObj.Fast_and_Responsive__c=fastandResponsive;

scoreCardObj.Secured__c=isSecured;

scoreCardObj.Additional_Comment__c=additionalQuestions;

scoreCardObj.Logs__c=logs;    





insert scoreCardObj;

return scoreCardObj;

}



}