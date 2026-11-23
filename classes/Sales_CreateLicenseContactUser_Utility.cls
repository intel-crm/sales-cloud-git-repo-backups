/********************************************************************************************************************
Class Name    : Sales_CreateLicenseContactUser_Utility
Version       : 1.0
Created Date  : September 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           6-Sept-2021             Utility class for LicenseContactUser
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_CreateLicenseContactUser_Utility {
    /*private static final string ORIGIN = 'Sales_CreateLicenseContactUser_Utility';
    public static Id createLicenseContactUsers(Map<String, User> emailUserIdMap){
        Id contactIdToReturn;
        Map<id, id> usrIdContactIdMapForInsert = new Map<Id, id>();
        if(emailUserIdMap != null && !emailUserIdMap.isEmpty()){            
            List<Contact> contactsList = new List<Contact>();           
            Set<id> contactIdsForSharing = new Set<Id>();
            List<Sales_License_ContactUser__c> existingLicConUsr = [Select Id,Sales_License_Contact__c , Sales_License_User__c from Sales_License_ContactUser__c where Sales_License_Contact__r.Email IN:emailUserIdMap.keyset() limit 1];               
            if(!existingLicConUsr.isEmpty()){
                contactIdToReturn = existingLicConUsr[0].Sales_License_Contact__c;                    
            }
            if(contactIdToReturn == null){
                for(Contact con: [Select Id, Email from Contact where Email IN: emailUserIdMap.keyset()]){
                    contactIdToReturn = con.id; 
                    usrIdContactIdMapForInsert.put(emailUserIdMap.get(con.Email).id, con.id);
                }
                if(contactIdToReturn == null){
                    List<Account> accList = [Select Id from Account where Id = :System.label.Sales_PSGAccountForInternalUser limit 1];
                    if(accList.IsEmpty() && Test.isRunningTest()){
                        accList = [Select Id from Account limit 1];    
                    } 
                    if(!accList.IsEmpty()){
                        for(String emailId: emailUserIdMap.keyset()){
                            Contact con = new Contact();
                            con.Email = emailid;
                            con.AccountId = accList[0].id;
                            con.FirstName =  emailUserIdMap.get(emailId).FirstName;
                            con.LastName =  emailUserIdMap.get(emailId).LastName;
                            con.MailingCountry = emailUserIdMap.get(emailId).Country;
                            contactsList.add(con);                        
                        }
                    }
                    if(!contactsList.isEmpty()){
                        Database.SaveResult[] srList =  Database.insert(contactsList, false);
                        Sales_CreateLogRecords.createLogRecords(srList,contactsList,ORIGIN);
                        for(Contact con: contactsList){
                            if(con.id != null && emailUserIdMap.containskey(con.Email)){
                                contactIdToReturn = con.id;
                                usrIdContactIdMapForInsert.put(emailUserIdMap.get(con.Email).id, con.id);    
                            }    
                        }
                    }                                        
                }                                                                
            }
            List<Sales_License_ContactUser__c> licUserContactList = new List<Sales_License_ContactUser__c>();
            if(!usrIdContactIdMapForInsert.isEmpty()){
                for(Id userId: usrIdContactIdMapForInsert.keyset()){
                    Sales_License_ContactUser__c licContactUsr = new Sales_License_ContactUser__c(); 
                    licContactUsr.Sales_License_User__c = userId;
                    licContactUsr.Sales_License_Contact__c = usrIdContactIdMapForInsert.get(userId);
                    licUserContactList.add(licContactUsr);
                }
                Database.SaveResult[] saveResultList =  Database.insert(licUserContactList, false);
                Sales_CreateLogRecords.createLogRecords(saveResultList,licUserContactList,ORIGIN);
                contactIdsForSharing.addAll(usrIdContactIdMapForInsert.values());
                List<id> contactsIdsList = new List<Id>();
                contactsIdsList.addAll(contactIdsForSharing);
            }
        }
        return contactIdToReturn;    
    }  
    @future
    public static void shareLicenseAndHostRecord(Map<id,id> contactUserIds, Map<String, id> emailIdUserIdMap){
        Set<Id> contactIds = new Set<id>();
        if(emailIdUserIdMap != null && !emailIdUserIdMap.isEmpty()){
            Map<id, id> contactUsrMap = getUserContactMap(null,emailIdUserIdMap);
            if(!contactUsrMap.isEmpty()){
                contactUserIds.putAll(contactUsrMap);       
            }
        }
        if(contactUserIds.size() > 0){
            for(Sales_License_Admin_Delegate__c licAdminDel: [Select Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_delegate__c where Sales_License_isActive__c=true and (Sales_License_PrimaryAdmin_Contact__c IN: contactUserIds.keyset() or  Sales_License_DlgAdmin_Contact__c IN: contactUserIds.keyset()) ] ){
                if(!contactUserIds.values().contains(licAdminDel.Sales_License_PrimaryAdmin_Contact__c)){
                    contactIds.add(licAdminDel.Sales_License_PrimaryAdmin_Contact__c);
                }
                if(!contactUserIds.values().contains(licAdminDel.Sales_License_DlgAdmin_Contact__c)){
                    contactIds.add(licAdminDel.Sales_License_DlgAdmin_Contact__c);
                }
            }
            contactUserIds.putAll(getUserContactMap(contactIds,null));
            List<Sales_License__c> licensesToShareList = [Select Id, Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Primary_Admin_Contact__r.Account.IsPartner,Sales_License_Lic_User_Contact_ID__r.Account.IsPartner,Sales_License_Web_Display_Flag__c from Sales_License__c where Sales_License_Web_Display_Flag__c=true and (Sales_License_Primary_Admin_Contact__c IN :contactUserIds.keyset() or Sales_License_Lic_User_Contact_ID__c IN: contactUserIds.keyset())];
            if(!licensesToShareList.isEmpty()){
                Sales_LicenseTriggerUtility.contactUserIdMap = contactUserIds;
                Sales_LicenseTriggerUtility.shareLicenseRecordsWithDelegates(licensesToShareList, null);
            }
            List<Sales_Host__c> hostsToShareList = [Select Id, Sales_Contact__c from Sales_Host__c where Sales_Contact__c IN: contactUserIds.keyset()];
            if(!hostsToShareList.isEmpty()){
                Sales_HostTriggerUtility.contactUserIdMap = contactUserIds;
                Sales_HostTriggerUtility.shareHostRecordsWithDelegates(hostsToShareList, null);
            }
        }
    }
    public static Map<Id, Id> getUserContactMap(Set<id> contactIds, Map<String,Id> emailIdUserIdMap){
        Map<id,id> contactUserMap = new Map<Id, id>();
        if(contactIds != null && !contactIds.isEmpty()){                
            for(User u: [Select id, ContactId from User where ContactId IN: contactIds]){
                contactUserMap.put(u.ContactId, u.id);   
            }
        }else if(emailIdUserIdMap != null && !emailIdUserIdMap.IsEmpty()){
            for(Contact con: [Select Id, Email from Contact where Email IN: emailIdUserIdMap.keyset()]){
                contactUserMap.put(con.id, emailIdUserIdMap.get(con.Email));                      
            }       
        } 
        return contactUserMap;
    }  
    public static Map<Id, Id> getContactUserMapForInternalUser(Set<id> contactIds){
        Map<id, id> contactUserMap = new Map<id, id>();
        if(contactIds != null && !contactIds.isEmpty()){
            for(Sales_License_ContactUser__c licContUser: [Select Id,Sales_License_Contact__c, Sales_License_User__c from Sales_License_ContactUser__c where Sales_License_Contact__c IN: contactIds]){
                contactUserMap.put(licContUser.Sales_License_Contact__c, licContUser.Sales_License_User__c);                    
            }   
        }
        return contactUserMap;
    }*/
}