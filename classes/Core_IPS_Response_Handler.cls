/***************************************************************************************************
Class Name          : Core_IPS_Response_Handler
Version             : 1.0 
Created Date        : 18 Dec 2017
Function            : This Class is a Handler class for trigger Core_IPS_ResponseTrigger on Core_IPS_Response__c object.
Input Parameters    : NA
Output Parameters   : NA
Description         : NA
Used in             : trigger Dispatcher class Core_IPS_Response_Dispatcher 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Yogesh Sharma               18/12/2017             Created  
* Aayushi Singhal             6/04/2018              Modified
* Ashutosh Bhardwaj           19/04/2018             Modified
* Amritesh                    04/25/2018            Modified - US104141
*Karthick                     15/06/2018            Modified - Defect fix DE40163,DE40160
****************************************************************************************************/       

public class Core_IPS_Response_Handler {
    
    /***************************************************************************************************
    Method Name         : updateEnvironmentDetailsOnCase
    Method Type         : void
    Version             : 1.0 
    Created Date        : 18 Dec 2017
    Function            : This method is used update the Response Detail on Case.
    Input Parameters    : trigger.new records
    Output Parameters   : NA
    Description         : This method is used update the Response Detail on Case.
    Used in             : trigger Dispatcher class Core_IPS_Response_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              18/12/2017              Created
    ****************************************************************************************************/       
    public static void updateEnvironmentDetailsOnCase(List<Core_IPS_Response__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateEnvDetailsOnCaseFromCoreResponse'))
            return;
        
        if(newList==null) return;	
        List<Case> lstCase=new List<Case>();
        Set<Id> setCaseId = new Set<Id>();
        for(Core_IPS_Response__c objResp : newList) {
            setCaseId.add(objResp.Core_IPS_Case__c);
        }
        //FLS check added-Venugopal
        if(Case.SObjectType.getDescribe().isAccessible()){
        lstCase = [SELECT Id,(SELECT Id,Core_IPS_Agent_Only__c,Core_IPS_Question__c,Core_IPS_Answer__c,Core_IPS_Question_Master__c,Core_IPS_Question_Master__r.Core_IPS_Datatype__c FROM Core_IPS_Responses__r WHERE Core_IPS_Question_Master__r.RecordType.DeveloperName='EDQ'),Core_Environment_Details__c , Core_IPS_External_Environment_Details__c,Asset.Product2.name FROM Case WHERE Id IN :setCaseId];
        }
        Map<Id,Map<Id,wrapResponse>> mapCaseId2QuestionResponse = new Map<Id,Map<Id,wrapResponse>>(); // holds the Case Id Key => Map of Question and Related responses
        if(lstCase!=null) {
            for(Case objCase : lstCase) {
                if(!mapCaseId2QuestionResponse.containsKey(objCase.Id)) {
                    mapCaseId2QuestionResponse.put(objCase.Id, new Map<Id,wrapResponse>());
                }
                for(Core_IPS_Response__c objResponse : objCase.Core_IPS_Responses__r) {     
                    if(!mapCaseId2QuestionResponse.get(objCase.Id).containsKey(objResponse.Core_IPS_Question_Master__c)) {
                        mapCaseId2QuestionResponse.get(objCase.Id).put(objResponse.Core_IPS_Question_Master__c, new wrapResponse());
                    } 
                    wrapResponse wResp = mapCaseId2QuestionResponse.get(objCase.Id).get(objResponse.Core_IPS_Question_Master__c);
                    wResp.Question = objResponse.Core_IPS_Question__c;
                    if(String.isNotBlank(wResp.Answer)) {
                        wResp.Answer += ';';
                    }
                    wResp.Answer += String.isBlank(objResponse.Core_IPS_Answer__c) ? '' : objResponse.Core_IPS_Answer__c;
                    wResp.isAgentOnly = objResponse.Core_IPS_Agent_Only__c;
                    mapCaseId2QuestionResponse.get(objCase.Id).put(objResponse.Core_IPS_Question_Master__c, wResp);
                }
            }
        }
        
        if(mapCaseId2QuestionResponse.size()>0) {
            List<Case> lstCase2Update = new List<Case>();
            
            for(Id caseId : mapCaseId2QuestionResponse.keySet()) {
                String strEnvDetails = '';
                String strEnvDetailsExternal = '';
                
                //construct JSON
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject(); 
                gen.writeFieldName(System.Label.Core_IPS_WriteFieldName);   
                gen.writeStartArray();
                /*Ashutosh - US 102781 - adding style "word-break : break-all" on Line 84,85to align big answers to be break in table*/
                strEnvDetails = '<table border="1" width="100%" style="white-space:pre-line;word-break : break-all;"><tr><th>Question</th><th>Response</th></tr>';
                strEnvDetailsExternal = '<table border="1" width="100%" style="white-space:pre-line;word-break : break-all;"><tr><th>Question</th><th>Response</th></tr>';
            
                for(Id quesId : mapCaseId2QuestionResponse.get(caseId).keySet()) {
                    String envDetailsQuestion = mapCaseId2QuestionResponse.get(caseId).get(quesId).Question;
                    String envDetailsAnswer = mapCaseId2QuestionResponse.get(caseId).get(quesId).Answer;
                    Boolean isAgentOnly = mapCaseId2QuestionResponse.get(caseId).get(quesId).isAgentOnly;
                    if(String.isBlank(envDetailsAnswer)){
                        envDetailsAnswer = '';
                    }
                    
                    //Added by karthick - defect fix :DE40163,DE40160
                    envDetailsQuestion = envDetailsQuestion.escapeHtml4();                    
                    envDetailsAnswer = envDetailsAnswer.escapeHtml4();
                    
                    
                    strEnvDetails += '<tr style="white-space:pre-line;"><td width="30%"><b>'+ envDetailsQuestion +'</b></td>'; 
                    strEnvDetails  += '<td width="50%" valign="middle" style="white-space:pre-line;">'+envDetailsAnswer+'</td>';
                    if(!isAgentOnly) {
                        strEnvDetailsExternal += '<tr style="white-space:pre-line;"><td width="30%"><b>'+ envDetailsQuestion +'</b></td>';
                        strEnvDetailsExternal += '<td width="50%" valign="middle" style="white-space:pre-line;">'+envDetailsAnswer+'</td>';
                        strEnvDetailsExternal +='</tr>';
                    }
                    strEnvDetails +='</tr>';
                    //strEnvDetailsExternal +='</tr>'; Commented by Karthick - Defect fix : DE40163,DE40160
                    gen.writeStartObject(); 
                    if(String.isNotBlank( envDetailsQuestion ))    
                        gen.writeStringField(System.Label.Core_IPS_WriteStringfield_Question, envDetailsQuestion);
                    if(String.isNotBlank( envDetailsAnswer ))
                        gen.writeStringField(System.Label.Core_IPS_WriteStringfield_Response, envDetailsAnswer);
                    gen.writeEndObject();
                }
                
                gen.writeEndArray();
                //end of the parent JSON object
                gen.writeEndObject();
                String jsonString = gen.getAsString();
                Case objCase = new Case(Id=caseId);
                /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Case.fields.Core_jsonfield__c.isUpdateable()) {
                objCase.Core_jsonfield__c = jsonString;
                }
                strEnvDetails += '</table>';
                strEnvDetailsExternal += '</table>';
               // if (Schema.sObjectType.Case.fields.Core_Environment_Details__c.isUpdateable()) {
                objCase.Core_Environment_Details__c = strEnvDetails;
                //}
                //if (Schema.sObjectType.Case.fields.Core_IPS_External_Environment_Details__c.isUpdateable()) {
                objCase.Core_IPS_External_Environment_Details__c = strEnvDetailsExternal;
                //}
                lstCase2Update.add(objCase);
            }
            if(lstCase2Update.size()>0) {
                Core_CaseTrigger_Dispatcher.backendPromotionRecursive = true;
                update lstCase2Update;
            }
        }
    }

    /***************************************************************************************************
    Method Name         : assignCoreResponseFields
    Method Type         : void
    Version             : 1.0 
    Created Date        : 18 Dec 2017
    Function            : This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object.
    Input Parameters    : trigger.new records
    Output Parameters   : NA
    Description         : This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object.
    Used in             : trigger Dispatcher class Core_IPS_Response_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              18/12/2017              Created
    ****************************************************************************************************/       
        
    public static void assignCoreResponseFields(List<Core_IPS_Response__c> newList) {
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignCoreResponseFieldsFromEDQ'))
            return;
            
        if(newList!=null) {
            Set<Id> setMasterAnswerId = new Set<Id>();
            for(Core_IPS_Response__c objResp : newList) { 
                if(String.isBlank(objResp.Core_IPS_Answer__c) && objResp.Core_IPS_Answer_Master__c!=null) {
                    setMasterAnswerId.add(objResp.Core_IPS_Answer_Master__c);
                } 
            }
            if(setMasterAnswerId.size()>0) {
                Map<Id,Core_IPS_Answer__c> mapMasterAnswer = new Map<Id,Core_IPS_Answer__c>([SELECT Id,Core_IPS_Answer__c FROM Core_IPS_Answer__c WHERE Id IN :setMasterAnswerId]);
                for(Core_IPS_Response__c objResp : newList) {
                    if(String.isBlank(objResp.Core_IPS_Answer__c) && objResp.Core_IPS_Answer_Master__c!=null && mapMasterAnswer.containsKey(objResp.Core_IPS_Answer_Master__c)) {
                        objResp.Core_IPS_Answer__c = mapMasterAnswer.get(objResp.Core_IPS_Answer_Master__c).Core_IPS_Answer__c;
                    } 
                }
            }
        }
    }
    
    public class wrapResponse {
        public String Question;
        public String Answer;
        public Boolean isAgentOnly;
        public wrapResponse() {
            Question = '';
            Answer = '';
            isAgentOnly = false; 
        }
    }

    /***************************************************************************************************
    Method Name         : updateEDQfilteringFieldOnCase
    Method Type         : void
    Version             : 1.0 
    Created Date        : 4 April 2018
    UserStory#          : US95468
    Function            : This method is used to add response to the EDQ filtering fields on the Case record.
    Input Parameters    : trigger.new records
    Output Parameters   : NA
    Description         : This method will populate the two EDQ filtering fields on Case with the Response Questions' Reporting Name
                          and the Response Answer text
    Used in             : trigger Dispatcher class Core_IPS_Response_Dispatcher
    Number of Queries Within this Method    : 
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi Singhal            04/04/2018               Created
    ****************************************************************************************************/ 
    public static void  updateEDQfilteringFieldOnCase(List<Core_IPS_Response__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateEDQfilteringFieldOnCase'))
            return;  
        try{
            Set<Id> caseIdList=new Set<Id>();
            List<Case> caseList=new List<Case>();
            if(newList!=null && newList.size()>0){
                for(Core_IPS_Response__c resp: newList){
                    caseIdList.add(resp.Core_IPS_Case__c);
                }
                if(caseIdList!=null && caseIdList.size()>0){
                    for(Id caseId: caseIdList){
                        Case cs=new Case(Id=caseId);
                        caseList.add(cs);
                    }
                    if(Limits.getQueueableJobs()<Limits.getLimitQueueableJobs())
                    ID jobID = System.enqueueJob(new Core_IPS_CaseUpdateQueueable(caseList,Core_IPS_CaseUpdateQueueable.Mode.EDQ));

            }
                              
               
                
            }
            
        }catch(Exception ex){  } 
        
    }

    /***************************************************************************************************
    Method Name         : updateSurveySubmitFieldOnCase
    Method Type         : void
    Version             : 1.0 
    Created Date        : 25 April 2018
    Description         : This method is used to update survey submit field in case
    Input Parameters    : trigger.new records
    Output Parameters   : NA    
    Used in             : trigger Dispatcher class Core_IPS_Response_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                  04/25/2018               Created - US104141
    ****************************************************************************************************/ 
    public static void  updateSurveySubmitFieldOnCase(List<Core_IPS_Response__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSurveySubmitFieldOnCase'))
            return;  
        
        try{
            if(newList==null || newList.size()==0) return;
                        
            Set<Id> setCaseId = new Set<Id>();
            List<Case> lstCase2Update = new List<Case>();
            //FLS check added-Venugopal
            if(Core_IPS_Response__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_Response__c resp : [SELECT Id,Core_IPS_Case__c FROM Core_IPS_Response__c WHERE Id IN :newList AND Core_IPS_Question_Master__r.RecordType.DeveloperName=:Core_IPS_Helper_Utility.getIPSLabel('CoreQuestionSurveyRT')]){                
                if(!setCaseId.contains(resp.Core_IPS_Case__c)) {
                    setCaseId.add(resp.Core_IPS_Case__c);
                    lstCase2Update.add(new Case(Id=resp.Core_IPS_Case__c, Core_IPS_Survey_Captured__c=true));
                }
            }
            }
            if(lstCase2Update.size()>0) update lstCase2Update;            
        }
            
        catch(Exception e){  
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_Response__c', 'Core_IPS_Response_Handler'); 
        }        
    }
}