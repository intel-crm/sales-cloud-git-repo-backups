/**************************************************************************************
Apex Class Name:  Core_ChangeRequestHandler
Version     : 1.0 
Created Date: 30 SEP 2014
Function    : Handler Class for trigger on Change Request object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             30/09/2014              Original Version
* Ashwin Dash              19/06/2017              US67790 - Added for populating Requestor and giving access to Oppty and Case as requested by Requestor on approval with the logged in user name
*************************************************************************************/
public class Core_ChangeRequestHandler
{
    //Ensures that the trigger is running only once for Change Request Owner Population functionality  
    public static boolean bChangeRequestOwnerPopulation = true;
    
    //Ensures that the trigger is running only once for Account Team Member Population functionality  
    public static boolean baccountTeamMemberCreation = true;
    
    /*
    * Method name  : ChangeRequestBeforeHandler
    * Description  : Method to update the owner of Change Request record to the related account owner on creation/updation. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */

    public static void changeRequestOwnerPopulation(List<Core_Change_Request__c> changeRequestList,Map<Id,Core_Change_Request__c> changeRequestMap)
    {
        if(isChangeRequestOwnerPopulated()) {
            
            Map<Id,Account> mapAccountIdAccount;
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setUserIds = new Set<Id>();
            Map<Id,User> mapUserIdUser ;
            
            // adding the related Accounts of the change Request 
            for(Core_Change_Request__c changeRequestInstance : changeRequestList)
            {
                setAccountIds.add(changeRequestInstance.Core_Account__c);
            }
            
            // Fetching the accounts related to Change Request
            mapAccountIdAccount = new Map<Id,Account>([SELECT Id,OwnerId FROM Account Where Id In :setAccountIds]);
            
            for(Account sobjAccnt :mapAccountIdAccount.Values()){
                setUserIds.add(sobjAccnt.OwnerId);   
            }
            
            // Fetching the accounts related to Change Request
            mapUserIdUser = new Map<Id,User>([SELECT Id,IsActive FROM User Where Id In :setUserIds]);
            
            for(Core_Change_Request__c changeRequestInstance : changeRequestList)
            {
                // validating whether the account owner is active or not
                if(mapUserIdUser.get(mapAccountIdAccount.get(changeRequestInstance.Core_Account__c).OwnerId).IsActive == false)
                    changeRequestInstance.addError(System.Label.Core_Inactive_Account_Owner + System.Label.Core_Exception);
                else{
                    changeRequestInstance.OwnerId = mapAccountIdAccount.get(changeRequestInstance.Core_Account__c).OwnerId;
                    changeRequestInstance.Core_Requestor__c = UserInfo.getUserId();  //US67790 - Added for populating Requestor with the logged in user name - Ashwin 
                }
            }
        }
    }
    
    
    public static void accountTeamMemberCreation(Map<Id,Core_Change_Request__c> mapOldChangeRequest,Map<Id,Core_Change_Request__c> mapNewChangeRequest)
    {
        if(isAccountTeamMemberCreated()) {
        
            // Fetching the record type information for Account Team Request
            List<RecordType> lstRecordType = [SELECT Id,Name,DeveloperName From RecordType where sObjectType = :System.Label.Core_Change_Request
                                              AND DeveloperName = :System.Label.Account_Team_Request_RecordType];
            
            if(!lstRecordType.isEmpty())
            {
                // Map to store account related information
                Map<Id,Id> mapChangeRequestIdAccountId = new Map<Id,Id>();
                
                // List to store Account Team Member infromation to be inserted
                List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
                
                // List of Account Share records to be inserted
                List<AccountShare> lstAccountShare = new List<AccountShare>();
                
                // Set to store the Ids for which owner information needs to be fetched
                Set<Id> sAccountIds = new Set<Id>();
                
                // List of accounts related to change request record
                List<Account> lstAccount = new List<Account>();
                
                // List of Change Request which is of "Account_Team_Request" record type
                List<Core_Change_Request__c> lstChangeRequests = new List<Core_Change_Request__c>();
                
                // Map to store account Id and account details
                Map<Id,Account> mapAccountIdAccount = new Map<Id,Account>();
                
                for(Core_Change_Request__c changeRequest :mapNewChangeRequest.values())
                {
                    // If the change request record updated is of type "Account_Team_Request" record type and 
                    // if the change request is approved then add then those records needs to be processed.
                    if(lstRecordType.get(0).Id == changeRequest.RecordTypeId && 
                        mapOldChangeRequest.get(changeRequest.Id).Core_Status__c != System.Label.Core_Approved_Status && 
                        mapNewChangeRequest.get(changeRequest.Id).Core_Status__c == System.Label.Core_Approved_Status && 
                        changeRequest.CreatedById != UserInfo.getUserId())
                        {
                            sAccountIds.add(changeRequest.Core_Account__c);
                            lstChangeRequests.add(changeRequest);
                        }
                }
                
                if(!sAccountIds.isEmpty())
                {
                    // Fetching the Read Permission from Custom label
                    String sReadPermission = System.Label.Core_Read_Permission;
                    
                    // Fetching the Edit Permission from Custom label
                    String sEditPermission = System.Label.Core_Edit_Permission;
                    
                    // Fetching all the account records related to change request record
                    lstAccount = [SELECT Id,Name,OwnerId FROM Account WHERE ID IN :sAccountIds];
                    
                    mapAccountIdAccount = new Map<Id,Account>(lstAccount);
                    
                    for(Core_Change_Request__c changeRequest :lstChangeRequests)
                    {
                        // Checking whether Account Owner is not the creator of Change Request record
                        // if its same then inserting account team and account share would throw exception
                        if(mapAccountIdAccount.get(changeRequest.Core_Account__c).OwnerId != changeRequest.CreatedById)
                        {
                            if(changeRequest.Core_Account_Team_Role__c == 'Customer Access and Entitlement') {
                                // Creating an Account Team Member record and adding it to the list
                                AccountTeamMember accountTeamMemberInstance = new AccountTeamMember();
                                accountTeamMemberInstance.AccountId = changeRequest.Core_Account__c;
                                accountTeamMemberInstance.UserId = changeRequest.createdById;
                                accountTeamMemberInstance.TeamMemberRole = changeRequest.Core_Account_Team_Role__c;                             
                                accountTeamMemberInstance.AccountAccessLevel = sEditPermission;
                                //START - US67790: Adding below code for giving direct access without creating account Share  -- Ashwin
                                accountTeamMemberInstance.OpportunityAccessLevel = 'None';
                                accountTeamMemberInstance.CaseAccessLevel = 'None';
                                //END - US67790: Adding below code for giving direct access without creating account Share  -- Ashwin
                                lstAccountTeamMember.add(accountTeamMemberInstance);
                                
                                //Commenting out the Share Record creation as its is not required after the version upgrade - Ashwin
                                // Creating an Account Share record and it to the list
                                /*AccountShare accountShareInstance = new AccountShare();
                                accountShareInstance.AccountAccessLevel = sEditPermission;
                                accountShareInstance.CaseAccessLevel = 'None';
                                accountShareInstance.OpportunityAccessLevel = 'None';
                                accountShareInstance.UserOrGroupId = changeRequest.createdById;
                                accountShareInstance.AccountId = changeRequest.Core_Account__c;
                                lstAccountShare.add(accountShareInstance);*/
                            } else {
                                // Creating an Account Team Member record and adding it to the list
                                AccountTeamMember accountTeamMemberInstance = new AccountTeamMember();
                                accountTeamMemberInstance.AccountId = changeRequest.Core_Account__c;
                                accountTeamMemberInstance.UserId = changeRequest.createdById;
                                accountTeamMemberInstance.TeamMemberRole = changeRequest.Core_Account_Team_Role__c;
                                //START - US67790: Adding below code for giving direct access without creating account Share  -- Ashwin
                                accountTeamMemberInstance.AccountAccessLevel = changeRequest.Core_Account_Access_Level__c;
                                accountTeamMemberInstance.OpportunityAccessLevel = changeRequest.Core_Opportunity_Access_Level__c;
                                accountTeamMemberInstance.CaseAccessLevel = changeRequest.Core_Case_Access_Level__c ;
                                //END - US67790: Adding below code for giving direct access without creating account Share  -- Ashwin
                                lstAccountTeamMember.add(accountTeamMemberInstance);
                                
                                //Commenting out the Share Record creation as its is not required after the version upgrade - Ashwin
                                // Creating an Account Share record and it to the list
                                /*AccountShare accountShareInstance = new AccountShare();
                                accountShareInstance.AccountAccessLevel = sEditPermission;
                                accountShareInstance.CaseAccessLevel = sReadPermission;
                                accountShareInstance.OpportunityAccessLevel = sEditPermission;
                                accountShareInstance.UserOrGroupId = changeRequest.createdById;
                                accountShareInstance.AccountId = changeRequest.Core_Account__c;
                                lstAccountShare.add(accountShareInstance);*/
                            }
                        }
                    }
                    
                    
                     
                        
                    if(!lstAccountShare.isEmpty())
                    {
                    
                         Database.SaveResult[] srList = Database.insert(lstAccountShare, false);
                         Integer iDatabaseUpdateIndex = 0; 
                         // Capturing the logs for error records
                         for (Database.SaveResult sr : srList) 
                         {
                            
                            if (!sr.isSuccess()) 
                            {
                                for(Database.Error err : sr.getErrors()) 
                                {
                                    lstAccountShare.get(iDatabaseUpdateIndex).addError(err.getMessage());
                                    
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Lead fields that affected this error: ' + err.getFields());
                                }
                            }
                            iDatabaseUpdateIndex++;
                          }
                     }
                    if(!lstAccountTeamMember.isEmpty())
                    {
                    
                         Database.SaveResult[] srList = Database.insert(lstAccountTeamMember, false);
                         Integer iDatabaseUpdateIndex = 0; 
                         // Capturing the logs for error records
                         for (Database.SaveResult sr : srList) 
                         {
                            
                            if (!sr.isSuccess()) 
                            {
                                for(Database.Error err : sr.getErrors()) 
                                {
                                    lstAccountTeamMember.get(iDatabaseUpdateIndex).addError(err.getMessage());
                                    
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Lead fields that affected this error: ' + err.getFields());
                                }
                            }
                            iDatabaseUpdateIndex++;
                          }
                     }
                }
            }
        }
    }
    
