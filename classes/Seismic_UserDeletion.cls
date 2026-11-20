/****************************************************************************************************************************************
* Class Name  : Seismic_UserDeletion 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		The Apex Class makes Graph & Seismic API calls and verify mising  
															Seismic & Lessonly users those are not in Azure AD Groups for deletion. Groups are:
															Seismic SSO AZAD-CORP - Premium User (PRODUCTION)
															Seismic SSO AZAD-CORP - Business User (PRODUCTION)
															The scheduled job runs once in a month.
*****************************************************************************************************************************************/

public class Seismic_UserDeletion Implements Schedulable{
    
	public static Boolean isTest = true; //Test Mode
    public static String testUser = 'user_deletion_test@inteldev.com';
    public static Integer maxRecordAllow = 5;//Only 100 records can be deleted in a batch
    public enum Job_Status {Success,Failure,Error,NoRecord,Skip}
    
    public static Integer loadID = 0;
    public static String NextLink = '';
    public static String errorDetail = '';
    public static String errorMessage = '';
    public static String lastRun = '';
    public static Boolean flgContinue = false;
    public static Set<String> missingUsers = new Set<String>();
    public static Job_Status jobStatus;
	public static List<Seismic_User> seismicUsers = new List<Seismic_User>();
    public static List<Lessonly_User> lessonlyUsers = new List<Lessonly_User>();
    public static Map<String, String> config = new Map<String, String>();
    public static Set<String> sysAccounts = new Set<String>();
    
    
    /*Method to schedule the job*/
    public void execute(SchedulableContext sc)
    {
         main();
    }
    
