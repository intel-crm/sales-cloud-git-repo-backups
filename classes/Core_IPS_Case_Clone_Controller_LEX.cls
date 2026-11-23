public with sharing class Core_IPS_Case_Clone_Controller_LEX{
    public Core_IPS_Case_Clone_Controller_LEX(){
    }

    @AuraEnabled(cacheable = true)
    public static list<case> getCaseDetails(String recId){
        return [select CaseNumber, Core_IPS_Customer_Visible__c, Core_IPS_Issue_source__c, Core_IPS_Classification__c, RecordTypeId, RecordType.DeveloperName, Id, status, Core_CaseType__c, Core_Customer_Reference_ID__c, Core_IPS_Product_name__c, Core_IPS_Copy_Flag__c, Core_End_Customer__c, Asset.Core_IPS_Case__c, Priority, Core_IPS_GEC_Status__c, AccountId, Account.Core_Military_Aerospace_and_Government__c, ContactId, Core_case_issue_sub_category__c, Core_Case_Issue_Category__c, Core_IPS_Project_Case__r.Name, Core_Case_issue_category__r.name, Core_case_issue_sub_category__r.name, AssetId, Asset.status, Core_IPS_Supported_Product__c, Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, Core_IPS_Supported_Product__r.Core_EOIS__c, Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name, Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name, Core_Product_Variant__c, Core_IPS_Restricted_Secret_Content__c, Core_Severity_Reason__c, Core_IPS_Partner_Sup_Owner__c, Core_Partner_Supported_Account__c, Core_IPS_Priority_Reason__c, ParentId, origin, (select Name, Core_Question__c, Core_Answer__c, Core_Case__c
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          from Environments__r), (Select Id, Type__c, User__c, Contact__c, Active__c, case__c
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  From Interested_Parties__r)
                FROM case 
                WHERE Id = :recId];
    }

    @AuraEnabled(cacheable = false)
    public static list<case> geCloneCaseDetails(String recId){
        list<case> clonedCases;
        Case cs;
        if (recId == null){
            cs = new Case();
        } else{
            // SOQL Injection Fix - Start -  Shipra
            Set<String> exclude = new Set<String>{ 'Id' };
            Map<String, Object> bindMap = new Map<String, Object>{ 'recId' => recId };
            String qry = 'SELECT ' + Utilities_Portal_LEX.getAllFieldsAccessible(exclude, new Case()) + ', CaseNumber,Core_IPS_Project_Case__r.Name,RecordType.DeveloperName,Asset.Core_IPS_Case__c,Account.Core_Military_Aerospace_and_Government__c,Core_Case_issue_category__r.name,Core_case_issue_sub_category__r.name,Asset.status,Asset.Core_Supported_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,Core_IPS_Supported_Product__r.Core_EOIS__c,Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name,Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name,(select Name, Core_Question__c, Core_Answer__c, Core_Case__c from Environments__r) ,(Select Id,Type__c,User__c,Contact__c,Active__c ,case__c From  Interested_Parties__r) ';
            qry += 'FROM Case WHERE Id =: recId';
            clonedCases = createcloneCase(Database.queryWithBinds(qry, bindMap, AccessLevel.USER_MODE));
            // SOQL Injection Fix - End -  Shipra
        }

        return clonedCases;
    }

    @AuraEnabled(cacheable = false)
    public static List<Case> createcloneCase(List<Case> caseNewMap){
        boolean isAgent;
        boolean eoisFlag;
        Boolean isPartnerFAE;
        Boolean isAgentPartner;
        List<Contact> contactInContext = new List<Contact>();
        Boolean isMindsFlag;
        String selectedCountry;
        User u = [select Id, username, userType, ContactId, AccountId, profileid
                  from User
                  where Id = :UserInfo.getUserId()];
        system.debug('u'+u);
        if (Contact.SObjectType.getDescribe().isAccessible()){
             //FLS Read fix applied - Gangadhar 18/10/2022
            contactInContext = [Select id, Name, Core_MINDS__c, Core_Country_Region__c
                                from Contact
                                where id = :u.Contactid
                                limit 1];
        }
        system.debug('contactInContext'+contactInContext);
        if (contactInContext != null && !contactInContext.isEmpty()){
            if (isMindsFlag != NULL){
                isMindsFlag = contactInContext[0].Core_MINDS__c;
            }
            if (contactInContext[0].Core_Country_Region__c != NULL && contactInContext[0].Core_Country_Region__c != ''){
                selectedCountry = contactInContext[0].Core_Country_Region__c;
            }
        }
        //Add PSO/PSA to Case when copying a case
        isPartnerFAE = (Core_Utility.getPartnerUserType(userinfo.getuserId())).contains('Partner - DFAE');
        //Commented because,deleting the Core_IPS_Customer_Case_Controller.US:TWC745-5417
        // isAgentPartner = Core_IPS_Customer_Case_Controller.isPartnerAgentUser();//Change it to agent partner check
        if (u != null){
            if (u.userType == Label.Core_IPS_CustCommPlus_UserType || (Label.Core_Partner_Profile_Id).contains((u.profileId + '').substring(0, 15))){
                isAgent = false;
            } else{
                isAgent = true;
            }
        }
        List<case> returncaseList = new List<Case>();
        String selectedVariant;
        String selectedProductId;
        Boolean custVisible;
        for (Case cs : caseNewMap){
            case cloneCase = cs.clone(false, true, false, false);
            String prefixString = '(Copy Of ' + cs.CaseNumber + ') ';
            cloneCase.Subject = prefixString + cloneCase.Subject;
            cloneCase.Core_IPS_Customer_Visible__c = cs.Core_IPS_Customer_Visible__c;
            cloneCase.Core_CaseType__c = cs.Core_CaseType__c;
            selectedVariant = cloneCase.Core_Product_Variant__c;
            cloneCase.Core_Product_Variant__c = cloneCase.Core_Product_Variant__c;
            cloneCase.assetId = cs.assetId;
            cloneCase.Core_IPS_Customer_Visible__c = cs.Core_IPS_Customer_Visible__c;
            if (cs.Core_IPS_Issue_source__c == Label.Core_IPS_Legacy_PSG){
                cloneCase.Core_IPS_Issue_source__c = Label.Core_IPS_CaseSource_Val_for_Legacy_PSG;
            }
            cloneCase.Core_IPS_GEC_Status__c = '';
            String prefixDesc = '**Copied From Case ' + cs.CaseNumber + '<br>';
            cloneCase.Core_Issue_Description__c = prefixDesc + cloneCase.Core_Issue_Description__c;
            if (u.userType == Label.Core_IPS_CustCommPlus_UserType){
                cloneCase.ContactId = u.ContactId;
                cloneCase.AccountId = u.AccountId;
            } else{
                cloneCase.ContactId = cs.ContactId;
                cloneCase.AccountId = cs.AccountId;
            }
            cloneCase.Core_Severity__c = null;
            if (Schema.sObjectType.case.fields.Status.isCreateable()){
                cloneCase.Status = null;
            }
            cloneCase.ParentId = cs.Id;
            string ProjectName = cloneCase.Core_IPS_Project_Case__r.Name;
            string categorySelectedname = cloneCase.Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name;
            string subcategorySelectedname = cloneCase.Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name;
            string categorySelected = cloneCase.Core_Case_Issue_Category__c;
            string subCategorySelected = cloneCase.Core_case_issue_sub_category__c;
            cloneCase.AssetId = cs.AssetId;
            cloneCase.Core_IPS_Supported_Product__c = cs.Core_IPS_Supported_Product__c;
            if (Schema.sObjectType.case.fields.Core_Case_Issue_Category__c.isCreateable()){
                cloneCase.Core_Case_Issue_Category__c = cs.Core_Case_Issue_Category__c;
            }
            if (Schema.sObjectType.case.fields.Core_case_issue_sub_category__c.isCreateable()){
                cloneCase.Core_case_issue_sub_category__c = cs.Core_case_issue_sub_category__c;
            }
            if (Cs.Core_IPS_Supported_Product__r.Core_EOIS__c == true){
                eoisFlag = true;
            }
            Schema.DescribeSObjectResult caseObjectDetail = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> rtMapByName = caseObjectDetail.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtNoAssignedContact = rtMapByName.get('IPS No Assigned Contact Case');
            Schema.RecordTypeInfo rtCaseCreate = rtMapByName.get('IPS Case Create');
            boolean isNACCase = false;
            if (cs.Status == 'Closed'){
                if (cloneCase.contactId != null){
                    cloneCase.recordTypeId = rtCaseCreate.getRecordTypeId();
                } else{
                    cloneCase.recordTypeId = rtNoAssignedContact.getRecordTypeId();
                    isNACCase = true;
                }
            } else{
                if (cloneCase.contactId != null){
                    cloneCase.recordTypeId = rtCaseCreate.getRecordTypeId();
                } else{
                    cloneCase.recordTypeId = rtNoAssignedContact.getRecordTypeId();
                    isNACCase = true;
                }
            }
            if (Schema.sObjectType.case.fields.Core_Severity__c.isCreateable()){
                cloneCase.Core_Severity__c = Cs.Core_Severity__c;
            }

            returncaseList.add(cloneCase);
        }

        if (returncaseList != null){
            //    insert returncaseList;
        }
        return returncaseList;
    }

    @AuraEnabled
    public static void saveCaseDetails(){
        try{
            if (Schema.sObjectType.Case.fields.Core_Product_Variant__c.isUpdateable()){
                // cloneCase.Core_Product_Variant__c = selectedVariant;
            }
            if (Schema.sObjectType.Case.fields.Core_IPS_Customer_Visible__c.isUpdateable()){
                // cloneCase.Core_IPS_Customer_Visible__c =custVisible;        //added by Aayushi US126300
            }
        } catch (DMLException e){

        }
    }

    @AuraEnabled
    public static List<Product2> displayProductVariant(string selectedProductId){
        List<Product2> variantslist = Utilities_Portal_LEX.getProducts(selectedProductId);
        return variantslist;
    }

    @AuraEnabled
    public static List<Core_IPS_Product_Issue_Category__c> displaySubCategoryData(string caseIssueCategoryId){
        try{
            List<Core_IPS_Product_Issue_Category__c> catelist = Utilities_Portal_LEX.getsubCategory_Options(caseIssueCategoryId);
            return catelist;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Core_IPS_Product_Issue_Category__c> displayCategoryData(string prodId){
        list<Core_IPS_Product_Issue_Category__c> lProName = new list<Core_IPS_Product_Issue_Category__c>();
        try{
            for (Core_IPS_Product_Issue_Category__c a : Core_IPS_CaseUtility.getCategories(prodId)){
                lProName.add(a);
            }
            return lProName;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static case insertCaseData(List<case> caseList){

        try{
            if (caseList.size() > 0){
                insert caseList;
            }
        } catch (exception e){

        }
        return caseList[0];
    }

    //* This method checks if the ExportPDF is called by a community user or an internal user*/
    @AuraEnabled
    public static string getBaseUrlToLoadIframePage(){
        String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();
        String finalCummName = currentRequestURL.contains('IPS') ? 'IPS' : null;
        return finalCummName;
    }

}