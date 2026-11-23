/**************************************************************************************
Apex Class Name:  Core_AccountCoverageExportUtil
Version     : 1.0 
Created Date: 08 Dec 2016
Description    : Util class for Core_RoleHierarchyBatch, Core_Batch_TerritoryManagement, Core_Batch_AccountCoverage_Summary etc..  batches and all the methods are common
*************************************************************************************/
public class Core_AccountCoverageExportUtil {
    
    public static List<String> toEmailslist = new  List<String>();
    
    private static String EMAIL_NOT_LIST_PUB_GRP = 'Core_AccountCoverage_Notification';
    
    private static final String FAILED = 'Failed';
    public static Map<String,Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
    public static String sandboxName =  '';
    
    static{
        
        try{
            Boolean isSB = [Select isSandbox from Organization Limit 1].isSandbox ;
            sandboxName = (isSB == true ? UserInfo.getUserName().substringAfterLast('.').toUpperCase()+' ' : '');
        }catch(Exception ex){
            UCD_ACM_Logger.error('Core_AccountCoverageExportUtil',null,'Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        
        
        Set<String> emailSet = new Set<String>();
        for(User u : [select id, name, email, isactive, profile.name, userrole.name, usertype 
                      From User 
                      WHERE
                      isactive = True AND
                      ID in ( select userorgroupid from GroupMember where group.DeveloperName =: EMAIL_NOT_LIST_PUB_GRP)]){
                          emailSet.add(u.email);             
                      }
        toEmailslist = new  List<String>(emailSet); 
        
    } 
    
    //Retrieve all Users associated to profiles added in custom settings
    public static Map<Id, User> getUsers(){
        Map<Id, User> mapUser =  null;
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') && mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            try{
                Map<String, Core_AccountCoverage_Profiles__c> p = Core_AccountCoverage_Profiles__c.getall();
                mapUser = new Map<Id, User>([SELECT Id FROM User WHERE isActive = true AND FederationIdentifier != null AND Core_Login_Id__c != null AND ProfileId IN (SELECT Id FROM Profile WHERE Name IN : p.keySet())]);    
            }catch(Exception e){
                //Return blank map if incase of exception
                mapUser = new Map<Id, User>();
            }
            return mapUser;
        }
        
        else
        {
            return null;
        }
    }
    
