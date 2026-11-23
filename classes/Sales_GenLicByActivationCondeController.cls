/*********************************************************************************************************************
Class Name    : Sales_GenLicByActivationCondeController
Version       : 1.0
Created Date  : June 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           June-2021				 Called from Aura Component- Generate License by activation Code
* Jasmine Narula		June-2021
* ************************************************************************************************************************************************/
public without sharing class Sales_GenLicByActivationCondeController {
    private static final String LICENSE_STATUS_UNLICENSED='Unlicensed';
    private static final String ORDER_REASON_STOCKING_ORDER='Stocking Order';
    public static boolean isCustomOps;
    @AuraEnabled
    public static List<wrapperforActivationLicense> validateLicenses(Sales_License__c licRecord) {
        List<Sales_License__c> licList;
        //List<Id> licIdsListToReturn = new List<Id>();--unsed Variable
        //Set<Id> primaryContactIds = new Set<Id>();--Unsed Variable
        Set<Id> contactsIds = new Set<Id>();
        Id accountId;
        Set<id> directECAccountIds = new Set<id>();
        Boolean validateMentorGraphic = false;
        List<wrapperforActivationLicense> wrapperClass = new List<wrapperforActivationLicense>();
        Id primaryAdminContactIdToBeUpdated;
        Set<Id> licIdsToUpdate = new Set<Id>();
        List<Id> delPrimaryContactMap = new List<Id>();
        if(licRecord != null){
            User loggedInUser;
            if(licRecord.Sales_License_Primary_Admin_Contact__c != null){
                primaryAdminContactIdToBeUpdated = licRecord.Sales_License_Primary_Admin_Contact__c;
            }
            loggedInUser = [Select Id, ContactId, Contact.AccountId from User where Id = :UserInfo.getUserId()];
            if(primaryAdminContactIdToBeUpdated == null){
                primaryAdminContactIdToBeUpdated = loggedInUser.ContactId;
                accountId = loggedInUser.Contact.AccountId;
            }
            if(accountId == null && primaryAdminContactIdToBeUpdated!=null){
                Contact con = [Select id, Accountid from contact where id = :primaryAdminContactIdToBeUpdated];                
                accountId = con.AccountId;
            }
            List<Account> directECAccount = [Select id from Account where ParentId = :accountId and Core_Direct_Account_Type_Nm__c = 'End Customer'];
            for(Account acc : directECAccount){
                directECAccountIds.add(acc.Id);
            }
            contactsIds.add(primaryAdminContactIdToBeUpdated);
            if(contactsIds.size()>0){
                delPrimaryContactMap = validateDelegateUsers(contactsIds);
            }
        }
        isCustomOps=Sales_ValidateUserEditAccess.BypassRehostForCustomOps();
        if(isCustomOps==true)
        {
            licList = [Select Id, Sales_License_Product__c,Sales_License_Primary_Admin_Contact__c, Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Available_Temp_Licenses__c,Sales_License_Type__c,
                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c,Sales_License_Quantity__c,Sales_License_Status__c,Sales_License_Order__r.Sales_Order_Reason__c,Sales_License_Account__c,
                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License_Web_Display_Flag__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Primary_Admin_Contact__r.AccountId from Sales_License__c
                       where Sales_License_Activation_Code__c = :licRecord.Sales_License_Activation_Code__c];
        }
        else{
            licList = [Select Id, Sales_License_Product__c,Sales_License_Primary_Admin_Contact__c, Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Available_Temp_Licenses__c,Sales_License_Type__c,
                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c,Sales_License_Quantity__c,Sales_License_Status__c,Sales_License_Order__r.Sales_Order_Reason__c,Sales_License_Account__c,
                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License_Web_Display_Flag__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                       Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Primary_Admin_Contact__r.AccountId from Sales_License__c
                       where Sales_License_Activation_Code__c = :licRecord.Sales_License_Activation_Code__c and Sales_License_Web_Display_Flag__c=true]; 
        }
        Boolean isValidLicense;
        if(licList.size() > 0){
            for(Sales_License__c lic: licList){
                if(delPrimaryContactMap.contains(lic.Sales_License_Primary_Admin_Contact__c) || primaryAdminContactIdToBeUpdated == lic.Sales_License_Lic_User_Contact_ID__c || primaryAdminContactIdToBeUpdated == lic.Sales_License_Primary_Admin_Contact__c){
                    licIdsToUpdate.add(lic.Id);
                }else{
                    if(lic.Sales_License_Status__c==LICENSE_STATUS_UNLICENSED && lic.Sales_License_Order__r.Sales_Order_Reason__c==ORDER_REASON_STOCKING_ORDER){
                        isValidLicense = Sales_GenLicByActivationCondeController.validateMentorGraphics(lic.Sales_License_Product__c,directECAccountIds,accountId);
                        if(isValidLicense){
                            licIdsToUpdate.add(lic.Id);
                        }
                    }
                }
            }
        }
        if(licIdsToUpdate.size() >0){
            wrapperClass = fetchLicenseInformation(licIdsToUpdate);
        }
        return wrapperClass;
    }
    @AuraEnabled
    public static List<wrapperforActivationLicense> fetchLicenseDetails(String activationCode){
        List<Sales_License__c> licenseList = new  List<Sales_License__c>();
        List<wrapperforActivationLicense> wrapperClass = new List<wrapperforActivationLicense>();
        if(!String.isBlank(activationCode)){
            licenseList= [SELECT id,Name,Sales_License_Activation_Code__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Product__r.Name,
                          Sales_License_Quantity__c,Sales_Tool_License_Type__c, Sales_License_Type__c,Sales_License_Status__c from Sales_License__c where Sales_License_Activation_Code__c =:activationCode];
        }
        if(licenseList.size()==1){
            for(Sales_License__c lc : licenseList){
                wrapperforActivationLicense lst = new wrapperforActivationLicense();
                lst.licenseActivationCode = lc.Sales_License_Activation_Code__c;
                lst.productName = lc.Sales_License_Product__r.Name;
                lst.noOfSeats = lc.Sales_License_Quantity__c;
                lst.licenseToolType = lc.Sales_Tool_License_Type__c;
                lst.licType = lc.Sales_License_Type__c;
                lst.licenseName = lc.Name;
                lst.isHost = lc.Sales_License_Host_Node_Id__c;
                lst.webdisplayflag = lc.Sales_License_Web_Display_Flag__c;
                lst.licenserecordId = lc.Id;
                lst.licenseStatus = lc.Sales_License_Status__c;
                wrapperClass.add(lst);
            }          
        }
        return wrapperClass;
    }
    public static  List<Id> validateDelegateUsers(Set<id> contactIds){
        List<Id> delPrimaryContactMap = new List<Id>();
        for(Sales_License_Admin_Delegate__c delegateItem : [SELECT Id,Name,Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_DlgAdmin_Email_Txt__c,
                                                            Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c in :contactIds and Sales_License_isActive__c=true]){
                                                                if(!delPrimaryContactMap.contains(delegateItem.Sales_License_PrimaryAdmin_Contact__c))
                                                                    delPrimaryContactMap.add(delegateItem.Sales_License_PrimaryAdmin_Contact__c);                                                            
                                                            }
        return delPrimaryContactMap;
    }
    public static List<wrapperforActivationLicense> fetchLicenseInformation(Set<Id> inputlicenseList){
        List<wrapperforActivationLicense> wrapperClass = new List<wrapperforActivationLicense>();
        List<Sales_License__c> licenseList = new  List<Sales_License__c>();
        isCustomOps=Sales_ValidateUserEditAccess.BypassRehostForCustomOps();
        if(isCustomOps==true) {
            licenseList= [SELECT id,Name,Sales_License_Activation_Code__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Product__r.Name,
                          Sales_License_Quantity__c,Sales_License_Status__c,Sales_Tool_License_Type__c, Sales_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c
                          from Sales_License__c where Id IN:inputlicenseList and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!='ADD SEAT'
                          and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!='RENEWAL' and Sales_License_Type__c!='ADD SEAT' and Sales_License_Type__c!='RENEWAL'];
        }
        else{
            licenseList= [SELECT id,Name,Sales_License_Activation_Code__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Product__r.Name,
                          Sales_License_Quantity__c,Sales_License_Status__c,Sales_Tool_License_Type__c, Sales_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c
                          from Sales_License__c where Id IN:inputlicenseList and Sales_License_Web_Display_Flag__c=true and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!='ADD SEAT'
                          and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!='RENEWAL' and Sales_License_Type__c!='ADD SEAT' and Sales_License_Type__c!='RENEWAL'];
        }
        for(Sales_License__c lc : licenseList){
            wrapperforActivationLicense lst = new wrapperforActivationLicense();
            lst.licenseActivationCode = lc.Sales_License_Activation_Code__c;
            lst.productName = lc.Sales_License_Product__r.Name;
            lst.noOfSeats = lc.Sales_License_Quantity__c;
            lst.licenseToolType = lc.Sales_Tool_License_Type__c;
            lst.licType = lc.Sales_License_Type__c;
            lst.licenseName = lc.Name;
            lst.isHost = lc.Sales_License_Host_Node_Id__c;
            lst.webdisplayflag = lc.Sales_License_Web_Display_Flag__c;
            lst.licenserecordId = lc.Id;
            lst.productToolType= lc.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c;
            lst.licenseStatus = lc.Sales_License_Status__c;
            wrapperClass.add(lst);
        }          
        return wrapperClass;
    }
    public with sharing class wrapperforActivationLicense{
        @AuraEnabled public String licenseActivationCode;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal noOfSeats;
        @AuraEnabled public String licenseToolType;
        @AuraEnabled public String licType;
        @AuraEnabled public Id licenserecordId;
        @AuraEnabled public String licenseName;
        @AuraEnabled public String isHost;
        @AuraEnabled public Boolean webdisplayflag;
        @AuraEnabled public String productToolType;
        @AuraEnabled public String licenseStatus;
    }
    public static Boolean validateMentorGraphics(Id prodId, Set<Id> directECAccountIds, Id accountId){
        Boolean isValidLicense = true;
        List<Sales_License_Control__c>  licControlList = new List<Sales_License_Control__c> ();
        licControlList = [Select Id,Sales_InActive_Ind__c,Sales_Account_Competitor__c from Sales_License_Control__c where Sales_Product__c =:prodId
                          and (Sales_Account_Competitor__c IN :directECAccountIds or Sales_Account_Competitor__c=:accountId)];
        if(licControlList.size()>0){
            for(Sales_License_Control__c lc : licControlList){
                if(directECAccountIds.contains(lc.Sales_Account_Competitor__c) && lc.Sales_InActive_Ind__c == false){
                    isValidLicense = false;break;
                }
                if(lc.Sales_Account_Competitor__c==accountId && lc.Sales_InActive_Ind__c == false){
                    isValidLicense = false;break;
                }
            }
        }else{
            isValidLicense = true;
        }
        return isValidLicense;
    }
    @AuraEnabled
    public static Boolean updateLiceseRecord(Id licRecord, Id primaryAdmin) {
        Boolean isInternal = Sales_AddNewLicenseAdminController.isCommunity();
        Boolean isSuccess=false;        
        Id primaryAdminContactIdToBeUpdated;
        Id accountId;
        Set<Id> contactsIds= new Set<Id>();
        List<Id> delPrimaryContactMap = new List<Id>();
        List<Sales_License__c> licListToUpdate = new List<Sales_License__c>();
        User loggedInUser;
        if(primaryAdmin != null){
            primaryAdminContactIdToBeUpdated = primaryAdmin;
        }
        loggedInUser = [Select Id, ContactId, Contact.AccountId from User where Id = :UserInfo.getUserId()];
        if(primaryAdminContactIdToBeUpdated == null){
            primaryAdminContactIdToBeUpdated = loggedInUser.ContactId;accountId = loggedInUser.Contact.AccountId;
        }
        if(accountId == null && primaryAdminContactIdToBeUpdated!=null){
            Contact con = [Select id, Accountid from contact where id = :primaryAdminContactIdToBeUpdated];                
            accountId = con.AccountId;
        }
        contactsIds.add(primaryAdminContactIdToBeUpdated);
        if(contactsIds.size()>0){
            delPrimaryContactMap = validateDelegateUsers(contactsIds);
        }
        Sales_License__c lic = [SELECT id,Sales_License_Primary_Admin_Contact__c, Sales_License_Account__c, Sales_License_Start_Date_Dt__c,Sales_License_Avbl_Rehost_Nbr__c,
                                Sales_License_Available_Temp_Licenses__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c,
                                Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Quantity__c,
                                Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,
                                Sales_License_Product__r.SBQQ__SubscriptionTerm__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c 
                                from Sales_License__c where id =:licRecord];
        Integer prodMaintExpSubTermInMonths;
        Integer prodExpiryDurationInDays;
        if(lic.Sales_License_Primary_Admin_Contact__c!=primaryAdminContactIdToBeUpdated){
            if(delPrimaryContactMap.contains(lic.Sales_License_Primary_Admin_Contact__c)  || primaryAdminContactIdToBeUpdated == lic.Sales_License_Lic_User_Contact_ID__c || primaryAdminContactIdToBeUpdated == lic.Sales_License_Primary_Admin_Contact__c){
                isSuccess = true;
            }else{
                lic.Sales_License_Primary_Admin_Contact__c = primaryAdminContactIdToBeUpdated;
                lic.Sales_License_Account__c = accountId;
                lic.Sales_License_Start_Date_Dt__c = Date.today();
                if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c == true){
                    lic.Sales_License_Avbl_Rehost_Nbr__c = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c; 
                }
                if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c == true){
                    lic.Sales_License_Available_Temp_Licenses__c = lic.Sales_License_Quantity__c;
                }
                if(lic.Sales_License_Product__r.SBQQ__SubscriptionTerm__c!=null){
                    prodMaintExpSubTermInMonths = (Integer)lic.Sales_License_Product__r.SBQQ__SubscriptionTerm__c;
                    lic.Sales_License_Maintenance_Exp_Dt__c = Sales_LicenseTriggerUtility.getLastDateOfMonth(lic.Sales_License_Start_Date_Dt__c.addMonths(prodMaintExpSubTermInMonths));
                }
                if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c!=null){
                    prodExpiryDurationInDays = (Integer)lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c;    
                    lic.Sales_License_Expiration_Date_Dt__c = Sales_LicenseTriggerUtility.getLastDateOfMonth(lic.Sales_License_Start_Date_Dt__c.addDays(prodExpiryDurationInDays)).addDays(1);                                      
                }
                licListToUpdate.add(lic);
                if(!licListToUpdate.isEmpty()){
                    update licListToUpdate;
                    isSuccess = true;
                }
            }
        }else{
            isSuccess = true;
        }
        return isSuccess;
    }
}