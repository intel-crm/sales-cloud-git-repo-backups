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
    //This variable will store the Account Id and List of User Id to which the Account needs to be shared
    public static Map<Id, List<Id>> accountIdUserIdListMap = new Map<Id, List<Id>>();
    //This variable will store the Account Id and List of all User Id to which the Account needs to be checked for dedups
    public static Map<Id, List<Id>> accountIdUserIdListDedupMap = new Map<Id, List<Id>>();
    private static final String MANUAL = 'Manual';
    /*****************************************************************************************************
Method Name:        mfetchPartnerNodeUserMapping
@return  :          void
@parameters:        accountIdsList - List of Account Ids
Description:        This method will be invoked by a Process Builder to call the createObjectShareRecords method in
order to create the Share records for Account, Partner Fund Allocation and Partner Fund Request.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    @InvocableMethod
    public static void mfetchPartnerNodeUserMapping(List<Id> accountIdsList) {
        try{           
            if(accountIdsList.size() > 0 ) {
                Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([SELECT Id, Core_MDF_Account__c, Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c IN :accountIdsList AND Core_MDF_User__r.isactive = TRUE]);
                if(newPNUMappingMap != NULL && newPNUMappingMap.size()>0) {
                    createObjectShareRecords(newPNUMappingMap);
                }
                
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        // JV- Accenture : Add the exception into Core_Log_Entry Object
    }
    
    /*****************************************************************************************************
Method Name:        createObjectShareRecords
@return  :          void
@parameters:        newPNUMappingMap - Trigger.newMap for Core_MDF_Partner_Node_User_Mapping__c
Description:        Whenever a record is added in the Node User Mapping object, call the respective methods to create
Share records for Account, PFA , PFR and banks.
Added By:           Accenture - SB - 07/23/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void createObjectShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
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
    }
    
    /*****************************************************************************************************
Method Name:        createAccountShareRecords
@return  :          void
@parameters:        newPNUMappingMap - This will contain all the Core_MDF_Partner_Node_User_Mapping__c records.
Description:        Whenever a record is added in the Node User Mapping object, the Account associated with the record
should be shared with the user associated with the record.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    public static void createAccountShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{  
            
            //Iterate over the new set and create the Map of accountIdUserIdListMap to send it for insertion
            String errorMessage;
            addOrUpdateGeneralizeMap(newPNUMappingMap.values(), null);
            system.debug('accountIdUserIdListMap in createAccountShareRecords::'+accountIdUserIdListMap);
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
    }
    
    /*****************************************************************************************************
Method Name:        createPFAShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Partner Fund Allocation records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    public static void createPFAShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
    String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundAllocation WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundAllocation', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        system.debug('PartnerFundAllocation - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        createPFRShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Partner Fund Request records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - SB - 07/29/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    public static void createPFRShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundRequest WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundRequest', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        system.debug('PartnerFundRequest - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        createPFCAndPaymentShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Partner Fund Claim records
associated with the Account record and corresponding Payments Records should be shared with the List of User Ids to which the Account record is shared.
Added By:           Intel - Amal Thomas - 11/09/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    public static void createPFCAndPaymentShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, ChannelPartnerId, Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundClaim', accountIdUserIdListMap, query, newPNUMappingMap), 25);
        
        system.debug('PartnerFundClaim - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        createBankShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the bank records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Sridhar - 19/Nov/2018
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    public static void createBankShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Core_MDF_Bank__c,Core_MDF_Account__c, Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Account_Bank_Mapping__c', accountIdUserIdListMap, query, newPNUMappingMap), 25);
        
        system.debug('Core_MDF_Account_Bank_Mapping__c - batchInstanceId::'+batchInstanceId);
    }
    
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
    public static void createCaseShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id,AccountId FROM Case WHERE AccountId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Case', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        system.debug('Case - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        createAdjReqShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Adjustment Request records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - Krishna Kulkarni - 27/06/2019
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    public static void createAdjReqShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Adjustment_Request__c', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        system.debug('Core_MDF_Adjustment_Request__c - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        createEscalationShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Escalation(Late claim type - RMF program) records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared.
Added By:           Accenture - Varun Dnyaneshwar - 08/06/2020
******************************************************************************************************/
    public static void createEscalationShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Escalation_Type_nm__c =  '+ '\'' +Label.Core_MDF_Escalation_Status_Type+ '\' '
            +' AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
            +' AND Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Escalation__c', accountIdUserIdListMap, query, newPNUMappingMap), 50);
        
        system.debug('Core_MDF_Escalation__c - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        createCampaignShareRecords
@return  :          void
@parameters:        None
Description:        Whenever a record is added in the Node User Mapping object, the Campaign records
associated with the Account record should be shared with the List of User Ids to which the Account record is shared for RMF Program.
Added By:           Accenture - HP - 04/08/2020
Modified By:        Accenture - HP - 04/08/2020
******************************************************************************************************/
public static void createCampaignShareRecords(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
    String query = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                    +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                    +' FROM Campaign WHERE Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                    +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
        			+' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';
    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Campaign', accountIdUserIdListMap, query, newPNUMappingMap), Integer.valueOf(Label.Core_MDF_PNUMBatchSizeForCampaign));
}
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
    public static void deleteObjectShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, boolean isDeleteDuringEdit) {
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
            system.debug('accountIdUserIdListMap in deleteObjectShareRecords::'+accountIdUserIdListMap);
            
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
    }
    
    /*****************************************************************************************************
Method Name:        clearErrorField
@return  :          void
@parameters:        newPNUMappingMap
Description:        Whenever a record is updated from the Node User Mapping object, Error Field needs to be clear
Added By:           Accenture - KK - 12/12/2019
******************************************************************************************************/
    public static void clearErrorField(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        try{
            if(newPNUMappingMap != null) {
                for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newPNUMappingMap.values()) {
                    pnuMappingRecord.Core_MDF_Error_Details_txt__c = '';
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }
    
    
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
    public static void deleteAccountShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        try{
            String errorMessage;
            List<AccountShare> accountShareListToBeDeleted = new List<AccountShare>();
            //Map<AccountShareId,AccountShareRecord>
            Map<Id, AccountShare> accShareMap = new Map<Id, AccountShare>([SELECT Id, AccountId, UserOrGroupId
                                                                           FROM AccountShare
                                                                           WHERE AccountId IN : tempAccountIdUserIdListMap.keySet() AND
                                                                           RowCause =:MANUAL]);
            system.debug('accShareMap::'+accShareMap);
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
    }
    
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
    public static void deletePFAShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundAllocation WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundAllocationShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        system.debug('PartnerFundAllocationShare - batchInstanceId::'+batchInstanceId);
    }
    
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
    public static void deletePFRShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, ChannelPartnerId FROM PartnerFundRequest WHERE ChannelPartnerId IN '; 
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundRequestShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        system.debug('PartnerFundRequestShare - batchInstanceId::'+batchInstanceId);
    }
    
    
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
    public static void deleteBankShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Core_MDF_Bank__c,Core_MDF_Account__c,Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Bank__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 25);
        
        system.debug('Core_MDF_Bank__Share - batchInstanceId::'+batchInstanceId);
    }
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
    public static void deletePFCAndPaymentShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, ChannelPartnerId,Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('PartnerFundClaimShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 25);
        
        system.debug('PartnerFundClaimShare - batchInstanceId::'+batchInstanceId);
    }
    
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
    public static void deleteCaseShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, AccountId FROM Case WHERE AccountId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CaseShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        system.debug('CaseShare - batchInstanceId::'+batchInstanceId);
    }
    
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
    public static void deleteAdjReqShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Adjustment_Request__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        system.debug('Core_MDF_Adjustment_Request__Share - batchInstanceId::'+batchInstanceId);
    }
    
    /*****************************************************************************************************
Method Name:        deleteEscalationShareRecords
@return  :          void
@parameters:        accountIdUserIdListMap - This will contain all the Id of the accounts and the List of
User Ids to which the Account record is shared.
Description:        Whenever a record is deleted from the Node User Mapping object, the Escalation Share
records created because of it should be deleted.
Added By:           Accenture - Varun Dnyaneshwar - 10/06/2020
******************************************************************************************************/
    public static void deleteEscalationShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
        
        String query = 'SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,'
            +' Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId'
            +' FROM Core_MDF_Escalation__c WHERE Core_MDF_Escalation_Type_nm__c =  '+ '\'' +Label.Core_MDF_Escalation_Status_Type+ '\' '
            +' AND Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
            +' AND Core_MDF_Co_Marketing_Activity_id__c != NULL AND Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND '
            +' Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN ';
        
        Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('Core_MDF_Escalation__Share', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), 50);
        
        system.debug('Core_MDF_Escalation__Share - batchInstanceId::'+batchInstanceId);
    }
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
public static void deleteCampaignShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> tempAccountIdUserIdListMap) {
    String query = 'SELECT Id, Core_MDF_Program__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c,'
                    +' Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
                    +' FROM Campaign WHERE Core_MDF_Program__c = '+ '\'' +Label.Core_MDF_Retail_Channel_Program_Name+ '\' '
                    +' AND (Core_MDF_Account__c IN : setOfAccounts OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c IN : setOfAccounts'
        			+' OR Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN ';
    Id batchInstanceId = Database.executeBatch(new Core_MDF_DeleteBatchShareRecords('CampaignShare', tempAccountIdUserIdListMap, query, oldPNUMappingList, isDeleteDuringEdit,newPNUMappingMap,accountIdUserIdListMap), Integer.valueOf(Label.Core_MDF_PNUMBatchSizeForCampaign));
}
    
    /*****************************************************************************************************
Method Name:        isApexJobLimitAvailable
@return  :          void
@parameters:        newPNUMList - This will contain all the pnum records to be inserted.
Description:        Logic for restricting PNUM if already more than 94 jobs in Holding Status.
Added By:           Accenture - KK - 12/12/2019
Modified By:        Accenture - Krishna Kulkarni - 12/13/2019
******************************************************************************************************/
    
    public static void isApexJobLimitAvailable(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList) {
        try{
            //Logic for restricting PNUM if already more than 94 jobs in Holding Status
            AggregateResult[] groupedResults = [Select Count(Id) apexJobCount FROM AsyncApexJob Where Status =: Label.Core_MDF_HoldingJobStatus];
            if(groupedResults != null && groupedResults.size() > 0){
                Integer previousCount = Integer.valueOf(groupedResults[0].get('apexJobCount'));
                Integer batchSize = Integer.valueOf(System.Label.Core_MDF_PNUMBatchSize);
                if(100 - previousCount < batchSize){for(Core_MDF_Partner_Node_User_Mapping__c pnuMappingRecord : newPNUMList) {pnuMappingRecord.addError(System.Label.Core_MDF_PNUMTooManyJobs);
                                                                                                                              }
                                                   }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}        
    }
    
    
    /*****************************************************************************************************
Method Name:        checkPNUMDuplicateRecords
@return  :          void
@parameters:        pnumList - This will contain all the pnum records to be inserted.
Description:        Whenever a record is deleted from the Node User Mapping object, the Partner Fund Request Share
records created because of it should be deleted.
Added By:           Accenture - JV - 08/07/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void checkPNUMDuplicateRecords(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMList, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap) {
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
        
    }
    /*****************************************************************************************************
Method Name:        addOrUpdateGeneralizeMap
@return  :          void
@parameters:        newPNUMappingList - This will contain all the new pnum records to be inserted.
Description:        Whenever a record is inserted to the Node User Mapping object, the generalize accountIdUserIdListMap Map
should be updated.
Added By:           Accenture - JV - 08/08/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void addOrUpdateGeneralizeMap(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList, 
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
                                                }
    
    /*****************************************************************************************************
Method Name:        addOrUpdateDedupMap
@return  :          void
@parameters:        newPNUMappingList - This will contain all the new pnum records to be inserted.
Description:        Whenever a record is inserted to the Node User Mapping object, the generalize accountIdUserIdListMap Map
should be updated.
Added By:           Accenture - JV - 28/01/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void addOrUpdateGeneralizeDedupMap(List<Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingList, 
                                                     Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap) {
                                                         try{
                                                             List<Id> accountIdList = new List<Id>();
                                                             System.debug('accountIdUserIdListDedupMap' + accountIdUserIdListDedupMap.values());
                                                             for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord : newPNUMappingList) {
                                                                 accountIdList.add(pnumRecord.Core_MDF_Account__c);
                                                             }
                                                             // Map of pnumId to pNUM record which contains only active Users
                                                             Map<Id, Core_MDF_Partner_Node_User_Mapping__c> pnumMAP = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([SELECT Core_MDF_Account__c, Core_MDF_User__c
                                                                                                                                                                          FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                                                                                                                          WHERE Core_MDF_User__r.IsActive = true
                                                                                                                                                                          AND Core_MDF_Account__c IN :accountIdList]);
                                                             
                                                             for(Core_MDF_Partner_Node_User_Mapping__c pNUMappingRecord : pnumMAP.values()) {
                                                                 if(accountIdUserIdListDedupMap.containsKey(pNUMappingRecord.Core_MDF_Account__c)) {accountIdUserIdListDedupMap.get(pNUMappingRecord.Core_MDF_Account__c).add(pNUMappingRecord.Core_MDF_User__c);
                                                                                                                                                   }else{
                                                                                                                                                       accountIdUserIdListDedupMap.put(pNUMappingRecord.Core_MDF_Account__c, new List<Id>{pNUMappingRecord.Core_MDF_User__c});
                                                                                                                                                   }
                                                             }
                                                         }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw e;}
                                                         // JV- Accenture : Add the exception into Core_Log_Entry Object
                                                     }
    
    /*****************************************************************************************************
Method Name:        StopRecurrsion
@return  :          Boolean
@parameters:        oldPNUMappingMap & newPNUMappingMap -
Description:
Added By:           Accenture - Krishna Kulkarni - 10/04/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Boolean isAccountUserUpdated(Map<Id, Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingMap, 
                                               Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
                                                   try{
                                                       //To stop recursion - If same account & user but error message changed then block & return false
                                                       
                                                       for(Id pnumId : oldPNUMappingMap.keySet()) {
                                                           if(newPNUMappingMap.containsKey(pnumId)) {
                                                               
                                                               if((oldPNUMappingMap.get(pnumId).Core_MDF_Account__c == newPNUMappingMap.get(pnumId).Core_MDF_Account__c) && 
                                                                  (oldPNUMappingMap.get(pnumId).Core_MDF_User__c == newPNUMappingMap.get(pnumId).Core_MDF_User__c) && (oldPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c != newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c) && (newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c != null) && (newPNUMappingMap.get(pnumId).Core_MDF_Error_Details_txt__c.length() > 0)) {return false;
                                                                                                                                                                                                                                                                                                                                                                                                                                                        //system.debug('Returning false::');
                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                       }
                                                           }
                                                       }
                                                       system.debug('Returning true::');
                                                       return true;       }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}        
                                                   
                                               }
}