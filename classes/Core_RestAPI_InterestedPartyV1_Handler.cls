/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_InterestedPartyV1_Handler 
* Version     : 1.0 
* Created Date: 11 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/11/2017               Handler class for process request and reponse for the intereseted parites API
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_InterestedPartyV1_Handler {
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private DateTime entryTime = null;
    private String apiName = null;
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private static final String filterCondition = ' WHERE '+Core_RestAPI_Util.getConditionWithURIParam('Case__r.CaseNumber', 3);
    private String InterestedPartyV1_URI ='/v1.0/cases/*/interestedparties';
    private String INVALID_URI_404= '404';
    
    public static final String GET_INT_PARTIES_SOQL = ' SELECT  Name, Core_IPS_Account_Name__c, Active__c, Agent_Name__c, Contact__r.Name, Email__c, First_Name__c, Last_Name__c, Type__c, User__r.Name '+
        ' FROM Core_IPS_Case_Interested_Party__c '+filterCondition+ ' AND Type__c = \'External\' AND Active__c = true AND Case__r.Core_IPS_Customer_Visible__c = true ORDER BY Name DESC LIMIT '+Label.Core_RestAPI_Interested_Parties_Records_Limit;
    
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    
    public Core_RestApi_InterestedPartyV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName = APIname;
        System.debug(' INtialization completed CASE_NUMBER '+CASE_NUMBER+' filterCondition '+filterCondition);
    }
    
    //returns all interested parties for the given case number
    public Core_RestAPI_Response getInterestedParties(){
        try{
            //process all validations and skip processing the request if validations fails.
            boolean isRequestValid = doValidations();
            if(isRequestValid == true){
                processRequest();
            } 
            
        }catch(Exception e){
            response.successContent = null;
            System.debug(LoggingLevel.ERROR, 'Core_RestApi_InterestedPartyV1_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));    
            Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime);
        }finally{         
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        return response;
    } 
    
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        System.debug('Core_RestAPI_CaseV1_Handler doValidations Invoked ');
        Boolean isRequestValid = true;
        //List<Case> caseList = [Select Id FROM CASE Where CaseNumber =: CASE_NUMBER Limit 1];
        if(!CASE_NUMBER.isNumeric() || ( CASE_NUMBER != null && CASE_NUMBER.length() != 8 )){
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);  
            isRequestValid = false;
        }else if(Core_RestAPI_Util.isRequestURIValid(InterestedPartyV1_URI) == false){
            system.debug('inside isRequestValid ==>> '+isRequestValid );
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        } 
        return isRequestValid;
    }
    
    //Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        
       System.debug(' Core_RestApi_InterestedPartyV1_Handler Entered  getInterestedParties  \n SOQL'+GET_INT_PARTIES_SOQL);
        response.successContent = new List<InterstedPartyWrapper>();
        InterstedPartyWrapper ipWrpr = null;
        List<Core_IPS_Case_Interested_Party__c> lstInterestedParty = Database.query(GET_INT_PARTIES_SOQL);
        if(!lstInterestedParty.isEmpty()){
            for(Core_IPS_Case_Interested_Party__c ip : lstInterestedParty ){
                ipWrpr = new InterstedPartyWrapper();
                ipWrpr.accountName = ip.Core_IPS_Account_Name__c;
                ipWrpr.email = ip.Email__c;
                ipWrpr.firstName = ip.First_Name__c;
                ipWrpr.lastName = ip.Last_Name__c;
                response.successContent.add(ipWrpr);
            }
        }
        
        System.debug(' Core_RestApi_InterestedPartyV1_Handler Exited ');
    }
    
    //wrapper class for the response fields    
    public class InterstedPartyWrapper  implements Core_RestAPI_SuccessContent{
        public String accountName {get;set;}
        public String email {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
    }
    
}