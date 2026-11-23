public without sharing class Sales_ValidateUpdateOnHost {
    private static final String LICENSE_STATUS_LICENSED = 'Licensed';
    private static final String LICENSE_STATUS_UNLICENSED = 'Unlicensed';
    private static final String LICENSE_TYPE_FIXED = 'FIXED';
    private static final String LICENSE_TYPE_FLOAT = 'FLOAT';
    private static final String LICENSE_TYPE_NEUTRAL = 'NEUTRAL';
    private static final String LICENSE_TYPE_NA = 'N-A';
    public static void hostReassigment(List<Sales_License__c> newLicList, Map<Id, Sales_License__c> oldLicMap,Map<Id, Sales_License__c> newLicMap) {
        Set<id> hostId = new Set<id>();
        Set<id> licId = new Set<id>();
        set<id> licenseSet=new Set<id>();
        boolean bypassMethod=false;
        List<Sales_License__c> fixLicensesList=new List<Sales_License__c>();
        List<Sales_License__c> floatNaturalLicensesList=new List<Sales_License__c>();
        for(Sales_License__c licList:newLicList){
            if(licList.Sales_License_Host_Node_Id__c != null && licList.Sales_License_Host_Node_Id__c != oldLicMap.get(licList.Id).Sales_License_Host_Node_Id__c ){
                bypassMethod=true;
                boolean errorMsg=false;
                licenseSet.add(licList.Id);
                boolean isCustomOps=Sales_ValidateUserEditAccess.BypassRehostForCustomOps();
                if(licList.Sales_License_Web_Display_Flag__c==false ||licList.Sales_License_Activation_Code__c==null) {
                    if(isCustomOps==false) {
                        liclist.addError(System.label.Sales_SerialError);
                        errorMsg=true;
                    }        	 
                }     
                if((oldLicMap.get(licList.id).Sales_License_Type__c =='Add Seat') || (oldLicMap.get(licList.id).Sales_License_Type__c =='Renewal')){
                    licList.addError(System.label.Sales_AddSeatRenewError);
                    errorMsg=true;
                } 
                else if(oldLicMap.get(licList.id).Sales_License_Status__c=='Renewals Applied' || oldLicMap.get(licList.id).Sales_License_Status__c=='Cancelled'){
                    licList.addError(System.label.Sales_LicenseStatusError);
                    errorMsg=true;
                }
                else if(Sales_LicenseRecordPageComponentsUtility.LicenseTypeCheck(licList.Sales_License_Host_Node_Id__c,licList.id)==true){
                }
                else{
                    licList.addError(System.label.Sales_Lictooltyp);
                    errorMsg=true;
                }
                if(errorMsg==false && licList.Sales_Tool_License_Type__c=='FIXED' || licList.Sales_License_Host_Node_Id__r.Sales_License_Type__c=='FIXED'){
                    fixLicensesList.add(licList);
                    licId.add(licList.id);
                    hostId.add(licList.Sales_License_Host_Node_Id__c);
                    floatNaturalLicensesList.add(licList);
                }
                else{
                    if(errorMsg==false){
                        floatNaturalLicensesList.add(licList);
                    }
                }
            }
        }
        if(bypassMethod==true){
            for(Sales_license__c licenseList:[Select id,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Sales_License__c where id in :licenseSet]){
                if(licenseList.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='Add Seat'|| licenseList.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='Renewal'){
                    newLicMap.get(licenseList.id).addError(System.label.Sales_AddSeatRenewError);
                }
            }
            if(licId.size()>0 && hostId.size()>0){
                askForhostReassigment1(hostId,fixLicensesList,newLicMap);
            }
            for(Sales_License__c licList:floatNaturalLicensesList){
                if(oldlicmap.get(licList.Id).Sales_License_Status__c== LICENSE_STATUS_UNLICENSED && oldlicmap.get(licList.Id).Sales_License_Host_Node_Id__c==null){
                    licList.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                    licList.Sales_License_Avbl_Qty_Nbr__c = 0;
                }
                else if((oldlicmap.get(licList.Id).Sales_License_Status__c== LICENSE_STATUS_LICENSED || licList.Sales_License_Host_Node_Id__c != null) && (licList.Sales_License_Avbl_Rehost_Nbr__c>0)){
                    licList.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                    licList.Sales_License_Avbl_Qty_Nbr__c = 0;
                    licList.Sales_License_Avbl_Rehost_Nbr__c=licList.Sales_License_Avbl_Rehost_Nbr__c-1;
                }
                else if(oldLicMap.get(licList.id).Sales_License_Avbl_Rehost_Nbr__c==0 && (licList.Sales_License_Status__c== LICENSE_STATUS_LICENSED || licList.Sales_License_Host_Node_Id__c!=null)){
                    licList.addError(System.Label.Sales_avlbeRehostZeroErrMsg);
                }
                else if(oldLicMap.get(licList.id).Sales_License_Avbl_Rehost_Nbr__c==null && (licList.Sales_License_Status__c== LICENSE_STATUS_LICENSED || licList.Sales_License_Host_Node_Id__c!=null)){
                    licList.addError(System.Label.Sales_avlbeRehostNullErrMsg);
                }
                else if(licList.Sales_License_Status__c!= LICENSE_STATUS_LICENSED && licList.Sales_License_Host_Node_Id__c==null){
                    licList.Sales_License_Status__c= LICENSE_STATUS_LICENSED;
                    licList.Sales_License_Avbl_Qty_Nbr__c = 0;
                }
            }
        }
    }
    public static void askForhostReassigment1(Set<Id> hostIds, List<Sales_License__c> licenseList,Map<Id, Sales_License__c> newLicMap) {
        Boolean isLicenseExist = false;
        Set<Id> productIdsSet = new Set<Id>();
        set<Id> LicId=new Set<Id>();
        set<id> lisIdToExclude=new set<Id>();
        Set<id> licenseIds=new Set<Id>();
        map<id,id> productHostMap= new  map<id,id>();
        map<id,id> productHostMap1= new  map<id,id>();
        map<id,id> productHostMap2= new  map<id,id>();
        Set<Id> productIdsSet1 = new Set<Id>();
        for(Sales_License__c lic:licenseList){
            licenseIds.add(lic.id);
            if(productHostMap1.size()>0 && lic.Sales_License_Host_Node_Id__c!=null && lic.Sales_License_Product__c!=null && productHostMap1.containsKey(lic.Sales_License_Host_Node_Id__c) && productHostMap1.get(lic.Sales_License_Host_Node_Id__c)==lic.Sales_License_Product__c){
                newLicMap.get(lic.id).addError(System.label.Sales_sameHostAssignToSameFixLic);
                productIdsSet1.add(lic.Sales_License_Product__c);
                productHostMap2.put(lic.Sales_License_Host_Node_Id__c,lic.Sales_License_Product__c);
                LicId.add(lic.id);
            }
            else{
                productIdsSet.add(lic.Sales_License_Product__c); 
                productHostMap1.put(lic.Sales_License_Host_Node_Id__c,lic.Sales_License_Product__c);
            }    
        }
        if(licenseIds.size()>1){
            for(Sales_License__c lic:licenseList){
                licenseIds.add(lic.id);
                if(productHostMap2!=null && lic.Sales_License_Host_Node_Id__c!=null && lic.Sales_License_Product__c!=null && productHostMap2.containsKey(lic.Sales_License_Host_Node_Id__c) && productHostMap2.get(lic.Sales_License_Host_Node_Id__c)==lic.Sales_License_Product__c){
                    newLicMap.get(lic.id).addError(System.label.Sales_sameHostAssignToSameFixLic);
                    LicId.add(lic.id);
                }
            }
        }
        for(Sales_Host__c hostObj : [Select Id, (Select Id,Sales_Tool_License_Type__c,Sales_License_Product__c From Licenses__r where Sales_License_Product__c IN: productIdsSet and Sales_Tool_License_Type__c='FIXED') from Sales_Host__c Where Id IN :hostIds and Sales_License_Type__c='FIXED']){
            for(Sales_License__c license : hostObj.Licenses__r){
                if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                    productHostMap.put(hostObj.id,license.Sales_License_Product__c);
                    lisIdToExclude.add(license.id);
                }
            }
        }
        if(lisIdToExclude.size()>0){
            for(Sales_License__c lic:newLicMap.values() ){
                if(lisIdToExclude.contains(lic.id) && lic.Sales_License_Host_Node_Id__c==null){
                    isLicenseExist=true;
                }
            }
        }
        if(isLicenseExist==false){
            for(Sales_License__c lic:newLicMap.values() ){
                if(LicId.size()==0 && productHostMap.size()>0 && productHostMap.containsKey(lic.Sales_License_Host_Node_Id__c) && productHostMap.get(lic.Sales_License_Host_Node_Id__c)==lic.Sales_License_Product__c){
                    lic.addError(System.label.Sales_licenseWithSameHostExist);
                }
            }
        }
    }
}