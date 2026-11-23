/****************************************************************************************************************************************                               
* Class Name        : Core_MDF_FeedbackController                             
* Created Date      : 02/22/2023                                
* Modification Log                              
* Developer            Date               Description                               
* ---------------------------------------------------------------------------------------------------------------------------------------                               
* Khushi         03/15/2023         Class to save survey feedback from users                             
* Ayush          02/12/2024         Reminder POP up for survey response every month/quarter
* Ayush          06/03/2024         Add user's account and Program Name for the survey's provided
*****************************************************************************************************************************************/

public with sharing class Core_MDF_FeedbackController {
    
    public static Map<String,String> questionIdMap= new Map<String,String>();
    public static List<string> languages = (Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE).split(',');
    
    
    @AuraEnabled
    public static List<SurveyDetailsWrapper> fetchRecords(){
        List<SurveyDetailsWrapper> questionList = new List<SurveyDetailsWrapper>();
        
        try{
            fetchSurveyQuestions surveyques = new fetchSurveyQuestions();
            questionList = surveyques.getSurveyQuestions();
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
        return questionList;
    }
    
    
    
    @AuraEnabled
    public static Core_MDF_Survey__c submitScoreAction(SurveyWrapper surveyMap){
        
        Integer COMMENT_FIELD_LIMIT = Core_MDF_CCP_ConstantClass.COMMENT_FIELD_LIMIT; 
        Core_MDF_Survey__c surveyObj = new Core_MDF_Survey__c();
        try {
            
            String currentPageInfo = ''; 
            
            if(surveyMap.pageRef.contains('recordId') && !surveyMap.pageRef.contains('objectApiName')){
                pageReferenceWrapper pageWrap = (pageReferenceWrapper) JSON.deserialize(surveyMap.pageRef,pageReferenceWrapper.class); 
                
                id recId = pageWrap.recordId;
                String sObjName = recId.getSObjectType().getDescribe().getName();
                pageWrap.objectApiName = sObjName;
                currentPageInfo = JSON.serialize(pageWrap);
            }
            else{
                currentPageInfo = surveyMap.pageRef;
            }
            
            /* Set<String> programSet = new Set<String>(); 
Id ultimateAccountId;
List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>(); 
Id userId = UserInfo.getUserId();
User userRecord = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId]; //query to get loggedin user's Account

if(userId != null){
fetchSurveyQuestions pnumRecord = new fetchSurveyQuestions();
pnumList = pnumRecord.fetchPNUMRecords(); //calling fetchPNUMRecords method to get the logged in user's PNUM
system.debug('@@pnumList ->'+pnumList);
}

if(pnumList != null && !pnumList.isEmpty()){
for(Core_MDF_Partner_Node_User_Mapping__c pnumRec : pnumList){
programSet.add(pnumRec.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c); //adding programs fetched from PNUM query in programset
ultimateAccountId = pnumRec.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c; //adding Account Id's fetched from PNUM query in ultimateAccountSet
system.debug('@@ultimateAccountId PNUM ->'+ultimateAccountId);
}
}
else{ //if PNUM records does not exist fetch account from user's contact's Account and program from external PGMs for the particular user's account 
if(userRecord.Contact.AccountId != null){
fetchSurveyQuestions pgmRecord = new fetchSurveyQuestions();
pgmList = pgmRecord.fetchPGMRecords(userRecord.Contact.AccountId);
system.debug('@@pgmList ->'+pgmList);
if(pgmList != null && !pgmList.isEmpty()){
for(Core_MDF_Partner_Group_Mapping__c pgmRec : pgmList){
programSet.add(pgmRec.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c); //adding programs fetched from PGM query in programset 
ultimateAccountId = userRecord.Contact.AccountId; //adding Account Id's fetched from PGM querry
system.debug('@@ultimateAccountId PGM ->'+ultimateAccountId);
}
}
}
}*/
            
            Set<String> programSet = new Set<String>(); 
            Id ultimateAccountId;
            Id userAccountId;
            List<SurveyResponseWrapper> surveyResponseWrapperList = new List<SurveyResponseWrapper>();
            surveyResponseWrapperList = getUserAccountAndProgram();
            
            for(SurveyResponseWrapper responseWrapper : surveyResponseWrapperList){
                programSet = responseWrapper.programSet;
                ultimateAccountId = responseWrapper.ultimateAccountId;
                userAccountId = responseWrapper.userAccountId;
            }
            
            //List<String> programList = new List<String>(programSet);
            //List<Id> ultimateAccountList = new List<Id>(ultimateAccountSet);
            
            DateTime dtm=System.now();
            surveyObj.Core_MDF_Survey_CapturedOn_Page_txt__c = currentPageInfo;
            surveyObj.Core_MDF_Submitted_By_id__c=UserInfo.getUserId();
            surveyObj.Core_MDF_Submitted_On_dtm__c=dtm;
            
            //Insufficient access exception fix - begin
            Id accountToStamp = userAccountId;

            if (ultimateAccountId != null) {
                if (ultimateAccountId == userAccountId) {
                    accountToStamp = ultimateAccountId;
                } else {
                    // Query to check if the running user has Read access to the Ultimate Account
                    List<Account> accessibleUltimateAccount = [
                        SELECT Id 
                        FROM Account 
                        WHERE Id = :ultimateAccountId 
                        LIMIT 1
                    ];
                    
                    if (!accessibleUltimateAccount.isEmpty()) {
                        accountToStamp = ultimateAccountId;
                    }
                }
            }
            
            surveyObj.Core_MDF_User_Account__c = accountToStamp;
            //Insufficient access exception fix - end

            surveyObj.Core_MDF_User_Program_nm__c = !programSet.isEmpty() ? String.join(programSet, ';') : ''; 
            insert surveyObj;
            
            List<Core_MDF_Survey_Response__c> surveyResponseList= new List<Core_MDF_Survey_Response__c>();
            // Highlight: Unused Local Variable - 14285
            // List<String> surveQuestionList= new List<String> ();
            for(SurveyDetailsWrapper surveyResult : surveyMap.SurveyDetailsWrapperList){
                String questionId;
                // Highlight: Unused Local Variable - 14285
                // String questionLabel;
                String rating;
                if(surveyResult.questionId != ''){
                    Core_MDF_Survey_Response__c responseData= new Core_MDF_Survey_Response__c();
                    responseData.Core_MDF_Survey_Question_id__c=surveyResult.questionId;
                    responseData.Core_MDF_Answers_txt__c=surveyResult.rating;
                    responseData.Core_MDF_Survey_id__c=surveyObj.id;
                    surveyResponseList.add(responseData);
                }
                else if(surveyResult.questionId == ''){
                    if(string.isNotBlank(surveyResult.rating)){
                        surveyObj.Core_MDF_Comment_txt__c=surveyResult.rating.length() < COMMENT_FIELD_LIMIT ? surveyResult.rating : surveyResult.rating.substring(0, COMMENT_FIELD_LIMIT);
                    }
                }
            }
            update(surveyObj);
            
            if(!surveyResponseList.isEmpty()){
                fetchSurveyQuestions surveyresponse = new fetchSurveyQuestions();
                surveyresponse.createSurveyResponse(surveyResponseList);
            }
            return surveyObj; 
            
        } catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); 
            //throw e;
            
            /****************************************/
            /*List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
LogEntryDetailsWrapper logEntryWrapper = new LogEntryDetailsWrapper();                              

if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IUPGMLogEntry')){ // to bypass the log entry record creation
logEntryWrapper.origin = 'Core_MDF_FeedbackController.submitScoreAction';
logEntryWrapper.errorMsg = e.getMessage();
}
if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IUPGMLogEntry')){ // to bypass the log entry record creation
if(logEntryWrapper != null){
Core_Log_Entry__c logEntryObj = createLogInstance(logEntryWrapper); // calling createLogInstance method with wrapper as parameter
logEntryList.add(logEntryObj);
system.debug('@@logEntryList -> '+logEntryList);
}
if(!logEntryList.isEmpty()){
List<Core_MDF_Bulk_Transaction__e> logEntryPEList = createBulkTransactionPlatEventInstance(logEntryList); //calling createBulkTransactionPlatEventInstance method with logEntryObj parameters
if(!logEntryPEList.isEmpty()){
system.debug('@@logEntryPEList -> '+logEntryPEList);
EventBus.publish(logEntryPEList); 
}
}
}*/
            /***************************************/
            //throw new AuraHandledException(e.getMessage());
            return null;
        }
        //return surveyObj;  
    }
    
    @AuraEnabled
    public static Boolean isCommunity(){
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean getFirstLoginHistory(){
        try {
            Boolean isPopupEnabled = false;
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_FeedbackPopup')){ // bypass logic for survey popup
                
                String surveyPopupFrequency = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SurveyPopupFrequency').toLowercase();
                String surveyFrequency = '';
                String frequencyString = '';
                Integer currentfrequency;
                if(surveyPopupFrequency == 'monthly'){ // to check if popup should come up on monthly basis or quaterly basis
                    surveyFrequency = 'THIS_MONTH'; //getting current month based on the configuration selected
                    currentfrequency = Date.today().month(); //getting current month based on the configuration selected
                    frequencyString = 'CALENDAR_MONTH(LoginTime) = ';
                }
                else if(surveyPopupFrequency == 'quaterly'){ // to check if popup should come up on monthly basis or quaterly basis
                    surveyFrequency = 'THIS_QUARTER'; //getting current quater based on the configuration selected
                    currentfrequency = Integer.valueOf(getCurrentQuarter()); //getting current quater based on the configuration selected
                    frequencyString = 'CALENDAR_QUARTER(LoginTime) = ';
                }
                
                // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query - Begin
                /*
String surveyQuery = 'SELECT Id FROM Core_MDF_Survey__c WHERE Core_MDF_Submitted_By_id__c = '+ '\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'' +
' AND CreatedDate = ' + String.escapeSingleQuotes(surveyFrequency) + ' LIMIT 1';
*/
                String surveyQuery = 'SELECT Id FROM Core_MDF_Survey__c WHERE Core_MDF_Submitted_By_id__c = '+ '\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'' +
                    ' AND CreatedDate = ' + surveyFrequency + ' LIMIT 1';
                // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query - End
                List<Core_MDF_Survey__c> surveyList = Database.query(surveyQuery);
                if(surveyList.isEmpty() && surveyList.size() == 0){ //If no feedback provided in currect month or quarter (based on our config) then only show the popup.  
                    List<LoginHistory> successLoginList = new List<LoginHistory>();
                    
                    // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query - Begin
                    /*
String query = 'SELECT Id, LoginTime, Status from LoginHistory WHERE UserId = ' + '\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'' +
' AND LoginUrl = ' + '\'' +  String.escapeSingleQuotes(Label.Core_MDF_PFRCommunityLink)+ 's/login' + '\''+
' AND CALENDAR_YEAR(LoginTime) = ' + Date.today().year() +
' AND ' + String.escapeSingleQuotes(frequencyString) + currentfrequency + 
' Order by Status ASC';*/
                    
                    String query = 'SELECT Id, LoginTime, Status from LoginHistory WHERE UserId = ' + '\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'' +
                        ' AND LoginUrl = ' + '\'' +  String.escapeSingleQuotes(Label.Core_MDF_PFRCommunityLink)+ 's/login' + '\''+
                        ' AND CALENDAR_YEAR(LoginTime) = ' + Date.today().year() +
                        ' AND ' + frequencyString + currentfrequency + 
                        ' Order by Status ASC'; 
                    // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query - End
                    List<LoginHistory> recordsList = Database.query(query);
                    // US - TWC702-14285: Flatten nested IFs (no logic change) - commented original code
                    /* for(LoginHistory loginRecord : recordsList){
if(loginRecord.Status.toLowercase() == Core_MDF_CCP_ConstantClass.FEEDBACK_SUCCESS_STATUS.toLowerCase()){ //to get only the Success records from query as Status field cannot be added in where clause
successLoginList.add(loginRecord); 
if(successLoginList.size() == 2){ // list size = 2 then break to avoid extra for loop iterations as we require only size = 1 to check if it the ist login. If size = 2 means its not the 1st login
break;
}
}
}*/
                    // US - TWC702-14285: Flatten nested IFs (no logic change) - Begin
                    /* for (LoginHistory loginRecord : recordsList) {
if (loginRecord.Status.toLowerCase() != Core_MDF_CCP_ConstantClass.FEEDBACK_SUCCESS_STATUS.toLowerCase()) {
continue;
}

successLoginList.add(loginRecord);

if (successLoginList.size() == 2) {
break;
}
}*/
                    Integer index = 0;
                    while (index < recordsList.size() && successLoginList.size() < 2) {
                        LoginHistory loginRecord = recordsList[index];
                        if (loginRecord.Status.toLowerCase() == Core_MDF_CCP_ConstantClass.FEEDBACK_SUCCESS_STATUS.toLowerCase()) {
                            successLoginList.add(loginRecord);
                        }
                        index++;
                    }
                    
                    // US - TWC702-14285: Flatten nested IFs (no logic change) -End
                    if(!successLoginList.isEmpty() && successLoginList != null && successLoginList.size() == 1){ // to check if success record's count = 1 this means the user is loging in for the first time in particular month or quarter
                        isPopupEnabled = true;
                    }
                }
                else{
                    isPopupEnabled = false;
                }
            }
            else{
                isPopupEnabled = false;
            }
            return isPopupEnabled;
        }
        catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage());
                            }
    }
    
    public static Double getCurrentQuarter(){
        Double month = date.today().month();
        return (Math.ceil(month / 3));
    } 
    
    public without sharing class fetchSurveyQuestions{
        public List<SurveyDetailsWrapper> getSurveyQuestions(){
            List<SurveyDetailsWrapper> questionList = new List<SurveyDetailsWrapper>();
            String userLang = UserInfo.getLanguage();
            // Highlight: Unused Local Variable - 14285
            // Date todayDate = system.today();
            String Ext_UserType = Core_MDF_CCP_ConstantClass.Ext_UserType;
            
            String usrType = (UserInfo.getUserType() == Ext_UserType)? 'External' :  'Internal';
            
            for(Core_MDF_Survey_Question__c surveyQuestion : [Select id,Core_MDF_Question__c,Core_MDF_Active_ind__c,
                                                              Core_MDF_Sort_Order__c,Core_MDF_pt_BR_txt__c,
                                                              Core_MDF_zh_CN_txt__c,Core_MDF_zh_TW_txt__c,Core_MDF_fr_txt__c,
                                                              Core_MDF_de_txt__c,Core_MDF_it_txt__c,Core_MDF_ja_txt__c,Core_MDF_ko_txt__c,
                                                              Core_MDF_ru_txt__c,Core_MDF_es_MX_txt__c,Core_MDF_es_txt__c, Core_MDF_Visible_To_nm__c,
                                                              Core_MDF_Question_Start_Date_dt__c, Core_MDF_Question_Expiration_Date_dt__c
                                                              FROM Core_MDF_Survey_Question__c
                                                              WHERE Core_MDF_Active_ind__c = true 
                                                              AND Core_MDF_Category_nm__c = 'CCP'
                                                              AND ((Core_MDF_Question_Start_Date_dt__c != null AND Core_MDF_Question_Expiration_Date_dt__c != null AND Core_MDF_Question_Start_Date_dt__c <= TODAY 
                                                                    AND Core_MDF_Question_Expiration_Date_dt__c >= TODAY) OR (Core_MDF_Question_Start_Date_dt__c = null) OR (Core_MDF_Question_Expiration_Date_dt__c = null))
                                                              AND Core_MDF_Visible_To_nm__c =: usrType
                                                              Order by Core_MDF_Sort_Order__c]){
                                                                  
                                                                  SurveyDetailsWrapper wrapper= new SurveyDetailsWrapper();
                                                                  wrapper.questionId = surveyQuestion.id;
                                                                  wrapper.order =(Integer)surveyQuestion.Core_MDF_Sort_Order__c;
                                                                  If(userLang != null && userLang != 'en_US' && languages.contains(userLang)){
                                                                      String colToBeQueried = 'Core_MDF_'+userLang+'_txt__c';
                                                                      wrapper.question = String.valueOf(surveyQuestion.get(colToBeQueried));
                                                                  } else {
                                                                      wrapper.question =  surveyQuestion.Core_MDF_Question__c; 
                                                                  }
                                                                  questionList.add(wrapper);
                                                              }
            return questionList;
        }
        
        public void createSurveyResponse(List<Core_MDF_Survey_Response__c> surveyResponseList){
            
            insert surveyResponseList;
        }
        
        //Method to fetch and return PNUM Records for logged in User's Id
        public List<Core_MDF_Partner_Node_User_Mapping__c> fetchPNUMRecords(){
            return [SELECT Id, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c 
                    FROM Core_MDF_Partner_Node_User_Mapping__c 
                    WHERE Core_MDF_Active_Ind__c = TRUE
                    AND Core_MDF_User__c = :UserInfo.getUserId()];
        }
        
        //Method to fetch and return External PGM Records for logged in User's Account Id
        public List<Core_MDF_Partner_Group_Mapping__c> fetchPGMRecords(Id AccountId){
            String extAccessType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Ext_AccessType');
            return [SELECT Id, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_CoMarketingActiveAccount_Id__c 
                    FROM Core_MDF_Partner_Group_Mapping__c 
                    WHERE Core_MDF_Account__c =: AccountId 
                    AND Core_MDF_Inactive_Ind__c = FALSE 
                    AND Core_MDF_Type_of_Access__c =: extAccessType];
        }
        
    }
    
    public static List<SurveyResponseWrapper> getUserAccountAndProgram(){
        List<SurveyResponseWrapper> surveyResponseWrapperList = new List<SurveyResponseWrapper>();
        Set<String> programSet = new Set<String>(); 
        Id ultimateAccountId;
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>(); 
        Id userId = UserInfo.getUserId();
        SurveyResponseWrapper responseWrapper = new SurveyResponseWrapper();
        User userRecord = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId]; //query to get loggedin user's Account
        responseWrapper.userAccountId = userRecord.Contact.AccountId;
        surveyResponseWrapperList.add(responseWrapper);
        
        if(userId != null){
            fetchSurveyQuestions pnumRecord = new fetchSurveyQuestions();
            pnumList = pnumRecord.fetchPNUMRecords(); //calling fetchPNUMRecords method to get the logged in user's PNUM
        }
        //Avoid using debug statements
        if(pnumList != null && !pnumList.isEmpty()){
            for(Core_MDF_Partner_Node_User_Mapping__c pnumRec : pnumList){
                programSet.add(pnumRec.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c); //adding programs fetched from PNUM query in programset
                responseWrapper.programSet = programSet;
                responseWrapper.ultimateAccountId = pnumRec.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c; //adding Account Id's fetched from PNUM query in ultimateAccountSet
                surveyResponseWrapperList.add(responseWrapper);
            }
        }
        else{ //if PNUM records does not exist fetch account from user's contact's Account and program from external PGMs for the particular user's account 
            if(userRecord.Contact.AccountId != null){
                fetchSurveyQuestions pgmRecord = new fetchSurveyQuestions();
                pgmList = pgmRecord.fetchPGMRecords(userRecord.Contact.AccountId);
                if(pgmList != null && !pgmList.isEmpty()){
                    for(Core_MDF_Partner_Group_Mapping__c pgmRec : pgmList){
                        programSet.add(pgmRec.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c); //adding programs fetched from PGM query in programset 
                        responseWrapper.programSet = programSet;
                        responseWrapper.ultimateAccountId = pgmRec.Core_MDF_CoMarketingActiveAccount_Id__c; //adding Account Id's fetched from PGM querry
                        surveyResponseWrapperList.add(responseWrapper);
                    }
                }
            }
        }
        return surveyResponseWrapperList;
    } 
    
    public class SurveyDetailsWrapper{
        @AuraEnabled public String question { get; set; }
        @AuraEnabled public String questionId { get; set; }
        @AuraEnabled public String rating { get; set; }
        @AuraEnabled public Integer order { get; set; }
    }
    
    public class SurveyWrapper{
        @AuraEnabled public String pageRef { get; set; }
        @AuraEnabled public List<SurveyDetailsWrapper> SurveyDetailsWrapperList { get; set; } 
    }
    
    public class pageReferenceWrapper{
        public String recordId;
        public String objectApiName;
        public String actionName;
    }
    
    public class SurveyResponseWrapper{
        public Set<String> programSet;
        public Id ultimateAccountId;
        public Id userAccountId;
    }
    
    
    /***************************************************************************************************** 
Method Name   :        createLogInstance
@return       :        logEntryObj
@parameters   :        logWrapper
Description   :        creates and returns the log entry object record based on the inputs
******************************************************************************************************/
    
    public static Core_Log_Entry__c createLogInstance(LogEntryDetailsWrapper logWrapper){
        Core_Log_Entry__c logEntryObj = new Core_Log_Entry__c();
        /*if(!logWrapper.successIds.isEmpty()){
logEntryObj.Core_Severity__c = 'Info';
String logDetails = JSON.serialize(logWrapper.successIds);
logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;  
}
if(!logWrapper.failedPGMList.isEmpty()){
logEntryObj.Core_Severity__c = 'Critical';
String logDetails = JSON.serialize(logWrapper.failedPGMList);
logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;
}
if(!logWrapper.failedGroupMemberList.isEmpty()){
logEntryObj.Core_Severity__c = 'Critical';
String logDetails = JSON.serialize(logWrapper.failedGroupMemberList);
logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;
}*/
        
        logEntryObj.Core_Severity__c = 'Critical';
        //logEntryObj.Core_Project__c = Label.Core_MDF_Program_Name;
        logEntryObj.Core_When__c = System.now();
        logEntryObj.Core_Origin__c = logWrapper.origin;
        logEntryObj.Core_Scope__c = 'Feedback Exception'; // Need to Ask the Scope of Log entry      
        logEntryObj.Core_Message__c = logWrapper.errorMsg;
        return logEntryObj;
    }
    
    public static List<Core_MDF_Bulk_Transaction__e> createBulkTransactionPlatEventInstance(List<Core_Log_Entry__c> logEntryList){
        List<Core_MDF_Bulk_Transaction__e> bulkTransactionList = new List<Core_MDF_Bulk_Transaction__e>();
        for(Core_Log_Entry__c log : logEntryList){
            Core_MDF_Bulk_Transaction__e bulkTransactionEvent = new Core_MDF_Bulk_Transaction__e();
            bulkTransactionEvent.Core_MDF_JSON_Data__c = JSON.serialize(log);
            bulkTransactionEvent.Core_MDF_Object_Name__c = 'Core_Log_Entry__c';
            bulkTransactionList.add(bulkTransactionEvent);
        }
        return bulkTransactionList;
    }
    
    //Wrapper to store Log Entry Details
    public class LogEntryDetailsWrapper{
        public String origin;
        //public Set<Id> successIds = new Set<Id>();
        //public List<Core_MDF_Partner_Group_Mapping__c> failedPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();
        //public List<Groupmember> failedGroupMemberList = new List<Groupmember>();
        public String errorMsg;
    }
    
    
}