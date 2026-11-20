/**************************************************************************************
Apex Class Name: UCD_ACM_MoveContactWithCases_Cont
    Test Class : UCD_ACM_MoveContactWithCases_ContTest
    Version     : 2.0
    Created Date: Dec 2024
    Created by : Sandesh H
    Description : For moving the contact from one account to another account along with the PRC,Subscriptions,cases and entitlements
     *************************************************************************************/
public without sharing class UCD_ACM_MoveContactWithCases_Cont {
    
    private static final Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
    public static Boolean userAuthorized;
    public static boolean hasAccessToAcctSelection;
    private static final String SUCCESS = 'Success';
    private static final String PENDING = 'Pending';
    private static final String UPDATE_REASON_CHANGE_ACCOUNT = 'Change Account';
    public static  final String ipsAssetRecTypeId = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
    public static boolean checkRecursion = false;
    
    
    @AuraEnabled(cacheable=true)
    public static boolean checkUserAccess(){
        userAuthorized = false;
        Map<String, Core_Move_Contact_Authorized_Profiles__c> lCSOpenCases = Core_Move_Contact_Authorized_Profiles__c.getAll();
        for(String s : lCSOpenCases.keySet() ){
            if(currLoggedInUserProfile.Name.equalsIgnoreCase(s.trim())){
                userAuthorized = true;
                break;
            }
        }
        return userAuthorized;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesDetails(Id contactId){
        List<Case> casesResult = new List<Case>();
        try{
            if(Case.SObjectType.getDescribe().isAccessible()){
                casesResult = [Select id,Product.name,caseNumber,status,ContactId,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,
                      Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c,Asset.Name,Account.Name,
                      Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,AssetId,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, 
                      Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name 
                      FROM Case Where contactId =: contactId AND RecordType.Name != 'CEP Case' ];
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','getCasesDetails','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        return casesResult;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Project_Member__c> getIPSProjects(Id contactId){
        List<Core_IPS_Project_Member__c> ipsProjectresult = new List<Core_IPS_Project_Member__c>();
        try{
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                ipsProjectresult =  [Select Core_IPS_Project__r.Name,  Core_IPS_Contact_Account__c, Core_IPS_Provisioning_Date__c , Core_Selective_Member__c, Core_Status__c, Core_User__c,Core_User__r.Name
                           FROM Core_IPS_Project_Member__c where Core_IPS_Contact__c  =: contactId];
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','getIPSProjects','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        return ipsProjectresult;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PRM_Account_Contact_Relationship__c> getAccountContactRelationship(Id contactId){
        List<PRM_Account_Contact_Relationship__c> resultPCR = new List<PRM_Account_Contact_Relationship__c>();
        try{
            if(PRM_Account_Contact_Relationship__c.SObjectType.getDescribe().isAccessible()){
                resultPCR = [Select id, PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__c,PRM_Partner_Role_UI__c,PRM_Start_Date_Dt__c, PRM_End_Date_Dt__c,
            PRM_AGS_Identity_Creation_Fail__c,PRM_CampaignId__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Source_Agent__c,PRM_Initiated_By__c,//PRM_isACRChanged__c
            PRM_Record_Link__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c =: contactId];
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','getAccountContactRelationship','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        return resultPCR;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PRM_ContactSubscriptionAssociation__c> getSubscribtions(Id contactId){
        List<PRM_ContactSubscriptionAssociation__c> subResult = new List<PRM_ContactSubscriptionAssociation__c>();
        try{
            if(PRM_ContactSubscriptionAssociation__c.SObjectType.getDescribe().isAccessible()){
                subResult = [Select id, Name,PRM_Contact_Id__c,PRM_Contact_Id__r.Name,PRM_Partner_Subscription_Id__c,PRM_Partner_Subscription_Id__r.Name,CreatedDate,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,LastModifiedDate,
            PRM_Record_Link__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c  =: contactId];
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','getSubscribtions','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        return subResult;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Core_Contact_Entitlement__c> getEntitlementDetails(Id recordId){
        List <Core_Contact_Entitlement__c> entitlementResult = new List <Core_Contact_Entitlement__c>();
        try{
            if(Core_Contact_Entitlement__c.SObjectType.getDescribe().isAccessible()){
                entitlementResult =  [Select Id, Name,Core_Contact_Id__r.Name,Core_Entitlement_Id__r.Name,Core_Entitlement_Type__c,Core_Selected__c 
        from Core_Contact_Entitlement__c where Core_Contact_Id__c =: recordId AND Core_Entitlement_Id__r.Core_IsActive__c = true];
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','getEntitlementDetails','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        return entitlementResult;
    }
    
    @AuraEnabled
    public static List<Contact> getAccRelatedContacts(Id contactId, Id accountId) {
        List <Contact> result = new List <Contact>();
        try{
            if(Contact.SObjectType.getDescribe().isAccessible()){
                result = [SELECT Id, Name FROM Contact WHERE Id !=: contactId and AccountId =: accountId and Core_Login_Status__c = 'Active' and Core_Enterprise_Id__c != NULL LIMIt 49999]; //Ganesh Changes
            }
            
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','getEntitlementDetails','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
        }
        return result;
    }
    
    @AuraEnabled
    public static String changeAccount(List<Case> casewithoutProj, Id accountId, Id contactId, Boolean keepEntitlements,Boolean moveCase, Id caseMoveContactId,List<PRM_Account_Contact_Relationship__c> PCRList) {
        String result = '';
        String strReturn;
        Contact currContact1;
        try{
            List<Core_IPS_Account_Change_Status__c> accChangeStsLst = new List<Core_IPS_Account_Change_Status__c>();
            if(Core_IPS_Account_Change_Status__c.SObjectType.getDescribe().isAccessible()){
                accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c =: contactId LIMIT 1];
            }
            if(!accChangeStsLst.isEmpty() && 'In Progress'.equalsIgnoreCase(accChangeStsLst[0].Core_IPS_Status__c)) {
                result = 'Change In Progress';
            }
            else{
                Account targetAccountObj = new Account();
                if(Account.SObjectType.getDescribe().isAccessible()){
                    targetAccountObj = [select Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , 
                                            Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.UserRole.Name, Core_PSG_Account__c
                                            FROM Account where ID =: accountId Limit 1];
                }
                
                Contact currContact = new Contact();
                if(Contact.SObjectType.getDescribe().isAccessible()){
                    currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                                Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                                Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                                Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                                From Contact Where id =: contactId];
                }
                
                //Id accId = '0012i00000ELsscAAD';
                List<Case> lCaseToUpdateContact = new List<Case>();
                List<Case> lCaseToUpdateAccount = new List<Case>();
                if(moveCase == true && caseMoveContactId != null){
                    for(Case cs : casewithoutProj){
                        cs.ContactId = caseMoveContactId;
                        lCaseToUpdateContact.add(cs);
                    }
                }else if(moveCase == false){
                    lCaseToUpdateAccount = casewithoutProj;
                }
                if(!keepEntitlements){
                    updateContactEntitlementList(contactId);
                }
                
                strReturn = updateAssetsToCase(lCaseToUpdateContact, lCaseToUpdateAccount, accountId, targetAccountObj, currContact);
                
                if(SUCCESS.equalsIgnoreCase(strReturn)){
                    if(keepEntitlements == false){
                        currContact.Core_AGS_Integration_Status__c = PENDING;
                    }
                    currContact.Core_ERPM_Integration_Status__c = PENDING;
                    //currContact1.Core_AGS_Integration_Status__c = PENDING;
                    currContact.AccountId = accountId;
                    currContact.Core_Account_Changeable__c= true;
                    Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;
                    if(Schema.sObjectType.Contact.isUpdateable()){
                    update currContact;
                    }
                    
                    updateTargetAccountAdditionalFields(currContact, keepEntitlements, targetAccountObj);
                    
                    if(!PCRList.isEmpty()){
                        List<PRM_Account_Contact_Relationship__c> createNewPCRList = new List<PRM_Account_Contact_Relationship__c>();
                        List<PRM_Account_Contact_Relationship__c> deletePCRList = new List<PRM_Account_Contact_Relationship__c>();
                        for(PRM_Account_Contact_Relationship__c PCR : PCRList){
                            if(PCR.PRM_Account_Id__c != accountId){
                                PRM_Account_Contact_Relationship__c newPCR = new PRM_Account_Contact_Relationship__c();
                                newPCR.PRM_Account_Id__c = accountId;
                                newPCR.PRM_Contact_Id__c = PCR.PRM_Contact_Id__c;
                                newPCR.PRM_Relationship_Id__c = PCR.PRM_Relationship_Id__c;
                                newPCR.PRM_Start_Date_Dt__c = PCR.PRM_Start_Date_Dt__c;
                                newPCR.PRM_End_Date_Dt__c = PCR.PRM_End_Date_Dt__c;
                                newPCR.PRM_AGS_Identity_Creation_Fail__c = PCR.PRM_AGS_Identity_Creation_Fail__c;
                                newPCR.PRM_CampaignId__c = PCR.PRM_CampaignId__c;
                                newPCR.PRM_InActive_Ind__c = PCR.PRM_InActive_Ind__c;
                                //newPCR.PRM_isACRChanged__c = PCR.PRM_isACRChanged__c;
                                newPCR.PRM_Status_Nm__c = PCR.PRM_Status_Nm__c;
                                newPCR.PRM_Status_Reason_Txt__c = PCR.PRM_Status_Reason_Txt__c;
                                newPCR.PRM_Source_Agent__c = PCR.PRM_Source_Agent__c;
                                newPCR.PRM_Initiated_By__c = PCR.PRM_Initiated_By__c;
                                createNewPCRList.add(newPCR);
                                deletePCRList.add(PCR);
                            }
                            
                        }
                        if(createNewPCRList.size()>0 && deletePCRList.size()>0){
                            if(Schema.sObjectType.PRM_Account_Contact_Relationship__c.isCreateable()){
                            insert createNewPCRList;
                            }
                            if(Schema.sObjectType.PRM_Account_Contact_Relationship__c.isDeletable()){
                            delete deletePCRList;
                            }
                        }
                    }
                }
                result = 'Successful';
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','changeAccount','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
            result = 'ERROR :' + ex.getMessage();
        }
        
        return result;
    }
    
    public static String updateAssetsToCase(List<Case> lCaseToUpdateContact,List<Case> lstCases, Id accId, Account targetAccountObj, Contact currContact){  // Modified by Ganapati for US436541
        //Map<Id,Id> mapConIdTobe = new Map<Id,id>(); // Commented by Ganapati for US436541 - not used any where
        String strReturn;
        List<Asset> lstCreateAsset = new List<Asset>();
        List<Case> lstUpdateCase = new List<Case>();
        List<Case> newLstUpdateCase = new List<Case>();
        List<Case> finalLstUpdateCase = new List<Case>();
        Date todayDate = System.today(); // Added by Ganapati for US436541
        //List<Asset> lstAssetsForNewAcc = new List<Asset>(); // Commented by Ganapati for US436541 - not used any where
        Map<String,Asset> mapAsset = new Map<String,Asset>();
        List<Case> lstCaseForReupdate = new List<Case>();
        //List<Core_IPS_Account__c> lstIPSAccounts = new List<Core_IPS_Account__c>(); // Commented by Ganapati for US436541 - not used any where
        Set<String> stTobeUpdatedAsset = new Set<String>();
        Id assetPublicRecordId=schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Public Product').getRecordTypeId();
        //lstAssetsForNewAcc = [SELECT id,Core_IPS_Project__c,Core_Product_Organization__c,Core_Supported_Product__c,Accountid FROM Asset WHERE Accountid = : accId]; // Commented by Ganapati for US436541
        
        //for(Asset objAssetRef : lstAssetsForNewAcc){// Commented by Ganapati for US436541
            if(Asset.SObjectType.getDescribe().isAccessible()){
                for(Asset objAssetRef : [SELECT id,Core_IPS_Project__c,Core_Product_Organization__c,Core_Supported_Product__c,Accountid FROM Asset WHERE Accountid = : accId]){// Added by Ganapati for US436541
                    //if(objAssetRef.Accountid != null) { // Commented by Ganapati for US436541 - only assets which have account id have queried
                        mapAsset.put(string.valueof(objAssetRef.Accountid) + string.valueof(objAssetRef.Core_Product_Organization__c)  +  string.valueof(objAssetRef.Core_Supported_Product__c),objAssetRef);
                    //}
                }
            }
            
            for(Case objCaseRef : lstCases){
                objCaseRef.AccountId = accId;
                if(objCaseRef.Core_IPS_Project_Case__c == null && objCaseRef.AccountID != null && objCaseRef.Core_IPS_Product_Org1__c !=null && objCaseRef.Core_IPS_Supported_Product__c!= null && objCaseRef.Asset.recordtypeid!=assetPublicRecordId){
                    string strKey_Asset = string.valueof(objCaseRef.AccountID) + string.valueof(objCaseRef.Core_IPS_Product_Org1__c)  +  string.valueof(objCaseRef.Core_IPS_Supported_Product__c) ;
                    if(!mapAsset.isEmpty() && mapAsset.containsKey(strKey_Asset)) {
                        objCaseRef.AssetId = mapAsset.get(strKey_Asset).id;
                        // Added by Ganapati for US436541 - start
                        if(checkRecursion == false) {
                            lstUpdateCase.add(objCaseRef);
                        } else {
                            newLstUpdateCase.add(objCaseRef);
                        }
                        // Added by Ganapati for US436541 - end
                    } else {
                        if(objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c!=null && !stTobeUpdatedAsset.contains(strKey_Asset)){
                            Asset objAsset = new Asset();
                            objAsset.Name = objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c;
                            objAsset.Product2Id=objCaseRef.Core_IPS_Supported_Product__r.Core_Product__c;
                            objAsset.Core_IPS_Asset__c=true;
                            objAsset.core_alias__c=objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c;
                            objAsset.recordtypeid = ipsAssetRecTypeId;
                            objAsset.AccountId = objCaseRef.AccountId;
                            objAsset.Core_Product_Organization__c = objCaseRef.Core_IPS_Product_Org1__c;
                            objAsset.Core_Supported_Product__c = objCaseRef.Core_IPS_Supported_Product__c;
                            objAsset.Status = 'Inactive';
                            /* Commented by Ganapati for US436541
                            objAsset.InstallDate = system.today()-1;
                            objAsset.UsageEndDate = system.today();
                            Commented by Ganapati for US436541 - end */
                                // Added by Ganapati for US436541 -start
                            objAsset.InstallDate = todayDate - 1;
                            objAsset.UsageEndDate = todayDate;
                            // Added by Ganapati for US436541 -end
                            lstCreateAsset.add(objAsset);
                            stTobeUpdatedAsset.add(strKey_Asset);
                        }
                        lstCaseForReupdate.add(objCaseRef);
                    }
                } else if(objCaseRef.Asset.recordtypeid==assetPublicRecordId) {
                    lstUpdateCase.add(objCaseRef);
                }
            }
            try{
                /* Commented by Ganapati for US436541
                if(lstUpdateCase.size()>0){
                    update lstUpdateCase;
                }*/
                if(checkRecursion == false) { // Added by Ganapati for US436541
                    if(!lstUpdateCase.isEmpty()) {
                        finalLstUpdateCase.addAll(lstUpdateCase);
                    }
                    if(!lCaseToUpdateContact.isEmpty()) {
                        finalLstUpdateCase.addAll(lCaseToUpdateContact);
                    }
                }
                if(checkRecursion && !newLstUpdateCase.isEmpty()) {
                    finalLstUpdateCase.addAll(newLstUpdateCase);
                }
                if(lstCreateAsset.size()>0 && Schema.sObjectType.Asset.isCreateable()){
                    insert lstCreateAsset;
                    if(lstCaseForReupdate.size()>0) {
                        //updateAssetsToCase(lstCaseForReupdate,accId); // Commented by Ganapati for US436541
                        // Added by Ganapati for US436541 - start
                        checkRecursion = true;
                        updateAssetsToCase(new List<Case>(), lstCaseForReupdate, accId, targetAccountObj, currContact);
                        checkRecursion = false;
                        // Added by Ganapati for US436541 - end
                    }
                }
                // Added by Ganapati for US436541 - start
                if(checkRecursion == false) {
                    if(!finalLstUpdateCase.isEmpty()) {
                        if(finalLstUpdateCase.size() <= Integer.valueOf(Label.Core_IPS_CaseUpdateLstSize) || !Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('ActiveOrDeactiveCaseUpdateBatch')) {
                            update finalLstUpdateCase;
                        } else if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('ActiveOrDeactiveCaseUpdateBatch')) {
                            
                            Core_IPS_Account_Change_Status__c accChangeSts = new Core_IPS_Account_Change_Status__c();
                            accChangeSts.Core_IPS_Contact__c = currContact.Id;
                            accChangeSts.Core_IPS_Status__c = 'In Progress';
                            if(Schema.sObjectType.Contact.isCreateable()){
                            insert accChangeSts;
                            }
                            Core_IPS_MoveContactWithCases_Batch moveContactsBatch = new Core_IPS_MoveContactWithCases_Batch(finalLstUpdateCase, accId, targetAccountObj, currContact);
                            Database.executeBatch(moveContactsBatch, Integer.valueOf(Label.Core_IPS_caseUpdateBatchSize));
                        }
                    }
                }
                // Added by Ganapati for US436541 - end
                strReturn = SUCCESS;
            }catch(Exception e){
                
                strReturn = e.getMessage();
                throw e;
            }
            return strReturn;
        }
        
        public static void updateContactEntitlementList(Id contactId){
            List<Core_Contact_Entitlement__c> ceList = [select Id, Name,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_IsActive__c,Core_Status__c,
                                                        Core_Selected__c, Core_Update_Reason__c
                                                        FROM Core_Contact_Entitlement__c 
                                                        WHERE Core_Entitlement_Id__r.Core_IsActive__c = true AND Core_Contact_Id__c  =: contactId
                                                        AND Core_Selected__c = true];
            List<Core_Contact_Entitlement__c> ceListforUpdate = new List<Core_Contact_Entitlement__c>();
            for(Core_Contact_Entitlement__c ceObject : ceList)
            {
                ceObject.Core_Selected__c = false;
                ceObject.Core_Status__c = PENDING;
                ceObject.Core_Update_Reason__c = UPDATE_REASON_CHANGE_ACCOUNT;
                ceObject.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                ceListforUpdate.add(ceObject);
            }
            
            //US:US390485 - Dev:Aparna - Description:updating records in future call to overcome 101 Error - Date:26/6/2019
            //update ceList;
            
            string cntEntrecords=JSON.serialize(ceListforUpdate);
            if(string.isNotblank(cntEntrecords)){
                updateCntEntitlementInFuture(cntEntrecords);
            }
            //End for US390485
        }
        
        public static void updateTargetAccountAdditionalFields(Contact contactref, Boolean keepEntitlements, Account targetAccountObj){
            Account acc = new Account();
            try{
                //Code to update IPS flag in account if the contact IPS flag is true
                if(contactref.Core_IPS_Active__c == true && contactref.Account.Core_IPS_Active__c == false && keepEntitlements == true && contactref != null ){
                    acc.Id = contactref.Accountid;
                    acc.Core_IPS_Active__c = true;
                }
                
                //Set the Account.B2b indicator to true if it is false when the current contact B2B indicator is true
                if(contactref.Core_Contact_B2B_Indicator__c == true && targetAccountObj.Core_B2B_Entitlement__c == false && keepEntitlements == true && contactref != null ){
                    acc.Id = contactref.Accountid;
                    acc.Core_B2B_Entitlement__c = true;
                }
                
                //Update acc Only if IPSFlag or B2B flag is set.
                if(String.isNotBlank(acc.Id) && Schema.sObjectType.Account.isUpdateable()) {
                    update acc;
                }
            } catch(Exception ex){
                UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','updateCntEntitlementInFuture','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
                
            }
        }
        
        @future
        public static void updateCntEntitlementInFuture(string strList){
            try {
                List<Core_Contact_Entitlement__c > newCntEntList = (List<Core_Contact_Entitlement__c >)JSON.deserialize(strList, List<Core_Contact_Entitlement__c >.class);
                if(newCntEntList !=null && newCntEntList .size()>0 && Schema.sObjectType.Core_Contact_Entitlement__c.isUpdateable()){
                    database.update(newCntEntList);
                }
            } catch(Exception ex){
                UCD_ACM_Logger.error('UCD_ACM_MoveContactWithCases_Cont','updateCntEntitlementInFuture','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
                
            }
        }
    }