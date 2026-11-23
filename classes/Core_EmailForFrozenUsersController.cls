/*******************************************************************************************************************************
Apex Class Name:  Core_EmailForFrozenUsersController
Version     : 1.0 
Created Date: 20 JUNE 2022
Function    : methods to fetch user data and send as an excel attachment to required users.
Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------------------------- 
* Sankarshana                 06/20/2022               Methods to fetch user data and send as an excel attachment and send email to required users.
* Rakshit                     18/10/2023               Updated SOQL Query to get the list of Users and the Email Template
*********************************************************************************************************************************/
public with sharing class Core_EmailForFrozenUsersController implements Schedulable {   
    
/*
* Method name  : SendEmailwithExcelAttachment
* Description  : Method to fetch user data who have not logged in >90 days and send email with excel
attachment to required users.
* Return Type  : void
* Parameter    : Null
*/
    public void execute(SchedulableContext SC){       
        //Collections to store user related data                
        Map<Id,Decimal> usrMap = new Map<Id,Decimal>();	
        Set<Id> lstTempUser = new Set<Id>();
        List<User> users = new List<User>();
        Map<Id,Boolean> userIdtoIsFrozenMap = new Map<Id,Boolean>();
        //Table to store user data which will be converted into excel sheet.
        String csvBody = '<table border="1" style="border-collapse: collapse"><tr bgcolor = "#D3D3D3"><th>Id</th><th>Name</th><th>Profile</th><th>FederationID</th><th>Email</th><th>IsActive</th><th>IsFrozen</th><th>CreatedBy</th><th>LastLoginDate</th><th>LastModifiedDate</th><th>Manager</th><th>Department</th><th>Role</th><th>Username</th><th>EmployeeTypeCode</th><th>WWID</th><th>CreatedDate</th></tr>';
        
        
        
        //SOQL query to fetch list of UserLogin to get User's Frozen status.
        for(UserLogin userLogin : [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE UserId IN (SELECT Id FROM User WHERE IsActive = true AND UserType='Standard' AND LastLoginDate < LAST_90_DAYS)]){
            userIdtoIsFrozenMap.put(userLogin.UserId, userLogin.IsFrozen);
        }
        
        //SOQL query to fetch list of users who have not logged in last 90 days.
        //First check if the current Org is Sandbox. If YES, then limit the list of users to 3000 as large number of users is causing Heap size exception.
        Boolean isSandbox = ([SELECT IsSandbox FROM Organization LIMIT 1])[0].IsSandbox;

        if(Test.isRunningTest()){
            users = [SELECT Name, Profile.UserLicense.Name, Profile.Name, FederationIdentifier, Email, IsActive, LastLoginDate, LastModifiedDate, Id, CreatedBy.Name, Core_Manager__c, Department,UserRole.Name,Username,Core_Employee_Type_Code__c,Core_WWID__c,CreatedDate FROM user WHERE Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = TRUE) AND isactive=true AND UserType='Standard' AND LastLoginDate < LAST_90_DAYS ORDER BY LastLoginDate DESC LIMIT 200]; 
        } else{
            if(isSandbox){
                users = [SELECT Name, Profile.UserLicense.Name, Profile.Name, FederationIdentifier, Email, IsActive, LastLoginDate, LastModifiedDate, Id, CreatedBy.Name, Core_Manager__c, Department,UserRole.Name,Username,Core_Employee_Type_Code__c,Core_WWID__c,CreatedDate FROM user WHERE Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = TRUE) AND isactive=true AND UserType='Standard' AND LastLoginDate < LAST_90_DAYS ORDER BY LastLoginDate DESC LIMIT 3000];
            } else {
                users = [SELECT Name, Profile.UserLicense.Name, Profile.Name, FederationIdentifier, Email, IsActive, LastLoginDate, LastModifiedDate, Id, CreatedBy.Name, Core_Manager__c, Department,UserRole.Name,Username,Core_Employee_Type_Code__c,Core_WWID__c,CreatedDate FROM user WHERE Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = TRUE) AND isactive=true AND UserType='Standard' AND LastLoginDate < LAST_90_DAYS ORDER BY LastLoginDate DESC];
            }
            
        }
     
        
        //Iterate across list of users to create CSV file
        for(User uObj : users){
            lstTempUser.add(uObj.Id);
            csvBody += '<tr align="left"><td>' + uObj.Id + '</td><td>' + uObj.Name + '</td><td>' + uObj.Profile.Name + '</td><td >'+ uObj.FederationIdentifier +'</td><td>'+  uObj.Email + '</td><td>'+ uObj.IsActive +'</td><td>'+ userIdtoIsFrozenMap.get(uObj.Id) +'</td><td>'+ uObj.CreatedBy.Name +'</td><td>'+ uObj.LastLoginDate +'</td><td>' + uObj.LastModifiedDate + '</td><td>' + uObj.Core_Manager__c + '</td><td>' + uObj.Department +'</td><td>' + uObj.UserRole.Name + '</td><td>'+ uObj.Username +'</td><td>' + uObj.Core_Employee_Type_Code__c +'</td><td>' + uObj.Core_WWID__c + '</td><td>' + uObj.CreatedDate  + '</td></tr>';
        }
        //close table and clear off the unnecessary variables to free up the heap size.
        csvBody += '</table>';   
        userIdtoIsFrozenMap.clear(); 
        
        //AggregateResult list to fetch each profile with user count who have not logged in > 90 days.        
        for(AggregateResult ar : [SELECT ProfileId, Count(Core_User_Profile_Name__c) //**************Code can be optimised here. Get details from existing user's list
                                  FROM user WHERE Id IN : lstTempUser AND isactive=true GROUP BY Profile.Name,ProfileId]){ 
                                      usrMap.put((String)ar.get('ProfileId'),(Decimal)ar.get('expr0'));            
                                  }       
        //Map to fetch profile id,name and licensetype data.
        Map<Id,Profile> prfMap = new Map<Id,Profile>([Select Id, Name, UserLicense.Name FROM Profile WHERE Id IN : usrMap.keyset()]); //**************Code can be optimised here. Get details from existing user's list
        
        Date nextWeek = System.now().date().addDays(7);
       string dateTimeValue= Datetime.newInstance(nextWeek.year(), nextWeek.month(), nextWeek.day()).format('yyy-MM-dd');
        String htmlMessageString = '<p>**<strong>This is an auto-triggered email </strong>**</p><p>\n</p><p>Hi,</p><p>\n</p><p>Please find attached the list of users who are frozen and have not logged into the system for more than 90 days. These users will be inactivated in salescloud by ' + dateTimeValue + '. </p><p>\n</p><p><strong><u>Action requested:</u></strong> Please review the user list and let us know if you wish to retain anyone’s access. All other users will be inactivated in order to free-up the unused licenses.</p><p>\n</p><p>In case of concern, you may reach out to <a href="mailto:parthx.soomanyu@intel.com" rel="noopener noreferrer" target="_blank" style="font-family: Calibri, sans-serif;">Parth Soomanyu</a>/<a href="mailto:akshayx.bhimrao@intel.com" rel="noopener noreferrer" target="_blank" style="font-family: Calibri, sans-serif;">Akshay Bhimrao</a>.</p>';
        String orgName = '<p>' +'<b>'+'Org Name: '+'</b>'+ UserInfo.getOrganizationName()  +'</p>';
        String orgId = '<p>' +'<b>'+'Org ID: '+'</b>'+ UserInfo.getOrganizationId()  +'</p>';
        String Caption = '<p>'+ label.Core_Email_Body_Caption +'</p>';   
        //Table to display user license, profile and user count for each profile.        
        String htmlBody = '';
        //open table.
        htmlBody = '<table border="1" style="border-collapse: collapse">';    
        htmlBody += '<tr><th>License Type</th><th>Profile</th><th>Non-logged Users</th></tr>';
        //iterate over list and output columns/data into table rows.
        for(Id pId : prfMap.keyset()){            
            htmlBody += '<tr><td>' + prfMap.get(pId).UserLicense.Name + '</td><td>' + prfMap.get(pId).Name+ '</td><td>' + usrMap.get(pId) + '</td></tr>';                                        	
        }        
        htmlBody += '<tr><td>' +  + '</td><td>' +'<b align="right">'+ 'Total:' +'</b>' + '</td><td>' + users.Size() + '</td></tr>';
        //close table.
        htmlBody += '</table>';
        //Split custom label which has email addresses to be sent to given email ids.
        string toaddressList =label.Core_Email_Addresses_For_Internal_Users;
        String[] toaddresssplit =toaddressList.split(',');           
        String Subject = label.Core_Email_Subject_For_Internal_Users_Not_Logged;
        String finalHtmlBody = htmlMessageString + '\n' + orgName + '\n' + orgId + '\n' + Caption + htmlBody;
        if(prfMap.size() > 0){
            List<Messaging.SendEmailResult> result = sendEmail(Subject, toaddresssplit, finalHtmlBody, csvBody);          
            if (result[0].success) {
               
            } else {
                
            }
        }        
    }    
/*
* Method name  : sendEmail
* Description  : Method to send email with excel attachment to required users.
* Return Type  : List<Messaging.SendEmailResult>
* Parameter    : Null
*/
    public static List<Messaging.SendEmailResult> sendEmail(String Subject, List<String> toaddresssplit, String finalHtmlBody, String csvBody){
        //Email attachement to attach csvBody as excel attachment.   
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                        
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(csvBody);
        String csvName = 'UserList'+'.xls';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        csvAttachment.setContentType('application/vnd.ms-excel');            
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});         
        email.setHtmlBody(finalHtmlBody);     
        email.setSubject(subject);
        email.setToAddresses(toaddresssplit); 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce.system.user@intel.com'];
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {email};
            Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
        return result;                  
    }   
}