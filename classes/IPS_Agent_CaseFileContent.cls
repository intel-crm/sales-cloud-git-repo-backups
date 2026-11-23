global with sharing class IPS_Agent_CaseFileContent {

    /*
     * ============================================================
     * MAXIMUM APEX TEXT FILE SIZE
     * ============================================================
     *
     * 2 MB
     *
     * Files above this limit should use DIRECT_DOWNLOAD
     * through the MCP server.
     */
    private static final Long MAX_FILE_SIZE = 2097152;


    /*
     * ============================================================
     * REQUEST
     * ============================================================
     */
    global class Request {

        @InvocableVariable(
            label='Case Number'
            description='Salesforce Case Number'
            required=true
        )
        global String caseNumber;


        @InvocableVariable(
            label='Content Version Id'
            description='Latest Content Version Id returned by IPS Agent Get Case Files'
            required=true
        )
        global String contentVersionId;
    }


    /*
     * ============================================================
     * RESPONSE
     * ============================================================
     */
    global class Response {

        @InvocableVariable(
            label='Success'
        )
        global Boolean success;


        @InvocableVariable(
            label='Case Number'
        )
        global String caseNumber;


        @InvocableVariable(
            label='Content Document Id'
        )
        global String contentDocumentId;


        @InvocableVariable(
            label='Content Version Id'
        )
        global String contentVersionId;


        @InvocableVariable(
            label='File Name'
        )
        global String fileName;


        @InvocableVariable(
            label='File Type'
        )
        global String fileType;


        @InvocableVariable(
            label='Extension'
        )
        global String extension;


        @InvocableVariable(
            label='Content Size'
        )
        global Long contentSize;


        @InvocableVariable(
            label='Content'
            description='Readable text content of the file'
        )
        global String content;


        @InvocableVariable(
            label='Error'
        )
        global String error;
    }


    /*
     * ============================================================
     * MCP TOOL
     * ============================================================
     */
    @InvocableMethod(
        label='IPS Agent Get Case File Content'
        description='Reads the latest version of a small text file associated with a Salesforce Case. Binary and large files must use direct download.'
        category='IPS Agent'
    )
    global static List<Response> getCaseFileContent(
        List<Request> requests
    ) {

        List<Response> responses =
            new List<Response>();


        if (requests == null) {
            return responses;
        }


        for (Request request : requests) {

            Response response =
                new Response();

            response.success = false;


            try {

                /*
                 * ----------------------------------------------------
                 * Validate request
                 * ----------------------------------------------------
                 */
                if (request == null) {

                    response.error =
                        'Request is required';

                    responses.add(response);
                    continue;
                }


                if (
                    String.isBlank(
                        request.caseNumber
                    )
                ) {

                    response.error =
                        'Case number is required';

                    responses.add(response);
                    continue;
                }


                if (
                    String.isBlank(
                        request.contentVersionId
                    )
                ) {

                    response.error =
                        'Content Version Id is required';

                    responses.add(response);
                    continue;
                }


                String caseNumber =
                    request.caseNumber.trim();


                String requestedVersionId =
                    request.contentVersionId.trim();


                /*
                 * ----------------------------------------------------
                 * Step 1
                 *
                 * Get Case.
                 * ----------------------------------------------------
                 */
                Case caseRecord =
                    IPS_Agent_CaseSelector.getCaseByNumber(
                        caseNumber
                    );


                /*
                 * ----------------------------------------------------
                 * Step 2
                 *
                 * Get file metadata associated with Case.
                 *
                 * VersionData is NOT loaded here.
                 * ----------------------------------------------------
                 */
                List<ContentDocumentLink> links =
                    IPS_Agent_CaseSelector.getCaseFiles(
                        caseRecord.Id
                    );


                /*
                 * ----------------------------------------------------
                 * Step 3
                 *
                 * Verify that the requested ContentVersion:
                 *
                 * 1. belongs to a file on this Case
                 * 2. is the latest published version
                 * ----------------------------------------------------
                 */
                ContentDocumentLink matchedFile =
                    null;


                if (links != null) {

                    for (ContentDocumentLink link : links) {

                        if (
                            link == null ||
                            link.ContentDocument == null ||
                            link.ContentDocument
                                .LatestPublishedVersionId == null
                        ) {
                            continue;
                        }


                        String latestVersionId =
                            String.valueOf(
                                link.ContentDocument
                                    .LatestPublishedVersionId
                            );


                        if (
                            latestVersionId ==
                            requestedVersionId
                        ) {

                            matchedFile =
                                link;

                            break;
                        }
                    }
                }


                /*
                 * ----------------------------------------------------
                 * File security/relationship check failed.
                 * ----------------------------------------------------
                 */
                if (matchedFile == null) {

                    response.error =
                        'File is not associated with the specified Case or is not the latest version.';

                    responses.add(response);
                    continue;
                }


                /*
                 * ----------------------------------------------------
                 * Step 4
                 *
                 * Check size BEFORE loading VersionData.
                 * ----------------------------------------------------
                 */
                Long fileSize =
                    matchedFile.ContentDocument.ContentSize;


                if (fileSize == null) {

                    response.error =
                        'Unable to determine file size.';

                    responses.add(response);
                    continue;
                }


                if (
                    fileSize > MAX_FILE_SIZE
                ) {

                    response.error =
                        'File is too large for Apex text retrieval. ' +
                        'Use DIRECT_DOWNLOAD through the MCP server.';

                    responses.add(response);
                    continue;
                }


                /*
                 * ----------------------------------------------------
                 * Step 5
                 *
                 * Only text files may be converted from Blob
                 * to String.
                 *
                 * DO NOT add PDF/DOCX/PNG/etc here.
                 * ----------------------------------------------------
                 */
                String extension =
                    matchedFile.ContentDocument.FileExtension;


                if (!isTextFile(extension)) {

                    response.error =
                        'File is binary and cannot be returned as text. ' +
                        'Use DIRECT_DOWNLOAD through the MCP server.';

                    responses.add(response);
                    continue;
                }


                /*
                 * ----------------------------------------------------
                 * Step 6
                 *
                 * Now retrieve VersionData.
                 *
                 * We only reach this point for a small text file.
                 * ----------------------------------------------------
                 */
                ContentVersion version =
                    IPS_Agent_CaseSelector.getFileVersion(
                        matchedFile.ContentDocument
                            .LatestPublishedVersionId
                    );


                if (
                    version == null ||
                    version.VersionData == null
                ) {

                    response.error =
                        'File content is empty';

                    responses.add(response);
                    continue;
                }


                /*
                 * ----------------------------------------------------
                 * Step 7
                 *
                 * Build metadata response.
                 * ----------------------------------------------------
                 */
                response.caseNumber =
                    caseRecord.CaseNumber;


                response.contentDocumentId =
                    String.valueOf(
                        version.ContentDocumentId
                    );


                response.contentVersionId =
                    String.valueOf(
                        version.Id
                    );


                response.fileName =
                    buildFileName(
                        version.Title,
                        version.FileExtension
                    );


                response.fileType =
                    version.FileType;


                response.extension =
                    version.FileExtension;


                response.contentSize =
                    version.ContentSize;


                /*
                 * ----------------------------------------------------
                 * Step 8
                 *
                 * Convert Blob to String.
                 *
                 * SAFE ONLY because we already checked that this
                 * is one of our supported text extensions.
                 *
                 * Binary files never reach this line.
                 * ----------------------------------------------------
                 */
                response.content =
                    version.VersionData.toString();


                response.success = true;
                response.error = null;

            }
            catch (Exception e) {

                response.success = false;
                response.error = e.getMessage();
            }


            responses.add(response);
        }


        return responses;
    }


    /*
     * ============================================================
     * TEXT FILE CHECK
     * ============================================================
     */
    private static Boolean isTextFile(
        String extension
    ) {

        if (String.isBlank(extension)) {
            return false;
        }


        String ext =
            extension.toLowerCase();


        return (
            ext == 'txt'  ||
            ext == 'log'  ||
            ext == 'csv'  ||
            ext == 'json' ||
            ext == 'xml'  ||
            ext == 'html' ||
            ext == 'htm'  ||
            ext == 'md'
        );
    }


    /*
     * ============================================================
     * BUILD FILE NAME
     * ============================================================
     */
    private static String buildFileName(
        String title,
        String extension
    ) {

        if (String.isBlank(title)) {
            return null;
        }


        if (String.isBlank(extension)) {
            return title;
        }


        String suffix =
            '.' + extension.toLowerCase();


        if (
            title.toLowerCase().endsWith(suffix)
        ) {

            return title;
        }


        return title + '.' + extension;
    }
}