/********************************************************************************************************************
Class Name    : Sales_LicenseAdminDelegateUtility
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma            28-May-2021         License Admin Delegate Utility  
* *********************************************************************************************************************/
public without sharing class Sales_LicenseAdminDelegateUtility {
    public static void shareRecordsWithDelegates(List<Sales_License_Admin_Delegate__c> licAdmDlgList , Map<Id,Sales_License_Admin_Delegate__c> oldLicAdmDlgMap){
        Boolean isAfterInsert;
        Boolean isAfterUpdate;
        if(oldLicAdmDlgMap==null){
            isAfterInsert = true;
            isAfterUpdate = false;    
        }else{
            isAfterInsert = false;
            isAfterUpdate = true;        
        }                  
        Map<Id,Id> primaryAdminDelegateUsrMap = new Map<Id,Id>();			
        Set<Id> contIds = new Set<Id>();									
        for(Sales_License_Admin_Delegate__c adm : licAdmDlgList){
            if (adm.Sales_License_PrimaryAdmin_Contact__c != null) {
                contIds.add(adm.Sales_License_PrimaryAdmin_Contact__c);
            }
            if (adm.Sales_License_DlgAdmin_Contact__c != null) {
                contIds.add(adm.Sales_License_DlgAdmin_Contact__c);
            }
        }
        if(oldLicAdmDlgMap!=null){
            for(Sales_License_Admin_Delegate__c adm : oldLicAdmDlgMap.values()){
                if (adm.Sales_License_PrimaryAdmin_Contact__c != null) {
                    contIds.add(adm.Sales_License_PrimaryAdmin_Contact__c);
                }
                if (adm.Sales_License_DlgAdmin_Contact__c != null) {
                    contIds.add(adm.Sales_License_DlgAdmin_Contact__c);
                }
            }
        }
        if(!contIds.isEmpty()){
            List<User> usrList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contIds];
            for(User usr : usrList){
                primaryAdminDelegateUsrMap.put(usr.ContactId, usr.Id);
                contIds.remove(usr.ContactId);
            }
            if(usrList.isEmpty() || contIds.size() > 0){
                Map<Id, id> contUserMap = Sales_CreateLicenseContactUser_Utility.getContactUserMapForInternalUser(contIds);
                if(contUserMap != null && !contUserMap.isEmpty()){
                    primaryAdminDelegateUsrMap.putAll(contUserMap);         
                }                                
            }
        }
        Set < Id > contactIdSet = new Set < Id > ();
        Set < Id > oldPrimaryAdminContactIdSet = new Set < Id > ();
        List < Sales_Host__c > allHostsForOldPrimaryAdmList = new List < Sales_Host__c > ();
        List < Sales_License__c > allLicensesForOldPrimaryAdmList = new List < Sales_License__c > ();
        Map < Id, Map < Id, Sales_License__c >> allLicensesForOldPrimaryAdmMap = new Map < Id, Map < Id, Sales_License__c >> ();
        Map < Id, Map < Id, Sales_Host__c >> allHostsForOldPrimaryAdmMap = new Map < Id, Map < Id, Sales_Host__c >> ();
        Map < Id, Map < Id, Sales_License__c >> allLicenseMap = new Map < Id, Map < Id, Sales_License__c >> ();
        Map < Id, Map < Id, Sales_License__c >> allLicensesRevokeMap = new Map < Id, Map < Id, Sales_License__c >> ();
        Map < Id, Map < Id, Sales_Host__c >> allHostMap = new Map < Id, Map < Id, Sales_Host__c >> ();
        for (Sales_License_Admin_Delegate__c adm: licAdmDlgList) {
            if (adm.Sales_License_PrimaryAdmin_Contact__c != null) {
                contactIdSet.add(adm.Sales_License_PrimaryAdmin_Contact__c);
            }
        }
        List < Sales_License__c > allLicenseList = [
            SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_Host_Node_Id__c, Sales_License_Web_Display_Flag__c
            FROM Sales_License__c
            WHERE Sales_License_Primary_Admin_Contact__c IN: contactIdSet
        ];
        for (Sales_License__c license: allLicenseList) {
            if (license.Sales_License_Web_Display_Flag__c) {
                if (!allLicenseMap.containsKey(license.Sales_License_Primary_Admin_Contact__c)) {
                    allLicenseMap.put(license.Sales_License_Primary_Admin_Contact__c, new Map < Id, Sales_License__c > ());
                }
                allLicenseMap.get(license.Sales_License_Primary_Admin_Contact__c).put(license.Id, license);
            }
            if (!allLicensesRevokeMap.containsKey(license.Sales_License_Primary_Admin_Contact__c)) {
                allLicensesRevokeMap.put(license.Sales_License_Primary_Admin_Contact__c, new Map < Id, Sales_License__c > ());
            }
            allLicensesRevokeMap.get(license.Sales_License_Primary_Admin_Contact__c).put(license.Id, license);
        }
        List < Sales_Host__c > allHostList = [
            SELECT Id, Sales_Contact__c
            FROM Sales_Host__c
            WHERE Sales_Contact__c IN: contactIdSet
        ];
        for (Sales_Host__c host: allHostList) {
            if (!allHostMap.containsKey(host.Sales_Contact__c)) {
                allHostMap.put(host.Sales_Contact__c, new Map < Id, Sales_Host__c > ());
            }
            allHostMap.get(host.Sales_Contact__c).put(host.Id, host);
        }
        if (isAfterUpdate) {
            for (Sales_License_Admin_Delegate__c admList: licAdmDlgList) {
                if (oldLicAdmDlgMap.containsKey(admList.Id) && oldLicAdmDlgMap.get(admList.Id).Sales_License_PrimaryAdmin_Contact__c != null) {
                    oldPrimaryAdminContactIdSet.add(oldLicAdmDlgMap.get(admList.Id).Sales_License_PrimaryAdmin_Contact__c);
                }
            }
            if (!oldPrimaryAdminContactIdSet.isEmpty()) {
                allLicensesForOldPrimaryAdmList = [
                    SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_Host_Node_Id__c
                    FROM Sales_License__c
                    WHERE Sales_License_Primary_Admin_Contact__c IN: oldPrimaryAdminContactIdSet
                ];
                allHostsForOldPrimaryAdmList = [
                    SELECT Id, Sales_Contact__c
                    FROM Sales_Host__c
                    WHERE Sales_Contact__c IN: oldPrimaryAdminContactIdSet
                ];
            }
            for (Sales_License__c license: allLicensesForOldPrimaryAdmList) {
                if (!allLicensesForOldPrimaryAdmMap.containsKey(license.Sales_License_Primary_Admin_Contact__c)) {
                    allLicensesForOldPrimaryAdmMap.put(license.Sales_License_Primary_Admin_Contact__c, new Map < Id, Sales_License__c > ());
                }
                allLicensesForOldPrimaryAdmMap.get(license.Sales_License_Primary_Admin_Contact__c).put(license.Id, license);
            }
            for (Sales_Host__c host: allHostsForOldPrimaryAdmList) {
                if (!allHostsForOldPrimaryAdmMap.containsKey(host.Sales_Contact__c)) {
                    allHostsForOldPrimaryAdmMap.put(host.Sales_Contact__c, new Map < Id, Sales_Host__c > ());
                }
                allHostsForOldPrimaryAdmMap.get(host.Sales_Contact__c).put(host.Id, host);
            }
        }
        for(Sales_License_Admin_Delegate__c AdmList : licAdmDlgList){
            Map<Id,Sales_License__c> allLicenses;
            Map<Id,Sales_License__c> allLicensesRevoke;
            Map<Id,Sales_Host__c> allHosts;
            if(AdmList.Sales_License_PrimaryAdmin_Contact__c != null) {
                allLicenses = allLicenseMap.containsKey(AdmList.Sales_License_PrimaryAdmin_Contact__c) ? allLicenseMap.get(AdmList.Sales_License_PrimaryAdmin_Contact__c) : new Map < Id, Sales_License__c > ();
                allLicensesRevoke = allLicensesRevokeMap.containsKey(AdmList.Sales_License_PrimaryAdmin_Contact__c) ? allLicensesRevokeMap.get(AdmList.Sales_License_PrimaryAdmin_Contact__c) : new Map < Id, Sales_License__c > ();
                allHosts = allHostMap.containsKey(AdmList.Sales_License_PrimaryAdmin_Contact__c) ? allHostMap.get(AdmList.Sales_License_PrimaryAdmin_Contact__c) : new Map < Id, Sales_Host__c > ();
            } 
            Id primaryAdminUserId = null;
            Id dlgAdminUserId = null;
            if(primaryAdminDelegateUsrMap.containsKey(AdmList.Sales_License_PrimaryAdmin_Contact__c)){
                primaryAdminUserId=primaryAdminDelegateUsrMap.get(AdmList.Sales_License_PrimaryAdmin_Contact__c);
            }
            if(primaryAdminDelegateUsrMap.containsKey(AdmList.Sales_License_DlgAdmin_Contact__c)){
                dlgAdminUserId=primaryAdminDelegateUsrMap.get(AdmList.Sales_License_DlgAdmin_Contact__c);
            }        
            if(isAfterInsert){     
                if(primaryAdminUserId != null){
                    manualShareAccessLicDlgAdmRecord(AdmList.Id, new List < Id > {
                        primaryAdminUserId
                            });
                }
                if(allLicenses != null){                                     
                    List<Id> allLicenseIds = new List<Id>(allLicenses.keySet());
                    if(primaryAdminUserId != null){
                        manualShareAccessOnBulkLicenses(allLicenseIds,primaryAdminUserId);  
                    }
                    if(dlgAdminUserId != null){
                        manualShareAccessOnBulkLicenses(allLicenseIds,dlgAdminUserId);   
                    }   
                }               
                if(allHosts != null){                  
                    List<Id> allHostIds = new List<Id>(allHosts.keySet());
                    if(primaryAdminUserId != null){
                        manualShareAccessOnBulkHost(allHostIds,primaryAdminUserId);  
                    }
                    if(dlgAdminUserId != null){
                        manualShareAccessOnBulkHost(allHostIds,dlgAdminUserId);   
                    }                                    
                }                
            } else if (isAfterUpdate) {
                Map < Id, Sales_License__c > allLicensesForOldPrimaryAdm = allLicensesForOldPrimaryAdmMap.containsKey((oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c)) ? allLicensesForOldPrimaryAdmMap.get((oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c)) : new Map < Id, Sales_License__c > ();
                Map < Id, Sales_Host__c > allHostsForOldPrimaryAdm = allHostsForOldPrimaryAdmMap.containsKey((oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c)) ? allHostsForOldPrimaryAdmMap.get((oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c)) : new Map < Id, Sales_Host__c > ();
                if( (oldLicAdmDlgMap.get(AdmList.Id).Sales_License_isActive__c != AdmList.Sales_License_isActive__c) || (oldLicAdmDlgMap.get(AdmList.Id).Sales_License_DlgAdmin_Contact__c != AdmList.Sales_License_DlgAdmin_Contact__c ) || (oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c != AdmList.Sales_License_PrimaryAdmin_Contact__c )  ){ 
                    Id oldPriAdminUserId=null;
                    if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c != AdmList.Sales_License_PrimaryAdmin_Contact__c ){
                        if(primaryAdminDelegateUsrMap.containsKey(AdmList.Sales_License_PrimaryAdmin_Contact__c)){
                            oldPriAdminUserId=primaryAdminDelegateUsrMap.get(AdmList.Sales_License_PrimaryAdmin_Contact__c);
                        } 
                        if(oldPriAdminUserId != null){
                            revokeAccessLicDlgAdmRecord(AdmList.Id,new List<Id>{oldPriAdminUserId});
                        }
                        if(primaryAdminUserId != null){
                            manualShareAccessLicDlgAdmRecord(AdmList.Id,new List<Id>{primaryAdminUserId});
                        }
                    }
                    Id oldDlgAdminUserId=null;
                    if(primaryAdminDelegateUsrMap.containsKey(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_DlgAdmin_Contact__c)){
                        oldDlgAdminUserId=primaryAdminDelegateUsrMap.get(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_DlgAdmin_Contact__c);
                    } 
                    if(allLicenses != null){
                        if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c != AdmList.Sales_License_PrimaryAdmin_Contact__c ){
                            if(oldDlgAdminUserId != null){
                                revokeAccessOnBulkLicenses( new List<Id>(allLicensesForOldPrimaryAdm.keySet()) ,new List<Id>{oldDlgAdminUserId});
                            }
                            List<Id> allLicenseIds = new List<Id>(allLicenses.keySet());
                            if(dlgAdminUserId != null){
                                manualShareAccessOnBulkLicenses(allLicenseIds,dlgAdminUserId);                           
                            }
                        }
                        if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_DlgAdmin_Contact__c != AdmList.Sales_License_DlgAdmin_Contact__c ){                        
                            if(oldDlgAdminUserId != null){
                                revokeAccessOnBulkLicenses( new List<Id>(allLicensesForOldPrimaryAdm.keySet()) ,new List<Id>{oldDlgAdminUserId});
                            }
                            List<Id> allLicenseIds = new List<Id>(allLicenses.keySet());
                            if(dlgAdminUserId != null){
                                manualShareAccessOnBulkLicenses(allLicenseIds,dlgAdminUserId);                           
                            }
                        }
                        if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_isActive__c != AdmList.Sales_License_isActive__c){
                            if(AdmList.Sales_License_isActive__c == true){
                                if(dlgAdminUserId != null){
                                    manualShareAccessOnBulkLicenses( new List<Id>(allLicenses.keySet()) ,dlgAdminUserId);                           
                                }
                            }else{
                                if(dlgAdminUserId != null){
                                    revokeAccessOnBulkLicenses( new List<Id>(allLicensesRevoke.keySet()) ,new List<Id>{dlgAdminUserId});
                                } 
                            }
                        }
                    }
                    if(allHosts != null){ 
                        if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_PrimaryAdmin_Contact__c != AdmList.Sales_License_PrimaryAdmin_Contact__c ){
                            if(oldDlgAdminUserId != null){
                                revokeAccessOnBulkHosts( new List<Id>(allHostsForOldPrimaryAdm.keySet()) ,new List<Id>{oldDlgAdminUserId});
                            }
                            List<Id> allHostIds = new List<Id>(allHosts.keySet());
                            if(dlgAdminUserId != null){
                                manualShareAccessOnBulkHost(allHostIds,dlgAdminUserId);                            
                            }
                        }
                        if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_DlgAdmin_Contact__c != AdmList.Sales_License_DlgAdmin_Contact__c ){       
                            if(oldDlgAdminUserId != null){
                                revokeAccessOnBulkHosts( new List<Id>(allHostsForOldPrimaryAdm.keySet()) ,new List<Id>{oldDlgAdminUserId});
                            }
                            List<Id> allHostIds = new List<Id>(allHosts.keySet());
                            if(dlgAdminUserId != null){
                                manualShareAccessOnBulkHost(allHostIds,dlgAdminUserId);                            
                            }
                        } 
                        if(oldLicAdmDlgMap.get(AdmList.Id).Sales_License_isActive__c != AdmList.Sales_License_isActive__c){
                            if(AdmList.Sales_License_isActive__c == true){
                                if(dlgAdminUserId != null){
                                    manualShareAccessOnBulkHost( new List<Id>(allHosts.keySet()) ,dlgAdminUserId);                            
                                }
                            }else{
                                if(dlgAdminUserId != null){
                                    revokeAccessOnBulkHosts( new List<Id>(allHosts.keySet()) ,new List<Id>{dlgAdminUserId});
                                }
                            }
                        }
                    }
                }
            }   
        }
    }
    public static void revokeRecordsOnDlgAdminDelete(List<Sales_License_Admin_Delegate__c> oldLicAdmDlgList){
        Boolean isBeforeDelete = (Trigger.isDelete && Trigger.isBefore);  
        if(isBeforeDelete && oldLicAdmDlgList.size()>0){
            Map<Id,Id> primaryAdminDelegateUsrMap = new Map<Id,Id>();			
            Set<Id> contIds = new Set<Id>();                                    
            for(Sales_License_Admin_Delegate__c adm : oldLicAdmDlgList){                    
                if(adm.Sales_License_DlgAdmin_Contact__c != null)
                    contIds.add(adm.Sales_License_DlgAdmin_Contact__c);
            }
            if(!contIds.isEmpty()){
                List<User> usrList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contIds];
                for(User usr : usrList){
                    primaryAdminDelegateUsrMap.put(usr.ContactId, usr.Id);
                    contIds.remove(usr.ContactId);
                }
                if(usrList.isEmpty() || contIds.size() > 0){
                    Map<Id, id> contUserMap = Sales_CreateLicenseContactUser_Utility.getContactUserMapForInternalUser(contIds);
                    if(contUserMap != null && !contUserMap.isEmpty()){
                        primaryAdminDelegateUsrMap.putAll(contUserMap);         
                    }                                
                }
            }
            Set < Id > contactId = new Set < Id > ();
            for(Sales_License_Admin_Delegate__c admList : oldLicAdmDlgList){
                if (admList.Sales_License_PrimaryAdmin_Contact__c != null) {
                    contactId.add(admList.Sales_License_PrimaryAdmin_Contact__c);
                }
            }
            List < Sales_License__c > allLicenseList = [
                SELECT Id, Sales_License_Primary_Admin_Contact__c, Sales_License_Host_Node_Id__c, Sales_License_Web_Display_Flag__c
                FROM Sales_License__c 
                WHERE Sales_License_Primary_Admin_Contact__c IN: contactId
            ];
            List < Sales_Host__c > allHostList = [
                SELECT Id, Sales_Contact__c
                FROM Sales_Host__c 
                WHERE Sales_Contact__c IN: contactId
            ];
            Map < Id, Map < Id, Sales_License__c >> allLicenseMap = new Map < Id, Map < Id, Sales_License__c >> ();
            Map < Id, Map < Id, Sales_Host__c >> allHostMap = new Map < Id, Map < Id, Sales_Host__c >> ();
            for (Sales_License__c license: allLicenseList) {
                if (!allLicenseMap.containsKey(license.Sales_License_Primary_Admin_Contact__c)) {
                    allLicenseMap.put(license.Sales_License_Primary_Admin_Contact__c, new Map < Id, Sales_License__c > ());
                }
                allLicenseMap.get(license.Sales_License_Primary_Admin_Contact__c).put(license.Id, license);
            }
            for (Sales_Host__c host: allHostList) {
                if (!allHostMap.containsKey(host.Sales_Contact__c)) {
                    allHostMap.put(host.Sales_Contact__c, new Map < Id, Sales_Host__c > ());
                }
                allHostMap.get(host.Sales_Contact__c).put(host.Id, host);
            }
            for (Sales_License_Admin_Delegate__c admList: oldLicAdmDlgList) {
                Map < Id, Sales_License__c > allLicensesForPrimaryAdm = allLicenseMap.containsKey(admList.Sales_License_PrimaryAdmin_Contact__c) ? allLicenseMap.get(admList.Sales_License_PrimaryAdmin_Contact__c) : new Map < Id, Sales_License__c > ();
                Map < Id, Sales_Host__c > allHostForPrimaryAdm = allHostMap.containsKey(admList.Sales_License_PrimaryAdmin_Contact__c) ? allHostMap.get(admList.Sales_License_PrimaryAdmin_Contact__c) : new Map < Id, Sales_Host__c > ();
                Id dlgAdminUserId=null;
                if(primaryAdminDelegateUsrMap.containsKey(admList.Sales_License_DlgAdmin_Contact__c)){
                    dlgAdminUserId = primaryAdminDelegateUsrMap.get(admList.Sales_License_DlgAdmin_Contact__c);
                }
                if(dlgAdminUserId != null){
                    revokeAccessOnBulkLicenses( new List<Id>(allLicensesForPrimaryAdm.keySet()) , new List<Id>{dlgAdminUserId} );
                    revokeAccessOnBulkHosts( new List<Id>(allHostForPrimaryAdm.keySet()) , new List<Id>{dlgAdminUserId} );
                }
            }  
        } 
    }
    public static void manualShareAccessOnBulkLicenses(List<Id> recordIds, Id userId){
        List<Sales_License__Share> listOfLicenseShareRecords = new List<Sales_License__Share>();
        for(Id recId : recordIds){         
            Sales_License__Share licenseShare  = new Sales_License__Share();		
            licenseShare.ParentId = recId;		 								
            licenseShare.UserOrGroupId = userId;									
            licenseShare.AccessLevel = 'Edit';										
            licenseShare.RowCause = Schema.Sales_License__Share.RowCause.Manual;				
            listOfLicenseShareRecords.add(licenseShare);   							
        }
        if(listOfLicenseShareRecords.size() > 0){
            Database.SaveResult[] results = Database.insert(listOfLicenseShareRecords,false);
        }
    }
    public static void manualShareAccessOnBulkHost(List<Id> recordIds, Id userId){
        List<Sales_Host__Share> listOfHostShareRecords = new List<Sales_Host__Share>();
        for(Id recId : recordIds){         
            Sales_Host__Share hostShare  = new Sales_Host__Share();		
            hostShare.ParentId = recId;		 								
            hostShare.UserOrGroupId = userId;									
            hostShare.AccessLevel = 'Edit';										
            hostShare.RowCause = Schema.Sales_License__Share.RowCause.Manual;				
            listOfHostShareRecords.add(hostShare);   							
        }
        if(listOfHostShareRecords.size() > 0){
            Database.SaveResult[] results = Database.insert(listOfHostShareRecords,false);
        }
    }
    public static void revokeAccessOnBulkLicenses(List<Id> recordIds, List<Id> userIds){
        List<Sales_License__Share> listOfLicenseRevokeShareRecords = [SELECT Id, ParentId, UserOrGroup.Name, UserOrGroupId
                                                                      FROM Sales_License__Share 
                                                                      WHERE ParentId IN: recordIds AND UserOrGroupId IN: userIds
                                                                     ];
        if(listOfLicenseRevokeShareRecords.size() > 0){
            Database.DeleteResult [] results = Database.delete(listOfLicenseRevokeShareRecords,false);
        }
    }
    public static void revokeAccessOnBulkHosts(List<Id> recordIds, List<Id> userIds){
        List<Sales_Host__Share> listOfHostRevokeShareRecords = [SELECT Id, ParentId, UserOrGroup.Name, UserOrGroupId
                                                                FROM Sales_Host__Share 
                                                                WHERE ParentId IN: recordIds AND UserOrGroupId IN: userIds
                                                               ];
        if(listOfHostRevokeShareRecords.size() > 0){
            Database.DeleteResult [] results = Database.delete(listOfHostRevokeShareRecords,false);
        }
    }
    public static void manualShareAccessLicDlgAdmRecord(Id recordId, List<Id> userIds){
        List<Sales_License_Admin_Delegate__Share> listOfRecords = new List<Sales_License_Admin_Delegate__Share>();
        for(Id userId : userIds){         
            Sales_License_Admin_Delegate__Share recShare  = new Sales_License_Admin_Delegate__Share();		
            recShare.ParentId = recordId;		 								
            recShare.UserOrGroupId = userId;									
            recShare.AccessLevel = 'Edit';										
            recShare.RowCause = Schema.Sales_License__Share.RowCause.Manual;				
            listOfRecords.add(recShare);   							
        }
        if(listOfRecords.size() > 0){
            Database.SaveResult[] results = Database.insert(listOfRecords,false);
        }
    }
    public static void revokeAccessLicDlgAdmRecord(Id recordId, List<Id> userIds){
        List<Sales_License_Admin_Delegate__Share> listRevokeShareRecords = [SELECT Id, ParentId, UserOrGroup.Name, UserOrGroupId
                                                                            FROM Sales_License_Admin_Delegate__Share 
                                                                            WHERE ParentId =: recordId AND UserOrGroupId IN: userIds
                                                                           ];
        if(listRevokeShareRecords.size() > 0){
            Database.DeleteResult [] results = Database.delete(listRevokeShareRecords,false);
        }
    }
}