    /*
     * Method name  : isChangeRequestOwnerPopulated
     * Description  : Ensures that the trigger is running only once during the after update for "Change Request Owner Population"
     * Return Type  : boolean
     * Parameter    : NONE
     */
    public static boolean isChangeRequestOwnerPopulated() {
        // Set the bolean to TRUE once the trigger is RUN
        if (bChangeRequestOwnerPopulation) {
            bChangeRequestOwnerPopulation = false;
            return true;
        } else {
            return bChangeRequestOwnerPopulation;
        }
    }
    
     /*
     * Method name  : isAccountTeamMemberCreated
     * Description  : Ensures that the trigger is running only once during the after update for "Account Team Member Creation"
     * Return Type  : boolean
     * Parameter    : NONE
     */
    public static boolean isAccountTeamMemberCreated() {
        // Set the bolean to TRUE once the trigger is RUN
        if (baccountTeamMemberCreation) {
            baccountTeamMemberCreation = false;
            return true;
        } else {
            return baccountTeamMemberCreation;
        }
    }
    
    public static void accountNameUpdate(Map<Id,Core_Change_Request__c> mapOldChangeRequest, List<Core_Change_Request__c> listNewChangeRequest) {
        try{
            Id updateAccountNameRequestId = Schema.SObjectType.Core_Change_Request__c.getRecordTypeInfosByDeveloperName().get('Update_Account_Name_Request').getRecordTypeId();
            Map<Id,String> mapAccountIdName = new Map<Id,String>();
            for (Core_Change_Request__c cr : listNewChangeRequest) {
                if (cr.recordTypeId == updateAccountNameRequestId && cr.Core_Status__c == 'Approved' && mapOldChangeRequest?.get(cr.Id).Core_Status__c != 'Approved')  {
                    mapAccountIdName.put(cr.Core_Account__c, cr.Core_Account_Name__c);
                }
            }
            
            List<Account> listUpdateAccounts = [SELECT Id,Name FROM ACCOUNT WHERE Id IN :mapAccountIdName.keySet()];
            for (Account acc : listUpdateAccounts) {
                acc.Name = mapAccountIdName.get(acc.Id);        
            }
            
            Database.saveResult[] dsr = Database.update(listUpdateAccounts, false);   
            UCD_ACM_Logger.error('Core_ChangeRequestHandler','accountNameUpdate',String.join(dsr,';') , null);
        }catch(Exception e){
            UCD_ACM_Logger.error('Core_ChangeRequestHandler','accountNameUpdate',e.getMessage() , null);
        }finally{
            UCD_ACM_Logger.setLogDetails();   
        }
    }
    
