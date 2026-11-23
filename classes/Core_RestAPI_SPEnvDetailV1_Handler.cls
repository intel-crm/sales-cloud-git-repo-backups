/**********************************************************************************************************************************************************
* Class Name  : Core_RestAPI_SPEnvDetailV1_Handler 
* Version     : 1.0  
* Created Date: 2 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/2/2018           Handler class to process request and response for  the specific Supported Product's Environment Details 
**********************************************************************************************************************************************************/
public with sharing class Core_RestAPI_SPEnvDetailV1_Handler{
    
    private DateTime entryTime = null;
    private String apiName;
    private String ERROR_CODE_500 = '500';
    private String MALFORMED_INPUT_9011 = '9011';
    private String SUCCESS_CODE_200 = '200';
    private Set<Id> envQuestnIds = new Set<Id>();
    Map<Id,List<Core_IPS_Answer__c>> mapQues2Answer = new Map<Id,List<Core_IPS_Answer__c>>();
    private static final String PRODUCT_ID =  Core_RestAPI_Util.getInputFromURIParam(3); 
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private String SPEnvDetailV1_URI ='/v1.0/products/*/environmentdetails';
    private String INVALID_URI_404= '404';
    private static final String envFilterCondition = 'Core_Agent_Only__c= false ';
    private static final String filterCondition = Core_RestAPI_Util.getConditionWithURIParam('Id', 3);
    private String SUPPORTED_PRODUCT_NAME;
    private static final String GET_SUPPORTED_PRODUCT_ID = 'SELECT Id,Name,Core_Supported_Product__r.Name FROM Asset WHERE '+ filterCondition ;
    private static final String GET_ENVIRONMENT_DETAILS_SOQL = ' SELECT Name,Id,Core_Environment_Variable__r.Name,Core_IPS_Question__r.Name,'+
        'Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__r.Core_IPS_Datatype__c, Core_IPS_Question__r.Core_IPS_Required__c,Core_Agent_Only__c,'+
        'Core_IPS_Question_Text__c,Core_IPS_Question__r.Core_IPS_Parent_Question__r.Name,Core_Environment_Variable__r.Core_Datatype__c,'+
        ' Core_Environment_Variable__r.Core_Answers__c, Core_Required__c,Core_Supported_Product__r.name,Core_Supported_Product__r.Core_Supported_Product_Name__c '+
        'FROM Core_IPS_Assigned_Environment_Variables__c WHERE  Core_Supported_Product__r.name=: SUPPORTED_PRODUCT_NAME AND Core_Status__c =  \'Active\' AND '
         + envFilterCondition + ' LIMIT '+ LABEL.Core_RestAPI_SP_Env_DetailV1_Records_Limit;
    
    //Default Constructor
    public Core_RestAPI_SPEnvDetailV1_Handler(DateTime currTime, String APIname){
        
        System.debug('SOQL:'+ GET_ENVIRONMENT_DETAILS_SOQL);
        this.entryTime = currTime;
        this.apiName= APIname;
        response.successContent = new List<SupportedproductEnvDetailsWrapper>();
        System.debug('Core_RestAPI_SPEnvDetailV1_Handler success response'+response.successContent);
    }
    
    //Retrieve specific Supported Product's Environment details for the logged in User
    public Core_RestAPI_Response getEnvironmentDetails(){
        System.debug(' Core_RestAPI_SPEnvDetailV1_Handler getEnvironmentDetails Entered  \n ');
        try{
            //Validations if need to be handled in util class       
            Boolean isRequestValid = doValidations();               
            //Process the api request
            if(isRequestValid == true){
                processRequest();
            }     
        }catch(Exception e){
            Core_RestAPI_Util.processException(e,ERROR_CODE_500,response,apiName,entryTime);
        }finally{    
            System.debug('Core_RestAPI_SPEnvDetailV1_Handler Logging transaction and returning the response '+response);  
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200 ;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        System.debug(' Core_RestAPI_SPEnvDetailV1_Handler getEnvironmentDetails Exiting ');
        return response;
    } 
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        
        System.debug('Core_RestAPI_SPEnvDetailV1_Handler doValidations Invoked '+PRODUCT_ID);
        Boolean isRequestValid = true;
        if (Core_RestAPI_Util.isProductIdValid(PRODUCT_ID)){
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);
            isRequestValid = false;
        }else if(Core_RestAPI_Util.isRequestURIValid(SPEnvDetailV1_URI) == false){
            system.debug('inside isRequestValid ==>> '+isRequestValid );
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        }
        return isRequestValid;
    }
    // Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        
        List<Core_IPS_Assigned_Environment_Variables__c> lstEnvirVariable = new List<Core_IPS_Assigned_Environment_Variables__c>();
        List<Core_IPS_Question__c> lstCoreQuestions = new List<Core_IPS_Question__c>();
        List<Asset> lstSupportedProductName = Database.query(GET_SUPPORTED_PRODUCT_ID);
        if(!lstSupportedProductName.isEmpty()){
            SUPPORTED_PRODUCT_NAME = lstSupportedProductName[0].Core_Supported_Product__r.Name;
            lstEnvirVariable = DATABASE.Query(GET_ENVIRONMENT_DETAILS_SOQL);
            if(!lstEnvirVariable.isEmpty()){
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : lstEnvirVariable){
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); 
                }
                //FLS check added -Venugopal
                if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
                    lstCoreQuestions = [SELECT Id,Name,Core_IPS_Question__c,Core_IPS_Parent_Question__c,Core_IPS_Datatype__c,Core_IPS_Required__c,(select id,Core_IPS_Answer__c,Core_IPS_Parent_Answer__r.Name, Name from Core_Answers__r WHERE Core_IPS_Status__c = 'Active') FROM Core_IPS_Question__c WHERE ID IN: envQuestnIds AND Core_IPS_Status__c = 'Active'];
                }
                    System.debug('lstCoreQuestions--->'+lstCoreQuestions);
                for(Core_IPS_Question__c objAns :lstCoreQuestions){
                    mapQues2Answer.put(objAns.Id,objAns.Core_Answers__r);
                }
                System.debug('Map of Question and Answers'+mapQues2Answer);
                SupportedproductEnvDetailsWrapper objWrapp = new SupportedproductEnvDetailsWrapper ();
                List<EnvironmentDetailsWrapper> objEDWrapp=new List<EnvironmentDetailsWrapper>();
                for(Core_IPS_Assigned_Environment_Variables__c objEnvirVariable: lstEnvirVariable)
                {    
                    objWrapp.intelProductName = lstSupportedProductName[0].Name;
                    objWrapp.intelProductId = lstSupportedProductName[0].Id;
                    EnvironmentDetailsWrapper  objEnvQues = new EnvironmentDetailsWrapper ();
                    objEnvQues.environmentDetailID =objEnvirVariable.Core_IPS_Question__r.Name;
                    objEnvQues.datatype =objEnvirVariable.Core_IPS_Question__r.Core_IPS_Datatype__c;
                    objEnvQues.required =objEnvirVariable.Core_Required__c ;
                    objEnvQues.environmentDetailQuestion= objEnvirVariable.Core_IPS_Question__r.Core_IPS_Question__c ;
                    objEnvQues.parentEnvironmentDetailId = objEnvirVariable.Core_IPS_Question__r.Core_IPS_Parent_Question__r.Name;
                    List<AnswerWrapper > lstAnswers= new List<AnswerWrapper >();
                    if(mapQues2Answer.get(objEnvirVariable.Core_IPS_Question__c) != null)
                        for(Core_IPS_Answer__c objAns : mapQues2Answer.get(objEnvirVariable.Core_IPS_Question__c)){
                            AnswerWrapper answrapp= new AnswerWrapper ();
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
                System.debug('ProcessRequest response.successContent '+response.successContent);
                
            }
        }else{
            Core_RestAPI_Util.processException(null,MALFORMED_INPUT_9011, response, apiName, entryTime); 
        }
        
    }
    
    // Here below EnvironmentDetailsWrapper Wrapper class must implements the interface Core_RestAPI_SuccessContent
    // Wrapper to build fields of Core_IPS_Assigned_Environment_Variables__c Custom object
    public class SupportedproductEnvDetailsWrapper implements Core_RestAPI_SuccessContent{
        
        //Wrapper for Supported Product details
        public String intelProductName {get;set;}
        public String intelProductId {get;set;}
        public List<EnvironmentDetailsWrapper> envDetails {get;set;}
        
    }
    //Wrapper for Environment details
    public class EnvironmentDetailsWrapper {
        public String environmentDetailQuestion  {get;set;}
        public String environmentDetailId {get;set;}
        public String datatype {get;set;}      
        public Boolean required {get;set;}
        public List<AnswerWrapper> answers {get;set;}
        public String parentEnvironmentDetailId{get;set;}
        
    }
    //Wrapper to display answer
    public class AnswerWrapper {
        public String answer {get;set;}
        public String answerId{get;set;}
        public String parentAnswerId{get;set;}
    }
}