/*********************************************************************************************************************
Apex Class Name  : ER_RegistrationProfileResponse
Version       : 1.0
Created Date  : 1 Feb 2022
Function      : 

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Gaurav Kurwade            1 Feb 2022              To fetch project size and project timeframe from Registration Record     
*************************************************************************************************************************/


public class ER_RegistrationProfileResponse {

    //Store Profile respose values - added on 28-01-2022 by Gaurav(Quest team) 
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_RegistrationProfileResponse';
    
    /*Commented as part of EBR framework and implemented the logic with Flows
    public static void getProfileResponseValues(List<PRM_Registration_Request__c> regRequestListNew, Map<id, PRM_Registration_Request__c> oldregRequestMap){
      
        String params = '';
        
        try{
            for(PRM_Registration_Request__c rr : regRequestListNew){
            System.debug(' regRequest '+regRequestListNew);
            if(rr.PRM_Profile_Response__c != null && rr.PRM_Profile_Response__c!= ''){
                for(String s : rr.PRM_Profile_Response__c.split('}')){
                    String questionCode = s.substringAfter(Label.PRM_QuestionCode+' ').substringBefore(' '+Label.PRM_ResponseCode);
                    System.debug(' questionCode '+questionCode);
                    String answerCode =  s.substringAfter(Label.PRM_ResponseCode+' ').substringBefore(' '+Label.PRM_ResponseValue);
                    System.debug(' answerCode '+answerCode);
                    String responseValue = s.substringAfter(Label.PRM_ResponseValue+' ').substringBefore('}');
                    System.debug(' responseValue '+responseValue);
                    
                    if(questionCode == 'project_budget'){
                        rr.Project_Size__c = responseValue;
                        System.debug(' project_budget '+rr.Project_Size__c);
                    }
                    if(questionCode == 'project_desc'){
                        rr.Project_Description__c = responseValue;
                        System.debug(' project_desc '+rr.Project_Description__c);
                    }
                    if(questionCode == 'project_timeframe'){
                        rr.Project_Timeframe__c = responseValue;
                        System.debug(' Project_Timeframe__c '+rr.Project_Timeframe__c);
                    }
                   
                }
            }
        }
        } catch(Exception ex)
        {
            system.debug('Registration Profile Response type Exception: '+ex.getmessage());
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in ER_RegistrationProfileResponse', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
        
    }*/
}