    public static void accountAddressUpdate(Map<Id,Core_Change_Request__c> mapOldChangeRequest, List<Core_Change_Request__c> listNewChangeRequest) {
        Id updateAccountAddressRequestId = Schema.SObjectType.Core_Change_Request__c.getRecordTypeInfosByDeveloperName().get('Update_Account_Address_Request').getRecordTypeId();
        Map<Id,Core_Change_Request__c> mapAccountIdChangeRequest = new Map<Id,Core_Change_Request__c>();
        for (Core_Change_Request__c cr : listNewChangeRequest) {
            if (cr.recordTypeId == updateAccountAddressRequestId && cr.Core_Status__c == 'Approved' && mapOldChangeRequest?.get(cr.Id).Core_Status__c != 'Approved') {
                mapAccountIdChangeRequest.put(cr.Core_Account__c, cr);
            }
        }
        List<Account> listUpdateAccounts = [SELECT Id,Name FROM ACCOUNT WHERE Id IN :mapAccountIdChangeRequest.keySet()];
        for (Account acc : listUpdateAccounts) {
            acc.BillingCity = mapAccountIdChangeRequest.get(acc.Id).Core_Requested_Address__City__s;  
            acc.BillingCountryCode = mapAccountIdChangeRequest.get(acc.Id).Core_Requested_Address__CountryCode__s;
            acc.BillingStateCode = mapAccountIdChangeRequest.get(acc.Id).Core_Requested_Address__StateCode__s;
            acc.BillingStreet = mapAccountIdChangeRequest.get(acc.Id).Core_Requested_Address__Street__s;
            acc.BillingPostalCode = mapAccountIdChangeRequest.get(acc.Id).Core_Requested_Address__PostalCode__s;
        }
        
        Database.saveResult[] dsr = Database.update(listUpdateAccounts, false);   
        UCD_ACM_Logger.error('Core_ChangeRequestHandler','accountAddressUpdate',String.join(dsr,';') , null);
        UCD_ACM_Logger.setLogDetails();        
    }
    
    public static void checkRequestor(List<Core_Change_Request__c> listNewChangeRequests) {
        try{
            List<Id> listAccountId = new List<Id>();
            for (Core_Change_Request__c cr : listNewChangeRequests) {
                listAccountId.add(cr.Core_Account__c);
            }
            
            Map<Id,Account> MapIdAccount = new Map<Id,Account>([SELECT Id,OwnerId FROM ACCOUNT WHERE Id IN :listAccountId]);
            
            for (Core_Change_Request__c cr : listNewChangeRequests) {
                if (UserInfo.getUserId() == MapIdAccount.get(cr.Core_Account__c).OwnerId) {
                    cr.Core_Status__c = 'Approved';
                }
            }
        }catch(Exception e){
            UCD_ACM_Logger.error('Core_ChangeRequestHandler','checkRequestor',e.getMessage() , null);
            UCD_ACM_Logger.setLogDetails();   
        }
    } 
}