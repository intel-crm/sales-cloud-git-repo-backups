/******************************************************************************************************************************************
Class Name  : ER_SalesCloud_Integration
Test Class Name : ER_SalesCloud_Integration_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 May 2024
Function    : Apex class to generate A&E payloads for Accounts, Contacts, CMFs
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         15/05/2024             Original version 
*****************************************************************************************************************************************/
public class ER_SalesCloud_Integration {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_SalesCloud_Integration';
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'Registration';
    public static string params = '';
    public static void createLogEntry(String message, Exception ex, String tags, String severity, String objectType){
        String strDetailsAndEx = '';
        if( ex != null ) {
            strDetailsAndEx += 'Message: ' + ex.getMessage() + '\n';
            strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
            strDetailsAndEx += 'Stack Trace: ' +ex.getStackTraceString() + '\n';
            strDetailsAndEx += 'Type Name: ' +ex.getTypeName() + '\n';
        }
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
            Core_Origin__c = LOG_ENTRY_ORIGIN,
            Core_Project__c = LOG_ENTRY_PROJECT,
            Core_Scope__c = LOG_ENTRY_SCOPE,
            Core_Severity__c = 'Medium',
            Core_Message__c =  (message == null || message.length() <= 255 ? message : message.substring(0, 255)),
            Core_Details__c = strDetailsAndEx,
            Core_When__c = system.now(),
            Core_sObjectType__c = objectType
        );
        if(objCLE != Null){
            insert objCLE;  
        }
    }
    private static ER_SalesCloud_Integration_Model.AEAccountInformation getAnEAccountInformation(Account acct){
        ER_SalesCloud_Integration_Model.AEAccountInformation acctInfo = new ER_SalesCloud_Integration_Model.AEAccountInformation();       
        acctInfo.Name = acct.Name;
        acctInfo.AccountNo = acct.AccountNumber;
        acctInfo.PrimeAccountName = acct.Core_Prime_Account_Name__c;
        acctInfo.SalesGroup = acct.Core_Sales_Groups__c;
        acctInfo.Industry = acct.Industry;
        acctInfo.CoveredAccount = acct.Core_Covered_Account__c;
        acctInfo.CNDANumber = acct.Core_CNDA_Number__c;
        acctInfo.BusinessPartnerId = acct.Core_Business_Partner_Id__c;
        acctInfo.BusinessId = acct.Core_Business_ID__c;
        acctInfo.BizOrgType = acct.Core_Account_Type__c;
        acctInfo.PartnerRole = acct.Core_IPA_Partner_Role__c;        
        acctInfo.Region = acct.Core_Geo__c;
        acctInfo.SubRegion = acct.Core_Sub_Geo__c;
        acctInfo.UserDefinedPhoneNumber = acct.Core_User_Defined_Phone_Number__c;
        acctInfo.UserDefinedWebsite = acct.Core_User_Defined_Website__c;        
        acctInfo.EnglishNameOnly = acct.Core_English_Only_Name__c;        
        acctInfo.PartnerProgramSegment = acct.Core_IPA_Partner_Segment__c;
        acctInfo.AccountLegalName = acct.Core_Account_Legal_Name__c;
        acctInfo.AccountBUFocus = acct.Core_Account_BU_Focus__c;       
        acctInfo.RecordType = acct.RecordType.Name;        
        acctInfo.IsIPA = acct.Core_Intel_Partner_Alliance_PartnerGroup__c;
        acctInfo.Deactivated = acct.Core_Deactivated__c;
        acctInfo.DeactivatedReason = acct.Core_Deactivation_Reason__c;
        acctInfo.IsODM = acct.Core_IsODM__c;
        acctInfo.AccountOwner = new ER_SalesCloud_Integration_Model.RecordOwner(acct.Owner.Email, acct.Owner.FirstName, acct.Owner.LastName);
        acctInfo.BadgeTier = acct.Core_IPA_Badge_Tier__c;      
        acctInfo.address = new ER_SalesCloud_Integration_Model.AccountAddress();
        acctInfo.address.PrimaryAddress = getAccountPrimaryAddress(acct);   
        acctInfo.address.SecondaryAddress = getAccountSecondaryAddress(acct);
        return acctInfo; 
    }
    private Static ER_SalesCloud_Integration_Model.Address getAccountPrimaryAddress(Account acct){
        ER_SalesCloud_Integration_Model.Address primaryAddress = new ER_SalesCloud_Integration_Model.Address();
        boolean isAddressEmpty = false;
        isAddressEmpty = (String.isEmpty(acct.BillingStreet) && String.isEmpty(acct.Billingcity) 
                          && String.isEmpty(acct.BillingState) && String.isEmpty(acct.BillingCountry) 
                          && String.isEmpty(acct.BillingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            primaryAddress.Street = acct.BillingStreet;
            primaryAddress.City = acct.Billingcity;
            primaryAddress.State = acct.BillingState;
            primaryAddress.StateCode = acct.BillingStateCode;
            primaryAddress.Country = acct.BillingCountry;
            primaryAddress.CountryCode = acct.BillingCountryCode;
            primaryAddress.PostalCode = acct.BillingPostalCode;   
            return primaryAddress;
        }else{
            return null;
        }
    }
    
    private Static ER_SalesCloud_Integration_Model.Address getAccountSecondaryAddress(Account acct){       
        boolean isAddressEmpty = false;
        ER_SalesCloud_Integration_Model.Address secondaryAddress = new ER_SalesCloud_Integration_Model.Address();
        isAddressEmpty = (String.isEmpty(acct.ShippingStreet) && String.isEmpty(acct.Shippingcity) && String.isEmpty(acct.ShippingState) && String.isEmpty(acct.ShippingCountry) && String.isEmpty(acct.ShippingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            secondaryAddress.Street = acct.ShippingStreet;
            secondaryAddress.City = acct.Shippingcity;
            secondaryAddress.State = acct.ShippingState;
            secondaryAddress.StateCode = acct.ShippingStateCode;
            secondaryAddress.Country = acct.ShippingCountry;
            secondaryAddress.CountryCode = acct.ShippingCountryCode;
            secondaryAddress.PostalCode = acct.ShippingPostalCode;
            return secondaryAddress;
        }else{
            return null;
        }
    }
    public static void GenerateAnEAccountOBM(Set<Id> accountIds){
        try{
            List<AE_ACM_Integration_change_event__e> accountChangeEvents  = new List<AE_ACM_Integration_change_event__e>();
            List<Account> accts = [SELECT Name,AccountNumber,Core_Prime_Account_Name__c,Core_Sales_Groups__c,Industry,Core_Covered_Account__c,Core_CNDA_Number__c,
                                   Core_CIM_ID__c, Core_Business_Partner_Id__c,Core_Business_ID__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,
                                   Core_Geo__c,Core_Sub_Geo__c,Core_User_Defined_Phone_Number__c,Core_User_Defined_Website__c,
                                   Core_English_Only_Name__c,Core_IPA_Partner_Segment__c,RecordTypeId,Core_IPA_Badge_Tier__c,
                                   Core_Account_Legal_Name__c,Core_Account_BU_Focus__c,LastModifiedDate,Core_Is_Active__c,
                                   OwnerId,Owner.Email,Owner.FirstName,Owner.LastName,RecordType.Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IsODM__c,Core_Deactivated__c,Core_Deactivation_Reason__c,                           
                                   BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode,
                                   ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingCountry,ShippingCountryCode,ShippingPostalCode,LastModifiedBy.Name,CreatedBy.Name,CreatedDate,(SELECT name,Status__c,Status_Reason__c,Effective_End_Date__c,Effective_Start_Date__c,Business_Types__r.Business_Type_Code__c,Business_Types__r.Business_Types_Category__c,Business_Types__r.Name,Business_Types__r.Is_Active__c,LastModifiedDate,LastModifiedBy.Name,CreatedBy.Name,CreatedDate from Account_Business_Types__r) FROM Account WHERE Id IN :accountIds];
            if(accts.size() > 0) {
                List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>();                                        
                for(Account acct: accts){  
                    String tags = '';
                    ER_SalesCloud_Integration_Model.AccountAEPayload payload = new ER_SalesCloud_Integration_Model.AccountAEPayload();
                    
                    payload.MessageType = 'A&E Account Integration'; // Adding account message type to the payloa        
                    payload.AccountId = acct.Id;
                    payload.LastModifiedDate = acct.LastModifiedDate;
                    payload.CreatedDate=acct.CreatedDate;
                    payload.LastModifiedBy=acct.LastModifiedBy.Name;
                    payload.CreatedBy=acct.CreatedBy.Name;
                    payload.AccountStatus = acct.Core_Deactivated__c == true ? 'INACTIVE':'ACTIVE';
                    payload.AccountInformation = getAnEAccountInformation(acct);
                    //payload.AccountBusinessTypes = getAccountBusinessTypes(acct);
                    ER_SalesCloud_Integration.ReturnWrapper businessTypeData= new  ER_SalesCloud_Integration.ReturnWrapper();
                    businessTypeData = getAccountBusinessTypes(acct);
                    payload.AccountBusinessTypes=businessTypeData.accountBusinessTypes;
                    payload.BusinessTypeNames = String.join(businessTypeData.businessTypes,',');
                    tags = acct.Id+';'+acct.Name;
                    AE_ACM_Integration_change_event__e accountChangeEvent=createPlatformEvent(JSON.serialize(payload));
                    //AE_ACM_Integration_change_event__e accountChangeEvent=new AE_ACM_Integration_change_event__e(Message__c = JSON.serialize(payload));
                    accountChangeEvents.add(accountChangeEvent);
                    outboundMsgs.add(createAndGetOBM('A&E Account Integration', JSON.serialize(payload) , tags));
                    
                }
                if(publishAEACMIntegrationChangeEvent(accountChangeEvents)&&outboundMsgs.size() > 0)
                {
                    List<Database.SaveResult> list_save=Database.insert(outboundMsgs, FALSE);
                    
                    UpdateACMRecords(accountIds,'Account');
                }
            } 
        }catch(Exception ex){
            createLogEntry('Error in A&E Account Integration', ex, LOG_ENTRY_ERROR, 'High',params);
        }
    }
    
    public static void GenerateContactOBMAnE(Set<Id> contactIds){
        try{
            List<Contact> conts = new List<Contact>();
            conts = [SELECT id,Salutation,Name,FirstName,LastName,AccountId,Account.Name,Account.AccountNumber, Account.Core_CIM_ID__c,Account.Core_Business_Party_Id__c, Title,Core_IPA_Contact_Segment__c,Core_Preferred_Language__c,Core_Preferred_Communication__c,Phone,Fax,MobilePhone,Email,
                     Core_IPA_PartnerRole__c,Core_IPS_Region__c,Core_IPS_Sub_Region__c,/*Core_Login_Id__c,*/Core_Local_First_Name__c,Core_Local_Last_Name__c,Core_Do_Not_Contact__c,
                     Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_Job_Function_Code__c,Core_Profession__c,Core_IPA_Email_Verification_Date__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,                         
                     MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,LastModifiedDate, Account.Core_Is_Active__c,Account.Core_IsODM__c,Account.Core_Deactivated__c,/*Core_Identity_Status__c,*/Core_Login_Status__c,Core_Deletion_Reason__c,
                     PRM_Wechat_Union_Id__c,Core_IPA_Partner_Community__c,//PRM_Registration_Source_txt__c,PRM_Wechat_Open_Id__c,PRM_Wechat_Union_Id__c, PRM_Registration_Source_txt__c,
                     //Contact Entitlements
                     (SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Selected__c,Core_Status_Change_Date_Time__c,LastModifiedBy.Name,CreatedBy.Name,CreatedDate,LastModifiedDate FROM Contact_Entitlements__r),
                     //CBT
                     (SELECT name,Status__c,Status_Reason__c,Pending_Registration__c,Business_Types__r.Business_Type_Code__c,Business_Types__r.Business_Types_Category__c,Business_Types__r.Name,Business_Types__r.Is_Active__c,LastModifiedBy.Name,CreatedBy.Name,CreatedDate,LastModifiedDate from Contact_Business_Types__r) 
                     FROM Contact WHERE id IN :contactIds];
            
            
            
            if(conts.size() > 0){ 
                GenerateContactOutboundMessageAnE(conts);
            }
        }catch(Exception ex){
            createLogEntry('Error in A&E Contact Integration', ex, LOG_ENTRY_ERROR, 'High',params);
        }
    }  
    public static void GenerateContactOutboundMessageAnE(List<Contact> conts){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        List<AE_ACM_Integration_change_event__e> accountChangeEvents  = new List<AE_ACM_Integration_change_event__e>();
        Map<String,String> pRoleLabelValueMap = new Map<String,String>();
        List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry v : pickListValues) {
            pRoleLabelValueMap.put(v.getValue(), v.getLabel());                
        }
        List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>();
        for(Contact con: conts){
            accountIdSet.add(con.AccountId);
            contactIdSet.add(con.id);
        }        
        //To fetch Account with Account Id in Contact        
        if(!accountIdSet.isEmpty()){
            accountsMap = new Map<Id, Account>([SELECT name,AccountNumber,Core_Business_Party_Id__c,Core_Sales_Groups__c,Industry,Core_Account_Type__c,Core_IPA_Partner_Role__c,ShippingStreet,Shippingcity,ShippingState,ShippingStateCode,ShippingCountry,ShippingCountryCode,ShippingPostalCode,BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode,Core_Business_ID__c, Core_Business_Partner_Id__c, Owner.Email, Owner.FirstName, Owner.LastName, Core_Prime_Account_Name__c,(SELECT name,Status__c,Status_Reason__c,Effective_End_Date__c,Effective_Start_Date__c,Business_Types__r.Business_Type_Code__c,Business_Types__r.Business_Types_Category__c,Business_Types__r.Name,Business_Types__r.Is_Active__c from Account_Business_Types__r) FROM Account WHERE Id IN :accountIdSet]);
        }
        Map<String,List<ER_Customer_Master_File_Group__c>> cmfDataMap = new Map<String,List<ER_Customer_Master_File_Group__c>>();
        for(ER_Customer_Master_File_Group__c cmfData :[SELECT id,name,ER_Active__c,ER_Description__c,ER_Count_of_Customer_Master_Files__c,ER_Inactive_Customer_Master_Files__c,ER_Count_of_Contacts__c,ER_Inactive_Contacts__c,CreatedBy.Name,CreatedDate,LastModifiedDate,LastModifiedBy.Name,(SELECT id,ER_CMF_Name__c,ER_Customer_Master_File_Group__r.Id,ER_Customer_Master_File_Group__r.NAme,ER_Customer_Master_File_Group__r.ER_Active__c,ER_Customer_Master_File_Group__r.ER_Description__c,ER_Customer_Master_File_Group__r.ER_Count_of_Customer_Master_Files__c,ER_Customer_Master_File_Group__r.ER_Inactive_Customer_Master_Files__c,ER_Customer_Master_File_Group__r.ER_Count_of_Contacts__c,
                                                                                                                                                                                                                                                                                                ER_Customer_Master_File_Group__r.ER_Inactive_Contacts__c,ER_Customer_Master_File_Group__r.LastModifiedBy.Name,ER_Customer_Master_File_Group__r.CreatedBy.Name,ER_Customer_Master_File_Group__r.CreatedDate,ER_Customer_Master_File_Group__r.LastModifiedDate,ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c,ER_Customer_Master_File__r.ER_Sales_Org_Code__c ,ER_Customer_Master_File__r.ER_Sales_Org_Name__c,ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c,ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c,ER_Customer_Master_File__r.ER_CMF_Address__c,ER_Customer_Master_File__r.ER_Account_Group__c,
                                                                                                                                                                                                                                                                                                ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c,ER_Customer_Master_File__r.Name,ER_Customer_Master_File__r.ER_CMF_Name__c,ER_Active__c from CMFGroupAssociations__r),(SELECT ER_Contact__r.id from ContactGroupAssociations__r) FROM ER_Customer_Master_File_Group__c  WHERE id IN (SELECT ER_Customer_Master_File_Group__c from ER_ContactGroupAssociation__c WHERE ER_Contact__r.id IN : contactIdSet)]){
                                                                                                                                                                                                                                                                                                    for(ER_ContactGroupAssociation__c contactAssoc:cmfData.ContactGroupAssociations__r){
                                                                                                                                                                                                                                                                                                        if(cmfDataMap.containsKey(contactAssoc.ER_Contact__r.id)){
                                                                                                                                                                                                                                                                                                            List<ER_Customer_Master_File_Group__c> idsOfCmfGroup = cmfDataMap.get(contactAssoc.ER_Contact__r.id);
                                                                                                                                                                                                                                                                                                            idsOfCmfGroup.add(cmfData);
                                                                                                                                                                                                                                                                                                            cmfDataMap.put(contactAssoc.ER_Contact__r.id,idsOfCmfGroup);
                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                        else{
                                                                                                                                                                                                                                                                                                            cmfDataMap.put(contactAssoc.ER_Contact__r.id,new List<ER_Customer_Master_File_Group__c>{cmfData});
                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                }
        
        for(Contact cont: conts){
            String tags = '';
            ER_SalesCloud_Integration_Model.DSAPayload payload = new ER_SalesCloud_Integration_Model.DSAPayload();
            payload.AccountId = cont.AccountId;
            payload.MessageType = 'A&E Contact Integration'; // Adding contact message type to the payload
            payload.ContactId = cont.Id;
            payload.AccountBasicInformation = getAccountBasicInformation(accountsMap.get(cont.AccountId));
            payload.AccountStatus =cont.Account.Core_Deactivated__c == true ? 'InActive':'Active';
            payload.ContactStatus =cont.Core_Login_Status__c;
            payload.DeletionReason = cont.Core_Deletion_Reason__c;
            payload.isODMAccount = cont.Account.Core_IsODM__c;
            payload.ContactBasicInformation = getContactBasicDetails(cont,pRoleLabelValueMap);
            payload.ContactEntitlements = getContactEntitlementsAnE(cont);
            ER_SalesCloud_Integration.ReturnWrapper businessTypeData= new  ER_SalesCloud_Integration.ReturnWrapper();
            businessTypeData = getContactBusinessTypes(cont);
            payload.ContactBusinessTypes=businessTypeData.contactBusinessTypes;
            payload.BusinessTypeNames = String.join(businessTypeData.businessTypes,',');
            payload.LastModifiedDate = cont.LastModifiedDate;
            if(cmfDataMap.get(cont.id) !=null && !(cmfDataMap.get(cont.id).isEmpty())){
                payload.CMFGroups = getCMFDetails(cmfDataMap.get(cont.id));
            }
            tags = cont.Id+';'+cont.Email+';'+cont.Name;
            AE_ACM_Integration_change_event__e accountChangeEvent=createPlatformEvent(JSON.serialize(payload));
            accountChangeEvents.add(accountChangeEvent);
            outboundMsgs.add(createAndGetOBM('A&E Contact Integration', JSON.serialize(payload) , tags));
        }
        if(publishAEACMIntegrationChangeEvent(accountChangeEvents)&&outboundMsgs.size() > 0)
        {
            List<Database.SaveResult> list_save=Database.insert(outboundMsgs, FALSE);
            for (Database.SaveResult sr: list_save) {
                if (!sr.isSuccess()) {
                    String errorMsg = 'Id - '+sr.getId();
                    for (Database.Error err: sr.getErrors()) {
                        errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields(); 
                        System.debug('Error Occured'+errorMsg);                              
                    }
                }
            }
            UpdateACMRecords(contactIdSet,'Contact');
        }
    }
    private static ER_SalesCloud_Integration_Model.AccountBasicInformation getAccountBasicInformation(Account acct){
        ER_SalesCloud_Integration_Model.AccountBasicInformation acctInfo = new ER_SalesCloud_Integration_Model.AccountBasicInformation();
        acctInfo.Name = acct.Name;
        acctInfo.AccountNo = acct.AccountNumber;
        acctInfo.PrimeAccountName = acct.Core_Prime_Account_Name__c;
        acctInfo.BusinessPartnerId = acct.Core_Business_Partner_Id__c;
        acctInfo.BusinessId = acct.Core_Business_ID__c;
        acctInfo.UCDID = acct.Core_Business_Party_Id__c;
        acctInfo.AccountOwner = new ER_SalesCloud_Integration_Model.RecordOwner(acct.Owner.Email, acct.Owner.FirstName, acct.Owner.LastName);
        acctInfo.address = new ER_SalesCloud_Integration_Model.AccountAddress();
        acctInfo.address.PrimaryAddress = getAccountPrimaryAddress(acct);   
        acctInfo.address.SecondaryAddress = getAccountSecondaryAddress(acct);
        return acctInfo; 
        
    }
    public static void GenerateCMFOutboundMessage(Set<Id> cmfGroupIds){
        try{
            Map<String,String> contactIdToCmfMap = new Map<String,String>();
            List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>(); 
            List<AE_ACM_Integration_change_event__e> accountChangeEvents  = new List<AE_ACM_Integration_change_event__e>();
            List<ER_Customer_Master_File_Group__c> cmfGroupList = [SELECT id,Name,ER_Description__c, ER_Active__c, ER_Count_of_Contacts__c, ER_Count_of_Customer_Master_Files__c, ER_Inactive_Contacts__c, ER_Inactive_Customer_Master_Files__c, CreatedDate, LastModifiedDate,LastModifiedBy.Name,CreatedBy.Name,(SELECT ER_Contact__r.id,ER_Contact__r.FirstName, ER_Contact__r.LastName, ER_Contact__r.Title, ER_Contact_Email__c, ER_Contact__r.MobilePhone, ER_Contact__r.Core_eRPM_Person_Id__c, ER_Contact__r.Core_Enterprise_Id__c, ER_Account_Name__c,/* ER_Contact__r.Core_Login_Id__c,*/ ER_Contact__r.CreatedDate, ER_Contact__r.LastModifiedDate,ER_Contact__r.LastModifiedBy.Name,ER_Contact__r.CreatedBy.Name,ER_Contact__r.AccountId,ER_Active__c,ER_Account_IsODM__c,CreatedDate,CreatedBy.Name,ER_Contact__r.MailingCountryCode,ER_Contact__r.Account.Core_Business_Party_Id__c from ContactGroupAssociations__r),(SELECT id,ER_CMF_Name__c,ER_Customer_Master_File_Group__r.NAme,ER_Customer_Master_File_Group__r.ER_Active__c,ER_Customer_Master_File_Group__r.ER_Description__c,ER_Customer_Master_File_Group__r.ER_Count_of_Customer_Master_Files__c,ER_Customer_Master_File_Group__r.ER_Inactive_Customer_Master_Files__c,ER_Customer_Master_File_Group__r.ER_Count_of_Contacts__c,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ER_Customer_Master_File_Group__r.ER_Inactive_Contacts__c,ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c,ER_Customer_Master_File__r.ER_Sales_Org_Code__c ,ER_Customer_Master_File__r.ER_Sales_Org_Name__c,ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c,ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c,ER_Customer_Master_File__r.ER_CMF_Address__c,ER_Customer_Master_File__r.ER_Account_Group__c,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c,ER_Customer_Master_File__r.Name,ER_Customer_Master_File__r.ER_CMF_Name__c,ER_Active__c,CreatedBy.Name,CreatedDate,ER_Central_Block__c,ER_Customer_Master_File__r.CreatedDate,ER_Customer_Master_File__r.LastModifiedDate,ER_Customer_Master_File__r.LastModifiedBy.Name,ER_Customer_Master_File__r.CreatedBy.Name from CMFGroupAssociations__r) from ER_Customer_Master_File_Group__c   where ID IN :cmfGroupIds];
            for(ER_Customer_Master_File_Group__c cmfGroupRec : cmfGroupList){
                ER_SalesCloud_Integration_Model.cmfWrapperAnE payload = new ER_SalesCloud_Integration_Model.cmfWrapperAnE();
                payload.MessageType = 'A&E CMF Group Integration';
                payload.GroupName = cmfGroupRec.Name;
                payload.GroupId = cmfGroupRec.Id;
                payload.Description = cmfGroupRec.ER_Description__c;
                payload.Active = cmfGroupRec.ER_Active__c;
                payload.ActiveCMFCount = String.valueOf(cmfGroupRec.ER_Count_of_Customer_Master_Files__c);
                payload.InActiveCMFCount = String.valueOf(cmfGroupRec.ER_Inactive_Customer_Master_Files__c);
                payload.ActiveContactCount = String.valueOf(cmfGroupRec.ER_Count_of_Contacts__c);
                payload.InActiveContactCount = String.valueOf(cmfGroupRec.ER_Inactive_Contacts__c);
                payload.CreatedDate = cmfGroupRec.CreatedDate; 
                payload.LastModifiedDate = cmfGroupRec.LastModifiedDate;
                payload.LastModifiedBy = cmfGroupRec.LastModifiedBy.Name;
                payload.CreatedBy = cmfGroupRec.CreatedBy.Name;
                List<ER_SalesCloud_Integration_Model.cmfData> cmfList = new List<ER_SalesCloud_Integration_Model.cmfData>();
                for(ER_CMFGroupAssociation__c rec : cmfGroupRec.CMFGroupAssociations__r){
                    ER_SalesCloud_Integration_Model.cmfData cmfDataRec = new  ER_SalesCloud_Integration_Model.cmfData();
                    cmfDataRec.CMFID = rec.ER_Customer_Master_File__r.NAme;
                    cmfDataRec.Name = rec.ER_Customer_Master_File__r.ER_CMF_Name__c;
                    cmfDataRec.SalesOrgCode = rec.ER_Customer_Master_File__r.ER_Sales_Org_Code__c;
                    cmfDataRec.SalesOrgName = rec.ER_Customer_Master_File__r.ER_Sales_Org_Name__c;
                    cmfDataRec.SalesDistiChannelCode = rec.ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c;
                    cmfDataRec.SalesDistiChannelName = rec.ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c;
                    cmfDataRec.Address = rec.ER_Customer_Master_File__r.ER_CMF_Address__c;
                    cmfDataRec.AccountGroup = rec.ER_Customer_Master_File__r.ER_Account_Group__c;
                    cmfDataRec.DirectCustomerRoleCode = rec.ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c;
                    cmfDataRec.DirectCustomerRoleName = rec.ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c;
                    cmfDataRec.IsPartOfGroup = rec.ER_Active__c;
                    cmfDataRec.CentralBlock = rec.ER_Central_Block__c;
                    cmfDataRec.CMFAddedToGroup =rec.CreatedDate;
                    cmfDataRec.CMFAddedToGroupBy = rec.CreatedBy.Name;
                    cmfDataRec.CreatedDate = rec.ER_Customer_Master_File__r.CreatedDate;
                    cmfDataRec.LastModifiedDate = rec.ER_Customer_Master_File__r.LastModifiedDate;
                    cmfDataRec.LastModifiedBy = rec.ER_Customer_Master_File__r.LastModifiedBy.Name;
                    cmfDataRec.CreatedBy = rec.ER_Customer_Master_File__r.CreatedBy.Name;
                    cmfList.add(cmfDataRec);
                }
                
                List<ER_SalesCloud_Integration_Model.ContactBasicInfoAE> contactBasicInfoList = new List<ER_SalesCloud_Integration_Model.ContactBasicInfoAE>();
                for(ER_ContactGroupAssociation__c rec :cmfGroupRec.ContactGroupAssociations__r){
                    ER_SalesCloud_Integration_Model.ContactBasicInfoAE contatcBasicInfo = new ER_SalesCloud_Integration_Model.ContactBasicInfoAE();
                    //contatcBasicInfo.ContactBasicInformation = getContactBasicDetails(rec.ER_Contact__r.id,pRoleLabelValueMap);
                    contatcBasicInfo.FirstName = rec.ER_Contact__r.FirstName;
                    contatcBasicInfo.LastName = rec.ER_Contact__r.LastName;
                    contatcBasicInfo.EnterpriseId = rec.ER_Contact__r.Core_Enterprise_Id__c;
                    contatcBasicInfo.Email = rec.ER_Contact_Email__c;
                    contatcBasicInfo.CreatedDate = rec.ER_Contact__r.CreatedDate;
                    contatcBasicInfo.LastModifiedDate = rec.ER_Contact__r.LastModifiedDate;
                    contatcBasicInfo.LastModifiedBy = rec.ER_Contact__r.LastModifiedBy.Name;
                    contatcBasicInfo.CreatedBy = rec.ER_Contact__r.CreatedBy.Name;
                    contatcBasicInfo.AccountName= rec.ER_Account_Name__c;
                    contatcBasicInfo.AccountId = rec.ER_Contact__r.AccountId;
                    contatcBasicInfo.IsPartOfGroup = rec.ER_Active__c;
                    contatcBasicInfo.IsODMAccount = rec.ER_Account_IsODM__c;
                    contatcBasicInfo.ContactAddedToCMF = rec.CreatedDate;
                    contatcBasicInfo.ContactAddedToCMFBy = rec.CreatedBy.Name;
                    contatcBasicInfo.ContactCountryCode = rec.ER_Contact__r.MailingCountryCode;
                    contatcBasicInfo.UCDID = rec.ER_Contact__r.Account.Core_Business_Party_Id__c;
                    
                    
                    
                    contactBasicInfoList.add(contatcBasicInfo);
                    
                    
                }
                payload.CMFs = cmfList;
                payload.ContactBasicInformation = contactBasicInfoList;
                String tags = cmfGroupRec.Id+';'+cmfGroupRec.Name;
                AE_ACM_Integration_change_event__e accountChangeEvent=createPlatformEvent(JSON.serialize(payload));
                accountChangeEvents.add(accountChangeEvent);
                outboundMsgs.add(createAndGetOBM('A&E CMF Group Integration', JSON.serialize(payload) , tags));
            }
            if(publishAEACMIntegrationChangeEvent(accountChangeEvents)&&outboundMsgs.size() > 0)
            {
                List<Database.SaveResult> list_save=Database.insert(outboundMsgs, FALSE);
                for (Database.SaveResult sr: list_save) {
                    if (!sr.isSuccess()) {
                        String errorMsg = 'Id - '+sr.getId();
                        for (Database.Error err: sr.getErrors()) {
                            errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields(); 
                            System.debug('Error Occured'+errorMsg);                              
                        }
                    }
                }
                UpdateACMRecords(cmfGroupIds,'CMF Group');
            }
        }catch(Exception ex){
            createLogEntry('Error in A&E CMFG Integration', ex, LOG_ENTRY_ERROR, 'High',params);
        }
    }
    private static List<ER_SalesCloud_Integration_Model.cmfWrapper> getCMFDetails(List<ER_Customer_Master_File_Group__c> cmfData){
        Map<String,List<ER_CMFGroupAssociation__c>> cmfDataMap = new Map<String,List<ER_CMFGroupAssociation__c>>();
        for(ER_Customer_Master_File_Group__c grouprec:cmfData){
            
            cmfDataMap.put(grouprec.Name,new List<ER_CMFGroupAssociation__c>{});
            for(ER_CMFGroupAssociation__c associationRec : grouprec.CMFGroupAssociations__r){
                if(cmfDataMap.containsKey(associationRec.ER_Customer_Master_File_Group__r.Name)){
                    List<ER_CMFGroupAssociation__c> idsOfCmfGroup = cmfDataMap.get(associationRec.ER_Customer_Master_File_Group__r.Name);
                    idsOfCmfGroup.add(associationRec);
                    cmfDataMap.put(associationRec.ER_Customer_Master_File_Group__r.Name,idsOfCmfGroup);
                }
                else{
                    cmfDataMap.put(associationRec.ER_Customer_Master_File_Group__r.Name,new List<ER_CMFGroupAssociation__c>{associationRec});
                }
            }
        }
        System.debug('GroupSize'+cmfDataMap.size());
        List<ER_SalesCloud_Integration_Model.cmfWrapper> cmfWrapperDataList = new List<ER_SalesCloud_Integration_Model.cmfWrapper>();
        String GroupName;
        for(ER_Customer_Master_File_Group__c grouprec:cmfData){
            GroupName = grouprec.Name;
            ER_SalesCloud_Integration_Model.cmfWrapper cmfWrapperData = new ER_SalesCloud_Integration_Model.cmfWrapper();
            cmfWrapperData.GroupName = GroupName; 
            cmfWrapperData.GroupId = grouprec.Id;
            cmfWrapperData.CreatedDate = grouprec.CreatedDate;
            cmfWrapperData.LastModifiedDate = grouprec.LastModifiedDate;
            cmfWrapperData.CreatedBy = grouprec.CreatedBy.Name;
            cmfWrapperData.LastModifiedBy =grouprec.LastModifiedBy.Name;
            cmfWrapperData.Active = grouprec.ER_Active__c;
            cmfWrapperData.Description= grouprec.ER_Description__c;
            cmfWrapperData.ActiveCMFcount= String.valueof(grouprec.ER_Count_of_Customer_Master_Files__c);
            cmfWrapperData.InActiveCMFcount= String.valueof(grouprec.ER_Inactive_Customer_Master_Files__c);
            cmfWrapperData.ActiveContactCount= String.valueof(grouprec.ER_Count_of_Contacts__c);
            cmfWrapperData.InActiveContactCount= String.valueof(grouprec.ER_Inactive_Contacts__c);
            List<ER_SalesCloud_Integration_Model.cmfData> cmfdetails = new List<ER_SalesCloud_Integration_Model.cmfData> ();
            for(ER_CMFGroupAssociation__c rec :cmfDataMap.get(GroupName)){
                ER_SalesCloud_Integration_Model.cmfData cmf = new ER_SalesCloud_Integration_Model.cmfData();
                cmf.CMFID = rec.ER_Customer_Master_File__r.Name;
                cmf.name=  rec.ER_Customer_Master_File__r.ER_CMF_Name__c;
                cmf.DirectCustomerRoleName=rec.ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c ;
                cmf.SalesOrgCode=rec.ER_Customer_Master_File__r.ER_Sales_Org_Code__c ;
                cmf.SalesOrgName=rec.ER_Customer_Master_File__r.ER_Sales_Org_Name__c ;
                cmf.SalesDistiChannelCode=rec.ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c ;
                cmf.SalesDistiChannelName=rec.ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c ;
                cmf.Address=rec.ER_Customer_Master_File__r.ER_CMF_Address__c ;
                cmf.AccountGroup=rec.ER_Customer_Master_File__r.ER_Account_Group__c ;
                cmf.DirectCustomerRoleCode=rec.ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c ;
                cmfdetails.add(cmf);
            }
            cmfWrapperData.CMFs=cmfdetails;
            cmfWrapperDataList.add(cmfWrapperData);
        }
        return cmfWrapperDataList;
        
    }
    private static ER_SalesCloud_Integration_Model.ContactBasicInformation getContactBasicDetails(Contact cont, Map<String,String> pRoleLabelValueMap){
        ER_SalesCloud_Integration_Model.ContactBasicInformation ContactDetails = new ER_SalesCloud_Integration_Model.ContactBasicInformation();
        ContactDetails.AccountName = cont.Account.Name;
        ContactDetails.Title = cont.Salutation;        
        ContactDetails.FullName = cont.Name;
        ContactDetails.FirstName = cont.FirstName;
        ContactDetails.LastName = cont.LastName;
        ContactDetails.LocalFirstName = cont.Core_Local_First_Name__c;
        ContactDetails.LocalLastName = cont.Core_Local_Last_Name__c;
        ContactDetails.EnglishFirstName = cont.Core_English_Only_First_Name__c;
        ContactDetails.EnglishLastName = cont.Core_English_Only_Last_Name__c;
        ContactDetails.JobFunction = cont.Core_Job_Function__c;
        ContactDetails.JobFunctionCode = cont.Core_Job_Function_Code__c;
        ContactDetails.Phone = cont.phone;
        ContactDetails.Fax = cont.Fax;
        ContactDetails.Mobile = cont.MobilePhone;
        ContactDetails.Email = cont.email;
        ContactDetails.PreferredCommunication = cont.Core_Preferred_Communication__c;
        ContactDetails.PreferredLanguage = cont.Core_Preferred_Language__c;
        ContactDetails.PartnerRole = cont.Core_IPA_PartnerRole__c;
        ContactDetails.PartnerRoleLabel = String.isEmpty(cont.Core_IPA_PartnerRole__c)?null:(pRoleLabelValueMap.containsKey(cont.Core_IPA_PartnerRole__c)?pRoleLabelValueMap.get(cont.Core_IPA_PartnerRole__c):cont.Core_IPA_PartnerRole__c);
            ContactDetails.Segment = cont.Core_IPA_Contact_Segment__c;
        ContactDetails.eRPMPersonId = cont.Core_eRPM_Person_Id__c;
        ContactDetails.EnterpriseId = cont.Core_Enterprise_Id__c;
        ContactDetails.Region = cont.Core_IPS_Region__c;
        ContactDetails.SubRegion = cont.Core_IPS_Sub_Region__c;
        ContactDetails.DNC = cont.Core_Do_Not_Contact__c;
        ContactDetails.Communities = cont.Core_IPA_Partner_Community__c;
        ContactDetails.MailingAddress = getContactMailingAddress(cont);
        ContactDetails.WeChatUnionId = cont.PRM_Wechat_Union_Id__c;
        //ContactDetails.Loginid = cont.Core_Login_Id__c;
        ContactDetails.Loginid = cont.email;
        ContactDetails.EmailVerificationDate = cont.Core_IPA_Email_Verification_Date__c;
        
        
        return ContactDetails;
    }
    private static ER_SalesCloud_Integration_Model.Address getContactMailingAddress(Contact cont){
        ER_SalesCloud_Integration_Model.Address mailingAddr = new ER_SalesCloud_Integration_Model.Address();
        boolean isAddressEmpty = (String.isEmpty(cont.MailingStreet) && String.isEmpty(cont.MailingCity) 
                                  && String.isEmpty(cont.MailingState) && String.isEmpty(cont.MailingCountry) 
                                  && String.isEmpty(cont.MailingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            mailingAddr.Street = cont.MailingStreet;
            mailingAddr.City = cont.MailingCity;
            mailingAddr.State = cont.MailingState;
            mailingAddr.StateCode = cont.MailingStateCode;
            mailingAddr.Country = cont.MailingCountry;
            mailingAddr.CountryCode = cont.MailingCountryCode;
            mailingAddr.PostalCode = cont.MailingPostalCode; 
            return mailingAddr;
        }else{
            return null;
        }      
        
    }
    private static List<ER_SalesCloud_Integration_Model.ContactEntitlementAnE> getContactEntitlementsAnE(Contact cont){
        
        List<ER_SalesCloud_Integration_Model.ContactEntitlementAnE> ContactEntitlements = new List<ER_SalesCloud_Integration_Model.ContactEntitlementAnE>();
        for(Core_Contact_Entitlement__c ce: cont.Contact_Entitlements__r){
            ER_SalesCloud_Integration_Model.ContactEntitlementAnE ContEntitlement = new ER_SalesCloud_Integration_Model.ContactEntitlementAnE();
            ContEntitlement.Name = ce.Core_Entitlement_Id__r.Name;
            ContEntitlement.Type = ce.Core_Type__c;
            ContEntitlement.Status = ce.Core_Status__c;
            ContEntitlement.IsSelected = ce.Core_Selected__c;
            ContEntitlement.StatusChangeDateUtc = ce.Core_Status_Change_Date_Time__c;
            ContEntitlement.LastModifiedDate = ce.LastModifiedDate;
            ContEntitlement.CreatedDate  = ce.CreatedDate;
            ContEntitlement.LastModifiedBy = ce.LastModifiedBy.Name;
            ContEntitlement.CreatedBy = ce.CreatedBy.Name;
            
            ContactEntitlements.add(ContEntitlement);
        }    
        return ContactEntitlements;
    }
    private static ER_SalesCloud_Integration.ReturnWrapper getContactBusinessTypes(Contact cont){
        Set<String> businessTypeSet = new Set<String>();
        List<ER_SalesCloud_Integration_Model.ContactBusinessType> ContactBusinessTypes = new List<ER_SalesCloud_Integration_Model.ContactBusinessType>();
        for(Contact_Business_Types__c cbt: cont.Contact_Business_Types__r){
            ER_SalesCloud_Integration_Model.ContactBusinessType ContactBusinessType = new ER_SalesCloud_Integration_Model.ContactBusinessType();
            businessTypeSet.add(cbt.Business_Types__r.Name);
            ContactBusinessType.Name = cbt.Business_Types__r.Name;
            ContactBusinessType.BusinessTypeCode =cbt.Business_Types__r.Business_Type_Code__c;
            ContactBusinessType.BusinessTypeCategory =cbt.Business_Types__r.Business_Types_Category__c ;
            ContactBusinessType.IsActive = cbt.Business_Types__r.Is_Active__c;
            ContactBusinessType.Status = cbt.Status__c;
            ContactBusinessType.StatusReason = cbt.Status_Reason__c;
            ContactBusinessType.PendingRegistration = cbt.Pending_Registration__c;
            ContactBusinessTypes.add(ContactBusinessType);
        }    
        ER_SalesCloud_Integration.ReturnWrapper returnBusinessTypes = new  ER_SalesCloud_Integration.ReturnWrapper();
        returnBusinessTypes.businessTypes = businessTypeSet;
        returnBusinessTypes.contactBusinessTypes = ContactBusinessTypes;
        return returnBusinessTypes;
    }
    private static ER_SalesCloud_Integration.ReturnWrapper getAccountBusinessTypes(Account acc){
        Set<String> businessTypeSet = new Set<String>();
        List<ER_SalesCloud_Integration_Model.AccountBusinessType> AccountBusinessTypes = new List<ER_SalesCloud_Integration_Model.AccountBusinessType>();
        for(Account_Business_Types__c abt: acc.Account_Business_Types__r){
            ER_SalesCloud_Integration_Model.AccountBusinessType AccountBusinessType = new ER_SalesCloud_Integration_Model.AccountBusinessType();
            businessTypeSet.add(abt.Business_Types__r.Name);
            AccountBusinessType.Name = abt.Business_Types__r.Name;
            AccountBusinessType.BusinessTypeCode =abt.Business_Types__r.Business_Type_Code__c;
            AccountBusinessType.IsActive = abt.Business_Types__r.Is_Active__c;
            AccountBusinessType.Status = abt.Status__c;
            AccountBusinessType.StatusReason = abt.Status_Reason__c;
            AccountBusinessType.LastModifiedDate =abt.LastModifiedDate;
            AccountBusinessType.CreatedDate=abt.CreatedDate;
            AccountBusinessType.LastModifiedBy=abt.LastModifiedBy.Name;
            AccountBusinessType.CreatedBy=abt.CreatedBy.Name;
            
            AccountBusinessTypes.add(AccountBusinessType);
        }
        ER_SalesCloud_Integration.ReturnWrapper returnBusinessTypes = new  ER_SalesCloud_Integration.ReturnWrapper();
        returnBusinessTypes.businessTypes = businessTypeSet;
        returnBusinessTypes.accountBusinessTypes = AccountBusinessTypes;
        return returnBusinessTypes;
        
    }
    private static Core_Integration_Outbound_Message__c createAndGetOBM (String MessageType, String payload, String tags){
        Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
        outboundMsg.Core_MessageType__c = MessageType;
        String payloadTemp = '<![CDATA[' +  payload + ']]>';
        outboundMsg.Core_Payload__c = payloadTemp.length()> =131072 ? payloadTemp.substring(0,131072):payloadTemp;
        outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
        return outboundMsg;
    }
    
    //Handles logic of updating ACM Records to success after publishing the platform events
    public static void UpdateACMRecords(Set<Id> ids,String Type)
    {
        Map<String,String>typeMap=new Map<String,String>();
        typeMap.put('Account',Label.ER_ACM_Content_AccountId);
        typeMap.put('Contact',Label.ER_ACM_Content_ContactId);
        typeMap.put('CMF Group',Label.ER_ACM_Content_CMFG);
        try{
            List<ACM_Integration_Message_Queue__c> integrationMessageToUpdate = new List<ACM_Integration_Message_Queue__c>();
            
            For(ACM_Integration_Message_Queue__c integrationMessage : [Select Id,Message_Status__c from ACM_Integration_Message_Queue__c where Custom_Filter__c IN :ids and Content_Type__c= :typeMap.get(Type) and Message_status__c='New' and  Queue_Type__c ='Outbound' and Module_Name__c = :Label.ER_ACM_Module_Name]){
                integrationMessage.Message_Status__c = 'Success';
                integrationMessageToUpdate.add(integrationMessage);
            }  
            
            if(integrationMessageToUpdate != null && integrationMessageToUpdate.size() > 0){
                update integrationMessageToUpdate;
            }
        }
        catch (Exception ex) { 
            createLogEntry('Error in UpdateACMRecords', ex, LOG_ENTRY_ERROR, 'High',params);
            
        }
    }
    public static AE_ACM_Integration_change_event__e createPlatformEvent(String jsonString){
        Integer jsonStringLen = jsonString.length();
        Integer ref = Integer.valueOf(Label.A_E_Integration_Payload_Length);
        Integer count = jsonStringLen/ref;// variable is declared as Integer,apex is ignoring decimal places
        String concat = '';
        AE_ACM_Integration_change_event__e accountChangeEvent=new AE_ACM_Integration_change_event__e();
        accountChangeEvent.Message__c = count == 0 ? jsonString : jsonString.substring(0,ref) ;
        if(count == 1){
            accountChangeEvent.Message1__c = jsonString.substring(ref,jsonStringLen);
        }
        if(count == 2){
			accountChangeEvent.Message1__c = jsonString.substring(ref,2*ref);
            accountChangeEvent.Message2__c = jsonString.substring(2*ref,jsonStringLen);
        }
        if(count == 3){
            accountChangeEvent.Message1__c = jsonString.substring(ref,2*ref);
            accountChangeEvent.Message2__c = jsonString.substring(2*ref,3*ref);
            accountChangeEvent.Message3__c = jsonString.substring(3*ref,jsonStringLen);
        }
        concat = (accountChangeEvent.Message__c != NULL ? accountChangeEvent.Message__c : '')+
                 (accountChangeEvent.Message1__c != NULL ? accountChangeEvent.Message1__c : '')+
                 (accountChangeEvent.Message2__c != NULL ? accountChangeEvent.Message2__c : '')+
            	 (accountChangeEvent.Message3__c != NULL ? accountChangeEvent.Message3__c : '');
        if(concat == jsonString){
            System.debug('Verification-->>TRUE'+count);
        }
        else{
            System.debug('Verification-->>FALSE'+accountChangeEvent.Message1__c);
        }
        return accountChangeEvent;
    }
    
    // Handles logic of publishing Platform Events for Account,Contact, CMF Group changes
    public static Boolean publishAEACMIntegrationChangeEvent(List<AE_ACM_Integration_change_event__e> accountChangeEvents)
    {
        List<Database.SaveResult> eventPublishResultList = new List<Database.SaveResult>();
        Boolean EventPublish=false;
        string exceptiondetails = '';
        try{  
            If(accountChangeEvents.size() > 0) 
            {
                system.debug('587accountChangeEvents'+accountChangeEvents);
                eventPublishResultList = EventBus.publish(accountChangeEvents);
                system.debug('588eventPublishResultList'+eventPublishResultList);
            }
            system.debug('590eventPublishResultList'+eventPublishResultList);
            
            
            for (Database.SaveResult sr : eventPublishResultList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        system.debug('getmessage'+err.getMessage());
                        System.debug('Error returned: ' +err.getStatusCode() + ' - ' +err.getMessage());
                        exceptiondetails += ' Error returned: ' + err.getStatusCode() +' - '+ err.getMessage()+ ' ';
                    }
                    
                }
            }
            System.debug('599exceptiondetails'+exceptiondetails);
            if(string.IsnotBlank(exceptiondetails)){
                EventPublish =false;
                createLogEntry('Error in publishAEACMIntegrationChangeEvent', null, LOG_ENTRY_ERROR, 'High',exceptiondetails);
            }     
            else
            {
                EventPublish =true;
                createLogEntry('Events Published',null, LOG_ENTRY_INFO, 'Medium',params);
            }
            return EventPublish;
        }
        
        catch (Exception ex) {
            createLogEntry('Error in publishAEACMIntegrationChangeEvent', ex, LOG_ENTRY_ERROR, 'High',params);
            return EventPublish;
            
        }
    }
    public class CustomException extends Exception{}
    public class ReturnWrapper{ 
        Set<String> businessTypes;
        List<ER_SalesCloud_Integration_Model.AccountBusinessType> accountBusinessTypes;
        List<ER_SalesCloud_Integration_Model.ContactBusinessType> contactBusinessTypes;
    }
    
    
}