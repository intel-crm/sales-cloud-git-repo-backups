/***************************************************************************************************************************************
Apex Class Name     : PRM_RegistrationProfileResponse 
Version             : 1.0
Created Date        : July 2019
Function            : To highlight answers given by users in a lightning component

Modification Log    :
* Developer                 Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Harshit                   29-07-2019                    Comparing inserted registration profile response with master data and 
Rahul													  returning selected answers through wrapper class
*************************************************************************************************************************************/

public class PRM_RegistrationProfileResponse {
    @AuraEnabled
    public static List<QuesAnsWrapper> displayResponse(String recordId){
        System.debug(' recordId '+recordId);
        List<PRM_Registration_Profile_Response__c> regResponseList = new List<PRM_Registration_Profile_Response__c>();
        Map<String,PRM_Profile_Questions__c> profQuesMap = new Map<String,PRM_Profile_Questions__c>();
        Map<PRM_Profile_Questions__c,Set<PRM_Profile_Answer__c>> profQuesAnsMap = new Map<PRM_Profile_Questions__c,Set<PRM_Profile_Answer__c>>();
        QuesAnsWrapper questionAnswerWrapper = new QuesAnsWrapper();
        List<QuesAnsWrapper> wrapList = new List<QuesAnsWrapper>();
        Set<PRM_Profile_Answer__c> setofResponseAnswer = new Set<PRM_Profile_Answer__c>();
        Set<String> setOfAnswer = new Set<String>();
        
        String instanceId = [Select ProcessInstanceId from ProcessInstanceWorkitem where Id =: recordId].ProcessInstanceId;
        String targetObjectId = [Select TargetObjectId from ProcessInstance where Id =: instanceId].TargetObjectId;
       //get partner role for record id.
       String recordPartnerRole=[SELECT PRM_Partner_Role__c FROM PRM_Registration_Request__c where Id=: targetObjectId].PRM_Partner_Role__c;
        //to get the master data
        for(PRM_Profile_Questions__c profQues : [Select Id,PRM_Question_Type_Nm__c,PRM_Question_Display_Txt__c from PRM_Profile_Questions__c where PRM_Partner_Role__c INCLUDES (:recordPartnerRole)]){
            profQuesMap.put(profQues.Id, profQues);
            System.debug(' @ profQuesMap '+profQuesMap);
        }
        if(profQuesMap.size()>0)
        {
        for(PRM_Profile_Answer__c profAns : [Select Id,Name,PRM_Profile_Questions_Id__c,PRM_Answer_Display_Txt__c, 
                                             PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c
                                             from PRM_Profile_Answer__c where PRM_Profile_Questions_Id__c IN: profQuesMap.keySet()]){
                                                 system.debug('@@@'+profAns.PRM_Profile_Questions_Id__r);    
                                                 if(profQuesAnsMap.keySet().contains(profAns.PRM_Profile_Questions_Id__r)){
                                                     profQuesAnsMap.get(profAns.PRM_Profile_Questions_Id__r).add(profAns);
                                                 }
                                                 else {
                                                     Set<PRM_Profile_Answer__c> answerSet = new Set<PRM_Profile_Answer__c>();
                                                     answerSet.add(profAns);
                                                     profQuesAnsMap.put(profAns.PRM_Profile_Questions_Id__r,answerSet);
                                                 }
                                             }
        
        //to get the user selected answers
        regResponseList = [Select Id,Name,PRM_Profile_Answer_Id__c,PRM_Response_Txt__c,PRM_Profile_Question_Id__c,PRM_Registration_Request_Id__c,
                           PRM_Profile_Answer_Id__r.PRM_Profile_Questions_Id__c,PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c,PRM_Profile_Question_Id__r.PRM_Question_Display_Txt__c,
                           PRM_Profile_Question_Id__r.PRM_Question_Type_Nm__c from PRM_Registration_Profile_Response__c 
                           where PRM_Registration_Request_Id__c=:targetObjectId];
        
        if(regResponseList != null && regResponseList.size()>0){
            for(PRM_Registration_Profile_Response__c resp : regResponseList){
                System.debug('resp.PRM_Profile_Question_Id__r.PRM_Question_Type_Nm__c '+resp.PRM_Profile_Question_Id__r.PRM_Question_Type_Nm__c);
                System.debug('resp.PRM_Profile_Answer_Id__r'+resp.PRM_Profile_Answer_Id__r);
                if(resp.PRM_Profile_Question_Id__r.PRM_Question_Type_Nm__c == System.Label.PRM_TextArea &&
                   String.isBlank(resp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c)){
                       resp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c = resp.PRM_Response_Txt__c;
                   }
                if(resp.PRM_Profile_Answer_Id__r != null){
                    //selected Answers
                    setofResponseAnswer.add(resp.PRM_Profile_Answer_Id__r);
                    
                }
                if(profQuesAnsMap.containsKey(resp.PRM_Profile_Question_Id__r)){
                    System.debug('SET'+profQuesAnsMap.get(resp.PRM_Profile_Question_Id__r));
                    //master data answers
                    setOfAnswer.add(resp.PRM_Profile_Answer_Id__r.PRM_Answer_Display_Txt__c);
                }
            }
        }
        System.debug('setofResponseAnswer'+setofResponseAnswer);
        
        System.debug('setOfAnswer'+setOfAnswer);
        
        Map<PRM_Profile_Questions__c,Set<PRM_Profile_Answer__c>> qaMap = new Map<PRM_Profile_Questions__c,Set<PRM_Profile_Answer__c>>();
        
        if(setofResponseAnswer != null && setofResponseAnswer.size()>0){
            for(PRM_Profile_Answer__c ansResponse :setofResponseAnswer ){
                if(setOfAnswer != null && setOfAnswer.size()>0 && ansResponse.PRM_Answer_Display_Txt__c != null
                   && ansResponse.PRM_Answer_Display_Txt__c != ''){
                       if(setOfAnswer.contains(ansResponse.PRM_Answer_Display_Txt__c)){
                           System.debug('ansResponse.PRM_Answer_Display_Txt__c'+ansResponse.PRM_Answer_Display_Txt__c);
                           System.debug(' ansResponse '+ansResponse);
                           if(qaMap.keySet().contains(profQuesMap.get(ansResponse.PRM_Profile_Questions_Id__c))){
                               qaMap.get(profQuesMap.get(ansResponse.PRM_Profile_Questions_Id__c)).add(ansResponse);
                           }
                           else {
                               Set<PRM_Profile_Answer__c> answerSet = new Set<PRM_Profile_Answer__c>();
                               answerSet.add(ansResponse);
                               qaMap.put(profQuesMap.get(ansResponse.PRM_Profile_Questions_Id__c),answerSet);
                           }
                       }
                   }
            }
        }
        System.debug('qaMap'+qaMap);
        
        Map<String,List<String>> listQuesAns = new Map<String,List<String>>();
        for(PRM_Profile_Questions__c q: profQuesAnsMap.keySet()){
            QuesAnsWrapper qw = new QuesAnsWrapper();
            qw.q = q;
            qw.listofans.addAll(profQuesAnsMap.get(q));
            if(qaMap.keySet().contains(q)){
                qw.selectedResults.addAll(qaMap.get(q));
            }
            wrapList.add(qw);
        }
        System.debug(' profQuesAnsMap '+profQuesAnsMap);
        }
        return wrapList;
    }
    
