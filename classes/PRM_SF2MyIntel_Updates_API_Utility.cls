/**********************************************************************************************************************************
Apex Class Name  : PRM_SF2MyIntel_Updates_API_Utility
Version       : 1.0
Created Date  : DEC 2021
Function      : Utility for SF to MyIntel PRM_SF2MyIntel_Updates_API

Modification Log :
* Developer                				 Date               Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
* Gopikrishna Vankadari            	    15/12/2021         Utility for PRM_SF2MyIntel_Updates_API
************************************************************************************************************************************************/
public class PRM_SF2MyIntel_Updates_API_Utility {
    public static final String LOG_ENTRY_ORIGIN 	 = 'SFDC';
    public static final String LOG_ENTRY_PROJECT 	 = 'SF2myIntel';
    public static final String LOG_ENTRY_SCOPE   	 = 'SF2myIntel API';
    public static final String LOG_ENTRY_ERROR    	 = 'error';
    public static final String LOG_ENTRY_INFO     	 = 'info';
    public static final String STATUS_PENDING     	 ='Pending';
    public static final String STATUS_APPROVED       ='Approved';
    public static final String STATUS_REJECTED       ='Rejected';
    public static final String INCORRECT_EMAIL       ='Incorrect Input Email';
    public static final String MISSING_FIELDS        ='Communites/Email fields are missing in the Input Request';
    public static final String INVALID_FIELDS        ='Attribute not provided/invalid attribute value';
    public static final String CONTACT_DO_NOT_EXIST  ='Contact do not exist in Salesforce';
    public static final String SUCCESS_RESPONSE      ='Request for Community Enrollment Update Submitted Succesfully';
    public static final String ERROR_RESPONSE        ='Error Occured While Processing Your Community Enrollment Update Request';
    
    
    //Retrieves the Snapshot of Community details of associated Contact
    public static void retrieveCommunityDetails(String InputEmail){
        List<Contact> conList =checkContactExistance(InputEmail);
        if(conList!=null &&!conList.isEmpty()){
            for(Contact cont :conList){                                           
                responseMessage(cont.Email,(getCommunityDetails(cont).values()),true);                                
            }
        }  
    }
    
    //Update the Contact IPA Communities based on Input Request
    public static void updateCommunityDetails(String InputEmail,List<composeCommunityDetails>inputDataList){
        //String returnMessage;        
        List<Contact> conList =checkContactExistance(InputEmail);
        //String contactId;
        Map<String,composeCommunityDetails> existingCommunityDetails = new Map<String,composeCommunityDetails>();
        Map<String,Boolean> communitesToUpdate = new Map<String,Boolean>();
       // List<composeCommunityDetails> communityDetailsList = new List<composeCommunityDetails>();
        for(Contact cont:conList){
            existingCommunityDetails=getCommunityDetails(cont);  
            for(composeCommunityDetails comrec :inputDataList){
                if(existingCommunityDetails.get(comrec.CommunityName).IsOptedIn!=comrec.IsOptedIn){
                    communitesToUpdate.put(comrec.CommunityName,comrec.IsOptedIn);
                }                    
            }
            if(communitesToUpdate!=	null && !communitesToUpdate.isEmpty()){
                submitCommunityUpdates(cont.Id,communitesToUpdate);
            }
            else{
                responseDetails(SUCCESS_RESPONSE,true);
            }
        }
        
    }
    
    //Fetch the Community Snapshot for Input Contact
    public static Map<String,composeCommunityDetails> getCommunityDetails(Contact con){
        Map<String,composeCommunityDetails> commMap = new Map<String,composeCommunityDetails>();                
        Set<String> contactCommunities  = new Set<String>();
        Set<String> communityList =new Set<String>();
        communityList.addAll(System.Label.PRM_Available_Communities.split(';')); 
        if(con.Core_IPA_Partner_Community__c!=null){
            contactCommunities.addAll(con.Core_IPA_Partner_Community__c.split(';'));
        }
        for(String communityRecord:communityList){
            composeCommunityDetails ccDetails = new composeCommunityDetails();                
            ccDetails.CommunityName=communityRecord;
            if(contactCommunities.contains(communityRecord)){
                ccDetails.IsOptedIn=true;
            }else{
                ccDetails.IsOptedIn=false;
            }
            commMap.put(ccDetails.CommunityName,ccDetails);
        }                       
        return commMap;
    }
    
