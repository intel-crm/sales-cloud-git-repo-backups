/**************************************************************************************
Apex Class Name: Core_IPS_MoveContactWithLargeCases  
Version     : 1.0 
Created Date: Dec 2016
Description : For moving the contact from one account to another account along with the cases and entitlements
*************************************************************************************/
public without sharing class  Core_IPS_MoveContactWithLargeCases {
    private static final String PENDING = 'Pending';
    private static final String CLOSED = 'Closed';
    private static final String SUCCESS = 'Success';
    public Static Boolean failedBatch{get;set;}    
    private static final String UPDATE_REASON_CHANGE_ACCOUNT = 'Change Account';
    public static List<Case> allCaseList;
    public transient List<Asset> assetWithProjectId {get;set;}
    public transient List<Asset> assetWithOUTprojectId {get;set;}
    public static Boolean startBatch=false;
    public static String currAcc='';
    public Contact currContact1;
    public List<Contact> currcontactLookup;
    public Contact contactref;
    Map<id,Core_Contact_Entitlement__c> ceMap; 
  
    public boolean hasSelectedEntitlements {get;set;}
    
    //Current session contact Object
    public Contact currContact {get;set;}
    
    //target account where the contact is getting moved
    public Contact targetAccount {get;set;}
    
    private final Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
    
    public transient List<AssetWrapper> assetWithProjectIdFitered {get;set;}
    public transient  List<AssetWrapper> assetWithOUTprojectIdFitered {get;set;}
    
    //Check if the running User is authorized to performa the operation
    public Boolean userAuthorized;
    public Boolean displayPopUp{get;set;}
    public Boolean hidePoppup = false;
    public String moveAccoutWarningMessage{get;set;}
    //All the entitlements for the contact
    public List<EntitlementWrapper> entitlements {set; get{
        for(EntitlementWrapper k : entitlements){
            k.keepEntitlement  = keepEntitlements;
        }
        return entitlements;
    }}
    
    //target contact to keep the cases
    public Case contactLookUp {get;set;}
    public Id onloadAccount;
    public boolean hasAccessToAcctSelection {get;set;}
    public boolean gecCaseFound {get;set;}
    
    public boolean keepCases {get;set;}
    public boolean keepEntitlements {get;set;}
    
    public String errorMsg {get;set;}
    //Total cases 
    public List<Case> contactCases {get;set;}
    
    //Target Account to which the contact is getting moved to 
    @TestVisible private Account targetAccountObj = null;
    
    //Query all the target Account fields for validations
    private Account getTargetAccountObj(){
        if(targetAccount.AccountId != null){
            try{
                targetAccountObj = [select Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_CIM_ID__c,Core_Business_Party_Id__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , 
                                    Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.UserRole.Name, Core_PSG_Account__c
                                    FROM Account where ID =:targetAccount.AccountId Limit 1];
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Account : INVALID ACCOUNT ')); // '+tg.Name+' removed by prem
            }
        }
        
        return targetAccountObj;
        
    }
    //List of Cases which associated with IPS Project
    public List<CaseWrapper> casesWithProjectId {set; get{
        if( (casesWithProjectId != null && casesWithProjectId.size() > 0) || hasSelectedEntitlements == true ){
            if(!hasAccessToAcctSelection){
                errorMsg =  'Only Data Ops can move Contacts from one '+
                    'Account to another if there is any Selected Entitlements and/or IPS Cases. To request these movements please file an '+
                    '<a href ='+Label.Core_Change_Account_Ask_A_Question+'>Ask A Question</a>.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,errorMsg));
                
            }
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Note that if Cases or Accounts are on GEC hold then no movement can happen. '));
        return casesWithProjectId;
    }}
    public Integer caseCount {get;set;}  
    //List of Cases with Out  IPS Project    
    public List<CaseWrapper> casesWithOUTprojectId {set; get{
        
        for(CaseWrapper c : casesWithOUTprojectId){
            //if(keepCases == true && c.keepCase == false )
                c.keepCase  = keepCases;
        }
        caseCount   = casesWithOUTprojectId.size();
        return casesWithOUTprojectId;
    }}
    
    //Method initializes all the variables.
    public void initialize(){
        targetAccountObj = null;
        gecCaseFound = false;
        hasAccessToAcctSelection = true;
        keepCases = false;
        keepEntitlements = false;
        contactLookUp = new Case();
        //FLS Check Added - Yasasvi
        if(Case.SObjectType.getDescribe().isAccessible()){
          contactLookUp.Id = [select Id from Case Limit 1].Id;
        }
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
    public Core_IPS_MoveContactWithLargeCases(ApexPages.standardcontroller controller){
       
        try{
            initialize();
            //FLS Check Added - Yasasvi
            if(Contact.SObjectType.getDescribe().isAccessible()){
            currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                           Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                           Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                           Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                           From Contact Where id =: controller.getId() limit 1];  
            }
            onloadAccount = currContact.Accountid;
           
            //Retrieve Cases
            getCases();
           
            //Retrieve Entitlements
            retrieveEntitlements();
           
            
        }catch(Exception e){
            currContact = null;
        }
    }
    
    //Retrieve the Entitlements associated with the selected contact for displaying in UI
    public PageReference retrieveEntitlements(){
         Map<id,Core_Contact_Entitlement__c> contactEntitlementMap;
        entitlements = new List<EntitlementWrapper>();
        //FLS Check Added - Yasasvi
        if(Core_Contact_Entitlement__c.SObjectType.getDescribe().isAccessible()){
        contactEntitlementMap= new Map<id,Core_Contact_Entitlement__c>([SELECT Name , Core_Contact_Id__c, Core_Engagement_Tier__c, Core_Entitlement_Id__c, Core_From_Source__c,   
                                               Core_Selected__c,Core_Entitlement_Id__r.Core_Display_Name__c,  Core_Contact_Id__r.Name, Core_Type__c 
                                               FROM Core_Contact_Entitlement__c 
                                               WHERE Core_Contact_Id__c =: currContact.Id AND Core_Entitlement_Id__r.Core_IsActive__c = true limit 10000]);
            }
        for(Core_Contact_Entitlement__c cce : contactEntitlementMap.values())
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
    public void getCases(){
        final String AcctId = currContact != null ? currContact.AccountId : null;
        Map<id,Case> caseMap;
        casesWithProjectId = new List<CaseWrapper>();
        casesWithOUTprojectId = new List<CaseWrapper>();
        Set<Id> assetIdsWithProject = new Set<Id>();
        Set<Id> assetIdsWithOutProject = new Set<Id>();
        assetWithProjectIdFitered = new List<AssetWrapper>();
        assetWithOUTprojectIdFitered = new List<AssetWrapper>();        
        assetWithOUTprojectId = new List<Asset>();
        assetWithProjectId = new List<Asset>();
        //FLS Check Added - Yasasvi
        if(Case.SObjectType.getDescribe().isAccessible()){
               caseMap=new Map<id,Case>([Select id,Product.name,caseNumber,status,Contactid,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,
                      Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c, 
                      Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, 
                      Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name 
                      FROM Case  
                      Where contactId =: currContact.Id AND RecordType.Name != 'CEP Case' limit 10000 ]);
        }
        for(Case c:  caseMap.values())
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
        Map<id,Asset> assetWithProjectList=new Map<id,Asset>((List<Asset>)DataBase.query(ASSET_QUERY+ '  WHERE id =: assetIdsWithProject'));
        for(Asset a : assetWithProjectList.values()){
            assetWithProjectId.add(a);
            setPids.add(a.Product2Id);
        }
        
        if(String.isNotBlank(AcctId)){
            Map<id,Asset>  assetWithAccountProjectList=new Map<id,Asset> ((List<Asset>)DataBase.query(ASSET_QUERY+ '  where Accountid =: AcctId AND Product2Id =: setPids '));
            for(Asset a : assetWithAccountProjectList.values()){
                assetWithProjectIdFitered.add(new AssetWrapper(a,AcctId));                
            }
        }  
        
        setPids.clear();
        Map<id,Asset> assetWithoutProjectList=new Map<id,asset>((List<Asset>)DataBase.query(ASSET_QUERY+ '  where id =: assetIdsWithOutProject'));
        for(Asset a : assetWithoutProjectList.values()){
            assetWithOUTprojectId.add(a);
            setPids.add(a.Product2Id);
        }
        
        if(String.isNotBlank(AcctId)){
            Map<id,Asset> assetWithoutAccountProjectFilteredList= new Map<id,Asset>((List<Asset>)DataBase.query(ASSET_QUERY+ '  where Accountid =: AcctId AND Product2Id =: setPids ') );
            for(Asset a : assetWithoutAccountProjectFilteredList.values()){
                assetWithOUTprojectIdFitered.add(new AssetWrapper(a,AcctId));                
            }
        }
        

        
        //return null;
    }
    
    // @return true - if all the inputs are valid for processing.
    // @return false - if one or more inputs are InValid.
    @TestVisible private boolean hasValidInputs(){
        
        boolean flag = false;
        failedBatch=false;
        startBatch =false;
        //Account tg = null;
          

        if(currContact.AccountId == targetAccount.AccountId){
            AggregateResult[] groupedResults=[Select count(id) FROM Case Where contactId =: currContact.Id And Accountid !=: currContact.AccountId AND RecordType.Name != 'CEP Case' AND Core_IPS_Project_Case__c =null];
            if(groupedResults[0].get('expr0')==0){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Current account and target account is same.'));
                 return flag;
            }
            failedBatch=true;
        }
        
        
        //1. Validate GEC Cases.
        if(gecCaseFound){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' GEC Cases Found, moving contact and Entitlements is not allowed.'));
            return flag;
        }
        
        //Fetch all the target Account fields for further validations
        getTargetAccountObj();
        
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
        
        //code modified as per US120420
        List<String> listOfInvalidCNDANum = (Label.Core_IPS_Invalid_CNDA).split(';');
    
        if((String.isBlank(targetAccountObj.Core_CNDA_Number__c) || listOfInvalidCNDANum.contains(targetAccountObj.Core_CNDA_Number__c))  && keepEntitlements == true && targetAccountObj.Core_PSG_Account__c != true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CNDA must be filled manually by the user on the Account record : '+targetAccountObj.Name));
            return flag;
        }
        
        /*if(String.isBlank(targetAccountObj.Core_CIM_ID__c)  && keepEntitlements == true ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CIM ID must be filled manually by the user on the Account record : '+targetAccountObj.Name));
            return flag;
        }*/
        
        if(String.isBlank(targetAccountObj.Core_Business_Party_Id__c)  && keepEntitlements == true ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unified Id must be filled manually by the user on the Account record : '+targetAccountObj.Name));
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
        PageReference pageRef = new PageReference('/apex/Core_IPS_MoveContactWithLargeCases?Id='+currContact.id );
        pageRef.setRedirect(true);
        return pageRef;
        //targetAccount.AccountId= NULL;
    }
    
    public pageReference moveAccountchange(){
        hidePoppup= true;
        PageReference page=updateCasesOnSave();
        hidePoppup= false;
        displayPopUp = false;
        return page;
    }
    
    //Method to update Accounts and Move Cases to New Account
    
    public PageReference updateCasesOnSave(){
        PageReference page = null;
        String strStatus = '';
        
        Savepoint sp = Database.setSavepoint();
        allCaseList=new List<Case>();
           
        try{
             //return to page if Any of the validation fails;
            if(!hasValidInputs())
                return page;
          
            
            //----------------  Step 1 : Unselect all the selected entitlements and change the status to pending if keepEntitlements is checked in UI -------------------
            updateContactEntitlementList();
        
            //----------------  Step 2 : Move contacts and Cases-------------------
            //Method filters contact update cases and returns cases that account and assets to be update
            List<Case> lstMoveAcc = filterCasesAndUpdateContact();
            
        
            //Step 3: Method update account and assets to the cases and returns success or error message
            strStatus = updateAssetsToCase( lstMoveAcc, targetAccount.accountId);
               
            
            if(SUCCESS.equalsIgnoreCase(strStatus)){
                //FLS Check Added - Yasasvi
                if(Contact.SObjectType.getDescribe().isAccessible()){
                currContact1 = [Select Id,Name,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,AccountId,Core_Account_Changeable__c,Core_IPS_Active__c from contact where id =: currContact.id limit 1];
                }
                    /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Contact.fields.Core_ERPM_Integration_Status__c.isUpdateable()) {
                currContact1.Core_ERPM_Integration_Status__c = PENDING;
                //}
                //if (Schema.sObjectType.Contact.fields.Core_AGS_Integration_Status__c.isUpdateable()) {
                currContact1.Core_AGS_Integration_Status__c = PENDING;
                //}
                //if (Schema.sObjectType.Contact.fields.AccountId.isUpdateable()) {
                currContact1.AccountId = targetAccount.accountId;
                //}
                //if (Schema.sObjectType.Contact.fields.Core_Account_Changeable__c.isUpdateable()) {
                currContact1.Core_Account_Changeable__c= true;
                //}
                
                Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;
                update currContact1;
                //Update the addtional Fields to Account, B2B and IPS
                updateTargetAccountAdditionalFields(currContact1);
                // Changed as per US125042 //
                // FLS Check Added - Yasasvi
                if(Contact.SObjectType.getDescribe().isAccessible()){
                     currcontactLookup = [Select Id,Name from contact where id =: contactLookUp.contactid limit 1];
                }
                    if(currcontactLookup.size()>0 )
                   page =  new PageReference('/apex/Core_IPS_Move_Contact_Sucess_Message?id='+currContact.id+'&startBatch='+startBatch+'&currAcc='+EncodingUtil.urlEncode(currContact.account.name, 'UTF-8')+'&currcontact='+EncodingUtil.urlEncode(currcontactLookup[0].name, 'UTF-8'));  
                else
                   page =  new PageReference('/apex/Core_IPS_Move_Contact_Sucess_Message?id='+currContact.id+'&startBatch='+startBatch+'&currAcc='+EncodingUtil.urlEncode(currContact.account.name, 'UTF-8'));  
                page.setRedirect(true);
                
            }else if(String.isNotEmpty(strStatus)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strStatus));
            }
        }
        //added by sugandha for US79061
        Catch(DMLException ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getdmlMessage(0)));
            Database.rollback(sp);
            allCaseList=new List<Case>();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            Database.rollback(sp);
            allCaseList=new List<Case>();
        }
        // Updating Case from Batch DE38348 CPU Time Limit By Prem Ranjan 
        if(allCaseList.size()>0 ){
            startBatch=true;
            allCaseList=new List<Case>();
            Core_IPS_MoveContactWithBatch contactBatch = new Core_IPS_MoveContactWithBatch(currContact,targetAccount);
            contactBatch.failedCase=failedBatch;
            database.executeBatch(contactBatch,Integer.valueOf(Label.Core_IPS_MoveContactBatchLimit));
            // Changed as per US125042 //
            page =  new PageReference('/apex/Core_IPS_Move_Contact_Sucess_Message?id='+currContact.id+'&startBatch='+startBatch+'&currAcc='+EncodingUtil.urlEncode(currContact.account.name, 'UTF-8')+'&currcontact=null'); 
            page.setRedirect(true);
        }
        return page;
    }
    
    //Set the target accounts additional fields, currently IPS and B2B flags are setting as per the source contact/Account fields
    @TestVisible private void updateTargetAccountAdditionalFields(Contact curCont ){
        //FLS Check Added - Yasasvi
        if(Contact.SObjectType.getDescribe().isAccessible()){
         contactref = [SELECT id,accountid,Account.Core_IPS_Active__c,Core_IPS_Active__c FROM Contact where id =: curCont.id limit 1];
        }
            Account acc = new Account();
        //Code to update IPS flag in account if the contact IPS flag is true
        if(curCont.Core_IPS_Active__c == true && contactref.Account.Core_IPS_Active__c == false && keepEntitlements == true && contactref != null ){
            acc.Id = contactref.Accountid;
            //if (Schema.sObjectType.Account.fields.Core_IPS_Active__c.isUpdateable()) {
            acc.Core_IPS_Active__c = true;
            //}
        }
        
        //Set the Account.B2b indicator to true if it is false when the current contact B2B indicator is true
        if(currContact.Core_Contact_B2B_Indicator__c == true && targetAccountObj.Core_B2B_Entitlement__c == false && keepEntitlements == true && contactref != null ){
            //if (Schema.sObjectType.Account.fields.Id.isUpdateable()) {
            acc.Id = contactref.Accountid;
            //}
            //if (Schema.sObjectType.Account.fields.Core_B2B_Entitlement__c.isUpdateable()) {
            acc.Core_B2B_Entitlement__c = true;
            //}
        }
        
        //Update acc Only if IPSFlag or B2B flag is set.
        if(String.isNotBlank(acc.Id))
            update acc;
    }
        
    //Method to update contacts for the cases which are selected to move
    public List<Case> filterCasesAndUpdateContact(){
        
       
         PageReference page = null;
        List<Case> lCaseToUpdateContact = new List<Case>(); 
        List<Case> lCaseToUpdateAccount = new List<Case>();
        
        //INFO : For Now only updating cases with out project Id's
        for(CaseWrapper cseWOutPrjt : casesWithOUTprojectId){
            if(cseWOutPrjt.keepCase == true && contactLookUp.contactid !=null){
                cseWOutPrjt.cs.contactid = contactLookUp.contactid;
              //  if(cseWOutPrjt.cs.status =='new')
                    lCaseToUpdateContact.add(cseWOutPrjt.cs); 
                
            }else if(cseWOutPrjt.keepCase == false){
             //    if(cseWOutPrjt.cs.status =='new')
                    lCaseToUpdateAccount.add(cseWOutPrjt.cs); 
            }
        } 
        //code modified as per US120420
        if(lCaseToUpdateContact.size()>0){
            startBatch=true;
            lCaseToUpdateContact = new List<Case>();
            Core_IPS_MoveContactWithBatch contactBatch = new Core_IPS_MoveContactWithBatch(currContact,targetAccount,contactLookUp.contactid);
            contactBatch.failedCase=failedBatch;
            database.executeBatch(contactBatch,Integer.valueOf(Label.Core_IPS_MoveContactBatchLimit));
        }
        return lCaseToUpdateAccount;
    }
    
    public PageReference cancelPage(){
        return new PageReference('/'+currContact.id);
    }
    
    //Unselect all the selected entitlements and change the status to pending if keepEntitlements is checked
    public void updateContactEntitlementList(){
        
        if(!keepEntitlements){
            //FLS Check Added - Yasasvi
            if(Core_Contact_Entitlement__c.SObjectType.getDescribe().isAccessible()){
                ceMap = new Map<id,Core_Contact_Entitlement__c>([select Id, Name,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_IsActive__c,Core_Status__c,
                                                                 Core_Selected__c, Core_Update_Reason__c
                                                                 FROM Core_Contact_Entitlement__c 
                                                                 WHERE Core_Entitlement_Id__r.Core_IsActive__c = true AND Core_Contact_Id__c  =: currContact.Id
                                                                 AND Core_Selected__c = true limit 10000]);
                
                for(Core_Contact_Entitlement__c ceObject : ceMap.values())
                {
                    ceObject.Core_Selected__c = false;
                    ceObject.Core_Status__c = PENDING;
                    ceObject.Core_Update_Reason__c = UPDATE_REASON_CHANGE_ACCOUNT;
                    ceObject.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                    //ceList.add(ceObject);
                }
                update ceMap.values();
            }
        }
    }    
    //Wrapper class for the IPS projects
    List<Core_IPS_Project_Member__c> ipsProjects = null;
    public List<Core_IPS_Project_Member__c> getIPSProjects(){
        if(ipsProjects == null)
            //FLS Check Added - Yasasvi
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
            ipsProjects = [Select Core_IPS_Project__r.Name,  Core_IPS_Contact_Account__c, Core_IPS_Provisioning_Date__c , Core_Selective_Member__c, Core_Status__c, Core_User__c  
                           FROM Core_IPS_Project_Member__c where Core_IPS_Contact__c  = :currContact.Id limit 10000];
            }
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
    public static String updateAssetsToCase(List<Case> lstCases, Id accId){
        Map<Id,Id> mapConIdTobe = new Map<Id,id>();
        String strReturn;
        List<Asset> lstCreateAsset = new List<Asset>();
        List<Case> lstUpdateCase = new List<Case>();
        List<Asset> lstAssetsForNewAcc = new List<Asset>();
        Map<String,Asset> mapAsset = new Map<String,Asset>();
        List<Case> lstCaseForReupdate = new List<Case>();
        List<Core_IPS_Account__c> lstIPSAccounts = new List<Core_IPS_Account__c>();
        Set<String> stTobeUpdatedAsset = new Set<String>();
        Id assetPublicRecordId=schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Public Product').getRecordTypeId();
        //FLS Check Added - Yasasvi
        if(Asset.SObjectType.getDescribe().isAccessible()){
            lstAssetsForNewAcc = [SELECT id,Core_IPS_Project__c,Core_Product_Organization__c,Core_Supported_Product__c,Accountid FROM Asset WHERE Accountid = : accId limit 10000];
        }
        
        for(Asset objAssetRef : lstAssetsForNewAcc){
            if(objAssetRef.Accountid != null) {
                mapAsset.put(string.valueof(objAssetRef.Accountid) + string.valueof(objAssetRef.Core_Product_Organization__c)  +  string.valueof(objAssetRef.Core_Supported_Product__c),objAssetRef);
            }
        }
        
        
        for(Case objCaseRef : lstCases){
            
            objCaseRef.AccountId = accId;
            
            if(objCaseRef.Core_IPS_Project_Case__c == null && objCaseRef.AccountID != null && objCaseRef.Core_IPS_Product_Org1__c !=null && objCaseRef.Core_IPS_Supported_Product__c!= null && objCaseRef.Asset.recordtypeid!=assetPublicRecordId){
                string strKey_Asset = string.valueof(objCaseRef.AccountID) + string.valueof(objCaseRef.Core_IPS_Product_Org1__c)  +  string.valueof(objCaseRef.Core_IPS_Supported_Product__c) ;
                
                if(!mapAsset.isEmpty() && mapAsset.containsKey(strKey_Asset)){
                    objCaseRef.AssetId = mapAsset.get(strKey_Asset).id;  
                    lstUpdateCase.add(objCaseRef);
                }else{
                    if(objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c!=null && !stTobeUpdatedAsset.contains(strKey_Asset)){
                        Asset objAsset = new Asset();
                        /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
                        if (Schema.sObjectType.Asset.fields.Name.isCreateable()) {
                        objAsset.Name = objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c;
                        }
                        //if (Schema.sObjectType.Asset.fields.Product2Id.isCreateable()) {
                        objAsset.Product2Id=objCaseRef.Core_IPS_Supported_Product__r.Core_Product__c;
                        //}
                       // if (Schema.sObjectType.Asset.fields.Core_IPS_Asset__c.isCreateable()) {
                        objAsset.Core_IPS_Asset__c=true;
                        //}
                       // if (Schema.sObjectType.Asset.fields.core_alias__c.isCreateable()) {
                        objAsset.core_alias__c=objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c;
                        //}
                        //if (Schema.sObjectType.Asset.fields.recordtypeid.isCreateable()) {
                        objAsset.recordtypeid = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
                        //}
                        //if (Schema.sObjectType.Asset.fields.AccountId.isCreateable()) {
                        objAsset.AccountId = objCaseRef.AccountId;
                        //}
                        //if (Schema.sObjectType.Asset.fields.Core_Product_Organization__c.isCreateable()) {
                        objAsset.Core_Product_Organization__c = objCaseRef.Core_IPS_Product_Org1__c;
                        //}
                       // if (Schema.sObjectType.Asset.fields.Core_Supported_Product__c.isCreateable()) {
                        objAsset.Core_Supported_Product__c = objCaseRef.Core_IPS_Supported_Product__c;
                        //}
                        //if (Schema.sObjectType.Asset.fields.Status.isCreateable()) {
                        objAsset.Status = 'Inactive';
                        //}
                       // if (Schema.sObjectType.Asset.fields.InstallDate.isCreateable()) {
                        objAsset.InstallDate = system.today()-1;
                       //}
                       //if (Schema.sObjectType.Asset.fields.UsageEndDate.isCreateable()) {
                        objAsset.UsageEndDate = system.today();
                       //}
                        
                        lstCreateAsset.add(objAsset);
                        stTobeUpdatedAsset.add(strKey_Asset);
                    }
                    lstCaseForReupdate.add(objCaseRef);
                }
                
            }else if(objCaseRef.Asset.recordtypeid==assetPublicRecordId){
                lstUpdateCase.add(objCaseRef);
            }
            
        }
        try{
            if(lstUpdateCase.size()>0){
                allCaseList.addAll(lstUpdateCase);
            //update lstUpdateCase;  
            }
            if(lstCreateAsset.size()>0){
                insert lstCreateAsset; 
                if(lstCaseForReupdate.size()>0){
                    updateAssetsToCase(lstCaseForReupdate,accId);
                }
            }
            strReturn = SUCCESS;
        }catch(Exception e){
            strReturn = e.getMessage();
            throw e;
        }
        return strReturn;
    }
}