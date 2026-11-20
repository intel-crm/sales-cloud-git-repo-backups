/***************************************************************************************************************************************
Apex Class Name     : PRM_RetryIPAFlow 
Version             : 1.0
Created Date        : March 2025
Function            : To Retry IPA Flow for given Log Entries
User Story          : TWC729-7729
*************************************************************************************************************************************/

public without sharing class PRM_RetryIPAFlow {
    
    // Invocable method to retry IPA flow for given log entries
    @InvocableMethod(label='IPA Retry' description='Retries the IPA Flow for given Log Entries')
    public static void retryIpaFlow(List<String> recordIds) {

        Map<Id,Core_Log_Entry__c> LogEntryIdToRecordMap = new Map<Id,Core_Log_Entry__c>();
        Map<String,PRM_Registration_Request__c> rrMap = new Map<String,PRM_Registration_Request__c>();
        List<String> allEmails = new List<String>();
        List<Core_Log_Entry__c> logEntryToUpdate = new List<Core_Log_Entry__c>();
        List<Account> accountList = new List<Account>();
        List<string> BILLING_ADDRESS_FIELDS = LabelConfiguration__mdt.getInstance('PRM_PrimaryAddressFields').Value__c.split(',');

        
        // Query to fetch Core_Log_Entry__c records based on provided recordIds
        List<Core_Log_Entry__c> logEList = [SELECT Id, Name, Core_Retry_Counter__c, Core_Origin__c, Core_Message__c, Core_Tags__c, Core_sObjectId__c,Core_Scope__c ,Core_Details__c
                                             FROM Core_Log_Entry__c 
                                             WHERE id IN :recordIds 
                                             WITH USER_MODE];
        
        // Iterate over each log entry to process
        for(Core_Log_Entry__c logEntry : logEList){
            
            // If the log entry origin is 'CreateAccountAndRelatedRecords', split and add emails to the list
            if(logEntry.Core_Origin__c == 'CreateAccountAndRelatedRecords'){
                allEmails.addAll(logEntry.Core_Tags__c.split(';'));
            }
            // If the log entry scope is 'Account_Update', deserialize and add to account list
            else if(logEntry.Core_Scope__c == 'Account_Update' && !String.isBlank(logEntry.Core_Details__c)){
                List<Account> accountDeserialized = (List<Account>) JSON.deserialize(logEntry.Core_Details__c, List<Account>.class);
                for(Account accRec : accountDeserialized){
                    Account updatedAcc = new Account(Id = accRec.Id); // Initialize with Id
                    for (String fieldName : accRec.getPopulatedFieldsAsMap().keySet()) {
                        if (!BILLING_ADDRESS_FIELDS.contains(fieldName)) {
                            updatedAcc.put(fieldName, accRec.get(fieldName));
                        }
                    }
                    if(updatedAcc != null){
                        accountList.add(updatedAcc);
                    }
                }

              LogEntryIdToRecordMap.put(logEntry.Core_sObjectId__c, logEntry);
            }
            
        }
        
        // If we have any emails, proceed to fetch registration request records
        if(!allEmails.isEmpty()){
            // Query to fetch recently approved PRM_Registration_Request__c records based on email addresses
            List<PRM_Registration_Request__c> rrList = [SELECT Id, PRM_Account_Name__c, PRM_Account_Phone__c, PRM_Account_URL__c, PRM_Address_Line_1__c, PRM_Address_Line_2__c, PRM_Channel_Program_Level__c, PRM_Channel_Program__c, PRM_City__c, PRM_Company_Email_Domain__c, PRM_Company_Size__c, PRM_Contact_Login_ID__c, PRM_Country__c, PRM_DeDup_Criteria__c, PRM_Dup_Status__c, PRM_EmailVerifiedDateTime__c, PRM_Email_Domain_Check__c, PRM_Email_ID__c, PRM_Email_Verification_Criteria__c, PRM_Enterprise_ID__c, PRM_First_Name__c, PRM_Job_Function__c, PRM_Last_Name__c, PRM_Legal_Agreement_Criteria__c, PRM_Legal_Agreements__c, PRM_Matching_Contact__c, PRM_Partner_Relationship__c, PRM_Partner_Role__c, PRM_Partner_Segment__c, PRM_Partner_Type__c, PRM_Person_Phone_Number__c, PRM_Phy_Address_Line_1__c, PRM_Phy_Address_Line_2__c, PRM_Phy_City__c, PRM_Phy_Country__c, PRM_Phy_State_Province__c, PRM_Phy_Zip_Postal_Code__c, PRM_Preferred_Language__c, PRM_ProcessInstanceWorkItem_Id__c, PRM_Profile_Response__c, PRM_Salesforce_ID__c, PRM_State_Province__c, PRM_Status_Reason__c, PRM_Status__c, PRM_Subscriptions__c, PRM_TriggerProcess__c, PRM_Zip_Postal_Code__c, PRM_isLocked__c, PRM_isSubmitted__c, PRM_manualRecordCheck__c, Email_Verification_Status__c, PRM_Account_Partner_Type__c, PRM_Contact_Country__c, PRM_Contact_Salesforce_Id__c, PRM_Email_Log__c, PRM_Auto_Approve__c, PRM_Auto_Approve_rpt_txt__c, PRM_Review_Note_txt__c, PRM_Wechat_Union_Id__c, PRM_Channel_Program_Level_txt__c, Entitlement_Details__c, PRM_Submitted_Date__c, PRM_Profession__c, Account_ID__c, ActualApprover__c, Approved_Timestamp__c, Assigned_To__c, CNDA_Number__c, Countries__c, Current_Status__c, Geo_Code__c, Job_Title__c, PRM_New_Account__c, PRM_Reject_Reason__c, Profile_Response_Sync_Result__c, Sync_Profile_Response__c, Created_Date_Time__c, PRM_Pending_Auto_Approval_Criteria__c, PRM_Source__c, PRM_Account_Request_Queue__c, PRM_MDM_Rejection_Reason__c, PRM_Rejected_By__c, PRM_Suggested_Account__c, PRM_Alt_CompanyNameLang__c 
                                                         FROM PRM_Registration_Request__c 
                                                         WHERE PRM_Email_ID__c IN: allEmails 
                                                         AND PRM_Status__c = 'Approved' 
                                                         ORDER BY CreatedDate DESC 
                                                         LIMIT 50];
            
            // Iterate over the registration request records and add the most recent approved record for each email
            for (PRM_Registration_Request__c regRecord : rrList){
                if(!rrMap.containsKey(regRecord.PRM_Email_ID__c)){
                    rrMap.put(regRecord.PRM_Email_ID__c, regRecord);
                }
            }
            
            // If we have any registration request records, attempt to create Contact and related records
            if(!rrMap.isEmpty()){
                    PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(new List<PRM_Registration_Request__c>(rrMap.values()));
            }
        }
        
        // If there are account records to update, proceed with the update process
        if(!accountList.isEmpty() && accountList != null){
            Map<String,Account> accIdAccMap = new Map<String,Account>();
            for(Account acc : accountList){
                if(acc.accountNumber != null){
                    accIdAccMap.put(acc.accountNumber, acc);
                }
            }
            if(!accIdAccMap.isEmpty() && accIdAccMap != null){
                Account__c acs = Account__c.getValues('AccountNumber');
                Set<String> accountIdSet = new Set<String>();
                for (Account acc : [select id, accountNumber from account where accountNumber in: accIdAccMap.keyset()]) {
                    accountIdSet.add(acc.accountNumber);
                }
                for (Account acc : accountList) {
                    if (accountIdSet.contains(acc.accountNumber)) {
                        acc.AccountNumber = PRM_AccountNumberGenerator.getAccountNum();
                    }
                    acs.PRM_Max_Account_Number__c = acc.AccountNumber;    
                }update acs;
            }
            List<Database.saveResult> saveResult = Database.update(accountList, false);


            for (Integer i = 0; i< saveResult.size(); i++) {
                Id accountId = saveResult[i].getId();
                if(!saveResult[i].isSuccess() && LogEntryIdToRecordMap.containskey(accountList[i].id)){
                    // If save operation failed and retry counter is less than 4, increment retry counter
                    if(LogEntryIdToRecordMap.get(accountList[i].id).Core_sObjectId__c == accountList[i].id && LogEntryIdToRecordMap.get(accountList[i].id).Core_Retry_Counter__c < 4){
                        LogEntryIdToRecordMap.get(accountList[i].id).Core_Retry_Counter__c += 1;
                        if(!saveResult[i].getErrors().isEmpty()  && !saveResult[i].getErrors()[0].getMessage().contains(LabelConfiguration__mdt.getInstance('PRM_LockRow').Value__c)){
                            LogEntryIdToRecordMap.get(accountList[i].id).Core_Message__c = saveResult[i].getErrors()[0].getMessage();
                        }
                    }
                }
                else{
                    //If save operation was successful, update the message in the log entry
                    if(LogEntryIdToRecordMap.get(accountId).Core_sObjectId__c == accountId){
                        LogEntryIdToRecordMap.get(accountId).Core_Message__c = 'Successfully Inserted';
                    }
                }
                         // Add the log entry to the list of log entries to be updated
                logEntryToUpdate.add(LogEntryIdToRecordMap.get(accountId));
            }
            
            // If there are log entries to update, perform the update operation
            if(!logEntryToUpdate.isEmpty()){
                update logEntryToUpdate;
            }
        }
    }
}