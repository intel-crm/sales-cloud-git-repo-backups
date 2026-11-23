public with sharing class UCD_ACM_ContactMoveGovernance implements UCD_ACM_ServiceContracts.IContactMoveGovernance  {


    private static UCD_ACM_ServiceContracts.IContactMoveGovernance instance = UCD_ACM_ContactMoveGovernance.getInstance();
      private UCD_ACM_ContactMoveGovernance() {}
  
      public static UCD_ACM_ServiceContracts.IContactMoveGovernance getInstance(){
          if (instance == null) {
              instance = new UCD_ACM_ContactMoveGovernance();
          }
          return instance ;
      }


      private static UCD_ACM_SelectorContracts.IContactQuerySelector contactQuerySelectorInstance = UCD_ACM_ContactQuerySelector.getInstance();
      private static UCD_ACM_DomainContracts.IContactDomain contactDomainInstance = UCD_ACM_ContactDomain.getInstance();

      private static Core_UCD_MoveContactWithCases_Model.initializeWrapper  initializeWrapper = new Core_UCD_MoveContactWithCases_Model.initializeWrapper(); 
      
      private static String contactQueryFields = 'Id,Account.Name,Name,AccountId,Core_IPS_Active__c,FirstName,Account.Core_Export_Compliance_Block__c,Account.Core_Export_Compliance_Block_Reason__c,Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c' ;
      private static String CaseQueryFields = 'id,Product.name,caseNumber,status,Contactid,Core_IPS_Supported_Product__r.Name,Contact.Name, 	contact.Accountid,Core_IPS_Product_Org1__r.Name,Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c,Core_IPS_GEC_Case__c, Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name ';
      private static String assetQuery = 'Select Id, Name, Core_IPS_Asset__c, Core_IPS_Project__c, Core_IPS_Project_Name__c, AccountId, Product2Id, InstallDate, UsageEndDate, Status FROM  Asset ';
      private static String entitlementQueryFields = 'Name , Core_Contact_Id__c, Core_Engagement_Tier__c, Core_Entitlement_Id__c, Core_From_Source__c,Core_Selected__c,Core_Entitlement_Id__r.Core_Display_Name__c,  Core_Contact_Id__r.Name, Core_Type__c' ;
      private static String accountQueryFields = 'Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_CIM_ID__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.UserRole.Name, Core_PSG_Account__c';
      private static String contactMoveGovQueryFields = 'Id, Contact__r.name,Account__c, Account__r.name, Is_Approved__c,Is_Rejected__c';

    public static Core_UCD_MoveContactWithCases_Model.initializeWrapper getCurrContactDetails(String contactId){
					
        List<Contact>  contactDetails = contactQuerySelectorInstance.getCurrContactDetails(contactId, contactQueryFields);
        initializeWrapper.currContact = contactDetails;
        
        initializeWrapper = getCases(contactDetails[0], initializeWrapper);
        initializeWrapper = getAsset(initializeWrapper);
        
        initializeWrapper = getEntitlements( initializeWrapper);
        
        return initializeWrapper;
        
    }

    public static Core_UCD_MoveContactWithCases_Model.initializeWrapper getCases(Contact contactData, Core_UCD_MoveContactWithCases_Model.initializeWrapper initializeWrapper){
	
        
        List<Case>  caseDetails = contactQuerySelectorInstance.getCaseDetails(contactData.Id, CaseQueryFields);
        
        initializeWrapper = contactDomainInstance.GECCaseValidation(caseDetails, initializeWrapper);
        
        initializeWrapper.caseDetails = caseDetails ;
        return initializeWrapper;
       
    }

    public static Core_UCD_MoveContactWithCases_Model.initializeWrapper getAsset( Core_UCD_MoveContactWithCases_Model.initializeWrapper initializeWrapper){
        List<Core_UCD_MoveContactWithCases_Model.CaseWrapper> casesWithProjectId = new List<Core_UCD_MoveContactWithCases_Model.CaseWrapper>();
        List<Core_UCD_MoveContactWithCases_Model.CaseWrapper> casesWithOUTprojectId = new List<Core_UCD_MoveContactWithCases_Model.CaseWrapper>();
        Set<Id> assetIdsWithProject = new Set<Id>();
        Set<Id> assetIdsWithOutProject = new Set<Id>();

        for(Case caseDetail :initializeWrapper.caseDetails){
            if(caseDetail.Core_IPS_Project_Case__c != null){
                casesWithProjectId.add(new Core_UCD_MoveContactWithCases_Model.CaseWrapper(caseDetail, false)); 
                assetIdsWithProject.add(caseDetail.AssetId);
            }else {
                casesWithOUTprojectId.add(new Core_UCD_MoveContactWithCases_Model.CaseWrapper(caseDetail, false));
                assetIdsWithOutProject.add(caseDetail.AssetId);
            }
        }
        initializeWrapper.casesWithProjectId = casesWithProjectId;
        initializeWrapper.casesWithOUTprojectId = casesWithOUTprojectId;
        
            
            List<Core_UCD_MoveContactWithCases_Model.AssetWrapper> assetWithProjectIdFitered = new List<Core_UCD_MoveContactWithCases_Model.AssetWrapper>();
            List<Core_UCD_MoveContactWithCases_Model.AssetWrapper> assetWithOUTprojectIdFitered = new List<Core_UCD_MoveContactWithCases_Model.AssetWrapper>();        
            List<Asset> assetWithOUTprojectId = new List<Asset>();
            List<Asset> assetWithProjectId = new List<Asset>();
            
    
            String whereClause = 'WHERE id =: assetIdsWithProject' ;
        
            Set<Id> setPids = new Set<Id>();
            for(Asset a : contactQuerySelectorInstance.assetDetails(assetQuery, whereClause)){
                assetWithProjectId.add(a);
                setPids.add(a.Product2Id);
            }
            
            whereClause = 'where Accountid =: AcctId AND Product2Id =: setPids' ;
            
            if(String.isNotBlank(initializeWrapper.currContact != null ? initializeWrapper.currContact[0].AccountId : null)){
                for(Asset a : contactQuerySelectorInstance.assetDetails(assetQuery, whereClause)){
                    assetWithProjectIdFitered.add(new Core_UCD_MoveContactWithCases_Model.AssetWrapper(a, initializeWrapper.currContact[0].AccountId ));                
                }
            }  
            
            Set<Id> setPids2 = new Set<Id>();
            whereClause = 'where id =: assetIdsWithOutProject' ;
            for(Asset a : contactQuerySelectorInstance.assetDetails(assetQuery, whereClause)){
                assetWithOUTprojectId.add(a);
                setPids2.add(a.Product2Id);
            }
            
            whereClause = 'where Accountid =: AcctId AND Product2Id =: setPids2' ;
            if(String.isNotBlank(initializeWrapper.currContact != null ? initializeWrapper.currContact[0].AccountId : null)){
                for(Asset a : contactQuerySelectorInstance.assetDetails(assetQuery, whereClause)){
                    assetWithOUTprojectIdFitered.add(new Core_UCD_MoveContactWithCases_Model.AssetWrapper(a,initializeWrapper.currContact[0].AccountId ));                
                }
            }
                    
        return initializeWrapper;
    }

    public static Core_UCD_MoveContactWithCases_Model.initializeWrapper getEntitlements( Core_UCD_MoveContactWithCases_Model.initializeWrapper initializeWrapper){
        List<Core_UCD_MoveContactWithCases_Model.EntitlementWrapper> entitlements = new List<Core_UCD_MoveContactWithCases_Model.EntitlementWrapper>();

        for(Core_Contact_Entitlement__c cce : contactQuerySelectorInstance.getEntitlementsDetails(initializeWrapper.currContact[0].Id, entitlementQueryFields))
        {
            entitlements.add(new Core_UCD_MoveContactWithCases_Model.EntitlementWrapper(cce, false));   
            if(cce.Core_Selected__c == true)
                initializeWrapper.hasSelectedEntitlements = true;
        }

        boolean noEntitlements = ((entitlements != null && entitlements.size() == 0) || entitlements == null || initializeWrapper.hasSelectedEntitlements == false);
        boolean noCases = ((initializeWrapper.casesWithOUTprojectId != null && initializeWrapper.casesWithOUTprojectId.size() == 0) || initializeWrapper.casesWithOUTprojectId == null );

        if(noEntitlements && noCases){
            initializeWrapper.hasAccessToAcctSelection = Schema.sObjectType.Contact.isUpdateable() ;
        }else if(!noEntitlements || !noCases){
            if(initializeWrapper.userAuthorized == true){
                initializeWrapper.hasAccessToAcctSelection = true;
            }else{
                initializeWrapper.hasAccessToAcctSelection = false;
            }
        }
        return initializeWrapper;
    }

    public static Core_UCD_MoveContactWithCases_Model.ResponseModel caseUpdate(){
        Core_UCD_MoveContactWithCases_Model.ResponseModel responseModel = new Core_UCD_MoveContactWithCases_Model.ResponseModel();
        responseModel = hasValidInputs(initializeWrapper);
	    return responseModel;
    }

    
    private static Core_UCD_MoveContactWithCases_Model.ResponseModel hasValidInputs(Core_UCD_MoveContactWithCases_Model.initializeWrapper initializeWrapper){
       /* List<Core_IPS_Account_Change_Status__c> accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c = :currContact.Id LIMIT 1];
        if(!accChangeStsLst.isEmpty() && 'In Progress'.equalsIgnoreCase(accChangeStsLst[0].Core_IPS_Status__c)) {
            // return to page if account change is already in progress
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account change for this contact already in Progress. Please try later.'));
            return page;
        }*/ 

        List<Contact_Move_Governance__c> contactMoveGovDetails = contactQuerySelectorInstance.getContactMoveGovDetails(initializeWrapper.currContact[0].Id , contactMoveGovQueryFields);

        //Account tg = null;
        
        Core_UCD_MoveContactWithCases_Model.ResponseModel responseModel = new Core_UCD_MoveContactWithCases_Model.ResponseModel();

        if(initializeWrapper.currContact[0].AccountId == initializeWrapper.targetAccount.AccountId){
            responseModel.IsError = true;
            responseModel.errorMessage = 'Current account and target account is same.';
            return responseModel;
        }
        
        
        //1. Validate GEC Cases.
        if(initializeWrapper.gecCaseFound){
            responseModel.IsError = true;
            responseModel.errorMessage = ' GEC Cases Found, moving contact and Entitlements is not allowed.';
            return responseModel;
        }
        
        Account targetAccountObj = null;

        //Fetch all the target Account fields for further validations
        targetAccountObj = targetAccountObj == null ? contactQuerySelectorInstance.getTargetAccountObj(initializeWrapper.targetAccount.AccountId, accountQueryFields) : null ;
        
        //Query targetAccount fields for validations
        if(targetAccountObj == null){
            responseModel.IsError = true;
            responseModel.errorMessage = ' Account : INVALID ACCOUNT.';
            return responseModel;
        }
        
        if(targetAccountObj.Core_PSG_Account__c == false && initializeWrapper.currContact[0].Account.Core_PSG_Account__c ==true && !initializeWrapper.displayPopUp){
            initializeWrapper.moveAccoutWarningMessage= System.Label.Core_IPS_Move_AccWarning_Message;
            if(!initializeWrapper.displayPopUp){
                initializeWrapper.displayPopUp = true;   
                responseModel.IsError = true;
                responseModel.errorMessage = System.Label.Core_IPS_Move_AccWarning_Message;

            }  
            return responseModel;
        }
        
        //Validate source and targert are of same ODM Type
        if(targetAccountObj.Core_IsODM__c != initializeWrapper.currContact[0].Account.Core_IsODM__c && initializeWrapper.keepEntitlements == true){
            responseModel.IsError = true;
            responseModel.errorMessage = 'Keep Entitlements is not allowed when moving contact from a standard account to an ODM account or from an ODM account to standard account';
            return responseModel;
        }
        
        if(String.isBlank(targetAccountObj.Core_CNDA_Number__c)  && initializeWrapper.keepEntitlements == true && targetAccountObj.Core_PSG_Account__c != true){
            responseModel.IsError = true;
            responseModel.errorMessage = 'CNDA must be filled manually by the user on the Account record : '+targetAccountObj.Name ;
            return responseModel;
        }
        
        if(String.isBlank(targetAccountObj.Core_CIM_ID__c)  && initializeWrapper.keepEntitlements == true ){
            responseModel.IsError = true;
            responseModel.errorMessage = 'CIM ID must be filled manually by the user on the Account record : '+targetAccountObj.Name ;
            return responseModel;
        }
        
        if(String.isBlank(targetAccountObj.Core_English_Only_Name__c) && initializeWrapper.keepEntitlements == true ){
            responseModel.IsError = true;
            responseModel.errorMessage = 'English Only Name must be filled manually by the user on the Account record : '+targetAccountObj.Name ;
            return responseModel;
        }
        
        if(initializeWrapper.currContact[0].Account.Core_Export_Compliance_Block__c == true){
            responseModel.IsError = true;
            responseModel.errorMessage = ' Account :'+initializeWrapper.currContact[0].Account.Name+' is on  GEC Hold ' ;
            return responseModel;
        }
        
        //Do not process if target account or current Acccount has GEC on Hold Validation
        if(targetAccountObj.Core_Export_Compliance_Block__c == true){
            responseModel.IsError = true;
            responseModel.errorMessage = ' Account :'+targetAccountObj.Name+' is on  GEC Hold ' ;
            return responseModel;
        }
        
        
        // Validate target Account's owner has a role setup
        if(targetAccountObj.Core_IPS_Active__c == true  && initializeWrapper.keepEntitlements == true && String.isBlank(targetAccountObj.Owner.UserRole.Name)){
            responseModel.IsError = true;
            responseModel.errorMessage = 'Please contact IT Support to have them manually set the UserRole to Account :'+targetAccountObj.Name+'\'s Owner :' ;
            return responseModel;
        }
        return responseModel;
    }
}