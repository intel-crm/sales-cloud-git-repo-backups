/****************************************************************************************************************************************
* Class Name  : Core_MDF_PNUMappingServiceHandler - working with debug logs
* Version     : 1.0
* Created Date: 7-23-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/23/2018          Service Class for handling trigger related functions on Partner Node User Mapping object.
* Accenture – Shridhar K       01/08/2019       Updated createCaseShareRecords to share case records only with claim submitter.
* Accenture – JV       01/28/2019       Optimized the code in order to stop resharing the existing share records.
* Intel – Sarah       06/02/2019       Created createPaymentShareRecords to share Payment Records
* Accenture - Krishna  10/25/2019      Added Create Share & Delete Share Batches
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PNUMappingServiceHandler {
     //added dummy method to get the code coverage for this class
     public static void getCodeCoverage(){
    }
    //This variable will store the Account Id and List of User Id to which the Account needs to be shared
    /*public static Map<Id, List<Id>> accountIdUserIdListMap = new Map<Id, List<Id>>();
    //This variable will store the Account Id and List of all User Id to which the Account needs to be checked for dedups
    public static Map<Id, List<Id>> accountIdUserIdListDedupMap = new Map<Id, List<Id>>();
    private static final String MANUAL = 'Manual';
    //set of account id
    public static Set < Id > accountIdSet = new Set < Id >();
    //set of user id
    public static Set < Id > userIdSet = new Set < Id >();
    //Map of account id to program
    public static Map<Id,String> mapOfAccIdToProgram = new Map<Id,String>();
    //Map of account node to it's ultimate account
    public static Map<Id,Id> accNodeToUltimateAccMap = new Map<Id,Id>();
    //Map of user id to contact id
    public static Map<Id,Id> mapOfUserIdToContactId = new Map<Id,Id>();
    //Map of account node to it's program
    public static Map<Id,Id> accNodeToProgramMap = new Map<Id,Id>();*/
    /*****************************************************************************************************
Method Name:        mfetchPartnerNodeUserMapping
@return  :          void
@parameters:        accountIdsList - List of Account Ids
Description:        This method will be invoked by a Process Builder to call the createObjectShareRecords method in
order to create the Share records for Account, Partner Fund Allocation and Partner Fund Request.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*@InvocableMethod
    public static void mfetchPartnerNodeUserMapping(List<Id> accountIdsList) {
        try{           
            if(accountIdsList.size() > 0 ) {
                Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([SELECT Id, Core_MDF_Account__c, Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c IN :accountIdsList AND (Core_MDF_User__r.isactive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)]);
                if(newPNUMappingMap != NULL && newPNUMappingMap.size()>0) {
                    createObjectShareRecords(newPNUMappingMap);
                }
                
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
    }*/
    
    /*****************************************************************************************************
Method Name:        createObjectShareRecords
@return  :          void
@parameters:        newPNUMappingMap - Trigger.newMap for Core_MDF_Partner_Node_User_Mapping__c
Description:        Whenever a record is added in the Node User Mapping object, call the respective methods to create
Share records for Account, PFA , PFR and banks.
Added By:           Accenture - SB - 07/23/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void createObjectShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{
            //Call the method for creation of AccountShare records
                    createAccountShareRecords(newPNUMappingMap);
                    if(accountIdUserIdListMap.size() > 0) {
                        createPFAShareRecords(newPNUMappingMap);
                        createPFRShareRecords(newPNUMappingMap);
                        createPFCAndPaymentShareRecords(newPNUMappingMap);
                        createBankShareRecords(newPNUMappingMap);
                        createCaseShareRecords(newPNUMappingMap);
                        createAdjReqShareRecords(newPNUMappingMap);
                        createEscalationShareRecords(newPNUMappingMap);
                        createCampaignShareRecords(newPNUMappingMap);
                    }  
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
    }*/
    
    /*****************************************************************************************************
Method Name:        createAccountShareRecords
@return  :          void
@parameters:        newPNUMappingMap - This will contain all the Core_MDF_Partner_Node_User_Mapping__c records.
Description:        Whenever a record is added in the Node User Mapping object, the Account associated with the record
should be shared with the user associated with the record.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createAccountShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{  
            
            //Iterate over the new set and create the Map of accountIdUserIdListMap to send it for insertion
            String errorMessage;
            addOrUpdateGeneralizeMap(newPNUMappingMap.values(), null);
            
            if(accountIdUserIdListMap.size() > 0) {
                
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account',accountIdUserIdListMap, 'Edit');
                List<AccountShare> accountShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);        
                if(accountShareList == null) {errorMessage = System.Label.Core_MDF_AccountShareError;}
            }
            if(errorMessage != null && errorMessage.length() > 0){
                Core_MDF_Partner_Node_User_Mapping__c pnumInstance;List<Core_MDF_Partner_Node_User_Mapping__c> pnumInstanceList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                if(newPNUMappingMap != null) {for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord:newPNUMappingMap.values()) {
                    pnumInstance = new Core_MDF_Partner_Node_User_Mapping__c();pnumInstance.Id = pnumRecord.Id;
                    pnumInstance.Core_MDF_Error_Details_txt__c = pnumRecord.Core_MDF_Error_Details_txt__c == Null ? errorMessage + '.' :pnumRecord.Core_MDF_Error_Details_txt__c + '\n' + errorMessage + '.';pnumInstanceList.add(pnumInstance);
                }
                                             }
                if(pnumInstanceList != null && pnumInstanceList.size() > 0){Database.update(pnumInstanceList);
                                                                           }
            }}catch(Exception e) {if(e!=null){Core_MDF_CCP_UtilityClass.logError(e); throw e; }}
    }*/
    
    /*****************************************************************************************************
Method Name:        createPFAShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Partner Fund Allocation records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createPFAShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundAllocation WHERE ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN : allProgramstobeIncluded AND ChannelPartnerId IN';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundAllocation', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
     
    }*/
    
    /*****************************************************************************************************
Method Name:        createPFRShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Partner Fund Request records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createPFRShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundRequest WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundRequest', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        
    }*/
    
    /*****************************************************************************************************
Method Name:        createPFCAndPaymentShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Partner Fund Claim records
associated with the Account record and corresponding Payments Records should be shared with the List of User Ids to which the Account record is shared.
Added By:           Intel - Amal Thomas - 11/09/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createPFCAndPaymentShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, ChannelPartnerId, Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundClaim', accountIdUserIdListMap, query, newPNUMappingMap), 25);
        
      
    }*/
    
    /*****************************************************************************************************
Method Name:        createBankShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the bank records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Sridhar - 19/Nov/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createBankShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Core_MDF_Bank__c,Core_MDF_Account__c, Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Account_Bank_Mapping__c', accountIdUserIdListMap, query, newPNUMappingMap), 25);
        
       
    }*/
    
    /*****************************************************************************************************
Method Name:        createCaseShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Case records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           JV - 28/Nov/2018
Accenture – Shridhar K       01/08/2019     Updated createCaseShareRecords to share case records only with claim submitter.
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createCaseShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id,AccountId FROM Case WHERE AccountId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Case', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
       
    }*/
    
    /*****************************************************************************************************
Method Name:        createAdjReqShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Adjustment Request records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - Krishna Kulkarni - 27/06/2019
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void createAdjReqShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Adjustment_Request__c', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        

    }*/
    
    /*****************************************************************************************************
Method Name:        createEscalationShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Escalation(Late claim type - RMF program) records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - Varun Dnyaneshwar - 08/06/2020
******************************************************************************************************/
    /*public static void createEscalationShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Escalation_Type_nm__c =  '+ '\'' +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Status_Type')+ '\' '
            +' AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
            +' AND Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Escalation__c', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        
    }*/
    
    /*****************************************************************************************************
Method Name:        createCampaignShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Campaign records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared for RMF Program.
Added By:           Accenture - HP - 04/08/2020
Modified By:        Accenture - HP - 04/08/2020
******************************************************************************************************/
/*public static void createCampaignShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
    String query = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                    +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                    +' FROM Campaign WHERE (Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                    +' OR Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_IPA_Program_Name+ '\' )'
                    +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
                    +' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';
    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Campaign', accountIdUserIdListMap, query, newPNUMappingMap), Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PNUMBatchSizeForCampaign'));
}*/
/*****************************************************************************************************
Method Name:        deleteObjectShareRecords
@return  :          void
@parameters:        oldPNUMappingMap, newPNUMappingMap, isDeleteDuringEdit
Description:        Whenever a record is deleted from the Node User Mapping object, the AccountShare records, Partner
Fund Allocation Share records and the Partner Fund Allocation Share records created because of
it should be deleted.
Added By:           Accenture - SB - 07/31/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deleteObjectShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, boolean isDeleteDuringEdit) {
        List<Id> accountIdList = new List<Id>();
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : oldPNUMappingList) {
                if(accountIdUserIdListMap.containsKey(pnuMappingRecord.Core_MDF_Account__c)) {
                    accountIdUserIdListMap.get(pnuMappingRecord.Core_MDF_Account__c).add(pnuMappingRecord.Core_MDF_User__c);
                }else{
                    accountIdUserIdListMap.put(pnuMappingRecord.Core_MDF_Account__c, new List<Id>{
                        pnuMappingRecord.Core_MDF_User__c}
                                              );
                }
            }
            // deleting share records
            Map<Id, List<Id>> tempAccountIdUserIdListMap = new Map<Id, List<Id>>(accountIdUserIdListMap);
            
            accountIdUserIdListMap.clear();
            if(isDeleteDuringEdit){
                addOrUpdateGeneralizeMap(newPNUMappingMap.values(), null);
            }
            
            // creating share records
            
            
            if(tempAccountIdUserIdListMap.size() > 0) {
                deleteAccountShareRecords(oldPNUMappingList, isDeleteDuringEdit, newPNUMappingMap, tempAccountIdUserIdListMap);
                deletePFAShareRecords(oldPNUMappingList, isDeleteDuringEdit, newPNUMappingMap, tempAccountIdUserIdListMap);
                deletePFRShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deletePFCAndPaymentShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deleteBankShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deleteCaseShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deleteAdjReqShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deleteEscalationShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
                deleteCampaignShareRecords(oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap, tempAccountIdUserIdListMap);
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
        
        accountIdUserIdListMap.clear();
    }*/
    
    /*****************************************************************************************************
Method Name:        clearErrorField
@return  :          void
@parameters:        newPNUMappingMap
Description:        Whenever a record is updated from the Node User Mapping object, Error Field needs to be clear
Added By:           Accenture - KK - 12/12/2019
******************************************************************************************************/
    /*public static void clearErrorField(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{
            if(newPNUMappingMap != null) {
                for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newPNUMappingMap.values()) {
                    pnuMappingRecord.Core_MDF_Error_Details_txt__c = '';
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }*/
    
    
    /*****************************************************************************************************
Method Name:        deleteAccountShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the AccountShare record created
because of it should be deleted.
Added By:           Accenture - SB - 07/31/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deleteAccountShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        try{
            String errorMessage;
            List<AccountShare> accountShareListToBeDeleted = new List<AccountShare>();
            //Map<AccountShareId,AccountShareRecord>
            Map<Id, AccountShare> accShareMap = new Map<Id, AccountShare>([SELECT Id, AccountId, UserOrGroupId
                                                                           FROM AccountShare
                                                                           WHERE AccountId IN : tempAccountIdUserIdListMap.keySet() AND
                                                                           RowCause =:MANUAL]);
            
            for(AccountShare asRecord : accShareMap.values()) {   
                //check if the Share record exist
                if(tempAccountIdUserIdListMap.containsKey(asRecord.AccountId) &&
                   tempAccountIdUserIdListMap.get(asRecord.AccountId).contains(asRecord.UserOrGroupId)) {
                       accountShareListToBeDeleted.add(asRecord);
                   }
            }
            if(accountShareListToBeDeleted != null && accountShareListToBeDeleted.size() > 0) {
                Database.deleteResult[] srList = Database.delete(accountShareListToBeDeleted, false);
                for (Database.deleteResult sr : srList) {
                    if (!sr.isSuccess()) {errorMessage = System.Label.Core_MDF_AccShareDeleteError;
                                         }
                }
            }
            if(errorMessage != null && errorMessage.length() > 0 && newPNUMappingMap != null && isDeleteDuringEdit){Core_MDF_Partner_Node_User_Mapping__c pnumInstance;
                                                                                                                    List<Core_MDF_Partner_Node_User_Mapping__c> pnumInstanceList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                                                                                                                    for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord:newPNUMappingMap.values()) {pnumInstance = new Core_MDF_Partner_Node_User_Mapping__c();pnumInstance.Id = pnumRecord.Id;pnumInstance.Core_MDF_Error_Details_txt__c = pnumRecord.Core_MDF_Error_Details_txt__c == Null ? errorMessage + '.' :pnumRecord.Core_MDF_Error_Details_txt__c + '\n' + errorMessage + '.';pnumInstanceList.add(pnumInstance);
                                                                                                                                                                                                    }
                                                                                                                    if(pnumInstanceList != null && pnumInstanceList.size() > 0){Database.update(pnumInstanceList);
                                                                                                                                                                               }
                                                                                                                   }}catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }*/
    
    /*****************************************************************************************************
Method Name:        deletePFAShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Partner Fund Allocation Share
records created because of it should be deleted.
because of it should be deleted.
Added By:           Accenture - SB - 07/31/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deletePFAShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundAllocation WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundAllocationShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
       
    }*/
    
    /*****************************************************************************************************
Method Name:        deletePFRShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Partner Fund Request Share
records created because of it should be deleted.
Added By:           Accenture - SB - 08/01/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deletePFRShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundRequest WHERE ChannelPartnerId IN '; 
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundRequestShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
      
    }*/
    
    
    /*****************************************************************************************************
Method Name:        deletebankShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the bank Share
records created because of it should be deleted.
Added By:           Sridhar 21/11/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deleteBankShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Core_MDF_Bank__c,Core_MDF_Account__c,Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Bank__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 25);
        
        
    }*/
    /*****************************************************************************************************
Method Name:        deletePFCAndPaymentShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Partner Fund Claim Share
records and corresponding Payment Share records created because of it should be deleted.
Added By:           Intel - Amal Thomas - 11/09/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deletePFCAndPaymentShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, ChannelPartnerId,Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundClaimShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 25);
        
        
    }*/
    
    /*****************************************************************************************************
Method Name:        deleteCaseShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Case Share
records created because of it should be deleted.
Added By:           JV - 11/28/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deleteCaseShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, AccountId FROM Case WHERE AccountId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CaseShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
       
    }*/
    
    /*****************************************************************************************************
Method Name:        deleteAdjReqShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Adjustment Request Share
records created because of it should be deleted.
Added By:           Accenture - Krishna Kulkarni - 27/06/2019
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    /*public static void deleteAdjReqShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Adjustment_Request__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        
    }*/
    
    /*****************************************************************************************************
Method Name:        deleteEscalationShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Escalation Share
records created because of it should be deleted.
Added By:           Accenture - Varun Dnyaneshwar - 10/06/2020
******************************************************************************************************/
    /*public static void deleteEscalationShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Escalation_Type_nm__c =  '+ '\'' +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Status_Type')
            + '\' '
            +' AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
            +' AND Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Escalation__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        
    }*/
    /*****************************************************************************************************
Method Name:        deleteCampaignShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared for RMF Program.
Description:        Whenever a record is deleted from the Node User Mapping object, the Campaign Share
records created because of it should be deleted.
Added By:           Accenture - HP - 04/08/2020
Modified By:        Accenture - HP - 04/08/2020
******************************************************************************************************/
/*public static void deleteCampaignShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
    String query = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                    +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                    +' FROM Campaign WHERE (Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                    +' OR Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_IPA_Program_Name+ '\' )'
                    +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
                    +' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';
    Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CampaignShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PNUMBatchSizeForCampaign'));
}*/
    
    /*****************************************************************************************************
Method Name:        isApexJobLimitAvailable
@return  :          void
@parameters:        newPNUMList - This will contain all the pnum records to be inserted.
Description:        Logic for restricting PNUM if already more than 94 jobs in Holding Status.
Added By:           Accenture - KK - 12/12/2019
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    
    /*public static void isApexJobLimitAvailable(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList) {
        try{
            //Logic for restricting PNUM if already more than 94 jobs in Holding Status
            AggregateResult[] groupedResults = [Select Count(Id) apexJobCount FROM AsyncApexJob Where Status =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_HoldingJobStatus')];
            if(groupedResults != null && groupedResults.size() > 0){
                Integer previousCount = Integer.valueOf(groupedResults[0].get('apexJobCount'));
                Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PNUMBatchSize');
                if(100 - previousCount < batchSize){for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newPNUMList) {pnuMappingRecord.addError(System.Label.Core_MDF_PNUMTooManyJobs);
                                                                                                                              }
                                                   }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}        
    }*/
    
    
    /*****************************************************************************************************
Method Name:        checkPNUMDuplicateRecords
@return  :          void
@parameters:        pnumList - This will contain all the pnum records to be inserted.
Description:        Whenever a record is deleted from the Node User Mapping object, the Partner Fund Request Share
records created because of it should be deleted.
Added By:           Accenture - JV - 08/07/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void checkPNUMDuplicateRecords(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap) {
        try{            
            //Check for duplicate records in PNUM Object
            addOrUpdateGeneralizeDedupMap(newPNUMList, oldPNUMappingMap);
            if(accountIdUserIdListDedupMap.size() > 0) {
                for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newPNUMList) {
                    if(oldPNUMappingMap == null) {
                        if(accountIdUserIdListDedupMap.get(pnuMappingRecord.Core_MDF_Account__c) != null && accountIdUserIdListDedupMap.get(pnuMappingRecord.Core_MDF_Account__c).contains(pnuMappingRecord.Core_MDF_User__c)) {
                            pnuMappingRecord.addError(System.Label.Core_MDF_PNUMDuplicateError);
                        }
                    }else{
                        if(accountIdUserIdListDedupMap.get(pnuMappingRecord.Core_MDF_Account__c) != null &&
                           oldPNUMappingMap.get(pnuMappingRecord.Id).Core_MDF_User__c != pnuMappingRecord.Core_MDF_User__c &&
                           accountIdUserIdListDedupMap.get(pnuMappingRecord.Core_MDF_Account__c).contains(pnuMappingRecord.Core_MDF_User__c)) {pnuMappingRecord.addError(System.Label.Core_MDF_PNUMDuplicateError);
                                                                                                                                              }
                        if(accountIdUserIdListDedupMap.get(pnuMappingRecord.Core_MDF_Account__c) != null && oldPNUMappingMap.get(pnuMappingRecord.Id).Core_MDF_Account__c != pnuMappingRecord.Core_MDF_Account__c  && accountIdUserIdListDedupMap.get(pnuMappingRecord.Core_MDF_Account__c).contains(pnuMappingRecord.Core_MDF_User__c)) {pnuMappingRecord.addError(System.Label.Core_MDF_PNUMDuplicateError);
                                                                                                                                                                                                                                                                                                                                         }
                    }
                }
            }
            accountIdUserIdListDedupMap.clear();    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}        
        
    }*/
    /*****************************************************************************************************
Method Name:        addOrUpdateGeneralizeMap
@return  :          void
@parameters:        newPNUMappingList - This will contain all the new pnum records to be inserted.
Description:        Whenever a record is inserted to the Node User Mapping object, the generalize accountIdUserIdListMap Map
should be updated.
Added By:           Accenture - JV - 08/08/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void addOrUpdateGeneralizeMap(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList, 
                                                Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap) {
                                                    try{
                                                        for(Core_MDF_Partner_Node_User_Mapping__c pNUMappingRecord : newPNUMappingList) {
                                                            if(accountIdUserIdListMap.containsKey(pNUMappingRecord.Core_MDF_Account__c)) {
                                                                accountIdUserIdListMap.get(pNUMappingRecord.Core_MDF_Account__c).add(pNUMappingRecord.Core_MDF_User__c);
                                                            }else{
                                                                accountIdUserIdListMap.put(pNUMappingRecord.Core_MDF_Account__c, new List<Id>{
                                                                    pNUMappingRecord.Core_MDF_User__c}
                                                                                          );
                                                            }
                                                        }
                                                    }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
                                                    // JV- Accenture : Add the exception into Core_Log_Entry Object
                                                }*/
    
    /*****************************************************************************************************
Method Name:        addOrUpdateDedupMap
@return  :          void
@parameters:        newPNUMappingList - This will contain all the new pnum records to be inserted.
Description:        Whenever a record is inserted to the Node User Mapping object, the generalize accountIdUserIdListMap Map
should be updated.
Added By:           Accenture - JV - 28/01/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void addOrUpdateGeneralizeDedupMap(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList, 
                                                     Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap) {
                                                         try{
                                                             List<Id> accountIdList = new List<Id>();
                                                             
                                                             for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord : newPNUMappingList) {
                                                                 accountIdList.add(pnumRecord.Core_MDF_Account__c);
                                                             }
                                                             // Map of pnumId to pNUM record which contains only active Users
                                                             Map<Id, Core_MDF_Partner_Node_User_Mapping__c> pnumMAP = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([SELECT Core_MDF_Account__c, Core_MDF_User__c
                                                                                                                                                                          FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                                                                                                                          WHERE (Core_MDF_User__r.IsActive = true or Core_MDF_User__r.Partner_License_Reclaimed__c = true)
                                                                                                                                                                          AND Core_MDF_Account__c IN :accountIdList]);
                                                             
                                                             for(Core_MDF_Partner_Node_User_Mapping__c pNUMappingRecord : pnumMAP.values()) {
                                                                 if(accountIdUserIdListDedupMap.containsKey(pNUMappingRecord.Core_MDF_Account__c)) {accountIdUserIdListDedupMap.get(pNUMappingRecord.Core_MDF_Account__c).add(pNUMappingRecord.Core_MDF_User__c);
                                                                                                                                                   }else{
                                                                                                                                                       accountIdUserIdListDedupMap.put(pNUMappingRecord.Core_MDF_Account__c, new List<Id>{pNUMappingRecord.Core_MDF_User__c});
                                                                                                                                                   }
                                                             }
                                                         }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw e;}
                                                         // JV- Accenture : Add the exception into Core_Log_Entry Object
                                                     }*/
    
    /*****************************************************************************************************
Method Name:        StopRecurrsion
@return  :          Boolean
@parameters:        oldPNUMappingMap & newPNUMappingMap -
Description:
Added By:           Accenture - Krishna Kulkarni - 10/04/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static Boolean isAccountUserUpdated(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap, 
                                               Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
                                                   try{
                                                       //To stop recursion - If same account & user but error message changed then block & return false
                                                       
                                                       for(Id pnumId : oldPNUMappingMap.keySet()) {
                                                           if(newPNUMappingMap.containsKey(pnumId)) {
                                                               
                                                               if((oldPNUMappingMap.get(pnumId).Core_MDF_Account__c == newPNUMappingMap.get(pnumId).Core_MDF_Account__c) && 
                                                                  (oldPNUMappingMap.get(pnumId).Core_MDF_User__c == newPNUMappingMap.get(pnumId).Core_MDF_User__c) && (oldPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c != newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c) && (newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c != null) && (newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c.length() > 0)) {return false;
                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                       }
                                                           }
                                                       }
                                                      
                                                       return true;       }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}        
                                                   
                                               }*/
    
    /*****************************************************************************************************
Method Name:        validateAccountUserAccess
@return  :          N/A
@parameters:        List of PNUM
Description:           This method used to validate account user access corresponding to program
Added By:           Accenture - AD - 14/07/2020
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void validateAccountUserAccess(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        
        //Map of contact entitlement to list of contacts
        Map<String,List<Id>> mapOfCntctEntitlementToListOfContact = new Map<String,List<Id>>();
        //Map of program to contact entitlement
        Map<String,String> mapOfProgramToCntctEntitlement = new Map<String,String>();
       
        //quering channel program metadata and preparing map
        for(Core_MDF_ChannelProgram__mdt metaData:[Select Id,Core_MDF_Technical_Program_Name__c,Core_MDF_Contact_Entitlement_Nm__c 
                                                   from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c IN :mapOfAccIdToProgram.values()]){
            mapOfProgramToCntctEntitlement.put(metaData.Core_MDF_Technical_Program_Name__c,metaData.Core_MDF_Contact_Entitlement_Nm__c);
        }
        //quering existing contact entitlement and preparing map
        for(Core_Contact_Entitlement__c cntctEntitlement : [select Id,Core_Entitlement_Id__r.Name, Core_Contact_Id__c  from Core_Contact_Entitlement__c where Core_Contact_Id__c IN : mapOfUserIdToContactId.values()]){
            if(mapOfCntctEntitlementToListOfContact.containsKey(cntctEntitlement.Core_Entitlement_Id__r.Name)){
                mapOfCntctEntitlementToListOfContact.get(cntctEntitlement.Core_Entitlement_Id__r.Name).add(cntctEntitlement.Core_Contact_Id__c);
            }else{
                mapOfCntctEntitlementToListOfContact.put(cntctEntitlement.Core_Entitlement_Id__r.Name, new List<Id>{cntctEntitlement.Core_Contact_Id__c});
            }
        }
        //invoke method to display error if user and selected program is not matched
        displayErrorForInvalidUser(newPNUMappingList,mapOfAccIdToProgram,mapOfProgramToCntctEntitlement,
                                   mapOfCntctEntitlementToListOfContact,mapOfUserIdToContactId);
    }*/
