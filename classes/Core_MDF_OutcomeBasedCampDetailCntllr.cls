/****************************************************************************************************************************************
* Class Name       : Core_MDF_OutcomeBasedCampDetailCntllr 
* Test Class Name  : Core_MDF_OutcomeBasedDetailCntllrTest
* Version          : 1.0 
* Created Date     : 23/03/2026
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Ramapriya       23/03/2026         Server-side Controller class of Core_MDF_OutcomeBasedCampDetail 
												 (used for Outcome-Based Campaigns Detail Page)
*****************************************************************************************************************************************/
public without sharing class Core_MDF_OutcomeBasedCampDetailCntllr {
 @TestVisible private static Boolean testForceObjectAccessException = false;
    @TestVisible private static Boolean testCanCreateOverride;
    @TestVisible private static Boolean testCanUpdateOverride;
    @TestVisible private static Boolean testCanDeleteOverride;

    private static Boolean canCreateInternalNotes() {
        if (Test.isRunningTest() && testCanCreateOverride != null) {
            return testCanCreateOverride;
        }
        return Core_MDF_Notes__c.SObjectType.getDescribe().isCreateable();
    }

    private static Boolean canUpdateInternalNotes() {
        if (Test.isRunningTest() && testCanUpdateOverride != null) {
            return testCanUpdateOverride;
        }
        return Core_MDF_Notes__c.SObjectType.getDescribe().isUpdateable();
    }

    private static Boolean canDeleteInternalNotes() {
        if (Test.isRunningTest() && testCanDeleteOverride != null) {
            return testCanDeleteOverride;
        }
        return Core_MDF_Notes__c.SObjectType.getDescribe().isDeletable();
    }

    @AuraEnabled
    public static Map<String, Boolean> getInternalNotesObjectAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        accessMap.put('canCreate', false);
        accessMap.put('canUpdate', false);
        accessMap.put('canDelete', false);

        try {
            if (Test.isRunningTest() && testForceObjectAccessException) {
                throw new AuraHandledException('Forced test exception');
            }

            Schema.DescribeSObjectResult notesDescribe = Core_MDF_Notes__c.SObjectType.getDescribe();
            accessMap.put('canCreate', testCanCreateOverride != null ? testCanCreateOverride : notesDescribe.isCreateable());
            accessMap.put('canUpdate', testCanUpdateOverride != null ? testCanUpdateOverride : notesDescribe.isUpdateable());
            accessMap.put('canDelete', testCanDeleteOverride != null ? testCanDeleteOverride : notesDescribe.isDeletable());
        } catch (Exception e) {
            System.debug('ERROR in getInternalNotesObjectAccess: ' + e.getMessage());
        }

        return accessMap;
    }
    
