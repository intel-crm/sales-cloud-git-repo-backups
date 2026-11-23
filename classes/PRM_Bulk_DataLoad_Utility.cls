/******************************************************************************************************************************
Apex Class Name:  PRM_Bulk_DataLoad_Utility
Version     : 1.0 
Created Date: 01 OCT 2021
Function    : Utility Class for Bulk Upload Capability  

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/10/2021           Utility Class for Bulk Upload Capability
****************************************************************************************************************************************/
public class PRM_Bulk_DataLoad_Utility {

    public static String operationUpdate = 'Update';
    public static String operationInsert = 'Insert';
    public static String statusComplete = 'Complete';
    public static String statusApproved = 'Approved';
    public static String statusPendingAction = 'Pending Action';
    public static String strDeactivatedAccount ='DeactivatedAccount';
    public static String strSystemAccount = 'SystemAccount';
    public static String strNoActiveACM = 'NoActiveACM';
    public static String strEmployee = 'Employee';
    public static String strInactiveAcc = 'Inactive Account';
    public static String strNoWebsite = 'No Website';  
    public static String strPartnerInvite = 'Partner Invite';
    public static String strAdminInvite = 'Admin Invite';
    
  /*
   * To check if Contact is already existing for provided emailId and then assigning Update and Insert Operation Accodingly      
   *Adding Contact is already in Pending Action custom validation
   *Adding Contact is already IPA custom validation
   *Adding Incorrect Account Id for existing contact validation
   *Adding default comments to Bulk Record
  */    
    public static void checkContactExistance(List<PRM_Bulk_Data_Upload__c> bulkUploadList, String uniqueBatchId) {
    Map<String, PRM_Bulk_Data_Upload__c> inputMap = new Map<String, PRM_Bulk_Data_Upload__c>();
    //Boolean existingConNoPartnerRole = false;
    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> accntForDefaultRealation = new Set<Id>();
    Boolean hasPartnerAdmin = false;
    Map<Id, PRM_Bulk_Data_Upload__c> primaryContactMap = new Map<Id, PRM_Bulk_Data_Upload__c>();
    List<PRM_Bulk_Data_Upload__c> listIsRetryingObjs = new List<PRM_Bulk_Data_Upload__c>();
    Map<Id, String> mapAdminInviteAccIdsToPartnerRole = new Map<Id, String>();

    populateInputMapAndAdminInviteMap(bulkUploadList, inputMap, listIsRetryingObjs, mapAdminInviteAccIdsToPartnerRole, accntForDefaultRealation, hasPartnerAdmin, primaryContactMap);
    handleRetryingObjects(uniqueBatchId, listIsRetryingObjs);

    handleDefaultRelationshipsAndAdminInvite(mapAdminInviteAccIdsToPartnerRole, hasPartnerAdmin, accntForDefaultRealation, primaryContactMap);

    checkForExistingBulkRecords(inputMap);

    processContacts(inputMap, accountIdSet);
	
	processBulkUploadList(bulkUploadList, uniqueBatchId, accountIdSet, inputMap, mapAdminInviteAccIdsToPartnerRole);
  }