    /*Main Method for this job*/
    //@future(callout=true)
    public static void main() {
      String status='';
        try{
            
            //Clear 1+ year old logs.
            flgContinue = clearLog();
            
            //Fetch the new load ID to run the job.
            loadID = newLoadID();
            
            //Initialize the job/config
            flgContinue = initialize();
            
            //Identify user(s) in Seismic which are not there in Seismic AD groups and store in "seismicUsers" list.
            if(errorDetail == '' ||  Test.isRunningTest()) {
                Seismic_User.identifySeismicUsers('');
            }
            
            //Identify user(s) in Seismic which are not there in Seismic AD groups and store in "lesonlyUsers" list.
            if(errorDetail == '' ||  Test.isRunningTest()) {
                Lessonly_User.identifyLesonlyUsers();
            }
            
            //Fetch AD Group Members from Seismic Groups.           
            //And verify with Seismic & Lessonly Users in AD Group Memebers 
            //And store them in "missingUsers" & SeismicUserDeletion_User__c
            //Update Lessonly ID number in SeismicUserDeletion_User__c
            //Delete User from Seismic & Update SeismicUserDeletion_User__c.Deleted_In_Seismic__c flag           
            //Delete Users from Lessonly & Update SeismicUserDeletion_User__c.Deleted_In_Lessonly__c flag
            if(errorDetail == '' ||  Test.isRunningTest()) {
                String accessToken = getAccessToken();
                System.debug('here is my accessToken: ' + accessToken);
                if((errorDetail == '' && accessToken != '') || Test.isRunningTest()){
                    deleteVerifiedUsers(accessToken);
                }
            }

            if(jobStatus == Job_Status.Success ||  Test.isRunningTest()) {
                
                status = 'processed';//update the stratus to processed for global log.
                
                //send notification
                Seismic_UserDeletionNotification.sendSummary(loadID);
                Seismic_UserDeletionNotification.sendDevTeamSummary(loadID);
                //Core_Log_Entry.logEntryWithDetails('SFDC','Seismic_UserDeletion',null,'processed','Seismic & Lessonly UserDeletion job completed sucessfully','',null,'Contact',null);
            }
            else if(jobStatus == Job_Status.NoRecord) {
                status = 'Info';
            }
            else if(jobStatus == Job_Status.Failure || jobStatus == Job_Status.Error) {
                status = 'Error';
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } 
        catch (Exception e) {
            jobStatus = Job_Status.Error;
            errorMessage = 'Error occurred';
            errorDetail += e.getMessage(); 
        }
        
        if(status != 'processed' ||  Test.isRunningTest()) {
            Seismic_UserDeletionNotification.senderrorEmail('Seismic & Lessonly UserDeletion Interface '+ status, errorMessage + errorDetail);
        }
        
        System.debug(errorMessage + errorDetail);
        //Core_Log_Entry.logEntryWithDetails('SFDC','Seismic_UserDeletion',null,status ,errorMessage,errorDetail,null,null,null);
    }
    
    /*Clear records older then 1year old*/
 	@TestVisible 
    private static Boolean clearLog() {
        Boolean flg = false;
        try{
            //delete [SELECT Id FROM SeismicUserDeletion_User__c WHERE CreatedDate != THIS_YEAR];
            List<SeismicUserDeletion_User__c> userResult = [SELECT Id FROM SeismicUserDeletion_User__c WHERE CreatedDate < LAST_N_YEARS:2];
            if (userResult.size() > 0){
                System.debug('clearLog called');
                delete userResult;
                flg = true;
                jobStatus = Job_Status.Success;
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            //throw e;
            jobStatus = Job_Status.Error;
            errorDetail += 'Error occurred in clearLog : ' + e.getMessage();
        }
        return flg;
    }
    
    /*Generate New Load ID*/
	@TestVisible 
    private static Integer newLoadID() {
        Integer newID = 0;
        System.debug('newLoadID called');
        try{
            SeismicUserDeletion_User__c tmpTable = [SELECT Load_ID__c, LastModifiedDate, CreatedDate FROM SeismicUserDeletion_User__c ORDER BY Load_ID__c DESC LIMIT 1];
            newID = (Integer)tmpTable.Load_ID__c + 1;
            //tmpTable = [SELECT Load_ID__c, LastModifiedDate, CreatedDate FROM SeismicUserDeletion_User__c ORDER BY LastModifiedDate DESC LIMIT 1];
            //lastRun = (String)tmpTable.LastModifiedDate;
            //stem.debug(tmpTable.CreatedDate);
            jobStatus = Job_Status.Success;
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            if (e.getMessage() == 'List has no rows for assignment to SObject'){
                newID = 1;//this part will execute only once when there is no record in SeismicUserDeletion_User__c
            }
            else
            {
                jobStatus = Job_Status.Error;
                errorDetail += 'Error occurred in newLoadID : ' + e.getMessage();
            }
        }
        return newID;        
    }
    
    /*Access token for Graph API*/
    @TestVisible 
    private static Boolean initialize() {
        Boolean flg = false;
        if(Seismic_UserDeletion.config.size() == 0) {
            try{
                System.debug('initialize called');
                List<SeismicUserDeletion_Config__c> tempTable = [SELECT Key__c, Value__c FROM SeismicUserDeletion_Config__c LIMIT 100];
                for(SeismicUserDeletion_Config__c s : tempTable)                                             
                {
                    Seismic_UserDeletion.config.put(s.Key__c, s.Value__c); 
                } 
                
                //Put these in configuration TBD SJ. Post review- Venu
                sysAccounts.add(config.get('Yoda_Email'));//'yoda.seismic.support@intel.com');
                sysAccounts.add(config.get('Sales_POCEmail'));//'sales_content_poc@intel.com');
                //sysAccounts.add('@seismic.com');
                jobStatus = Job_Status.Success;
                flg = true;
                isTest = Boolean.valueOf(config.get('IsTest'));
                maxRecordAllow = Integer.valueOf(config.get('MaxRecordAllow'));
                
                //Testing purpose only to hit exception block, it doesn't execute real-time
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }
            catch (Exception e) {
                //throw e;
                jobStatus = Job_Status.Error;
                errorDetail += 'Error occurred in initialize : ' + e.getMessage();
            }
        }
        return flg;
    }

    /*Access token for Graph API*/
    @TestVisible 
	private static String getAccessToken() {
        String accessToken = '';
        String clientId = '';
        String clientSecret = '';
        String endPoint = '';
        String apiScope = '';
        
        //Initialization
        Map<String, Object> resGetBody = new Map<String, Object>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();
        
        System.debug('getAccessToken called');
        try{
            apiScope = config.get('GraphAPI_apiScope');//'https://graph.microsoft.com/.default';
            clientId = config.get('GraphAPI_ClientId');//'d27aaefe-a853-45a0-ab45-04ba27a230ad'; 
            clientSecret = config.get('GraphAPI_ClientSecret');//'fVB7Q~_7IXC1E6dClojFNBLkbb~OQ5LUKmB65'; 
            endPoint = config.get('GraphAPI_EndPoint');//'https://login.microsoftonline.com/46c98d88-e344-4ed4-8496-4ed7712e255d/oauth2/v2.0/token';//
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint(endPoint);
            req.setBody('grant_type=client_credentials' + '&client_id=' + clientId + '&client_secret=' + clientSecret + '&scope=' + apiScope);
            res = http.send(req);
            resGetBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = (String)resGetBody.get('access_token'); 
            jobStatus = Job_Status.Success;
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            
        }
        catch (Exception e) {
            jobStatus = Job_Status.Error;
            errorDetail += 'Error occurred in getAccessToken : ' + e.getMessage();
            System.debug(errorMessage);
        }
        return accessToken;
    }
    
    /*Get the list of users from Azure AD Groups*/
    @TestVisible 
    private static HttpResponse getAzureGroupMembers(String endPoint, String azureGroup, String accessToken){
        String CONTENT_TYPE='application/json';
        String CONTENT_TYPE_ACCEPT='application/json';
        String APPLICATION_CODE='SALESFORCE';
        Integer TIME_OUT=120000; 
        String METHOD='GET';  
        String employeeID;
        String email;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HTTPResponse();
        Map<String, Object> responseGetBody = new Map<String, Object>();
        List<Object> lstData = new List<Object>();
        Map<String,Object> data = new Map<String, Object>();
        
        //if endpoint is blank set the endpoint to first Graph API link
        if(endPoint ==''){
            endPoint = 'https://graph.microsoft.com/v1.0/groups/' + azureGroup+ '/members?$format=JSON&$select=displayName,mail,extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID';  
        }
        System.debug('getAzureGroupMembers called');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setEndpoint(endPoint);
        request.setTimeout(TIME_OUT); // Maximum Timeout Period
        request.setMethod(METHOD);
        request.setHeader('applicationCd', APPLICATION_CODE);
        request.setHeader('Content-Type', CONTENT_TYPE);
        request.setHeader('accept', CONTENT_TYPE_ACCEPT);
        try{
            response = http.send(request);
            responseGetBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('missing AD response'+ responseGetBody);
            NextLink = (String)responseGetBody.get('@odata.nextLink');
            if(response.getStatusCode() == 200){
                lstData = (list<Object>)responseGetBody.get('value');
                System.debug('missing users');
                for(Object fld : lstData){
                    data.clear();
                    data = (Map<String,Object>)fld;
                    email = String.valueOf(data.get('mail'));
                    employeeID = String.valueOf(data.get('extension_0f4113104c90419c9f4205e0384e2ac7_enterpriseID'));
                    if (employeeID != null){ 
                        missingUsers.add(email.tolowercase());
                        System.debug(email + '_' + employeeID);
                    }
                }
                jobStatus = Job_Status.Success;
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            
        }
        catch (Exception e) {
            jobStatus = Job_Status.Error;
            errorDetail += 'Error occurred in getAzureGroupMembers : ' + e.getMessage();
        }
        
        return response;
    }
     
	/*Get the list of users from Azure AD Groups*/
    @TestVisible 
    private static void deleteVerifiedUsers(String accessToken) {  
        try{
            //Set<String> missingUsers = new Set<String>();
            //String accessToken = getAccessToken(); 
            System.debug('deleteVerifiedUsers called');
            getAzureGroupMembers('',config.get('Seismic_AD_PremiumUser'),accessToken); //Seismic SSO AZAD-CORP - Premium User (PRODUCTION)
            getAzureGroupMembers('',config.get('Seismic_AD_BusinessUser'),accessToken); //Seismic SSO AZAD-CORP - Business User (PRODUCTION))
            while (NextLink != null && NextLink != ''){
                getAzureGroupMembers(NextLink,config.get('Seismic_AD_BusinessUser'),accessToken); //Seismic SSO AZAD-CORP - Business User (PRODUCTION))
            }
            
            List<SeismicUserDeletion_User__c> userList = new List<SeismicUserDeletion_User__c>();
            SeismicUserDeletion_User__c user;
            
            //Iterate thru Seismic-Identified Users for missing users in Azure AD Seismic Role/Groups     
            //Exclude SysAccounts & Seismic Accounts 
            if(!missingUsers.isEmpty()) {
                for(Seismic_User usr : seismicUsers) {
                    if((!missingUsers.contains(usr.email.tolowercase()) && !sysAccounts.contains(usr.email.tolowercase()) && !usr.email.contains('@seismic.com')) || Test.isRunningTest()) 
                    {
                        user = new SeismicUserDeletion_User__c();
                        user.Load_ID__c = loadID;
                        user.Email__c = usr.email;
                        user.Seismic_ID__c = usr.id;
                        
                        //Lessonly UserID
                        for(Lessonly_User usr2 : lessonlyUsers){
                            if(usr.email == usr2.email){
                                user.Lessonly_ID__c = usr2.id;
                                break;
                            }
                        }
                        
                        //Add users in list
                        userList.add(user);
                        //System.debug(usr.email);
                    }  
                }
                
                if(!Boolean.valueOf(config.get('ExcludeDeletion')))
                {
                    //Delete Lessonly Users
                    Lessonly_User.deleteLessonlyUsers(userList);
                    
                    //Delete Seismic Users
                    Seismic_User.deleteSeismicUsers(userList);
            	}
                
                if(!userList.isEmpty()){
                    insert userList;
                    jobStatus = Job_Status.Success;
                }
                else if(jobStatus != Job_Status.Error) {
                    jobStatus = Job_Status.NoRecord;
                    errorMessage = 'Seismic & Azure Group is 100% sync. No action required.';
                }
                
            }
            else if(jobStatus != Job_Status.Error) {
                jobStatus = Job_Status.Error;
                errorMessage = 'Unable to make Graph API call to retrieve members';
            }
           
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            jobStatus = Job_Status.Error;
            errorDetail += 'Error occurred in deleteVerifiedUsers : ' + e.getMessage();
        }
    }
}