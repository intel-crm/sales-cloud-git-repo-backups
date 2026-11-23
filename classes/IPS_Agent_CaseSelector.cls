public with sharing class IPS_Agent_CaseSelector {

    /*
     * ============================================================
     * GET CASE BY CASE NUMBER
     * ============================================================
     */
    public static Case getCaseByNumber(String caseNumber) {

        if (String.isBlank(caseNumber)) {
            throw new IPS_Agent_Exception(
                'Case number is required'
            );
        }

        List<Case> cases = [
            SELECT
                Id,
                CaseNumber,
                Subject,
                CreatedDate,
                ClosedDate,
                Status,
                Description,
                Priority,
                Comments,
                Core_Issue_Description__c,
                Core_Closure_Comment__c,
                Core_IPS_email_text__c,
                Core_IPS_Product_name__c,
                Core_IPS_Case_Owner_Name__c,
                Core_IPS_Case_Owner_Email__c,
                Core_IPS_Internal_Note__c,
                Core_IPS_Problem_Statement__c,
                Core_IPS_Resolution__c,
                Core_IPS_Knowledge_Base_Link__c,
                Core_IPS_Project_Case__c
            FROM Case
            WHERE CaseNumber = :caseNumber
            WITH USER_MODE
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new IPS_Agent_Exception(
                'Case not found'
            );
        }

        return cases[0];
    }


    /*
     * ============================================================
     * GET MY OPEN CASES
     * ============================================================
     */
    public static List<Case> getMyOpenCases(
        String userEmail
    ) {

        if (String.isBlank(userEmail)) {
            throw new IPS_Agent_Exception(
                'User email is required'
            );
        }

        List<User> users = [
            SELECT
                Id,
                Name,
                Email
            FROM User
            WHERE Email = :userEmail
            AND IsActive = true
            WITH USER_MODE
            LIMIT 1
        ];

        if (users.isEmpty()) {
            throw new IPS_Agent_Exception(
                'User not found'
            );
        }

        Id ownerId = users[0].Id;

        return [
            SELECT
                Id,
                CaseNumber,
                Subject,
                CreatedDate,
                ClosedDate,
                Status,
                Description,
                Priority,
                Comments,
                Core_Issue_Description__c,
                Core_Closure_Comment__c,
                Core_IPS_email_text__c,
                Core_IPS_Product_name__c,
                Core_IPS_Case_Owner_Name__c,
                Core_IPS_Case_Owner_Email__c,
                Core_IPS_Internal_Note__c,
                Core_IPS_Problem_Statement__c,
                Core_IPS_Resolution__c,
                Core_IPS_Knowledge_Base_Link__c,
                Core_IPS_Project_Case__c
            FROM Case
            WHERE OwnerId = :ownerId
            AND Status NOT IN ('Closed', 'Resolved')
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }


    /*
     * ============================================================
     * GET HISTORICAL CASES
     * ============================================================
     */
    public static List<Case> getHistoricalCases(
        String productName,
        Id currentCaseId
    ) {

        return [
            SELECT
                Id,
                CaseNumber,
                Subject,
                CreatedDate,
                ClosedDate,
                Status,
                Description,
                Priority,
                Comments,
                Core_Issue_Description__c,
                Core_Closure_Comment__c,
                Core_IPS_email_text__c,
                Core_IPS_Product_name__c,
                Core_IPS_Case_Owner_Name__c,
                Core_IPS_Case_Owner_Email__c,
                Core_IPS_Internal_Note__c,
                Core_IPS_Problem_Statement__c,
                Core_IPS_Resolution__c,
                Core_IPS_Knowledge_Base_Link__c,
                Core_IPS_Project_Case__c
            FROM Case
            WHERE Core_IPS_Product_name__c = :productName
            AND Status IN ('Closed', 'Resolved')
            AND Id != :currentCaseId
            WITH USER_MODE
            ORDER BY ClosedDate DESC
            LIMIT 50
        ];
    }


    /*
     * ============================================================
     * GET CASE COMMENTS
     * ============================================================
     */
    public static List<Core_IPS_Case_Comments__c> getCaseComments(
        Id caseId
    ) {

        return [
            SELECT
                Id,
                Core_IPS_Comment__c,
                CreatedDate,
                CreatedBy_Name__c
            FROM Core_IPS_Case_Comments__c
            WHERE Core_IPS_Case__c = :caseId
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }

    /*
     * ============================================================
     * GET IPS PROJECT ASSOCIATED WITH CASE
     * ============================================================
     */
    public static Core_IPS_Project__c getCaseProject(
        Id projectId
    ) {

        if (projectId == null) {
            throw new IPS_Agent_Exception(
                'No project is associated with this case'
            );
        }


        List<Core_IPS_Project__c> projects = [
            SELECT
                Id,
                Core_IPS_Project_ID__c,
                Name,
                Core_Project_Description__c
            FROM Core_IPS_Project__c
            WHERE Id = :projectId
            AND IsDeleted = false
            WITH USER_MODE
            LIMIT 1
        ];


        if (projects.isEmpty()) {
            throw new IPS_Agent_Exception(
                'Project not found'
            );
        }


        return projects[0];
    }


    /*
     * ============================================================
     * GET IPS ATTACHMENTS FOR CASE
     * ============================================================
     */
    public static List<Core_IPS_Case_Attachments__c>
        getCaseAttachments(
            String caseNumber
        ) {

        if (String.isBlank(caseNumber)) {
            throw new IPS_Agent_Exception(
                'Case number is required'
            );
        }


        Case c =
            IPS_Agent_CaseSelector.getCaseByNumber(
                caseNumber
            );


        List<Core_IPS_Case_Attachments__c> attachments = [
            SELECT
                Id,
                Core_File_Name__c,
                Core_File_URL__c,
                Core_File_Description__c
            FROM Core_IPS_Case_Attachments__c
            WHERE Core_Case__c = :c.Id
            AND IsDeleted = false
            WITH USER_MODE
            LIMIT 50
        ];


        if (attachments.isEmpty()) {
            throw new IPS_Agent_Exception(
                'No attachments found for Case ' +
                caseNumber
            );
        }


        return attachments;
    }


     /*
    * ============================================================
    * GET FILES ASSOCIATED WITH CASE
    * ============================================================
    *
    * Returns file metadata only.
    *
    * LatestPublishedVersionId represents the latest
    * published version of each file.
    *
    * VersionData is NOT loaded here.
    * ============================================================
    */
    public static List<ContentDocumentLink> getCaseFiles(
        Id caseId
    ) {

        if (caseId == null) {
            throw new IPS_Agent_Exception(
                'Case Id is required'
            );
        }

        return [
            SELECT
                ContentDocumentId,
                ContentDocument.Title,
                ContentDocument.FileType,
                ContentDocument.FileExtension,
                ContentDocument.ContentSize,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.CreatedDate,
                ContentDocument.LastModifiedDate
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseId
            WITH USER_MODE
            ORDER BY ContentDocument.LastModifiedDate DESC
            LIMIT 50
        ];
    }


    /*
    * ============================================================
    * GET SMALL FILE CONTENT
    * ============================================================
    *
    * Only use this for small text files.
    *
    * Large/binary files should be downloaded directly
    * by the MCP Node server through Salesforce REST API.
    * ============================================================
    */
    public static ContentVersion getFileVersion(
        Id versionId
    ) {

        if (versionId == null) {
            throw new IPS_Agent_Exception(
                'Content Version Id is required'
            );
        }

        List<ContentVersion> versions = [
            SELECT
                Id,
                ContentDocumentId,
                Title,
                FileExtension,
                FileType,
                ContentSize,
                VersionData
            FROM ContentVersion
            WHERE Id = :versionId
            WITH USER_MODE
            LIMIT 1
        ];

        if (versions.isEmpty()) {
            throw new IPS_Agent_Exception(
                'File version not found'
            );
        }

        return versions[0];
    }
}