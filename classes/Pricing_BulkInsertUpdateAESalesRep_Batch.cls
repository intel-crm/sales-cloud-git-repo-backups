/**
* @description       : 
* @author            : Accenture
* @group             : 
* @last modified on  : 04-15-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_BulkInsertUpdateAESalesRep_Batch implements Database.Batchable<sObject>,Database.Stateful{
    public String newAEEmail;
    public String aeAction;
    public String newFSEEmail;
    public String oldFSEEmail;
    public String fseAction;
    public String endCustomerId;
    public String endCustomerCountry;
    public List<PermissionSetAssignment> validPermSetAssignment = new List<PermissionSetAssignment>();
    public static Boolean isBulkAEUpdateInsertOnQuoteQTM = false;
    public Integer quotesCount = 0;
    public integer countSuccessRecs = 0;
    public integer countErrorRecs = 0;
    public Map<Id,String> quoteIdToQuoteNumMap = new Map<Id,String>();
    public Map<Id,String> quoteIdToMsgMap = new Map<Id,String>();
    Map<Id,SBQQ__Quote__c> quoteIdToQuoteRecMap = new Map<Id,SBQQ__Quote__c>();
    public List<String> oldAndNewFSEEmailList =  new List<String>();
    public List<User> usersList = new List<User>();
    public String newFSEName;
    public String oldFSEName;
    public String oldAEEmail;
    
    public Pricing_BulkInsertUpdateAESalesRep_Batch(String newAEEmailFromFlow, String aeActionFromFlow, String newFSEEmailFromFlow, String oldFSEEmailFromFlow, String fseActionFromFlow,List<PermissionSetAssignment> validPermSetAssignment,String endCustomerId,String endCustomerCountry, String oldAEEmailInput){
        this.newAEEmail = newAEEmailFromFlow;
        this.aeAction = aeActionFromFlow;
        this.newFSEEmail = newFSEEmailFromFlow;
        this.oldFSEEmail = oldFSEEmailFromFlow;
        this.fseAction = fseActionFromFlow;
        this.validPermSetAssignment = validPermSetAssignment;
        this.endCustomerId = endCustomerId;
        this.endCustomerCountry = endCustomerCountry;
        this.oldAEEmail = oldAEEmailInput;
    }
    
    /**
    * @description Method called from the Flow to Bulk Update or Insert Account Executive
    * @author Bharath Chandrashekar | 09-29-2022 
    * @param flowInputsList 
    **/
    @InvocableMethod(label = 'performBulkUpdateInsertAEOnQuoteQTM' description = 'To update or insert Account Executive in bulk on Quote or Quote Team respectively')
    public static List<String> performBulkUpdateInsertAEOnQuoteQTM(List<FlowInputs> flowInputsList){
        String newAEEmail = flowInputsList[0].aeActionInput == Label.Pricing_AE_Bulk_Insert_Flow_Action_For_Inactive_Users ? flowInputsList[0].newAEEmailInputforInactiveUser : flowInputsList[0].newAEEmailInput;
        String aeAction = flowInputsList[0].aeActionInput;
        String newFSEEmail = flowInputsList[0].fseActionInput == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users ? flowInputsList[0].newFSEEmailInputforInactiveUser : flowInputsList[0].newFSEEmailInput;
        String oldFSEEmail = flowInputsList[0].fseActionInput == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users ? flowInputsList[0].oldFSEEmailInputforInactiveUser : flowInputsList[0].oldFSEEmailInput;
        String fseAction = flowInputsList[0].fseActionInput; // Sales Rep Replace
        String unifiedEndCustomerId = flowInputsList[0].unifiedEndCustomerIdInput;
        String endCustomerCountryName = flowInputsList[0].endCustomerCountryInput;
        String oldAEEmail = flowInputsList[0].aeActionInput == Label.Pricing_AE_Bulk_Insert_Flow_Action_For_Inactive_Users ? flowInputsList[0].oldAEEmailInputforInactiveUser : flowInputsList[0].oldAEEmailInput;
        // TWC1972-7639
        String fseOldToReplace = flowInputsList[0].fseOldToReplace;
        String fseNewToReplaceWith = flowInputsList[0].fseNewToReplaceWith;
        if(fseAction == 'Sales Rep Replace'){
            oldFSEEmail = fseOldToReplace;
            newFSEEmail = fseNewToReplaceWith;
        }

        String errorIndicatorUser;
        String errorIndicatorAE;
        String errorIndicatorQuote;
        List<String> errorRespList = new List<String>();

        try{
            List<User> userList = new List<User>();
            if(!String.isEmpty(aeAction)){
                userList = [SELECT Id ,Name FROM User WHERE Email =:newAEEmail AND IsActive = true];
            }
            String query1 = Label.Pricing_BulkInsertUpdateAESalesRep_Batch_Query1;

            List<SBQQ__Quote__c> quotesList = !String.isEmpty(aeAction) && !aeAction.contains('End Customer') ?  
                [SELECT Id,Name, Pricing_Intel_Account_Exec_Email_Txt__c FROM SBQQ__Quote__c 
                 WHERE Pricing_Intel_Account_Exec_Email_Txt__c =: UserInfo.getUserEmail() 
                 AND Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender AND Pricing_On_Hold_Cb__c = false] : 
            (!String.isEmpty(fseAction) && (fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users || fseAction == 'Sales Rep Replace')) ? 
                [SELECT Id,Name, Pricing_Intel_Account_Exec_Email_Txt__c FROM SBQQ__Quote__c 
                 WHERE Pricing_Intel_Sales_Rep_Email_Txt__c =: oldFSEEmail 
                 AND Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender AND Pricing_On_Hold_Cb__c = false] :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isNotBlank(endCustomerCountryName) && String.isNotBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND Pricing_On_Hold_Cb__c =' + false + ' AND ((Pricing_IsUnifiedCustomer__c =' + true +' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false +' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+')) AND Pricing_End_Customer_Country_Nm__c =\''+ endCustomerCountryName+'\'') :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isBlank(endCustomerCountryName) && String.isBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND Pricing_On_Hold_Cb__c =' + false) :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isNotBlank(endCustomerCountryName) && String.isBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND Pricing_On_Hold_Cb__c =' + false + ' AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountryName+'\'') :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isBlank(endCustomerCountryName) && String.isNotBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND Pricing_On_Hold_Cb__c =' + false + ' AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+'))') :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isNotBlank(endCustomerCountryName) && String.isNotBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+')) AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountryName +'\''+' AND Id IN(SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\''+ oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\''+ Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND Pricing_On_Hold_Cb__c =' + false) :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isNotBlank(endCustomerCountryName) && String.isBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountryName + '\''+' AND Id IN(SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\''+ oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender + '\''+' AND Pricing_Role_Nm__c=\''+ Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND Pricing_On_Hold_Cb__c =' + false) :
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isBlank(endCustomerCountryName) && String.isNotBlank(unifiedEndCustomerId)) ?  
                Database.query(query1 + ' AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + unifiedEndCustomerId +'\''+')) AND Id IN(SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\''+ oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\''+ Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND Pricing_On_Hold_Cb__c =' + false):
            (!String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isBlank(endCustomerCountryName) && String.isBlank(unifiedEndCustomerId)) ? 
                Database.query(query1 + ' AND Id IN(SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\''+ oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\''+ Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND Pricing_On_Hold_Cb__c =' + false) :
                [SELECT Id,Name, Pricing_Intel_Account_Exec_Email_Txt__c FROM SBQQ__Quote__c 
                WHERE Pricing_Intel_Sales_Rep_Email_Txt__c =: UserInfo.getUserEmail() 
                AND Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender AND Pricing_On_Hold_Cb__c = false];

            List<PermissionSetAssignment> validPermSetAssignment = !String.isEmpty(aeAction)?
                [SELECT Id, Assignee.Id FROM PermissionSetAssignment WHERE Assignee.Email =: newAEEmail 
                    AND Assignee.IsActive = true AND PermissionSet.name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive LIMIT 1]:
                [SELECT Id, Assignee.Id FROM PermissionSetAssignment WHERE Assignee.Email =: newFSEEmail 
                    AND Assignee.IsActive = true AND PermissionSet.name =: Label.Pricing_Tender_PermissionSets_TenderUser LIMIT 1];
            
            if(userList.size() == 0 && !String.isEmpty(aeAction)){
                errorIndicatorUser = Label.Pricing_Bulk_Invalid_AE_User_Err_Msg;
                errorRespList.add(errorIndicatorUser);
                createCoreLogEntry(errorIndicatorUser, 'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+ aeAction, aeAction );        
            }
            else if(quotesList.size() == 0){
                errorIndicatorQuote = (!String.isEmpty(fseAction) && (fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users || fseAction == 'Sales Rep Replace')) ?  Label.Pricing_Bulk_AESDM_No_Quotes_Err_Msg.replace('<email address>' , oldFSEEmail) 
                                      : (!String.isEmpty(aeAction) && aeAction.contains('End Customer')) ? Label.Pricing_bulk_EC_AE_No_Quotes_Msg : Label.Pricing_Bulk_AESDM_No_Quotes_Err_Msg.replace('<email address>' , UserInfo.getUserEmail());

                errorRespList.add(errorIndicatorQuote);
                createCoreLogEntry(errorIndicatorQuote,'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+ (!String.isEmpty(aeAction) ? aeAction : fseAction), 
                                   !String.isEmpty(aeAction) ? aeAction : fseAction);            
            }
            else if(validPermSetAssignment.size() == 0 && !String.isEmpty(fseAction)){
                errorIndicatorAE = Label.Pricing_Bulk_SDM_PS_Err_Msg;
                errorRespList.add(errorIndicatorAE);
                createCoreLogEntry(errorIndicatorAE, 'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+fseAction,fseAction );                
            }
            else if(quotesList.size() > 0){
                if(!String.isEmpty(aeAction)){
                    Id jobId = Database.executeBatch(new Pricing_BulkInsertUpdateAESalesRep_Batch(newAEEmail, aeAction, newFSEEmail, oldFSEEmail, fseAction, validPermSetAssignment,unifiedEndCustomerId,endCustomerCountryName,oldAEEmail));
                }
                else if(!String.isEmpty(fseAction) && fseAction == Label.Pricing_FSE_Bulk_Update_Flow_Action && validPermSetAssignment.size() > 0){
                    Id jobId = Database.executeBatch(new Pricing_BulkInsertUpdateAESalesRep_Batch(newAEEmail, aeAction, newFSEEmail, oldFSEEmail, fseAction, validPermSetAssignment,unifiedEndCustomerId,endCustomerCountryName,oldAEEmail), Integer.valueof(Label.Pricing_SDM_Bulk_Update_Batch_Size));    
                }
                else if(!String.isEmpty(fseAction) && (fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users || fseAction == 'Sales Rep Replace') && validPermSetAssignment.size() > 0){
                    Id jobId = Database.executeBatch(new Pricing_BulkInsertUpdateAESalesRep_Batch(newAEEmail, aeAction, newFSEEmail, oldFSEEmail, fseAction, validPermSetAssignment,unifiedEndCustomerId,endCustomerCountryName,oldAEEmail), Integer.valueof(Label.Pricing_SDM_Bulk_Insert_Batch_Size));
                }
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
        return errorRespList;
    }
    
    public static void createCoreLogEntry(String details, String message, String origin){
        core_log_entry__c logEntry = new core_log_entry__c();
        logEntry.Core_Details__c = details;
        logEntry.Core_Message__c = message;
        logEntry.Core_Origin__c = origin;
        logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
        logEntry.Core_Severity__c = 'Medium';
        logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
        logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
        logEntry.Core_When__c = system.now();
        insert logEntry;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query2 = Label.Pricing_BulkInsertUpdateAESalesRep_Batch_Query2;
        return !String.isEmpty(aeAction) && !aeAction.contains('End Customer') ? 
            Database.getQueryLocator([SELECT Id,name,SBQQ__Account__r.name,Pricing_End_Customer_Name__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordType.DeveloperName, Pricing_Folio_ID_Nm__c,SBQQ__Status__c,SBQQ__Account__c,Pricing_End_Customer__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Country_Nm__c,Pricing_Region_Nm__c,Pricing_Project_Name_Nm__c,
                                      Pricing_ShipmentStDate_Dt__c,Pricing_ShipmentEndDate_Dt__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Bid_Dt__c,Pricing_Customer_Reference_Id__c,Pricing_Account_Executive_Nm__c FROM SBQQ__Quote__c 
                                      WHERE Id NOT IN
                                      (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE  Pricing_Quote_Team_Member_Id__r.email =:newAEEmail AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =:Label.Pricing_Program_Code_Tender) 
                                      AND Id  IN
                                      (SELECT Pricing_Quote_Id__c  FROM Pricing_Quote_Team__c WHERE  Pricing_Quote_Team_Member_Id__r.email =: aeAction == Label.Pricing_AE_Bulk_Insert_Flow_Action_For_Inactive_Users ? oldAEEmail : UserInfo.getUserEmail()  AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_Account_Executive)
                                       AND Pricing_On_Hold_Cb__c = false ORDER BY name DESC]) :                              
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isNotBlank(endCustomerCountry) && String.isNotBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE  Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+')) AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountry +'\''+' ORDER BY name DESC') :
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isNotBlank(endCustomerCountry) && String.isBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountry +'\''+'ORDER BY name DESC') :
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isBlank(endCustomerCountry) && String.isNotBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\''+ endCustomerId +'\''+')) ORDER BY name DESC') :
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkInsertion_Action && String.isBlank(endCustomerCountry) && String.isBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') ORDER BY name DESC') :
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isNotBlank(endCustomerCountry) && String.isNotBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND Id IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\'' + Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+')) AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountry +'\''+'ORDER BY name DESC') : 
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isNotBlank(endCustomerCountry) && String.isBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND Id IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\'' + Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND Pricing_End_Customer_Country_Nm__c =\'' + endCustomerCountry +'\''+'ORDER BY name DESC') :
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isBlank(endCustomerCountry) && String.isNotBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND Id IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\'' + Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') AND ((Pricing_IsUnifiedCustomer__c =' + true + ' AND Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+') OR (Pricing_IsUnifiedCustomer__c =' + false + ' AND Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c =\'' + endCustomerId +'\''+')) ORDER BY name DESC') :
                !String.isEmpty(aeAction) && aeAction == Label.Pricing_EC_AE_BulkUpdate_Action && String.isBlank(endCustomerCountry) && String.isBlank(endCustomerId)? 
                Database.getQueryLocator(query2 + ' WHERE Pricing_On_Hold_Cb__c =' + false + ' AND Id NOT IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + newAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+') AND Id IN (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =\'' + oldAEEmail +'\''+' AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =\'' + Label.Pricing_Program_Code_Tender +'\''+' AND Pricing_Role_Nm__c=\'' + Label.Pricing_Quote_Team_Role_Account_Executive +'\''+') ORDER BY name DESC') :
                (!String.isEmpty(fseAction) && ((fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users) || (fseAction == 'Sales Rep Replace'))) ? 
                Database.getQueryLocator([SELECT Id,name,SBQQ__Account__r.name,Pricing_End_Customer_Name__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordType.DeveloperName,(SELECT Id, Pricing_Status_Nm__c FROM SBQQ__LineItems__r), 
                                        Pricing_Folio_ID_Nm__c,SBQQ__Status__c,SBQQ__Account__c,Pricing_End_Customer__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Country_Nm__c,Pricing_Region_Nm__c,Pricing_Project_Name_Nm__c,
                                        Pricing_ShipmentStDate_Dt__c,Pricing_ShipmentEndDate_Dt__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Bid_Dt__c,Pricing_Customer_Reference_Id__c,Pricing_Account_Executive_Nm__c 
                                        FROM SBQQ__Quote__c
                                        WHERE Id NOT IN(SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =:newFSEEmail 
                                                            AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =:Label.Pricing_Program_Code_Tender) 
                                        AND Id IN(SELECT Pricing_Quote_Id__c  FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Team_Member_Id__r.email =: oldFSEEmail 
                                                    AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_FSE)
                                        AND Pricing_On_Hold_Cb__c = false ORDER BY name DESC]) :                        
                Database.getQueryLocator([SELECT Id,name,SBQQ__Account__r.name,Pricing_End_Customer_Name__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordType.DeveloperName, Pricing_Folio_ID_Nm__c,SBQQ__Status__c,SBQQ__Account__c,Pricing_End_Customer__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Country_Nm__c,Pricing_Region_Nm__c,Pricing_Project_Name_Nm__c,
                Pricing_ShipmentStDate_Dt__c,Pricing_ShipmentEndDate_Dt__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Bid_Dt__c,Pricing_Customer_Reference_Id__c,Pricing_Account_Executive_Nm__c FROM SBQQ__Quote__c 
                WHERE Id NOT IN
                (SELECT Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE  Pricing_Quote_Team_Member_Id__r.email =:newFSEEmail AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =:Label.Pricing_Program_Code_Tender) 
                AND Id  IN
                (SELECT Pricing_Quote_Id__c  FROM Pricing_Quote_Team__c WHERE  Pricing_Quote_Team_Member_Id__r.email =: UserInfo.getUserEmail() AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender AND Pricing_Role_Nm__c =:Label.Pricing_Quote_Team_Role_FSE)
                AND Pricing_On_Hold_Cb__c = false ORDER BY name DESC]) ; 
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quoteRecsList){
        try
        {
            Map<String,String> successMap = new Map<String,String>();
            Map<String,Id> successQuoteNumToQuoteIdMap = new Map<String,Id>();
            Map<String,String> errorMap = new Map<String,String>();
            Map<String,Id> errorQuoteNumToQuoteIdMap = new Map<String,Id>();
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            String logMsg;
            String errorMsg;
            List<Database.SaveResult> bulkUpdResults = new List<Database.SaveResult>();
            List<Id> quoteIdsQTMUpdate = new List<Id>();
            Id userIdforDeleteShare;
            User oldAEUser;
            Set<Id> quoteIds = new Set<Id>();

            if(aeAction == Label.Pricing_AE_Bulk_Update_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Update_Flow_Action || aeAction == Label.Pricing_EC_AE_BulkUpdate_Action){
                isBulkAEUpdateInsertOnQuoteQTM = true;
                List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
                List<List<SBQQ__Quote__c>> results = new List<List<SBQQ__Quote__c>>();
                if(!String.isEmpty(fseAction)){
                    // Account team check
                    results = getValidAccountTeamQuote(quoteRecsList);
                    quotesToProcess = results[0];
                }else{
                    quotesToProcess = quoteRecsList;
                }
                List<List<Object>> quoteRecsToBeUpd = getAEEmailListForBulkUpdate(quotesToProcess);
                SBQQ.TriggerControl.disable();
                Database.SaveResult[] quoteUpdResults = database.update((List<SBQQ__Quote__c>)quoteRecsToBeUpd[0], false);
                SBQQ.TriggerControl.enable();
                Database.SaveResult[] quoteTeamInsResults = database.insert((List<Pricing_Quote_Team__c>)quoteRecsToBeUpd[1], false);
                quoteIdsQTMUpdate = (List<Id>)quoteRecsToBeUpd[2];
                bulkUpdResults.addAll(quoteUpdResults);
                bulkUpdResults.addAll(quoteTeamInsResults);
                for(database.SaveResult sr : bulkUpdResults){
                    if(sr.issuccess()){
                        countSuccessRecs++;
                        if(quoteIdToQuoteNumMap.containsKey(sr.getId())){
                            quoteIdToMsgMap.put(sr.getId(),'Success');
                            logMsg = 'Record: '+quoteIdToQuoteNumMap.get(sr.getId())+' has been processed successfully.';
                            successMap.put(quoteIdToQuoteNumMap.get(sr.getId()),logMsg);
                            successQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(sr.getId()),sr.getId());
                        }
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = err.getMessage();
                        }
                        countErrorRecs++;
                        if(quoteIdToQuoteNumMap.containsKey(sr.getId())){
                            quoteIdToMsgMap.put(sr.getId(),errorMsg);
                            errorMap.put(quoteIdToQuoteNumMap.get(sr.getId()),errorMsg);
                            errorQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(sr.getId()),sr.getId());
                        }
                    }
                }

                for(Pricing_Quote_Team__c qtme: [SELECT Id, Pricing_Quote_Id__c, Pricing_Quote_Id__r.Name 
                                                    FROM Pricing_Quote_Team__c 
                                                    WHERE Pricing_Quote_Id__c IN: quoteIdsQTMUpdate]){
                    quoteIdToQuoteNumMap.put(qtme.Pricing_Quote_Id__c,qtme.Pricing_Quote_Id__r.Name);
                    quoteIdToMsgMap.put(qtme.Pricing_Quote_Id__c,'Success');
                    logMsg = 'Record: '+qtme.Pricing_Quote_Id__r.Name+' has been processed successfully.';
                    successMap.put(qtme.Pricing_Quote_Id__r.Name,logMsg);
                    successQuoteNumToQuoteIdMap.put(qtme.Pricing_Quote_Id__r.Name,qtme.Pricing_Quote_Id__c);
                }

                if(!String.isEmpty(aeAction)){
                    if(aeAction == Label.Pricing_EC_AE_BulkUpdate_Action){
                        oldAEUser = [SELECT Id FROM User WHERE Email =: oldAEEmail Limit 1];
                        userIdforDeleteShare = oldAEUser.Id;
                    }
                    userIdforDeleteShare = aeAction == Label.Pricing_EC_AE_BulkUpdate_Action ? oldAEUser.Id : UserInfo.getUserId();
                    deleteShareQuoteAE(new Set<Id>(successQuoteNumToQuoteIdMap.values()),userIdforDeleteShare);
                }
            }
            else if(aeAction == Label.Pricing_AE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || aeAction == Label.Pricing_EC_AE_BulkInsertion_Action){
                Set<Id> quoteTeamIds = new Set<Id>();
                isBulkAEUpdateInsertOnQuoteQTM = true;
                List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
                List<List<SBQQ__Quote__c>> results = new List<List<SBQQ__Quote__c>>();
                if(!String.isEmpty(fseAction)){
                    // accoount team check
                    results = getValidAccountTeamQuote(quoteRecsList);
                    quotesToProcess = results[0];
                }else{
                    quotesToProcess = quoteRecsList;
                }

                List<Pricing_Quote_Team__c> quoteTeamListForBulkInsert = getQuoteTeamListForBulkInsert(quotesToProcess);
                Database.SaveResult[] qtmInsertResults = database.insert(quoteTeamListForBulkInsert, false);
                for(database.SaveResult sr : qtmInsertResults){
                    if(sr.issuccess()){
                        countSuccessRecs++;
                        quoteTeamIds.add(sr.getId());
                    }else{
                        countErrorRecs++;
                    }
                }

                for(Pricing_Quote_Team__c qtm: [SELECT Id, Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Id IN: quoteTeamIds]){
                    quoteIdToMsgMap.put(qtm.Pricing_Quote_Id__c,'Success');
                }
            }else if(aeAction == Label.Pricing_AE_Bulk_Insert_Flow_Action_For_Inactive_Users || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users){
                Set<Id> quoteTeamIds = new Set<Id>();
                isBulkAEUpdateInsertOnQuoteQTM = true;
                List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
                List<List<SBQQ__Quote__c>> results = new List<List<SBQQ__Quote__c>>();
                if(!String.isEmpty(fseAction)){
                    // Account team check
                    results = getValidAccountTeamQuote(quoteRecsList);
                    quotesToProcess = results[0];
                }else{
                    quotesToProcess = quoteRecsList;
                }

                List<Pricing_Quote_Team__c> quoteTeamListForBulkInsert = getQuoteTeamListForBulkInsert(quotesToProcess);
                Database.SaveResult[] qtmInsertResults = database.insert(quoteTeamListForBulkInsert, false);
                for(database.SaveResult sr : qtmInsertResults){
                    if(sr.issuccess()){
                        countSuccessRecs++;
                        quoteTeamIds.add(sr.getId());
                    }else{
                        countErrorRecs++;
                    }
                }
                List<Pricing_Quote_Team__c> qtmList = new List<Pricing_Quote_Team__c>();
                for(Pricing_Quote_Team__c qtm : [SELECT Id, Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Id IN: quoteTeamIds]){
                    quoteIdToMsgMap.put(qtm.Pricing_Quote_Id__c,'Success');
                    quoteIds.add(qtm.Pricing_Quote_Id__c);

                }
                for(Pricing_Quote_Team__c qtm : [SELECT Id, Pricing_Quote_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN: quoteIds AND ((Pricing_Quote_Team_Member_Id__r.email = :oldAEEmail AND Pricing_Role_Nm__c = :Label.Pricing_Quote_Team_Role_Account_Executive) OR (Pricing_Quote_Team_Member_Id__r.email = :oldFSEEmail AND Pricing_Role_Nm__c = :Label.Pricing_Quote_Team_Role_FSE))]){
                    qtmList.add(qtm);
                }
                if(qtmList.size() > 0){
                    delete qtmList;
                }
            }
            else if(fseAction == 'Sales Rep Replace'){
                isBulkAEUpdateInsertOnQuoteQTM = true;
                List<SBQQ__Quote__c> quotesToReplaceFSE = new List<SBQQ__Quote__c>();
                List<SBQQ__Quote__c> quotesFSENotInAccTeam = new List<SBQQ__Quote__c>();
                List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
                List<List<SBQQ__Quote__c>> results = new List<List<SBQQ__Quote__c>>();

                results = getValidAccountTeamQuote(quoteRecsList);
                quotesToProcess = results[0];
                quotesFSENotInAccTeam = results[1];

                // adding error for Account Team missmatch quote
                for(SBQQ__Quote__c quote: quotesFSENotInAccTeam){
                    quoteIdToMsgMap.put(quote.Id,Label.Pricing_Tender_Quote_Sales_Rep_Error_Message);
                    errorMap.put(quote.Name,Label.Pricing_Tender_Quote_Sales_Rep_Error_Message);
                    errorQuoteNumToQuoteIdMap.put(quote.Name,quote.Id);
                }

                for(SBQQ__Quote__c quote: quotesToProcess ){ // set validation for pending Quote Lines Quote
                    for(SBQQ__QuoteLine__c ql : quote.SBQQ__LineItems__r){
                        if(ql.Pricing_Status_Nm__c == 'Pending Intel Field Review'){
                            quoteIdToMsgMap.put(quote.Id,'FSE can not be replaced as Appproval Process is in-progress.');
                            errorMap.put(quote.Name,'FSE can not be replaced as Appproval Process is in-progress.');
                            errorQuoteNumToQuoteIdMap.put(quote.Name,quote.Id);
                        }
                    }
                    if(!quoteIdToMsgMap.containsKey(quote.Id)){
                        quotesToReplaceFSE.add(quote);
                    }
                }
                
                List<List<Object>> quoteRecsToBeUpd = getFSESDMReplace(quotesToReplaceFSE);
                SBQQ.TriggerControl.disable();
                Database.SaveResult[] quoteUpdResults = database.update((List<SBQQ__Quote__c>)quoteRecsToBeUpd[0], false);
                SBQQ.TriggerControl.enable();
                bulkUpdResults.addAll(quoteUpdResults);
                for(database.SaveResult sr : bulkUpdResults){
                    if(sr.issuccess()){
                        countSuccessRecs++;
                        if(quoteIdToQuoteNumMap.containsKey(sr.getId())){
                            quoteIdToMsgMap.put(sr.getId(),'Success');
                            logMsg = 'Record: '+quoteIdToQuoteNumMap.get(sr.getId())+' has been processed successfully.';
                            successMap.put(quoteIdToQuoteNumMap.get(sr.getId()),logMsg);
                            successQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(sr.getId()),sr.getId());
                        }
                    } else{
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = err.getMessage();
                        }
                        countErrorRecs++;
                        if(quoteIdToQuoteNumMap.containsKey(sr.getId())){
                            quoteIdToMsgMap.put(sr.getId(),errorMsg);
                            errorMap.put(quoteIdToQuoteNumMap.get(sr.getId()),errorMsg);
                            errorQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(sr.getId()),sr.getId());
                        }
                    }
                }
            }

            if(successMap.size()>0 && successQuoteNumToQuoteIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(successMap,successQuoteNumToQuoteIdMap,'Low',!String.isEmpty(aeAction) ? aeAction : fseAction));
            }
            if(errorMap.size()>0 && errorQuoteNumToQuoteIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(errorMap,errorQuoteNumToQuoteIdMap,'Medium',!String.isEmpty(aeAction) ? aeAction : fseAction));
            }
            if(logEntryList.size() > 0){
                insert logEntryList;    
            }
        }
        
        catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }

    /**
    * @description validate account team for records
    * @author Vrushabh Uprikar | 01-17-2025 
    * @param quoteRecsList 
    * @return List<List<SBQQ__Quote>> 
    **/
    public List<List<SBQQ__Quote__c>> getValidAccountTeamQuote(List<SBQQ__Quote__c> quoteRecsList){
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,List<SBQQ__Quote__c>> mapAccountIdQuotes = new  Map<Id,List<SBQQ__Quote__c>>();
        List<SBQQ__Quote__c> quotesFSENotInAccTeam = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec: quoteRecsList){
            quoteIdToQuoteNumMap.put(quoteRec.Id,quoteRec.Name);
            accIdSet.add(quoteRec.SBQQ__Account__c); // Account Set 
            if(mapAccountIdQuotes.containsKey(quoteRec.SBQQ__Account__c)){ // map for Account Id and Quote List
                mapAccountIdQuotes.get(quoteRec.SBQQ__Account__c).add(quoteRec);
            }else{
                mapAccountIdQuotes.put(quoteRec.SBQQ__Account__c, new List<SBQQ__Quote__c>{quoteRec});
            }
            quoteIdToQuoteRecMap.put(quoteRec.Id,quoteRec);
        }

        // Check Account Team Member for Quotes
        if(accIdSet.size() > 0){
            List<AccountTeamMember> accTeamList = new List<AccountTeamMember>([SELECT Id,User.Email,UserId,AccountId FROM AccountTeamMember WHERE AccountId IN:accIdSet AND User.Email =:newFSEEmail]);
            if(accTeamList.size() > 0){
                for(AccountTeamMember accTeam : accTeamList) {
                    if(mapAccountIdQuotes.containsKey(accTeam.AccountId)){
                        quotesToProcess.addAll(mapAccountIdQuotes.get(accTeam.AccountId));
                    }else{
                        quotesFSENotInAccTeam.addAll(mapAccountIdQuotes.get(accTeam.AccountId));
                    }
                }
            }else{
                for(Id accId : accIdSet){
                quotesFSENotInAccTeam.addAll(mapAccountIdQuotes.get(accId));
                }
            }
        }
        List<List<SBQQ__Quote__c>> result = new List<List<SBQQ__Quote__c>>();
        result.add(quotesToProcess);
        result.add(quotesFSENotInAccTeam);

        return result;
    }
    
    public void finish(Database.BatchableContext bc){
        try{
            String csvColumnHeader;
            List<String> csvRowValues = new List<String>();
            String loggedInUserEmail = UserInfo.getUserEmail();
            Map<String,String> successInsMap = new Map<String,String>();
            Map<String,Id> successInsQuoteNumToQuoteIdMap = new Map<String,Id>();
            Map<String,String> errorInsMap = new Map<String,String>();
            Map<String,Id> errorInsQuoteNumToQuoteIdMap = new Map<String,Id>();
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            String status = '';
            String logMsg;
            String errorMsg =!String.isEmpty(aeAction) ? Label.Pricing_AE_Bulk_Insert_Error_Msg : Label.Pricing_SDM_Bulk_Insert_Error_Msg;
            List<OrgWideEmailAddress> orgWideEmailAdd = [SELECT Id from OrgWideEmailAddress where Address=:Label.Pricing_OrgWideEmailAddress];
            Id orgWideEmailAddId = orgWideEmailAdd[0].id;
            //old AND new fse Names
            if(!String.isEmpty(fseAction) && (fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users || fseAction == 'Sales Rep Replace')) {
                oldAndNewFSEEmailList.add(oldFSEEmail);
                oldAndNewFSEEmailList.add(newFSEEmail);
                usersList = [SELECT Id, Name, Email FROM User WHERE Email IN: oldAndNewFSEEmailList AND IsActive = true];
            }
            for(User user : usersList){  
                if(user.Email == oldFSEEmail){
                    oldFSEName = user.Name;
                }
                if(user.Email == newFSEEmail){
                    newFSEName = user.Name;
                }
            }
            //form the data rows to append in the csv file
            if(aeAction == Label.Pricing_AE_Bulk_Update_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Update_Flow_Action || aeAction == Label.Pricing_EC_AE_BulkUpdate_Action || fseAction =='Sales Rep Replace' ){
                for(Id key: quoteIdToQuoteNumMap.keyset()){
                    String row;
                    status = quoteIdToMsgMap.containsKey(key) ? quoteIdToMsgMap.get(key):'';
                    status = (!String.isEmpty(status) && status.contains(','))?status.replace(',',''):!(String.isEmpty(status) && status.contains(','))?status:'';
                    String accountName = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).SBQQ__Account__r.name)?((quoteIdToQuoteRecMap.get(Key)).SBQQ__Account__r.name).replace(',',''):'';
                    String endCustName = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Name__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Name__c).replace(',',''):'';
                    String endCustCountry = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Country_Nm__c)?(quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Country_Nm__c:'';
                    String endCustRegion = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Region_Nm__c)?(quoteIdToQuoteRecMap.get(Key)).Pricing_Region_Nm__c:'';
                    String proj = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Project_Name_Nm__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_Project_Name_Nm__c).replace(',',''):'';
                    String strDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).year()):'';
                    String endDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).year()):'';
                    String respReqDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).year()):'';
                    String propDueDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).year()):'';
                    String refReqId = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Customer_Reference_Id__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_Customer_Reference_Id__c).replace(',',''):'';
                    if(quoteIdToMsgMap.containsKey(key)){
                        row = status + ',' + quoteIdToQuoteNumMap.get(key) + ',' + (quoteIdToQuoteRecMap.get(Key)).SBQQ__Status__c 
                            + ',' + accountName + ',' + endCustName + ',' + endCustCountry + ',' + endCustRegion + ',' + proj 
                            + ',' + strDate + ',' + endDate + ',' + respReqDate + ',' + propDueDate + ',' + refReqId;
                        csvRowValues.add(row);
                    }
                    else{
                        row = errorMsg + ',' + quoteIdToQuoteNumMap.get(key) + ',' + (quoteIdToQuoteRecMap.get(Key)).SBQQ__Status__c 
                            + ',' + accountName + ',' + endCustName + ',' + endCustCountry + ',' + endCustRegion + ',' + proj 
                            + ',' + strDate + ',' + endDate + ',' + respReqDate + ',' + propDueDate + ',' + refReqId;
                        csvRowValues.add(row);
                        logMsg = 'Record: '+quoteIdToQuoteNumMap.get(key)+' is processed with an error. '+ (!String.isEmpty(aeAction) ? Label.Pricing_AE_Bulk_Insert_Error_Msg : Label.Pricing_SDM_Bulk_Insert_Error_Msg);
                        errorInsMap.put(quoteIdToQuoteNumMap.get(key),logMsg);
                        errorInsQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(key),key);
                    }
                }
            }
            else if(aeAction == Label.Pricing_AE_Bulk_Insert_Flow_Action || aeAction == Label.Pricing_AE_Bulk_Insert_Flow_Action_For_Inactive_Users || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users || aeAction == Label.Pricing_EC_AE_BulkInsertion_Action){
                for(Id key: quoteIdToQuoteNumMap.keyset()){
                   if(key != null && quoteIdToQuoteRecMap.get(Key) != null) {
                        String accountName = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).SBQQ__Account__r.name)?((quoteIdToQuoteRecMap.get(Key)).SBQQ__Account__r.name).replace(',',''):'';
                        String endCustName = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Name__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Name__c).replace(',',''):'';
                        String endCustCountry = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Country_Nm__c)?(quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Country_Nm__c:'';
                        String endCustRegion = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Region_Nm__c)?(quoteIdToQuoteRecMap.get(Key)).Pricing_Region_Nm__c:'';
                        String proj = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Project_Name_Nm__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_Project_Name_Nm__c).replace(',',''):'';
                        String strDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).year()):'';
                        String endDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).year()):'';
                        String respReqDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).year()):'';
                        String propDueDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).year()):'';
                        String refReqId = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Customer_Reference_Id__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_Customer_Reference_Id__c).replace(',',''):'';
                        if(quoteIdToMsgMap.containsKey(key)){
                            String row;
                            status = quoteIdToMsgMap.get(key);
                            status = (!String.isEmpty(status) && status.contains(','))?status.replace(',',''):!(String.isEmpty(status) && status.contains(','))?status:'';
                            row = status + ',' + quoteIdToQuoteNumMap.get(key) + ',' + (quoteIdToQuoteRecMap.get(Key)).SBQQ__Status__c 
                                + ',' + accountName + ',' + endCustName + ',' + endCustCountry + ',' + endCustRegion + ',' + proj 
                                + ',' + strDate + ',' + endDate + ',' + respReqDate + ',' + propDueDate + ',' + refReqId;
                            csvRowValues.add(row);
                            logMsg = 'Record: '+quoteIdToQuoteNumMap.get(key)+' has been processed successfully.';
                            successInsMap.put(quoteIdToQuoteNumMap.get(key),logMsg);
                            successInsQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(key),key);
                        }
                        else{
                            String row;
                            row = errorMsg + ',' + quoteIdToQuoteNumMap.get(key) + ',' + (quoteIdToQuoteRecMap.get(Key)).SBQQ__Status__c 
                                + ',' + accountName + ',' + endCustName + ',' + endCustCountry + ',' + endCustRegion + ',' + proj 
                                + ',' + strDate + ',' + endDate + ',' + respReqDate + ',' + propDueDate + ',' + refReqId;
                            csvRowValues.add(row);
                            logMsg = 'Record: '+quoteIdToQuoteNumMap.get(key)+' is processed with an error. '+ (!String.isEmpty(aeAction) ? Label.Pricing_AE_Bulk_Insert_Error_Msg : Label.Pricing_SDM_Bulk_Insert_Error_Msg);
                            errorInsMap.put(quoteIdToQuoteNumMap.get(key),logMsg);
                            errorInsQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(key),key);
                        }
                    }
                }
            }
            if(successInsMap.size()>0 && successInsQuoteNumToQuoteIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(successInsMap,successInsQuoteNumToQuoteIdMap,'Low',(!String.isEmpty(aeAction) ? aeAction : fseAction)));
            }
            if(errorInsMap.size()>0 && errorInsQuoteNumToQuoteIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(errorInsMap,errorInsQuoteNumToQuoteIdMap,'Medium',(!String.isEmpty(aeAction) ? aeAction : fseAction)));
            }
            if(logEntryList.size() > 0){
                insert logEntryList;    
            }
            csvColumnHeader = 'Success/Error, Quote Number, Status, Account, End Customer, End Customer Country/Region, End Customer Sales Geography, Project Name, Pricing Start Date, Pricing End Date, Intel Response Requested By Date, Proposal Due Date, Reference Request ID \n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            Blob b = Blob.valueOf(csvFile);
            //Send an email once the Batch finishes processing
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            String urlValue = '<a href="https://ags.intel.com/identityiq/ui/rest/redirect?rp1=/accessRequest/accessRequest.jsf&rp2=accessRequest/manageAccess/add?filterKeyword=IQR%20Account%20Executive">here</a>';
            String inValidAEuser = (!String.isEmpty(aeAction) && validPermSetAssignment.size()>0)? '' : 'To access an IQR quote, you must be approved for the IQR Account Executive role in AGS. <br/> '+'Go '+ urlValue +' to request the role. It may take up to 75 minutes after AGS approval before you can access the quote.'; 
            String[] toAddresses = new String[] {(!String.isEmpty(aeAction) ? newAEEmail : newFSEEmail)};
            String[] ccAddresses = new String[] {(!String.isEmpty(fseAction) && fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users) ? oldFSEEmail : loggedInUserEmail};
            if(!String.isEmpty(aeAction) && (aeAction == Label.Pricing_EC_AE_BulkUpdate_Action || aeAction == Label.Pricing_AE_Bulk_Insert_Flow_Action_For_Inactive_Users)){
                ccAddresses.add(oldAEEmail);
            }
            String[] bccAddresses = new String[] {Label.Pricing_IQR_Support_Email};
            String body = (!String.isEmpty(fseAction) && ((fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action || fseAction == Label.Pricing_FSE_Bulk_Insert_Flow_Action_For_Inactive_Users))) ? '<b>'+ UserInfo.getFirstName() +' '+ UserInfo.getLastName() + '</b> requested <b>' + newFSEName + '</b> be added to <b>'+ quotesCount + '</b> quotes in the Intel Quote Request (IQR) Tool where <b>'+ oldFSEName  +'</b> was listed as an SDM/FSE. Please refer to the attached file to see the list of quotes and errors, if any.'
                        :'<b>'+ UserInfo.getFirstName() +' '+ UserInfo.getLastName() + '</b> requested you be added to <b>'+ quotesCount + '</b> quotes in the Intel Quote Request (IQR) Tool. Please refer to the attached file to see the list of quotes and errors, if any.<br/> <br/>'+ (!String.isEmpty(aeAction) ?inValidAEuser : '') ;
            att.setFileName('Bulk '+(!String.isEmpty(aeAction) ? aeAction : fseAction)+'_'+string.valueOf(system.now())+'.csv');
            att.setBody(b);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{att});
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setToAddresses(toAddresses);
            mail.setccAddresses(ccAddresses);
            mail.setbccAddresses(bccAddresses);
            mail.setOrgWideEmailAddressId(orgWideEmailAddId);
            mail.setSubject(Label.Pricing_bulk_AE_SDM_Email_Subject);
            mail.setHtmlBody(body);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    
    /**
    * @description Method written to get the quotes list for Account Executive Bulk Update
    * @author Bharath Chandrashekar | 09-29-2022 
    * @param quoteRecsList 
    * @return List<SBQQ__Quote__c> 
    **/
    public List<List<Object>> getAEEmailListForBulkUpdate(List<SBQQ__Quote__c> quoteRecsList){
        List<SBQQ__Quote__c> quotesList = new List<SBQQ__Quote__c>();
        Set<Id> quoteIds = new Set<Id>();
        List<Id> quoteIdsForQTMReplace = new List<Id>();
        User u = !String.isEmpty(aeAction)?[SELECT Id ,Name FROM User WHERE Email =:newAEEmail AND IsActive = true LIMIT 1]:new User();
        List<PermissionSetAssignment> aePermSetAssignment = validPermSetAssignment;
        List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
        List<Pricing_Quote_Team__c> qtmListToBeDeleted = new List<Pricing_Quote_Team__c>();
        List<Pricing_Quote_Team__c> qtmList = !String.isEmpty(aeAction) && !aeAction.contains('End Customer')?
        [SELECT Id, Pricing_Quote_Team_Member_Id__c, Pricing_Quote_Team_Member_Id__r.email, Pricing_Quote_Id__c 
             FROM pricing_quote_team__c WHERE Pricing_Quote_Team_Member_Id__r.email =: UserInfo.getUserEmail() 
             AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender 
             AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_Account_Executive 
             AND Pricing_Quote_Id__c IN: quoteRecsList]:
        !String.isEmpty(aeAction) && aeAction.contains('End Customer') ?
        [SELECT Id, Pricing_Quote_Team_Member_Id__c, Pricing_Quote_Team_Member_Id__r.email, Pricing_Quote_Id__c 
             FROM pricing_quote_team__c WHERE Pricing_Quote_Team_Member_Id__r.email =: oldAEEmail 
             AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender 
             AND Pricing_Role_Nm__c =:Label.Pricing_Quote_Team_Role_Account_Executive 
             AND Pricing_Quote_Id__c IN: quoteRecsList]:
        [SELECT Id, Pricing_Quote_Team_Member_Id__c, Pricing_Quote_Team_Member_Id__r.email, Pricing_Quote_Id__c 
         FROM pricing_quote_team__c WHERE Pricing_Quote_Team_Member_Id__r.email =: UserInfo.getUserEmail() 
         AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender 
         AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_FSE 
         AND Pricing_Quote_Id__c IN: quoteRecsList];
             List<List<Object>> quoteBulkUpsertList = new List<List<Object>>();
        if(quoteRecsList.size() > 0 && (!String.isEmpty(aeAction) || (!String.isEmpty(fseAction) && aePermSetAssignment.size() > 0))){
            for(SBQQ__Quote__c quoteRec: quoteRecsList){
                if((!String.isEmpty(aeAction) && ((!aeAction.contains('End Customer') && quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c == UserInfo.getUserEmail()) || (aeAction.contains('End Customer') && quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c == oldAEEmail))) || (!String.isEmpty(fseAction) && (quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c == UserInfo.getUserEmail() || (fseAction == 'Sales Rep Replace' && quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c == oldFSEEmail) )) ){
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    quote.Id = quoteRec.Id;
                    if(!String.isEmpty(aeAction)){
                        quote.Pricing_Intel_Account_Exec_Email_Txt__c = newAEEmail;
                    }
                    else{
                        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = newFSEEmail;
                    }
                    if(!quoteIds.contains(quoteRec.Id)){
                        quotesList.add(quote);
                        quotesCount++;
                    }
                }
                else if((!String.isEmpty(aeAction) && (!aeAction.contains('End Customer') && quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c != UserInfo.getUserEmail() || (aeAction.contains('End Customer') && quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c != oldAEEmail))) || (!String.isEmpty(fseAction) && quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c != UserInfo.getUserEmail())){
                    if(qtmList.size() > 0 && qtmListToBeDeleted.isEmpty()){
                        qtmListToBeDeleted.addAll(qtmList);
                    }
                    Pricing_Quote_Team__c qt = new Pricing_Quote_Team__c();
                    qt.Pricing_Quote_Team_Member_Id__c = (!String.isEmpty(aeAction) && validPermSetAssignment.size()>0)?aePermSetAssignment[0].Assignee.Id:(!String.isEmpty(aeAction) && validPermSetAssignment.size()==0)?u.Id:aePermSetAssignment[0].Assignee.Id;
                    qt.Pricing_Quote_Id__c = quoteRec.Id;
                    qt.Pricing_Role_Nm__c = !String.isEmpty(aeAction) ? Label.Pricing_Quote_Team_Role_Account_Executive : Label.Pricing_Quote_Team_Role_FSE;
                    if(!quoteIds.contains(quoteRec.Id)){
                        quoteTeamList.add(qt);
                        quoteIdsForQTMReplace.add(quoteRec.Id);
                        quotesCount++;
                    }
                }
                quoteIdToQuoteNumMap.put(quoteRec.Id,quoteRec.Name);
                quoteIdToQuoteRecMap.put(quoteRec.Id,quoteRec);
                quoteIds.add(quoteRec.Id);
            }
            if(qtmListToBeDeleted.size() > 0){
                Database.delete(qtmListToBeDeleted, false);
            }
        }
        quoteBulkUpsertList.add((List<Object>)quotesList);
        quoteBulkUpsertList.add((List<Object>)quoteTeamList);
        quoteBulkUpsertList.add((List<Object>)quoteIdsForQTMReplace);
        return quoteBulkUpsertList;
    }
    
    /**
    * @description Method written to get the quote team list for Account Executive Bulk Insert into Quote Team
    * @author Bharath Chandrashekar | 09-29-2022 
    * @param quoteRecsList 
    * @return List<Pricing_Quote_Team__c> 
    **/
    public List<Pricing_Quote_Team__c> getQuoteTeamListForBulkInsert(List<SBQQ__Quote__c> quoteRecsList){
        List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
        Set<Id> quoteIds = new Set<Id>();
        User u = !String.isEmpty(aeAction)?[SELECT Id ,Name FROM User WHERE Email =:newAEEmail AND IsActive = true LIMIT 1]:new User();
        List<PermissionSetAssignment> aePermSetAssignment = validPermSetAssignment;
        if(quoteRecsList.size() > 0 && (!String.isEmpty(aeAction) || (!String.isEmpty(fseAction) && aePermSetAssignment.size() > 0))){
            for(SBQQ__Quote__c quoteRec: quoteRecsList){
                Pricing_Quote_Team__c qt = new Pricing_Quote_Team__c();
                qt.Pricing_Quote_Team_Member_Id__c = (!String.isEmpty(aeAction) && validPermSetAssignment.size()>0)?aePermSetAssignment[0].Assignee.Id:(!String.isEmpty(aeAction) && validPermSetAssignment.size()==0)?u.Id:aePermSetAssignment[0].Assignee.Id;
                qt.Pricing_Quote_Id__c = quoteRec.Id;
                qt.Pricing_Role_Nm__c = !String.isEmpty(aeAction) ? Label.Pricing_Quote_Team_Role_Account_Executive : Label.Pricing_Quote_Team_Role_FSE;
                if(!quoteIds.contains(quoteRec.Id)){
                    quoteTeamList.add(qt);
                    quotesCount++;
                }
                quoteIdToQuoteNumMap.put(quoteRec.Id,quoteRec.Name);
                quoteIdToQuoteRecMap.put(quoteRec.Id,quoteRec);
                quoteIds.add(quoteRec.Id);
            }
        }
        return quoteTeamList;
    }
    
    /**
    * @description Method to Delete the Old AE Sharing Records
    * @author Bharath Chandrashekar | 12-05-2022 
    * @param quoteIds 
    * @param aeUsrId 
    **/
    public static void deleteShareQuoteAE(Set<Id> quoteIds,Id aeUsrId){
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<SBQQ__Quote__Share> quoteShareList=new List<SBQQ__Quote__Share>();
        List<Pricing_Comments__Share> commentShareList=new List<Pricing_Comments__Share>();
        List<Pricing_Quote_Line_Status_Age__Share> TPTShareList = new List<Pricing_Quote_Line_Status_Age__Share>();
        if(!quoteIds.isEmpty()){
            //Quote share records added to list for deletion.
            for(SBQQ__Quote__Share share : [SELECT Id,ParentId,UserOrGroupId,RowCause FROM SBQQ__Quote__Share WHERE ParentId IN: quoteIds AND UserOrGroupId = : aeUsrId AND RowCause =: Schema.SBQQ__Quote__Share.RowCause.Manual]){
                quoteShareList.add(share);
            }
            //Comment share records added to list for deletion.
            for(Pricing_Comments__Share commentShare : [SELECT Id,ParentId,Parent.Pricing_Quote__c,UserOrGroupId,RowCause FROM Pricing_Comments__Share WHERE Parent.recordtypeid =: commentRecordTypeId AND Parent.Pricing_Quote__c IN: quoteIds AND UserOrGroupId = : aeUsrId AND RowCause =: Schema.SBQQ__Quote__Share.RowCause.Manual]){
                commentShareList.add(commentShare);
            }
            //TPT share records added to list for deletion.
            for(Pricing_Quote_Line_Status_Age__Share TPTShareRec : [SELECT Id, ParentId,Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c,
                                                                    Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.Pricing_Account_Executive_Nm__c,
                                                                    UserOrGroupId, AccessLevel, RowCause FROM Pricing_Quote_Line_Status_Age__Share WHERE 
                                                                    Parent.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c IN: quoteIds
                                                                    AND UserOrGroupId = : aeUsrId AND RowCause =: Schema.Pricing_Quote_Line_Status_Age__Share.RowCause.Manual]){
                                                                        TPTShareList.add(TPTShareRec);
                                                                    }
            if(!quoteShareList.isEmpty()){
                delete quoteShareList;
            }
            if(!commentShareList.isEmpty()){
                delete commentShareList;
            }
            if(!TPTShareList.isEmpty()){
                delete TPTShareList;
            }
        }
    }
    
    //Stores inputs from Flow 
    public class FlowInputs {
        @InvocableVariable public String newAEEmailInput;
        @InvocableVariable public String aeActionInput;
        @InvocableVariable public String newFSEEmailInput;
        @InvocableVariable public String oldFSEEmailInput;
        @InvocableVariable public String fseActionInput;
        @InvocableVariable public String unifiedEndCustomerIdInput;
        @InvocableVariable public String endCustomerCountryInput;
        @InvocableVariable public String oldAEEmailInput;
        @InvocableVariable public String fseOldToReplace;
        @InvocableVariable public String fseNewToReplaceWith;
        @InvocableVariable public String oldAEEmailInputforInactiveUser;
        @InvocableVariable public String newAEEmailInputforInactiveUser;
        @InvocableVariable public String oldFSEEmailInputforInactiveUser;
        @InvocableVariable public String newFSEEmailInputforInactiveUser;
        public FlowInputs(){

        }
    }

    /**
    * @description Method written to replace SDM/FSE Email
    * @author Vrushabh | 12-17-2024
    * @param quoteRecsList 
    * @return List<SBQQ__Quote__c> 
    **/
    public List<List<Object>> getFSESDMReplace(List<SBQQ__Quote__c> quoteRecsList){

        List<SBQQ__Quote__c> quotesListUpdatedFSE = new List<SBQQ__Quote__c>();
        Set<Id> quoteIds = new Set<Id>();
        List<Id> quoteIdsForQTMReplace = new List<Id>();

        List<PermissionSetAssignment> FSEPermSetAssignment = validPermSetAssignment;
        List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
        List<Pricing_Quote_Team__c> qtmListToBeDeleted = new List<Pricing_Quote_Team__c>();
        List<Pricing_Quote_Team__c> qtmList = new List<Pricing_Quote_Team__c>();

        List<List<Object>> quoteBulkUpsertList = new List<List<Object>>();
        if(quoteRecsList.size() > 0 && !String.isEmpty(fseAction) && FSEPermSetAssignment.size() > 0){
            qtmList = [SELECT Id, Pricing_Quote_Team_Member_Id__c, Pricing_Quote_Team_Member_Id__r.email, Pricing_Quote_Id__c 
                        FROM pricing_quote_team__c WHERE Pricing_Quote_Team_Member_Id__r.email =: oldFSEEmail 
                        AND Pricing_Quote_Id__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Program_Code_Tender 
                        AND Pricing_Role_Nm__c =: Label.Pricing_Quote_Team_Role_FSE 
                        AND Pricing_Quote_Id__c IN: quoteRecsList];

            for(SBQQ__Quote__c quoteRec: quoteRecsList){
                if((!String.isEmpty(fseAction) && quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c == oldFSEEmail)){ // check old email
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    quote.Id = quoteRec.Id;
                    quote.Pricing_Intel_Sales_Rep_Email_Txt__c = newFSEEmail; // replace new email
                
                    Pricing_Quote_Team__c qt = new Pricing_Quote_Team__c();
                    qt.Pricing_Quote_Team_Member_Id__c = validPermSetAssignment[0].Assignee.Id; 
                    qt.Pricing_Quote_Id__c = quoteRec.Id;
                    qt.Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_FSE; // Quote Team Replce List
                    if(!quoteIds.contains(quoteRec.Id)){
                        if(!quoteTeamList.contains(qt)){
                            quoteTeamList.add(qt);
                        }
                        quoteIdsForQTMReplace.add(quoteRec.Id);
                        quotesListUpdatedFSE.add(quote);
                        quotesCount++;
                    }
                    //quoteIdToQuoteRecMap.put(quoteRec.Id,quoteRec);
                    quoteIds.add(quoteRec.Id);
                }   
            }
            if(qtmList.size() > 0 && qtmListToBeDeleted.isEmpty()){
                qtmListToBeDeleted.addAll(qtmList);
            }
            if(qtmListToBeDeleted.size() > 0){
                Database.delete(qtmListToBeDeleted, false);
            }
        }
        quoteBulkUpsertList.add((List<Object>)quotesListUpdatedFSE);
        quoteBulkUpsertList.add((List<Object>)quoteTeamList);
        quoteBulkUpsertList.add((List<Object>)quoteIdsForQTMReplace);
        return quoteBulkUpsertList;
    }
}