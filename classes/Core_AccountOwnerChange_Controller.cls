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
*****************************************************************************************************/
public without sharing class Core_AccountOwnerChange_Controller 
{
    private Account accountUpdate;
    private Account currentAccount;
    private String  currentUserId;
    private ApexPages.StandardController controller {get; set;}
    //private ApexPages.Message myMsg;

    private PageReference acctPage;
    
    public Core_AccountOwnerChange_Controller(ApexPages.StandardController paramController)
    {
        controller     = paramController; 
        currentAccount = (Account) controller.getRecord();       
        currentUserId  = UserInfo.getUserId();
        System.debug('CONSTRUCTOR currentUserId: ' + currentUserId);
        
        
    }


    public PageReference returnToAccount()
    {
        return acctPage;
    }


    public PageReference changeOwnerRequest()
    {
        System.debug('START - Method');
        
        // DH 1/20/17: added this, to refresh the current user ID, so test code will work
        // (the user who sets up the controller for testing may not be the one invoking this method)
        currentUserId  = UserInfo.getUserId();

        // Making this an instance variable creates a serialization error.
        ApexPages.Message myMsg;    
                
        try
        {
            List<Account> accountList = [SELECT Id, Name, OwnerId,Core_Sales_Groups__c
                                         FROM Account
                                         WHERE Id = :currentAccount.Id];
                                             
            if (accountList.size() == 0)
                return null;
    
            accountUpdate = accountList[0];    
    
            // Create return page on for current account
            acctPage = new ApexPages.StandardController(accountUpdate).view();
            acctPage.setRedirect(false);
    
            // Get current user INFO
            List<User> userList = [SELECT Name, Email, IsActive, ProfileId
                                   FROM User 
                                   WHERE Id = :currentUserId];
            
            List<PermissionSetAssignment> userSuperUserPermSets = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :currentUserId and PermissionSetId = :Label.Core_A_E_Super_User_Permission_Set_ID];
            
            if (userList.size() == 0)
                return acctPage;
    
            User user = userList[0];
            
            System.debug('Current User Profile ID: ' + user.ProfileId + ', Permission Set query: ' + userSuperUserPermSets);
            
            // Current user is A&E User (profile) but not A&E Super User (perm set) - do nothing
            if ((user.ProfileId == Label.Core_A_E_User_Profile_ID) && (userSuperUserPermSets.size() == 0)) {
              //  myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sorry, your profile is A&E User, which requires ' +
                //                              'the A&E Super User permission set to take ownership of accounts.');
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'You do not have permission to take ownership of an account.  Please request to be an Account Team Member.');
                ApexPages.addMessage(myMsg);        
                return null;  // cctPage;
            }
                
            // Account Owner same as Current User - do nothing
            System.debug('Current User Check: ' + accountUpdate.OwnerId + ' == ' + currentUserId);
            if (accountUpdate.OwnerId == currentUserId)
            {
              
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account already owned by ' + user.Name);
                ApexPages.addMessage(myMsg);        
                return null;  // cctPage;
            }
            
            // Integration User or Uncovered Account - change owner!
            System.debug('Integration User Check: ' + accountUpdate.OwnerId + ' == ' + Label.Core_CRM_Integration_User_ID);
            System.debug('Uncovered Account Check: ' + accountUpdate.OwnerId + ' == ' + Label.Core_Uncovered_Account_ID);
            if ((accountUpdate.OwnerId == Label.Core_CRM_Integration_User_ID) ||
                (accountUpdate.OwnerId == Label.Core_Uncovered_Account_ID))
            {
                accountUpdate.OwnerId = user.Id;
                update accountUpdate;
                
                String oldOwner = '';
                if (accountUpdate.OwnerId == Label.Core_CRM_Integration_User_ID)
                    oldOwner = 'Integration User';
                else
                    oldOwner = 'Uncovered Account';
                //START - Added by Rajesh for change request  on US9595--if Account SalesGroup is Blank and Uncovered Account,displaying the Warning MSG//    
                if(String.isBlank(accountUpdate.Core_Sales_Groups__c) && !(accountUpdate.Core_Covered_Account__c)){
                   myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Core_Acc_SalesGroup_WarningMsg);
                    ApexPages.addMessage(myMsg); 
                 }
                  //End- Added by Rajesh for change request  on US9595--if Account SalesGroup is Blank and Uncovered Account,displaying the Warning MSG// 
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account Owner changed from "' + oldOwner + '" to ' + user.Name);
                ApexPages.addMessage(myMsg);                
                        
                return null;
            } 
            
            System.debug('Inactive User Check');
            
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
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Inactive Account Owner "' + ownerName + '" changed to "' + user.Name + '" for account "' + accountUpdate.Name + '"');
                ApexPages.addMessage(myMsg);   
                return null;
            } 
            
            
            System.debug('Current User Check');
            
            User owner = userList[0];
            
            String requestText = 'ACE Cloud user ' + user.Name + ' has requested onwership of your account: ' + accountUpdate.Name + '.  ' +
                'For your approval, a task to re-assign ownership has been attached to the account in Salesforce.';
            
            System.debug('E-Mail');
            
            // Reserve a single email
            Messaging.reserveSingleEmailCapacity(1);
            
            // Create a new single email message object
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Strings to hold the email addresses to which you are sending the email.
            List<String> toAddresses = new List<String> {owner.Email}; 
                
                // Assign the addresses for the To and CC lists to the mail object.
                mail.setToAddresses(toAddresses);
            
            mail.setReplyTo(user.Email);
            
            // Specify the name used as the display name.
            mail.setSenderDisplayName(user.Name);
            
            // Specify the subject line for your email address.
            mail.setSubject('Account Ownership change request: ' + accountUpdate.Name);
            
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            
            mail.setHtmlBody(requestText);
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                
            
            
            System.debug('Task');
            
            Task newTask        = new Task();
            newTask.Description = requestText; 
            newTask.OwnerId     = owner.Id;    
            newTask.Priority    = 'High';
            newTask.Subject     = 'Account Ownership Change Request from ' + user.Name;
            newTask.Type        = 'Change Ownership';
            newTask.WhatId      = accountUpdate.Id; 
            insert newTask;        
            
            System.debug('END - Method');
             
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account Owner Change Request: ');
            ApexPages.addMessage(myMsg);        
            
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, '"' + requestText + '"');
            ApexPages.addMessage(myMsg);        
            
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Emailed to "' + owner.Name + '" @ "' + owner.Email + '":');
            ApexPages.addMessage(myMsg);        
            
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Account Owner Change Request Task added to account: ' + accountUpdate.Name);
            ApexPages.addMessage(myMsg);        
            return null;
        }    
        catch (Exception err)
        {
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Account Ownership Change - Internal processing ERROR');
            ApexPages.addMessage(myMsg);        
            
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
            ApexPages.addMessage(myMsg);        
            
            return null;           
        }        
    }

}