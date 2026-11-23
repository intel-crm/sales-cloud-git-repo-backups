/*********************************************************************************************************************
Class Name    : Sales_HostTriggerUtility
Version       : 1.0
Created Date  : Apr 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma           21-Apr-2021             Host Information Trigger Utility
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_HostTriggerUtility {
    /*public static Map<id, id> contactUserIdMap;
    public static boolean validateHost = false;
    public static boolean Check=false;
    @AuraEnabled  
    public static  List<Sales_License__c> fetchLicensesFromHost(id hostid){
        List<Sales_License__c> listlic = [select Name,Sales_License_Primary_Admin_Contact__r.Name, Sales_License_Activation_Code__c, Sales_License_Product__r.Name, Sales_License_Type__c, Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c ,Sales_License_Avbl_Qty_Nbr__c, Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Expiration_Date_Dt__c, Sales_License_Maintenance_Exp_Dt__c ,Sales_Lic_User_Contact_Txt__c, Sales_License_Quantity__c from Sales_License__c where Sales_License_Type__c !='Optional' and Sales_License_Web_Display_Flag__c =true and Sales_License_Host_Node_Id__c=:hostid];
        return listlic;
    }
    public static void shareHostRecordsWithDelegates(List<Sales_Host__c> hostList , Map<Id,Sales_Host__c> oldHostMap){
        Set<id> contactIdsForAdminDelegate = new Set<id>();
        Map<Id,List<Id>> primaryAdminsDelegatesMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> GrantAccessMap = new Map<Id,List<Id>>();             
        Map<Id,List<Id>> RevokeAccessMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> RevokeHostAccessForUsersMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> GrantHostAccessForUsersMap = new Map<Id,List<Id>>();
        Map<Id,Id> primaryAdminDelegateUsrMap = new Map<Id,Id>();       
        set<Id> contIds = new Set<Id>();            
        Boolean isAfterInsert, isAfterUpdate;
        if(oldHostMap==null){
            isAfterInsert = true;
            isAfterUpdate = false;    
        }else{
            isAfterInsert = false;
            isAfterUpdate = true;    
        }
        for(Sales_Host__c host: hostList){
            if(host.Sales_Contact__c != null){
                contactIdsForAdminDelegate.add(host.Sales_Contact__c);     
            }
            if(oldHostMap != null && oldHostMap.get(host.id).Sales_Contact__c != null){
                contactIdsForAdminDelegate.add(oldHostMap.get(host.id).Sales_Contact__c);     
            }              
        }
        List<Sales_License_Admin_Delegate__c> allDelegateAdminsList = [SELECT Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c  
                                                                       FROM Sales_License_Admin_Delegate__c WHERE Sales_License_isActive__c=true and Sales_License_PrimaryAdmin_Contact__c IN: contactIdsForAdminDelegate];
        contIds.addAll(contactIdsForAdminDelegate);
        for( Sales_License_Admin_Delegate__c delegateRecord : allDelegateAdminsList ){
            contIds.add(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);      
            if(primaryAdminsDelegatesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c)){
                List<Id> allExistingDelegates = primaryAdminsDelegatesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c);
                allExistingDelegates.add(delegateRecord.Sales_License_DlgAdmin_Contact__c);             
                primaryAdminsDelegatesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , allExistingDelegates);
            }else{              
                primaryAdminsDelegatesMap.put(delegateRecord.Sales_License_PrimaryAdmin_Contact__c , new List<Id>{delegateRecord.Sales_License_DlgAdmin_Contact__c});
            }
            if(primaryAdminsDelegatesMap.containsKey(delegateRecord.Sales_License_PrimaryAdmin_Contact__c)){
                contIds.addAll(primaryAdminsDelegatesMap.get(delegateRecord.Sales_License_PrimaryAdmin_Contact__c));
            }
        }
        if(primaryAdminsDelegatesMap.size() > 0 || contactIdsForAdminDelegate.size() > 0){
            if(isAfterInsert){
                for(Sales_Host__c hostRecord : hostList){                                                         
                    if(hostRecord.Sales_Contact__c != null){  
                        contIds.add(hostRecord.Sales_Contact__c); 
                    }
                }
                if(!contIds.isEmpty()){                    
                    createShareRecordsForHosts createShareRecords = new createShareRecordsForHosts();
                    List<User> usrList = createShareRecords.getUsersList(contIds); 
                    for(User usr: usrList){                     
                        primaryAdminDelegateUsrMap.put(usr.ContactId, usr.Id);
                        contIds.remove(usr.ContactId);
                    }
                    if(usrList.isEmpty() || contIds.size() > 0){
                        Map<Id, id> contUserMap = Sales_CreateLicenseContactUser_Utility.getContactUserMapForInternalUser(contIds);
                        if(contUserMap != null && !contUserMap.isEmpty()){
                            primaryAdminDelegateUsrMap.putAll(contUserMap);     
                        }                       
                    }
                    if(contactUserIdMap != null && !contactUserIdMap.isEmpty()){
                        primaryAdminDelegateUsrMap.putAll(contactUserIdMap);                            
                    }
                }
                Map<Id,List<Id>> manualSharingMap = new Map<Id,List<Id>>();
                for(Sales_Host__c hostRecord : hostList){
                    Id recordId = hostRecord.Id;  
                    List<Id> recUserIds = new List<Id>();
                    if(hostRecord.Sales_Contact__c != null){                  
                        try{
                            if(primaryAdminDelegateUsrMap.containsKey(hostRecord.Sales_Contact__c)){
                                recUserIds.add(primaryAdminDelegateUsrMap.get(hostRecord.Sales_Contact__c));                                
                            }  
                        }catch(System.QueryException e){
                        } 
                        if(primaryAdminsDelegatesMap.containsKey(hostRecord.Sales_Contact__c)){
                            for(Id delegateContId : primaryAdminsDelegatesMap.get(hostRecord.Sales_Contact__c)){
                                if(primaryAdminDelegateUsrMap.containsKey(delegateContId)){
                                    recUserIds.add(primaryAdminDelegateUsrMap.get(delegateContId));
                                }                              
                            }                                                        
                        }
                        if(recUserIds.size() > 0){
                            manualSharingMap.put(recordId, recUserIds);
                        }
                    }                
                }
                if(manualSharingMap.size() > 0){
                    createShareRecordsForHosts createHostShareRec = new createShareRecordsForHosts();
                    createHostShareRec.shareHostRecordsManually(manualSharingMap);
                }                    
            }
            else if(isAfterUpdate){
                for(Sales_Host__c hostRecord : hostList){
                    Id recordId = hostRecord.Id;
                    if(oldHostMap.get(recordId)?.Sales_Contact__c != hostRecord.Sales_Contact__c ){
                        if(oldHostMap.get(recordId)?.Sales_Contact__c != null){ 
                            Id oldPrimaryAdminId = oldHostMap.get(recordId)?.Sales_Contact__c;
                            List<Id> delegateAdminIdsList = primaryAdminsDelegatesMap.get(oldPrimaryAdminId);
                            if(RevokeAccessMap.containsKey(recordId)){
                                List<Id> contactsToRevoke = RevokeAccessMap.get(recordId);
                                contactsToRevoke.add(oldPrimaryAdminId);                                                                                                               
                                if(delegateAdminIdsList != null){
                                    contactsToRevoke.addAll(delegateAdminIdsList);                                                                                   
                                }
                                RevokeAccessMap.put(recordId,contactsToRevoke);
                            }
                            else{
                                List<Id> contactsToRevoke = new List<Id>();
                                contactsToRevoke.add(oldPrimaryAdminId);                                                                                                               
                                if(delegateAdminIdsList != null){
                                    contactsToRevoke.addAll(delegateAdminIdsList);                                                                                   
                                }
                                RevokeAccessMap.put(recordId,contactsToRevoke);
                            }  
                        }
                        if(hostRecord.Sales_Contact__c != null){   
                            Id newPrimaryAdminId =  hostRecord.Sales_Contact__c;
                            List<Id> delegateAdminIdsList = primaryAdminsDelegatesMap.get(hostRecord.Sales_Contact__c);
                            if(GrantAccessMap.containsKey(recordId)){
                                List<Id> contactsToAssign = GrantAccessMap.get(recordId);
                                contactsToAssign.add(newPrimaryAdminId);                                   
                                if(delegateAdminIdsList != null){
                                    contactsToAssign.addAll(delegateAdminIdsList);                                                                                                   
                                }
                                GrantAccessMap.put(recordId,contactsToAssign);
                            }
                            else{
                                List<Id> contactsToAssign = new List<Id>();
                                contactsToAssign.add(newPrimaryAdminId);                                   
                                if(delegateAdminIdsList != null){
                                    contactsToAssign.addAll(delegateAdminIdsList);                                                                                                   
                                }
                                GrantAccessMap.put(recordId,contactsToAssign);
                            } 
                        }
                    }
                }
                Set<Id> allContIds = new Set<Id>();
                Map<Id,Id> contUsrMap = new Map<Id,Id>();
                for( Id licRecId : RevokeAccessMap.keySet() ){
                    allContIds.addAll(RevokeAccessMap.get(licRecId));
                }
                for( Id recId : GrantAccessMap.keySet() ){
                    allContIds.addAll(GrantAccessMap.get(recId));
                }
                if(!allContIds.isEmpty()){  
                    createShareRecordsForHosts createShareRecords = new createShareRecordsForHosts();
                    List<User> usrList = createShareRecords.getUsersList(contIds); 
                    for(User usr: usrList){        
                        contUsrMap.put(usr.ContactId, usr.Id);
                        allContIds.remove((usr.ContactId));
                    }
                    if(usrList.isEmpty() || allContIds.size() > 0){
                        Set<id> contIdsSet = new Set<id>();
                        contIdsSet.addAll(allContIds);
                        Map<Id, id> contUserMap = Sales_CreateLicenseContactUser_Utility.getContactUserMapForInternalUser(contIdsSet);
                        if(contUserMap != null && !contUserMap.isEmpty()){
                            contUsrMap.putAll(contUserMap);     
                        }                       
                    }
                    if(contactUserIdMap != null && !contactUserIdMap.isEmpty()){
                        contUsrMap.putAll(contactUserIdMap);                            
                    }
                    for( Id licRecId : RevokeAccessMap.keySet() ){
                        List<Id> usrIds = new List<Id>();
                        for(Id contId : RevokeAccessMap.get(licRecId)){
                            if(contUsrMap.containsKey(contId)){
                                usrIds.add(contUsrMap.get(contId));
                            }
                        }
                        if(!usrIds.isEmpty()){
                            RevokeHostAccessForUsersMap.put(licRecId,usrIds);
                        }                       
                    }
                    if(RevokeHostAccessForUsersMap.size() > 0){
                        createShareRecordsForHosts createShareRecords1 = new createShareRecordsForHosts();
                        createShareRecords1.revokeSharedEditAccessOnHosts(RevokeHostAccessForUsersMap,GrantHostAccessForUsersMap );
                    }                    
                    for( Id recId : GrantAccessMap.keySet() ){
                        List<Id> grantAccessUsrIds = new List<Id>();
                        for(Id contId : GrantAccessMap.get(recId)){
                            if(contUsrMap.containsKey(contId)){
                                grantAccessUsrIds.add(contUsrMap.get(contId));
                            }                           
                        }
                        if(grantAccessUsrIds.size() > 0){
                            GrantHostAccessForUsersMap.put(recId, grantAccessUsrIds);
                        }                        
                    }
                    if(RevokeHostAccessForUsersMap.size() > 0 || GrantHostAccessForUsersMap.size() > 0){
                        createShareRecordsForHosts revokeShareRecords = new createShareRecordsForHosts();
                        revokeShareRecords.revokeSharedEditAccessOnHosts(RevokeHostAccessForUsersMap,GrantHostAccessForUsersMap );
                    } 
                    if(GrantHostAccessForUsersMap.size() > 0){
                        createShareRecordsForHosts createHostShareRec = new createShareRecordsForHosts();
                        createHostShareRec.shareHostRecordsManually(GrantHostAccessForUsersMap);
                    }
                }
            }
        }
    }
    private without sharing class createShareRecordsForHosts{
        public List<User> getUsersList(Set<Id> contIds){
            return [SELECT Id, ContactId FROM User WHERE ContactId IN :contIds];
        }
        public void shareHostRecordsManually(Map<Id,List<Id>> recUserIdMap){
            List<Sales_Host__Share> listOfHostShareRecords = new List<Sales_Host__Share>();
            for(Id recordId : recUserIdMap.keySet()){
                for(Id usrId : recUserIdMap.get(recordId)){
                    Sales_Host__Share hostShare  = new Sales_Host__Share();                             
                    hostShare.ParentId = recordId;                                                                                                                                            
                    hostShare.UserOrGroupId = usrId;                                                                                                                                    
                    hostShare.AccessLevel = 'Edit';                                                                                                                                             
                    hostShare.RowCause = Schema.Sales_License__Share.RowCause.Manual;                                               
                    listOfHostShareRecords.add(hostShare);     
                }
            }
            if(listOfHostShareRecords.size() > 0){
                Database.SaveResult[] results = Database.insert(listOfHostShareRecords,false);
            }    
        }
        public void revokeSharedEditAccessOnHosts(Map<Id,List<Id>> recUserIdMap, Map<Id,List<Id>> manualAccessShareMap){
            Set<Id> allUserIds = new Set<Id>();
            for(Id recId : recUserIdMap.keySet()){
                allUserIds.addAll(recUserIdMap.get(recId));
            }
            for(Id recId : manualAccessShareMap.keySet()){
                allUserIds.addAll(manualAccessShareMap.get(recId));
            }
            List<Sales_Host__Share> listOfHostRevokeShareRecords = new List<Sales_Host__Share>();
            for(Sales_Host__Share shareRec : [SELECT Id, ParentId, UserOrGroup.Name, UserOrGroupId, RowCause
                                              FROM Sales_Host__Share 
                                              WHERE ParentId IN :recUserIdMap.keySet() or ParentId IN :manualAccessShareMap.keySet()]){
                                                  if(!listOfHostRevokeShareRecords.contains(shareRec) && recUserIdMap.containsKey(shareRec.ParentId) && recUserIdMap.get(shareRec.ParentId).contains(shareRec.UserOrGroupId)){
                                                      listOfHostRevokeShareRecords.add(shareRec);
                                                  }   
                                                  if(!listOfHostRevokeShareRecords.contains(shareRec) && manualAccessShareMap.containsKey(shareRec.ParentId) && !manualAccessShareMap.get(shareRec.ParentId).contains(shareRec.UserOrGroupId) && shareRec.RowCause == 'Manual'){
                                                      listOfHostRevokeShareRecords.add(shareRec);
                                                  }
                                              }
            if(listOfHostRevokeShareRecords.size() > 0){
                Database.DeleteResult [] results = Database.delete(listOfHostRevokeShareRecords,false);
            }
        }
    }
    public static void manualShareEditAccessOnHosts(Map<Id,List<Id>> recUserIdMap){
        List<Sales_Host__Share> listOfHostShareRecords = new List<Sales_Host__Share>();
        for(Id recordId : recUserIdMap.keySet()){
            for(Id usrId : recUserIdMap.get(recordId)){
                Sales_Host__Share hostShare  = new Sales_Host__Share();                             
                hostShare.ParentId = recordId;                                                                                                                                            
                hostShare.UserOrGroupId = usrId;                                                                                                                                    
                hostShare.AccessLevel = 'Edit';                                                                                                                                             
                hostShare.RowCause = Schema.Sales_License__Share.RowCause.Manual;                                               
                listOfHostShareRecords.add(hostShare);     
            }
        }
        if(listOfHostShareRecords.size() > 0){
            Database.SaveResult[] results = Database.insert(listOfHostShareRecords,false);
        }
    }
    public static void revokeSharedEditAccessOnHosts(Map<Id,List<Id>> recUserIdMap){
        Set<Id> allUserIds = new Set<Id>();
        for(Id recId : recUserIdMap.keySet()){
            allUserIds.addAll(recUserIdMap.get(recId));
        }
        List<Sales_Host__Share> listOfHostRevokeShareRecords = new List<Sales_Host__Share>();
        for(Sales_Host__Share shareRec : [SELECT Id, ParentId, UserOrGroup.Name, UserOrGroupId
                                          FROM Sales_Host__Share 
                                          WHERE ParentId IN :recUserIdMap.keySet() AND UserOrGroupId IN :allUserIds]){
                                              if(recUserIdMap.get(shareRec.ParentId).contains(shareRec.UserOrGroupId)){
                                                  listOfHostRevokeShareRecords.add(shareRec);
                                              }                   
                                          }
        if(listOfHostRevokeShareRecords.size() > 0){
            Database.DeleteResult [] results = Database.delete(listOfHostRevokeShareRecords,false);
        }
    }
    public static void validateUpdateOnHost(Map<Id, Sales_Host__c> newHostsMap, Map<Id, Sales_Host__c> oldHostMap){
        string ORIGIN = 'Sales_HostTriggerUtility';
        string PROJECT = 'PSG Sales';
        Set<id> updatedHostIdsSet = new Set<id>();
        Set<id> updateRehostforRedundantSet = new Set<id>();
        List<Sales_License__c> licensesList= new List<Sales_License__c>();
        List<Sales_License__c> redundantLicensesList= new List<Sales_License__c>();
        for(Sales_Host__c host: newHostsMap.values()){
            if(oldHostMap != null && ((oldHostMap.get(host.id).Sales_License_Type__c != host.Sales_License_Type__c) || 
                                      (oldHostMap.get(host.id).Sales_Computer_Type__c != host.Sales_Computer_Type__c) || 
                                      (oldHostMap.get(host.id).Name != host.Name)||((oldHostMap.get(host.id).Sales_Companion_Server1_Txt__c != host.Sales_Companion_Server1_Txt__c) && (host.Sales_License_Type__c =='FIXED') || 
                                                                                    (oldHostMap.get(host.id).Sales_Companion_Server2_Txt__c != host.Sales_Companion_Server2_Txt__c) && (host.Sales_License_Type__c =='FIXED'))))
            {
                updatedHostIdsSet.add(host.id);
            }
            if(oldHostMap != null && ((oldHostMap.get(host.id).Sales_License_Type__c != host.Sales_License_Type__c) || 
                                      (oldHostMap.get(host.id).Sales_Computer_Type__c != host.Sales_Computer_Type__c) || 
                                      (oldHostMap.get(host.id).Name != host.Name)||((oldHostMap.get(host.id).Sales_Redundant_Server1_Txt__c != host.Sales_Redundant_Server1_Txt__c) && (oldHostMap.get(host.id).Sales_License_Type__c =='FLOAT') || 
                                                                                    (oldHostMap.get(host.id).Sales_Redundant_Server2_Txt__c != host.Sales_Redundant_Server2_Txt__c)&&(oldHostMap.get(host.id).Sales_License_Type__c =='FLOAT'))))
            {
                updateRehostforRedundantSet.add(host.id);
            }
        }
        for(Sales_License__c lic: [Select Id, Sales_Tool_License_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Txt__c from Sales_License__c where (Sales_License_Host_Node_Id__c IN: updatedHostIdsSet or Sales_License_Host_Node_Id__c IN: updateRehostforRedundantSet)])
        {
            if(!(((lic.Sales_Tool_License_Type__c=='FIXED' || lic.Sales_Tool_License_Type__c=='NEUTRAL') && newHostsMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_License_Type__c=='FIXED') || ((lic.Sales_Tool_License_Type__c=='FLOAT' || (lic.Sales_Tool_License_Type__c=='NEUTRAL') || (lic.Sales_Tool_License_Type__c=='N-A')) && newHostsMap.get(lic.Sales_License_Host_Node_Id__c)?.Sales_License_Type__c=='FLOAT'))){
                newHostsMap.get(lic.Sales_License_Host_Node_Id__c).addError(System.label.Sales_LicenseTypeMismatch);
            }
            if(lic.Sales_License_Avbl_Rehost_Nbr__c > 0){
                if((oldHostMap != null) && (newHostsMap!=null) && (Check!=true) && (( oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c !=null && (oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c)) || 
                                                                                    ( oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c !=null && (oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c)) || 
                                                                                    ( oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Name !=null && (oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Name != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Name)) ||((newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c =='FIXED') && (((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c !=null) && (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c)  || 
                                                                                                                                                                                                                                                                                                                                                                        ((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c !=null) && (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c))) || ( (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c =='FLOAT') && (((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) && ( newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c) || 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          ((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c !=null) && (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) &&  oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c)))))
                {
                    lic.Sales_License_Avbl_Rehost_Nbr__c=lic.Sales_License_Avbl_Rehost_Nbr__c-1;
                    lic.Sales_License_Host_Node_Txt__c = newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Name ;
                    licensesList.add(lic); 
                }    
            }   
            else if(lic.Sales_License_Avbl_Rehost_Nbr__c < 1 || lic.Sales_License_Avbl_Rehost_Nbr__c == null){
                if((oldHostMap != null) && (newHostsMap!=null) && ((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c!=null && (oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c)) || 
                                                                   ((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c !=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c) || 
                                                                   ( oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Name !=null && (oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Name != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Name))||((newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c =='FIXED') && (((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c !=null) && (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c)  || 
                                                                                                                                                                                                                                                                                                                                                      ((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c !=null) && (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c))) || ( (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c =='FLOAT') && (((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) && ( newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) && oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c) || 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ((oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c !=null) && (newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) &&  oldHostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c != newHostsMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c)))))
                {
                    newHostsMap.get(lic.Sales_License_Host_Node_Id__c).addError(System.label.Sales_rehostErorr);
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','Host Id:'+lic.Sales_License_Host_Node_Id__c,'Rehost on license is error',lic.Sales_License_Host_Node_Id__c, '', '');  
                }
            }
        }
        if(licensesList.size()>0)
        {
            update licensesList;
            Check =true;
        }
        if(redundantLicensesList.size()>0)
        {
            update redundantLicensesList;
        }
    }   
    public static void validatePrimaryAdminContactOnHost(List<Sales_License__c>LicenseList,Set<id>hostSet,Map<Id, Sales_Host__c>hostMap){
        Set<String> contactIdSet = new Set<String>();
        Set<String> licUsercontactIdSet = new Set<String>(); 
        for(Sales_License__c licList:LicenseList){
            if(licList.Sales_License_Primary_Admin_Contact__c!=null){
                contactIdSet.add(licList.Sales_License_Primary_Admin_Contact__c);
            }
            if(licList.Sales_License_Lic_User_Contact_ID__c!=null){
                contactIdSet.add(licList.Sales_License_Lic_User_Contact_ID__c);
            }
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_PrimaryAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            contactIdSet.add(licAdmin.Sales_License_DlgAdmin_Contact__c); 
        }
        for (Sales_Host__c hostList :[Select id,Sales_Contact__c from Sales_Host__c where id in : hostSet and Sales_Contact__c!=null])
        {
            if(!contactIdSet.contains(hostMap.get(hostList.id).Sales_Contact__c)){
                hostMap.get(hostList.id).Sales_Contact__c.addError(System.label.Sales_InvalidHost_Error);
            }
        }
    }*/
}