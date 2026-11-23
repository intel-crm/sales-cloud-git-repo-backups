/****************************************************************************************************************************************
* Class Name  : Core_RestApi_IP_CreateV1_Handler
* Version     : 1.0 
* Created Date: 12 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/11/2017              creates interested parties 
*****************************************************************************************************************************************/
public  with sharing class Core_RestAPI_IP_CreateV1_Handler {
    private DateTime entryTime = null;
    private String apiName = null;
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private Case caseObj =  null;
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    public User userinfoObj = null;
    
    private Core_RestAPI_IP_CreateV1_Wrapper intPartyWrapper = null;
    private User userObj = null;
    private Contact contactObj = null;
    
    public Core_RestAPI_IP_CreateV1_Handler(DateTime currTime, String APIname, Core_RestAPI_IP_CreateV1_Wrapper ipWrpr){
        this.entryTime = currTime;
        this.apiName = APIname;
        this.intPartyWrapper = ipWrpr;
        System.debug(' Initialization completed CASE_NUMBER '+CASE_NUMBER);
        response.successContent = new List<SuccessResponse>();
        userinfoObj = [Select Id, Name, ContactId FROM User where id =: UserInfo.getUserId()];
        init();
    }
    
    private Map<String, Contact> mUserName_Contact = new Map<String, Contact>();
    
    //Initialization method-  query all the required sobject records for processing and validation s
    private void init(){
        List<User> lUsers =  [Select ContactId From User where Username =:intPartyWrapper.userName Limit 1];
        if(lUsers.size() > 0)
            userObj = lUsers[0];
        
        List<Contact> lContacts = [Select Id, Name From Contact where Id =: userObj.ContactId Limit 1] ;
        if(lContacts.size() > 0)
            contactObj = lContacts[0];
    }
    
    //returns all interested parties for the given case number
    public Core_RestAPI_Response createInterestedParties(){
        boolean isRequestValid = null;
        try{
            //process all validations and skip processing the request if any validations fails.
            isRequestValid = doValidations();
            
            //Process the request if all validations pass
            if(isRequestValid == true)
                processRequest();
            
        }catch(Exception e){
            response.successContent = null;
            System.debug(LoggingLevel.ERROR, 'Core_RestApi_InterestedPartyV1_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));    
            Core_RestAPI_Util.processException(e, '500', response, apiName, entryTime);
        }finally{         
            if(String.isBlank(response.code))
                response.code = '200';
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }    
        System.debug(' Validations Passed ? : '+isRequestValid+ ' \n Response '+Json.serializePretty(response));
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        
        Boolean  isCaseNumberValid = Core_RestAPI_Util.isCaseNumberValid(CASE_NUMBER);
        if(isCaseNumberValid == false)
            Core_RestAPI_Util.processException(null ,'9011', response, apiName, entryTime);   
        if(checkAccesbbility() == false)
            Core_RestAPI_Util.processException(null ,'9011', response, apiName, entryTime);   
        return (isCaseNumberValid && isCaseFound()  && hasValidContact() && checkAccesbbility());
    }
    
    //Process the request 
    private void processRequest(){
        List<Core_IPS_Case_Interested_Party__c> newInterstedPartiesList = new list<Core_IPS_Case_Interested_Party__c>();
        if(intPartyWrapper != null) {
            //Map holds contact id and the user id
            
            Core_IPS_Case_Interested_Party__c intParty = new Core_IPS_Case_Interested_Party__c();
            intParty.Contact__c = contactObj.Id;
            intParty.Case__c = caseObj.Id;
            intParty.Type__c = 'External';
            intParty.Active__c = true;
            //Id contId = ipw.contactId;
            //TODO what if the contact has no user record.
            intParty.User__c = userObj.Id;
            newInterstedPartiesList.add(intParty);
            
            //System.debug(' mContactId_UserId '+mContactId_UserId);
            System.debug(' newInterstedPartiesList '+newInterstedPartiesList);
            upsert newInterstedPartiesList;
            for(Core_IPS_Case_Interested_Party__c ips : [Select Name FROM Core_IPS_Case_Interested_Party__c Where Id IN : newInterstedPartiesList]){
                SuccessResponse sr = new SuccessResponse();
                sr.interestedPartyId = ips.Name;
                response.successContent.add(sr);
            }
        }
        System.debug('  Core_RestApi_CreateIPV1_Handler processRequest Start '+newInterstedPartiesList);
    }
    
    
    //New method for All case validation GEC , not closed cased, accessible , editable, Check to reuse any available methods. move to Util
    private Boolean isCaseFound(){
        Boolean caseFound = true;
        List<Case> caseList = [Select Id FROM CASE Where CaseNumber =: CASE_NUMBER Limit 1];
        //TODO Check if case is associate to account
        if(caseList.isEmpty()){
            Core_RestAPI_Util.processException(null ,'9013', response, apiName, entryTime);   
            caseFound = false;
        }else{
            caseObj = caseList[0];
        }
        return caseFound;
    }
    
    //Check if the record is editable access to the User
    public Boolean checkAccesbbility(){
        return [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfoObj.Id AND RecordId = :caseObj.id].HasEditAccess;
    }
    
    
    
    //Validate if the user has a valid contact and does not have an existing interested party created
    private Boolean hasValidContact(){
        Boolean contactValid = true;
        
        System.debug('contactObj >>  '+contactObj);
        
        //Verify all the contact ids passed in the request are valid, exists and accessible
        if(contactObj == null){
            Core_RestAPI_Util.processException(null ,'9013', response, apiName, entryTime);   
            //Override the custom message
            response.errorContent.errorMessage = ' User\'s contact is invalid or does not exist or not accessible ';
            System.debug(response.errorContent.errorMessage );                
            return false;
        }
        
        
        for(Core_IPS_Case_Interested_Party__c ip : [Select Contact__c FROM Core_IPS_Case_Interested_Party__c where Contact__c  =: contactObj.Id] ){
            Core_RestAPI_Util.processException(null ,'9011', response, apiName, entryTime);   
            //Override the custom message
            response.errorContent.errorMessage = ' Contact already an existing active intereseted party '+ contactObj.Id;
            //Duplicates Found
            contactValid = false;
            System.debug('Existing contact ids '+response.errorContent.errorMessage);                
            break;
        }
        return contactValid;
    }
    
    //Wrapper class for the success response
    public class SuccessResponse implements Core_RestAPI_SuccessContent{
        String interestedPartyId{get;set;}
    }
    
}