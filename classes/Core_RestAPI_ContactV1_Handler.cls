/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ContactV1_Handler 
* Version     : 1.0 
* Created Date: 24 May 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         05/24/2018               Handler class for process request and reponse for the contacts API
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_ContactV1_Handler {
    
    private String ERROR_CODE_500 = '500';
    private String UNAUTHORIZED_9005='9005';
    private String SUCCESS_CODE_200 = '200';
    private DateTime entryTime = null;
    private String apiName; 
    
    private static String  condition = 'contact.Core_IPS_Active__c = true AND IsActive =true AND AccountId = ';  
    public Core_RestAPI_AccountWrapper response = new Core_RestAPI_AccountWrapper ();
    private static User objuser= null;
    private static string accId = null;
    private static final String GET_CONTACT_SOQL = 'SELECT id,name ,IsActive  ,accountId ,account.name ,contact.id ,contact.Core_IPS_Active__c , '+
        'contact.Email ,contact.FirstName ,contact.LastName FROM user WHERE '+ condition ;
    
    public Core_RestAPI_ContactV1_Handler(DateTime currTime, String APIname){
        System.debug('GET_CONTACT_SOQL --->'+GET_CONTACT_SOQL );
        this.entryTime = currTime;
        this.apiName = APIname;
        
        system.debug(' UserInfo.getUserId() ==>> '+UserInfo.getUserId());
        objuser = [Select AccountId,IsActive FROM User where Id =: UserInfo.getUserId() limit 1];
        system.debug(' objuser==>> '+objuser);
        System.debug('Core_RestAPI_ContactsV1_Handler  URI '+RestContext.request.requestURI  );
    }
    
    //Retrieve contacts for the logged in User
    public Core_RestAPI_Response getContacts(){
        try{
            boolean isRequestValid = doValidations();
            system.debug('objuser.AccountId ====>> '+objuser.AccountId);
            if(objuser.AccountId != null){
                accId = objuser.AccountId;
            }else{
                Core_RestAPI_Util.processException(null , UNAUTHORIZED_9005, response, apiName, entryTime);
                isRequestValid = false;
            }
            //Validations if need to be handled in util class      
            //Process the api request
            if(isRequestValid == true)
                processRequest();
            
        }catch(Exception e){
            Core_RestAPI_Util.processException( e, ERROR_CODE_500, response, apiName, entryTime);
            response.successContent = null;
        }finally{
            System.debug('Core_RestAPI_ContactV1_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200 ;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        System.debug('Core_RestAPI_ContactV1_Handler doValidations Invoked ');
        Boolean isRequestValid = true;
        return isRequestValid;
    }
    
    //Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        System.debug('Core_RestAPI_ContactV1_Handler  processRequest ');
        string get_contact_soql = GET_CONTACT_SOQL +'\''+accId+'\'' + 'LIMIT '+Label.Core_RestAPI_ContactsV1_Records_Limit;
        system.debug('get_contact_soql ==>> '+get_contact_soql );
        List<user> lstCon = Database.Query(get_contact_soql);
        system.debug('lstCon  ===>> '+lstCon );
        
        
        response.accountName= lstCon[0].Account.Name;
        response.accountId= String.valueOf(lstCon[0].AccountId);
        response.listCount= lstCon.size();
        response.url= RestContext.request.requestURI ;
  
        List<ContactWrapper> lstCont = new List<ContactWrapper>();
        if(!lstCon.IsEmpty()){
            for(user u : lstCon)
            {  
                ContactWrapper cw = new ContactWrapper();
                cw.firstName= u.contact.FirstName;
                cw.lastName= u.contact.LastName;
                cw.email= u.contact.Email;
                cw.id= u.contact.id;
                lstCont.add(cw);
            }
        }
        response.successContent=lstCont;    
    }
    
    //Adding additional fields to actual response
    public class Core_RestAPI_AccountWrapper extends Core_RestAPI_Response{
        String accountName{get;set;}
        String accountId{get;set;}
        Integer listCount{get;set;}
        String url{get;set;}
    }
    public class ContactWrapper implements Core_RestAPI_SuccessContent{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String email{get;set;}
        public String id{get;set;}
    }
}