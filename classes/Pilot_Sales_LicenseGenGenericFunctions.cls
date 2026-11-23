/*********************************************************************************************************************
Class Name    : Pilot_Sales_LicenseGenGenericFunctions
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari            22/09/2021              Pilot Project for testing framework.
* ************************************************************************************************************************************************/
public  without sharing class Pilot_Sales_LicenseGenGenericFunctions {
    private static final String LICENSE_STATUS_LICENSED = 'Licensed';
    private static final String LICENSE_TYPE_FIXED = 'FIXED';
    private static final String LICENSE_TYPE_FLOAT = 'FLOAT';
    private static final String LICENSE_TYPE_NEUTRAL = 'NEUTRAL';
    private static final String LICENSE_TYPE_NA = 'N-A';
    
    //this method will validate for delegateUsers
    public static  Map<Id,Id> validateDelegateUsers(Set<id> contactIds){
        Map<Id,Id> delPrimaryContactMap = new Map<Id,Id>();//storing Delegate admin and Primary Admin in the delPrimaryContactMap map and returning the same
        //for(Sales_License_Admin_Delegate__c delegateItem : [SELECT Id,Name,Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_DlgAdmin_Email_Txt__c,
        //                                                    Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c in :contactIds and Sales_License_isActive__c=true]){
        for(Sales_License_Admin_Delegate__c delegateItem : SEL_Sales_License_Admin_Delegate.newInstance().selectByContactIdsAndIsActive(contactIds)){
        	delPrimaryContactMap.put(delegateItem.Sales_License_DlgAdmin_Contact__c,delegateItem.Sales_License_PrimaryAdmin_Contact__c);                                                            
        }
        return delPrimaryContactMap;
    }
    
    // Delegate Admin Related List of License
    @AuraEnabled
    public static List<Sales_License_Admin_Delegate__c> getDelegateAdmin(id primaryContactId) {
        List<Sales_License_Admin_Delegate__c> lstDelAdmin;
        if(primaryContactId != null){// Fetching Delegate Admin Details via Querying and Storing the data in List
            //lstDelAdmin = new List<Sales_License_Admin_Delegate__c>([SELECT Id,Name,Sales_License_DlgAdmin_Contact__r.Name,Sales_License_isActive__c,Sales_License_DlgAdmin_FirstName_Txt__c,Sales_License_DlgAdmin_LastName_Txt__c,Sales_License_DlgAdmin_Email_Txt__c, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c FROM Sales_License_Admin_Delegate__c
            //                                                         Where Sales_License_PrimaryAdmin_Contact__c =:primaryContactId] );
            lstDelAdmin = new List<Sales_License_Admin_Delegate__c>(SEL_Sales_License_Admin_Delegate.newInstance().selectByPrimaryContactId(primaryContactId));
        }
        return lstDelAdmin;
    }
    
    @AuraEnabled 
    public static String getPrimaryCtId(String id){
        //return [select Sales_License_Primary_Admin_Contact__c from Sales_License__c where id=:id ]?.Sales_License_Primary_Admin_Contact__c;
    	return [select Sales_License_Primary_Admin_Contact__c from Sales_License__c where id=:id ]?.Sales_License_Primary_Admin_Contact__c;
    }
    
    //this method will check if any host is associated to some existing license
    public static Boolean askForhostReassigment(Set<Id> hostIds, Set<id> licenseIds) {
        Boolean isLicenseExist = false;
        Set<Id> productIdsSet = new Set<Id>();
        //Get the product id of the source license
        //Added as part of US1094912: Check if product also matches on license along with host
        //for(Sales_License__c lic: [Select Id, Sales_License_Product__c from Sales_License__c where Id IN: licenseIds]){
        for(Sales_License__c lic: SEL_Sales_License.newInstance().selectByIds(licenseIds)){
            if(lic.Sales_License_Product__c != null){
                productIdsSet.add(lic.Sales_License_Product__c);    
            }    
        }
        //check if license exist for the same host and same product
        //for(Sales_Host__c hostObj : [Select Id, (Select Id From Licenses__r where Sales_License_Product__c IN: productIdsSet) from Sales_Host__c Where Id IN :hostIds]){
        for(Sales_Host__c hostObj : SEL_Sales_Host.newInstance().selectByHostIds(productIdsSet, hostIds)){
            for(Sales_License__c license : hostObj.Licenses__r){
                if(licenseIds.contains(license.Id)){
                    isLicenseExist= false;
                }else if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {isLicenseExist= true;
                                                                                         }else {isLicenseExist= false;}
            }
        }
        return isLicenseExist;
    }
    
    //method to check host Reassignment
    public static String hostReassigmentLogic(Map<Id,Id> mapofInputs) {
        Map<Id, Sales_License__c> hostHasLicenseMap = new Map<Id, Sales_License__c>();
        String isReturnMsg='';        
        List<Sales_License__c> originalicenseList = new List<Sales_License__c>();
        List<Sales_License__c> updatelicenseList = new List<Sales_License__c>();
        Set<id> hostwithNoLicense = new Set<id>();
        Integer count=0;
        //for(Sales_Host__c hostObj : [Select Id, (Select Id From Licenses__r limit 1) from Sales_Host__c Where Id IN :mapofInputs.keySet()]){
        for(Sales_Host__c hostObj :SEL_Sales_Host.newInstance().selectByHostIdsAndLimit(mapofInputs.keySet())){
            if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                hostHasLicenseMap.put(hostObj.id, hostObj.Licenses__r);
            }else {hostwithNoLicense.add(hostObj.Id);}
        }
        Set<Id> licIdsSet = new Set<Id>(mapofInputs.values());
        //Map<Id, Sales_License__c> licensetobeupdated = new Map<Id, Sales_License__c>([SELECT Id, Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Host_Node_Id__c, Sales_License_Activation_Code__c,Sales_License_Status__c, Sales_License_Product__c from Sales_License__c where ID IN :mapofInputs.values()]);
        Map<Id, Sales_License__c> licensetobeupdated = new Map<Id, Sales_License__c>(SEL_Sales_License.newInstance().selectByIds(licIdsSet));
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
                    isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;//return error msg
                }
                else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==null && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                    isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;//return error msg
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
        //for(Sales_License__c lc : [SELECT Id, Sales_License_Product__c, Sales_Tool_License_Type__c, Sales_License_Host_Node_Id__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Activation_Code__c,Sales_License_Status__c from Sales_License__c where Sales_License_Host_Node_Id__c IN : hostHasLicenseMap.keySet()]){
        for(Sales_License__c lc : SEL_Sales_License.newInstance().selectByHostIds(hostHasLicenseMap.keySet())){
            Sales_License__c lcObj;//checking if tool type is fixed...we will reassign a host
            if(mapofInputs.containsKey(lc.Sales_License_Host_Node_Id__c)){
                if(lc.Sales_Tool_License_Type__c ==LICENSE_TYPE_FIXED){
                    lcObj = licensetobeupdated.get(mapofInputs.get(lc.Sales_License_Host_Node_Id__c));// lcObj license on which host is to be assigned
                    //US1094912: Show available rehost error for the same product license having the same host
                    if(lc.Sales_License_Avbl_Rehost_Nbr__c==0 && lc.Sales_License_Product__c == lcObj.Sales_License_Product__c){// lc license on which host is present
                        isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;//return error msg
                    }
                    //US1094912: Show available rehost error for the same product license having the same host
                    else if(lc.Sales_License_Avbl_Rehost_Nbr__c==null && lc.Sales_License_Product__c == lcObj.Sales_License_Product__c){// lc license on which host is present
                        isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;//return error msg
                    }
                    else {// lc license on which host is present
                      // System.debug('Inside on current license>>'+lcObj.Sales_License_Avbl_Rehost_Nbr__c==null);
                        
                      
                        if((lcObj.Sales_License_Avbl_Rehost_Nbr__c > 0) || ((lcObj.Sales_License_Avbl_Rehost_Nbr__c==0 || lcObj.Sales_License_Avbl_Rehost_Nbr__c==null) && (lcObj.Sales_License_Host_Node_Id__c==null) && (lcObj.Sales_License_Status__c!= LICENSE_STATUS_LICENSED))){
                            if((lcObj.Sales_License_Avbl_Rehost_Nbr__c > 0 && lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED) || lcObj.Sales_License_Host_Node_Id__c!=null){
                                lcObj.Sales_License_Avbl_Rehost_Nbr__c = lcObj.Sales_License_Avbl_Rehost_Nbr__c - 1;
                           }
                           
                          // lcObj.Sales_License_Avbl_Rehost_Nbr__c = lcObj.Sales_License_Avbl_Rehost_Nbr__c - 1;
                            lcObj.Sales_License_Host_Node_Id__c = lc.Sales_License_Host_Node_Id__c;
                            lcObj.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                            lcObj.Sales_License_Avbl_Qty_Nbr__c = 0;
                            //US1094912: Delink the host from existing license if product on license is also same 
                            if(lc.Sales_License_Avbl_Rehost_Nbr__c > 0  && lc.Sales_License_Product__c == lcObj.Sales_License_Product__c){
                                lc.Sales_License_Host_Node_Id__c = null;
                                lc.Sales_License_Avbl_Rehost_Nbr__c = lc.Sales_License_Avbl_Rehost_Nbr__c - 1;
                            }
                            if(!originalicenseList.contains(lc)){
                                originalicenseList.add(lc);
                            }
                            /*if((lcObj.Sales_License_Avbl_Rehost_Nbr__c==0 || lcObj.Sales_License_Avbl_Rehost_Nbr__c==null) && (lcObj.Sales_License_Host_Node_Id__c==null))
                            {
                                lcObj.Sales_License_Avbl_Rehost_Nbr__c = lcObj.Sales_License_Avbl_Rehost_Nbr__c - 1;
                            }*/
                            if(!updatelicenseList.contains(lcObj)){
                                updatelicenseList.add(lcObj);
                            }
                        }
                        else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==0 && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                            if(isReturnMsg==''){
                                isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;//return error msg
                            }
                        }
                        else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==null && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                            if(isReturnMsg=='')
                                isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;//return error msg
                        }
                    }
                    
                }else if(lc.Sales_Tool_License_Type__c ==LICENSE_TYPE_FLOAT  || lc.Sales_Tool_License_Type__c ==LICENSE_TYPE_NEUTRAL || lc.Sales_Tool_License_Type__c ==LICENSE_TYPE_NA){//for non fixed license types
                    if(count==0){
                        lcObj = licensetobeupdated.get(mapofInputs.get(lc.Sales_License_Host_Node_Id__c));
                        if((lcObj.Sales_License_Avbl_Rehost_Nbr__c > 0) || (((lcObj.Sales_License_Avbl_Rehost_Nbr__c==0) || (lcObj.Sales_License_Avbl_Rehost_Nbr__c==null)) && (lcObj.Sales_License_Host_Node_Id__c==null))){
                            if(((lcObj.Sales_License_Avbl_Rehost_Nbr__c > 0 && lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED) || lcObj.Sales_License_Host_Node_Id__c!=null) && count==0){// lcObj license on which host is to be assigned
                                lcObj.Sales_License_Avbl_Rehost_Nbr__c = lcObj.Sales_License_Avbl_Rehost_Nbr__c - 1;
                                // count++;
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
                            count++;
                        }
                        else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==0 && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                            if(isReturnMsg==''){
                                isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;//return error msg
                            }
                        }
                        else if(lcObj.Sales_License_Avbl_Rehost_Nbr__c==null && (lcObj.Sales_License_Status__c== LICENSE_STATUS_LICENSED || lcObj.Sales_License_Host_Node_Id__c!=null)){
                            if(isReturnMsg==''){
                                isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;//return error msg
                            }    
                        }
                    }     
                }   
            }
        }
        if(updatelicenseList.size()>0){
            System.debug('isReturnMsg-->'+isReturnMsg);
            try{update updatelicenseList; 
                if(isReturnMsg==''){
                    isReturnMsg = System.Label.Sales_SuccessHostReassignment;
                    System.debug('isReturnMsg-->'+isReturnMsg);
                }
               }catch(Exception e){
                   if(e.getMessage().contains('_EXCEPTION')){
                       String pureErrorMessage = e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                       isReturnMsg = pureErrorMessage;
                   }else{isReturnMsg = e.getMessage();}
               }                                                                                           
        }
        if(originalicenseList.size() > 0){
            try{update originalicenseList;
                if(isReturnMsg==''){
                    isReturnMsg = System.Label.Sales_SuccessHostReassignment;
                    System.debug('isReturnMsg-->'+isReturnMsg);
                }
               }catch(Exception e){
                   if(e.getMessage().contains('_EXCEPTION')){
                       String pureErrorMessage = e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                       isReturnMsg = pureErrorMessage;
                   }else{isReturnMsg = e.getMessage();}
               }
        }
        System.debug('Return msg>>'+isReturnMsg);
        return isReturnMsg;
    }
    
    public static Date getLastDateOfMonth(Date dt){
        Date result;Integer noOfDays;
        if(dt != null){noOfDays = Date.daysInMonth(dt.year(), dt.month());
                       result = date.newInstance(dt.year(), dt.month(), noOfDays);
                      }return result;
    }
    
    public static void applyRenewals(List<Sales_License__c> baselicensesList){
        List<Sales_License__c> listOfLicensesToProcess = new List<Sales_License__c>();
        Set<Id> licenseIds = new Set<id>();Set<Id> contactId = new Set<Id>();
        Map<Id,Id> delPrimaryContactMap = new Map<Id,Id>();
        Set<id> foundProdIdSet = new Set<Id>();
        Integer prodExpiryDurationInDays;Integer prodMaintenanceDurInMonths;
        Integer prodRenewalGracePeriodInDays;Integer prodAdditionExpDurationGracePeriod ;
        Integer prodSubscriptionTerm;
        String hostId;date maintDate;
        date licenseDate;date dte;
        Boolean ismaintainance =false;Boolean isLicense = false;
        Set<Id> hostSet = new Set<Id>();
        
        //List<Sales_License__c> baseLicList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
        //                                      Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
        //                                      Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Renewal_Period_Nbr__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Product__r.SBQQ__SubscriptionTerm__c,Sales_License_Host_Node_Id__c FROM Sales_License__c where Id IN : baselicensesList AND Sales_License_Type__c != 'Evaluation' AND Sales_License_Status__c ='Licensed' ];// added by monika for US1086965
        List<Sales_License__c> baseLicList = SEL_Sales_License.newInstance().selectByLicIdTypeAndStatus(baselicensesList);// added by monika for US1086965
        for(Sales_License__c baselic : baseLicList){
            //baselic.Sales_License_Quantity__c = 0;
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
            
            System.debug('prodExpiryDurationInDays-->'+prodExpiryDurationInDays);
            System.debug('prodRenewalGracePeriodInDays-->'+prodRenewalGracePeriodInDays);
            System.debug('prodMaintenanceDurInMonths-->'+prodSubscriptionTerm);
            System.debug('prodAdditionExpDurationGracePeriod-->'+prodAdditionExpDurationGracePeriod);
            system.debug('LicenseData before updation' + baselic.Sales_License_Expiration_Date_Dt__c);
            System.debug(' maintainance expiration'+baselic.Sales_License_Maintenance_Exp_Dt__c);
            
            //License expiration date logic //if product expiration duration of base opn is null
            if( prodExpiryDurationInDays <= 0 || prodExpiryDurationInDays == null){
                baselic.Sales_License_Expiration_Date_Dt__c = null;
            }
            //if renewal grace period is 0 then license expiration date is current date+ prod exp duration 
            else if((prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0 ) && prodExpiryDurationInDays > 0){
               baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1); 
            }
            else if(prodRenewalGracePeriodInDays > 0  //base license record is within active maintainance 
                    && baselic.Sales_License_Maintenance_Exp_Dt__c >(Date.today()) && prodExpiryDurationInDays > 0){   //31/7/2021 --> 31/7/2021+ 365-->31/7/2021
                        baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth (baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodExpiryDurationInDays)).addDays(1);
                    }
            //6/30/2021 --> 6/30/2021+60= 08/30/2021> todays date -->7/8/2022
            else  if(prodRenewalGracePeriodInDays > 0  //base license record is within grace period
                     &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today())) && prodExpiryDurationInDays != null && baselic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                         baselic.Sales_License_Expiration_Date_Dt__c =  getLastDateOfMonth(date.today().addDays(prodExpiryDurationInDays)).addDays(1);
                     }//3/31/2021--> 3/31/2021+60-->05/30/2021 < todays date -->
            else if(prodRenewalGracePeriodInDays > 0   //base license record is beyond grace period
                    &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today())) && prodExpiryDurationInDays != null && baselic.Sales_License_Maintenance_Exp_Dt__c <(Date.today())){
                        baselic.Sales_License_Expiration_Date_Dt__c = getLastDateOfMonth(baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodAdditionExpDurationGracePeriod)).addDays(1);
                    }
            //Maintainance expiration dates logic
            if(prodRenewalGracePeriodInDays == null || prodRenewalGracePeriodInDays == 0){
                baselic.Sales_License_Maintenance_Exp_Dt__c =  getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));  
            }
            else if(prodRenewalGracePeriodInDays > 0 //base license record is within active maintainance 
                    && baselic.Sales_License_Maintenance_Exp_Dt__c >(Date.today())){
                        baselic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(baselic.Sales_License_Maintenance_Exp_Dt__c?.addMonths(prodSubscriptionTerm));
                    }
            else if(prodRenewalGracePeriodInDays > 0 //base license record is within grace period
                    //6/31/2021    < 6/31/2021+90 = 09/28/2021 -->7/8/2021 +365 = 7/31/2021
                    // && lic.Sales_License_Maintenance_Exp_Dt__c <(lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))){
                    &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))>(Date.today()))){
                        baselic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(date.today().addMonths(prodSubscriptionTerm));
                    }
            //3/31/2021  3/31/2021+60 = 05/30/2021< todays date --> 05/31/2022
            else if(prodRenewalGracePeriodInDays > 0 //base license record is beyond grace period
                    //&& (lic.Sales_License_Maintenance_Exp_Dt__c) >(lic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays)))
                    &&((baselic.Sales_License_Maintenance_Exp_Dt__c?.addDays(prodRenewalGracePeriodInDays))<(Date.today()))){
                        dte = baselic.Sales_License_Maintenance_Exp_Dt__c?.addMonths(prodSubscriptionTerm);
                        baselic.Sales_License_Maintenance_Exp_Dt__c = getLastDateOfMonth(dte.addDays(prodRenewalGracePeriodInDays));
                    }
            baselic.Sales_License_Avbl_Rehost_Nbr__c = baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;//available rehost to be set as max rehost
            //available temp license needs to be true
            if(baselic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c==true){
                baselic.Sales_License_Available_Temp_Licenses__c = baselic.Sales_License_Quantity__c;//available temp license and #of seats should be equal on base license
            }
            baselic.Sales_Renewed_Description__c='License was automatically renewed by System on '+date.today().format();
            baselic.Sales_License_Comments_Txt__c='License was automatically renewed by System on '+date.today().format();
            listOfLicensesToProcess.add(baselic);
            if(baselic.Sales_License_Host_Node_Id__c!=null){
                hostId=baselic.Sales_License_Host_Node_Id__c;
                hostSet.add(baselic.Sales_License_Host_Node_Id__c);
            }
        }
        if(listOfLicensesToProcess.size()>0){
            update(listOfLicensesToProcess);             
        }
       /* For(Id host : hostSet){
            if(!String.isBlank(hostId)){
                Sales_LicenseGenIntegration_Utility.returnHostIdDetail(host,'HostId','');
            }
        }
       
      //commented for optimization
      */
       System.enqueueJob(new Sales_BulkHostProcessLicGenQueueable(hostSet,''));
      
    }

}