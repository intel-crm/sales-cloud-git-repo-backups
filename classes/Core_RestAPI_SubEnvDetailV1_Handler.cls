/**********************************************************************************************************************************************************
* Class Name  : Core_RestAPI_SubEnvDetailV1_Handler
* Version     : 1.0  
* Created Date: 2 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/2/2018              Handler class to process request and response for  the specific Supported Product's Subcategories Environment Details 
**********************************************************************************************************************************************************/
public with sharing class Core_RestAPI_SubEnvDetailV1_Handler{
    
    private DateTime entryTime = null;
    private String apiName;
    private Set<Id> envQuestnIds = new Set<Id>();
    Map<Id,List<Core_IPS_Answer__c>> mapQues2Answer = new Map<Id,List<Core_IPS_Answer__c>>(); 
    private String ERROR_CODE_500 = '500';
    private String INVALID_URI_404= '404';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private static final String SUB_CATEGORY_ID =  Core_RestAPI_Util.getInputFromURIParam(4); 
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private static final String filterCondition = Core_RestAPI_Util.getConditionWithURIParam('Core_Product_Issue_Sub_Category__r.Name',4);
    private static final String envFilterCondition = 'Core_Agent_Only__c= false AND  Core_Status__c =  \'Active\'';
    private String SubEnvDetailV1_URI ='/v1.0/products/categories/*/environmentdetails';
    
    private static final String GET_ENVIRONMENT_DETAILS_SOQL='Select Core_Product_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name,'+
        'Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id , Core_IPS_Question__c,Core_IPS_Question__r.Name,'+
        'Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__r.Core_IPS_Datatype__c, Core_IPS_Question__r.Core_IPS_Required__c,'+
        'Core_IPS_Question_Text__c,Core_Product_Issue_Sub_Category__c,Core_Required__c,Core_Agent_Only__c,Core_Environment_Variable__c,'+
        'Core_IPS_Question__r.Core_IPS_Parent_Question__r.Name FROM Core_IPS_Assigned_Environment_Variables__c '+
        'where '+envFilterCondition +' AND ' +filterCondition+ ' LIMIT ' +LABEL.Core_RestAPI_Sub_Env_DetailV1_Records_Limit;
    
    public Core_RestAPI_SubEnvDetailV1_Handler(DateTime currTime, String APIname){
        system.debug('GET_ENVIRONMENT_DETAILS_SOQL ==>> '+GET_ENVIRONMENT_DETAILS_SOQL);
        this.entryTime = currTime;
        this.apiName= APIname;
        response.successContent = new List<SubCatEnvDetailsWrapper >();
        
    }
    //Retrieve specific Supported Product's Subcategories Env details for the logged in User
    public Core_RestAPI_Response getEnvironmentDetails(){
        System.debug(' Core_RestAPI_SubEnvDetailV1_Handler getEnvironmentDetails Entered  \n ');
        try{
            //Validations if need to be handled in util class      
            Boolean isRequestValid = doValidations();               
            //Process the api request
            if(isRequestValid == true)
            {
                processRequest();
            }              
        }catch(Exception e){
            Core_RestAPI_Util.processException(e,ERROR_CODE_500 ,response,apiName,entryTime);
        }finally{   
            System.debug('Core_RestAPI_SubEnvDetailV1_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200 ;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        System.debug(' Core_RestAPI_SubEnvDetailV1_Handler getEnvironmentDetails Exiting ');
        return response;
    } 
    // Validation if any for the API goes here
    @testVisible
    private Boolean doValidations(){
        System.debug('Core_RestAPI_SubEnvDetailV1_Handler  doValidations Invoked ');
        Boolean isRequestValid = true; 
        Pattern testPattern = Pattern.compile('IC-[0-9]{8}');
        Matcher testMatcher = testPattern.matcher(SUB_CATEGORY_ID);
        if(!testMatcher.matches()){          
            isRequestValid = false; 
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011,response, apiName, entryTime);           
        }
        else if(Core_RestAPI_Util.isRequestURIValid(SubEnvDetailV1_URI ) == false){
            //TODO Move to constant after the code review
            system.debug('inside isRequestValid ==>> '+isRequestValid );
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        } 
        return isRequestValid;
        
    } 
    // Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        
        System.debug('Core_RestAPI_SubEnvDetailV1_Handler  processRequest Entering SOQL  \n '+GET_ENVIRONMENT_DETAILS_SOQL);
        // In this for loop retrieving fields of Core_IPS_Assigned_Environment_Variables__c Custom Object
        List<Core_IPS_Assigned_Environment_Variables__c> lstEnvirVariable = new List<Core_IPS_Assigned_Environment_Variables__c>();
        lstEnvirVariable = DATABASE.Query(GET_ENVIRONMENT_DETAILS_SOQL );
        system.debug('lstEnvirVariable==>> '+lstEnvirVariable);
        List<Core_IPS_Question__c> lstCoreQuestions = new List<Core_IPS_Question__c>();
        if(!lstEnvirVariable.isEmpty()){
            for(Core_IPS_Assigned_Environment_Variables__c envQuestn : lstEnvirVariable){
                envQuestnIds.add(envQuestn.Core_IPS_Question__c); 
            }
            lstCoreQuestions = [SELECT Id,Name,Core_IPS_Question__c,Core_IPS_Parent_Question__c,Core_IPS_Datatype__c,Core_IPS_Required__c , (SELECT Id,Core_IPS_Answer__c,Core_IPS_Parent_Answer__r.Name, Name from Core_Answers__r WHERE Core_IPS_Status__c = 'Active') FROM Core_IPS_Question__c WHERE ID IN: envQuestnIds AND Core_IPS_Status__c = 'Active'];
            System.debug('lstCoreQuestions --->'+lstCoreQuestions );
            for(Core_IPS_Question__c objAns :lstCoreQuestions ){
                mapQues2Answer.put(objAns.Id,objAns.Core_Answers__r);
            }
            System.debug('Map of Question and Answers'+mapQues2Answer);
            
            SubCatEnvDetailsWrapper objWrapp = new SubCatEnvDetailsWrapper ();
            List<EnvQuestionWrapper> objEDWrapp=new List<EnvQuestionWrapper>();
            for(Core_IPS_Assigned_Environment_Variables__c objEnvirVariable: lstEnvirVariable)
            {    
                objWrapp.caseSubcategoryName = objEnvirVariable.Core_Product_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name ;
                objWrapp.caseSubcategryId = objEnvirVariable.Core_Product_Issue_Sub_Category__r.Name;
                EnvQuestionWrapper objEnvQues = new EnvQuestionWrapper();
                objEnvQues.environmentDetailID =objEnvirVariable.Core_IPS_Question__r.Name;
                objEnvQues.datatype =objEnvirVariable.Core_IPS_Question__r.Core_IPS_Datatype__c;
                objEnvQues.required =objEnvirVariable.Core_Required__c;
                objEnvQues.environmentDetailQuestion= objEnvirVariable.Core_IPS_Question__r.Core_IPS_Question__c ;
                objEnvQues.parentEnvironmentDetailId = objEnvirVariable.Core_IPS_Question__r.Core_IPS_Parent_Question__r.Name;
                List<AnsWrapper> lstAnswers= new List<AnsWrapper>();
                if(mapQues2Answer.get(objEnvirVariable.Core_IPS_Question__c) != null)
                    for(Core_IPS_Answer__c objAns : mapQues2Answer.get(objEnvirVariable.Core_IPS_Question__c)){
                        AnsWrapper answrapp= new AnsWrapper();
                        answrapp.answer = objAns.Core_IPS_Answer__c;
                        answrapp.answerId = objAns.Name;
                        answrapp.parentAnswerId = objAns.Core_IPS_Parent_Answer__r.Name;
                        lstAnswers.add(answrapp);
                    }
                objEnvQues.answers=lstAnswers;
                
                
                objEDWrapp.add(objEnvQues);
            } 
            objWrapp.envDetails=objEDWrapp;
            response.successContent.add(objWrapp);
            
        }
        System.debug('ProcessRequest response.successContent '+response.successContent);
    }
    // Here below EnvironmentDetailsWrapper Wrapper class must implements the interface Core_RestAPI_SuccessContent
    // Wrapper to build fields of Core_IPS_Assigned_Environment_Variables__c Custom object
    public class SubCatEnvDetailsWrapper implements Core_RestAPI_SuccessContent{
        
        //Wrapper for Environment details
        public String caseSubcategoryName{get;set;}
        public String caseSubcategryId{get;set;}
        public List<EnvQuestionWrapper> envDetails{get;set;}
    }
    //Wrapper for Environment Questions
    public class EnvQuestionWrapper { 
        public String environmentDetailId{get;set;}
        public String datatype{get;set;}       
        public Boolean required{get;set;} 
        public String environmentDetailQuestion{get;set;}
        public String parentEnvironmentDetailId{get;set;}
        public List<AnsWrapper> answers{get;set;}
        
    }
    //Wrapper for answers
    public class AnsWrapper{ 
        public String answer{get;set;}
        public String answerId{get;set;}
        public String parentAnswerId{get;set;}
    }  
}