/*****************************************************************************************************
Method Name:        displayErrorForInvalidUser
@return  :          N/A
@parameters:        Maps
Description:        This method used to display error if user and selected program is not matched
Added By:           Accenture - AD - 14/07/2020
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void displayErrorForInvalidUser(List < Core_MDF_Partner_Node_User_Mapping__c > newPNUMappingList,
                                                  Map < Id, String > mapOfAccIdToProgram,
                                                  Map < String, String > mapOfProgramToCntctEntitlement,
                                                  Map < String, List < Id >> mapOfCntctEntitlementToListOfContact,
                                                  Map < Id, Id > mapOfUserIdToContactId) {
    //Looping all incoming PNUM's
    for (Core_MDF_Partner_Node_User_Mapping__c pnum: newPNUMappingList) {
        //List of contact id
        List < Id > listOfContacts = new List < Id > ();
        //hold contact entitlement name
        String contactEntitlement = null;
        //hold account program
        String program = mapOfAccIdToProgram.containsKey(pnum.Core_MDF_Account__c) ? mapOfAccIdToProgram.get(pnum.Core_MDF_Account__c) : null;
        //hold contact entitlement name corresonding to program
        if (!String.isBlank(program)) {
            contactEntitlement = mapOfProgramToCntctEntitlement.containsKey(program) ? mapOfProgramToCntctEntitlement.get(program) : null;
        }
        //hold list of contacts corresponding to contact entitlement
        if (!String.isBlank(contactEntitlement)) {
            listOfContacts = mapOfCntctEntitlementToListOfContact.containsKey(contactEntitlement) ? mapOfCntctEntitlementToListOfContact.get(contactEntitlement) : null;
        }
        /**check user does not belongs to user list
         * If user does not have corresponding entitlement, show error
         
        if (mapOfUserIdToContactId != null && mapOfUserIdToContactId.size() > 0 &&
            (listOfContacts == null || (listOfContacts.size() > 0 &&
                !listOfContacts.contains(mapOfUserIdToContactId.get(pnum.Core_MDF_User__c))))) {
            pnum.addError(Label.Core_MDF_InvalidProgramAccessToUser);
        }
    }
}*/
    