//Method to check whether the User has access to view the record
    @AuraEnabled
    public static UserAccessResult checkUserRecordAccess(String recordId, String objectApiName) {
        UserAccessResult result = new UserAccessResult();
        
        try {
            
            // Handle empty recordId
            if (String.isBlank(recordId)) {
                result.hasAccess = false;
                return result;
            }
            
            // Handle invalid Id with different object
            Id recId = Id.valueOf(recordId);
            String objectName = recId.getSObjectType().getDescribe().getName();
            
            if (!objectName.equalsIgnoreCase(objectApiName)) {
                result.hasAccess = false;
                return result;
            }
            
            // Query UserRecordAccess
            List<UserRecordAccess> accessList = [
                SELECT RecordId, HasReadAccess, HasEditAccess
                FROM UserRecordAccess
                WHERE UserId = :UserInfo.getUserId()
                AND RecordId = :recordId
                LIMIT 1
            ];
            
            if (accessList.isEmpty()) {
                result.hasAccess = false;
                return result;
            }
            
            UserRecordAccess userAccess = accessList[0];
            
            if (!accessList.isEmpty() && (userAccess.HasReadAccess || userAccess.HasEditAccess)){
                result.hasAccess = true;
                result.recordId = userAccess.RecordId;
            } else {
                result.hasAccess = false;
            }
            
        } catch (Exception e) {
            result.hasAccess = false;
        }
        
        return result;
    }
    
    // Wrapper class to return access information
    public class UserAccessResult {
        @AuraEnabled public Boolean hasAccess { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        
        public UserAccessResult() {
            this.hasAccess = false;
        }
    }
 /**
     * @description Get internal notes (Core_MDF_Notes__c) linked to the activity record
     * @param recordId The PartnerFundRequest (activity) record ID
    * @return List of note wrapper maps with Name, Title, Comments, CreatedByName, CreatedDateFormatted
     */
    @AuraEnabled
    public static List<Map<String, String>> getInternalNotes(String recordId) {
        List<Map<String, String>> notesList = new List<Map<String, String>>();
        try {
            if (String.isBlank(recordId)) {
                return notesList;
            }

            List<Core_MDF_Notes__c> noteRecs = [
                SELECT Id,
                       Name,
                       Core_MDF_Title_txt__c,
                       Core_MDF_Comments_txt__c,
                       CreatedBy.Name,
                       CreatedDate
                FROM Core_MDF_Notes__c
                WHERE Core_MDF_Activity_id__c = :recordId
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];

            for (Core_MDF_Notes__c noteRec : noteRecs) {
                Map<String, String> n = new Map<String, String>();
                n.put('Id', noteRec.Id);
                n.put('Name', noteRec.Name != null ? noteRec.Name : '');
                n.put('Title', noteRec.Core_MDF_Title_txt__c != null ? noteRec.Core_MDF_Title_txt__c : '');
                n.put('Comments', noteRec.Core_MDF_Comments_txt__c != null ? noteRec.Core_MDF_Comments_txt__c : '');
                n.put('CreatedByName', noteRec.CreatedBy != null ? noteRec.CreatedBy.Name : '');
                n.put('CreatedDateFormatted', noteRec.CreatedDate != null
                    ? noteRec.CreatedDate.format('MMM d, yyyy h:mm a') : '');
                notesList.add(n);
            }
        } catch (Exception e) {
            System.debug('ERROR in getInternalNotes: ' + e.getMessage());
        }
        return notesList;
    }

    /**
     * @description Create a new internal note in Core_MDF_Notes__c linked to activity
     * @param parentRecordId The PartnerFundRequest record ID
     * @param noteTitle The note title (Core_MDF_Title_txt__c)
     * @param noteBody The comments value (Core_MDF_Comments_txt__c)
     * @return Boolean indicating success
     */
    @AuraEnabled
    public static Boolean createInternalNote(String parentRecordId, String noteTitle, String noteBody) {
        try {
            if (String.isBlank(parentRecordId) || String.isBlank(noteTitle)) {
                throw new AuraHandledException('Title and parent record are required.');
            }

            if (!canCreateInternalNotes()) {
                throw new AuraHandledException('You do not have permission to create Internal Notes.');
            }

            Core_MDF_Notes__c noteRec = new Core_MDF_Notes__c();
            noteRec.Core_MDF_Activity_id__c = parentRecordId;
            noteRec.Core_MDF_Title_txt__c = noteTitle;
            noteRec.Core_MDF_Comments_txt__c = noteBody;
            insert noteRec;

            return true;

        } catch (Exception e) {
            System.debug('ERROR in createInternalNote: ' + e.getMessage());
            throw new AuraHandledException('Unable to save Internal Note: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateInternalNote(String noteId, String noteTitle, String noteBody) {
        try {
            if (String.isBlank(noteId) || String.isBlank(noteTitle)) {
                throw new AuraHandledException('Note ID and title are required.');
            }

            if (!canUpdateInternalNotes()) {
                throw new AuraHandledException('You do not have permission to edit Internal Notes.');
            }

            Core_MDF_Notes__c noteRec = [
                SELECT Id, Core_MDF_Title_txt__c, Core_MDF_Comments_txt__c
                FROM Core_MDF_Notes__c
                WHERE Id = :noteId
                LIMIT 1
            ];

            noteRec.Core_MDF_Title_txt__c = noteTitle;
            noteRec.Core_MDF_Comments_txt__c = noteBody;
            update noteRec;

            return true;

        } catch (Exception e) {
            System.debug('ERROR in updateInternalNote: ' + e.getMessage());
            throw new AuraHandledException('Unable to update Internal Note: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean deleteInternalNote(String noteId) {
        try {
            if (String.isBlank(noteId)) {
                throw new AuraHandledException('Note ID is required.');
            }

            if (!canDeleteInternalNotes()) {
                throw new AuraHandledException('You do not have permission to delete Internal Notes.');
            }

            Core_MDF_Notes__c noteRec = [
                SELECT Id
                FROM Core_MDF_Notes__c
                WHERE Id = :noteId
                LIMIT 1
            ];

            delete noteRec;
            return true;

        } catch (Exception e) {
            System.debug('ERROR in deleteInternalNote: ' + e.getMessage());
            throw new AuraHandledException('Unable to delete Internal Note: ' + e.getMessage());
        }
    }
}