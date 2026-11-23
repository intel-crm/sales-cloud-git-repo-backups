/*****************************************************
Component Name    : Sales_UpdateContactDetails
Created Date  : Jan 2022
Function      : <TWC3144-34> : DEV - Contact's email address is updated but license record still showing old email address
Modification Log :
Developer                       Date                    Description
Dnyanada Argulwar             01/05/2022                 TWC3144-34
*****************************************************/
public without sharing class Sales_UpdateContactDetails {
    public static final string ORIGIN = 'Sales_UpdateContactDetails';
    //public static final string CRITICALSEVERITY = 'Critical';--Unused
    public static final string INFOSEVERITY = 'Info';
    //public static final string SUCCESSSEVERITY = 'Operation Completed Successfully!';--Unused
    //public static final string FAILSEVERITY = 'Operation Failed!';--Unused
    //public static final string HOSTOBJECTNAME = 'Sales_Host__c';--Unused
    //public static final string LICENSEOBJECTNAME = 'Sales_License__c';--Unused
    //public static final string LICENSEADMINDELEGATEOBJECTNAME = 'Sales_License_Admin_Delegate__c';--Unused
    public static final string PROJECT = 'PSG Sales';
    public static boolean BypassTriggerForContactUpdate=false;
    public static void updateContactDetails_LicenseHost(List<Contact> contactList){
   
        Set<String> license_Primary_Admin_Email=new Set<String>();
        Set<String> contactName=new Set<String>();
        set<id> contactId=new Set<Id>();
        for(contact con: contactList){
            license_Primary_Admin_Email.add(con.Email);
            String contactFullName = con.FirstName+' '+con.LastName;
            contactName.add(contactFullName);  
            contactId.add(con.id);
        }
        System.enqueueJob(new UpadateContactDetailsOnLicenseHost(contactId,license_Primary_Admin_Email,contactName));
    }
    public static void updateContactDetails_LicenseAdminDelegate(List<Contact> contactList){
        BypassTriggerForContactUpdate=true;
        set<id> contactId=new Set<Id>();
        for(contact con: contactList){  
            contactId.add(con.id);
        }
        List<Sales_License_Admin_Delegate__c> adminDlgList=[Select id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_PrimaryAdmin_Email_Txt__c,Sales_License_PrimaryAdmin_FirstName_Txt__c,Sales_License_PrimaryAdmin_LastName_Txt__c,
                                                            Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Email_Txt__c,Sales_License_DlgAdmin_FirstName_Txt__c,Sales_License_DlgAdmin_LastName_Txt__c,Sales_License_Dlg_Adm_FullName__c,
                                                            Sales_License_PrimaryAdmin_Contact__r.name,Sales_License_PrimaryAdmin_Contact__r.FirstName,Sales_License_PrimaryAdmin_Contact__r.LastName,Sales_License_PrimaryAdmin_Contact__r.email,Sales_License_DlgAdmin_Contact__r.name,Sales_License_DlgAdmin_Contact__r.email,
                                                            Sales_License_DlgAdmin_Contact__r.FirstName,Sales_License_DlgAdmin_Contact__r.LastName from Sales_License_Admin_Delegate__c 
                                                            where (Sales_License_PrimaryAdmin_Contact__c=:contactId or Sales_License_DlgAdmin_Contact__c=:contactId)];
        try{
            if(adminDlgList.size()>0){
                for (Sales_License_Admin_Delegate__c admDlg : adminDlgList){
                    if(admDlg.Sales_License_PrimaryAdmin_Email_Txt__c!=admDlg.Sales_License_PrimaryAdmin_Contact__r.email){
                        admDlg.Sales_License_PrimaryAdmin_Email_Txt__c=admDlg.Sales_License_PrimaryAdmin_Contact__r.email;
                    }
                    if(admDlg.Sales_License_PrimaryAdmin_FirstName_Txt__c!=admDlg.Sales_License_PrimaryAdmin_Contact__r.FirstName){
                        admDlg.Sales_License_PrimaryAdmin_FirstName_Txt__c=admDlg.Sales_License_PrimaryAdmin_Contact__r.FirstName;
                    }
                    if(admDlg.Sales_License_PrimaryAdmin_LastName_Txt__c!=admDlg.Sales_License_PrimaryAdmin_Contact__r.LastName){
                        admDlg.Sales_License_PrimaryAdmin_LastName_Txt__c=admDlg.Sales_License_PrimaryAdmin_Contact__r.LastName;
                    }
                    if(admDlg.Sales_License_DlgAdmin_Email_Txt__c!=admDlg.Sales_License_DlgAdmin_Contact__r.email){
                        admDlg.Sales_License_DlgAdmin_Email_Txt__c=admDlg.Sales_License_DlgAdmin_Contact__r.email;
                    }
                    if(admDlg.Sales_License_DlgAdmin_FirstName_Txt__c!=admDlg.Sales_License_DlgAdmin_Contact__r.FirstName){
                        admDlg.Sales_License_DlgAdmin_FirstName_Txt__c=admDlg.Sales_License_DlgAdmin_Contact__r.FirstName;
                    }
                    if(admDlg.Sales_License_DlgAdmin_LastName_Txt__c!=admDlg.Sales_License_DlgAdmin_Contact__r.LastName){
                        admDlg.Sales_License_DlgAdmin_LastName_Txt__c=admDlg.Sales_License_DlgAdmin_Contact__r.LastName;
                    }
                    /* else if(AdmDlg.Sales_License_Dlg_Adm_FullName__c!=AdmDlg.Sales_License_DlgAdmin_Contact__r.name){
                    	AdmDlg.Sales_License_Dlg_Adm_FullName__c=AdmDlg.Sales_License_DlgAdmin_Contact__r.name;
                    }*/
                }
                Update adminDlgList; 
            }
        }
        catch (Exception e){
        }
    }
    public without sharing class UpadateContactDetailsOnLicenseHost implements System.Queueable{
        private set<Id> contactId;
        private Set<String> license_Primary_Admin_Email;
        private Set<String> contactName;
        public UpadateContactDetailsOnLicenseHost(set<Id> contactId,Set<String> license_Primary_Admin_Email, Set<String> contactName){
            this.contactId=contactId;
            this.license_Primary_Admin_Email=license_Primary_Admin_Email;
            this.contactName=contactName;
        }
        public void execute(System.QueueableContext ctx){
            BypassTriggerForContactUpdate=true;
            Boolean successPriLicense=true; 
            Boolean successLicLicense=true; 
            Boolean successHost=true; 
            List<Sales_License__c> licenseUserLicenseList=[select id,name,Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Lic_User_Contact_ID__r.Email, Sales_License_Primary_Admin_Contact__r.Email, 
                                                           Sales_License_PriAdm_Email__c , Licensed_User_Email_Address_Txt__c,Sales_License_Primary_Admin_Contact_Txt__c,Sales_Lic_User_Contact_Txt__c,Sales_License_Lic_User_Contact_ID__r.Name, 
                                                           Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Lic_User_Contact_ID__r.FirstName,Sales_License_Lic_User_Contact_ID__r.LastName from Sales_License__c where ( Sales_License_Lic_User_Contact_ID__c=:contactId)and
                                                           (
                                                               (Licensed_User_Email_Address_Txt__c not in :license_Primary_Admin_Email) or
                                                               (Sales_Lic_User_Contact_Txt__c not in :contactName) ) limit 10000 FOR UPDATE 
                                                          ];
            if(licenseUserLicenseList.size()>0){
                try{
                    for (Sales_License__c lc : licenseUserLicenseList) {
                        String conName=lc.Sales_License_Lic_User_Contact_ID__r.FirstName+' '+lc.Sales_License_Lic_User_Contact_ID__r.LastName;
                        if(lc.Licensed_User_Email_Address_Txt__c!=lc.Sales_License_Lic_User_Contact_ID__r.Email){
                            lc.Licensed_User_Email_Address_Txt__c=lc.Sales_License_Lic_User_Contact_ID__r.Email;
                        }
                        if( lc.Sales_Lic_User_Contact_Txt__c!=conName){
                            lc.Sales_Lic_User_Contact_Txt__c=conName;
                        }
                    }
                    update licenseUserLicenseList;
                    System.enqueueJob(new UpadateContactDetailsOnLicenseHost(contactId,license_Primary_Admin_Email,contactName)); 
                }
                catch (Exception e){
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateContactDetails.ORIGIN, Sales_UpdateContactDetails.PROJECT,'',Sales_UpdateContactDetails.INFOSEVERITY,'','Error Occurred While Initialing the updation of contact Details on license admin  : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                    successLicLicense=false;
                }
            }
            else{
                List<Sales_License__c> primaryAdminLicenseList=[select id,name,Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Lic_User_Contact_ID__r.Email, Sales_License_Primary_Admin_Contact__r.Email, 
                                                                Sales_License_PriAdm_Email__c , Licensed_User_Email_Address_Txt__c,Sales_License_Primary_Admin_Contact_Txt__c,Sales_Lic_User_Contact_Txt__c,Sales_License_Lic_User_Contact_ID__r.Name, 
                                                                Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Primary_Admin_Contact__r.FirstName,Sales_License_Primary_Admin_Contact__r.LastName from Sales_License__c where (Sales_License_Primary_Admin_Contact__c =:contactId )and
                                                                ((Sales_License_PriAdm_Email__c not in :license_Primary_Admin_Email) or
                                                                 (Sales_License_Primary_Admin_Contact_Txt__c not in :contactName)
                                                                ) limit 10000 FOR UPDATE 
                                                               ];
                if(primaryAdminLicenseList.size()>0){
                    try{
                        for (Sales_License__c lc : primaryAdminLicenseList) {
                            String conName=lc.Sales_License_Primary_Admin_Contact__r.FirstName+' '+lc.Sales_License_Primary_Admin_Contact__r.LastName;
                            if(lc.Sales_License_PriAdm_Email__c!=lc.Sales_License_Primary_Admin_Contact__r.Email){
                                lc.Sales_License_PriAdm_Email__c=lc.Sales_License_Primary_Admin_Contact__r.Email;   
                            }
                            if(lc.Sales_License_Primary_Admin_Contact_Txt__c!=conName){
                                lc.Sales_License_Primary_Admin_Contact_Txt__c=conName;
                            }
                        }
                        update primaryAdminLicenseList;
                        System.enqueueJob(new UpadateContactDetailsOnLicenseHost(contactId,license_Primary_Admin_Email,contactName)); 
                    }
                    catch (Exception e){
                        Core_Log_Entry.logEntryWithDetails(Sales_UpdateContactDetails.ORIGIN, Sales_UpdateContactDetails.PROJECT,'',Sales_UpdateContactDetails.INFOSEVERITY,'','Error Occurred While Initialing the updation of contact Details on primary admin  : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                        successPriLicense=false;
                    }
                }else{
                    List<Sales_Host__c> hostList=[select id,Sales_Contact__c, Sales_Primary_Admin_Email__c,
                                                  Sales_Primary_Admin_Name__c,Sales_Contact__r.name,Sales_Contact__r.Email,Sales_Contact__r.FirstName,Sales_Contact__r.LastName from Sales_Host__c where
                                                  Sales_Contact__c=:contactId and (Sales_Primary_Admin_Email__c not in :license_Primary_Admin_Email or
                                                                                   Sales_Primary_Admin_Name__c not in :contactName) limit 10000];
                    if(hostList.size()>0){
                        try{
                            for (Sales_Host__c h : hostList){
                                String conName=h.Sales_Contact__r.FirstName+' '+h.Sales_Contact__r.LastName;
                                if(h.Sales_Primary_Admin_Email__c!=h.Sales_Contact__r.Email){
                                    h.Sales_Primary_Admin_Email__c=h.Sales_Contact__r.Email;
                                }
                                if(h.Sales_Primary_Admin_Name__c!=conName){
                                    h.Sales_Primary_Admin_Name__c=conName;
                                }
                            }
                            update hostList;     
                            System.enqueueJob(new UpadateContactDetailsOnLicenseHost(contactId,license_Primary_Admin_Email,contactName)); 
                        }
                        catch (Exception e){
                            Core_Log_Entry.logEntryWithDetails(Sales_UpdateContactDetails.ORIGIN, Sales_UpdateContactDetails.PROJECT,'',Sales_UpdateContactDetails.INFOSEVERITY,'','Error Occurred While Initialing the updation of contact Details on host : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', ''); 
                            successHost=false;
                        }
                    }
                }
                if(successLicLicense==true && successPriLicense==true){                
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateContactDetails.ORIGIN, Sales_UpdateContactDetails.PROJECT,'',Sales_UpdateContactDetails.INFOSEVERITY,'','Successfully Updated contact Details on License','','', '');    
                }
                if(successHost==true){                
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateContactDetails.ORIGIN, Sales_UpdateContactDetails.PROJECT,'',Sales_UpdateContactDetails.INFOSEVERITY,'','Successfully Updated contact Details on Host','','', '');   
                }  
            }
        }
    }
}