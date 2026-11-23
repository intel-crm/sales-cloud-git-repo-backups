/****************************************************************************************************
Apex Class Name : Core_AccountOwnerChange_Controller
Version         : 1.0 
Created Date    : 01/16/15
Function        : User actuated process to request ownership of an account from the current owner.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              01/16/2015             Original Version
* Dave Hood                   03/20/2015             Updated for "Uncovered Account"
* Dave Hood                   01/17/2017             Updated to block users with A&E profile but not A&E Super User permission set
* Rajesh                      21/2/2017              Added logic for US95951-ACCT: Sales Group entry mandatory after taking Account Ownership.
* Ankita                      15/4/2020              Updated for Industry- US643521 -ACCT : Validation rule update for  Industry LOV updation.
* Ajay                        25/03/2023             Updated messages.     
* Mayank                      17/07/2024             Removing Task and adding Approval Process
*****************************************************************************************************/
public without sharing class Core_AccountOwnerChange_Controller 
{
    private Account accountUpdate;
    private Account currentAccount;
    private String  currentUserId;
    private ApexPages.StandardController controller {get; set;}
    //private ApexPages.Message myMsg;
    public static Map<String,Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
    
    private PageReference acctPage;
    
    public Core_AccountOwnerChange_Controller(ApexPages.StandardController paramController)
    {
        controller     = paramController; 
        currentAccount = (Account) controller.getRecord();       
        currentUserId  = UserInfo.getUserId();    
    }
    
    
    public PageReference returnToAccount()
    {
        if(mapAcmClassCheckToEol.containsKey('AccountOwnerChangeController') && mapAcmClassCheckToEol.get('AccountOwnerChangeController').IsActive__c)
        {
            return acctPage;
        }
        return null;
        
    }
    
    
    public PageReference changeOwnerRequest()
    {
        if(mapAcmClassCheckToEol.containsKey('AccountOwnerChangeController') && mapAcmClassCheckToEol.get('AccountOwnerChangeController').IsActive__c)
        {
            System.debug('Insert');
            // DH 1/20/17: added this, to refresh the current user ID, so test code will work
            // (the user who sets up the controller for testing may not be the one invoking this method)
            currentUserId  = UserInfo.getUserId();
            
            // Making this an instance variable creates a serialization error.
            ApexPages.Message myMsg;    
            User user  = new User();
            List<PermissionSetAssignment> userSuperUserPermSets  = new List<PermissionSetAssignment>();
            List<User> userList = new List<User>(); 
            
            //Start (Kavyashree HR)- Added the field RecordType.Name in the query      
            //try
            //{
                if ((Schema.sObjectType.Account.fields.Name.isAccessible())&& 
                    (Schema.sObjectType.Account.fields.OwnerId.isAccessible())&&
                    (Schema.sObjectType.Account.fields.Industry.isAccessible())&&
                    (Schema.sObjectType.Account.fields.Core_Sub_Industry__c.isAccessible())&&
                    (Schema.sObjectType.Account.fields.Core_Sales_Groups__c.isAccessible())&&
                    (Schema.sObjectType.Account.fields.Core_Owner_Changed_From_Uncovered__c.isAccessible())&&
                    (Schema.sObjectType.Account.fields.New_Owner__c.isAccessible()))
                {
                    List<Account> accountList = [SELECT Id, Name, OwnerId,Industry,Core_Sub_Industry__c, Core_Sales_Groups__c, RecordType.Name , Core_Owner_Changed_From_Uncovered__c,New_Owner__c
                                                 FROM Account
                                                 WHERE Id = :currentAccount.Id];
                    
                    if (accountList.size() == 0)
                        //return null;
                    
                    accountUpdate = accountList[0];   
                    accountUpdate.New_Owner__c = currentUserId;
                }
                
                // Create return page on for current account
                acctPage = new ApexPages.StandardController(accountUpdate).view();
                acctPage.setRedirect(false);
                
                // Get current user INFO
                if (Schema.sObjectType.User.fields.Name.isAccessible()) {
                    userList = [SELECT Name, Email, IsActive, ProfileId
                                FROM User 
                                WHERE Id = :currentUserId];
                    
                    if (Schema.sObjectType.PermissionSetAssignment.fields.Id.isAccessible()) {
                        
                        userSuperUserPermSets = [
                            SELECT Id
                            FROM PermissionSetAssignment
                            WHERE AssigneeId = :currentUserId and PermissionSetId = :Label.Core_A_E_Super_User_Permission_Set_ID];
                        
                        if (userList.size() == 0)
                            return acctPage;
                    }
                    user = userList[0];
                }
                
                if (accountUpdate.OwnerId == currentUserId)
                {
                    
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account already owned by ' + user.Name);
                    ApexPages.addMessage(myMsg);        
                    //return null;  // cctPage;
                }
                // Current user is A&E User (profile) but not A&E Super User (perm set) - do nothing
                if ((user.ProfileId == Label.Core_A_E_User_Profile_ID) && (userSuperUserPermSets.size() == 0)) {
                    //  myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sorry, your profile is A&E User, which requires ' +
                    //                              'the A&E Super User permission set to take ownership of accounts.');
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'You do not have permission to take ownership of an account.  Please request to be an Account Team Member.');
                    ApexPages.addMessage(myMsg);        
                    //return null;  // cctPage;
                }
                
                // Account Owner same as Current User - do nothing
                if (accountUpdate.OwnerId == currentUserId)
                {
                    
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account already owned by ' + user.Name);
                    ApexPages.addMessage(myMsg);        
                    //return null;  // cctPage;
                }
                
                //Commented by Kavyashree HR (Infosys Team) on 9/4/2020 for the US767646
                //Updated By Ankita- US643521 Industry value(Other than To be Defined) required to change the Account Owner from Uncovered to Other user
                /**if(accountUpdate.OwnerId == Label.Core_Uncovered_Account_ID && (accountUpdate.Industry ==Null || accountUpdate.Industry=='To Be Defined')){
myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please fill in an Industry value apart from '+'"'+'To Be Defined'+'"'+' before changing the ownership of this account');
ApexPages.addMessage(myMsg);        
return null;                    
}**/   
                //Start - Added by Kavyashree HR (Infosys Team) on 9/4/2020 for the US767646
                if((String.isBlank(accountUpdate.Industry) || accountUpdate.Industry == 'To Be Defined') && accountUpdate.RecordType.Name == 'Intel Account'){                   
                    accountUpdate.Core_Owner_Changed_From_Uncovered__c = true;
                    if(String.isBlank(accountUpdate.Industry)){
                        accountUpdate.Industry = 'To Be Defined';
                        accountUpdate.Core_Sub_Industry__c = 'To Be Defined';
                    }
                    myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Core_Acc_Industry_WarningMsg);
                    ApexPages.addMessage(myMsg); 
                }
                //End - Added by Kavyashree HR (Infosys Team) on 9/4/2020 for the US767646         
                // Integration User or Uncovered Account - change owner!
                if ((accountUpdate.OwnerId == Label.Core_CRM_Integration_User_ID) ||
                    (accountUpdate.OwnerId == Label.Core_Uncovered_Account_ID)||  (accountUpdate.OwnerId == Label.Core_A_E_Account_Owner_ID))
                {
                    //accountUpdate.OwnerId = user.Id;
                    //update accountUpdate;
                    
                    String oldOwner = '';
                    if (accountUpdate.OwnerId == Label.Core_CRM_Integration_User_ID)
                        oldOwner = 'Integration User';
                    else if(accountUpdate.OwnerId == Label.Core_Uncovered_Account_ID){
                        oldOwner = 'Uncovered Account';
                    }
                    else{
                        oldOwner = 'A&E Account Owner';
                    }
                    accountUpdate.OwnerId = user.Id;
                    if(Schema.sObjectType.Account.fields.Core_Owner_Changed_From_Uncovered__c.isUpdateable() &&
                       Schema.sObjectType.Account.fields.Industry.isUpdateable()  &&
                       Schema.sObjectType.Account.fields.Core_Sub_Industry__c.isUpdateable()  &&
                       Schema.sObjectType.Account.fields.OwnerId.isUpdateable()){
                           update accountUpdate;
                       }
                    //START - Added by Rajesh for change request  on US9595--if Account SalesGroup is Blank and Uncovered Account,displaying the Warning MSG//    
                    /*if(String.isBlank(accountUpdate.Core_Sales_Groups__c) && !(accountUpdate.Core_Covered_Account__c)){
myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Core_Acc_SalesGroup_WarningMsg);
ApexPages.addMessage(myMsg); 
}*/
                    
                    //End- Added by Rajesh for change request  on US9595--if Account SalesGroup is Blank and Uncovered Account,displaying the Warning MSG//                 
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account Owner changed from "' + oldOwner + '" to ' + user.Name + ', however, by design, you will not be able to change the Sales Group.  If you wish to change the Sales Group, request via AAQ; include link to Account and detailed justification.');
                    ApexPages.addMessage(myMsg);                
                    
                    //return null;
                } 
                System.debug('before insert');
                if (Schema.sObjectType.User.fields.Name.isAccessible()) {
                    System.debug('Insert 2');
                    userList = [SELECT Name, Email, IsActive 
                                FROM User 
                                WHERE Id = :accountUpdate.OwnerId];
                    
                    // Inactive User - change owner!                                        
                    if ((userList.size() == 0) || (!userList[0].isActive))
                    {
                        String ownerName = '***';
                        if (userList.size() > 0)
                            ownerName = userliSt[0].Name;
                        
                        
                        accountUpdate.OwnerId = currentUserId;
                        
                        update accountUpdate;
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Inactive Account Owner "' + ownerName + '" changed to "' + user.Name + '" for account "' + accountUpdate.Name + '"' + ', however, by design, you will not be able to change the Sales Group.  If you wish to change the Sales Group, request via AAQ; include link to Account and detailed justification.');
                        ApexPages.addMessage(myMsg);   
                        return null;
                    } 
                    
                    
                    User owner = userList[0];
                    
                    String requestText = 'ACE Cloud user ' + user.Name + ' has requested onwership of your account: ' + accountUpdate.Name + '.  ' +
                        'For your approval, a task to re-assign ownership has been attached to the account in Salesforce.';
                    
                    
                    if(System.Label.Core_Ownership_Orgwide_Email_Id != null && String.isNotBlank(System.Label.Core_Ownership_Orgwide_Email_Id)){
                        System.debug('Insert mail');
                        // Reserve a single email
                        Messaging.reserveSingleEmailCapacity(1);
                        
                        // Create a new single email message object
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        // Strings to hold the email addresses to which you are sending the email.
                        List<String> toAddresses = new List<String> {owner.Email}; 
                        toAddresses.add('rohitx.podder@intel.com');
                            
                            // Assign the addresses for the To and CC lists to the mail object.
                            mail.setToAddresses(toAddresses);
                        
                        mail.setReplyTo(user.Email);
                        
                        mail.setOrgWideEmailAddressId([Select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com].Id);
                        
                        // Specify the name used as the display name.
                        
                        // Specify the subject line for your email address.
                        mail.setSubject('Account Ownership change request: ' + accountUpdate.Name);
                        
                        // Optionally append the salesforce.com email signature to the email.
                        // The email address of the user executing the Apex Code will be used.
                        mail.setUseSignature(false);
                        
                        mail.setHtmlBody(requestText);
                        
                        // Send the email you have created.
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }               
                    
                    
                    
                    Task newTask        = new Task();
                    newTask.Description = requestText; 
                    newTask.OwnerId     = owner.Id;    
                    newTask.Priority    = 'High';
                    newTask.Subject     = 'Account Ownership Change Request from ' + user.Name;
                    newTask.Type        = 'Change Ownership';
                    newTask.WhatId      = accountUpdate.Id; 
                    if(Schema.sObjectType.Task.fields.Description.isCreateable()){
                        insert newTask;        
                    }
                    /*
if(Schema.sObjectType.Account.fields.Core_Owner_Changed_From_Uncovered__c.isUpdateable() &&
Schema.sObjectType.Account.fields.Industry.isUpdateable()  &&
Schema.sObjectType.Account.fields.Core_Sub_Industry__c.isUpdateable()  &&
Schema.sObjectType.Account.fields.OwnerId.isUpdateable()&&
(Schema.sObjectType.Account.fields.New_Owner__c.isUpdateable())){
update accountUpdate;
}
// Create an approval process instance
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setComments('Requesting Account Ownership Change Request from ' + user.Name);
req.setObjectId(accountUpdate.id);
req.setSubmitterId(UserInfo.getUserId());
req.setProcessDefinitionNameOrId('Account_Ownership_Transfer_Approval'); // Use the API name of your approval process
Approval.ProcessResult result = Approval.process(req);
// Check if the process submission was successful
if (result.isSuccess()) {
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Ownership transfer request submitted successfully.'));
} else {
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to submit ownership transfer request.'));
}*/
                    
                    
                    
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account Owner Change Request: however, by design, you will not be able to change the Sales Group.  If you wish to change the Sales Group, request via AAQ; include link to Account and detailed justification.');
                    ApexPages.addMessage(myMsg);        
                    
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, '"' + requestText + '"');
                    ApexPages.addMessage(myMsg);        
                    
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Emailed to "' + owner.Name + '" @ "' + owner.Email + '":');
                    ApexPages.addMessage(myMsg);        
                    
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account Owner Change Request Task added to account: ' + accountUpdate.Name);
                    ApexPages.addMessage(myMsg);
                    //}        
                    //}
                }
                return null;
                
                
            //}    
            /*catch (Exception err)
            {
                System.debug('error'+err);
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Account Ownership Change - Internal processing ERROR');
                ApexPages.addMessage(myMsg);        
                
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
                ApexPages.addMessage(myMsg);        
                
                return null;           
            }*/
        }
        return null;
        
    }
}