  private static void populateInputMapAndAdminInviteMap(List<PRM_Bulk_Data_Upload__c> bulkUploadList,
                                                      Map<String, PRM_Bulk_Data_Upload__c> inputMap,
                                                      List<PRM_Bulk_Data_Upload__c> listIsRetryingObjs,
                                                      Map<Id, String> mapAdminInviteAccIdsToPartnerRole,Set<Id> accntForDefaultRealation,Boolean hasPartnerAdmin,Map<Id, PRM_Bulk_Data_Upload__c> primaryContactMap) {
    for (PRM_Bulk_Data_Upload__c dataList : bulkUploadList) {
        validateBulkData(dataList,inputMap);

        if (dataList.PRM_isRetrying__c) {
            listIsRetryingObjs.add(dataList);
        }

        if (dataList.PRM_RegistrationType__c == strAdminInvite) {
            handleAdminInviteMap(dataList, mapAdminInviteAccIdsToPartnerRole);
        }
		if(dataList.PRM_RegistrationType__c == strPartnerInvite && String.isNotBlank(dataList.PRM_IPA_Partner_Role__c)){
                dataList.PRM_IPA_Partner_Role__c = null;// We should not accept Partner Role for Partner Invite and give existing Partner role from Account's oldest ACM even if user provides it
        }
          
        handleDefaultRelationships(dataList, accntForDefaultRealation, hasPartnerAdmin, primaryContactMap);
    }
  }
  private static void validateBulkData(PRM_Bulk_Data_Upload__c dataList, Map<String, PRM_Bulk_Data_Upload__c> inputMap) {
    if (String.isBlank(dataList.PRM_ContactEmail__c) || String.isBlank(dataList.PRM_AccountId__c)
            || String.isBlank(dataList.PRM_First_Name__c) || String.isBlank(dataList.PRM_Last_Name__c)) {
        dataList.addError(System.Label.PRM_BulkMissingMandatoryFields);
    } else if (dataList.PRM_RegistrationType__c == strAdminInvite && String.isBlank(dataList.PRM_IPA_Partner_Role__c)) {
        dataList.addError('Partner Role is Mandatory for Admin Invite');
    } else if (!inputMap.containsKey(dataList.PRM_ContactEmail__c)) {
        inputMap.put(dataList.PRM_ContactEmail__c, dataList);
    } else {
        dataList.addError(System.Label.PRM_Bulk_DuplicateEmail);
    }
   }
   private static void handleAdminInviteMap(PRM_Bulk_Data_Upload__c dataList, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    if (!mapAdminInviteAccIdsToPartnerRole.containsKey(dataList.PRM_AccountId__c)) {
        mapAdminInviteAccIdsToPartnerRole.put(dataList.PRM_AccountId__c, dataList.PRM_IPA_Partner_Role__c);
    } else {
        dataList.PRM_IPA_Partner_Role__c = mapAdminInviteAccIdsToPartnerRole.get(dataList.PRM_AccountId__c);
        dataList.PRM_Comments__c = 'Updated Partner Role as Account already given Partner Role in the current transaction';
    }
  }

