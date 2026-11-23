/*********************************************************************************************************************
Class Name    : Sales_Primary_DelegateNames_Utility
Version       : 1.0
Created Date  : Jun 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        23-Jun-2021             Sales_Primary_DelegateNames_Utility
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_Primary_DelegateNames_Utility {
    /*public static void OnLicenseInsertUpdate(Map<Id,Sales_License__c> licMap, Map<Id,Sales_License__c> oldLicMap){          
        Boolean isInsert; 
        Boolean isUpdate;
        if(oldLicMap == null){
            isInsert = true; 
            isUpdate = false;
        }
        else{
            isUpdate = true; 
            isInsert = false;
        }
        Map<Id,List<String>> primaryAdminsDelegatesMap = new Map<Id,List<String>>();
        List<Sales_License_Admin_Delegate__c> allDelegateAdminsList = [SELECT Id, Sales_License_isActive__c, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c, Sales_License_Dlg_Adm_Email__c, Sales_License_PrimaryAdmin_Contact__r.Name, Sales_License_DlgAdmin_Contact__r.Name
                                                                       FROM Sales_License_Admin_Delegate__c WHERE Sales_License_isActive__c=true];
        for( Sales_License_Admin_Delegate__c delegateRecord : allDelegateAdminsList ){
            if(primaryAdminsDelegatesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c) == true){
                List<String> allExistingDelegates = primaryAdminsDelegatesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
                allExistingDelegates.add(delegateRecord.Sales_License_Dlg_Adm_Email__c);
                primaryAdminsDelegatesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , allExistingDelegates);
            }else{
                primaryAdminsDelegatesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , new List<String>{delegateRecord.Sales_License_Dlg_Adm_Email__c});
            }
        }
        if(isInsert){ 
            if(licMap != null){
                for(Sales_License__c licenseObj : licMap.values()){                  
                    if( licenseObj.Sales_License_Primary_Admin_Contact__c!=null && primaryAdminsDelegatesMap.size() > 0 && primaryAdminsDelegatesMap.containsKey(licenseObj.Sales_License_Primary_Admin_Contact__c) ){
                        List<String> allDelegateNamesList = primaryAdminsDelegatesMap.get(licenseObj.Sales_License_Primary_Admin_Contact__c);
                        licenseObj.Sales_License_DelegateNames_Txt__c = String.join(allDelegateNamesList, ', ');
                    }else{
                        licenseObj.Sales_License_DelegateNames_Txt__c = '';   
                    }                             
                }
            }            
        }
        else if(isUpdate){
            for(Sales_License__c licenseObj : licMap.values()){     
                if(licenseObj.Sales_License_Primary_Admin_Contact__c!=oldLicMap.get(licenseObj.Id).Sales_License_Primary_Admin_Contact__c){     
                    if( licenseObj.Sales_License_Primary_Admin_Contact__c!=null && primaryAdminsDelegatesMap.size() > 0 && primaryAdminsDelegatesMap.containsKey(licenseObj.Sales_License_Primary_Admin_Contact__c) ){
                        List<String> allDelegateNamesList = primaryAdminsDelegatesMap.get(licenseObj.Sales_License_Primary_Admin_Contact__c);
                        licenseObj.Sales_License_DelegateNames_Txt__c = String.join(allDelegateNamesList, ', ');   
                    }else{
                        licenseObj.Sales_License_DelegateNames_Txt__c = '';   
                    }            
                }                                 
            }
        }
    }
    public static void OnPrimaryAdmDlgAdmInsertUpdate(Map<Id,Sales_License_Admin_Delegate__c> adminsMap, Map<Id,Sales_License_Admin_Delegate__c> oldAdminsMap){
        Boolean isInsert;
        Boolean isUpdate;
        if(oldAdminsMap == null){
            isInsert = true; 
            isUpdate = false;
        }
        else{
            isUpdate = true; 
            isInsert = false;
        }
        List<Sales_License__c> licRecords = new List<Sales_License__c>();
        Set<Id> primaryContactId = new Set<Id>();
        List<String> delegateAdminList = new List<String>();
        for(Sales_License_Admin_Delegate__c adminDelegate : adminsMap.values()){
            primaryContactId.add(adminDelegate.Sales_License_PrimaryAdmin_Contact__c);
        }
        for(Sales_License_Admin_Delegate__c allDelegateAdminforPrimaryContacts : [Select id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Email_Txt__c from Sales_License_Admin_Delegate__c where Sales_License_PrimaryAdmin_Contact__c IN :primaryContactId and Sales_License_isActive__c = TRUE]){
            delegateAdminList.add(allDelegateAdminforPrimaryContacts.Sales_License_DlgAdmin_Email_Txt__c);
        }
        if(isInsert){            
            Map<Id,List<String>> primaryAdmDlgAdmNamesMap = new Map<Id,List<String>>();
            for( Sales_License_Admin_Delegate__c delegateRecord : adminsMap.values() ){
                if(delegateRecord.Sales_License_PrimaryAdmin_Contact__c != null && primaryAdmDlgAdmNamesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c) == true){
                    List<String> allExistingDelegatesInMap = primaryAdmDlgAdmNamesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
                    allExistingDelegatesInMap.add(delegateRecord.Sales_License_Dlg_Adm_Email__c);
                    primaryAdmDlgAdmNamesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , allExistingDelegatesInMap);
                }else if(delegateRecord.Sales_License_PrimaryAdmin_Contact__c != null){
                    primaryAdmDlgAdmNamesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , new List<String>{delegateRecord.Sales_License_Dlg_Adm_Email__c});
                }
            }
            List<Sales_License__c> existingLicRecordsWithPrimary = [SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_DelegateNames_Txt__c
                                                                    FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c IN: primaryAdmDlgAdmNamesMap.keySet() ] ;
            for(Sales_License__c licRec : existingLicRecordsWithPrimary){     
                if( primaryAdmDlgAdmNamesMap.size() > 0 && primaryAdmDlgAdmNamesMap.containsKey(licRec.Sales_License_Primary_Admin_Contact__c) ){
                    List<String> allNewDelegateNamesList = primaryAdmDlgAdmNamesMap.get(licRec.Sales_License_Primary_Admin_Contact__c);                  
                    if(licRec.Sales_License_DelegateNames_Txt__c != null){
                        licRec.Sales_License_DelegateNames_Txt__c = licRec.Sales_License_DelegateNames_Txt__c + ', ' + String.join(allNewDelegateNamesList, ', ');  
                    }else{
                        licRec.Sales_License_DelegateNames_Txt__c = String.join(allNewDelegateNamesList, ', ');   
                    }
                    licRecords.add(licRec);    
                }                              
            }
            if(licRecords.size() > 0){
                List<Database.SaveResult> updateResult = Database.update(licRecords);
            }
        }
        else if(isUpdate){
            Set<Id> contactIdSet = new Set<Id>();
            for(Sales_License_Admin_Delegate__c priDlgRecord : adminsMap.values()){
                if(priDlgRecord.Sales_License_PrimaryAdmin_Contact__c !=null){
                    contactIdSet.add(priDlgRecord.Sales_License_PrimaryAdmin_Contact__c);
                }
            }
            List<Sales_License__c> existingLicRecordsWithPrimaryList = [
                SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_DelegateNames_Txt__c
                FROM Sales_License__c 
                WHERE Sales_License_Primary_Admin_Contact__c =: contactIdSet];
            Map< Id, List<Sales_License__c>> existingLicRecordsWithPrimaryMap = new Map< Id , List<Sales_License__c>>(); 
            if(!existingLicRecordsWithPrimaryList.isEmpty()){
                for(Sales_License__c lic : existingLicRecordsWithPrimaryList){
                    if(!existingLicRecordsWithPrimaryMap.containsKey(lic.Sales_License_Primary_Admin_Contact__c)){
                        existingLicRecordsWithPrimaryMap.put(lic.Sales_License_Primary_Admin_Contact__c, new List<Sales_License__c>());
                    }
                    existingLicRecordsWithPrimaryMap.get(lic.Sales_License_Primary_Admin_Contact__c).add(lic);
                }
            }
            for(Sales_License_Admin_Delegate__c priDlgRecord : adminsMap.values()){ 
                licRecords = new List<Sales_License__c>();
                List<Sales_License__c> existingLicRecordsWithPrimary= new List<Sales_License__c>();
                if(priDlgRecord.Sales_License_PrimaryAdmin_Contact__c !=NULL){
                    existingLicRecordsWithPrimary = existingLicRecordsWithPrimaryMap.containsKey(priDlgRecord.Sales_License_PrimaryAdmin_Contact__c) ? existingLicRecordsWithPrimaryMap.get(priDlgRecord.Sales_License_PrimaryAdmin_Contact__c) : new List<Sales_License__c>();
                }
                if(priDlgRecord.Sales_License_DlgAdmin_Contact__c != oldAdminsMap.get(priDlgRecord.Id)?.Sales_License_DlgAdmin_Contact__c||
                   priDlgRecord.Sales_License_DlgAdmin_Email_Txt__c != oldAdminsMap.get(priDlgRecord.Id)?.Sales_License_DlgAdmin_Email_Txt__c || priDlgRecord.Sales_License_isActive__c != oldAdminsMap.get(priDlgRecord.Id)?.Sales_License_isActive__c){  
                       for(Sales_License__c licRec : existingLicRecordsWithPrimary){     
                           licRec.Sales_License_DelegateNames_Txt__c = String.join(delegateAdminList, ', ');  
                           licRecords.add(licRec);    
                       } 
                   }
            }
            if(licRecords.size() > 0){
                List<Database.SaveResult> updateResult = Database.update(licRecords);
            } 
        }
    }
    public static void OnPrimaryAdmDlgAdmDelete(Map<Id,Sales_License_Admin_Delegate__c> oldAdminsMap){
        Boolean isDelete = (Trigger.isDelete && Trigger.isAfter); 
        List<Sales_License__c> licRecords = new List<Sales_License__c>();
        if(isDelete){
            Map<Id,List<String>> oldPrimaryAdmDlgAdmNamesMap = new Map<Id,List<String>>();
            for( Sales_License_Admin_Delegate__c delegateRecord : oldAdminsMap.values() ){
                if(oldPrimaryAdmDlgAdmNamesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c) == true){
                    List<String> allExistingDelegatesInMap = oldPrimaryAdmDlgAdmNamesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
                    allExistingDelegatesInMap.add(delegateRecord.Sales_License_Dlg_Adm_Email__c);
                    oldPrimaryAdmDlgAdmNamesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , allExistingDelegatesInMap);
                }else{
                    oldPrimaryAdmDlgAdmNamesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , new List<String>{delegateRecord.Sales_License_Dlg_Adm_Email__c});
                }
            }            
            List<Sales_License__c> existingLicRecordsWithPrimary = [SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_DelegateNames_Txt__c
                                                                    FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c IN: oldPrimaryAdmDlgAdmNamesMap.keySet() ] ;
            for(Sales_License__c licRec : existingLicRecordsWithPrimary){     
                if( oldPrimaryAdmDlgAdmNamesMap.size() > 0 && oldPrimaryAdmDlgAdmNamesMap.containsKey(licRec.Sales_License_Primary_Admin_Contact__c) ){
                    List<String> allDelegateNamesToRemoveList = oldPrimaryAdmDlgAdmNamesMap.get(licRec.Sales_License_Primary_Admin_Contact__c);
                    Set<String> existingDlgNames;
                    if(licRec.Sales_License_DelegateNames_Txt__c != null){
                        existingDlgNames = ( new Set<String>((licRec.Sales_License_DelegateNames_Txt__c).split(', ')) );
                        existingDlgNames.removeAll(allDelegateNamesToRemoveList);
                    }else{
                        existingDlgNames = new Set<String>();
                    }                    
                    List<String> finalDlgNames = new List<String>( existingDlgNames );
                    licRec.Sales_License_DelegateNames_Txt__c = String.join(finalDlgNames, ', ');
                    licRecords.add(licRec);    
                }                              
            }
            if(licRecords.size() > 0){ 
                List<Database.SaveResult> updateResult = Database.update(licRecords);
            }
        }  
    }
    /********************************************************************************************************************************************************
    Additional Scripts to :
    1. void populateAllLicensePrimary_DelegateNames() --> 
    - Initialize/Populate the "Delegate Admins of Primary Admin (API - Sales_License_DelegateNames_Txt__c )" field on All Licenses.
    - To be used to Populate the field on all Licenses, post deployemnt if Licenses already exist in the destination Org & to fix bad data issues.
    2. void clearAllLicensePrimary_DelegateNames() -->
    - Clear "Delegate Admins of Primary Admin (API - Sales_License_DelegateNames_Txt__c )" field on All Licenses. 
    - If you are facing bad data issues, use this method & then the method mentioned above to resolve the issues.
    **********************************************************************************************************************************************************/
    /*public static void populateAllLicensePrimary_DelegateNames(){
        List<Sales_License_Admin_Delegate__c> allDelegateAdminsList = [SELECT Id, Sales_License_isActive__c, Sales_License_Dlg_Adm_Email__c, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c, Sales_License_PrimaryAdmin_Contact__r.Name, Sales_License_DlgAdmin_Contact__r.Name
                                                                       FROM Sales_License_Admin_Delegate__c WHERE Sales_License_isActive__c=true];
        Map<Id,List<String>> primaryAdmDlgAdmNamesMap = new Map<Id,List<String>>();
        for( Sales_License_Admin_Delegate__c delegateRecord : allDelegateAdminsList ){
            if(primaryAdmDlgAdmNamesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c) == true){
                List<String> allExistingDelegatesInMap = primaryAdmDlgAdmNamesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
                allExistingDelegatesInMap.add(delegateRecord.Sales_License_Dlg_Adm_Email__c);
                primaryAdmDlgAdmNamesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , allExistingDelegatesInMap);
            }else{
                primaryAdmDlgAdmNamesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , new List<String>{delegateRecord.Sales_License_Dlg_Adm_Email__c});
            }
        }
        List<Sales_License__c> licRecords = new List<Sales_License__c>();
        List<Sales_License__c> allLicenses = [SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_DelegateNames_Txt__c FROM Sales_License__c ];
        for(Sales_License__c licRec : allLicenses){
            if( primaryAdmDlgAdmNamesMap.size() > 0 && primaryAdmDlgAdmNamesMap.containsKey(licRec.Sales_License_Primary_Admin_Contact__c) ){
                List<String> allNewDelegateNamesList = primaryAdmDlgAdmNamesMap.get(licRec.Sales_License_Primary_Admin_Contact__c);
                if(licRec.Sales_License_DelegateNames_Txt__c != null){
                    licRec.Sales_License_DelegateNames_Txt__c = licRec.Sales_License_DelegateNames_Txt__c + String.join(allNewDelegateNamesList, ', ');   
                }else{
                    licRec.Sales_License_DelegateNames_Txt__c = String.join(allNewDelegateNamesList, ', ');   
                }
                licRecords.add(licRec);    
            }   
        }
        if(licRecords.size() > 0){
            Database.SaveResult[] updateResult = Database.update(licRecords);
        }
    }
    public static void clearAllLicensePrimary_DelegateNames(){
        List<Sales_License__c> licRecords = new List<Sales_License__c>();
        List<Sales_License__c> allLicenses = [SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_DelegateNames_Txt__c FROM Sales_License__c ];
        for(Sales_License__c licRec : allLicenses){
            if(licRec.Sales_License_Primary_Admin_Contact__c!=null){
                licRec.Sales_License_DelegateNames_Txt__c = '';
                licRecords.add(licRec);    
            }  
        }   
        if(licRecords.size() > 0){
            Database.SaveResult[] updateResult = Database.update(licRecords);
        }
    }*/
}