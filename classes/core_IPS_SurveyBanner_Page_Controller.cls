public class core_IPS_SurveyBanner_Page_Controller {
  
    /***************************************************************************************************
*Class Name:  Core_IPS_Survey_Page_Controller
*Version     : 1.0 
*Description:  Controller for Core_IPS_Survey_Page

****************************************************************************************************/ 

    public static Survey_BannerURL__c mcs{get;set;}
    public List<wrapQuestion> lstQuestions{get;set;}
    public Boolean isSurveySubmitted{get;set;}
    public Boolean isCaseClosed{get;set;}
    public Boolean isError{get;set;}
    //public Boolean isSuccess{get;set;}
    public Boolean displayWarning{get;set;}
    public String caseNumber{get;set;}
    public String contactname{get;set;}
    public String lang{get;set;}
    public String containerCSS{get;set;} 
    public String surveyHeaderLabel{get;set;}
    public String surveyFooterLabel{get;set;}
    public String logoImageResource{get;set;}
    public Map<String,String> mapParam{get;set;}
    public String  banner{get;set;}
    
    public Boolean showMainContent{get{
        return (!isError && !displayWarning /*&& !isSuccess*/);
    } set;}
    
    public String caseId{get;set;}
    public String surveyType{get;set;}
    private Core_IPS_Survey_Settings__c surveySetting;
    
    //Constructor
    public core_IPS_SurveyBanner_Page_Controller() {
        init();
    }
    
    /***************************************************************************************************
    Method Name:  getParam 
    Version     : 1.0     
    Function    : This method checks parameter from Parameter Map of Page and return value if present. 
    Input Parameters: Parameter Key String 
    Output Parameters: Parameter Key String
   
    ****************************************************************************************************/
    private String getParam(String str) {
        if(mapParam.containsKey(str)) {
            return mapParam.get(str);
        } else 
            return null;
    }
    
    /***************************************************************************************************
    Method Name:  init 
    Version     : 1.0     
    Function    : This method initializes the variables and checks accesibility
    Input Parameters: none
    Output Parameters: void
    ****************************************************************************************************/
    public void init() {
        try{
            isSurveySubmitted = false;
            isCaseClosed = false;
            isError = false;
            //isSuccess = false;
            displayWarning = false;
            
            if(mapParam==null) {
                mapParam = new Map<String,String>(ApexPages.currentPage().getParameters());        
            }
            lang = getParam('lang');
            caseId = getParam('caid');
            surveyType = getParam('stype');
                        
            String userProfileId = String.valueOf(UserInfo.getProfileId()).left(15);
            
            if(String.isBlank(surveyType)){                
                Set<String> setSalesRepProfile = splitIPSLabel(Core_IPS_Helper_Utility.getIPSLabel('IPS_SalesRep_ProfilesId'));               
                if(setSalesRepProfile.contains(userProfileId)) {
                    surveyType = 'Sales Rep';
                }                
                Set<String> setCustomerProfile = splitIPSLabel(Core_IPS_Helper_Utility.getIPSLabel('IPS_Customer_ProfilesId'));                 
                if(setCustomerProfile.contains(userProfileId)) {
                    surveyType = 'Customer';
                }         
                
                /*Added by Amritesh - 07/18/2018 - US109362 */
                if(setSalesRepProfile!=null && setSalesRepProfile.size()>0) {
                    if(hasPermissionSet(setSalesRepProfile)) { surveyType = 'Sales Rep'; }
                }
            }     
            
            fetchSurveySetting();
                        
            //validations
            if(String.isBlank(caseId)) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.Survey_Invalid_Link));
                return;
            } else if(caseId.length()<15){
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.Survey_Invalid_Link));
                return;
            }
            if([SELECT COUNT() FROM Case WHERE Id=:caseId]==0) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.Survey_Invalid_Link));
                return;
            }
            if(String.isBlank(surveyType)) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.Core_IPS_Survey_not_available));
                return;
            }
            
            Case objCase = [SELECT isClosed,Core_Sub_Status__c,CaseNumber,Contact.Name,RecordType.Name FROM Case WHERE Id=:caseId LIMIT 1]; // added by amritesh - US103747
            isCaseClosed = objCase.isClosed;
            caseNumber = objCase.CaseNumber;
            contactname = objCase.Contact.Name;
            String recordTypeName = objCase.RecordType.Name;
            if(String.isBlank(recordTypeName)) {
                recordTypeName = 'none';
            }
            
            if(!recordTypeName.startsWith('IPS')) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.Core_IPS_Survey_not_available));
                return;
            }
            
            if(!isCaseClosed){
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.Core_IPS_Survey_Case_not_Closed));
                return;
            }
                
            // added by amritesh - US103747 - start
            if(objCase.Core_Sub_Status__c!='Closed') {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.Core_IPS_Survey_not_available));
                return;
            }
            // US103747 - end
            
            if([SELECT COUNT() FROM Core_IPS_Response__c WHERE Core_IPS_Case__c=:caseId AND Core_IPS_Question_Master__r.RecordType.DeveloperName='Survey']>0) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.Survey_Already_Submitted));
                return;
            }
            fetchSurvey();
        } catch(Exception ex) { System.debug(ex.getMessage()); 
            //Core_IPS_ExceptionHandling.logEntryWithException(ex, '', 'Core_IPS_Survey_Page_Controller');
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.Core_IPS_Survey_Error_Message_2)); 
        }
    }
    
    /***************************************************************************************************
    Method Name:  splitIPSLabel 
    Version     : 1.0     
    Function    : This method splits the String into Set
    Input Parameters: String
    Output Parameters: Set<String>
  
    ****************************************************************************************************/
    private Set<String> splitIPSLabel(String StrValue) {        
        Set<String> setValues = new Set<String>();
        if(String.isNotBlank(StrValue)) { 
            setValues = new Set<String>(StrValue.split(','));
        }
        return setValues;
    }
    
    /***************************************************************************************************
    Method Name:  hasPermissionSet 
    Version     : 1.0     
    Function    : This checks if permission set is assigned to User
    Input Parameters: Set<String>
    Output Parameters: Boolean
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                   07/18/2018              Created - US109362
    ****************************************************************************************************/
    @TestVisible
    private Boolean hasPermissionSet(Set<String> setPermissionSetId) {        
        PermissionSetAssignment[] lstPSA = [Select Id,AssigneeId  from PermissionSetAssignment where AssigneeId=:userInfo.getUserId() AND PermissionSetId IN :setPermissionSetId LIMIT 1];
        return (lstPSA!=null && lstPSA.size()>0);
    }
    
    /***************************************************************************************************
    Method Name:  fetchSurvey 
    Version     : 1.0     
    Function    : This method fetches the Questions and Answers to display on page. 
    Input Parameters: none
    Output Parameters: void
       ****************************************************************************************************/
    private void fetchSurvey() {
        lstQuestions = new List<wrapQuestion>();        
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Answers = new Map<Id,List<Core_IPS_Answer__c>>();
        
        List<Core_IPS_Question__c> lstQuestion = new List<Core_IPS_Question__c>([SELECT Id,Name,Core_IPS_Datatype__c,Core_IPS_Question__c,Core_IPS_Required__c,Core_IPS_Order_No__c                                                               
                                                                                 /*(SELECT Id,Core_IPS_Translation__c FROM Translations__r WHERE Core_IPS_Language__c=:lang)*/ // localization/translation will be enabled later
                                                                                 FROM Core_IPS_Question__c WHERE Core_IPS_Survey_Type__c=:surveyType AND RecordType.DeveloperName='Survey' AND
                                                                                 Core_IPS_Status__c='Active' ORDER BY Core_IPS_Order_No__c]);
        if(lstQuestion.size()==0) {
            isError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.Core_IPS_Survey_not_available));
            return;
        }
        for(Core_IPS_Answer__c objEnvAnswer : [SELECT Id,Core_IPS_Answer__c,Core_IPS_Question__c
                                               /*(SELECT Id,Core_IPS_Translation__c FROM Translations__r WHERE Core_IPS_Language__c=:lang)*/  // localization/translation will be enabled later
                                               FROM Core_IPS_Answer__c WHERE Core_IPS_Question__c IN :lstQuestion AND Core_IPS_Status__c='Active' 
                                               ORDER BY Core_IPS_Order_No__c,Name ASC]) 
        {
            Id QuesId = objEnvAnswer.Core_IPS_Question__c;
            if(!mapQuesId2Answers.containsKey(QuesId)) {
                mapQuesId2Answers.put(QuesId, new List<Core_IPS_Answer__c>());
            }
            mapQuesId2Answers.get(QuesId).add(objEnvAnswer);
        }
        
        for(Core_IPS_Question__c objEnv : lstQuestion) 
        {
            if(!mapQuesId2Answers.containsKey(objEnv.Id)) {
                mapQuesId2Answers.put(objEnv.Id, new List<Core_IPS_Answer__c>());
            }            
            lstQuestions.add(new wrapQuestion(objEnv, mapQuesId2Answers.get(objEnv.Id)));
        }
    }
    
    /***************************************************************************************************
    Method Name:  fetchSurveySetting 
    Version     : 1.0     
    Function    : This method fetches the Custom Setting for the specific type of Survey
    Input Parameters: none
    Output Parameters: void
    
    ****************************************************************************************************/
    private void fetchSurveySetting() {
        if(surveySetting==null) {
            surveySetting = Core_IPS_Survey_Settings__c.getInstance(surveyType);
        }
        if(surveySetting!=null) {
            containerCSS = surveySetting.Core_IPS_container_CSS__c;
            surveyHeaderLabel = surveySetting.Core_IPS_Header_Label__c;
            surveyFooterLabel = surveySetting.Core_IPS_Footer_Label__c;
            logoImageResource = surveySetting.Core_IPS_Image_Resource__c;
        }
    }
    
    /***************************************************************************************************
    Method Name:  captureSurvey 
    Version     : 1.0     
    Function    : This method captures inputs from page and store in Survey Response
    Input Parameters: none
    Output Parameters: Pagereference
  
    ****************************************************************************************************/
    public Pagereference captureSurvey() {
        Savepoint sp = Database.setSavepoint();
        Boolean error = false;
        Boolean allAnswerEmpty = true;
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        try{            
            for(wrapQuestion wQues : lstQuestions) {
                if(wQues.isRequired && String.isBlank(wQues.answer)) {
                    error = true;
                    wQues.errorMsg = System.Label.Core_IPS_Survey_Input_Required;
                }
                else if(String.isNotBlank(wQues.answer)) {
                    allAnswerEmpty = false;
                }
                
                Core_IPS_Response__c objEnvResponse = new Core_IPS_Response__c();                
                objEnvResponse.Core_IPS_Answer__c = wQues.answer;
              
                objEnvResponse.Core_IPS_Case__c = caseId;  
                objEnvResponse.Core_IPS_Question_Master__c = wQues.questionId;
              
                if(wQues.mapAnswerId.containsKey(wQues.answer)) {
                    objEnvResponse.Core_IPS_Answer_Master__c = wQues.mapAnswerId.get(wQues.answer);
                   
                }
                lstEnvResponse.add(objEnvResponse);
            }
            if(error) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.Core_IPS_Survey_Error_Message_1));
                return null;   
            }
            /*if(allAnswerEmpty && !displayWarning) {
                displayWarning = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, System.Label.Core_IPS_Survey_Empty_Answer_Warning));
                return null;
            }*/
            insert lstEnvResponse;            
            //isSuccess = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, System.Label.Survey_Capture_Success_Message)); 
            return SkiptoCase();
        } 
        catch(Exception ex) { 
            Database.rollback(sp);  
            Core_IPS_ExceptionHandling.logEntryWithException(ex, 'Core_IPS_Response__c', 'Core_IPS_Survey_Page_Controller');
          ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.Core_IPS_Survey_Error_Message_2));  
        }
        return null;
    }
    
    /***************************************************************************************************
    Method Name:  skipToCase 
    Version     : 1.0     
    Function    : This method redirects the user to case page
    Input Parameters: none
    Output Parameters: Page to redirect
   
    ****************************************************************************************************/
    public Pagereference skipToCase() {
        Pagereference pgref;
        /*if(getParam('retURL')!=null) {
            String returl = getParam('retURL');
            if(!returl.startsWith('/') && !returl.toUpperCase().startsWith('%2F')) {
                returl = '/' + returl;
            }
            pgref = new Pagereference(returl);
        } else*/ if(String.isNotBlank(caseId)){
            pgref = new Pagereference('/' + caseId);
        } else {
            pgref = new Pagereference('/');
        }
        return pgref;
    }
    
    /***************************************************************************************************
    Method Name:  backfromWarning 
    Version     : 1.0     
    Function    : This method takes back from warning
    Input Parameters: none
    Output Parameters: none
    
    ****************************************************************************************************/
    public void backfromWarning() {
        displayWarning = false;
    }
    
    /***************************************************************************************************
    Class Name:  wrapQuestion
    Version     : 1.0     
    Description:  Warpper Class to store questions and their related answers
   
    ****************************************************************************************************/ 
    public class wrapQuestion{
        public Integer orderNo{get;set;}
        public String question{get;set;}
        public String answer{get;set;}
        public String answerType{get;set;}
        public List<SelectOption> options{get;set;}
        public Boolean isRequired{get;set;}
        public transient String errorMsg{get;set;}
        
        Id questionId;
        Map<String,Id> mapAnswerId; //stores record id for particular answer
        
        public wrapQuestion(Core_IPS_Question__c objQuestion, List<Core_IPS_Answer__c> lstEnvAns) {
            answer = '';            
            orderNo = Integer.valueOf(objQuestion.Core_IPS_Order_No__c);            
            questionId = objQuestion.Id;
            isRequired = objQuestion.Core_IPS_Required__c;
            
            question = objQuestion.Core_IPS_Question__c; 
            
            // localization/translation will be enabled later
            /*for(Core_IPS_Translation__c objTranslation : objQuestion.Translations__r) {
              question = objTranslation.Core_IPS_Translation__c;
            }*/
            
            if(objQuestion.Core_IPS_Datatype__c == 'Picklist') {
                answerType = 'picklist';
            }            
            else if(objQuestion.Core_IPS_Datatype__c == 'Select Radio') {
                answerType = 'rowselect';
            }
            else if(String.valueOf(objQuestion.Core_IPS_Datatype__c).startsWith('Text Area')) {
                answerType = 'textarea';
            } else {
                answerType = 'freetext';
            }
            
            options = new List<SelectOption>();
            if(answerType=='picklist') {
                options.add(new SelectOption('',''));
            }             
            
            mapAnswerId = new Map<String,Id>();
            for(Core_IPS_Answer__c objAns : lstEnvAns) {
                String answer = objAns.Core_IPS_Answer__c;
                
                // localization/translation will be enabled later
                /*for(Core_IPS_Translation__c objTranslation : objAns.Translations__r) {
                  answer = objTranslation.Core_IPS_Translation__c;
                }*/
                answer = answer.trim();
                options.add(new SelectOption(answer,answer));
                mapAnswerId.put(answer, objAns.Id);
            }
        }
    }
   
   
   public PageReference caseOwnerRedirectPage(){
        //Modified by karthick - US108700 - R4.3 - 27/06/2018
        Set<Id> userIds = new Set<Id>();
        caseId = getParam('caid');
        List<Case> caseRecord=[select id,casenumber,ownerid,Core_IPS_Survey_Captured__c from case where id=:caseId];
        
        userIds.add(caseRecord[0].ownerid); 
        for(CaseHistory objCH : [Select Field,NewValue,OldValue from CaseHistory where CaseId=:caseId and Field='Owner']){
            String OldValue = String.ValueOf(objCH.OldValue);
            String NewValue = String.ValueOf(objCH.NewValue);
            
            if(NewValue!=null && NewValue.startsWith('005')){
                //System.debug('--New Value ::'+objCH.NewValue);
                userIds.add(NewValue);
            }
        }
        //System.debug('---User Id set ::'+userIds);
    
        List<String> countryCodeList =(Label.Core_IPS_CountryCode).split(';');
        if(caseRecord.size()>0){
            Map<ID, User> userMap = new Map<ID, User>([SELECT id,name,email,Core_User_Country_Code__c FROM User where Core_User_Country_Code__c In:countryCodeList and Id IN:userIds ] );
            
            if(userMap!=null && userMap.size()>0){
                
                if(caseRecord[0].Core_IPS_Survey_Captured__c== false){
                    caseRecord[0].Core_IPS_Survey_Captured__c=true;
                 
                    update caseRecord;
                }
                    
                PageReference pageRef=new PageReference('/'+caseId);
                pageRef.setRedirect(true);
                return pageRef;
                
            }
            
        }
        return null;
    }
    public static void getcustomvalue(){
 mcs = Survey_BannerURL__c.getall().values();
System.debug(mcs.core_IPS_SurveyBanner_Url__c);
      //  Map<String_data_set_name, CustomSettingApiName> var =
//CustomSettingApiName.getAll();
//Survey_BannerURL__c students = Survey_BannerURL__c.getValues('core_IPS_SurveyBanner_Url__c');
//Map<String, Survey_BannerURL__c> students = Survey_BannerURL__c.getAll();
       //System.debug(students.core_IPS_SurveyBanner_Url__c);
        

}
    
}