  private static void handleDefaultRelationships(PRM_Bulk_Data_Upload__c dataList, Set<Id> accntForDefaultRealation, Boolean hasPartnerAdmin, Map<Id, PRM_Bulk_Data_Upload__c> primaryContactMap) {
    if (!hasPartnerAdmin && (dataList.PRM_Partner_Relationship__c == null || !dataList.PRM_Partner_Relationship__c.contains('Partner Admin'))) {
        accntForDefaultRealation.add(dataList.PRM_AccountId__c);
    }

    if (accntForDefaultRealation != null && accntForDefaultRealation.contains(dataList.PRM_AccountId__c) &&
            (dataList.PRM_Partner_Relationship__c != null && dataList.PRM_Partner_Relationship__c.contains('Partner Admin'))) {
        accntForDefaultRealation.remove(dataList.PRM_AccountId__c);
        hasPartnerAdmin = true;
    }

    if (!primaryContactMap.containsKey(dataList.PRM_AccountId__c)) {
        primaryContactMap.put(dataList.PRM_AccountId__c, dataList);
    }
  }
  private static void handleRetryingObjects(String uniqueBatchId, List<PRM_Bulk_Data_Upload__c> listIsRetryingObjs) {
    Map<String, PRM_Bulk_Data_Upload__c> mapCampaignToBulk = new Map<String, PRM_Bulk_Data_Upload__c>();
    List<String> listCampaignId = new List<String>();

    for (PRM_Bulk_Data_Upload__c bulkObj : listIsRetryingObjs) {
        listCampaignId.add(bulkObj.PRM_CampaignId__c);
    }

    populateMapCampaignToBulk(listCampaignId, mapCampaignToBulk);

    updateBatchIds(uniqueBatchId, listIsRetryingObjs, mapCampaignToBulk);
  }
  private static void populateMapCampaignToBulk(List<String> listCampaignId, Map<String, PRM_Bulk_Data_Upload__c> mapCampaignToBulk) {
    for (PRM_Bulk_Data_Upload__c oldRecs : [
        SELECT Id, PRM_CampaignId__c, PRM_BatchID__c
        FROM PRM_Bulk_Data_Upload__c
        WHERE PRM_CampaignId__c in :listCampaignId
        ORDER BY createdDate DESC, PRM_CampaignId__c
    ]) {
        if (!mapCampaignToBulk.containsKey(oldRecs.PRM_CampaignId__c)) {
            mapCampaignToBulk.put(oldRecs.PRM_CampaignId__c, oldRecs);
        }
    }
  }
  private static void updateBatchIds(String uniqueBatchId, List<PRM_Bulk_Data_Upload__c> listIsRetryingObjs, Map<String, PRM_Bulk_Data_Upload__c> mapCampaignToBulk) {
    for (PRM_Bulk_Data_Upload__c bulkRec : listIsRetryingObjs) {
        if (mapCampaignToBulk.containsKey(bulkRec.PRM_CampaignId__c)) {
            bulkRec.PRM_BatchID__c = mapCampaignToBulk.get(bulkRec.PRM_CampaignId__c).PRM_BatchID__c;
        } else {
            bulkRec.PRM_BatchID__c = uniqueBatchId;
        }
    }
  }
  private static void handleDefaultRelationshipsAndAdminInvite(Map<Id, String> mapAdminInviteAccIdsToPartnerRole, Boolean hasPartnerAdmin, Set<Id> accntForDefaultRealation, Map<Id, PRM_Bulk_Data_Upload__c> primaryContactMap) {
    system.debug('here' + accntForDefaultRealation);
    if (accntForDefaultRealation.size() > 0) {
        for (PRM_Account_Contact_Relationship__c pcr : [
            SELECT id, PRM_Account_Id__c
            FROM PRM_Account_Contact_Relationship__c
            WHERE PRM_Account_Id__c in :accntForDefaultRealation AND PRM_InActive_Ind__c = false AND PRM_Status_Nm__c = 'Complete'
        ]) {
            accntForDefaultRealation.remove(pcr.PRM_Account_Id__c);
        }

        if (accntForDefaultRealation.size() > 0) {
            for (Id acntId : accntForDefaultRealation) {
                PRM_Bulk_Data_Upload__c bNew = primaryContactMap.get(acntId);
                bNew.PRM_Partner_Relationship__c = 'Employee;Partner Admin';
            }
        }
    }
  }
  private static void checkForExistingBulkRecords(Map<String, PRM_Bulk_Data_Upload__c> inputMap) {
    for (PRM_Bulk_Data_Upload__c bulkDatas : [
        SELECT PRM_ContactEmail__c, PRM_Status__c
        FROM PRM_Bulk_Data_Upload__c
        WHERE PRM_Status__c = 'New' AND PRM_ContactEmail__c IN :inputMap.keySet()
    ]) {
        if (inputMap.containsKey(bulkDatas.PRM_ContactEmail__c)) {
            inputMap.get(bulkDatas.PRM_ContactEmail__c).addError(System.Label.PRM_BulkRecordExistsError);
            inputMap.remove(bulkDatas.PRM_ContactEmail__c);
        }
        
    }
  }
  private static void processContacts(Map<String, PRM_Bulk_Data_Upload__c> inputMap, Set<Id> accountIdSet) {
    for (Contact con : [
        SELECT Id, Email, AccountId, Core_IPA_PartnerRole__c, Core_Preferred_Language__c, Core_IPA_Contact_Segment__c, Contact_ID__c,
            (SELECT PRM_Status_Nm__c, PRM_Contact_Id__c, PRM_InActive_Ind__c, PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r)
        FROM Contact
        WHERE Email IN :inputMap.keySet()
    ]) {
        PRM_Bulk_Data_Upload__c bulkUploadObject = inputMap.get(con.Email);
        List<PRM_Account_Contact_Relationship__c> contactAcrs = con.Account_Contact_Relationships__r;
        bulkUploadObject.PRM_OperationType__c = operationUpdate;
        bulkUploadObject.PRM_Contact_Id__c = con.Contact_ID__c;
        bulkUploadObject.PRM_Preferred_Language__c = con.Core_Preferred_Language__c;

        List<String> conInputRelationships = new List<String>();

        if(inputmap.containsKey(con.Email) && inputmap.get(con.Email).PRM_RegistrationType__c == strPartnerInvite && con.Core_IPA_PartnerRole__c != null){
               bulkUploadObject.PRM_IPA_Partner_Role__c = con.Core_IPA_PartnerRole__c; 
        }

        handleACRValidation(bulkUploadObject, contactAcrs, conInputRelationships);
		processContactData( bulkUploadObject, con, inputMap, conInputRelationships,contactAcrs, accountIdSet);
		
    }
 }
  private static void handleACRValidation(PRM_Bulk_Data_Upload__c bulkUploadObject, List<PRM_Account_Contact_Relationship__c> contactAcrs, List<String> conInputRelationships) {
    if (bulkUploadObject.PRM_Partner_Relationship__c != null) {
        handleRelationshipSplit(bulkUploadObject.PRM_Partner_Relationship__c, conInputRelationships);
        handleDefaultRelationshipsValidation(bulkUploadObject, contactAcrs, conInputRelationships);
    } else {
        handleDefaultACRValidation(bulkUploadObject, contactAcrs, conInputRelationships);
    }
  }
  private static void handleRelationshipSplit(String relationship, List<String> conInputRelationships) {
    if (relationship.contains(';')) {
        conInputRelationships = relationship.split(';');
    } else {
        conInputRelationships.add(relationship);
    }
  }
  private static void handleDefaultRelationshipsValidation(PRM_Bulk_Data_Upload__c bulkUploadObject, List<PRM_Account_Contact_Relationship__c> contactAcrs, List<String> conInputRelationships) {
    if(!conInputRelationships.contains(strEmployee)){
                    conInputRelationships.add(strEmployee);
    }
 }
  private static void handleDefaultACRValidation(PRM_Bulk_Data_Upload__c bulkUploadObject, List<PRM_Account_Contact_Relationship__c> contactAcrs,List<String> conInputRelationships) {
    for(PRM_Account_Contact_Relationship__c acr: contactAcrs ){
                    conInputRelationships.add(acr.PRM_Relationship_Id__r.Name);
                }
  }
  private static void processContactData(
        PRM_Bulk_Data_Upload__c bulkUploadObject,
        Contact con,
        Map<String, PRM_Bulk_Data_Upload__c> inputMap,
        List<String> conInputRelationships,
        List<PRM_Account_Contact_Relationship__c> contactAcrs,
        Set<Id> accountIdSet) {

    boolean ACRNonIPA = false;
    boolean isPendingAction = false;

    if (conInputRelationships.size() <= contactAcrs.size()) {
        processACRs(con, conInputRelationships, contactAcrs, isPendingAction, ACRNonIPA);
    } else {
        ACRNonIPA = true;
    }

    if (contactAcrs.isEmpty() && !ACRNonIPA) {
        ACRNonIPA = true;
    }

    handleContactValidation(bulkUploadObject, con, ACRNonIPA, isPendingAction, inputMap, accountIdSet);
  }
  private static void processACRs(
        Contact con,
        List<String> conInputRelationships,
        List<PRM_Account_Contact_Relationship__c> contactAcrs,
        boolean isPendingAction, boolean ACRNonIPA) {

    for (PRM_Account_Contact_Relationship__c acr : con.Account_Contact_Relationships__r) {
        if (conInputRelationships.contains(acr.PRM_Relationship_Id__r.Name)) {
            if (acr.PRM_Status_Nm__c == statusPendingAction && !acr.PRM_InActive_Ind__c) {
                isPendingAction = true;
                continue;
            } else if (acr.PRM_InActive_Ind__c) {
                ACRNonIPA = true;
            }
        } else {
            ACRNonIPA = true;
            break;
        }
    }
  }
  private static void handleContactValidation(PRM_Bulk_Data_Upload__c bulkUploadObject, Contact con, boolean ACRNonIPA, boolean isPendingAction, Map<String, PRM_Bulk_Data_Upload__c> inputMap, Set<Id> accountIdSet) {
    if (ACRNonIPA && !isPendingAction) {
        if (bulkUploadObject.PRM_AccountId__c == con.AccountId || inputMap.get(con.Email).PRM_AccountId__c == null) {
            bulkUploadObject.PRM_AccountId__c = con.AccountId;
            accountIdSet.add(con.AccountId);
        } else {
            bulkUploadObject.addError(System.Label.PRM_IncorrectAccountIDError);
        }
    } else if (!ACRNonIPA && !isPendingAction) {
       bulkUploadObject.addError(System.Label.PRM_IPAContactError);
    } else if (!ACRNonIPA && isPendingAction) {
        bulkUploadObject.addError(System.Label.PRM_ContactPendingStatusError);
    } else if (ACRNonIPA && isPendingAction) {
        ACRNonIPA = true;
    }
    boolean blockedcont=  PRM_AdminRegistration.getBlockedAccountContact(bulkUploadObject.PRM_ContactEmail__c,bulkUploadObject.PRM_AccountId__c);
        if(blockedcont){
            bulkUploadObject.addError('contact is blocked');
        }
  }

