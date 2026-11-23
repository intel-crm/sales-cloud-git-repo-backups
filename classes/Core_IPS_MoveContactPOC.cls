public without sharing class Core_IPS_MoveContactPOC {
    private static final String PENDING = 'Pending';
    private static final String CLOSED = 'Closed';
    private static final String SUCCESS = 'Success';
    private static final String UPDATE_REASON_CHANGE_ACCOUNT = 'Change Account';
    public static  final String ipsAssetRecTypeId = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
    public static boolean checkRecursion = false;   
    public static List<Case> finalLstUpdateCase = new List<Case>();
    public class My1Exception extends Exception {} 
    public class My2Exception extends Exception {}
    
    @AuraEnabled public static Case contactLookUp {get;set;}
    // @AuraEnabled public static Id onloadAccount;
    @AuraEnabled public static boolean hasAccessToAcctSelection {get;set;}
    @AuraEnabled public static boolean gecCaseFound {get;set;}
    
    @AuraEnabled public static boolean keepCases {get;set;}
    @AuraEnabled public static boolean keepEntitlements {get;set;}
    private static final Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
    
    @AuraEnabled public static String errorMsg {get;set;}
    @AuraEnabled public static Boolean userAuthorized{get;set;}
    @AuraEnabled public static Boolean displayPopUp{get;set;}
    public  static Boolean hidePoppup = false;
    @AuraEnabled public static String moveAccoutWarningMessage{get;set;}
    @AuraEnabled public static boolean hasSelectedEntitlements {get;set;}
    @AuraEnabled public static Contact targetAccount {get;set;}
    @AuraEnabled public static Contact currContact {get;set;}
    @AuraEnabled public static Account acc {get;set;}
    @AuraEnabled public static List<Account> targetAccountObj {get;set;}
    @AuraEnabled public static List<Contact> targetContactObj {get;set;}
    @AuraEnabled public static List<AssetWrapper> assetWithProjectIdFitered {get;set;}
    @AuraEnabled public static List<AssetWrapper> assetWithOUTprojectIdFitered {get;set;}
    @AuraEnabled public static List<Asset> assetWithProjectId {get;set;}
    @AuraEnabled public static List<Asset> assetWithOUTprojectId {get;set;}
    
    public static void initialize(){
        targetAccountObj = null;
        gecCaseFound = false;
        hasAccessToAcctSelection = true;
        keepCases = false;
        keepEntitlements = false;
        contactLookUp = new Case();
        contactLookUp.Id = [select Id from Case Limit 1].Id;
        targetAccount = new Contact();
        userAuthorized = false;
        String temp = '';
        hasSelectedEntitlements = false;
        errorMsg = '';
        
        Map<String, Core_Move_Contact_Authorized_Profiles__c> lCSOpenCases = Core_Move_Contact_Authorized_Profiles__c.getAll();
        for(String s : lCSOpenCases.keySet() ){
            if(currLoggedInUserProfile.Name.equalsIgnoreCase(s.trim())){
                userAuthorized = true;
                break;
            }
        }
    }
    
    public class CaseWrapper{
        public Case cs {get;set;}
        public boolean keepCase {get;set;}
        public CaseWrapper(Case arg1, Boolean flag){
            cs = arg1;
            keepCase = flag;
        }
    }
    
    //Wrapper class for the Assets
    public class AssetWrapper{
        public Asset asst {get;set;}
        public boolean isAcct {get;set;}
        AssetWrapper(Asset ac, String acctId){
            asst = ac;
            If(acctId != null && acctId.equals(ac.AccountId)){
                isAcct = true;
            }else{
                isAcct = false;
            }
        }
    }
    @AuraEnabled public static Integer caseCount {get;set;}  
    @AuraEnabled//List of Cases with Out  IPS Project    
    public static List<CaseWrapper> casesWithOUTprojectId {set; get{
        
        for(CaseWrapper c : casesWithOUTprojectId){
            //if(keepCases == true && c.keepCase == false )
            c.keepCase  = keepCases;
        }
        caseCount   = casesWithOUTprojectId.size();
        return casesWithOUTprojectId;
    }}
    
    @AuraEnabled//List of Cases which associated with IPS Project
    public static List<CaseWrapper> casesWithProjectId {set; get{
        if( (casesWithProjectId != null && casesWithProjectId.size() > 0) || hasSelectedEntitlements == true ){
            if(!hasAccessToAcctSelection){
                errorMsg =  'Only Data Ops can move Contacts from one '+
                    'Account to another if there is any Selected Entitlements and/or IPS Cases. To request these movements please file an '+
                    '<a href ='+Label.Core_Change_Account_Ask_A_Question+'>Ask A Question</a>.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,errorMsg));
                
            }
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Note that if Cases or Accounts are on GEC hold then no movement can happen.'));
        return casesWithProjectId;
    }}
    
    @AuraEnabled(cacheable=true)
    public static contact getCurrentContact (String recordId){
        initialize();
        currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                       Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                       Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                       Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                       From Contact Where id =: recordId];
        targetAccount = currContact;
        //getCases();
        return currContact;
    }
    @AuraEnabled(cacheable=true)
    Public static List<Account> getTargetAccountObj( String targetAccountName){
        if(targetAccountName != null && !string.isempty(targetAccountName)){
            String searchKey = '%' + targetAccountName + '%';
            try{
                targetAccountObj = [select Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_CIM_ID__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , 
                                    Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.Name, Owner.UserRole.Name, Core_PSG_Account__c,
                                    Core_Prime_Account_Name__c, Core_Sales_Groups__c,Core_Account_Country__c,Core_Covered_Account__c,Core_Partner_Alliance_Program__c,Core_Account_Type__c
                                    FROM Account where name LIKE: searchKey];
            }catch(Exception e){
                
            }
        }
        return targetAccountObj;
        
    }
        @AuraEnabled(cacheable=true)
        Public static List<Contact> getTargetContactObj( String consearchKey, String currentAccountId, String currentConId){
      try{
          if(consearchKey != null && !string.isempty(consearchKey)){
            String searchKey = '%' + consearchKey + '%';
            
                targetContactObj = [select Id, Name, AccountId, Account.Name
                                    FROM Contact where Contact.Name LIKE: searchKey AND Account.Id =: currentAccountId AND Id !=: currentConId AND Core_IPS_Active__c = true];
            
        }else{
            targetContactObj = [select Id, Name, AccountId, Account.Name
                                    FROM Contact where Account.Id =: currentAccountId AND Id !=: currentConId AND Core_IPS_Active__c = true];
        }
            }catch(Exception e){
                
            }
        system.debug('targetContactObj - ' + targetContactObj);
        return targetContactObj;
        
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Core_Contact_Entitlement__c> getContactEntitlement (String recordId){
        List<Core_Contact_Entitlement__c> ceList = [select Id, Name,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_IsActive__c,Core_Status__c,
                                                        Core_Selected__c, Core_Update_Reason__c
                                                        FROM Core_Contact_Entitlement__c 
                                                        WHERE Core_Contact_Id__c  =: recordId];
        return ceList;
    }

    @AuraEnabled(cacheable=true)
    Public static Account fetchDefaultRecord( String recordId){
        //if(recordId != null && !string.isempty(recordId)){
            //String searchrecordId = '%' + recordId + '%';
            try{
                acc = [select Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_CIM_ID__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , 
                       Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.UserRole.Name, Core_PSG_Account__c
                       FROM Account where id=: recordId Limit 10];
            }catch(Exception e){
                
            //}
        }
        return acc;
        
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getCases(Contact currentCon){
        System.debug('currentCon'+currentCon);
        gecCaseFound = false;
        final String AcctId = currentCon != null ? currentCon.AccountId : null;
        
        casesWithProjectId = new List<CaseWrapper>();
        casesWithOUTprojectId = new List<CaseWrapper>();
        Set<Id> assetIdsWithProject = new Set<Id>();
        Set<Id> assetIdsWithOutProject = new Set<Id>();
        assetWithProjectIdFitered = new List<AssetWrapper>();
        assetWithOUTprojectIdFitered = new List<AssetWrapper>();        
        assetWithOUTprojectId = new List<Asset>();
        assetWithProjectId = new List<Asset>();
        
        for(Case c:  [Select id,Product.name,caseNumber,status,Contactid,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,
                      Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c, 
                      Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, 
                      Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name 
                      FROM Case  
                      Where contactId =: currentCon.Id AND RecordType.Name != 'CEP Case' ])
        {
            if(c != null){
                //See if it has any GEC case found, do not reset it is already set.
                if(!gecCaseFound && c.Core_IPS_GEC_Case__c && String.isNotBlank(c.Core_IPS_GEC_Status__c) &&  c.Core_IPS_GEC_Status__c.startsWith('On Hold')){
                    gecCaseFound = true;
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' GEC Case Found, moving contact is not allowed.'));
                }
                if(c.Core_IPS_Project_Case__c != null){
                    casesWithProjectId.add(new CaseWrapper(c, false)); 
                    assetIdsWithProject.add(c.AssetId);
                }else {
                    casesWithOUTprojectId.add(new CaseWrapper(c, false));
                    assetIdsWithOutProject.add(c.AssetId);
                } 
            }
        }
        
        //To reuse the SOQL with different conditions below
        final String ASSET_QUERY = 'Select Id, Name, Core_IPS_Asset__c, Core_IPS_Project__c, Core_IPS_Project_Name__c, AccountId, Product2Id, InstallDate, UsageEndDate, Status FROM  Asset ';
        
        Set<Id> setPids = new Set<Id>();
        for(Asset a : DataBase.query(ASSET_QUERY+ '  WHERE id =: assetIdsWithProject')){
            assetWithProjectId.add(a);
            setPids.add(a.Product2Id);
        }
        
        if(String.isNotBlank(AcctId)){
            for(Asset a : DataBase.query(ASSET_QUERY+ '  where Accountid =: AcctId AND Product2Id =: setPids ' )){
                assetWithProjectIdFitered.add(new AssetWrapper(a,AcctId));                
            }
        }  
        
        setPids.clear();
        for(Asset a : DataBase.query(ASSET_QUERY+ '  where id =: assetIdsWithOutProject')){
            assetWithOUTprojectId.add(a);
            setPids.add(a.Product2Id);
        }
        
        if(String.isNotBlank(AcctId)){
            for(Asset a : DataBase.query(ASSET_QUERY+ '  where Accountid =: AcctId AND Product2Id =: setPids ' )){
                assetWithOUTprojectIdFitered.add(new AssetWrapper(a,AcctId));                
            }
        }
        system.debug('casefound'+gecCaseFound);
        return gecCaseFound;
    }
    @AuraEnabled
    Public static String hasValidInputs(Contact con, Account tarAcc, Boolean gecCase, Boolean keepEntitlements){
        List<Account> a = getTargetAccountObj(tarAcc.Name);
        tarAcc = a[0];
        String ErrorMessage = 'false';
        boolean flag = false;
        //Account tg = null;
        System.debug('con++++'+con);
        System.debug('tarAcc'+tarAcc);
        System.debug('gecCase'+gecCase);
        if(con.AccountId == tarAcc.id){
            ErrorMessage = ' Current account and Requested account is same.';
            return ErrorMessage;
        }
        
        
        //1. Validate GEC Cases.
        if(gecCase){
            ErrorMessage = ' GEC Cases Found, moving contact and Entitlements is not allowed.';
            return ErrorMessage;
        }
        
        //Fetch all the target Account fields for further validations
        //gettarAccObj(tarAccObj[0].Id);
        
        //Query tarAcc fields for validations
        //Account tarAccObj = null;
        if(tarAcc == null){
            ErrorMessage = ' Account : INVALID ACCOUNT '; 
            return ErrorMessage;
        }
        
        if(tarAcc.Core_PSG_Account__c == false && con.Account.Core_PSG_Account__c ==true && !hidePoppup){
            moveAccoutWarningMessage= System.Label.Core_IPS_Move_AccWarning_Message;
            if(!hidePoppup){
                //displayPopUp = true;
                ErrorMessage = moveAccoutWarningMessage;  
            }  
            return ErrorMessage;
        }
        //Validate source and targert are of same ODM Type
        boolean tarAccODMflag = tarAcc.Core_IsODM__c;
        if(tarAccODMflag != con.Account.Core_IsODM__c && keepEntitlements == true){
            ErrorMessage='Keep Entitlements is not allowed when moving contact from a standard account to an ODM account or from an ODM account to standard account';
            return ErrorMessage;
        }
        
        if(String.isBlank(tarAcc.Core_CNDA_Number__c)  && keepEntitlements == true && tarAcc.Core_PSG_Account__c != true){
            ErrorMessage='CNDA must be filled manually by the user on the Account record : '+tarAcc.Name;
            return ErrorMessage;
        }
        
        if(String.isBlank(tarAcc.Core_CIM_ID__c)  && keepEntitlements == true ){
            ErrorMessage = 'CIM ID must be filled manually by the user on the Account record : '+tarAcc.Name;
            return ErrorMessage;
        }
        
        if(String.isBlank(tarAcc.Core_English_Only_Name__c) && keepEntitlements == true ){
            ErrorMessage='English Only Name must be filled manually by the user on the Account record : '+tarAcc.Name;
            return ErrorMessage;
        }
        
        if(con.Account.Core_Export_Compliance_Block__c == true){
            ErrorMessage = ' Account :'+con.Account.Name+' is on  GEC Hold ';
            return ErrorMessage;
        }
        
        //Do not process if target account or current Acccount has GEC on Hold Validation
        if(tarAcc.Core_Export_Compliance_Block__c == true){
            ErrorMessage = ' Account :'+tarAcc.Name+' is on  GEC Hold ';
            return ErrorMessage;
        }
        
        //Do Not proces if IPS Active flag is false and keepEntitlements = true in Target Account
        //if(con.Account.Core_IPS_Active__c == true && tarAccObj.Core_IPS_Active__c == false  && keepEntitlements == true){
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact IT Support to have them manually set the IPS Active flag on the Account record : '+tarAccObj.Name));
        //    return flag;
        //}
        
        //Do Not proces if B2B flag is false and keepEntitlements = true in Target Account
        //if(con.Account.Core_B2B_Entitlement__c == true && tarAccObj.Core_B2B_Entitlement__c == false  && keepEntitlements == true){
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact IT Support to have them manually set the B2B Entitlement flag on the Account record : '+tarAccObj.Name));
        //    return flag;
        //}
        
        // Validate target Account's owner has a role setup
        if(tarAcc.Core_IPS_Active__c == true  && keepEntitlements == true && String.isBlank(tarAcc.Owner.UserRole.Name)){
            ErrorMessage = 'Please contact IT Support to have them manually set the UserRole to Account :'+tarAcc.Name+'\'s Owner :';
            return ErrorMessage;
        }
        ErrorMessage = 'true';
        return ErrorMessage;
    }
    public static String updateAssetsToCase(List<Case> lCaseToUpdateContact,List<Case> lstCases, Id accId, Account targetAccountObj, Contact currContact){  // Modified by Ganapati for US436541
        //Map<Id,Id> mapConIdTobe = new Map<Id,id>(); // Commented by Ganapati for US436541 - not used any where
        String strReturn;
        List<Asset> lstCreateAsset = new List<Asset>();
        List<Case> lstUpdateCase = new List<Case>();
        List<Case> newLstUpdateCase = new List<Case>();
        Date todayDate = System.today(); // Added by Ganapati for US436541
        //List<Asset> lstAssetsForNewAcc = new List<Asset>(); // Commented by Ganapati for US436541 - not used any where
        Map<String,Asset> mapAsset = new Map<String,Asset>();
        List<Case> lstCaseForReupdate = new List<Case>();
        //List<Core_IPS_Account__c> lstIPSAccounts = new List<Core_IPS_Account__c>(); // Commented by Ganapati for US436541 - not used any where
        Set<String> stTobeUpdatedAsset = new Set<String>();
        Id assetPublicRecordId=schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Public Product').getRecordTypeId();
        //lstAssetsForNewAcc = [SELECT id,Core_IPS_Project__c,Core_Product_Organization__c,Core_Supported_Product__c,Accountid FROM Asset WHERE Accountid = : accId]; // Commented by Ganapati for US436541
        
        //for(Asset objAssetRef : lstAssetsForNewAcc){// Commented by Ganapati for US436541
        for(Asset objAssetRef : [SELECT id,Core_IPS_Project__c,Core_Product_Organization__c,Core_Supported_Product__c,Accountid FROM Asset WHERE Accountid = : accId]){// Added by Ganapati for US436541
            //if(objAssetRef.Accountid != null) { // Commented by Ganapati for US436541 - only assets which have account id have queried
            mapAsset.put(string.valueof(objAssetRef.Accountid) + string.valueof(objAssetRef.Core_Product_Organization__c)  +  string.valueof(objAssetRef.Core_Supported_Product__c),objAssetRef);
            //}
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
            if(lstCreateAsset.size()>0){
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
                        System.debug('Inline 724');
                        Core_IPS_Account_Change_Status__c accChangeSts = new Core_IPS_Account_Change_Status__c();
                        accChangeSts.Core_IPS_Contact__c = currContact.Id;
                        accChangeSts.Core_IPS_Status__c = 'In Progress';
                        insert accChangeSts;
                        Core_IPS_MoveContactWithCases_Batch moveContactsBatch = new Core_IPS_MoveContactWithCases_Batch(finalLstUpdateCase, accId, targetAccountObj, currContact);  
                        Database.executeBatch(moveContactsBatch, Integer.valueOf(Label.Core_IPS_caseUpdateBatchSize));   
                    }
                }
            }
            // Added by Ganapati for US436541 - end
            strReturn = SUCCESS;
        }catch(Exception e){
            System.debug('Core_Contact_Status_Update_Handler.updateAssets Exception:'+e);
            strReturn = e.getMessage();
            throw e;
        }
        return strReturn;
    }
    @TestVisible private static void updateTargetAccountAdditionalFields(Contact curCont, Contact currContact, Account tarAcc){
        Contact contactref = [SELECT id,accountid,Account.Core_IPS_Active__c,Core_IPS_Active__c FROM Contact where id =: curCont.id limit 1];
        Account acc = new Account();
        //Code to update IPS flag in account if the contact IPS flag is true
        if(curCont.Core_IPS_Active__c == true && contactref.Account.Core_IPS_Active__c == false && keepEntitlements == true && contactref != null ){
            acc.Id = contactref.Accountid;
            acc.Core_IPS_Active__c = true;
        }
        
        //Set the Account.B2b indicator to true if it is false when the current contact B2B indicator is true
        if(currContact.Core_Contact_B2B_Indicator__c == true && tarAcc.Core_B2B_Entitlement__c == false && keepEntitlements == true && contactref != null ){
            acc.Id = contactref.Accountid;
            acc.Core_B2B_Entitlement__c = true;
        }
        
        //Update acc Only if IPSFlag or B2B flag is set.
        if(String.isNotBlank(acc.Id)) {
            System.debug('Ankit==>+acc'+acc);
            update acc;
        }   
    }
    @AuraEnabled
    public static String updateContactOnSave(Contact CurrContact, Account tarAccount, String Reason, Boolean isCheckedWithAccowner, Boolean isCheckedKeepEntitlement){
        //List<String> str = new List<String>();
        String msg;
        //Boolean isSuccess = false;
        system.debug('Account and contact'+ CurrContact+tarAccount);
        // getCurrentContact(CurrContact.Id);
        //getTargetAccountObj(targetAccountName);
        system.debug('isCheckedWithAccowner - ' + isCheckedWithAccowner);
        
        //system.debug('targetAccountObj - ' + targetAccountObj);
        //PageReference page = null;
        String strStatus = '';
        // Added by Ganapati for US436541 - start - to check if account change is already in progress 
        List<Core_IPS_Account_Change_Status__c> accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c = : CurrContact.id LIMIT 1];
        system.debug('accChangeStsLst - ' + accChangeStsLst);
        if(!accChangeStsLst.isEmpty() && 'In Progress'.equalsIgnoreCase(accChangeStsLst[0].Core_IPS_Status__c)) {
            // return to page if account change is already in progress
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account change for this contact already in Progress. Please try later.'));
            //return page;
            msg = 'Account change for this contact already in Progress. Please try later.';
            //str.add('black');
        } 
        // Added by Ganapati for US436541 - end
        Savepoint sp = Database.setSavepoint();
        
        //return to page if Any of the validation fails;
        /* if(!hasValidInputs()){
//return page;
}
*/
        try{
            
            //----------------  Step 1 : Unselect all the selected entitlements and change the status to pending if keepEntitlements is checked in UI -------------------
            // updateContactEntitlementList();
            
            //----------------  Step 2 : Move contacts and Cases-------------------
            //Method filters contact update cases and returns cases that account and assets to be update
            //List<Case> lstMoveAcc = filterCasesAndUpdateContact(); // commented by Ganapati for US436541 - functinality included inline below
            getCases(CurrContact);
            List<Case> lCaseToUpdateContact = new List<Case>(); 
            List<Case> lCaseToUpdateAccount = new List<Case>();
            system.debug('casesWithOUTprojectId - ' + casesWithOUTprojectId);
            system.debug('contactLookUp - ' + contactLookUp);
            for(CaseWrapper cseWOutPrjt : casesWithOUTprojectId){
                if(cseWOutPrjt.keepCase == true && contactLookUp.contactid !=null){
                    cseWOutPrjt.cs.contactid = contactLookUp.contactid;
                    lCaseToUpdateContact.add(cseWOutPrjt.cs); 
                    
                }else if(cseWOutPrjt.keepCase == false){
                    lCaseToUpdateAccount.add(cseWOutPrjt.cs);
                    
                }
            } 
            //Step 3: Method update account and assets to the cases and returns success or error message
            //strStatus = updateAssetsToCase(lstMoveAcc, targetAccount.accountId); // Commented by Ganapati for US436541 - changed function definition
            System.debug('lCaseToUpdateAccount - '+lCaseToUpdateAccount);
            system.debug('lCaseToUpdateContact - ' + lCaseToUpdateContact);
            //strStatus = updateAssetsToCase(new Map<Id, Case>(lstMoveAcc), targetAccount.accountId, targetAccountObj, currContact, keepEntitlements);
            strStatus = updateAssetsToCase(lCaseToUpdateContact, lCaseToUpdateAccount, CurrContact.accountId, tarAccount, CurrContact);// Added by Ganapati for US436541 - start
            //strStatus = 'success';
            system.debug('strStatus - ' + strStatus);
            if(SUCCESS.equalsIgnoreCase(strStatus)){
                Contact currContact1 = [Select Id,Name,Email,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,AccountId,Core_Account_Changeable__c,Core_IPS_Active__c from contact where id =: CurrContact.id limit 1];
                String OldAccount = currContact1.AccountId != null ? currContact1.AccountId : null;
                currContact1.Core_ERPM_Integration_Status__c = PENDING;
                currContact1.Core_AGS_Integration_Status__c = PENDING;
                currContact1.AccountId = tarAccount.Id;//targetAccount.accountId;
                currContact1.Core_Account_Changeable__c= true;
                Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;
                
                Set<String> contactName = new Set<String>();
                contactName.add(currContact1.Name);
                
                String Query = 'Select id, Contact__r.name,Account__c, Account__r.name, Is_Approved__c,Is_Rejected__c from Contact_Move_Governance__c where Contact__r.name IN :contactName';
                List<Contact_Move_Governance__c> afterQueryContactMoveGovernace = Database.query(Query);
                system.debug('afterQueryContactMoveGovernace - ' + afterQueryContactMoveGovernace);
                
                boolean isvalid = true;
                For(Contact_Move_Governance__c ContactMoveGovernance :afterQueryContactMoveGovernace){
                    if(ContactMoveGovernance.Contact__r.name == currContact1.name &&  ContactMoveGovernance.Is_Approved__c == false && ContactMoveGovernance.Is_Rejected__c == false){
                        isvalid = false;
                        break;
                    }
                }
                
                system.debug('isvalid - ' + isvalid);
                if(isvalid){
                    Contact_Move_Governance__c ContactMoveGovernanceRec = new Contact_Move_Governance__c();
                    ContactMoveGovernanceRec.Old_Account__c = OldAccount;
                    ContactMoveGovernanceRec.Is_Approved__c = false;
                    ContactMoveGovernanceRec.Account__c = tarAccount.Id;//targetAccount.accountId;
                    ContactMoveGovernanceRec.Contact__c = currContact1.Id;
                    ContactMoveGovernanceRec.Contact_Name__c = currContact1.Name;
                    ContactMoveGovernanceRec.Contact_Email__c = currContact1.Email;
                    ContactMoveGovernanceRec.Checked_with_Account_Owner__c = isCheckedWithAccowner;
                    ContactMoveGovernanceRec.Reason__c = Reason;
                    ContactMoveGovernanceRec.Keep_Entitlement__c = isCheckedKeepEntitlement;
                    insert ContactMoveGovernanceRec;
                    system.debug('ContactMoveGovernanceRec - ' + ContactMoveGovernanceRec);
                    updateTargetAccountAdditionalFields(currContact1,CurrContact,tarAccount);
                    //isSuccess = true;
                    //str.add('green');
                    msg = 'Approval request has been sent successfully';
                    
                }else{
                    System.debug('isvalid==>'+isvalid);
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A request to move the contact is already in progress!'));
                    //return null;
                    //str.add('grey');
                    msg = 'A request to move the contact is already in progress!';
                }
                //update currContact1;
                
                
                //Update the addtional Fields to Account, B2B and IPS
                // updateTargetAccountAdditionalFields(currContact1);
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Contact move request submitted')); 
                // page = new PageReference('/'+currContact.Id); 
            }else if(String.isNotEmpty(strStatus)){
                system.debug('strStatuselse - ' + strStatus);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strStatus));
                //str.add('red');
                msg = strStatus;
            }
        } catch(DMLException ex) { //added by sugandha for US79061
            System.debug('excep msg::'+ex.getMessage() + ex.getLineNumber() + ex.getStackTraceString());
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        } 
        //return isSuccess;
        system.debug('str values - ' + msg);
        return msg;
    }    
}