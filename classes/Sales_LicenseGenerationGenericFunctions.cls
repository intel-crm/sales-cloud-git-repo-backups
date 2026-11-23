/*********************************************************************************************************************
Class Name    : Sales_LicenseGenerationGenericFunctions
Version       : 1.0
Created Date  : June 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari           June-2021                 validateDelegateUsers Method 
* 
* ************************************************************************************************************************************************/
@isTest
public without sharing class Sales_LicenseGenerationGenericFunctions {
    /*private static final String LICENSE_STATUS_LICENSED = 'Licensed';
    private static final String LICENSE_STATUS_UNLICENSED = 'Unlicensed';
    private static final String LICENSE_TYPE_FIXED = 'FIXED';
    private static final String LICENSE_TYPE_FLOAT = 'FLOAT';
    private static final String LICENSE_TYPE_NEUTRAL = 'NEUTRAL';
    private static final String LICENSE_TYPE_NA = 'N-A';
    public static  Map<Id,Set<Id>> validateDelegateUsers(Set<id> contactIds){
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        for(Sales_License_Admin_Delegate__c delegateItem : [SELECT Id,Name,Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_DlgAdmin_Email_Txt__c,
                                                            Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c in :contactIds and Sales_License_isActive__c=true]){
                                                                if(delPrimaryContactMap.containsKey(delegateItem.Sales_License_DlgAdmin_Contact__c)){
                                                                    Set<Id> primaryContactSet = new Set<Id>();
                                                                    primaryContactSet = delPrimaryContactMap.get(delegateItem.Sales_License_DlgAdmin_Contact__c);
                                                                    primaryContactSet.add(delegateItem.Sales_License_PrimaryAdmin_Contact__c); 
                                                                    delPrimaryContactMap.put(delegateItem.Sales_License_DlgAdmin_Contact__c,primaryContactSet);
                                                                }
                                                                else
                                                                {  delPrimaryContactMap.put(delegateItem.Sales_License_DlgAdmin_Contact__c,new Set<Id>{delegateItem.Sales_License_PrimaryAdmin_Contact__c});                                                                }                                                        
                                                            }
        return delPrimaryContactMap;
    }
    @AuraEnabled
    public static List<Sales_License_Admin_Delegate__c> getDelegateAdmin(id primaryContactId) {
        List<Sales_License_Admin_Delegate__c> lstDelAdmin;
        User contactinfo=[Select Id, Contact.Id From User Where Id=:userInfo.getUserId()];
        Id Contactid= contactinfo.Contact.Id;
        if(Contactid==null){
            List<Sales_License_ContactUser__c> existingLicConUsr = [Select Id,Sales_License_Contact__c , Sales_License_User__c from Sales_License_ContactUser__c where Sales_License_User__c=: userInfo.getUserId() limit 1];               
            if(!existingLicConUsr.isEmpty()){
                Contactid = existingLicConUsr[0].Sales_License_Contact__c;                    
            }  
        }
        if(Sales_AddNewLicenseAdminController.isCommunity() == false){ 
            if(primaryContactId != null && primaryContactId==Contactid){
                lstDelAdmin = new List<Sales_License_Admin_Delegate__c>([SELECT Id,Name,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_isActive__c,Sales_License_DlgAdmin_FirstName_Txt__c,Sales_License_DlgAdmin_LastName_Txt__c,Sales_License_DlgAdmin_Email_Txt__c, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c FROM Sales_License_Admin_Delegate__c
                                                                         Where Sales_License_PrimaryAdmin_Contact__c =:primaryContactId and Sales_License_PrimaryAdmin_Contact__c =:Contactid ] );
            }
        }
        else{
            if(primaryContactId != null){
                lstDelAdmin = new List<Sales_License_Admin_Delegate__c>([SELECT Id,Name,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_isActive__c,Sales_License_DlgAdmin_FirstName_Txt__c,Sales_License_DlgAdmin_LastName_Txt__c,Sales_License_DlgAdmin_Email_Txt__c, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c FROM Sales_License_Admin_Delegate__c
                                                                         Where Sales_License_PrimaryAdmin_Contact__c =:primaryContactId] );
            }
        }
        return lstDelAdmin;
    }
    @AuraEnabled 
    public static String getPrimaryCtId(String id){
        return [select Sales_License_Primary_Admin_Contact__c from Sales_License__c where id=:id ]?.Sales_License_Primary_Admin_Contact__c;
    }
    public static Boolean askForhostReassigment(Set<Id> hostIds, Set<id> licenseIds) {
        //Sales_LicenseRecordPageComponentsUtility.BypassTriggerReassignmentLogic=true;
        Boolean isLicenseExist = false;
        Set<Id> productIdsSet = new Set<Id>();
        for(Sales_License__c lic: [Select Id, Sales_License_Product__c from Sales_License__c where Id IN: licenseIds]){
            if(lic.Sales_License_Product__c != null){
                productIdsSet.add(lic.Sales_License_Product__c);    
            }    
        }
        for(Sales_Host__c hostObj : [Select Id, (Select Id,Sales_Tool_License_Type__c From Licenses__r where Sales_License_Product__c IN: productIdsSet and Sales_Tool_License_Type__c='FIXED') from Sales_Host__c Where Id IN :hostIds and Sales_License_Type__c='FIXED']){
            for(Sales_License__c license : hostObj.Licenses__r){
                if(licenseIds.contains(license.Id)){
                    isLicenseExist= false;
                }else if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                    isLicenseExist= true;
                }else {isLicenseExist= false;}
            }
        }
        return isLicenseExist;
    }
    public static String hostReassigmentLogic(Map<Id,Id> mapofInputs) {
        //Sales_LicenseRecordPageComponentsUtility.BypassTriggerReassignmentLogic=true;
        Map<Id, Sales_License__c> hostHasLicenseMap = new Map<Id, Sales_License__c>();
        String isReturnMsg='';        
        List<Sales_License__c> originalicenseList = new List<Sales_License__c>();
        List<Sales_License__c> updatelicenseList = new List<Sales_License__c>();
        Map<Id, Sales_License__c> mapOfLicObjOldLicense = new Map<Id, Sales_License__c>();
        Set<id> hostwithNoLicense = new Set<id>();
        Integer count=0;
        for(Sales_Host__c hostObj : [Select Id, (Select Id From Licenses__r limit 1) from Sales_Host__c Where Id IN :mapofInputs.keySet()]){
            if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                hostHasLicenseMap.put(hostObj.id, hostObj.Licenses__r);
            }else {hostwithNoLicense.add(hostObj.Id);}
        }
        Map<Id, Sales_License__c> licensetobeupdated = new Map<Id, Sales_License__c>([SELECT Id,Sales_Tool_License_Type__c, Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Host_Node_Id__c, 
                                                                                      Sales_License_Activation_Code__c,Sales_License_Status__c, Sales_License_Product__c from Sales_License__c where ID IN :mapofInputs.values()]);
        for(Sales_License__c lic: licensetobeupdated.values()){
            Sales_License__c oldLic = new Sales_License__c();
            oldLic.Sales_License_Host_Node_Id__c = lic.Sales_License_Host_Node_Id__c;
            oldLic.Sales_License_Status__c = lic.Sales_License_Status__c;
            oldLic.Sales_License_Avbl_Rehost_Nbr__c = lic.Sales_License_Avbl_Rehost_Nbr__c;
            mapOfLicObjOldLicense.put(lic.id, oldLic);
        }
        if(hostwithNoLicense.size()>0){
            Sales_License__c lcObj;
            for(Id hostId : hostwithNoLicense){
                lcObj = licensetobeupdated.get(mapofInputs.get(hostId));
                if((lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c != null) && (lcObj.Sales_License_Avbl_Rehost_Nbr__c>0)){
                    lcObj.Sales_License_Host_Node_Id__c = hostId;
                    lcObj.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                    lcObj.Sales_License_Avbl_Qty_Nbr__c = 0;
                    lcObj.Sales_License_Avbl_Rehost_Nbr__c=lcObj.Sales_License_Avbl_Rehost_Nbr__c-1;
                }
                else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==0 && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                    isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;
                }
                else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==null && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                    isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;
                }
                if(lcObj.Sales_License_Status__c!= LICENSE_STATUS_LICENSED && lcObj.Sales_License_Host_Node_Id__c==null){
                    lcObj.Sales_License_Host_Node_Id__c = hostId;
                    lcObj.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                    lcObj.Sales_License_Avbl_Qty_Nbr__c = 0;
                }
                if(!updatelicenseList.contains(lcObj)){
                    updatelicenseList.add(lcObj);
                }
            }
        }
        Boolean isAvlblRehostDecrementedOnTargetLic = false;
        for(Sales_License__c lc : [SELECT Id, Sales_License_Product__c, Sales_Tool_License_Type__c, Sales_License_Host_Node_Id__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Activation_Code__c,Sales_License_Status__c from Sales_License__c where Sales_License_Host_Node_Id__c IN : hostHasLicenseMap.keySet()]){
            Sales_License__c lcObj;
            if(mapofInputs.containsKey(lc.Sales_License_Host_Node_Id__c)){
                lcObj = licensetobeupdated.get(mapofInputs.get(lc.Sales_License_Host_Node_Id__c));
                Sales_License__c oldLic = mapOfLicObjOldLicense.get(lcObj.id);
                if(lc.Sales_License_Host_Node_Id__c != oldLic.Sales_License_Host_Node_Id__c || oldLic.Sales_License_Host_Node_Id__c == null){
                    if(lc.Sales_Tool_License_Type__c ==LICENSE_TYPE_FIXED && lcObj.Sales_Tool_License_Type__c == LICENSE_TYPE_FIXED){                                                 
                        if(lc.Sales_License_Host_Node_Id__c!=null) {
                            if((oldLic.Sales_License_Avbl_Rehost_Nbr__c > 0) || ((oldLic.Sales_License_Avbl_Rehost_Nbr__c==0 || oldLic.Sales_License_Avbl_Rehost_Nbr__c==null) && (oldLic.Sales_License_Host_Node_Id__c==null) && (oldLic.Sales_License_Status__c!= LICENSE_STATUS_LICENSED))){
                                if(isAvlblRehostDecrementedOnTargetLic == false && ((lcObj.Sales_License_Avbl_Rehost_Nbr__c > 0 && lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED) || lcObj.Sales_License_Host_Node_Id__c!=null)){
                                    lcObj.Sales_License_Avbl_Rehost_Nbr__c = lcObj.Sales_License_Avbl_Rehost_Nbr__c - 1;
                                    isAvlblRehostDecrementedOnTargetLic = true;
                                }
                                lcObj.Sales_License_Host_Node_Id__c = lc.Sales_License_Host_Node_Id__c;
                                if(oldLic.Sales_License_Status__c == LICENSE_STATUS_UNLICENSED){
                                    isAvlblRehostDecrementedOnTargetLic = true;
                                }
                                lcObj.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                                lcObj.Sales_License_Avbl_Qty_Nbr__c = 0;
                                if(lc.Sales_License_Product__c == lcObj.Sales_License_Product__c){
                                    lc.Sales_License_Host_Node_Id__c = null;
                                }
                                if(!originalicenseList.contains(lc)){
                                    originalicenseList.add(lc);
                                }
                                if(!updatelicenseList.contains(lcObj)){
                                    updatelicenseList.add(lcObj);
                                }
                            }
                            else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==0 && ((lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED  && isAvlblRehostDecrementedOnTargetLic == false )/*|| lcObj.Sales_License_Host_Node_Id__c!=null*//*)){
                                if(isReturnMsg==''){
                                    isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;
                                }
                            }
                            else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==null && ((lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED && isAvlblRehostDecrementedOnTargetLic == false)/* || lcObj.Sales_License_Host_Node_Id__c!=null*//*) && isReturnMsg==''){
                                isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;
                            }
                        }
                    }else if((lcObj.Sales_Tool_License_Type__c ==LICENSE_TYPE_FLOAT  || lcObj.Sales_Tool_License_Type__c ==LICENSE_TYPE_NEUTRAL || lcObj.Sales_Tool_License_Type__c ==LICENSE_TYPE_NA || lc.Sales_Tool_License_Type__c !=LICENSE_TYPE_FIXED) && count==0 ){
                        lcObj = licensetobeupdated.get(mapofInputs.get(lc.Sales_License_Host_Node_Id__c));
                        if((oldLic.Sales_License_Avbl_Rehost_Nbr__c > 0) || (((oldLic.Sales_License_Avbl_Rehost_Nbr__c==0) || (oldLic.Sales_License_Avbl_Rehost_Nbr__c==null)) && (oldLic.Sales_License_Host_Node_Id__c==null))){
                            if(isAvlblRehostDecrementedOnTargetLic == false && (((oldLic.Sales_License_Avbl_Rehost_Nbr__c > 0 && oldLic.Sales_License_Status__c== LICENSE_STATUS_LICENSED) || oldLic.Sales_License_Host_Node_Id__c!=null) && count==0)){
                                lcObj.Sales_License_Avbl_Rehost_Nbr__c = lcObj.Sales_License_Avbl_Rehost_Nbr__c - 1;
                                isAvlblRehostDecrementedOnTargetLic = true;
                            }
                            lcObj.Sales_License_Host_Node_Id__c = lc.Sales_License_Host_Node_Id__c;
                            lcObj.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                            lcObj.Sales_License_Avbl_Qty_Nbr__c = 0;
                            if(!originalicenseList.contains(lc)){
                                originalicenseList.add(lc);
                            }
                            if(!updatelicenseList.contains(lcObj)){ 
                                updatelicenseList.add(lcObj);
                            }
                            if(oldLic.Sales_License_Avbl_Rehost_Nbr__c==0 && (oldLic.Sales_License_Status__c== LICENSE_STATUS_LICENSED || oldLic.Sales_License_Host_Node_Id__c!=null)){
                                if(isReturnMsg==''){
                                    isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;
                                }
                            }
                            else if(oldLic.Sales_License_Avbl_Rehost_Nbr__c==null && (oldLic.Sales_License_Status__c== LICENSE_STATUS_LICENSED || oldLic.Sales_License_Host_Node_Id__c!=null) && isReturnMsg==''){ 
                                isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;
                            }
                            count++;
                        }
                        else if(oldLic.Sales_License_Avbl_Rehost_Nbr__c==0 && (oldLic.Sales_License_Status__c== LICENSE_STATUS_LICENSED || oldLic.Sales_License_Host_Node_Id__c!=null)){
                            if(isReturnMsg==''){
                                isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;
                            }
                        }
                        else if(oldLic.Sales_License_Avbl_Rehost_Nbr__c==null && (oldLic.Sales_License_Status__c== LICENSE_STATUS_LICENSED || oldLic.Sales_License_Host_Node_Id__c!=null) && isReturnMsg=='' ){
                            isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;
                        }    
                    }   
                }
                else
                {
                    isReturnMsg = System.Label.Sales_SuccessHostReassignment;
                }
            }
        }
        if(updatelicenseList.size()>0){
            try{if(String.isBlank(isReturnMsg) || isReturnMsg == System.label.Sales_SuccessHostReassignment){update updatelicenseList;}
                if(isReturnMsg=='' ){isReturnMsg = System.Label.Sales_SuccessHostReassignment;}
               }catch(Exception e){
                   if(e.getMessage().contains('_EXCEPTION')){
                       String pureErrorMessage = e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                       isReturnMsg = pureErrorMessage;
                   }else{isReturnMsg = e.getMessage();} 
               }                                                                                           
        }
        if(originalicenseList.size() > 0){
            try{if(String.isBlank(isReturnMsg) || isReturnMsg == System.label.Sales_SuccessHostReassignment){update originalicenseList;}
                if(isReturnMsg==''){isReturnMsg = System.Label.Sales_SuccessHostReassignment;}
               }catch(Exception e){
                   if(e.getMessage().contains('_EXCEPTION')){
                       String pureErrorMessage = e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                       isReturnMsg = pureErrorMessage;
                   }else{isReturnMsg = e.getMessage();}
               }
        }
        return isReturnMsg;
    }
    public static Date getLastDateOfMonth(Date dt){
        Date result;
        Integer noOfDays;
        if(dt != null){noOfDays = Date.daysInMonth(dt.year(), dt.month());
                       result = date.newInstance(dt.year(), dt.month(), noOfDays);
                      }return result;
    }
    public static void applyRenewals(List<Sales_License__c> baselicensesList){
        List<Sales_License__c> listOfLicensesToProcess = new List<Sales_License__c>();
        Set<Id> licenseIds = new Set<id>();
        Set<Id> contactId = new Set<Id>();
        Map<Id,Id> delPrimaryContactMap = new Map<Id,Id>();
        Set<id> foundProdIdSet = new Set<Id>();
        Integer prodExpiryDurationInDays;
        Integer prodMaintenanceDurInMonths;
        Integer prodRenewalGracePeriodInDays;
        Integer prodAdditionExpDurationGracePeriod ;
        Integer prodSubscriptionTerm;
        String hostId;
        date maintDate;
        date licenseDate;
        date dte;
        Boolean ismaintainance =false;
        Boolean isLicense = false;
        Set<Id> hostSet = new Set<Id>();
        List<Sales_License__c> baseLicList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Renewed_Date__c,Sales_License_Renewal_Status__c,
                                              Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                              Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Product__r.SBQQ__SubscriptionTerm__c,Sales_License_Host_Node_Id__c FROM Sales_License__c where Id IN : baselicensesList AND Sales_License_Type__c != 'Evaluation' AND Sales_License_Status__c ='Licensed' ];
        for(Sales_License__c baselic : baseLicList){
            if(baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c != null){
                prodExpiryDurationInDays = (Integer)baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c;
            }
            else{prodExpiryDurationInDays= 0;
                }
            if(baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Renewal_Period_Nbr__c != null){
                prodRenewalGracePeriodInDays = (Integer)baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Renewal_Period_Nbr__c;
            }
            else {prodRenewalGracePeriodInDays = 0;
                 }
            if(baselic.Sales_License_Product__r.SBQQ__SubscriptionTerm__c != null){
                prodSubscriptionTerm = (Integer)baselic.Sales_License_Product__r.SBQQ__SubscriptionTerm__c;
            }
            else {prodSubscriptionTerm = 0; 
                 }
            prodAdditionExpDurationGracePeriod = prodExpiryDurationInDays + prodRenewalGracePeriodInDays;
            if( prodExpiryDurationInDays <= 0 || prodExpiryDurationInDays == null){
                baselic.Sales_License_Expiration_Date_Dt__c = null;
            }
            else if((prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0 ) && prodExpiryDurationInDays > 0){
                if(baselic.Sales_License_Maintenance_Exp_Dt__c != null && baselic.Sales_License_Maintenance_Exp_Dt__c >= Date.Today()){
                    baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(baselic.Sales_License_Maintenance_Exp_Dt__c.addDays(prodExpiryDurationInDays)).addDays(1); 
                }else{
                    baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1); 
                }
            }
            else if(prodRenewalGracePeriodInDays > 0  
                    && baselic.Sales_License_Maintenance_Exp_Dt__c >(Date.today()) && prodExpiryDurationInDays > 0){   
                        baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth (baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodExpiryDurationInDays)).addDays(1);
                    }
            else  if(prodRenewalGracePeriodInDays > 0  
                     &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today())) && prodExpiryDurationInDays != null && baselic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                         baselic.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1);
                     }
            else if(prodRenewalGracePeriodInDays > 0   
                    &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today())) && prodExpiryDurationInDays != null && baselic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                        baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodAdditionExpDurationGracePeriod)).addDays(1);
                    }
            if(prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0){
                if(baselic.Sales_License_Maintenance_Exp_Dt__c != null && baselic.Sales_License_Maintenance_Exp_Dt__c >= Date.today()){
                    baselic.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(baselic.Sales_License_Maintenance_Exp_Dt__c.addMonths(prodSubscriptionTerm));                      
                }else{
                    baselic.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));  
                }
            }
            else if(prodRenewalGracePeriodInDays > 0 
                    && baselic.Sales_License_Maintenance_Exp_Dt__c >(Date.today())){
                        baselic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(baselic.Sales_License_Maintenance_Exp_Dt__c?.addMonths(prodSubscriptionTerm));
                    }
            else if(prodRenewalGracePeriodInDays > 0 
                    &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today()))){
                        baselic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));
                    }
            else if(prodRenewalGracePeriodInDays > 0 
                    &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today()))){
                        dte = baselic.Sales_License_Maintenance_Exp_Dt__c?.addMonths(prodSubscriptionTerm);
                        baselic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(dte.addDays(prodRenewalGracePeriodInDays));
                    }
            baselic.Sales_License_Avbl_Rehost_Nbr__c = baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;
            if(baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c==true){
                baselic.Sales_License_Available_Temp_Licenses__c = baselic.Sales_License_Quantity__c;
            }
            baselic.Sales_License_Comments_Txt__c='License was automatically renewed by System on '+date.today().format();
            baselic.Sales_License_Renewal_Status__c = 'License Renewed';
            baselic.Sales_License_Renewed_Date__c = Date.today();
            listOfLicensesToProcess.add(baselic);
            if(baselic.Sales_License_Host_Node_Id__c!=null){
                hostId=baselic.Sales_License_Host_Node_Id__c;
                hostSet.add(baselic.Sales_License_Host_Node_Id__c);
            }
        }
        if(listOfLicensesToProcess.size()>0){
            update(listOfLicensesToProcess);             
        }
        //System.enqueueJob(new Sales_BulkHostProcessLicGenQueueable(hostSet,'autorenewal'));
    }*/
}