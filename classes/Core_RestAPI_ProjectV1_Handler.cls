/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectV1_Handler 
* Version     : 1.0 
* Created Date: 20 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/20/2017               Handler class to process request and response for the projects API
*****************************************************************************************************************************************/
public  with sharing class Core_RestAPI_ProjectV1_Handler {
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private DateTime entryTime = null;
    private String apiName;
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    
    private static final String GET_PROJECTS_SOQL = 'SELECT Core_IPS_Project_ID__c,Name,Core_Status__c '+
        'FROM Core_IPS_Project__c ORDER BY Core_IPS_Project_ID__c DESC LIMIT'+ ' '+Label.Core_RestAPI_ProjectsV1_Records_Limit;
    
    //Default Constructor
    public Core_RestAPI_ProjectV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName= APIname;
        response.successContent = new List<ProjectWrapper>();
    }
    
    //Retrieve Projects for the logged in User
    public Core_RestAPI_Response getProjects(){
        try{
            //Validations if need to be handled in util class      
            Boolean isRequestValid = doValidations();
            //Process the api request
            if(isRequestValid == true)
                processRequest();
        }catch(Exception e){
            Core_RestAPI_Util.processException(e,ERROR_CODE_500,response,apiName,entryTime);
        }finally{  
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        return response;
    } 
    
    // Validation if any for the API goes here
    @testVisible
    private Boolean doValidations(){
        Boolean isRequestValid = true; 
        return isRequestValid;
    } 
    
    // Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        
        // In this for loop retrieving fields of Core_IPS_Project__c Custom Object
        for(Core_IPS_Project__c objProj: DATABASE.Query(GET_PROJECTS_SOQL))
        {  
            ProjectWrapper objProjectWrapp = new ProjectWrapper();
            objProjectWrapp.ipsProjectName = objProj.Name;
            objProjectWrapp.ipsProjectId = objProj.Core_IPS_Project_ID__c;
            objProjectWrapp.status=objProj.Core_Status__c;        
            response.successContent.add(objProjectWrapp);
        }
    }       
    // Here below ProjectWrapper Wrapper class must implements the interface Core_RestAPI_SuccessContent
    // Wrapper to build name,status and ProjectId structure
    public class ProjectWrapper  implements Core_RestAPI_SuccessContent{
        
        public String ipsProjectName {set;get;}
        public String status {get;set;}
        public String ipsProjectId {get;set;}
        
    }
}