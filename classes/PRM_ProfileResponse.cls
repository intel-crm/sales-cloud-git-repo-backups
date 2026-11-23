/**********************************************************************************************************************
Class Name    : PRM_ProfileResponse
Version       : 1.0
Created Date  : June 2019
Function      : Inserting profile response and registration profile response from 'PRM_Profile_Response__c' field of PRM_Registration_Request__c object

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------
* Rahul Kainth              11 June,2019            Inserting profile response and registration profile response from 
  Harshit											'PRM_Profile_Response__c' field of PRM_Registration_Request__c object

***********************************************************************************************************************/
public without sharing class PRM_ProfileResponse {
    
    /*
* @description      : Creation of profile response by comparing 'PRM_Profile_Response__c' field's value with profile question 
					  and profile answer table
* @name             : createResponse
* @param            : List<PRM_Registration_Request__c> regRequest - Getting registration request from PRM_CreateAccountAndRelatedRecords class
* @param            : List<Account> accList - Getting inserted account list from PRM_CreateAccountAndRelatedRecords class
* @param            : List<Contact> contList - Getting inserted contact list from PRM_CreateAccountAndRelatedRecords class
* @param			: Boolean flag - true if registration profile response is getting created
					  false - if profile response is getting created
* @throws exception : NONE
*/
    
    public static void createResponse(List<PRM_Registration_Request__c> regRequest,List<Account> accList,List<Contact> contList,Boolean flag){
        Map<String,PRM_Profile_Questions__c> profQuesMap = new Map<String,PRM_Profile_Questions__c>();
        Map<String,PRM_Profile_Answer__c> profAnsMap = new Map<String,PRM_Profile_Answer__c>();
        Set<String> ss = new Set<String>();
        Map<String,PRM_Profile_Responses__c> existingPRMap = new Map<String,PRM_Profile_Responses__c>();
        //check for duplicates
        if(accList != null && accList.size()>0)
        {
            for(PRM_Profile_Responses__c pr : [Select id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Answer_Id__c,PRM_Contact_Id__c from PRM_Profile_Responses__c where PRM_Account_Id__c =: accList[0].Id])
            {
                existingPRMap.put(String.valueOf(pr.PRM_Account_Id__c)+String.valueOf(pr.PRM_Profile_Questions_Id__c)+String.valueOf(pr.PRM_Profile_Answer_Id__c),pr);
            }
        }
        List<PRM_Profile_Responses__c> profResponseList = new List<PRM_Profile_Responses__c>();
        List<PRM_Registration_Profile_Response__c> listOfRegResponse = new List<PRM_Registration_Profile_Response__c>();
        for(PRM_Profile_Questions__c profQues : [Select Id,PRM_Question_Cd__c,PRM_Question_Type_Nm__c from PRM_Profile_Questions__c]){
            profQuesMap.put(profQues.PRM_Question_Cd__c,profQues);
            System.debug(' @ profQuesMap '+profQuesMap);
        }
        for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c]){
            profAnsMap.put(profAns.PRM_Answer_Cd__c,profAns);
            System.debug(' @ profAnsMap '+profAnsMap);
        }
        for(PRM_Registration_Request__c rr : regRequest){
            if(rr.PRM_Profile_Response__c != null && rr.PRM_Profile_Response__c!= ''){
                for(String s : rr.PRM_Profile_Response__c.split('}')){
                    Id questionId;
                    Id answerId;
                    String questionCode = s.substringAfter(Label.PRM_QuestionCode+' ').substringBefore(' '+Label.PRM_ResponseCode);
                    System.debug(' questionCode '+questionCode);
                    String answerCode =  s.substringAfter(Label.PRM_ResponseCode+' ').substringBefore(' '+Label.PRM_ResponseValue);
                    System.debug(' answerCode '+answerCode);
                    String responseValue = s.substringAfter(Label.PRM_ResponseValue+' ').substringBefore('}');
                    System.debug(' responseValue '+responseValue);
                    if(profQuesMap.containsKey(questionCode)){
                        questionId = profQuesMap.get(questionCode).Id;
                        System.debug(' questionId '+questionId);
                    }
                    if(profAnsMap.containsKey(answerCode)){
                        answerId = profAnsMap.get(answerCode).Id;
                        System.debug(' answerId '+answerId);
                    }
                    
                    //to create registration profile response 
                    if(flag){
                        System.debug('flag'+flag);
                        PRM_Registration_Profile_Response__c registrationResponse = new PRM_Registration_Profile_Response__c();
                        if(questionId != null){
                            registrationResponse.PRM_Profile_Question_Id__c = questionId;
                        }
                        if(answerId != null){
                            registrationResponse.PRM_Profile_Answer_Id__c = answerId;
                        }
                        if(rr.Id != null){
                            registrationResponse.PRM_Registration_Request_Id__c = rr.Id;
                        }
                        
                        registrationResponse.PRM_Response_Txt__c = responseValue;
                        listOfRegResponse.add(registrationResponse);
                        System.debug(' listOfRegResponse '+listOfRegResponse);
                    }
                    
                    //to create profile response
                    else{
                    PRM_Profile_Responses__c profResponse = new PRM_Profile_Responses__c();
                    if(questionId != null){
                        profResponse.PRM_Profile_Questions_Id__c = questionId;
                    }
                    if(answerId != null){
                        profResponse.PRM_Profile_Answer_Id__c = answerId;
                    }
                        
                    //profResponse.PRM_Response_Txt__c = responseValue;
                    if(contList.size() > 0){
                        profResponse.PRM_Contact_Id__c = contList[0].Id;
                    }
                    if(accList.size() > 0){
                        profResponse.PRM_Account_Id__c = accList[0].Id;
                        if(existingPRMap != null && existingPRMap.get(String.valueOf(profResponse.PRM_Account_Id__c)+String.valueOf(profResponse.PRM_Profile_Questions_Id__c)+String.valueOf(profResponse.PRM_Profile_Answer_Id__c)) != null){
                              profResponse = existingPRMap.get(String.valueOf(profResponse.PRM_Account_Id__c)+String.valueOf(profResponse.PRM_Profile_Questions_Id__c)+String.valueOf(profResponse.PRM_Profile_Answer_Id__c)) ;
                        } 
                        if(profQuesMap.keySet().contains(questionCode) && profQuesMap.get(questionCode).PRM_Question_Type_Nm__c != Label.PRM_TextArea){
                            if(profAnsMap.keySet().contains(answerCode)){
                                profResponse.PRM_Response_Txt__c = profAnsMap.get(answerCode).PRM_Answer_Display_Txt__c;
                            }
                        }
                        else {
                            profResponse.PRM_Response_Txt__c = responseValue;
                        }
                        profResponse.PRM_InActive_Ind__c = false;
                        profResponseList.add(profResponse);
                    }
                    System.debug('@@ profResponseList '+profResponseList);
                    }
                }
            }
        }
        if(profResponseList != null && profResponseList.size()>0){
            upsert profResponseList;
        }
        if(listOfRegResponse != null && listOfRegResponse.size()>0){
            insert listOfRegResponse;
        }
    }
}