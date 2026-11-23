/*****************************************************
Component Name    : Sales_UpdateSharingonAccountChange
Created Date  : Jan 2022
Function      : <TWC3144-675> : DEV - Retrigerring sharing logic for license host and license Admin delegate
Modification Log :
Developer                       Date                    Description
Dnyanada Argulwar             01/05/2022                 TWC3144-34
*****************************************************/
@isTest
public without sharing class Sales_UpdateSharingonAccountChange {
    /*public static final string ORIGIN = 'Sales_UpdateSharingonAccountChange';
    //public static final string CRITICALSEVERITY = 'Critical';--Unused
    public static final string INFOSEVERITY = 'Info';
    //public static final string SUCCESSSEVERITY = 'Operation Completed Successfully!';--Unused
    //public static final string FAILSEVERITY = 'Operation Failed!';--Unused
    //public static final string HOSTOBJECTNAME = 'Sales_Host__c';--Unused
    //public static final string LICENSEOBJECTNAME = 'Sales_License__c';--Unused
    //public static final string LICENSEADMINDELEGATEOBJECTNAME = 'Sales_License_Admin_Delegate__c';--Unused
    public static final string PROJECT = 'PSG Sales';
    public static boolean BypassTriggerForContactUpdate=false;
    public static void updateSharingOn_LicenseHost(Set<Id> ContactIdSet){
        if(Core_SendContact_to_AGS_onGECChange.BypassContactSharingMethod==false){
            Core_SendContact_to_AGS_onGECChange.BypassContactSharingMethod=true;
            System.enqueueJob(new UpadateSharingOnLicense(ContactIdSet));
            System.enqueueJob(new UpadateSharingOnHost(ContactIdSet));
            System.enqueueJob(new UpadateSharingOnLicenseAdmin(ContactIdSet));
        }
    }
    public without sharing class UpadateSharingOnLicense implements System.Queueable{
        private Set<id> ContactIdSet;
        public UpadateSharingOnLicense(Set<id> ContactIdSet){
            this.ContactIdSet=ContactIdSet;
        }
        public void execute(System.QueueableContext ctx){
            if(ContactIdSet.size() > 0){
                for(Sales_License_Admin_Delegate__c licAdminDel: [Select Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_delegate__c where Sales_License_isActive__c=true and (Sales_License_PrimaryAdmin_Contact__c IN: ContactIdSet or  Sales_License_DlgAdmin_Contact__c IN: ContactIdSet) ] ){
                    if(licAdminDel.Sales_License_PrimaryAdmin_Contact__c!=null){
                        ContactIdSet.add(licAdminDel.Sales_License_PrimaryAdmin_Contact__c);
                    }
                    if(licAdminDel.Sales_License_DlgAdmin_Contact__c!=null){
                        ContactIdSet.add(licAdminDel.Sales_License_DlgAdmin_Contact__c);
                    }
                }
                List<Sales_License__c> licensesToShareList = [Select Id, Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Primary_Admin_Contact__r.Account.IsPartner,Sales_License_Lic_User_Contact_ID__r.Account.IsPartner,Sales_License_Web_Display_Flag__c from Sales_License__c where Sales_License_Web_Display_Flag__c=true and (Sales_License_Primary_Admin_Contact__c IN :ContactIdSet or Sales_License_Lic_User_Contact_ID__c IN: ContactIdSet)];
                if(!licensesToShareList.isEmpty()){
                    Sales_LicenseTriggerUtility.shareLicenseRecordsWithDelegates(licensesToShareList, null);
                }
            }  
        }
    }
    public without sharing class UpadateSharingOnHost implements System.Queueable{
        private Set<id> ContactIdSet;
        public UpadateSharingOnHost(Set<id> ContactIdSet){
            this.ContactIdSet=ContactIdSet;
        }
        public void execute(System.QueueableContext ctx){
            if(ContactIdSet.size() > 0){
                for(Sales_License_Admin_Delegate__c licAdminDel: [Select Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_delegate__c where Sales_License_isActive__c=true and (Sales_License_PrimaryAdmin_Contact__c IN: ContactIdSet or  Sales_License_DlgAdmin_Contact__c IN: ContactIdSet) ] ){
                    if(licAdminDel.Sales_License_PrimaryAdmin_Contact__c!=null){
                        ContactIdSet.add(licAdminDel.Sales_License_PrimaryAdmin_Contact__c);
                    }
                    if(licAdminDel.Sales_License_DlgAdmin_Contact__c!=null){
                        ContactIdSet.add(licAdminDel.Sales_License_DlgAdmin_Contact__c);
                    }
                }
                List<Sales_Host__c> hostsToShareList = [Select Id, Sales_Contact__c from Sales_Host__c where Sales_Contact__c IN: ContactIdSet];
                if(!hostsToShareList.isEmpty()){
                    Sales_HostTriggerUtility.shareHostRecordsWithDelegates(hostsToShareList, null);
                }
            }
        }
    }
    public without sharing class UpadateSharingOnLicenseAdmin implements System.Queueable{
        private Set<id> ContactIdSet;
        public UpadateSharingOnLicenseAdmin(Set<id> ContactIdSet){
            this.ContactIdSet=ContactIdSet;
        }
        public void execute(System.QueueableContext ctx){
            //Set<Id> ContactSet =new Set<Id>();--Unused
            if(ContactIdSet.size() > 0){
                List<Sales_License_Admin_Delegate__c> licAdminDelSharingList= [Select Id, Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_delegate__c where Sales_License_isActive__c=true and (Sales_License_PrimaryAdmin_Contact__c IN: ContactIdSet) ];
                if(!licAdminDelSharingList.isEmpty()){
                    //Sales_LicenseAdminDelegateUtility.shareRecordsWithDelegates(licAdminDelSharingList,null);
                }
            }
        }
    }*/
}