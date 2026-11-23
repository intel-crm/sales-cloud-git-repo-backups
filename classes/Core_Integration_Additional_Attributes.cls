/******************************************************************************************************************************************
Class Name  : Core_Integration_Additional_Attributes
Version     : 1.0
Created Date: 13 May 2019
Function    : This class is used to set the eRPM accounts & Contacts optional attributes/fields into SalesForce. 

Following are the major functionlities handled in this class
Set the benefits, Legal Agreements & Profile Responses for a given account.
Set the subscriptions for a given contact.

// TODO :: REVISIT :: Naming Convention/Class Name ///
Modification Log :
* Developer                   Date                     Description
* ----------------------------------------------------------------------------
* eRPM-Team                  13/05/2019                Original version
*****************************************************************************************************************************************/

public class Core_Integration_Additional_Attributes implements Queueable {    
    private Id accountId, contactId;
    private string programCode;
    private string changeAgentId;
    private List<Core_IntegrationUtility.eRPM_Profile_Response> profileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
    private List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAccountRelations =  new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
    private List<Core_IntegrationUtility.eRPM_Subscription> subscriptions = new List<Core_IntegrationUtility.eRPM_Subscription>();
    private List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAccountRelEnt = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
    private List<Core_IntegrationUtility.ERPM_Person_Account> personAccount = new List<Core_IntegrationUtility.ERPM_Person_Account>();
    
    public static final String LOG_ENTRY_ORIGIN = 'eRPM-SFDC Integration';
    public static final String LOG_ENTRY_PROJECT = 'Core_Integration_Additional_Attributes';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
    public Core_Integration_Additional_Attributes(Id eRPM_Account_No, Id eRPM_Contact_Id, string eRPM_Program_Code,
                                                  List<Core_IntegrationUtility.eRPM_Profile_Response> eRPM_ProfileResponses,
                                                  List<Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPM_PersonAccountRelations,
                                                  List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions,
                                                  List<Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPM_PersonAccountRelEnt,
                                                  string change_Agent_Id,List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccount) {
                                                      accountId = eRPM_Account_No;
                                                      contactId = eRPM_Contact_Id;
                                                      programCode = eRPM_Program_Code;
                                                      profileResponses = eRPM_ProfileResponses;
                                                      personAccountRelations=eRPM_PersonAccountRelations;
                                                      subscriptions=eRPM_Subscriptions;
                                                      personAccountRelEnt=eRPM_PersonAccountRelEnt; 
                                                      changeAgentId = string.isNotBlank(change_Agent_Id) ? change_Agent_Id :'eRPM';
                                                      personAccount= eRPM_PersonAccount;
                                                      system.debug('RelationshipQueue const personAccountRelations '+personAccountRelations);
                                                      system.debug('Person account-->'+personAccount);
                                                  }
    
    public void execute(QueueableContext context) { 
        System.debug('Queue Inside execute');
        if(profileResponses != null && profileResponses.size() >0){SetProfileResponses(profileResponses);
                                                                  }
        System.debug('RelationshipQueue before if '+personAccountRelations);
        if(personAccountRelations != null && personAccountRelations.size() >0) {
            system.debug(' RelationshipQueue personAccountRelations inside if '+personAccountRelations);
            SetPersonAccountRelationships(personAccountRelations);
        }
        System.debug('subscriptionsQueue before if '+personAccountRelations);
        if(subscriptions != null && subscriptions.size() >0) {
            System.debug('subscriptionsQueue inside if '+personAccountRelations);
            SetSubscriptions(subscriptions);
        }
        if(personAccount != null && personAccount.size() >0)
            SetContactEntitlements(personAccount);        
    }
    
