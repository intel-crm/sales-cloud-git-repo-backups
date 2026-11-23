public class Sample_Core_SupportedPrdt_Hndlr {
    /*private DateTime entryTime = null;
    private String sObjectName; 
    private String condition{get;set;}
    private static final String SOBJECT_NAME ='Case';
    private static final String ORDER_BY =' Order by CaseNumber DESC ';
    public SKPOC_RestAPI_Response response = new SKPOC_RestAPI_Response();
    List<String> columnNames = new List<String> ();
    
    private static final String GET_CASES_SOQL = ' SELECT CaseNumber,nikhil,Status, Core_Sub_Status__c, Core_Severity__c, Core_IPS_Project_Case__r.Name, Core_IPS_Product__c, '+
        ' Subject, Contact.Name, Contact.Account.Name, CreatedDate, ClosedDate  '+
        ' FROM case '+ Core_RestAPI_Util.getCondition() + ORDER_BY + Core_RestAPI_Util.RECORD_LIMIT ;
    
    public Core_RestAPI_SupportedProduct_Handler (DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.sobjectName = APIname;
        this.condition = '';
        response.successContent = new List<EnvironmentDetails>();
        System.debug('Core_RestAPI_Case_Handler SOQL '+GET_CASES_SOQL);
        
    }
    
    
    //Retrieve cases for the logged in User
    public SKPOC_RestAPI_Response getEnvironmentDetails(){
        
        try{
            //Validations if need to be handled in util class      
            boolean isRequestValid =null;// doValidations();
            
            //Process the api request
            //if(isRequestValid == true)
            processRequest();
            
        }catch(Exception e){
            //Core_RestAPI_Util.processException(e, response,sObjectName,entryTime);
        }finally{
            System.debug('Core_RestAPI_Case_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = '200';
            
            
        }        
        return response;
    } 
   
    public void  processRequest(){
        String supportedProdName = 'SP-0000001615';
        EnvironmentDetails  wrpr = new EnvironmentDetails();
        List<Core_IPS_Assigned_Environment_Variables__c> envDetails = [Select Id, Name, Core_Environment_Variable__c, Core_Environment_Variable__r.Name, 
                                                                       Core_Type__c, Core_Required__c 
                                                                       FROM Core_IPS_Assigned_Environment_Variables__c 
                                                                       Where Core_Supported_Product__r.Name =:supportedProdName];
        System.debug(' Env Details  '+envDetails);
        for(Core_IPS_Assigned_Environment_Variables__c env : envDetails){
            wrpr.supportedProductName = env.name;
            wrpr.environmentDetailQuestion = env.Core_Environment_Variable__r.Name;
            wrpr.environmentDetailID = env.Id;
            wrpr.datatype = env.Core_Type__c;
            wrpr.required = env.Core_Required__c;
            response.successContent.add(wrpr);
        }
    } 
    
    
    public class EnvironmentDetails implements Core_RestAPI_ResponseContent{
        public String supportedProductName {get;set;}
        public String environmentDetailQuestion {get;set;}
        public String environmentDetailID {get;set;}
        public String datatype {get;set;}
        public Core_RestAPI_ResponseContent answers {get;set;}
        public Boolean required {get;set;}
    }
    
    public class Answers implements Core_RestAPI_ResponseContent{
        
    }*/
}