    //Check If Contact exists in SF for the provided Email
    public static List<Contact> checkContactExistance(String InputEmail){
        String returnMessage;
        List<Contact> conList =[SELECT Id,Email,Core_IPA_Partner_Community__c FROM Contact WHERE Email =: InputEmail];
        if(conList==null || conList.isEmpty()){      
            returnMessage=CONTACT_DO_NOT_EXIST;
            responseDetails(returnMessage,false); 
        }
        return conList;
    }
    
    //Get the existing enrollment request and update the status according to Input Request 
    public static void submitCommunityUpdates(Id loggedInContactId,Map<String,Boolean> communitesToUpdate){
        List<PRM_Partner_Community_Enrollment_Request__c> enrollmentRequestsToUpdate = new List<PRM_Partner_Community_Enrollment_Request__c>();
        Set<String> newEnrolledCommunities = communitesToUpdate.keySet();     
        Set<String> updatedEnrollments = new Set<String>();
        List<PRM_Partner_Community_Enrollment_Request__c>existingEnrollments=[Select PRM_Partner_Community_Nm__c from PRM_Partner_Community_Enrollment_Request__c where PRM_Contact_Id__c = :loggedInContactId And (PRM_Status_Nm__c =:STATUS_PENDING OR PRM_Status_Nm__c=:STATUS_APPROVED OR PRM_Status_Nm__c=:STATUS_REJECTED)];
        if(existingEnrollments.size()>0 && !existingEnrollments.isEmpty()){                           
            processEnrollmentRequests(existingEnrollments, communitesToUpdate, 'Integration User', 'ERPM.OBM Integration', 'IPA Registration Integration User', 'STATUS_APPROVED', 'STATUS_REJECTED', userInfo.getUserEmail(), updatedEnrollments, enrollmentRequestsToUpdate);                                                    
            /*for(PRM_Partner_Community_Enrollment_Request__c enrollmentRequest: existingEnrollments){
                if(communitesToUpdate.containsKey(enrollmentRequest.PRM_Partner_Community_Nm__c)){
                    if(communitesToUpdate.get(enrollmentRequest.PRM_Partner_Community_Nm__c)) {
                        enrollmentRequest.PRM_Status_Nm__c=STATUS_APPROVED;
                        enrollmentRequestsToUpdate.add(enrollmentRequest);
                        updatedEnrollments.add(enrollmentRequest.PRM_Partner_Community_Nm__c);
                    }else{
                        enrollmentRequest.PRM_Status_Nm__c=STATUS_REJECTED;
                        if(userInfo.getName() == 'Integration User' || userInfo.getName() == 'ERPM.OBM Integration' || userInfo.getName() == 'IPA Registration Integration User'){
                            enrollmentRequest.PRM_Community_Change_Agent__c = enrollmentRequest.PRM_Contact_Id__r.Email;}
                            else{
                                enrollmentRequest.PRM_Community_Change_Agent__c = userInfo.getUserEmail();
                            }
                        enrollmentRequestsToUpdate.add(enrollmentRequest);
                        updatedEnrollments.add(enrollmentRequest.PRM_Partner_Community_Nm__c);
                    }
                }
            } */                                       
        }
        newEnrolledCommunities.removeAll(updatedEnrollments);
        if(enrollmentRequestsToUpdate.size()>0 ||newEnrolledCommunities!=null){   
            submitCommunityEnrollmentRequest(loggedInContactId,newEnrolledCommunities,enrollmentRequestsToUpdate);
        }
    }
    public static void processEnrollmentRequests(List<PRM_Partner_Community_Enrollment_Request__c> existingEnrollments,
                                      Map<String, Boolean> communitesToUpdate,
                                      String integrationUser1,
                                      String integrationUser2,
                                      String integrationUser3,
                                      String statusApproved,
                                      String statusRejected,
                                      String defaultEmail,
                                      Set<String> updatedEnrollments,
                                      List<PRM_Partner_Community_Enrollment_Request__c> enrollmentRequestsToUpdate) {
    for (PRM_Partner_Community_Enrollment_Request__c enrollmentRequest : existingEnrollments) {
        if (communitesToUpdate.containsKey(enrollmentRequest.PRM_Partner_Community_Nm__c)) {
            if (communitesToUpdate.get(enrollmentRequest.PRM_Partner_Community_Nm__c)) {
                enrollmentRequest.PRM_Status_Nm__c = statusApproved;
            } else {
                enrollmentRequest.PRM_Status_Nm__c = statusRejected;
                if (userInfo.getName() == 'Integration User' || userInfo.getName() == 'ERPM.OBM Integration' || userInfo.getName() == 'IPA Registration Integration User') {
                    enrollmentRequest.PRM_Community_Change_Agent__c = enrollmentRequest.PRM_Contact_Id__r.Email;
                } else {
                    enrollmentRequest.PRM_Community_Change_Agent__c = defaultEmail;
                }
            }
            enrollmentRequestsToUpdate.add(enrollmentRequest);
            updatedEnrollments.add(enrollmentRequest.PRM_Partner_Community_Nm__c);
        }
    }
    }
    //Create or Update Community Enrollment Request based on the Input Request
    public static void submitCommunityEnrollmentRequest(String loggedInContactId,Set<String> newCommunites,List<PRM_Partner_Community_Enrollment_Request__c> enrollmentRequestsToUpdate){       
        //List<PRM_Partner_Community_Enrollment_Request__c> newEnrollmentRequests = new List<PRM_Partner_Community_Enrollment_Request__c>();
        if(newCommunites!=null && !newCommunites.isEmpty()){
            for(Object comm: newCommunites){
                String communityName = String.valueOf(comm);              
                PRM_Partner_Community_Enrollment_Request__c newEnrollmentRequest = new PRM_Partner_Community_Enrollment_Request__c();
                newEnrollmentRequest.PRM_Contact_Id__c = loggedInContactId;
                newEnrollmentRequest.PRM_Partner_Community_Nm__c = communityName;
                newEnrollmentRequest.PRM_Status_Nm__c = STATUS_PENDING;
                newEnrollmentRequest.PRM_Start_Date_Dt__c=System.now();            
                enrollmentRequestsToUpdate.add(newEnrollmentRequest);
            }
        }        
        if(enrollmentRequestsToUpdate.size()>0){
            try{
                upsert enrollmentRequestsToUpdate;
                responseDetails(SUCCESS_RESPONSE,true);
            }
            catch(Exception e){
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_ERROR,ERROR_RESPONSE,null,null,null,null,e);
                responseDetails(ERROR_RESPONSE,false);
            }
        }      
    }
    
    public static void responseMessage(String InputEmail,List<composeCommunityDetails>communityDetails,Boolean isSuccess){
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        ResponseWrapper resWrap =new ResponseWrapper(InputEmail,communityDetails,isSuccess);        
        res.responseBody = Blob.valueOf(JSON.serialize(resWrap));
    } 
    
    public static void responseDetails(String returnMessage,Boolean isSuccess){
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');  
        ErrorResponseWrapper resWrap =new ErrorResponseWrapper(); 
        resWrap.Message=returnMessage;
        resWrap.IsSuccess=isSuccess;
        res.responseBody = Blob.valueOf(JSON.serialize(resWrap));
    }
    
    //Wrapper class to store Input for API Community  details 
    public class FetchInputDetails{         
        public String EmailId;
        public String Attribute;
        public List<composeCommunityDetails> CommunityDetails;		
    } 
    
    public class ResponseWrapper {
        public String EmailId;
        public Boolean IsSuccess;
        public List<composeCommunityDetails> CommunityDetails;    
        public ResponseWrapper(String InputEmail,List<composeCommunityDetails> InputCommunityDetails,Boolean inputValue){
            EmailId=InputEmail;
            CommunityDetails=InputCommunityDetails;
            IsSuccess=inputValue;
        }
    } 
    public class composeCommunityDetails{        
        public Boolean IsOptedIn;
        public String CommunityName;
    }    
    public class ErrorResponseWrapper {
        public String Message;
        public Boolean IsSuccess;       
    } 
}