    public boolean SetProfileResponses(List<Core_IntegrationUtility.eRPM_Profile_Response> eRPM_ProfileResponses){   
        try{
            if(string.isBlank(accountId) || string.isBlank(programCode) || (eRPM_ProfileResponses == null || eRPM_ProfileResponses.size() == 0))
                throw new CustomException('--SetProfileResponses-- accountId/Program Code/eRPM_ProfileResponses is/are null or empty--');           
            
            //Get the eRPM Question Answer codes Mapping List from GetQuestionAnswersMapList method by passing eRPM_ProfileResponses
            //Get the eRPM Question Answer Ids Mapping List from GetQuestionReponseIdsMapList method by passing Question Codes & Response Codes Mapping               
            //Get the list of profile responses for the given account.        
            List<PRM_Profile_Responses__c> accountProfileResponses = GetAccountProfileResponses(eRPM_ProfileResponses);
            String errorMessages = '';
            system.debug('accountProfileResponses ::: Before Upsert ::: ' + accountProfileResponses);
            //Do DML Operations           
            if(accountProfileResponses !=null && accountProfileResponses.size() >0){                
                List<Database.UpsertResult> result = Database.upsert(accountProfileResponses,false);
                for (Database.UpsertResult sr : result) {
                    if (!sr.isSuccess()) {                        
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {errorMessages += 'Error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' fields that affected this error: ' + err.getFields()+'- ';                             
                                                                 }
                        throw new CustomException(errorMessages);
                    }                   
                }   
                system.debug('--SetProfileResponses Success--');                              
                return true; 
            }
            else {
                return false; 
            }      
            
        }        
        catch(Exception ex) {
            system.debug('Exception :: SetProfileResponses - '+ex.getMessage());
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, '', LOG_ENTRY_ERROR,
                                                 'Error in SetProfileResponses method', '', '', 'PRM_Profile_Responses__c', '', ex);
            return false;
        }
        
    }    
    
    public boolean SetPersonAccountRelationships(List<Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPM_PersonAccountRelations){
        try{
            system.debug('Relationship enter main method');
            if(string.isBlank(accountId) || string.isBlank(programCode) || (eRPM_PersonAccountRelations ==null || eRPM_PersonAccountRelations.size() == 0))
                throw new CustomException('--SetPersonAccountRelationships-- accountId/Program Code/eRPM_PersonAccountRelations is/are null or empty--');
            
            //Get the list of person account relationship association by passing eRPM person account relationships to Insert/Update into SF
            List<PRM_Account_Contact_Relationship__c> personAccountRelationships = GetPersonAccountRelationships(eRPM_PersonAccountRelations);            
            String errorMessages = '';
            
            system.debug('******** personAccountRelationships Before Upsert::: ********' + personAccountRelationships);
            //Do DML Operations
            if(personAccountRelationships !=null && personAccountRelationships.size() >0){                
                List<Database.UpsertResult> result = Database.upsert(personAccountRelationships,false);
                for (Database.UpsertResult sr : result) {
                    if (!sr.isSuccess()) {                        
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {errorMessages += 'Error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' fields that affected this error: ' + err.getFields()+'- ';                             
                                                                 }
                        throw new CustomException(errorMessages);
                    }                   
                }   
                system.debug('--SetPersonAccountRelationships Success--');                 
                return true; 
            }
            else {return false; 
                 }            
        }        
        catch(Exception ex) {
            system.debug('Exception :: SetPersonAccountRelationships - '+ex.getMessage());
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, '', LOG_ENTRY_ERROR,
                                                 'Error in SetPersonAccountRelationships method', '', '', 'PRM_Account_Contact_Relationship__c', '', ex);
            return false;
        }    
    }
    
    public boolean SetSubscriptions(List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions){
        try{
            if(string.isBlank(contactId) || (eRPM_Subscriptions == null || eRPM_Subscriptions.size() == 0))
                throw new CustomException('SetSubscriptions-- contactId/eRPM_Subscriptions is/are null or empty');
            
            //Get the List of Contact subcriptions from eRPM payload       
            List<PRM_ContactSubscriptionAssociation__c> contactSubscriptions = GetSubscriptions(eRPM_Subscriptions);
            String errorMessages = '';
            
            
            //Do DML Operations
            if(contactSubscriptions !=null && contactSubscriptions.size() >0){
                List<Database.UpsertResult> result = Database.upsert(contactSubscriptions,false);
                for (Database.UpsertResult sr : result) {
                    if (!sr.isSuccess()) {                        
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errorMessages += 'Error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' fields that affected this error: ' + err.getFields()+'- ';                             
                        }
                        throw new CustomException(errorMessages);
                    }                   
                }   
                system.debug('--SetSubscriptions Success--');   
                return true; 
            }            
            else {return false; 
                 }            
        } 
        catch(Exception ex) {
            system.debug('Exception :: SetSubscription - '+ex.getMessage());
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, '', LOG_ENTRY_ERROR,
                                                 'Error in SetSubscription method', '', '', 'PRM_ContactSubscriptionAssociation__c', '', ex);
            return false;
        }    
    }
    
    public boolean SetContactEntitlements(List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccount){
        //Team Ruby Changed parameter of method from List<Core_IntegrationUtility.ERPM_Person_Account_Relation> to List<Core_IntegrationUtility.ERPM_Person_Account>
        List<Core_Contact_Entitlement__c> contactEntitlements;
        String errorMessages;
        try{
            if(string.isBlank(contactId) || (eRPM_PersonAccount ==null || eRPM_PersonAccount.size() == 0))
                throw new CustomException('--SetContactEntitlements-- contactId/Program Code/eRPM_PersonAccount is/are null or empty--');
            
            /* Team Ruby Changes - Start*/
            //Get the list of contact entitlements by passing eRPM person account relationships to Insert/Update into SF
            //Assigning entitlements when contact is not partner user and if it is partner user it's license should be 'Partner Community'.
            User UserObj;
            Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Partner Community')]);
            for(User comUser: [select id,IsActive,profileId from user where IsActive = true AND ContactId =:contactId]) {UserObj = comUser;
                                                                                                                        }
            System.debug('UserObj-->'+UserObj);
            //Assigning entitlements when contact is partner user and if it is partner user it's license is 'Partner Community'.
            if(UserObj != null && profileIds.containsKey(UserObj.profileId)){contactEntitlements = GetContactEntitlements(eRPM_PersonAccount);            
                                                                             errorMessages = '';
                                                                            }
            //Assigning entitlements when contact is not partner user.
            else if(UserObj == null){
                contactEntitlements = GetContactEntitlements(eRPM_PersonAccount);            
                errorMessages = '';
            }
            else{ 
                System.debug(' do nothing');
                // do nothing
            }
            /* Team Ruby Changes - End*/
            //system.debug('******** contactEntitlements Before Upsert::: ********' + contactEntitlements);
            //Do DML Operations
            if(contactEntitlements !=null && contactEntitlements.size() >0){                
                List<Database.UpsertResult> result = Database.upsert(contactEntitlements,false);
                for (Database.UpsertResult sr : result){
                    if (!sr.isSuccess()){                        
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()){errorMessages += 'Error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' fields that affected this error: ' + err.getFields()+'- ';                             
                                                                }
                        throw new CustomException(errorMessages);
                    }                   
                }   
                system.debug('--contactEntitlements Success--');                 
                return true; 
            }
            else{
                return false; 
            }            
        }        
        catch(Exception ex) {
            system.debug('Exception :: SetContactEntitlements - '+ex.getMessage());
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, '', LOG_ENTRY_ERROR,'Error in SetContactEntitlements method', '', '', 'Core_Contact_Entitlement__c', '', ex);
            return false;
        }        
    }
    public boolean IsProgramCodeValid(){      
        return database.countQuery('SELECT COUNT() from ChannelProgram WHERE PRM_programCode__c =: programCode') >0 ;             
    }
    
    private List<PRM_Profile_Responses__c> GetAccountProfileResponses(List<Core_IntegrationUtility.eRPM_Profile_Response> eRPM_ProfileResponses){  
        List<PRM_Profile_Responses__c> accountProfileResponses = new List<PRM_Profile_Responses__c>(); 
        
        try{            
            Map<string, List<string>> questionAnswersMapList =  new Map<string, List<string>>();
            Map<string, List<Core_IntegrationUtility.eRPM_Profile_Response>> questionAnswersMapListObject =  new Map<string, List<Core_IntegrationUtility.eRPM_Profile_Response>>();
            for(Core_IntegrationUtility.eRPM_Profile_Response response : eRPM_ProfileResponses){           
                if (!questionAnswersMapList.containsKey(response.eRPM_QuestionCode)) {                
                    questionAnswersMapList.put(response.eRPM_QuestionCode, new List<String>{response.eRPM_ResponseCode});
                    questionAnswersMapListObject.put(response.eRPM_QuestionCode, new List<Core_IntegrationUtility.eRPM_Profile_Response>{response});
                }
                else {          
                    questionAnswersMapList.get(response.eRPM_QuestionCode).add(response.eRPM_ResponseCode);
                    questionAnswersMapListObject.get(response.eRPM_QuestionCode).add(response);
                }
            }
            
            //get the response codes (values) from question answer map list
            List<string> responsesCodes = new List<string>();           
            for (List<String> response : questionAnswersMapList.values())
                responsesCodes.addAll(response);
            system.debug('---- Response Codes ---- :: '+ responsesCodes);
            system.debug('---- eRPM Question Codes ---- :: '+ questionAnswersMapList.Keyset());
            
            Map<Id, List<Id>> questionAnswerIdsMap = new Map<Id, List<Id>>();
            Map<Id, string> questionIdCodeMap = new Map<Id, String>();
            Map<Id, string> questionIdCodeListMap = new Map<Id, String>();
            Map<Id, string> answerIdCodeMap = new Map<Id, String>();
            //List<PRM_Profile_Answer__c> existingPAs = [SELECT Id, PRM_Answer_Cd__c, PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c 
            //                                           FROM PRM_Profile_Answer__c 
            //                                           WHERE PRM_Answer_Cd__c IN : responsesCodes];
            //system.debug('---- existingPAs ---- :: '+ existingPAs);
            //system.debug('---- existingPAs size ---- :: '+ existingPAs.size());            
            //system.debug('----- existingPAs[0] + PRM_Answer_Cd__c  ------' + existingPAs[0].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + existingPAs[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
            //system.debug('----- existingPAs[1] + PRM_Answer_Cd__c  ------' + existingPAs[1].PRM_Answer_Cd__c + ' :: PRM_Profile_Questions_Id__r.PRM_Question_Cd__c :: ' + existingPAs[1].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);                        
            Map<string,PRM_Profile_Answer__c> existingProfileAnswerMap = new Map<string,PRM_Profile_Answer__c>();
            //GET the list of Response Id, Response code, Question Id & Question Code from Profile Answer     
            for(PRM_Profile_Answer__c PPA :  [SELECT Id, PRM_Answer_Cd__c, PRM_Profile_Questions_Id__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c 
                                              FROM PRM_Profile_Answer__c 
                                              WHERE PRM_Answer_Cd__c IN : responsesCodes
                                              AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c IN : questionAnswersMapList.keySet() ]) {
                                                  //Map the eRPM question Code with Salesforce Question Id
                                                  questionIdCodeMap.put(PPA.PRM_Profile_Questions_Id__c, PPA.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
                                                  answerIdCodeMap.put(PPA.Id, PPA.PRM_Answer_Cd__c);
                                                  system.debug('---PPA.PRM_Question_Cd__c --- ' + PPA.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
                                                  system.debug('---PPA.PRM_Answer_Cd__c --- ' + PPA.PRM_Answer_Cd__c);
                                                  
                                                  existingProfileAnswerMap.put(String.valueOf(PPA.ID)+String.valueOf(PPA.PRM_Profile_Questions_Id__c), PPA);
                                                  
                                                  if(questionAnswersMapList.get(PPA.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c).contains(PPA.PRM_Answer_Cd__c)) {
                                                      //GET the list of Response Id, Response code, Question Id & Question Code from Profile Answer
                                                      if(!questionAnswerIdsMap.containsKey(PPA.PRM_Profile_Questions_Id__c)) {                                                      
                                                          questionAnswerIdsMap.put(PPA.PRM_Profile_Questions_Id__c, new List<Id> { PPA.Id });                                                      
                                                      }
                                                      else {                                        
                                                          questionAnswerIdsMap.get(PPA.PRM_Profile_Questions_Id__c).add(PPA.Id);                                                      
                                                      }                                                  
                                                  }
                                              }
            //Validate the profile Question/Response/s, if user pass some invalid Question/Response Code/s
            //TODO :: REVISIT :: Throw an exception or WRITE logs  
            //Commented the below code as per the code review comments          
            //if(questionAnswerIdsMap.size() != questionAnswersMapList.size()) {
            //throw new CustomException('Invalid Profile Question/Answer Code/s!');
            //}                      
            system.debug('------ questionAnswerIdsMap ----:: === >> ' + questionAnswerIdsMap);            
            system.debug('------ questionAnswerIdsMap.size() ----:: === >> ' + questionAnswerIdsMap.size());
            system.debug('------ existingProfileAnswerMap ----:: === >> ' + existingProfileAnswerMap);            
            system.debug('------ existingProfileAnswerMap.size() ----:: === >> ' + existingProfileAnswerMap.size());
            
            if(questionAnswerIdsMap.size() ==0){throw new CustomException('questionAnswerIdsMap null or empty');
                                               }
            
            //get the response Ids (values) from question answer map list
            List<Id> responsesIds = new List<Id>();             
            for (List<Id> response : questionAnswerIdsMap.values()){            
                responsesIds.addAll(response);
            }
            //Get the existing profile Responses with right combination. 
            Map<String, PRM_Profile_Responses__c> existingPRMap = new Map<String, PRM_Profile_Responses__c>();
            Map<Id, List<Id>> existingAcctProfileResponses = new Map<Id, List<Id>>();       
            //GET the list of Profile Responses        
            for(PRM_Profile_Responses__c profileResponse : [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c, PRM_InActive_Ind__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: accountId 
                                                            AND PRM_Profile_Questions_Id__c IN : questionAnswerIdsMap.keySet()]) {
                                                                //AND PRM_Profile_Answer_Id__c IN : responsesIds]) {                                                                
                                                                existingPRMap.put(String.valueOf(profileResponse.PRM_Account_Id__c)+String.valueOf(profileResponse.PRM_Profile_Questions_Id__c)+String.valueOf(profileResponse.PRM_Profile_Answer_Id__c), profileResponse);
                                                                //system.debug('------ Existing Profile Response Map-----::' + existingPRMap.KeySet());                                                              
                                                                //Don't do anything if changes are done from Salescloud
                                                                if(changeAgentId != 'SalesCloud'){
                                                                    if((profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c == Label.PRM_TextArea || profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c == 'Text')){                                                                                                
                                                                        for(Core_IntegrationUtility.eRPM_Profile_Response eProfResp : questionAnswersMapListObject.get(profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c)){                                                                        
                                                                            if((profileResponse.PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c == eProfResp.eRPM_ResponseCode) && (string.isNotBlank(eProfResp.eRPM_ResponseText) && (profileResponse.PRM_Response_Txt__c != eProfResp.eRPM_ResponseText))){profileResponse.PRM_Response_Txt__c = eProfResp.eRPM_ResponseText;                                                                           
                                                                                                                                                                                                                                                                                                       accountProfileResponses.add(profileResponse);
                                                                                                                                                                                                                                                                                                       break;
                                                                                                                                                                                                                                                                                                      }                                                                                                                                               
                                                                        }
                                                                    }
                                                                    else{
                                                                        //TODO :: REVISIT :: Don't update anyting for the picklist/multiSelect Picklist/Boolean value. 
                                                                        if((profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c == 'Picklist') || (profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c == 'Boolean')){
                                                                            system.debug('----- Existing profile question type either Picklist/Boolean ---');
                                                                            system.debug('---- questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c) ----- ' + questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c));
                                                                            if(!questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c).contains(profileResponse.PRM_Profile_Answer_Id__c)){
                                                                                system.debug('----- InSide questionAnswerIdsMap Existing profile question type either Picklist/Boolean ---');
                                                                                
                                                                                List<Id> AnswerIds = questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c);
                                                                                system.debug('-------AnswerIds ---- ' + questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c) + ' -- AnswerIds [0]  :: ' + AnswerIds[0]);
                                                                                profileResponse.PRM_Profile_Answer_Id__c = AnswerIds[0];                                                                                
                                                                                accountProfileResponses.add(profileResponse);
                                                                            }
                                                                        }
                                                                        else if((profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c == 'Multiselect') || (profileResponse.PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c == 'Boolean')){
                                                                            system.debug('----- Existing profile question type Multiselect ---');
                                                                            system.debug('----- questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c) ----- ' + questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c));
                                                                            if(!questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c).contains(profileResponse.PRM_Profile_Answer_Id__c)){
                                                                                system.debug('----- InSide questionAnswerIdsMap Existing profile question type Multiselect ---');                                                                                
                                                                                //List<Id> AnswerIds = questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c);
                                                                                system.debug('-------AnswerIds ---- ' + questionAnswerIdsMap.get(profileResponse.PRM_Profile_Questions_Id__c));
                                                                                profileResponse.PRM_InActive_Ind__c = true;                                                                                
                                                                                accountProfileResponses.add(profileResponse);
                                                                            }
                                                                        }
                                                                        else
                                                                        {
                                                                            //TODO :: REVISIT :: Other than Multiselect ,Picklist, Boolean, Text Textarea
                                                                            //Later we will revisit. 
                                                                        }
                                                                    }
                                                                }                                                                
                                                            }
            
            system.debug('------ Existing Profile Response Map-----::' + existingPRMap);
            //add new profile questions & responses if given profiles are not associated with the given account
            //Get the profile questions & responses which are not present existingAccountBenefits                
            for(Id questionId : questionAnswerIdsMap.keySet()){           
                for(Id answrId : questionAnswerIdsMap.get(questionId)){               
                    if((existingAcctProfileResponses == null || existingAcctProfileResponses.size() == 0) || (!existingAcctProfileResponses.get(questionId).contains(answrId)))
                    {                        
                        boolean IsProfileResponseExists = false;
                        if((existingPRMap != null && existingPRMap.size() >0) && (existingPRMap.get(String.valueOf(accountId)+String.valueOf(questionId)+String.valueOf(answrId)) != null)){
                            IsProfileResponseExists = true;                            
                        }
                        system.debug('---- Multiple Responses Issue fix IsProfileResponseExists----- :: '+ IsProfileResponseExists);
                        //The below logic is just to get the response Code from the payload
                        string responseText = '';
                        for(Core_IntegrationUtility.eRPM_Profile_Response eProfResp : questionAnswersMapListObject.get(questionIdCodeMap.get(questionId))){
                            if(eProfResp.eRPM_ResponseCode == answerIdCodeMap.get(answrId)){
                                responseText = eProfResp.eRPM_ResponseText;
                                break;
                            }
                        }
                        if(!IsProfileResponseExists){
                            //Add new profile responses into the account profile responses list
                            accountProfileResponses.add(new PRM_Profile_Responses__c(
                                PRM_Account_Id__c = accountId,
                                PRM_Profile_Questions_Id__c = questionId,
                                PRM_Profile_Answer_Id__c = answrId,
                                PRM_Response_Txt__c = responseText,
                                PRM_InActive_Ind__c = false)); 
                        }
                    }
                }
            }                        
        }
        catch(Exception ex)
        {
            system.debug('Exception :: GetAccountProfileResponses- ' + ex.getMessage());
            throw new CustomException(ex);
        }
        system.debug('--End of GetAccountProfileResponses ---- :: ' + accountProfileResponses);
        system.debug('--End of GetAccountProfileResponses ---- :: ' + accountProfileResponses.size());
        return accountProfileResponses;
    }
    
    private List<PRM_ContactSubscriptionAssociation__c> GetSubscriptions(List<Core_IntegrationUtility.eRPM_Subscription> eRPM_Subscriptions){ 
        List<PRM_ContactSubscriptionAssociation__c> contactSubscriptions = new List<PRM_ContactSubscriptionAssociation__c>();
        try{
            Map<string, Core_IntegrationUtility.eRPM_Subscription> eRPMSubscriptionMap = new Map<string, Core_IntegrationUtility.eRPM_Subscription>();
            for(Core_IntegrationUtility.eRPM_Subscription subscription : eRPM_Subscriptions){
                eRPMSubscriptionMap.put(subscription.eRPM_SubscriptionCode, subscription);
            }
            
            //Get the List of Subscription Ids (key) from the eRPM subscription map
            Map<Id, string> partnerSubscriptionIds = new Map<Id, string>();
            for(PRM_Partner_Subscription__c prtnrsubs : [SELECT Id, PRM_Subscription_Cd__c  from PRM_Partner_Subscription__c 
                                                         WHERE PRM_Subscription_Cd__c IN : eRPMSubscriptionMap.KeySet()
                                                         AND PRM_InActive_Ind__c= false]){
                                                             partnerSubscriptionIds.put(prtnrsubs.Id, prtnrsubs.PRM_Subscription_Cd__c);
                                                         } 
            //Validate the Subscription, if user pass some invalid subscrition
            //TODO :: REVISIT :: Throw an exception or WRITE logs
            if(partnerSubscriptionIds.size() == 0) {
                throw new CustomException('Invalid Subcription/s!');
            }     
            
            //Get the existing Contact Subscriptions ID  to update some of the field values 
            Set<Id> existingContactSubscription = new Set<Id>();        
            //Get the existing Contact Subscription Associations to update some of the field values 
            for(PRM_ContactSubscriptionAssociation__c conctSubscription :
                [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                 WHERE PRM_Contact_Id__c =: contactId 
                 AND PRM_Partner_Subscription_Id__c IN :new set<Id>(partnerSubscriptionIds.KeySet())]) {
                     //Get the eRPM Subscriptions Inacitve reason Codes
                     Core_IntegrationUtility.eRPM_Subscription eRPMSubs = eRPMSubscriptionMap.get(conctSubscription.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
                     if(conctSubscription.PRM_Status_Nm__c != eRPMSubs.eRPM_SubscriptionStatusCode){
                         //TODO :: REVISIT :: YET TO DECIDE HOW TO APPROACH
                         conctSubscription.PRM_Status_Nm__c = eRPMSubs.eRPM_SubscriptionStatusCode;
                         conctSubscription.PRM_Status_Reason_Txt__c = eRPMSubs.eRPM_SubscriptionStatusCode;
                         contactSubscriptions.add(conctSubscription);
                         existingContactSubscription.add(conctSubscription.PRM_Partner_Subscription_Id__c);
                     }
                     else{
                         //Don't update anything if there any changes w.r.t the existing objects.
                         partnerSubscriptionIds.remove(conctSubscription.PRM_Partner_Subscription_Id__c);
                     }
                 }
            system.debug('Before Insert partnerSubscriptionIds :::: ' + partnerSubscriptionIds);
            //add new contact subscriptions associations if given partner subscriptions are not associated with the given contact
            //Get the partner subscriptons which are not present existingContactSubscription
            for(Id subsId : partnerSubscriptionIds.keySet()){
                if(!existingContactSubscription.contains(subsId)){
                    //Get the eRPM subscription status reason Code
                    Core_IntegrationUtility.eRPM_Subscription eRPMSubscription = eRPMSubscriptionMap.get(partnerSubscriptionIds.get(subsId));
                    contactSubscriptions.add(new PRM_ContactSubscriptionAssociation__c(                           
                        PRM_Contact_Id__c = contactId,
                        PRM_Partner_Subscription_Id__c = subsId,
                        //TODO :: REVISIT :: Yet to discuss for the inactive reason
                        PRM_Status_Nm__c = eRPMSubscription.eRPM_SubscriptionStatusCode,
                        PRM_Status_Reason_Txt__c = eRPMSubscription.eRPM_SubscriptionStatusCode)); 
                }
            }
            return contactSubscriptions; 
        }
        catch(Exception ex)
        {
            //TODO :: REVISIT:: WRITE LOG
            system.debug('Exception :: GetSubscriptions- ' + ex.getMessage());
            throw new CustomException(ex);
        }       
    }
    
    private List<PRM_Account_Contact_Relationship__c> GetPersonAccountRelationships(List<Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPM_PersonAccountRelations){
        
        List<PRM_Account_Contact_Relationship__c> accountContactRelationships = new List<PRM_Account_Contact_Relationship__c>();
        try{
            
            Map<string, string> eRPMSFRelationshipCodesMap = new Map<string,string>();
            system.debug('Label.PRM_Relationship: '+Label.PRM_Relationship+' - eRPM_PersonAccountRelations[0].engagementCode :' + eRPM_PersonAccountRelations[0].engagementCode);
            Set<string> enggCodes= new Set<string>();   
            
            for(ERPM_SF_MAPPING_SETTING__mdt esfr : [SELECT eRPM_KeyValue__c, SF_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                                     WHERE Mappting_Type__c =: Label.PRM_Relationship AND eRPM_EngagementCodes__c =: eRPM_PersonAccountRelations[0].engagementCode])  //eRPM_PersonAccountRelations[0].engagementCode])
            {
                eRPMSFRelationshipCodesMap.put(esfr.eRPM_KeyValue__c,esfr.SF_KeyValue__c);
            }
            system.debug('eRPMSFRelationshipCodesMap: '+eRPMSFRelationshipCodesMap);
            
            Map<string, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> eRPMAcctContReltnMap = new Map<string, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>>();
            for(Core_IntegrationUtility.ERPM_Person_Account_Relation relation : eRPM_PersonAccountRelations){
                
                if(!eRPMAcctContReltnMap.containsKey(eRPMSFRelationshipCodesMap.get(relation.relationCode)))
                    eRPMAcctContReltnMap.put(eRPMSFRelationshipCodesMap.get(relation.relationCode), new List<Core_IntegrationUtility.ERPM_Person_Account_Relation> { relation } );
                else
                    eRPMAcctContReltnMap.get(eRPMSFRelationshipCodesMap.get(relation.relationCode)).add(relation);
            }
            
            system.debug('eRPMAcctContReltnMap: '+eRPMAcctContReltnMap);
            
            //Get the List of Relationships Ids (key) from the eRPM relationship map
            Map<Id, string> relationshipIds = new Map<Id, string>();            
            for(PRM_ContactRelationships__c contReltn : [SELECT Id, PRM_Contact_Relationship_Cd__c from PRM_ContactRelationships__c 
                                                         WHERE PRM_Channel_Program_Id__r.PRM_programCode__c =: programCode
                                                         AND PRM_Contact_Relationship_Cd__c IN : eRPMAcctContReltnMap.KeySet()]){                                                           
                                                             relationshipIds.put(contReltn.Id, contReltn.PRM_Contact_Relationship_Cd__c);
                                                         }
            system.debug('******** relationshipIds ********** ' + relationshipIds);
            //Get the existing Account Contact Relationships ID's  to update some of the field values 
            Set<Id> existingAccountContactRelationships = new Set<Id>();        
            for(PRM_Account_Contact_Relationship__c contAcctReln : [SELECT Id, PRM_Relationship_Id__c, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c , 
                                                                    PRM_InActive_Ind__c, PRM_Status_Nm__c,PRM_No_Email__c,PRM_Status_Reason_Txt__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:accountId 
                                                                    AND PRM_Contact_Id__c =:contactId
                                                                    //AND PRM_Account_Channel_Membership_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c =: programCode
                                                                    AND PRM_Relationship_Id__c IN : relationshipIds.KeySet()]){   
                                                                        boolean IsOneRelationshipActive = false;
                                                                        //Get the eRPM person relation Inacitve Codes/reason
                                                                        //List<Core_IntegrationUtility.ERPM_Person_Account_Relation> relation = eRPMAcctContReltnMap.get(contAcctReln.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c); 
                                                                        for(Core_IntegrationUtility.ERPM_Person_Account_Relation reln: eRPMAcctContReltnMap.get(contAcctReln.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c)){
                                                                            if(!reln.inactiveIndicator){
                                                                                IsOneRelationshipActive = true;
                                                                                break;
                                                                            }
                                                                        }
                                                                        if((contAcctReln.PRM_InActive_Ind__c != !IsOneRelationshipActive || contAcctReln.PRM_Status_Nm__c != 'Complete')
                                                                           && changeAgentId != 'SalesCloud'){
                                                                            contAcctReln.PRM_Status_Nm__c = 'Complete';
                                                                            contAcctReln.PRM_Status_Reason_Txt__c ='Status set to Complete as part of Person Account Relationship';//TWC729-8089 : Adding reason text
                                                                            contAcctReln.PRM_No_Email__c = true;
                                                                            //contAcctReln.PRM_isActive__c = relation.inactiveIndicator;
                                                                            contAcctReln.PRM_InActive_Ind__c = !IsOneRelationshipActive;
                                                                            existingAccountContactRelationships.add(contAcctReln.PRM_Relationship_Id__c);
                                                                            accountContactRelationships.add(contAcctReln);
                                                                        }else{relationshipIds.remove(contAcctReln.PRM_Relationship_Id__c);
                                                                              //Don't update anything if there any changes w.r.t the existing objects.
                                                                             }
                                                                    }
            
            system.debug('existingAccountContactRelationships ::  --> '+ existingAccountContactRelationships);
            //Get the account channel membership 
            /* PRM_AccountChannelMembership__c ACM = [SELECT Id, PRM_Account_Channel_Program_Key__c, PRM_Channel_Program_Id__r.PRM_programCode__c 
FROM PRM_AccountChannelMembership__c 
WHERE PRM_Channel_Program_Id__r.PRM_programCode__c =:programCode AND PRM_Account_Id__c =:accountId LIMIT 1];

system.debug('PRM_AccountChannelMembership__c ::  --> '+ ACM);*/
            system.debug('Before Insert relationshipIds :::: ' + relationshipIds);
            
            //add new Account Contact Relationships if given relationship is not associated with the given account & contact
            //Get the relationships which is not present existingAccountContactRelationships
            for(Id reltnspId : relationshipIds.keySet()){
                if(!existingAccountContactRelationships.contains(reltnspId)){
                    accountContactRelationships.add(new PRM_Account_Contact_Relationship__c(                           
                        PRM_Account_Id__c = accountId,
                        PRM_Contact_Id__c = contactId,
                        PRM_Relationship_Id__c = reltnspId,
                        PRM_Status_Nm__c = 'Complete',
                        PRM_Status_Reason_Txt__c ='Added as part of Person Account Relationship',//TWC729-8089 : Adding reason text
                        PRM_No_Email__c = true,
                        //PRM_Partner_Role__c = partnerRole,
                        //PRM_Account_Channel_Membership_Id__c = (ACM != null && string.isNotBlank(ACM.Id)) ? ACM.Id : null,
                        //TODO :: REVISIT :: Yet to discuss for the inactive reason
                        //PRM_isActive__c = true
                        PRM_InActive_Ind__c = false
                        //PRM_Status_Reason_Txt__c = ''
                    ));
                }
            }
            
        }
        catch(Exception ex)
        {throw new CustomException(ex);
        }
        return accountContactRelationships;
    }       
    
    private List<Core_Contact_Entitlement__c> GetContactEntitlements(List<Core_IntegrationUtility.ERPM_Person_Account> eRPM_PersonAccount){
        //Team Ruby Changed parameter of method from List<Core_IntegrationUtility.ERPM_Person_Account_Relation> to List<Core_IntegrationUtility.ERPM_Person_Account>
        /*Team ruby changes - Start*/
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> personAccRel = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        List<Core_IntegrationUtility.ERPM_Engagement> personEngagement = new List<Core_IntegrationUtility.ERPM_Engagement>();
        //Fetching personAccountRelations and personAccountEngagements from PersonAccount
        for(Core_IntegrationUtility.ERPM_Person_Account acct : eRPM_PersonAccount){
            for (Core_IntegrationUtility.ERPM_Engagement engg : acct.personAccountEngagements) {
                if(engg.engagementCode == system.label.ERPM_EngagementCode && engg.effectiveTierCode != system.label.ERPM_EffectiveTierCode){
                    personEngagement.add(engg);
                }
            }
            for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                if(ePAR.engagementCode == system.label.ERPM_EngagementCode){
                    personAccRel.add(ePAR);
                }
            }
        }
        /*Team ruby changes - end*/
        //Create a instance for Contact entitlements
        List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
        boolean worksForRelation = false;
        
        //Get the eRPM Account Contact Relationships
        Map<string, Core_IntegrationUtility.ERPM_Person_Account_Relation> eRPMAcctContReltnMap = new Map<string, Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        Map<string, Core_IntegrationUtility.ERPM_Person_Account_Relation> activeERPMAcctContReltnMap = new Map<string, Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        for(Core_IntegrationUtility.ERPM_Person_Account_Relation relation : personAccRel){
            /*Team ruby changes - Start*/
            if(relation.engagementCode == system.label.ERPM_EngagementCode){ // fetching only those person account relation where engagement code is ISA.
                eRPMAcctContReltnMap.put(relation.relationCode, relation);
                if(relation.relationName == system.label.PRM_Default_Relation){// Checking if there is any WorkFor Relation present in payload.
                    worksForRelation = true;
                }
                if(relation.inactiveIndicator == false){ //Checking active person account relation from the payload.
                    activeERPMAcctContReltnMap.put(relation.relationCode, relation);
                }
            }
            /*Team ruby changes - end*/
        }
        system.debug('eRPMAcctContReltnMap: '+eRPMAcctContReltnMap);
        system.debug('activeERPMAcctContReltnMap: '+activeERPMAcctContReltnMap);
        
        
        //Get the MP entitlements for the given relationships from the custom metadata types. 
        Map<string, string> eRPMSFRelationshipsEnttitlementsMap = new Map<string, string>();
        Map<string, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> entitlementRelationshipsMap = new Map<string, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>>();
        Map<string, string> activeERPMSFRelationshipsEnttitlementsMap = new Map<string, string>();
        Map<string, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> activeEntitlementRelationshipsMap = new Map<string, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>>();
        system.debug('Label.PRM_Relationship: '+Label.PRM_Relationship+' - personAccRel[0].engagementCode :' + personAccRel[0].engagementCode);
        // Fetching entitlements from custom metadata for all Person Account Relationship - Existing
        for(ERPM_SF_MAPPING_SETTING__mdt mapptingSetting : [SELECT eRPM_KeyValue__c, SF_KeyValue__c,Entitlement_Rank__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE Mappting_Type__c =: Label.PRM_eRPM_Relationship_Entitlement AND eRPM_EngagementCodes__c ='ISA' AND eRPM_KeyValue__c IN : eRPMAcctContReltnMap.KeySet() ORDER BY SF_KeyValue__c])
        {
            eRPMSFRelationshipsEnttitlementsMap.put(mapptingSetting.SF_KeyValue__c, mapptingSetting.eRPM_KeyValue__c);
            //This is to get the eRPM relationships based on SF entitlements
            if(!entitlementRelationshipsMap.containsKey(mapptingSetting.SF_KeyValue__c)){   
                entitlementRelationshipsMap.put(mapptingSetting.SF_KeyValue__c, new List<Core_IntegrationUtility.ERPM_Person_Account_Relation> { eRPMAcctContReltnMap.get(mapptingSetting.eRPM_KeyValue__c) });
            }
            else{                                        
                entitlementRelationshipsMap.get(mapptingSetting.SF_KeyValue__c).add(eRPMAcctContReltnMap.get(mapptingSetting.eRPM_KeyValue__c));                                                      
            }  
            //entitlementRelationshipsMap.put(mapptingSetting.SF_KeyValue__c, eRPMAcctContReltnMap.get(mapptingSetting.eRPM_KeyValue__c));
            system.debug('entitlementRelationshipsMap: '+entitlementRelationshipsMap);
        }
        /*Team ruby changes - start*/
        // Fetching entitlements from custom metadata for active Person Account Relationship
        for(ERPM_SF_MAPPING_SETTING__mdt mapptingSetting : [SELECT eRPM_KeyValue__c, SF_KeyValue__c,Entitlement_Rank__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE Mappting_Type__c =: Label.PRM_eRPM_Relationship_Entitlement AND eRPM_EngagementCodes__c = 'ISA' AND eRPM_KeyValue__c IN : activeERPMAcctContReltnMap.KeySet() ORDER BY SF_KeyValue__c])
        {
            activeERPMSFRelationshipsEnttitlementsMap.put(mapptingSetting.SF_KeyValue__c, mapptingSetting.eRPM_KeyValue__c);
            //This is to get the eRPM relationships based on SF entitlements
            if(!activeEntitlementRelationshipsMap.containsKey(mapptingSetting.SF_KeyValue__c)){   
                activeEntitlementRelationshipsMap.put(mapptingSetting.SF_KeyValue__c, new List<Core_IntegrationUtility.ERPM_Person_Account_Relation> { activeERPMAcctContReltnMap.get(mapptingSetting.eRPM_KeyValue__c) });
            }
            else{                                        
                activeEntitlementRelationshipsMap.get(mapptingSetting.SF_KeyValue__c).add(activeERPMAcctContReltnMap.get(mapptingSetting.eRPM_KeyValue__c));                                                      
            }  
            system.debug('activeEntitlementRelationshipsMap: '+activeEntitlementRelationshipsMap);
        }
        
        //Validate the entitlements which is being mapped to the contact relationship -- This step can be removed if not needed. 
        // List<Core_Entitlement__c> entitlements = [SELECT ID FROM Core_Entitlement__c WHERE name IN : eRPMSFRelationshipsEnttitlementsMap.values()];
        //if(entitlements !=null && (entitlements.size() <> eRPMSFRelationshipsEnttitlementsMap.values().size())){
        //Some of the entitlements are missing //Just log it
        
        // }
        // Add/Update the contact entitlement only for ISA -as per the configuration
        // If we want to extend this feature to other engagment simply add the custom metadata types for other engagements
        //List<Core_IntegrationUtility.ERPM_Person_Account_Relation> erpmPersonAccRel = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        
        Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> entitlementIdRelationshipsMap = new Map<Id, List<Core_IntegrationUtility.ERPM_Person_Account_Relation>>();
        
        //mapping existing entitlements so that we can do operation on all the entitlements of type 'ISA' existing on contact.
        for(Core_Entitlement__c ent :[SELECT Id,Name FROM Core_Entitlement__c WHERE Name IN : entitlementRelationshipsMap.KeySet()]){
            if(entitlementRelationshipsMap.get(ent.Name) != null && !entitlementRelationshipsMap.get(ent.Name).IsEmpty()){
                entitlementIdRelationshipsMap.put(ent.Id,entitlementRelationshipsMap.get(ent.Name));
            }
        }
        System.debug('entitlementIdRelationshipsMap-->'+entitlementIdRelationshipsMap);
        if(entitlementRelationshipsMap.size() == 0)return contactEntitlements;
        if(activeEntitlementRelationshipsMap.size() == 0){return contactEntitlements;
                                                         }
        set<string> uniqueEntitlements = new set<string>();
        set<string> activeUniqueEntitlements = new set<string>();
        //Fetching all Entitlements - Existing
        for(string entitlement : entitlementRelationshipsMap.KeySet()){
            uniqueEntitlements.add(entitlement);
        }
        //Fetching Entitlements only when Person Account Relationship is active - Existing
        for(string entitlement : activeEntitlementRelationshipsMap.KeySet()){
            activeUniqueEntitlements.add(entitlement);
        }
        system.debug('-------- uniqueEntitlements: --------- '+uniqueEntitlements);
        system.debug('-------- activeUniqueEntitlements: --------- '+activeUniqueEntitlements);
        Set<Id> entitlementIds = new Set<Id>();
        Set<Id> activeEntitlementIds = new Set<Id>();
        set<Id> finalEntitlementIds = new set<Id>();
        List<String> entitlementName = new List<String>();
        Map<String,Decimal> entitlementRankMap = new Map<String,Decimal>();
        Map<String,Id> entMap = new Map<String,Id>();
        String defaultWorksForEntitlements;
        List<Id> entitIdUpdateToInactive = new List<Id>();
        for(Core_Entitlement__c entitlemnt : [SELECT Id,Name FROM Core_Entitlement__c WHERE Name IN : uniqueEntitlements]){            entitlementIds.add(entitlemnt.ID);
                                                                                                                          }
        for(Core_Entitlement__c entitlemnt : [SELECT Id,Name FROM Core_Entitlement__c WHERE Name IN : activeUniqueEntitlements]){       activeEntitlementIds.add(entitlemnt.ID);
                                                                                                                                 entitlementName.add(entitlemnt.Name);
                                                                                                                                 entMap.put(entitlemnt.Name,entitlemnt.Id);
                                                                                                                                }
        System.debug('entitlementName-->'+entitlementName);
        System.debug('entitlementIds-->'+entitlementIds);
        System.debug('activeEntitlementIds-->'+activeEntitlementIds);
        System.debug('entMap-->'+entMap);
        
        //Adding default entitlements.
        if(worksForRelation){
            for(Core_Entitlement__c ent :[SELECT Id,Name FROM Core_Entitlement__c WHERE Name =:system.label.ERPM_DefaultRelation]){entitlementIds.add(ent.Id);
                activeEntitlementIds.add(ent.Id);
            }
        }
        system.debug('******** entitlementIds ********** ' + entitlementIds);
        system.debug('******** activeEntitlementIds ********** ' + activeEntitlementIds);
        
        //Return null, if there is no entitlements matching entitlement in the system.
        if(entitlementIds.size() == 0)
            return contactEntitlements;
        
        if(activeEntitlementIds.size() == 0){return contactEntitlements;
        }
        
        //Fetching list of all the existing contact entitlements on the contact.
        List<Core_Contact_Entitlement__c> existingCE = new List<Core_Contact_Entitlement__c>();
        existingCE = [SELECT Id, Core_Entitlement_Id__r.Name, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Selected__c, Core_Status__c,Core_From_Source__c,Core_Type__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: contactId AND Core_From_Source__c = false AND Core_Type__c =:system.label.ERPM_Core_Type];
        System.debug('existingCE-->'+existingCE);
        
        List<Id>allExistingEntId = new List<Id>();
        List<Id>entId = new List<Id>();
        List<Id>totalEntId = new List<Id>();
        List<String> entName = new List<String>();
        List<String> existingEntitlementName = new List<String>();
        Map<String,Decimal> existingentRankMap = new Map<String,Decimal>();
        List<Core_Contact_Entitlement__c> finalExistingCE = new List<Core_Contact_Entitlement__c>();
        //Fetching list of all the existing entitlements from all the contact entitlements on the contact.
        if(existingCE != null && !existingCE.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :existingCE){
                allExistingEntId.add(ce.Core_Entitlement_Id__c);
            }
        }
        System.debug('allExistingEntId-->'+allExistingEntId);
        //Fetching list of all the existing entitlements in the custom map for engagementcode as 'ISA'.
        for(ERPM_SF_MAPPING_SETTING__mdt mapptingSetting : [SELECT eRPM_KeyValue__c, SF_KeyValue__c,Entitlement_Rank__c,eRPM_EngagementCodes__c FROM ERPM_SF_MAPPING_SETTING__mdt Where eRPM_EngagementCodes__c =:system.label.ERPM_EngagementCode])
        {
            existingEntitlementName.add(mapptingSetting.SF_KeyValue__c);
        }
        System.debug('existingEntitlementName-->'+existingEntitlementName);
        //Fetch entitlements id from contact entitlements where engagement code is 'ISA'
        if(existingEntitlementName != null && !existingEntitlementName.IsEmpty()){
            for(Core_Entitlement__c ent :[SELECT Id,Name FROM Core_Entitlement__c WHERE Name IN :existingEntitlementName]){
                totalEntId.add(ent.Id);
            }
        }
        System.debug('totalEntId-->'+totalEntId);
        //Comparing entitlements and fetching only those entitlements where engagement code is 'ISA'
        if((allExistingEntId != null && !allExistingEntId.IsEmpty()) && (totalEntId != null && !totalEntId.IsEmpty())){
            for(Id existingEntitlement :allExistingEntId){
                if(totalEntId.contains(existingEntitlement)){
                    entId.add(existingEntitlement);
                }
            }
        }
        System.debug('entId-->'+entId);
        //Fetch final list of existing contact entitlements from entitlements where engagement code is 'ISA'
        if(entId != null && !entId.IsEmpty()){
            finalExistingCE = [SELECT Id, Core_Entitlement_Id__r.Name, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Selected__c, Core_Status__c,Core_From_Source__c,Core_Type__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: contactId AND Core_Entitlement_Id__c IN :entId AND Core_From_Source__c = false AND Core_Type__c =:system.label.ERPM_Core_Type];
            System.debug('finalExistingCE-->'+finalExistingCE);
        }
        //Fetch entitlements name entitlements from final list of existing entitlements.
        if(entId != null && !entId.IsEmpty()){
            for(Core_Entitlement__c ent :[SELECT Id,Name FROM Core_Entitlement__c WHERE Id IN :entId]){
                entName.add(ent.Name);
            }
        }
        System.debug('entName-->'+entName);
        //MappingFetch entitlements name and rank final list of existing entitlements.
        if(entName != null && !entName.IsEmpty()){
            for(ERPM_SF_MAPPING_SETTING__mdt mappingSetting : [SELECT eRPM_KeyValue__c, SF_KeyValue__c,Entitlement_Rank__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE SF_KeyValue__c IN :entName])
            {
                existingentRankMap.put(mappingSetting.SF_KeyValue__c , mappingSetting.Entitlement_Rank__c);
            }
        }
        System.debug('existingentRankMap-->'+existingentRankMap);
        //Mapping entitlements with rank
        if(entitlementName != null && !entitlementName.IsEmpty()){
            for(ERPM_SF_MAPPING_SETTING__mdt mappingSetting : [SELECT eRPM_KeyValue__c, SF_KeyValue__c,Entitlement_Rank__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE SF_KeyValue__c IN :entitlementName])
            {
                entitlementRankMap.put(mappingSetting.SF_KeyValue__c , mappingSetting.Entitlement_Rank__c);
            }
        }
        system.debug('entitlementRankMap-->' + entitlementRankMap);
        Map<Id,Decimal> entitlementIdRankMap = new Map<Id,Decimal>();
        for(Core_Entitlement__c ent :[SELECT Id,Name FROM Core_Entitlement__c WHERE Name IN :existingentRankMap.KeySet()]){
            entitlementIdRankMap.put(ent.Id,existingentRankMap.get(ent.Name));
        }
        system.debug('entitlementIdRankMap-->' + entitlementIdRankMap);
        Decimal maxRank = entitlementRankMap.get(entitlementName[0]);
        
        //Checking for highest rank.
        for(integer i=1; i<entitlementName.size(); i++){
            Decimal tempRank = entitlementRankMap.get(entitlementName[i]); 
            if(tempRank <= maxRank){
                maxRank = tempRank;
            }
        }
        //Adding entitlements with highest rank in a list. 
        for(integer i=0; i<entitlementName.size(); i++){
            Decimal tempRank = entitlementRankMap.get(entitlementName[i]);
            if(tempRank == maxRank){
                finalEntitlementIds.add(entMap.get(entitlementName[i]));
            }
        }
        //Insert default entitlement when it doesn't present in the existing entitlements list.
        if(worksForRelation){
            for(Core_Entitlement__c ent :[SELECT Id,Name FROM Core_Entitlement__c WHERE Name =:system.label.ERPM_DefaultRelation]){
                if(!allExistingEntId.contains(ent.Id)){finalEntitlementIds.add(ent.Id);
                }
            }
        }
        system.debug('finalEntitlementIds-->' + finalEntitlementIds);
        //Get the existing Contact entitlement ID's  to update some of the field values 
        Set<Id> existingContactEntitlements = new Set<Id>();
        String UPDATE_REASON_ISA_FLOW = 'ISA Registration';
        //Doing update operation on existing contact entitlemnts.
        for(Core_Contact_Entitlement__c contEntitlemnt :finalExistingCE)
        { 
            //Decimal maxRankExistingCE = entitlementIdRankMap.get(finalExistingCE[0].Core_Entitlement_Id__c);
            Decimal tempRankExistingCE = entitlementIdRankMap.get(contEntitlemnt.Core_Entitlement_Id__c);
            boolean IsOneRelationshipActive = false;
            //Get the eRPM account person relationship Inacitve Codes/reason
            System.debug('entitlementIdRelationshipsMap-->'+entitlementIdRelationshipsMap);
            if(entitlementIds.Contains(contEntitlemnt.Core_Entitlement_Id__c)){
                for(Core_IntegrationUtility.ERPM_Person_Account_Relation reln: entitlementIdRelationshipsMap.get(contEntitlemnt.Core_Entitlement_Id__c)){
                    if(entitlementIdRelationshipsMap.get(contEntitlemnt.Core_Entitlement_Id__c) != null && !entitlementIdRelationshipsMap.get(contEntitlemnt.Core_Entitlement_Id__c).IsEmpty()){
                        System.debug('reln.inactiveIndicator-->'+reln.inactiveIndicator);
                        System.debug('personEngagement-->'+personEngagement);
                        if(!reln.inactiveIndicator && personEngagement!= null && !personEngagement.IsEmpty()){IsOneRelationshipActive = true;
                            break;
                        }
                    }
                }
            }
            System.debug('IsOneRelationshipActive-->'+IsOneRelationshipActive);
            //Updating default entitlements.
            if(contEntitlemnt.Core_Entitlement_Id__r.Name == system.label.ERPM_DefaultRelation && contEntitlemnt.Core_Selected__c !=
               IsOneRelationshipActive){
                    contEntitlemnt.Core_Status__c = system.label.PRM_Status_Pending;
                    contEntitlemnt.Core_Data_Loaded__c = true;
                    contEntitlemnt.Core_DontNotify__c = false;
                    contEntitlemnt.Core_Selected__c = IsOneRelationshipActive;
                    existingContactEntitlements.add(contEntitlemnt.Core_Entitlement_Id__c);
                   if(!contactEntitlements.contains(contEntitlemnt)){contactEntitlements.add(contEntitlemnt);
                                                                    }
               }
               System.debug('contactEntitlements-->'+contactEntitlements);
            //Keep the contact entitlement intact
            //System.debug('maxRankExistingCE-->'+maxRankExistingCE);
            System.debug('tempRankExistingCE-->'+tempRankExistingCE);
            //Updating entitlements based on rank.
            if(tempRankExistingCE == maxRank){
                //contEntitlemnt.Core_Status__c = acctContactReltn.inactiveIndicator;
                System.debug('contEntitlemnt.Core_Selected__c-->'+contEntitlemnt.Core_Selected__c);
                System.debug('IsOneRelationshipActive-->'+IsOneRelationshipActive);
                if(contEntitlemnt.Core_Selected__c != IsOneRelationshipActive){
                    contEntitlemnt.Core_Status__c = system.label.PRM_Status_Pending;
                    contEntitlemnt.Core_Data_Loaded__c = true;
                    contEntitlemnt.Core_DontNotify__c = false;
                    contEntitlemnt.Core_Selected__c = IsOneRelationshipActive;
                    existingContactEntitlements.add(contEntitlemnt.Core_Entitlement_Id__c);
                    if(!contactEntitlements.contains(contEntitlemnt)){contactEntitlements.add(contEntitlemnt);
                                                                     }
                }
                else{finalEntitlementIds.remove(contEntitlemnt.Core_Entitlement_Id__c);
                    }
            }
            else{
                //Updating entitlements based on rank.
                if(contEntitlemnt.Core_Entitlement_Id__r.Name != system.label.ERPM_DefaultRelation && contEntitlemnt.Core_Selected__c == true){
                    contEntitlemnt.Core_Status__c = system.label.PRM_Status_Pending;
                    contEntitlemnt.Core_Data_Loaded__c = true;
                    contEntitlemnt.Core_DontNotify__c = false;
                    contEntitlemnt.Core_Selected__c = false;
                    existingContactEntitlements.add(contEntitlemnt.Core_Entitlement_Id__c);
                    if(!contactEntitlements.contains(contEntitlemnt)){
                        contactEntitlements.add(contEntitlemnt);
                    }
                }
                //Updating default entitlements.
                if(!worksForRelation && contEntitlemnt.Core_Entitlement_Id__r.Name == system.label.ERPM_DefaultRelation && contEntitlemnt.Core_Selected__c == true){
                    contEntitlemnt.Core_Status__c = system.label.PRM_Status_Pending;
                    contEntitlemnt.Core_Data_Loaded__c = true;
                    contEntitlemnt.Core_DontNotify__c = false;
                    contEntitlemnt.Core_Selected__c = false;
                    existingContactEntitlements.add(contEntitlemnt.Core_Entitlement_Id__c);
                    if(!contactEntitlements.contains(contEntitlemnt)){
                        contactEntitlements.add(contEntitlemnt);
                    }
                    System.debug('When no WorksFor relation in payload-->'+contEntitlemnt.Core_Selected__c);
                }
                system.debug('--Inside Loop -- ELSE Part.Core_Selected__c  -- ++ ' + contEntitlemnt.Core_Selected__c);
                //Don't update anything if there any changes w.r.t the existing objects.
                //finalEntitlementIds.remove(contEntitlemnt.Core_Entitlement_Id__c);
            }
        }
        //add new Contact entitlemtns if given entitlement is not associated to the contact
        //Get the entitlement which is not present existingContactEntitlements
        if(finalEntitlementIds !=null && !finalEntitlementIds.IsEmpty()){
            for(Id entitleId : finalEntitlementIds){
                if(!existingContactEntitlements.contains(entitleId)){                    
                    contactEntitlements.add(new Core_Contact_Entitlement__c(
                        Core_Contact_Id__c = contactId,
                        Core_Entitlement_Id__c = entitleId,                       
                        Core_Status__c = system.label.PRM_Status_Pending,
                        Core_Data_Loaded__c = true,
                        Core_DontNotify__c = false,
                        Core_Selected__c = true, //eRPM - Relationship inactiveIndicator = false; 
                        Core_Source__c = UPDATE_REASON_ISA_FLOW//Added for US539488:to Identify origin of Entitlement creation
                    ));
                }
            }
        }
        system.debug('contactEntitlements ::  --> '+ contactEntitlements);
        return contactEntitlements;
    }   
}