    @AuraEnabled
    public static retriggerEVWrap retriggerEv(String recordId,Boolean isFromContact){
        retriggerEVWrap retriggerWrap = new retriggerEVWrap();
        Map<String,String> langLocaleMap = new Map<String,String>();
        PRM_CIM_Request__mdt evDetails=[Select Id, API_Key__c from PRM_CIM_Request__mdt where MasterLabel='EVTrigger'];
        String statusResp;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String enterpriseId;
        String reqEnterpriseId;
        String emailAddr;
        String contLangCode;
        String responseDet;
        PRM_Registration_Request__c regReq = new PRM_Registration_Request__c();
        Contact contDet = new Contact();
        // Fetch the prefeered langauge codes
        for(PRM_LanguageLocaleMapping__mdt	localeResults : [Select Id,PRM_Preferred_Language_Name__c,PRM_Preferred_Language_Code__c,
                                                             PRM_Preferred_Locale_Code__c from PRM_LanguageLocaleMapping__mdt]){
                                                                 if(localeResults != null){
                                                                     langLocaleMap.put(localeResults.PRM_Preferred_Language_Code__c,localeResults.PRM_Preferred_Locale_Code__c);
                                                                 }
                                                             }        
        if(isFromContact == false){
             PRM_Registration_Request__c evRegReq = new PRM_Registration_Request__c();
            try
            {
            evRegReq=[Select id,PRM_Enterprise_ID__c,PRM_Preferred_Language__c,PRM_Email_ID__c,RecordTypeId from PRM_Registration_Request__c where id =:recordId LIMIT 1];
            }
            catch(System.QueryException e){}
             if(evRegReq!=null && (evRegReq.get('RecordTypeId') == Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByName().get('Email Verification Request').getRecordTypeId()))
             {
                 regReq = evRegReq;
             }
           else
             
            {
            
            String instanceId = [Select ProcessInstanceId from ProcessInstanceWorkitem where Id =: recordId].ProcessInstanceId;
            String targetObjectId = [Select TargetObjectId from ProcessInstance where Id =: instanceId].TargetObjectId;
            
            regReq = [Select id,PRM_Enterprise_ID__c,PRM_Preferred_Language__c,PRM_Email_ID__c from PRM_Registration_Request__c where id =:targetObjectId];
            }
           /* else
            {
              regReq=  [Select id,PRM_Enterprise_ID__c,PRM_Preferred_Language__c,PRM_Email_ID__c,RecordTypeId from PRM_Registration_Request__c where id =:recordId];
                
            }*/
            emailAddr=regReq.PRM_Email_ID__c;
               
            
            if(regReq.PRM_Enterprise_ID__c != null && regReq.PRM_Enterprise_ID__c!=' ' &&
               regReq.PRM_Preferred_Language__c != null && regReq.PRM_Preferred_Language__c !=''){
                   if(langLocaleMap != null && langLocaleMap.containsKey(regReq.PRM_Preferred_Language__c)){
                       enterpriseId = '/'+regReq.PRM_Enterprise_ID__c+'/'+langLocaleMap.get(regReq.PRM_Preferred_Language__c);
                       System.debug('enterpriseId'+enterpriseId);
                       reqEnterpriseId = regReq.PRM_Enterprise_ID__c;
                   }
                   //enterpriseId = '/'+regReq.PRM_Enterprise_ID__c+'/'+'en_US';
               }
        }
        
    else
    {
        
            //Schema.DescribeFieldResult fieldResult = Contact.Core_Preferred_Language__c.getDescribe().getPicklistValues();
            contDet=[select id,Core_Preferred_Language__c,Core_Enterprise_Id__c,Email from Contact where id =:recordId];
            if (contDet.Core_Preferred_Language__c!=null && contDet.Core_Enterprise_Id__c!=null && contDet.Core_Enterprise_Id__c!=' '){
                contLangCode=langLocaleMap.get(contDet.Core_Preferred_Language__c);
                enterpriseId = '/'+contDet.Core_Enterprise_Id__c+'/'+contLangCode;
                reqEnterpriseId = contDet.Core_Enterprise_Id__c;
            }
            
            emailAddr=contDet.Email;
      
            //system.debug('Preferred Language -->'+ fieldResult.getValue('contDet.Core_Preferred_Language__c'));
    }
        //String enterpriseId = '/'+regReq.PRM_Enterprise_ID__c;
        
        try{
            system.debug('request -->'+request);
            retriggerWrap.reqEnterpriseId = reqEnterpriseId;
            if (enterpriseId!= null & enterpriseId!= ' ' && reqEnterpriseId!=null && reqEnterpriseId!=' '){
                request.setHeader('Content-Type','application/json');
                request.setHeader('API_KEY', evDetails.API_Key__c);
                request.setTimeout(Integer.valueOf(System.Label.PRM_RetriggerEV_Timeout));
                request.setEndpoint('callout:PRM_EVTrigger'+enterpriseId);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                responseDet = response.getBody();
            }
            system.debug('Response --> '+responseDet);
            if (responseDet !=null){
                retriggerWrap.response=responseDet;
                
            }
            else{
                retriggerWrap.response=null;
            }
            retriggerWrap.email=emailAddr;
            
            //throw new CIMException('System.CalloutException');
        }
        
        catch (Exception e){
            retriggerWrap.response=null;
            retriggerWrap.email=emailAddr;
            PRM_ErrorUtilityClass.logError(e);
            
        }
        return retriggerWrap; 
    }
    
    public class retriggerEVWrap{
        @AuraEnabled
        public String response;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String reqEnterpriseId;
    }
    
    public class QuesAnsWrapper {
        
        @AuraEnabled
        public PRM_Profile_Questions__c q = new PRM_Profile_Questions__c();
        @AuraEnabled
        public List<PRM_Profile_Answer__c> listofans = new List<PRM_Profile_Answer__c>();
        @AuraEnabled
        public List<PRM_Profile_Answer__c> selectedResults = new List<PRM_Profile_Answer__c>();
        
    }
}