  private static void processBulkUploadList(List<PRM_Bulk_Data_Upload__c> bulkUploadList, String uniqueBatchId, Set<Id> accountIdSet, Map<String, PRM_Bulk_Data_Upload__c> inputMap, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    for (PRM_Bulk_Data_Upload__c dataList : bulkUploadList) {
        handleBulkUploadList(dataList, uniqueBatchId, accountIdSet);
    }

    if (!accountIdSet.isEmpty() && !inputMap.isEmpty()) {
        checkForActiveACM(accountIdSet, inputMap, mapAdminInviteAccIdsToPartnerRole);
    }
  }
  private static void handleBulkUploadList(PRM_Bulk_Data_Upload__c dataList, String uniqueBatchId,  Set<Id> accountIdSet) {
    if (dataList.PRM_OperationType__c != operationUpdate) {
        dataList.PRM_OperationType__c = operationInsert;
        dataList.PRM_Preferred_Language__c = dataList.PRM_Preferred_Language__c != null ? dataList.PRM_Preferred_Language__c : 'ENG';
        accountIdSet.add(dataList.PRM_AccountId__c);
    }

    String defaultComment = 'Created/Updated through Bulk Data Upload by' + ' ' + UserInfo.getName() + ' ' + 'on' + ' ' + System.now();
    dataList.PRM_Comments__c = dataList.PRM_Comments__c != null ? dataList.PRM_Comments__c + '-\n' + defaultComment : defaultComment;

    if (dataList.PRM_BatchID__c == null || String.isBlank(dataList.PRM_BatchID__c)) {
        dataList.PRM_BatchID__c = uniqueBatchId;
    }

    if (dataList.PRM_Partner_Relationship__c == null || String.isBlank(dataList.PRM_Partner_Relationship__c) || String.isEmpty(dataList.PRM_Partner_Relationship__c)) {
        dataList.PRM_Partner_Relationship__c = strEmployee;
    }
  }
    /*
     * Checking for Deactivated/Inactive ACM Accounts/System Account and throwing Custom validations
     * Assigning oldest partner role of Account to the new Contact
    */
    public static void checkForActiveACM(Set<Id> accountIdSet, Map<String, PRM_Bulk_Data_Upload__c> inputMap, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    Map<Id, List<String>> activeACMMap = new Map<Id, List<String>>();
    Map<Id, String> accountTypes = new Map<Id, String>();
    List<Id> sysaccs = getSystemAccountIds();

    populateAccountData(accountIdSet, activeACMMap, accountTypes, sysaccs);
    processInputData(inputMap, activeACMMap, accountTypes, mapAdminInviteAccIdsToPartnerRole);
   }