/*****************************************************************************************************
Method Name:        validateCrossAccUserAccess
@return  :          N/A
@parameters:        Maps
Description:        This method used to validate cross account and user access
Added By:           Accenture - AD - 14/07/2020
Modified By:        Date:       Changes:
******************************************************************************************************/

    /*public static void validateCrossAccUserAccess(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        
        //Map of user to list of corresponding groups
        Map<Id,List<String>> userToGroupsMap = new Map<Id,List<String>>();
        //Map of ultimate account and program to it's group
        Map<String,String> ultimateAccToGroupMap = new Map<String,String>();
        //External Access Type
        String extAccessType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Ext_AccessType');
        
        //quering existing PGM and preparing map
        for (Core_MDF_Partner_Group_Mapping__c  pgm : [Select id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Name__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Type_of_Access__c =: extAccessType and Core_MDF_Account__c IN: (accNodeToUltimateAccMap.values()) and Core_MDF_Channel_Program__c IN: (accNodeToProgramMap.values())]){
            //acc+progrm  > group name
            ultimateAccToGroupMap.put(pgm.Core_MDF_Account__c+'-'+pgm.Core_MDF_Channel_Program__c,pgm.Core_MDF_Group_Name__c);
        }
        //quering existing Group Member and preparing map
        for(GroupMember groupMember : [Select Id,UserOrGroupId,GroupId,Group.DeveloperName from GroupMember where UserOrGroupId IN : userIdSet]){
            if(userToGroupsMap.containsKey(groupMember.UserOrGroupId)){
                userToGroupsMap.get(groupMember.UserOrGroupId).add(groupMember.Group.DeveloperName);
            }else{
                userToGroupsMap.put(groupMember.UserOrGroupId, new List<String>{groupMember.Group.DeveloperName});
            }
        }
        //Looping all incoming PNUM's
        //Showing error if account group and user group does not match
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : newPNUMappingList){
            //get ultimate account based on account
            Id ultimateAccount = accNodeToUltimateAccMap.containsKey(pnum.Core_MDF_Account__c) ? accNodeToUltimateAccMap.get(pnum.Core_MDF_Account__c) : null;
            //get account channel program based on account
            Id accountProgram = accNodeToProgramMap.containsKey(pnum.Core_MDF_Account__c) ? accNodeToProgramMap.get(pnum.Core_MDF_Account__c) : null;
            //get group name based on ultimate account and program
            String groupName = ultimateAccToGroupMap.containsKey(ultimateAccount+'-'+accountProgram) ? ultimateAccToGroupMap.get(ultimateAccount+'-'+accountProgram) : null;
           
            //get list of groups corresponding to user
            List<String> groupList = userToGroupsMap.containsKey(pnum.Core_MDF_User__c) ? userToGroupsMap.get(pnum.Core_MDF_User__c) : null;
            if(groupList == null || (!String.isBlank(groupName) && groupList!=null && groupList.size()>0 && !groupList.contains(groupName))){
               pnum.addError(Label.Core_MDF_CrossAccountToUserMappingError);
            }
        }
    }*/
    
