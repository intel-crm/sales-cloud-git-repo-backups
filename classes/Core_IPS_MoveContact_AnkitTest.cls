/**************************************************************************************
Apex Class Name: Core_IPS_MoveContactWithCases_Controller  
Test Class : Core_IPS_MoveContactWithCases_Ctrlr_Test
Version     : 1.0 
Created Date: Dec 2016
Description : For moving the contact from one account to another account along with the cases and entitlements
* Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------
* Ganapati                    03/10/2019              Modified for US436541
*************************************************************************************/
public with sharing class  Core_IPS_MoveContact_AnkitTest {
    
    private static final String PENDING = 'Pending';
    private static final String CLOSED = 'Closed';
    private static final String SUCCESS = 'Success';
    private static final String UPDATE_REASON_CHANGE_ACCOUNT = 'Change Account';
    
    // Added by Ganapati for US436541 - start
    public static  final String ipsAssetRecTypeId = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
    public static boolean checkRecursion = false;   
    public static List<Case> finalLstUpdateCase = new List<Case>();
    // Added by Ganapati for US436541 - end
    public static List<Asset> assetWithProjectId {get;set;}
    public static List<Asset> assetWithOUTprojectId {get;set;}
    
    public static boolean hasSelectedEntitlements {get;set;}
    
    //Current session contact Object
    @AuraEnabled
    public static Contact currContact {get;set;}
    
 
    
    //target account where the contact is getting moved
    public static Contact targetAccount {get;set;}
    
    private static final Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
    
    public static List<AssetWrapper> assetWithProjectIdFitered {get;set;}
    public static List<AssetWrapper> assetWithOUTprojectIdFitered {get;set;}
    
    //Check if the running User is authorized to performa the operation
    public static Boolean userAuthorized;
    public static Boolean displayPopUp{get;set;}
    public static Boolean hidePoppup = false;
    public static String moveAccoutWarningMessage{get;set;}
    
    //All the entitlements for the contact
    public List<EntitlementWrapper> entitlements {set; get{
        for(EntitlementWrapper k : entitlements){
            k.keepEntitlement  = keepEntitlements;
        }
        return entitlements;
    }}
    
    //target contact to keep the cases
    public static Case contactLookUp {get;set;}
    public static Id onloadAccount;
    public static boolean hasAccessToAcctSelection {get;set;}
    public static boolean gecCaseFound {get;set;}
    
    public static boolean keepCases {get;set;}
    public static boolean keepEntitlements {get;set;}
    
    public static String errorMsg {get;set;}
    //Total cases 
    //public List<Case> contactCases {get;set;} // commented by Ganapati for US436541 - not used anywhere
    
    //Target Account to which the contact is getting moved to 
    @TestVisible public static Account targetAccountObj = null;
    
    //Query all the target Account fields for validations
    @AuraEnabled(cacheable=true)
    public static Account getTargetAccountObj(String recordId){
        if(targetAccountObj == null){
            try{
                targetAccountObj = [select Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_CIM_ID__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , 
                                    Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.UserRole.Name, Core_PSG_Account__c
                                    FROM Account where ID =: targetAccount.AccountId Limit 1];
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Account : INVALID ACCOUNT ')); // '+tg.Name+' removed by prem
            }
        }
        return targetAccountObj;
        
    }
    
    
    //List of Cases which associated with IPS Project
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
    
    
    public static Integer caseCount {get;set;}  
    //List of Cases with Out  IPS Project    
    public static List<CaseWrapper> casesWithOUTprojectId {set; get{
        
        for(CaseWrapper c : casesWithOUTprojectId){
            //if(keepCases == true && c.keepCase == false )
            c.keepCase  = keepCases;
        }
        caseCount   = casesWithOUTprojectId.size();
        return casesWithOUTprojectId;
    }}
    
    //Method initializes all the variables.
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
    
    //Default constructor
    public Core_IPS_MoveContact_AnkitTest (ApexPages.standardcontroller controller){
        
        try{
            initialize();
            System.debug('checkRecursion :::'+checkRecursion);
            
            currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                           Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                           Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                           Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                           From Contact Where id =: controller.getId()];   
            onloadAccount = currContact.Accountid;
            
            //Retrieve Cases
            getCases();
            
            //Retrieve Entitlements
            retrieveEntitlements();
            
            
        }catch(Exception e){
            currContact = null;
        }
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getCore_IPS_MoveContact_AnkitTest_LWCPOC (String recordId){
        
        try{
            //initialize();
            System.debug('checkRecursion :::'+checkRecursion);
            
            currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                           Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                           Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                           Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                           From Contact];  
            //List<Contact> myConList= [Select Id, FirstName, LastName, Email, Phone, Account.Name From Contact Where Id=:recordId];
            System.debug('####In Contact'+currContact);
            onloadAccount = currContact.Accountid;
            
            //Retrieve Cases
           // getCases();
            
            //Retrieve Entitlements
            //retrieveEntitlements();
            
            
        }catch(Exception e){
            currContact = null;
        }
        //System.debug('currContact'+currContact);
        return currContact;
                
    }
    @AuraEnabled(cacheable=true)
    public static String getCore_IPS_MoveContact_AnkitTest_LWCPOC1 (){
        String s = '';
        return s;
    }
    
    //Retrieve the Entitlements associated with the selected contact for displaying in UI
    public PageReference retrieveEntitlements(){
        entitlements = new List<EntitlementWrapper>();
        for(Core_Contact_Entitlement__c cce : [SELECT Name , Core_Contact_Id__c, Core_Engagement_Tier__c, Core_Entitlement_Id__c, Core_From_Source__c,   
                                               Core_Selected__c,Core_Entitlement_Id__r.Core_Display_Name__c,  Core_Contact_Id__r.Name, Core_Type__c 
                                               FROM Core_Contact_Entitlement__c 
                                               WHERE Core_Contact_Id__c =: currContact.Id AND Core_Entitlement_Id__r.Core_IsActive__c = true])
        {
            entitlements.add(new EntitlementWrapper(cce, false));   
            if(cce.Core_Selected__c == true)
                hasSelectedEntitlements = true;
        }
        
        // INFO 1. If the contact doesn't have any Entitlements or Collateral then allow User with R/W to the Contact can select new Account
        boolean noEntitlements = ((entitlements != null && entitlements.size() == 0) || entitlements == null || hasSelectedEntitlements == false);
        boolean noCases = ((casesWithOUTprojectId != null && casesWithOUTprojectId.size() == 0) || casesWithOUTprojectId == null );
        if(noEntitlements && noCases){
            hasAccessToAcctSelection = Schema.sObjectType.Contact.isUpdateable() ;
        }else if(!noEntitlements || !noCases){
            if(userAuthorized == true){
                hasAccessToAcctSelection = true;
            }else{
                hasAccessToAcctSelection = false;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' User do not have the permission to perform the  operation. Only Data Ops can perform the change'));
            }
        }
        return null;
    }
    
    //Retrieves all the Cases & Assets for displaying in UI.
    public static void getCases(){
        final String AcctId = currContact != null ? currContact.AccountId : null;
        
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
                      Where contactId =: currContact.Id AND RecordType.Name != 'CEP Case' ])
        {
            //See if it has any GEC case found, do not reset it is already set.
            if(!gecCaseFound && c.Core_IPS_GEC_Case__c && String.isNotBlank(c.Core_IPS_GEC_Status__c) &&  c.Core_IPS_GEC_Status__c.startsWith('On Hold')){
                gecCaseFound = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' GEC Case Found, moving contact is not allowed.'));
            }
            if(c.Core_IPS_Project_Case__c != null){
                casesWithProjectId.add(new CaseWrapper(c, false)); 
                assetIdsWithProject.add(c.AssetId);
            }else {
                casesWithOUTprojectId.add(new CaseWrapper(c, false));
                assetIdsWithOutProject.add(c.AssetId);
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
        
        
        //return null;
    }
    
    // @return true - if all the inputs are valid for processing.
    // @return false - if one or more inputs are InValid.
    @TestVisible private static boolean hasValidInputs(){
        
        boolean flag = false;
        //Account tg = null;
        
        if(currContact.AccountId == targetAccount.AccountId){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Current account and Requested account is same.'));
            return flag;
        }
        
        
        //1. Validate GEC Cases.
        if(gecCaseFound){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' GEC Cases Found, moving contact and Entitlements is not allowed.'));
            return flag;
        }
        
        //Fetch all the target Account fields for further validations
        getTargetAccountObj(targetAccountObj.Id);
        
        //Query targetAccount fields for validations
        //Account targetAccountObj = null;
        if(targetAccountObj == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Account : INVALID ACCOUNT ')); // '+tg.Name+' removed by prem
            return flag;
        }
        
        if(targetAccountObj.Core_PSG_Account__c == false && currContact.Account.Core_PSG_Account__c ==true && !hidePoppup){
            moveAccoutWarningMessage= System.Label.Core_IPS_Move_AccWarning_Message;
            if(!hidePoppup){
                displayPopUp = true;   
            }  
            return flag;
        }
        //Validate source and targert are of same ODM Type
        boolean targetAccountODMflag = targetAccountObj.Core_IsODM__c;
        if(targetAccountODMflag != currContact.Account.Core_IsODM__c && keepEntitlements == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Keep Entitlements is not allowed when moving contact from a standard account to an ODM account or from an ODM account to standard account'));
            return flag;
        }
        
        if(String.isBlank(targetAccountObj.Core_CNDA_Number__c)  && keepEntitlements == true && targetAccountObj.Core_PSG_Account__c != true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CNDA must be filled manually by the user on the Account record : '+targetAccountObj.Name));
            return flag;
        }
        
        if(String.isBlank(targetAccountObj.Core_CIM_ID__c)  && keepEntitlements == true ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CIM ID must be filled manually by the user on the Account record : '+targetAccountObj.Name));
            return flag;
        }
        
        if(String.isBlank(targetAccountObj.Core_English_Only_Name__c) && keepEntitlements == true ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'English Only Name must be filled manually by the user on the Account record : '+targetAccountObj.Name));
            return flag;
        }
        
        if(currContact.Account.Core_Export_Compliance_Block__c == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Account :'+currContact.Account.Name+' is on  GEC Hold '));
            return flag;
        }
        
        //Do not process if target account or current Acccount has GEC on Hold Validation
        if(targetAccountObj.Core_Export_Compliance_Block__c == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Account :'+targetAccountObj.Name+' is on  GEC Hold '));
            return flag;
        }
        
        //Do Not proces if IPS Active flag is false and keepEntitlements = true in Target Account
        //if(currContact.Account.Core_IPS_Active__c == true && targetAccountObj.Core_IPS_Active__c == false  && keepEntitlements == true){
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact IT Support to have them manually set the IPS Active flag on the Account record : '+targetAccountObj.Name));
        //    return flag;
        //}
        
        //Do Not proces if B2B flag is false and keepEntitlements = true in Target Account
        //if(currContact.Account.Core_B2B_Entitlement__c == true && targetAccountObj.Core_B2B_Entitlement__c == false  && keepEntitlements == true){
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact IT Support to have them manually set the B2B Entitlement flag on the Account record : '+targetAccountObj.Name));
        //    return flag;
        //}
        
        // Validate target Account's owner has a role setup
        if(targetAccountObj.Core_IPS_Active__c == true  && keepEntitlements == true && String.isBlank(targetAccountObj.Owner.UserRole.Name)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact IT Support to have them manually set the UserRole to Account :'+targetAccountObj.Name+'\'s Owner :'));
            return flag;
        }
        return true;
    }
    
    //added by mahendra
    public PageReference closePopup() {
        displayPopUp = false;
        PageReference pageRef = new PageReference('/apex/Core_IPS_MoveContactWithCases?Id='+currContact.id );
        pageRef.setRedirect(true);
        return pageRef;
        //targetAccount.AccountId= NULL;
    }
    
    public pageReference moveAccountchange(){
        hidePoppup= true;
        PageReference page=updateCasesOnSave();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Contact move request submitted')); 

        hidePoppup= false;
        displayPopUp = false;
        return page;
    }
    
    
    //Method to update Accounts and Move Cases to New Account
    public PageReference updateCasesOnSave(){
        PageReference page = null;
        String strStatus = '';
        // Added by Ganapati for US436541 - start - to check if account change is already in progress 
        List<Core_IPS_Account_Change_Status__c> accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c = :currContact.Id LIMIT 1];
        if(!accChangeStsLst.isEmpty() && 'In Progress'.equalsIgnoreCase(accChangeStsLst[0].Core_IPS_Status__c)) {
            // return to page if account change is already in progress
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account change for this contact already in Progress. Please try later.'));
            return page;
        } 
        // Added by Ganapati for US436541 - end
        Savepoint sp = Database.setSavepoint();
        
        //return to page if Any of the validation fails;
        if(!hasValidInputs()){
            return page;
        }
        
        try{
            
            //----------------  Step 1 : Unselect all the selected entitlements and change the status to pending if keepEntitlements is checked in UI -------------------
            updateContactEntitlementList();
            
            //----------------  Step 2 : Move contacts and Cases-------------------
            //Method filters contact update cases and returns cases that account and assets to be update
            //List<Case> lstMoveAcc = filterCasesAndUpdateContact(); // commented by Ganapati for US436541 - functinality included inline below
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
            system.debug('lCaseToUpdateContact - ' + lCaseToUpdateContact);
            System.debug('lstMoveAcc '+lCaseToUpdateAccount);
            //strStatus = updateAssetsToCase(new Map<Id, Case>(lstMoveAcc), targetAccount.accountId, targetAccountObj, currContact, keepEntitlements);
            strStatus = updateAssetsToCase(lCaseToUpdateContact, lCaseToUpdateAccount, targetAccount.accountId, targetAccountObj, currContact);// Added by Ganapati for US436541 - start
			system.debug('strStatus - ' + strStatus);
            
            if(SUCCESS.equalsIgnoreCase(strStatus)){
                Contact currContact1 = [Select Id,Name,Email,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,AccountId,Core_Account_Changeable__c,Core_IPS_Active__c from contact where id =: currContact.id limit 1];
                system.debug('currContact1 - ' + currContact1);
                String OldAccount = currContact1.AccountId != null ? currContact1.AccountId : null;
                system.debug('OldAccount - ' + OldAccount);
                currContact1.Core_ERPM_Integration_Status__c = PENDING;
                currContact1.Core_AGS_Integration_Status__c = PENDING;
                currContact1.AccountId = targetAccount.accountId;
                currContact1.Core_Account_Changeable__c= true;
                Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;

                Set<String> contactName = new Set<String>();
                contactName.add(currContact1.Name);
				system.debug('contactName - ' + contactName);
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

                if(isvalid){
                    Contact_Move_Governance__c ContactMoveGovernanceRec = new Contact_Move_Governance__c();
                    ContactMoveGovernanceRec.Old_Account__c = OldAccount;
                    ContactMoveGovernanceRec.Is_Approved__c = false;
                    ContactMoveGovernanceRec.Account__c = targetAccount.accountId;
                    ContactMoveGovernanceRec.Contact__c = currContact1.Id;
                    ContactMoveGovernanceRec.Contact_Name__c = currContact1.Name;
                    ContactMoveGovernanceRec.Contact_Email__c = currContact1.Email;
                    insert ContactMoveGovernanceRec;
                    updateTargetAccountAdditionalFields(currContact1);


                }else{
                    System.debug('isvalid==>'+isvalid);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A request to move the contact is already in progress!'));
                    return null;
                }
                //update currContact1;

    
                //Update the addtional Fields to Account, B2B and IPS
               // updateTargetAccountAdditionalFields(currContact1);
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Contact move request submitted')); 
                page = new PageReference('/'+currContact.id); 
            }else if(String.isNotEmpty(strStatus)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strStatus));
            }
        } catch(DMLException ex) { //added by sugandha for US79061
            System.debug('excep msg::'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getdmlMessage(0)));
            Database.rollback(sp);
    } catch(Exception e){
            System.debug('excep msg::'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            Database.rollback(sp);
        }
        return page;
       // return null;
    }
    
   @AuraEnabled
    public static void updateContactOnSave_Shiva(Contact CurrContact, Id targetAccountId){
        system.debug('My Method Running');
        system.debug('CurrContact - ' + CurrContact);
        system.debug('targetAccountId - ' + targetAccountId);
        PageReference page = null;
        String strStatus = '';
        // Added by Ganapati for US436541 - start - to check if account change is already in progress 
        List<Core_IPS_Account_Change_Status__c> accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c = : CurrContact.id LIMIT 1];
        system.debug('accChangeStsLst - ' + accChangeStsLst);
        if(!accChangeStsLst.isEmpty() && 'In Progress'.equalsIgnoreCase(accChangeStsLst[0].Core_IPS_Status__c)) {
            // return to page if account change is already in progress
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account change for this contact already in Progress. Please try later.'));
            //return page;
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
         /*   List<Case> lCaseToUpdateContact = new List<Case>(); 
          List<Case> lCaseToUpdateAccount = new List<Case>();
            for(CaseWrapper cseWOutPrjt : casesWithOUTprojectId){
                if(cseWOutPrjt.keepCase == true && contactLookUp.contactid !=null){
                    cseWOutPrjt.cs.contactid = contactLookUp.contactid;
                    lCaseToUpdateContact.add(cseWOutPrjt.cs); 
                    
                }else if(cseWOutPrjt.keepCase == false){
                    lCaseToUpdateAccount.add(cseWOutPrjt.cs);
                    
                }
          } */
            //Step 3: Method update account and assets to the cases and returns success or error message
            //strStatus = updateAssetsToCase(lstMoveAcc, targetAccount.accountId); // Commented by Ganapati for US436541 - changed function definition
            //System.debug('lstMoveAcc '+lCaseToUpdateAccount);
            //strStatus = updateAssetsToCase(new Map<Id, Case>(lstMoveAcc), targetAccount.accountId, targetAccountObj, currContact, keepEntitlements);
            //strStatus = updateAssetsToCase(lCaseToUpdateContact, lCaseToUpdateAccount, targetAccountId, TargetAccountObj, CurrContact);// Added by Ganapati for US436541 - start
			strStatus = 'success';
            if(SUCCESS.equalsIgnoreCase(strStatus)){
                Contact currContact1 = [Select Id,Name,Email,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,AccountId,Core_Account_Changeable__c,Core_IPS_Active__c from contact where id =: CurrContact.id limit 1];
                String OldAccount = currContact1.AccountId != null ? currContact1.AccountId : null;
                currContact1.Core_ERPM_Integration_Status__c = PENDING;
                currContact1.Core_AGS_Integration_Status__c = PENDING;
                currContact1.AccountId = targetAccountId;
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
                    ContactMoveGovernanceRec.Account__c = targetAccountId;
                    ContactMoveGovernanceRec.Contact__c = currContact1.Id;
                    ContactMoveGovernanceRec.Contact_Name__c = currContact1.Name;
                    ContactMoveGovernanceRec.Contact_Email__c = currContact1.Email;
                    insert ContactMoveGovernanceRec;
                    system.debug('ContactMoveGovernanceRec - ' + ContactMoveGovernanceRec);
                    //updateTargetAccountAdditionalFields(currContact1);


                }else{
                    System.debug('isvalid==>'+isvalid);
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A request to move the contact is already in progress!'));
                    //return null;
                }
                //update currContact1;

    
                //Update the addtional Fields to Account, B2B and IPS
               // updateTargetAccountAdditionalFields(currContact1);
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Contact move request submitted')); 
                page = new PageReference('/'+currContact.Id); 
            }else if(String.isNotEmpty(strStatus)){
                system.debug('strStatuselse - ' + strStatus);
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strStatus));
            }
        } catch(DMLException ex) { //added by sugandha for US79061
            System.debug('excep msg::'+ex.getMessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getdmlMessage(0)));
            Database.rollback(sp);
    } catch(Exception e){
            System.debug('excep msg::'+e.getMessage() + e.getLineNumber() + e.getStackTraceString());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            Database.rollback(sp);
        }
        //return page;
       // return null;
    }
    
    @AuraEnabled
    public static void updateContactOnSave(){
        system.debug('Method Running');
        PageReference page = null;
        String strStatus = '';
        // Added by Ganapati for US436541 - start - to check if account change is already in progress 
        List<Core_IPS_Account_Change_Status__c> accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c = :currContact.Id LIMIT 1];
        if(!accChangeStsLst.isEmpty() && 'In Progress'.equalsIgnoreCase(accChangeStsLst[0].Core_IPS_Status__c)) {
            // return to page if account change is already in progress
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account change for this contact already in Progress. Please try later.'));
            //return page;
        } 
        // Added by Ganapati for US436541 - end
        Savepoint sp = Database.setSavepoint();
        
        //return to page if Any of the validation fails;
        if(!hasValidInputs()){
            //return page;
        }
        
        try{
            
            //----------------  Step 1 : Unselect all the selected entitlements and change the status to pending if keepEntitlements is checked in UI -------------------
            updateContactEntitlementList();
            
            //----------------  Step 2 : Move contacts and Cases-------------------
            //Method filters contact update cases and returns cases that account and assets to be update
            //List<Case> lstMoveAcc = filterCasesAndUpdateContact(); // commented by Ganapati for US436541 - functinality included inline below
            List<Case> lCaseToUpdateContact = new List<Case>(); 
          List<Case> lCaseToUpdateAccount = new List<Case>();
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
            System.debug('lstMoveAcc '+lCaseToUpdateAccount);
            //strStatus = updateAssetsToCase(new Map<Id, Case>(lstMoveAcc), targetAccount.accountId, targetAccountObj, currContact, keepEntitlements);
            strStatus = updateAssetsToCase(lCaseToUpdateContact, lCaseToUpdateAccount, targetAccount.accountId, targetAccountObj, currContact);// Added by Ganapati for US436541 - start

            if(SUCCESS.equalsIgnoreCase(strStatus)){
                Contact currContact1 = [Select Id,Name,Email,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,AccountId,Core_Account_Changeable__c,Core_IPS_Active__c from contact where id =: currContact.id limit 1];
                String OldAccount = currContact1.AccountId != null ? currContact1.AccountId : null;
                currContact1.Core_ERPM_Integration_Status__c = PENDING;
                currContact1.Core_AGS_Integration_Status__c = PENDING;
                currContact1.AccountId = targetAccount.accountId;
                currContact1.Core_Account_Changeable__c= true;
                Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;

                Set<String> contactName = new Set<String>();
                contactName.add(currContact1.Name);

                String Query = 'Select id, Contact__r.name,Account__c, Account__r.name, Is_Approved__c,Is_Rejected__c from Contact_Move_Governance__c where Contact__r.name IN :contactName';
                List<Contact_Move_Governance__c> afterQueryContactMoveGovernace = Database.query(Query);

                boolean isvalid = true;
                For(Contact_Move_Governance__c ContactMoveGovernance :afterQueryContactMoveGovernace){
                    if(ContactMoveGovernance.Contact__r.name == currContact1.name &&  ContactMoveGovernance.Is_Approved__c == false && ContactMoveGovernance.Is_Rejected__c == false){
                        isvalid = false;
                        break;
                    }
                }

                if(isvalid){
                    Contact_Move_Governance__c ContactMoveGovernanceRec = new Contact_Move_Governance__c();
                    ContactMoveGovernanceRec.Old_Account__c = OldAccount;
                    ContactMoveGovernanceRec.Is_Approved__c = false;
                    ContactMoveGovernanceRec.Account__c = targetAccount.accountId;
                    ContactMoveGovernanceRec.Contact__c = currContact1.Id;
                    ContactMoveGovernanceRec.Contact_Name__c = currContact1.Name;
                    ContactMoveGovernanceRec.Contact_Email__c = currContact1.Email;
                    insert ContactMoveGovernanceRec;
                    updateTargetAccountAdditionalFields(currContact1);


                }else{
                    System.debug('isvalid==>'+isvalid);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A request to move the contact is already in progress!'));
                    //return null;
                }
                //update currContact1;

    
                //Update the addtional Fields to Account, B2B and IPS
               // updateTargetAccountAdditionalFields(currContact1);
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Contact move request submitted')); 
                page = new PageReference('/'+currContact.id); 
            }else if(String.isNotEmpty(strStatus)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strStatus));
            }
        } catch(DMLException ex) { //added by sugandha for US79061
            System.debug('excep msg::'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getdmlMessage(0)));
            Database.rollback(sp);
    } catch(Exception e){
            System.debug('excep msg::'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            Database.rollback(sp);
        }
        //return page;
       // return null;
    }
    
    //Set the target accounts additional fields, currently IPS and B2B flags are setting as per the source contact/Account fields
    @TestVisible private static void updateTargetAccountAdditionalFields(Contact curCont ){
        Contact contactref = [SELECT id,accountid,Account.Core_IPS_Active__c,Core_IPS_Active__c FROM Contact where id =: curCont.id limit 1];
        Account acc = new Account();
        //Code to update IPS flag in account if the contact IPS flag is true
        if(curCont.Core_IPS_Active__c == true && contactref.Account.Core_IPS_Active__c == false && keepEntitlements == true && contactref != null ){
            acc.Id = contactref.Accountid;
            acc.Core_IPS_Active__c = true;
        }
        
        //Set the Account.B2b indicator to true if it is false when the current contact B2B indicator is true
        if(currContact.Core_Contact_B2B_Indicator__c == true && targetAccountObj.Core_B2B_Entitlement__c == false && keepEntitlements == true && contactref != null ){
            acc.Id = contactref.Accountid;
            acc.Core_B2B_Entitlement__c = true;
        }
        
        //Update acc Only if IPSFlag or B2B flag is set.
        if(String.isNotBlank(acc.Id)) {
            System.debug('Ankit==>+acc'+acc);
            update acc;
        }   
    }
    
    //Method to update contacts for the cases which are selected to move
    /* Entitle method commented by Ganapati for US436541 - start - functionality included where it get called
     * public List<Case> filterCasesAndUpdateContact(){
        
        List<Case> lCaseToUpdateContact = new List<Case>(); 
        List<Case> lCaseToUpdateAccount = new List<Case>();
        
        //INFO : For Now only updating cases with out project Id's
        for(CaseWrapper cseWOutPrjt : casesWithOUTprojectId){
            if(cseWOutPrjt.keepCase == true && contactLookUp.contactid !=null){
                cseWOutPrjt.cs.contactid = contactLookUp.contactid;
                lCaseToUpdateContact.add(cseWOutPrjt.cs); 
                
            }else if(cseWOutPrjt.keepCase == false){
                lCaseToUpdateAccount.add(cseWOutPrjt.cs);
                
            }
        } 
        
        
        if(lCaseToUpdateContact.size()>0){
            try{
                update lCaseToUpdateContact;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error Occured while filtering Selected cases'));
                System.debug(' Exception >>> '+e.getMessage());
                throw e;
            }
        }
        
        return lCaseToUpdateAccount;
    }*/
    
    public PageReference cancelPage(){
        return new PageReference('/'+currContact.id);
    }
    
    //Unselect all the selected entitlements and change the status to pending if keepEntitlements is checked
    public static void updateContactEntitlementList(){
        
        if(!keepEntitlements){
            List<Core_Contact_Entitlement__c> ceList = [select Id, Name,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_IsActive__c,Core_Status__c,
                                                        Core_Selected__c, Core_Update_Reason__c
                                                        FROM Core_Contact_Entitlement__c 
                                                        WHERE Core_Entitlement_Id__r.Core_IsActive__c = true AND Core_Contact_Id__c  =: currContact.Id
                                                        AND Core_Selected__c = true];
            for(Core_Contact_Entitlement__c ceObject : ceList)
            {
                ceObject.Core_Selected__c = false;
                ceObject.Core_Status__c = PENDING;
                ceObject.Core_Update_Reason__c = UPDATE_REASON_CHANGE_ACCOUNT;
                //ceList.add(ceObject);
            }
            
            //US:US390485 - Dev:Aparna - Description:updating records in future call to overcome 101 Error - Date:26/6/2019
            //update ceList;
            
            string cntEntrecords=JSON.serialize(ceList);
            if(string.isNotblank(cntEntrecords)){
                updateCntEntitlementInFuture(cntEntrecords);
            }
            //End for US390485
        }
    } 
    
    /***********************************************************************************
Version     : 1.0 
Created Date: 26/6/2019
Function    : Future call to overcome 101 Error when changing Account on contact
Input Parameters: List
Output Parameters: None
Number of Queries Within this Method: 0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aparna                    26/6/2019               US390485-Created
***********************************************************************************/
    @future
    public static void updateCntEntitlementInFuture(string strList){
        try {
            List<Core_Contact_Entitlement__c > newCntEntList = (List<Core_Contact_Entitlement__c >)JSON.deserialize(strList, List<Core_Contact_Entitlement__c >.class);
            if(newCntEntList !=null && newCntEntList .size()>0){
                database.update(newCntEntList); 
            } 
        } catch(Exception e){ 
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Contact_Entitlement', 'Core_IPS_MoveContactWithCases_Controller');
            System.debug('Core_IPS_MoveContactWithCases_Controller-->updateCntEntitlementInFuture-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber()); 
        }
    }
    //End for US390485

    //Wrapper class for the IPS projects
    List<Core_IPS_Project_Member__c> ipsProjects = null;
    public List<Core_IPS_Project_Member__c> getIPSProjects(){
        if(ipsProjects == null)
            ipsProjects = [Select Core_IPS_Project__r.Name,  Core_IPS_Contact_Account__c, Core_IPS_Provisioning_Date__c , Core_Selective_Member__c, Core_Status__c, Core_User__c  
                           FROM Core_IPS_Project_Member__c where Core_IPS_Contact__c  = :currContact.Id];
        return ipsProjects;
    }

    //Wrapper Class for the entitlements
    public class EntitlementWrapper{
        public boolean keepEntitlement {get;set;}
        public Core_Contact_Entitlement__c ent {get;set;}
        public EntitlementWrapper( Core_Contact_Entitlement__c cce, Boolean flag){
            keepEntitlement = flag;
            ent = cce;
        }
    }
    
    //Wrapper class for the cases
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
    
    /* This method is to retrive all the assets for the new accounts and assign to the respected cases or creating an asset if requires. */   
    //public static String updateAssetsToCase(List<Case> lstCases, Id accId){ // Commented by Ganapati for US436541
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
}