    private static List<Id> getSystemAccountIds() {
     List<Id> sysaccs = new List<Id>();
     for (Core_Intel_System_Accounts__mdt listsystemacc : [SELECT AccountId__c FROM Core_Intel_System_Accounts__mdt]) {
        sysaccs.add(listsystemacc.AccountId__c);
    }
    return sysaccs;
  }

    private static void populateAccountData(Set<Id> accountIdSet, Map<Id, List<String>> activeACMMap, Map<Id, String> accountTypes, List<Id> sysaccs) {
    for (Account acc : getAccounts(accountIdSet)) {
        processAccount(acc, sysaccs, accountTypes, activeACMMap);
    }
  }

    private static List<Account> getAccounts(Set<Id> accountIdSet) {
    return [SELECT Id, Core_Account_Record_Type__c, Core_Deactivated__c, Core_User_Defined_Website__c,
        Core_Export_Compliance_Block__c, (SELECT Id, PRM_Partner_Role__c, PRM_Account_Id__c,
            PRM_Status_Nm__c, CreatedDate FROM Channel_Memberships1__r ORDER BY CreatedDate)
        FROM Account WHERE Id IN :accountIdSet];
  }

    private static void processAccount(Account acc, List<Id> sysaccs, Map<Id, String> accountTypes, Map<Id, List<String>> activeACMMap) {
    List<PRM_AccountChannelMembership__c> accountACM = acc.Channel_Memberships1__r;

    if (isInactiveAccount(acc, sysaccs)) {
        accountTypes.put(acc.Id, strDeactivatedAccount);
    } else if (sysaccs.contains(acc.Id)) {
        accountTypes.put(acc.Id, strSystemAccount);
    } else if (String.isBlank(acc.Core_User_Defined_Website__c)) {
        accountTypes.put(acc.Id, strNoWebsite);
    } else {
        processActiveACM(acc, accountACM, accountTypes, activeACMMap);
    }
 }