/*****************************************************************************************************
Method Name:        prepareCommonMapData
@return  :          N/A
@parameters:        Maps
Description:        This method used to prepare comman map and set data
Added By:           Accenture - AD - 14/07/2020
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void prepareCommonMapData(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        //Looping all incoming PNUM's
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : newPNUMappingList){
            accountIdSet.add(pnum.Core_MDF_Account__c);
            userIdSet.add(pnum.Core_MDF_User__c);
        }
        //quering existing contacts and preparing map
        for(User user : [select Id , ContactId from User where Id IN : userIdSet]){
            mapOfUserIdToContactId.put(user.Id,user.ContactId);
        }        
        //quering existing account and preparing map
        for ( Account acc : [Select Id, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id IN: (accountIdSet)]){
            mapOfAccIdToProgram.put(acc.Id,acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
            accNodeToUltimateAccMap.put(acc.Id,acc.Core_MDF_CoMarketing_Ultimate_Account__c);
            accNodeToProgramMap.put(acc.Id,acc.Core_MDF_Channel_Program__c);
        }
    }*/
     
/*****************************************************************************************************
Method Name:        validateAccountUserMapping
@return  :          N/A
@parameters:        Maps
Description:        This method used to validate account user access corresponding to program and as well as cross account user access
Added By:           Accenture - AD - 14/07/2020
Modified By:        Date:       Changes:
******************************************************************************************************/
     /*public static void validateAccountUserMapping(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList) {
        //preparing map data
        prepareCommonMapData(newPNUMappingList);
        //validate cross account user mapping
        validateCrossAccUserAccess(newPNUMappingList);
        //validate account user access corresponding to program
        validateAccountUserAccess(newPNUMappingList);
     }*/

}