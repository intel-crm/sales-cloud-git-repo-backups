@isTest
public with sharing class PSG_FeedbackController {
    
    //Control the PSG Feedbackform display.
    /*@AuraEnabled
    public static FeedbackWrapper getFormDetails(){
        try { 
            PSG_Feedback_Setting__c getSetting = PSG_Feedback_Setting__c.getInstance();
            FeedbackWrapper fw= new FeedbackWrapper(false,!getSetting.core_cpq_emoji_form__c,getSetting.core_cpq_emoji_form__c);
            Date todayDate = System.today();
            SBQQ__Quote__c quote= [SELECT Id FROM SBQQ__Quote__c where CreatedById =:userinfo.getUserId() LIMIT 1];
            if(getSetting.core_cpq_enabled__c && (todayDate>= getSetting.core_cpq_start_date__c && todayDate<=getSetting.core_cpq_end_date__c) && quote!=null){
                //Call the List user Feedback Details.
                List<Sales_Feedback__c> userFeedbackStatus = [SELECT Type__c,LastModifiedDate from Sales_Feedback__c where CreatedById =:userinfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 1];
                if(userFeedbackStatus.isEmpty()){ // No Record is created for that User than return the form.
                    fw.isFormVisible = getSetting.core_cpq_enabled__c;
                    return fw;
                }
                // if Last time it Skipped and LastModifiedDate it greater than or equal to Skipped Interval Days than return the form.
                if(userFeedbackStatus[0].Type__c == 'Skipped' && math.abs((todayDate).daysBetween(userFeedbackStatus[0].LastModifiedDate.date())) >= getSetting.core_cpq_skipped_interval__c){
                    fw.isFormVisible = getSetting.core_cpq_enabled__c;
                    return fw;
                }
                // if Last feedback is greater than or equal to Feedback Interval days than return the form.
                if(userFeedbackStatus[0].Type__c == 'Feedback' && math.abs((todayDate).daysBetween(userFeedbackStatus[0].LastModifiedDate.date()))>= getSetting.core_cpq_feedback_interval__c){
                    fw.isFormVisible = getSetting.core_cpq_enabled__c;
                    return fw;
                }                
            }
            return fw;
        } catch (Exception e) {
            //System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public class FeedbackWrapper{
        @AuraEnabled public Boolean isFormVisible;
        @AuraEnabled public Boolean isStar;
        @AuraEnabled public Boolean isEmoji;
        public FeedbackWrapper(Boolean isFormVisible,Boolean isStar,Boolean isEmoji){
            this.isFormVisible=isFormVisible;
            this.isStar=isStar;
            this.isEmoji=isEmoji;
        }
    }
    
    //Submit the PSG Feedback response.
    @AuraEnabled
    public static void feedbackSubmit(String feedbackRating, String feedbackComment, String feedbackType){
        List<Sales_Feedback__c> feedbackDetails = [SELECT Type__c, Rating__c,Feedback_Text__c, LastModifiedDate FROM Sales_Feedback__c where CreatedById =:userinfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 1];
        try{
            if(feedbackDetails.isEmpty() || feedbackDetails[0].Type__c == 'Feedback'){
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PSG_External_Disty'];
                List<PermissionSetAssignment> psaa = [SELECT Id from PermissionSetAssignment where AssigneeId=:userinfo.getUserId() and PermissionSetId=:ps.Id];
                Boolean hasExternalPermission = false;
                if(!psaa.isEmpty()){
                    hasExternalPermission= true;
                }
               // System.debug(hasExternalPermission);
                if(hasExternalPermission){
                    Sales_Feedback__c newfeedback = new Sales_Feedback__c(
                        Rating__c=feedbackRating,
                        Feedback_Text__c=feedbackComment,
                        Type__c=feedbackType,
                        Application__c='PSG Quoting',
                        User__c='External');
                    insert newfeedback;
                }else{
                    Sales_Feedback__c newfeedback = new Sales_Feedback__c(
                        Rating__c=feedbackRating,
                        Feedback_Text__c=feedbackComment,
                        Type__c=feedbackType,
                        Application__c='PSG Quoting',
                        User__c='Internal');
                    insert newfeedback; 
                }
            }else{
                Sales_Feedback__c newfeedback = new Sales_Feedback__c(
                    Rating__c=feedbackRating,
                    Feedback_Text__c=feedbackComment,
                    Type__c=feedbackType,
                    Application__c='PSG Quoting');
                newfeedback.Id=feedbackDetails[0].Id;
                update newfeedback;
            }
        } catch (Exception e) {
           // System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }*/
}