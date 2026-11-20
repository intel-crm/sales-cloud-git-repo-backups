/***************************************************************************************************
* Apex Class Name : Core_IPS_CaseCreateLWCController
* Test Class Name : Core_IPS_CaseCreateLWCControllerTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prasad                                              Created
****************************************************************************************************/

public with sharing class Core_IPS_CaseCreateLWCController {
    static Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();
    
    @AuraEnabled(cacheable=true)
    public static Core_IPS_CaseEditWrapper getCaseData(String caseId){
        return new Core_IPS_CaseEditWrapper(caseId);
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getvariant(String selectedProductId){  
        return  helper.getProductVariant(selectedProductId);
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getCategoryDetails(String supportedProductId){
        return  helper.getCategoryOptions(supportedProductId);
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getSubCategoryDetail(String categorySelected){
        return  helper.getsubCategoryOptions(categorySelected);
    }
    @AuraEnabled
    public static List<Core_IPS_CaseCreateHelper.DynamicField> getProductEDQ(String supportedProductId, String subCategoryid,Boolean isAgent){
        List<Core_IPS_EnvironmentDetailQuestion> edqs = helper.displayedqQuestions(supportedProductId,subCategoryid,isAgent);
        return helper.getDynmicFields(edqs);
    }
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_CaseCreateHelper.DynamicField> getSubCatProductEDQ(String supportedProductId, String subCategoryid,Boolean isAgent){
        List<Core_IPS_EnvironmentDetailQuestion> edqs = helper.displayedqQuestions(supportedProductId,subCategoryid,isAgent);
        return helper.getDynmicFields(edqs);
    }
    @AuraEnabled(cacheable=true)
    public static boolean getAgentDetail(){
        return  helper.getAgent();
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getPlatformDetails(Id productsId){
        return helper.getPlaformOptions(productsId);
    }
    
    @AuraEnabled  
    public static string getContactLookupSOQL(String projectId, String assetId){
        return helper.getContactLookupSOQL( projectId,  assetId);  
        
    }  
    // Added by Ganapati for product lookup configuration
    @AuraEnabled(cacheable=true)
    public static List<String> getProjectList(String relatedId){
        return  helper.getProjectList(relatedId);
    }
    @AuraEnabled
    public static Case submitCaseRecord(Case newRecord, Contact ContactRecord, String CaseEDQData){
        return helper.SubmitCaseRecord( newRecord,  ContactRecord, CaseEDQData);  
    }    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> displayProductVariant(String selectedProductId, String recordTypeName) {
        return helper.displayProductVariant( selectedProductId,  recordTypeName);
    } 
    
    @AuraEnabled
    public static void copyInterestedParties(String parentCaseId, String caseId) {
        Core_IPS_CaseCreateHelper.copyInterestedParties(parentCaseId, caseId);
    }
    
    @AuraEnabled
    public static String getErrorMessage(String errorCode) {
        return Core_IPS_CaseCreateHelper.getErrorMessage(errorCode);
    }
    
    @AuraEnabled(cacheable=true)
    public static String readFieldSet(String fieldSetName, String ObjectApiName){
        String fieldSetStr = '';
        List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet(fieldSetName, ObjectApiName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            fieldSetStr += fieldSetMemberObj.getFieldPath() + ', ';
        }  
        return fieldSetStr;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProjectListFromAsset(String prodId) {
        return Core_IPS_CaseCreateHelper.getProjectListFromAsset(prodId);       
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getAccountList() {
        Set<Id> accIdSet = Core_IPS_CaseCreateHelper.getAccountList();
        List<Id> accList = new List<Id>();
        accList.addAll(accIdSet);
        return accList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getContactListFromAsset(String prodId) {
        Set<Id> conIdSet = Core_IPS_CaseCreateHelper.getContactListFromAsset(prodId);
        List<Id> conIdList = new List<Id>();
        conIdList.addAll(conIdSet);
        return conIdList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getContactListFromProject(String projectId) {
        Set<Id> conIdSet = Core_IPS_CaseCreateHelper.getContactListFromProject(projectId);
        List<Id> conIdList = new List<Id>();
        conIdList.addAll(conIdSet);
        return conIdList;
    }
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfileName() {
        return Core_IPS_CaseCreateHelper.getCurrentUserProfileName();
    }
    @AuraEnabled(cacheable=true)
    public static String getIPSLabel(String name) {
        return Core_IPS_Helper_Utility.getIPSLabel(name);
    }
    
    @AuraEnabled
    public static String getButtonsVisibility(String caseId) {
        return helper.getButtonsVisibility(caseId);
    }
    
    @AuraEnabled    
    public static List<Contact> getContactRecords(){
        User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
        String loggedInUserAcctId = loggedInUser.Contact.AccountId;
        String loggedInUserContId = loggedInUser.ContactId ;
        String queryStr = null;
        // SOQL Injection Fix - Start -  Shipra
        //queryStr = 'Select id,Name,LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c, CreatedDate From Contact Where AccountId = \''+loggedInUserAcctId+'\' AND Core_IPS_Active__c  = true  ';
        queryStr = 'Select id,Name,LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c, CreatedDate From Contact Where AccountId = :loggedInUserAcctId AND Core_IPS_Active__c  = true  ';
        // SOQL Injection Fix - End -  Shipra
        return Database.query(queryStr);
    }
    
    @Auraenabled  public static String selectedCountry{get;set;}
    public static  List<Contact> contactInContext = new list<Contact>();
    @Auraenabled public static Boolean radioCheckbox{get;set;}
    @Auraenabled public static  User Usr{get;set;}
    
    @Auraenabled(cacheable=true)
    public static List<Contact> getcountryfields(){
        Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: Usr.Contactid];
        // TWC745-9175 - Exceptional Handling - Phani Start If Condition 04/05/2026
        if(contactInContext.size() > 0)
        {
        	selectedCountry = contactInContext[0].Core_Country_Region__c ;
        	radioCheckbox = contactInContext[0].Core_MINDS__c;
        } // TWC745-9175 - Exceptional Handling - Phani End If Condition 04/05/2026
        return contactInContext;    
    }
    @Auraenabled
    public static void Submitcountryvalue(String countryValue,Boolean radioCheckbox){
        
        List<Contact>  userContact = new List<Contact>();   
        List<User>  users = new List<User>();    
        List<user> usrRecord = [SELECT Id,TimeZoneSidKey, ContactId FROM User where id =:UserInfo.getUserId()   ];
        
        userContact = [SELECT Id,Name,AccountId,Account.Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c From Contact where id =:usrRecord[0].ContactId  ]; 
        Contact con = new Contact();
        con.id=userContact[0].Id;
        con.Core_Country_Region__c=countryValue;
        con.Core_MINDS__c=radioCheckbox;
        
        try{
            upsert con;
        }
        catch(Exception e){
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String getProjectAsset(Id productId,String mode) {
        //Niyaz -- 12/06/2025 --- added as part of vulnerability fix, AccountId removed — never used
        List<Asset>  ast = [SELECT Id, Name,Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Project__r.Name FROM Asset WHERE Id=:productId LIMIT 1];
        if(mode=='productId')
            return ast[0].Name;
        else if(mode=='projectId') { 
            return ast[0].Core_IPS_Project__r.Name;
        }
        else if(mode=='supportedProd')
            return ast[0].Core_Supported_Product__c;
        else
            return null;  
    }
    @AuraEnabled(cacheable=true)
    public static String getAssetOnProjectChange(Id selectedProjId,Id selectedProdId,Id selectedConId) {
        Id supportedProdId;
        Id accountId;
        List<Asset> lstAsset = new List<Asset>();
        List<Asset> astList =new  List<Asset> ();
        
        if (Schema.sObjectType.Asset.isAccessible()) {
            astList = [select Id,Core_Supported_Product__c FROM Asset WHERE Id =: selectedProdId LIMIT 1];
        }
        if(astList.size()>0)  supportedProdId = astList[0].Core_Supported_Product__c;
        if(selectedProjId!=null){
            lstAsset = [SELECT Id FROM Asset WHERE Core_IPS_Project__c=:selectedProjId AND Core_Supported_Product__c=: supportedProdId AND Status='Active'];
        }
        else {
          List<Contact> lstCont = new  List<Contact>();
          // FLS Fix -TWC745-7160 - Shipra
          if (Schema.sObjectType.Contact.isAccessible()) {
            lstCont = [SELECT AccountId FROM Contact WHERE Id=:selectedConId  WITH SECURITY_ENFORCED LIMIT 1];
        }
           
	   
	    if(lstCont.size()>0) accountId = lstCont[0].AccountId;
            if(accountId!=null) {
                lstAsset = [SELECT Id FROM Asset WHERE Core_Supported_Product__c=:supportedProdId AND Status='Active' AND (AccountId=:accountId OR RecordType.Developername=:Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Global_Asset_RT')) AND Id IN (SELECT Core_Intel_Product__c FROM Core_IPS_Map_Par_Line_Item__c WHERE (RecordType.DeveloperName='MAP' OR (RecordType.DeveloperName='PAR' AND Core_Intel_Product__r.Core_Supported_Product__r.Core_Flag_Status__c!='Par Hidden')) AND  Core_Status__c='ACTIVE' AND Core_Intel_Product__r.Core_Supported_Product__c=:supportedProdId)];
            } 
        }     
        
        if(lstAsset!=null && lstAsset.size()>0){
            //return true;
            return lstAsset[0].Id;
        }
        else{
            return 'false';
        }
        
    }
    public static Case caseRecord = new Case();
    @AuraEnabled
    public static boolean checkcloseCaseEditPermission(Id caseId) {
        User u = [Select profile.Name from user where id=:userinfo.getUserId()];
        if (Schema.sObjectType.Case.isAccessible()) {
            caseRecord = [Select Id,recordtype.DeveloperName From Case Where Id =:caseId];
        }
        boolean  checkflag = false;
        if(caseRecord.Recordtype.DeveloperName=='IPS_Closed_Case'){
            for(string str : Core_IPS_Labels__c.getValues('CloseCaseEditPermission').value__c.trim().split(','))
            {
                if(str.trim() == u.profile.Name)
                {
                    checkflag = true;
                }
            }
            return checkflag;
        } else{
            return checkflag;
        }
        
    }
    @AuraEnabled
    public static boolean hasEditAccess(Id caseId){
        boolean editAccess;
        editAccess = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :caseId].HasEditAccess;
        return editAccess;
    }
    @AuraEnabled
    public static boolean hasReadAccess(Id assestId){
        boolean readAccess;
        readAccess = [SELECT HasReadAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :assestId].HasReadAccess;
        return readAccess;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getProductQuery(Id selectedProjId,Id selectedAccountId) {
        List<String> finalList = new List<String>();
        if(String.isBlank(selectedProjId)){
            String newQuery = 'SELECT ';
            List<Schema.FieldSetMember> fieldSetMemberList2 = Core_Utility.readFieldSet('AssetFieldSet','Asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList2) {
                newQuery += fieldSetMemberObj.getFieldPath() + ', ' ;
            }
            
            newQuery += ' Id FROM Asset ';
            newQuery += ' WHERE AccountId!=null AND AccountId=:selectedAccountId AND Id IN (SELECT Core_Intel_Product__c FROM Core_IPS_Map_Par_Line_Item__c WHERE (RecordType.DeveloperName=\'MAP\' OR (RecordType.DeveloperName=\'PAR\' AND Core_Intel_Product__r.Core_Supported_Product__r.Core_Flag_Status__c!=\'Par Hidden\')) AND Core_Status__c=\'ACTIVE\') LIMIT 50000';
            List<Asset> prodList = Database.query(newQuery);
            for(Integer i=0;i<prodList.size();i++){
                finalList.add(prodList[i].Id);
            }
            return finalList;
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getProductSupportOwner(String selectedcontId,String selectedprojId) {
        List<User> searchList = new List<User>();
        String queryString = '';
        Id accId;
        List<String> pSOIds = new List<String>();
        String profileId = System.Label.Core_IPS_Agent_Partner_Profile_id;
        try{
            //set of all users assigned to  IPS FAE Partner Permission set 
            Set<Id> userIds = new Set<Id>();
            for(PermissionSetAssignment uId: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :System.Label.Core_IPS_Partner_DFAE_Permission_Set AND Assignee.ProfileId = :System.Label.Core_IPS_Partner_Profile_Id]){
                userIds.add(uId.AssigneeId);
                
            }
            //Account Id for Contact Based Cases
            if(selectedcontId != '' && selectedcontId != null ){
                List<Contact> contactList = new List<Contact>();
                // FLS Fix -TWC745-7160 - Shipra
                if (Schema.sObjectType.Contact.isAccessible()) { 
                    contactList = [SELECT AccountId FROM Contact WHERE Id =:selectedcontId and Core_IPS_Active__c = True WITH SECURITY_ENFORCED];
                }
                for(Contact c: contactList){
                    accId = c.AccountId;
                }
                }
            
            
            //Senario 1: Project Based Cases: The Partner Support Owner field should be a lookup that displays users with the Partner FAE/IPS Agent-Partner profile who are part of the project on the case.
            if(selectedprojId != '' && selectedprojId != null){
                queryString = 'SELECT Id, Name, FirstName, LastName, Email, Contact.Account.Name FROM User WHERE Id IN (SELECT Core_User__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__r.Id = :selectedprojId and Core_Status__c = \'Active\') AND (ProfileID =:profileId  OR Id IN :userIds) ORDER BY Name ASC LIMIT 300';
                searchList = Database.query(queryString);
                
            }                    
            //Senario 2: Non Project Based Cases:The Partner Support Owner field should be a lookup that displays users with the Partner FAE/IPS Agent-Partner profile who are members of the account on the case.
            else if(selectedcontId != '' && selectedcontId != null){
                queryString = 'SELECT Id, Name, FirstName, LastName, Email, Contact.Account.Name FROM User WHERE Contact.AccountId =:accId AND isActive = True AND (ProfileID =:profileId  OR Id IN :userIds) ORDER BY Name ASC LIMIT 300';               
                searchList = Database.query(queryString);
                
            }
            //For all other senario return null
            if(searchList.size()>0){
                for(User u : searchList){
                    pSOIds.add(u.Id);
                }
                
                return pSOIds;
                
            }
            else{
                return null;
            }                 
            
        }
        catch(Exception e){
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getPartnerSupportAccount(String selectedcontId,String selectedprojId,String selectedPSOId){
        return  helper.getPSAOptions(selectedcontId,selectedprojId,selectedPSOId);
    }
    @AuraEnabled(cacheable=false)
    public static String validateBeforeSubmitCase(Id selectedProductId,Id selectedProjectId,Id selectedContacttId,String caseRecordType) {
        List<Core_IPS_Project_Member__c> projMem;
        List<Asset> ast;
        Contact conRec;
	if(!String.isBlank(selectedProjectId) && selectedProjectId != null){
                if(caseRecordType!='' && caseRecordType!=null && caseRecordType!='Core_IPS_Case_Create_Self_Assigned' && Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()){
                    projMem = [SELECT Id,Name,Core_IPS_Project__c,Core_IPS_Contact__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c =: selectedProjectId AND Core_IPS_Contact__c =: selectedContacttId AND Core_Status__c = 'Active' LIMIT 1];
                }
                if(Schema.sObjectType.Asset.isAccessible()) {
                    ast = [SELECT Id,Name FROM Asset WHERE Core_IPS_Project__c =: selectedProjectId and Id =: selectedProductId LIMIT 1];
                }
                if(!ast.isEmpty() ){ 
                    if(caseRecordType =='Core_IPS_Case_Create_Self_Assigned' || !projMem.isEmpty()){
                        return 'true';
                    }  
                    else{
                        return System.Label.Core_IPS_Contact_NotAssociated_With_Project;
                    }
                } else{ 
                    return System.Label.Core_IPS_Product_NotAssociated_With_Project; 
                }
        }
        else{
            if(caseRecordType!='' && caseRecordType!=null && caseRecordType=='Core_IPS_Case_Create_Self_Assigned' && String.isBlank(selectedProjectId)){
                return 'true';
            } 
            List<Contact> conRecList = new List<Contact>(); // TWC745-9175 - Exceptional Handling - Phani
            if(Schema.sObjectType.Contact.isAccessible()) {  
                conRecList = [SELECT Id,Name,AccountId from Contact WHERE Id =: selectedContacttId LIMIT 1];
                if(conRecList.size()>0) // TWC745-9175 - Exceptional Handling - Phani Strat If Condition
                {
                    conRec = conRecList[0];
                } // TWC745-9175 - Exceptional Handling - Phani End If Condition
            }
            if(conRec!= null && Schema.sObjectType.Asset.isAccessible()) { // TWC745-9175 - Exceptional Handling - Phani
                ast = [SELECT Id,Name FROM Asset WHERE  Id =: selectedProductId AND (RecordType.Name= 'IPS Public Product' OR AccountId =: conRec.AccountId) LIMIT 1];
            }
            if(conRec!=null && !ast.isEmpty()){ 
                return 'true';
            } else{ 
                return System.Label.Core_IPS_Product_NotAssociated_With_Account; 
            }
        }
    
    }
}