    private static boolean isInactiveAccount(Account acc, List<Id> sysaccs) {
    return acc.Core_Account_Record_Type__c == strInactiveAcc || acc.Core_Deactivated__c || acc.Core_Export_Compliance_Block__c;
  }

    private static void processActiveACM(Account acc, List<PRM_AccountChannelMembership__c> accountACM, Map<Id, String> accountTypes, Map<Id, List<String>> activeACMMap) {
    boolean activeAcm = false;
    List<String> allActivePartnerRoles = new List<String>();

    for (PRM_AccountChannelMembership__c acms : accountACM) {
        if (acms.PRM_Status_Nm__c == statusApproved) {
            allActivePartnerRoles.add(acms.PRM_Partner_Role__c);
            activeAcm = true;
        }
    }

    if (!activeAcm) {
        accountTypes.put(acc.Id, strNoActiveACM);
    } else {
        activeACMMap.put(acc.Id, allActivePartnerRoles);
    }
  }

    private static void processInputData(Map<String, PRM_Bulk_Data_Upload__c> inputMap, Map<Id, List<String>> activeACMMap, Map<Id, String> accountTypes, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    for (PRM_Bulk_Data_Upload__c inputList : inputMap.values()) {
        processInputList(inputList, activeACMMap, accountTypes, mapAdminInviteAccIdsToPartnerRole);
    }
  }

    private static void processInputList(PRM_Bulk_Data_Upload__c inputList, Map<Id, List<String>> activeACMMap, Map<Id, String> accountTypes, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    updateInputListForActiveACM(inputList, activeACMMap, mapAdminInviteAccIdsToPartnerRole);
    handleAccountTypeValidation(inputList, accountTypes, mapAdminInviteAccIdsToPartnerRole);
  }

    private static void updateInputListForActiveACM(PRM_Bulk_Data_Upload__c inputList, Map<Id, List<String>> activeACMMap, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    if (!activeACMMap.isEmpty() && activeACMMap.containsKey(inputList.PRM_AccountId__c)) {
        if (mapAdminInviteAccIdsToPartnerRole.containsKey(inputList.PRM_AccountId__c)) {
            inputList.PRM_RegistrationType__c = strPartnerInvite;
            inputList.PRM_Comments__c = 'Updating the Registration request type from Admin Invite to Partner Invite as Account already has existing ACTIVE Partner Role';
            inputList.PRM_IPA_Partner_Role__c = activeACMMap.get(inputList.PRM_AccountId__c) != null ? activeACMMap.get(inputList.PRM_AccountId__c)[0] : null;
        }
        if (inputList.PRM_IPA_Partner_Role__c == null) {
            inputList.PRM_IPA_Partner_Role__c = activeACMMap.get(inputList.PRM_AccountId__c) != null ? activeACMMap.get(inputList.PRM_AccountId__c)[0] : null;
        }
    }
  }

    private static void handleAccountTypeValidation(PRM_Bulk_Data_Upload__c inputList, Map<Id, String> accountTypes, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
    if (!accountTypes.isEmpty()) {
        String accountType = accountTypes.get(inputList.PRM_AccountId__c);

        if (strDeactivatedAccount.equals(accountType)) {
            inputList.addError(System.Label.PRM_DeactivatedAccountError);
        } else if (strNoActiveACM.equals(accountType)) {
            handleNoActiveACMValidation(inputList, mapAdminInviteAccIdsToPartnerRole);
        } else if (strSystemAccount.equals(accountType)) {
            inputList.addError(System.Label.PRM_SystemAccountError);
        } else if (strNoWebsite.equals(accountType)) {
            inputList.addError('Website is Mandatory field for ACR Creation');
        }
     }
  }


    private static void handleNoActiveACMValidation(PRM_Bulk_Data_Upload__c inputList, Map<Id, String> mapAdminInviteAccIdsToPartnerRole) {
        system.debug('Method called bulk data load');
    if (inputList.PRM_RegistrationType__c == strPartnerInvite) {
        system.debug('Inside if 1');
        if (!mapAdminInviteAccIdsToPartnerRole.containsKey(inputList.PRM_AccountId__c)) {
            system.debug('Inside if 2');
            inputList.addError(System.Label.PRM_NoActiveACMError);
        } else {
            system.debug('Inside else');
            inputList.PRM_IPA_Partner_Role__c = mapAdminInviteAccIdsToPartnerRole.get(inputList.PRM_AccountId__c);
        }
     }
  }

}