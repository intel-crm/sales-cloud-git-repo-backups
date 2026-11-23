/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_ManageCPQLicenseAssignment implements Database.Batchable<sObject>, Database.Stateful{
    
    static String PACKAGE_NAMESPACE_PREFIX = 'SBQQ';
    
    public DateTime dtWhen;
    PackageLicense pl;
    Integer addLicenseCount = 0;

    public Pricing_ManageCPQLicenseAssignment(){
        dtWhen = system.now();
    }

    public Database.querylocator start(Database.BatchableContext bc){
        // Get the list of users assigned to CPQ permission set    
        return Database.getQueryLocator([SELECT Id FROM User WHERE ID IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =:Label.Pricing_CPQ_Managed_License_User ) 
        AND ID NOT in (SELECT UserId FROM UserPackageLicense WHERE (PackageLicense.NamespacePrefix =: PACKAGE_NAMESPACE_PREFIX))]);
    }

    public void execute(Database.BatchableContext bc, List<User> usr){
        try{            
            List<UserPackageLicense> addLicense =  new List<UserPackageLicense>();

            // Get package license details
            pl = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, ExpirationDate, Status FROM PackageLicense 
                  WHERE NamespacePrefix = :PACKAGE_NAMESPACE_PREFIX LIMIT 1];

            // Users who do not have license add it
            for(User u: usr){
                UserPackageLicense upl = new UserPackageLicense();
                upl.PackageLicenseId = pl.Id;
                upl.UserId = u.Id;
                addLicense.add(upl);
            }

            if(addLicense.size() > 0){
                Database.insert(addLicense, false);
                addLicenseCount = addLicenseCount + addLicense.size();
            }
        }catch(exception ex){     
            Pricing_Tender_Utility.logError(ex);
        }    
    }


    public void finish(Database.BatchableContext bc){
        // Send email summary for the batch, number of users added/removed licence used / remaining.
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }

    private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();

        String allowedLicense = pl != null ? String.valueOf(pl.AllowedLicenses) : 'No new users to Add';

        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        
        // Create Assign log Entry
        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
        addLogEntry.Core_Origin__c = 'IQR Batch for Assignment/Removal of CPQ License';
        addLogEntry.Core_Project__c = 'Intel Quote Request (IQR)';
        addLogEntry.Core_Scope__c = 'CPQ License assignment';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for CPQ License Assignment';
        addLogEntry.Core_When__c = dtWhen;
        addLogEntry.Core_Details__c = 'Duration: ' + duration + ' seconds\r\n  \r\n ' + addLicenseCount + 
                                        ' CPQ License added. ' + 'Allowed Licenses: ' + allowedLicense;

        lstLogEntry.add(addLogEntry);        
        return(lstLogEntry);
    }
}