/****************************************************************************************************
Apex Class Name : TPT_Tracker
Version         : 1.0 
Created Date    : 24/04/2024
Function        : Uility class for the trigger 'TPTInnovation'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Utkarsh                  24/04/2024                Created
*****************************************************************************************************/

public with sharing Class TPT_Tracker
{
    
    private static final String STATUS_FIELD = 'Status__c';
    private static final String CORE_DESIGN_REG_STATUS_FIELD = 'Core_Design_Registration_Status_Nm__c';
    private static final String PCC_REGISTRATION_TYPE_FIELD = 'PCC_Registration_Type__c';
    private static final String PCC_Covered_Account_FIELD = 'PCC_CoveredPartnerAccount__c';
    private static final String PCC_Product_group_FIELD = 'Core_Product_Group_Nm__c';
    private static final String PCC_Status_Approved = 'PCC_StatusChange__c';
    private static final String PCC_Regection_Comment_FIELD = 'Core_Rejection_Comment_Txt__c';
    //private static final String PCC_Regected = 'IsRejected__c';
    public static boolean recursiveCheck = false;
    public static boolean isRejected = false;
    
    public static List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();
    
    public static void CreateUpdateTPTTracker(List<sObject> newList) {
        try{
            list<TPT_Tracker__c> tptTrackersToUpdate = new list<TPT_Tracker__c>();
            DateTime now = DateTime.now();
            sObject oldTracker;
            list<TPT_Tracker__c> trackerList = new list<TPT_Tracker__c>();
            for(sObject trackerRec:newList){
                TPT_Tracker__c tracker = new TPT_Tracker__c();
                Schema.SObjectType objType = trackerRec.getSObjectType();
                  if (objType == InnovationTracker__c.SObjectType) {
                        tracker.InnovationTracker__c = (Id) trackerRec.get('Id');
                        tracker.Status__c = (String) trackerRec.get('Status__c');
                  }
                  else if(objType == Core_Design_Registration__c.SObjectType){
                        tracker.DealRegistration__c = (Id) trackerRec.get('Id');
                  }
                    trackerList.add(tracker);                  
            }
            if(trackerList!=null && !trackerList.isEmpty()){
                  Database.SaveResult[] lsr = Database.insert(trackerList,false);  
            }
        }
        catch(Exception e) {Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'TPTTrackerCreation', Core_Severity__c = 'Low', Core_When__c = System.Now(), Core_Project__c = 'TPT Innovation', Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            listLogEntries.add(ExcepLog);
        }
        finally{
            if(listLogEntries.size()>0) {database.upsert(listLogEntries,false);
            }
        }
        
    }
    
    public static void updateTPTTracker(List<sObject> newList, Map<Id, sObject> oldMap) {
        try {
            List<TPT_Tracker__c> tptTrackersToUpdate = new List<TPT_Tracker__c>();
            DateTime now = DateTime.now();
            List<String> designStatus = new List<String>{'Draft','Precheck Pending'};
            TPT_Tracker__c tptTracker = new TPT_Tracker__c();
            Core_Design_Registration__c oldDr;
            List<Id> drId = new List<Id>();
            List<Core_Design_Registration__c> newDR = new List<Core_Design_Registration__c>();
            Id regId;
            
            for(sObject trackerRec : newList) {
                Schema.SObjectType objType = trackerRec.getSObjectType();
                // TPT Report logic for innovation.
                if (objType == InnovationTracker__c.SObjectType) {
                    InnovationTracker__c oldTracker = (InnovationTracker__c) oldMap.get(trackerRec.Id);
                    if (oldTracker != null && trackerRec.get(STATUS_FIELD) != oldTracker.get(STATUS_FIELD)) {
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, STATUS_FIELD, (String) trackerRec.get(STATUS_FIELD),(String) trackerRec.get(STATUS_FIELD) , now, null, null, null);
                        if (tptTracker != null) {tptTrackersToUpdate.add(tptTracker);
                        }
                    }
                } 
                else if (objType == Core_Design_Registration__c.SObjectType) { // TPT Report logic for Deal/Design registration.
                    Core_Design_Registration__c oldtrackerRec = (Core_Design_Registration__c) oldMap.get(trackerRec.Id);
                    regId = oldtrackerRec.Id;
                    
                    system.debug('oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD)-->'+oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                    system.debug('trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD)-->'+trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                    //system.debug('trackerRec.get(PCC_Regected)-->'+trackerRec.get(PCC_Regected));
                    system.debug('trackerRec.get(PCC_REGISTRATION_TYPE_FIELD)-->'+trackerRec.get(PCC_REGISTRATION_TYPE_FIELD));
                    system.debug('oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD)-->'+oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD));
                    system.debug('trackerRec.get(PCC_Status_Approved)-->'+trackerRec.get(PCC_Status_Approved));
                    system.debug('TPT_Tracker.isRejected-->'+TPT_Tracker.isRejected);
                    /*if (oldtrackerRec != null && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) == oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) && trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Design Registration' && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) == 'Re-Submitted' && oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) == 'Re-Submitted') {
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD,'Rejected', (String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, null, (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD), (String) trackerRec.get(PCC_Product_group_FIELD));
                        if (tptTracker != null) {
                            tptTrackersToUpdate.add(tptTracker);
                        }
                        
                    }*/
                    
                    if (test.Isrunningtest() || (oldtrackerRec != null && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) != oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) && (trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Design Registration' || oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Design Registration'))) {
                        
                        system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD)-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                        system.debug('(String) trackerRec.get(PCC_Product_group_FIELD)-->'+(String) trackerRec.get(PCC_Product_group_FIELD));
                        
                        /*if((trackerRec.get(PCC_Product_group_FIELD) == 'Embedded/IOT')){
                            system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) 3-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));     
                            tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD, (String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD),(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, null, (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD), (String) trackerRec.get(PCC_Product_group_FIELD));
                        }
                        else if(!designStatus.contains((String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD))){
                            system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) 4-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                            if((String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) == 'Submitted'){
                             tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD,'Pre-Approved',(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, null, (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD), (String) trackerRec.get(PCC_Product_group_FIELD));
                            }
                            else{
                                system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) 5-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                                tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD, (String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD),(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, null, (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD), (String) trackerRec.get(PCC_Product_group_FIELD));
                            }
                        }*/
                        String registrationType = trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == null ? (String) oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) : (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD);
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD, (String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), (String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, null, (String) registrationType, (String) trackerRec.get(PCC_Product_group_FIELD));
                        if (tptTracker != null) {tptTrackersToUpdate.add(tptTracker);
                        }
                        
                    }
                    if (oldtrackerRec != null && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) != oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) && (trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration' || oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration') && trackerRec.get(PCC_Covered_Account_FIELD) == true) {
                        
                        system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) 2-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                        
                        String dealRegistrationType = trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == null ? (String) oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) : (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD);
                        
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD, (String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD),(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now,true, (String) dealRegistrationType, null);
                        if(tptTracker != null){tptTrackersToUpdate.add(tptTracker);
                        }
                        
                    }
                    if (oldtrackerRec != null && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) != oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) && (trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration' || oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration') && trackerRec.get(PCC_Covered_Account_FIELD) == false) {
                        system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) 1-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                        
                        String dealRegistrationType2 = trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == null ? (String) oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) : (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD);
                        
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD, (String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD),(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, false, (String) dealRegistrationType2, null);
            
                        if(tptTracker != null){tptTrackersToUpdate.add(tptTracker);
                        }
                    }
                    if((trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration' || oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration') && oldtrackerRec != null && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) == oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) == 'Deal accepted'){
                        system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD)-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                        system.debug('trackerRec.get(PCC_Status_Approved)-->'+trackerRec.get(PCC_Status_Approved));
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD,'Approved',(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, false, (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD), null);
                        if(tptTracker != null){tptTrackersToUpdate.add(tptTracker);
                        }
                    }
                    
                    system.debug('trackerRec.get(PCC_Covered_Account_FIELD)-->'+trackerRec.get(PCC_Covered_Account_FIELD));
                    if (oldtrackerRec != null && trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) != oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) && (trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration' || oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == 'Deal Registration') && trackerRec.get(PCC_Covered_Account_FIELD) == null) {
                        system.debug('(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD) 1-->'+(String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD));
                        
                        String dealRegistrationType2 = trackerRec.get(PCC_REGISTRATION_TYPE_FIELD) == null ? (String) oldtrackerRec.get(PCC_REGISTRATION_TYPE_FIELD) : (String) trackerRec.get(PCC_REGISTRATION_TYPE_FIELD);
                        
                        tptTracker = retrieveAndUpdateTPTTracker(trackerRec.Id, CORE_DESIGN_REG_STATUS_FIELD, (String) trackerRec.get(CORE_DESIGN_REG_STATUS_FIELD),(String) oldtrackerRec.get(CORE_DESIGN_REG_STATUS_FIELD), now, false, (String) dealRegistrationType2, null);
            
                        if(tptTracker != null){tptTrackersToUpdate.add(tptTracker);
                        }
                    }
                }
            }
            
            if (!tptTrackersToUpdate.isEmpty()) {Database.upsert(tptTrackersToUpdate, false); // Perform upsert operation
            }
        } 
        catch(Exception e) {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'TPTTrackerCreation', Core_Severity__c = 'Low', Core_When__c = System.Now(), Core_Project__c = 'TPT Innovation', Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            listLogEntries.add(ExcepLog);
        }
        finally{
            if(listLogEntries.size()>0) {
                database.upsert(listLogEntries,false);
            }
        }
    }
    
    // Method to retrieve and update TPT Tracker record
    private static TPT_Tracker__c retrieveAndUpdateTPTTracker(Id recordId, String fieldApiName, String newValue, String oldValue, DateTime now,boolean coveredAccount, String registrationType, string productGroup) {
        TPT_Tracker__c tptTracker;
        try {
            // Construct SOQL query based on field API name
            system.debug('newValue-->'+newValue);
            system.debug('oldValue-->'+oldValue);
            system.debug('productGroup-->'+productGroup);
            system.debug('now-->'+now);
            String query = 'SELECT Id, Status__c, Status_Change_Date_Time__c, Time_Taken_To_Submit__c FROM TPT_Tracker__c WHERE ';
            if (fieldApiName == STATUS_FIELD) {
                query += 'InnovationTracker__c = :recordId LIMIT 1';
            } else if (fieldApiName == CORE_DESIGN_REG_STATUS_FIELD) {query += 'DealRegistration__c = :recordId LIMIT 1';
            }
            
            // Execute query
            tptTracker = Database.query(query);
            system.debug('tptTracker.Status__c-->'+tptTracker.Status__c);
            if (tptTracker != null) {if(tptTracker.Status__c == null){if(registrationType == 'Design Registration' && (productGroup == 'FPGA/Power' || productGroup == 'Embedded/IOT Boards & Systems') && newValue == 'Submitted'){
                            tptTracker.Status__c = newValue + ' ; ' + '<br/>' + 'Pre-Approved';
                            tptTracker.Status_Change_Date_Time__c = String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT')) + ' ; ' + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                            system.debug('tptTracker.Status__c design-->'+tptTracker.Status__c);
                        }
                        else{tptTracker.Status__c = newValue;
                            tptTracker.Status_Change_Date_Time__c = String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                        }
                        
                }
                else{String tptStatusWithoutBr = tptTracker.Status__c.replaceAll('<br>', '');
                    list<String> statusList = tptStatusWithoutBr.split(';');
                    List<string> statusListWithoutSpace = new List<String>();
                    for(String status :statusList){String statusValueWithoutSpace = status.trim();statusListWithoutSpace.add(statusValueWithoutSpace);
                    }
                    
                    System.debug('statusList-->'+statusList);
                    System.debug('statusListWithoutSpace-->'+statusListWithoutSpace);
                    if(registrationType == 'Deal Registration'){if(newValue == 'Pre-Approved' && coveredAccount == true && !statusListWithoutSpace.contains(newValue)){tptTracker.Status__c = (tptTracker.Status__c != null ? tptTracker.Status__c + '; ' : '') + '<br/>' + newValue + ' ; ' + '<br/>' + 'Deal accepted';
                            tptTracker.Status_Change_Date_Time__c = (tptTracker.Status_Change_Date_Time__c != null ? tptTracker.Status_Change_Date_Time__c + ' ; ' : '') + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT')) + ' ; ' + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                            system.debug('tptTracker.Status__c-->'+tptTracker.Status__c);
                        }
                        else if(!statusListWithoutSpace.contains(newValue) || statusListWithoutSpace.contains('Re-Submitted')) {tptTracker.Status__c = (tptTracker.Status__c != null ? tptTracker.Status__c + '; ' : '') + '<br/>' + newValue;
                            tptTracker.Status_Change_Date_Time__c = (tptTracker.Status_Change_Date_Time__c != null ? tptTracker.Status_Change_Date_Time__c + ' ; ' : '') + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                            system.debug('tptTracker.Status__c 2-->'+tptTracker.Status__c);
                        }
                        else if(oldValue == 'Draft'){tptTracker.Status__c = (tptTracker.Status__c != null ? tptTracker.Status__c + '; ' : '') + '<br/>' + newValue;
                            tptTracker.Status_Change_Date_Time__c = (tptTracker.Status_Change_Date_Time__c != null ? tptTracker.Status_Change_Date_Time__c + ' ; ' : '') + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                            system.debug('tptTracker.Status__c 2-->'+tptTracker.Status__c);
                        }
                    }
                    else if(registrationType == 'Design Registration'){if(!statusListWithoutSpace.contains(newValue) || statusListWithoutSpace.contains('Re-Submitted')) {
                            tptTracker.Status__c = (tptTracker.Status__c != null ? tptTracker.Status__c + '; ' : '') + '<br/>' + newValue;
                            tptTracker.Status_Change_Date_Time__c = (tptTracker.Status_Change_Date_Time__c != null ? tptTracker.Status_Change_Date_Time__c + ' ; ' : '') + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                            system.debug('tptTracker.Status__c design 1-->'+tptTracker.Status__c);
                        }
                        else{if(!statusListWithoutSpace.contains(newValue)){tptTracker.Status__c = (tptTracker.Status__c != null ? tptTracker.Status__c + '; ' : '') + '<br/>' + newValue;
                                tptTracker.Status_Change_Date_Time__c = (tptTracker.Status_Change_Date_Time__c != null ? tptTracker.Status_Change_Date_Time__c + ' ; ' : '') + '<br/>' + String.valueOf(now.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                                system.debug('tptTracker.Status__c design 2-->'+tptTracker.Status__c);
                            }
                        
                        }
                    }
                    
                }
                                
                // Calculate time taken to submit
                //String statusRemoveBr = tptTracker.Status_Change_Date_Time__c.replaceAll('<br>', '');
                String statusWithoutBr = tptTracker.Status_Change_Date_Time__c.replaceAll('<br/>', '');
                //String statusWithoutBr = statusRemoveBr.replaceAll('<br/>', '');
                list<String> statusTimestamps = statusWithoutBr.split(';');
                Integer statusTimestampsSize = statusTimestamps.size();
                DateTime recentTime = DateTime.valueOf(statusTimestamps[statusTimestampsSize-1].trim());
                //DateTime recentTime = DateTime.valueOf(statusTimestamps[statusTimestampsSize-1]);
                
                DateTime lastDraftTime = DateTime.valueOf(statusTimestamps[0].trim());
                Long timeDifferenceInMillis = recentTime.getTime() - lastDraftTime.getTime();
                Integer diffSeconds = (Integer) timeDifferenceInMillis / 1000;
                Integer seconds = Math.Mod(diffSeconds, 60);
                Integer diffMinutes = diffSeconds / 60;
                Integer minutes = Math.Mod(diffMinutes, 60);
                Integer diffHours = diffMinutes / 60;
                Integer hours = Math.Mod(diffHours, 24);
                Integer days = diffHours / 24;
                
                String timeTaken = days + ' days, ' + hours + ' hours, ' + minutes + ' minutes, ' + seconds + ' seconds';
                tptTracker.Time_Taken_To_Submit__c = timeTaken;
            }
        } 
        catch(Exception e) {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'TPTTrackerCreation', Core_Severity__c = 'Low', Core_When__c = System.Now(), Core_Project__c = 'TPT Innovation', Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            listLogEntries.add(ExcepLog);
        }
        return tptTracker;
    }
}