    //Retreive All the Non admin Users
    public static Map<Id, User> getNonAdminUsers(){
        Map<Id, User> mapUser =  null;
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') && mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            try{
                Map<String, Core_AccountCoverage_Profiles__c> p = Core_AccountCoverage_Profiles__c.getall();
                Map<String, Core_AccountCoverage_Exclude_Roles__c > excRole = new Map<String, Core_AccountCoverage_Exclude_Roles__c >();
                for(Core_AccountCoverage_Exclude_Roles__c cs : [Select Name FROM Core_AccountCoverage_Exclude_Roles__c ]){
                    excRole.put(cs.Name, cs);
                }
                
                mapUser = new Map<Id, User>([SELECT Id, UserRole.Name FROM User WHERE isActive = true AND FederationIdentifier != null AND Core_Login_Id__c != null AND UserRole.Name NOT IN :excRole.keySet() AND ProfileId IN (SELECT Id FROM Profile WHERE Name IN : p.keySet())]);    
            }catch(Exception e){
                //Return blank map if incase of exception
                mapUser = new Map<Id, User>();
            }
            return mapUser;
            
        }
        
        else
        {
            return null;
        }
    }
    
    //Set the additional Body while sending the emails 
    public static String additionalEmailBody = '';
    
    //Update the custom setting of the batchstatus to completed or Failed
    public static void sendNotification(Database.BatchableContext batchcontext, String batchName){
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') && mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            // Get the batch job information
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:batchcontext.getJobId() LIMIT 1];
            
            String batchStatus = 'SUCCESS'; 
            String strEmailBody = sandboxName+' Salesforce Account Coverage Batch :' + batchName;
            String subject = '';
            String fromEmail = null;
            //List<String> toEmailslist = new  List<String>();
            if (a != null && a.NumberOfErrors > 0) {
                // Shoot an email to the user who kicked off the batch
                strEmailBody = strEmailBody + '\n\n Status: ' + a.Status + '\n' + 'Total batches processed: ' + a.TotalJobItems + '\n' + 'Batches with errors: ' + a.NumberOfErrors + '\n Extended errors:' + a.ExtendedStatus+'\n';
                strEmailBody += '\n Please contact a System Administrator.';
                batchStatus = 'FAILED';
                
            }
            
            setCustomSettings(batchName, batchStatus);               
            
            fromEmail = a.CreatedBy.Email;
            subject = sandboxName+' Salesforce Account Coverage: '+batchName+' has finished. Batch status: ' + batchStatus + '.';      
            //String[] toEmail = new String[]{a.CreatedBy.Email};
            
            
            if(FAILED.equalsIgnoreCase(batchStatus) || String.isNotBlank(additionalEmailBody))
                sendEmail(fromEmail, toEmailslist, subject, strEmailBody); 
            
            
        }
    }
    
    
    // Sends the Email
    public static void sendEmail(String fromEmail, List<String>  toEmail, String subject, String emailBody){
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') &&  mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            emailBody = emailBody +'\n ' +additionalEmailBody;
            List<Messaging.SendEmailResult>  mer = null;
            mail.setSubject(subject);
            mail.setPlainTextBody(emailBody);
            mail.setToAddresses(toEmail);
            if(!Test.isRunningTest()){
                mer = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
            }    
            
            
        }
    }
    
    
    //Sets the Account Coverage Settiings to BLank
    public static void setCustomSettings(String batchName, String batchStatus){
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') && mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            if('All'.equalsIgnoreCase(batchName)){
                List<Core_AccountCoverage_Batch_Status__c> settingsList = [SELECT Name, Core_Batch_Status__c FROM Core_AccountCoverage_Batch_Status__c];
                for(Core_AccountCoverage_Batch_Status__c bs: settingsList){
                    bs.Core_Batch_Status__c = batchStatus;
                }    
                update settingsList;
                
            }else{
                Core_AccountCoverage_Batch_Status__c cs = Core_AccountCoverage_Batch_Status__c.getInstance(batchName);
                if(cs != null){
                    cs.Core_Batch_Status__c = batchStatus;
                    update cs;
                }
            }
        }
    }
    
    //Retrieves the custom settings.
    public static String getCustomSettings(String batchName){
        String val = '';
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') &&  mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            Core_AccountCoverage_Batch_Status__c cs = Core_AccountCoverage_Batch_Status__c.getInstance(batchName);
            if(cs != null){
                val = cs.Core_Batch_Status__c;
            }
            return val;
        }
        else
        {
            return null;
            
        }
    }
    
    // verify if all the jobs are completed and return true/false
    public static Boolean areAllAccountCoverageBatchesCompleted(){
        boolean flag = true;
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') &&  mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            for(Core_AccountCoverage_Batch_Status__c status : [select Name, Core_Batch_Status__c from Core_AccountCoverage_Batch_Status__c
                                                               Where Name IN ('Core_Batch_AccountShare','Core_Batch_RoleHierarchy','Core_Batch_TerritoryManagement')])
            {
                if(!'SUCCESS'.equalsIgnoreCase(status.Core_Batch_Status__c)){
                    
                    flag = false;
                    break;
                }
            }
            
            return flag;
        }
        
        else
        {
            return null;
        }
    }
    
    
    // populate the Account fields to Account Coverage
    public static void populateAccountCoverage(Core_AccountCoverage_Export__c ce, Account acct, User currUser){
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') &&  mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            if(ce != null && acct != null){
                ce.Core_Account_Id__c = acct.Id;
                
                //User Details
                ce.Core_User_WWID__c = currUser.FederationIdentifier;
                ce.Core_Login_Id__c = currUser.Core_Login_Id__c ;
                //TODO: Pending Review
                ce.Core_User_First_Name__c = currUser.FirstName;
                ce.Core_User_Last_Name__c = currUser.LastName;
                ce.Core_User_Title__c  = currUser.Title;
                ce.Core_User_Country_Code__c = currUser.Core_User_Country_Code__c;
                ce.Core_User_IsActive__c = ( (currUser.IsActive == true) ? 'True' : 'False' );
                ce.Core_User_Email__c = currUser.Email;
                
                //TODO: Pending Review: Field Phone Text
                ce.Core_User_Phone__c = (String.isBlank(currUser.Phone) ?  currUser.MobilePhone : currUser.Phone);
                ce.Core_User_City__c = currUser.City;
                ce.Core_User_Language_Locale_Key__c  = currUser.LocaleSidKey;
                ce.Core_User_Id__c = currUser.Id;
                ce.Name = currUser.Name;
                ce.Core_User_Email__c =  currUser.Email;
                
                //Account Details
                ce.Core_Account_CIMID__c = null;
                ce.Core_Account_Geo__c = acct.Core_Geo__c;
                ce.Core_Account_Id__c = acct.Id;
                ce.Core_Status__c = 'New';
                ce.Core_Ext_Id__c = String.ValueOf(currUser.Id) + String.ValueOf(acct.Id);
                
                
            }
        }
    }
    
    
    //Call the Mule Service
    //Sample Url :  Reads from Custom Setting
    public static String callMuleService(){
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') && mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            //Email Related 
            String strEmailBody = sandboxName+'Salesforce Account Coverage - Mule Service Invocation Status:  ' ;
            String subject = sandboxName +'Salesforce Account Coverage - Mule Service Invocation Status:   ';
            String fromEmail = 'admin@intel.com';
            String status = 'SUCCESS';
            String responseBody = System.now().format()+' ';
            String load = 'DELTA';
            
            HTTPResponse httpResp = new HTTPResponse();
            
            try{
                
                //Read the custom setting from Core_AccountCoverage_LoadType__c
                //Map<String, Core_AccountCoverage_LoadType__c> mapCodes = Core_AccountCoverage_LoadType__c.getAll();
                Core_AccountCoverage_LoadType__c cl = [Select Name, Core_LoadType__c FROM Core_AccountCoverage_LoadType__c LIMIT 1];
                if(cl != null && null != cl.Core_LoadType__c)
                    if ('Full'.equalsIgnoreCase('cl.Core_LoadType__c'))
                    load = 'FULL';
                
                Core_System_Credentials__c sObjRecSystemCred = Core_System_Credentials__c.getValues('Core AC Mule Service');
                
                Http http = new Http();
                HttpRequest httpReq = new HttpRequest();
                httpReq.setMethod('GET');
                String endPointURL=sObjRecSystemCred.Core_End_Point_URL__c;
                String sUsername = sObjRecSystemCred.Core_UserName__c; 
                String sPassword = sObjRecSystemCred.Core_Password__c ; 
                Blob bAuthValue = Blob.valueOf(sUsername+ ':' + sPassword);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(bAuthValue);
                httpReq.setHeader('Authorization', authorizationHeader);
                httpReq.setTimeout(Integer.Valueof(System.Label.Core_TimeOut));
                
                endPointURL = endPointURL + '?LOAD=' + load;
                
                
                httpReq.setEndpoint(endPointURL);
                httpResp = http.send(httpReq);//Call the Util 
                
                
                responseBody = ( httpResp != null) ?  httpResp.getBody() : '' ;
                
                
                String[] responseBodyArray = responseBody.split(',', 2);
                
                if(!(httpResp != null && httpResp.getStatusCode() == 200 && responseBodyArray[0] == '1')){
                    httpResp.setStatus('Please Contact System Administrator');
                    Core_AccountCoverageExportUtil.additionalEmailBody = ' Status '+ httpResp.toString() + ' ' + responseBody;
                    status = 'FAILED';
                }
                
            }catch(Exception e){
                status = 'FAILED';
                
                Core_AccountCoverageExportUtil.additionalEmailBody = ' \n\n Failure Reason : '+ e.getMessage();
            }
            
            Core_AccountCoverage_Batch_Status__c cb = [SELECT Name, Core_Batch_Status__c, Core_Service_Response__c 
                                                       FROM Core_AccountCoverage_Batch_Status__c Where Name ='Core_Batch_AccountCoverage_MuleService'];
            cb.Core_Batch_Status__c = status;
            cb.Core_Service_Response__c = trim(responseBody, 255);
            update cb;
            
            
            
            strEmailBody = strEmailBody+' '+status;
            subject = subject+' '+status;
            
            //send Email
            if(FAILED.equalsIgnoreCase(status) || 'TRUE'.equalsIgnoreCase(Label.Core_Account_Coverage_Export_Mule_Success_Email ))
                sendEmail(fromEmail, Core_AccountCoverageExportUtil.toEmailslist, subject, strEmailBody);   
            
            return status;
        }
        else
        {
            return null;  
        }
    }
    
    //substring 
    public  static String trim(String arg, Integer charLength){
        String str = '';
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageExportUtil') &&  mapAcmClassCheckToEol.get('AccountCoverageExportUtil').IsActive__c){
            try{
                str = ( String.isNotBlank(arg) &&  arg.length() > charLength ) ?  arg.substring(0, charLength) : arg ;
            }catch(Exception ex){
                UCD_ACM_Logger.error('Core_AccountCoverageExportUtil','trim','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
            }
            return str;
        }     
        else{
            return null;
        }    
    }
}