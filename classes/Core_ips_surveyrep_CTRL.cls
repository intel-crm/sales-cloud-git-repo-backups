public with sharing class Core_ips_surveyrep_CTRL {

    @AuraEnabled  public static List<wrapQuestion> lstQuestions{get;set;}
    public static Boolean isSurveySubmitted{get;set;}
    public static Boolean isCaseClosed{get;set;}
    public  static Boolean isError{get;set;}
    
    public static String questionString{get;set;}
    public static Boolean displayWarning{get;set;}
    public static String caseNumber{get;set;}
    public static String contactname{get;set;}
    public static String lang{get;set;}
    public static String mapParam{get;set;}
    public static String userLanguage{get;set;}
    public static String profileName{get;set;}
    public static String surveyHeaderLabel{get;set;}
    public static String surveyFooterLabel{get;set;}
    
    private static String caseId{get;set;}
    public static String surveyType{get;set;}
    public  static Core_IPS_Survey_Settings__c surveySetting;
    public Boolean partren{get;set;}
    public Boolean repbb{get;set;}
    @AuraEnabled public static List<wrapQuestion> ques{get;set;}
    
     
    /***************************************************************************************************
Method Name:  init 
Version     : 1.0     
Function    : This method initializes the variables and checks accesibility
Input Parameters: none
Output Parameters: void
****************************************************************************************************/
    @AuraEnabled
    public static List<wrapQuestion> init(String mapram,string answer) {
        answer=answer;
      
        
        mapParam=mapram;
        
        Case objCase;
      
        try{
            isSurveySubmitted = false;
            isCaseClosed = false;
            isError = false;
           
            displayWarning = false;
            
           
            surveyType ='';
            caseId=mapParam;            
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
                
                
                if(setSalesRepProfile!=null && setSalesRepProfile.size()>0) {
                    if(hasPermissionSet(setSalesRepProfile)) { surveyType = 'Sales Rep'; }
                }
            }     
            
           
            
           
            if(String.isBlank(caseId)) {
                isError = true;
               
                
            } else if(caseId.length()<15){
                isError = true;
             
            }
            if([SELECT COUNT() FROM Case WHERE Id=:caseId]==0) {
                isError = true;
              
            }
            if(String.isBlank(surveyType)) {
                isError = true;
           
            }
            //FLS Check Added - Nishitha
            caseId=mapParam;
          
            if(Case.SObjectType.getDescribe().isAccessible()){
                objCase = [SELECT isClosed,Core_Sub_Status__c,CaseNumber,Contact.Name,RecordType.Name FROM Case WHERE Id=:caseId LIMIT 1]; // added by amritesh - US103747
            }
          
            isCaseClosed = objCase.isClosed;
            caseNumber = objCase.CaseNumber;
            contactname = objCase.Contact.Name;
            String recordTypeName = objCase.RecordType.Name;
            if(String.isBlank(recordTypeName)) {
                recordTypeName = 'none';
            }
            
            if(!recordTypeName.startsWith('IPS')) {
                isError = true;
              
            }
            
            if(!isCaseClosed){
                isError = true;
             
            }
            
       
            if(objCase.Core_Sub_Status__c!='Closed') {
                isError = true;
      
            }
            
            if([SELECT COUNT() FROM Core_IPS_Response__c WHERE Core_IPS_Case__c=:caseId AND Core_IPS_Question_Master__r.RecordType.DeveloperName='Survey']>0) {
                isError = true;
           
            }
          
            fetchSurvey();
        } catch(Exception ex) {
                               Core_IPS_ExceptionHandling.logEntryWithException(ex, '', 'Core_IPS_Survey_Page_Controller');
                              }
     
       
        return lstQuestions;
    }
    
    /***************************************************************************************************
Method Name:  splitIPSLabel 
Version     : 1.0     
Function    : This method splits the String into Set
Input Parameters: String
Output Parameters: Set<String>
****************************************************************************************************/
    private static Set<String> splitIPSLabel(String StrValue) {        
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
****************************************************************************************************/
    @TestVisible
    private static Boolean hasPermissionSet(Set<String> setPermissionSetId) {
        PermissionSetAssignment[] lstPSA;
        
        
        lstPSA = [Select Id,AssigneeId  from PermissionSetAssignment where AssigneeId=:userInfo.getUserId() AND PermissionSetId IN :setPermissionSetId LIMIT 1];
        
        return (lstPSA!=null && lstPSA.size()>0);
    }
    
    /***************************************************************************************************
Method Name:  fetchSurvey 
Version     : 1.0     
Function    : This method fetches the Questions and Answers to display on page. 
Input Parameters: none
Output Parameters: void
****************************************************************************************************/
    private static List<wrapQuestion> fetchSurvey() {
        lstQuestions = new List<wrapQuestion>(); 
        List<Core_IPS_Question__c> lstQuestion;
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Answers = new Map<Id,List<Core_IPS_Answer__c>>();
        if (Schema.sObjectType.Core_IPS_Question__c.isAccessible()) {
        lstQuestion = new List<Core_IPS_Question__c>([SELECT Id,Name,Core_IPS_Datatype__c,Core_IPS_Question__c,Core_IPS_Required__c,Core_IPS_Order_No__c                                                               
                                                      /*(SELECT Id,Core_IPS_Translation__c FROM Translations__r WHERE Core_IPS_Language__c=:lang)*/ // localization/translation will be enabled later
                                                      FROM Core_IPS_Question__c WHERE Core_IPS_Survey_Type__c=:surveyType AND RecordType.DeveloperName='Survey' AND
                                                      Core_IPS_Status__c='Active' ORDER BY Core_IPS_Order_No__c ]);
        }
        if(lstQuestion.size()==0) {
            isError = true;
            
        }
        if (Schema.sObjectType.Core_IPS_Answer__c.isAccessible()) {
        for(Core_IPS_Answer__c objEnvAnswer : [SELECT Id,Core_IPS_Answer__c,Core_IPS_Question__c
                                               /*(SELECT Id,Core_IPS_Translation__c FROM Translations__r WHERE Core_IPS_Language__c=:lang)*/  // localization/translation will be enabled later
                                               FROM Core_IPS_Answer__c WHERE Core_IPS_Question__c IN :lstQuestion AND Core_IPS_Status__c='Active' 
                                               ORDER BY Core_IPS_Order_No__c,Name ASC ]) 
        {
            
            Id QuesId = objEnvAnswer.Core_IPS_Question__c;
            if(!mapQuesId2Answers.containsKey(QuesId)) {
                mapQuesId2Answers.put(QuesId, new List<Core_IPS_Answer__c>());
            }
            mapQuesId2Answers.get(QuesId).add(objEnvAnswer);
        }
        
    }
        for(Core_IPS_Question__c objEnv : lstQuestion) 
        {
            if(!mapQuesId2Answers.containsKey(objEnv.Id)) {
                mapQuesId2Answers.put(objEnv.Id, new List<Core_IPS_Answer__c>());
            }            
            lstQuestions.add(new wrapQuestion(objEnv, mapQuesId2Answers.get(objEnv.Id)));
        }
        
     
        return lstQuestions;
    }
    
    /***************************************************************************************************
Method Name:  captureSurvey 
Version     : 1.0     
Function    : This method captures inputs from page and store in Survey Response
Input Parameters: none
Output Parameters: Pagereference
****************************************************************************************************/
    public class answerWrapper {
        String Id;
        String answert;
    }
    @AuraEnabled
    public static  List<Core_IPS_Response__c> captureSurvey(string answer,string mapram) {
        
       
        Map<String, String> answerMap = (Map<String, String>)JSON.deserialize(answer, Map<String, String>.class);
        
   
        Boolean error = false;
        Boolean allAnswerEmpty = true;
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        init(mapram,answer);
        try{ 
            Map<String, Map<String,Id>> quesToAnsMap = new Map<String, Map<String,Id>>();    
           
            for(wrapQuestion wQues : lstQuestions) { 
                quesToAnsMap.put(wQues.questionId, wQues.mapAnswerId);
            }
         
            for(String key : answerMap.keySet()) {
               
             
                    
                    Core_IPS_Response__c objEnvResponse = new Core_IPS_Response__c();     
                    if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Answer__c.isCreateable()) {                          
                    objEnvResponse.Core_IPS_Answer__c =  answerMap.get(key);
                    }
                
                    if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Case__c.isCreateable()) {                          
                    
                    objEnvResponse.Core_IPS_Case__c = caseId;  
                    }
                   
                    if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Question_Master__c.isCreateable()) {                          
                    
                    objEnvResponse.Core_IPS_Question_Master__c =key;
                    }
                    if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Answer_Master__c.isCreateable()) {                          

                     objEnvResponse.Core_IPS_Answer_Master__c = quesToAnsMap.get(key).get(answerMap.get(key));
                    } 
                    lstEnvResponse.add(objEnvResponse);
                }
                
              
                
 
               
                if (Schema.sObjectType.Core_IPS_Response__c.isCreateable()) {
                insert lstEnvResponse;    
                }        
              
        } 
        catch(Exception ex) { 
           
            Core_IPS_ExceptionHandling.logEntryWithException(ex, 'Core_IPS_Response__c', 'Core_IPS_Survey_Page_Controller');
              
        }
        return lstEnvResponse;
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
        @AuraEnabled public Integer orderNo{get;set;}
        @AuraEnabled public String question{get;set;}
        @AuraEnabled public String answer{get;set;}
        @AuraEnabled public String answerType{get;set;}
        @AuraEnabled public boolean answerTypeTextarea{get;set;}
        @AuraEnabled public boolean answerTypefreetext{get;set;}
        public List<SelectOption> options{get;set;}
        @AuraEnabled public Boolean isRequired{get;set;}
        @AuraEnabled public transient String errorMsg{get;set;}
        
        @AuraEnabled public Id questionId;
        @AuraEnabled public List<Id> mapAnswerId1; //stores record id for particular answer
        @AuraEnabled public List<String> anslabel;
        @AuraEnabled public List<String> emojii;
        @AuraEnabled public Map<String,Id> mapAnswerId;
        @AuraEnabled public List<Id> anId; 
         @AuraEnabled public boolean happyemoji{get;set;}
        @AuraEnabled public boolean neutralemoji{get;set;}
        @AuraEnabled public boolean sademoji{get;set;}
        

        public wrapQuestion()
        {
            
        }
        public wrapQuestion(Core_IPS_Question__c objQuestion, List<Core_IPS_Answer__c> lstEnvAns) {
            answer = answer;            
            orderNo = Integer.valueOf(objQuestion.Core_IPS_Order_No__c);            
            questionId = objQuestion.Id;
            isRequired = objQuestion.Core_IPS_Required__c;
            if( isRequired==true){
                isRequired=true;
            }
            
            question = objQuestion.Core_IPS_Question__c; 
            
            if(objQuestion.Core_IPS_Datatype__c == 'Picklist') {
                answerType = 'picklist';
                answerTypeTextarea=false;
                answerTypefreetext=false;
            }            
            else if(objQuestion.Core_IPS_Datatype__c == 'Select Radio') {
                answerType = 'rowselect';
                
                answerTypefreetext=false;  answerTypeTextarea=false;
            }
            else if(String.valueOf(objQuestion.Core_IPS_Datatype__c).startsWith('Text Area')) {
                answerType = 'textarea';
                answerTypeTextarea=true;
                answerTypefreetext=false;
            } else {
                answerType = 'freetext';
                answerTypefreetext=true;
                answerTypeTextarea=false;
            }
            
            options = new List<SelectOption>();
            if(answerType=='picklist') {
                options.add(new SelectOption('',''));
            }             
            
            mapAnswerId1 = new List<Id>();
            anslabel = new List<String>();
            emojii = new List<String>{'true','false','true1','false','true3'};
            mapAnswerId = new Map<String,Id>();
            for(Core_IPS_Answer__c objAns : lstEnvAns) {
                String answer = objAns.Core_IPS_Answer__c;
              
                
               
                answer = answer.trim();
              
                mapAnswerId1.add(objAns.Id);
                                
          
            
                anslabel.add(answer);
               
                mapAnswerId.put(answer, objAns.Id);
            }
            
        }
    }
    
    @AuraEnabled
    public Static Boolean caseOwnerRedirectPage(String CaseID){
     
       
        Set<Id> userIds = new Set<Id>();
        List<Case> caseRecord;
        caseId = CaseID;
      
        //FLS Check Added - Nishitha
         if(Case.SObjectType.getDescribe().isAccessible()){
        caseRecord=[select id,casenumber,ownerid,Core_IPS_Survey_Captured__c from case where id=:caseId];
      
        }
        userIds.add(caseRecord[0].ownerid); 
       
        //FLS Check Added - Nishitha
        if(CaseHistory.SObjectType.getDescribe().isAccessible()){
            for(CaseHistory objCH : [Select Field,NewValue,OldValue from CaseHistory where CaseId=:caseId and Field='Owner']){
                String OldValue = String.ValueOf(objCH.OldValue);
                String NewValue = String.ValueOf(objCH.NewValue);
                
                if(NewValue!=null && NewValue.startsWith('005')){
                    
                    userIds.add(NewValue);
                }
            }
        }
     
        
        List<String> countryCodeList =(Label.Core_IPS_CountryCode).split(';');
        if(caseRecord.size()>0){
            Map<ID, User> userMap = new Map<ID, User>([SELECT id,name,email,Core_User_Country_Code__c FROM User where Core_User_Country_Code__c In:countryCodeList and Id IN:userIds ] );
            
            if(userMap!=null && userMap.size()>0){
                
                if(caseRecord[0].Core_IPS_Survey_Captured__c== false){
        if (Schema.sObjectType.Case.fields.Core_IPS_Survey_Captured__c.isUpdateable()) {            

                    caseRecord[0].Core_IPS_Survey_Captured__c=true;
        }
                    update caseRecord;
                        }
           
            }
            
        }
    
        return  caseRecord[0].Core_IPS_Survey_Captured__c;
        
    }
    @AuraEnabled
     public static Core_IPS_Survey_Settings__c  fetchSurveySetting(String surveyType) {
        if(surveySetting==null) {
            surveySetting = Core_IPS_Survey_Settings__c.getInstance(surveyType);
        }
        if(surveySetting!=null) {
          //  containerCSS = surveySetting.Core_IPS_container_CSS__c;
            surveyHeaderLabel = surveySetting.Core_IPS_Header_Label__c;
            surveyFooterLabel = surveySetting.Core_IPS_Footer_Label__c;
           // logoImageResource = surveySetting.Core_IPS_Image_Resource__c;
        }
        return surveySetting;
    }
    
 @AuraEnabled
 public static boolean skipSurveyDisable(String caseid){
   
    caseId = caseid;
    List<Case> caseRecord1;
 
     if(Case.SObjectType.getDescribe().isAccessible()){
   
    caseRecord1=[select id,casenumber,ownerid,Core_IPS_Survey_Captured__c from case where id=:caseId];
    
    }
 
           
if(caseRecord1[0].Core_IPS_Survey_Captured__c==false){
                caseRecord1[0].Core_IPS_Survey_Captured__c=true;
                if (Schema.sObjectType.Case.isUpdateable()) {   
                update caseRecord1;
                }
}
   
    return  caseRecord1[0].Core_IPS_Survey_Captured__c;
 
 }
}