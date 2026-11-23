global with sharing class IPS_Agent_CaseFiles {

    /*
     * Small text files up to 2 MB can be read
     * through IPS_Agent_GetCaseFileContent.
     *
     * Large files and all binary files should
     * use DIRECT_DOWNLOAD through the MCP server.
     */
    private static final Long SMALL_FILE_LIMIT = 2097152;


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
            label='File Count'
        )
        global Integer fileCount;


        /*
         * File metadata returned as JSON.
         *
         * Example:
         *
         * [
         *   {
         *     "fileName": "debug.log",
         *     "contentVersionId": "068...",
         *     "contentDocumentId": "069...",
         *     "contentSize": 500000,
         *     "extension": "log",
         *     "retrievalMode": "APEX_TEXT"
         *   }
         * ]
         */
        @InvocableVariable(
            label='Files JSON'
            description='JSON array containing latest file metadata'
        )
        global String filesJson;


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
        label='IPS Agent Get Case Files'
        description='Returns metadata for the latest versions of Salesforce Files associated with a Case.'
        category='IPS Agent'
    )
    global static List<Response> getCaseFiles(
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
            response.fileCount = 0;
            response.filesJson = '[]';


            try {

                /*
                 * ----------------------------------------------------
                 * Validate request
                 * ----------------------------------------------------
                 */
                if (
                    request == null ||
                    String.isBlank(request.caseNumber)
                ) {

                    response.error =
                        'Case number is required';

                    responses.add(response);
                    continue;
                }


                String caseNumber =
                    request.caseNumber.trim();


                /*
                 * ----------------------------------------------------
                 * Get Case
                 * ----------------------------------------------------
                 */
                Case caseRecord =
                    IPS_Agent_CaseSelector.getCaseByNumber(
                        caseNumber
                    );


                /*
                 * ----------------------------------------------------
                 * Get Files associated with Case
                 * ----------------------------------------------------
                 *
                 * IMPORTANT:
                 *
                 * This selector should NOT retrieve VersionData.
                 */
                List<ContentDocumentLink> links =
                    IPS_Agent_CaseSelector.getCaseFiles(
                        caseRecord.Id
                    );


                /*
                 * Build simple JSON response.
                 */
                List<Map<String, Object>> files =
                    new List<Map<String, Object>>();


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


                        String extension =
                            link.ContentDocument.FileExtension;


                        Long contentSize =
                            link.ContentDocument.ContentSize;


                        /*
                         * ------------------------------------------------
                         * Determine retrieval method
                         * ------------------------------------------------
                         *
                         * APEX_TEXT:
                         *
                         * Small text file that may safely be read
                         * through IPS_Agent_GetCaseFileContent.
                         *
                         *
                         * DIRECT_DOWNLOAD:
                         *
                         * Binary or large file.
                         *
                         * The MCP/Node server should retrieve the
                         * original VersionData directly from Salesforce.
                         */
                        String retrievalMode =
                            'DIRECT_DOWNLOAD';


                        if (
                            isTextFile(extension) &&
                            contentSize != null &&
                            contentSize <= SMALL_FILE_LIMIT
                        ) {

                            retrievalMode =
                                'APEX_TEXT';
                        }


                        /*
                         * ------------------------------------------------
                         * Build file metadata
                         * ------------------------------------------------
                         */
                        Map<String, Object> file =
                            new Map<String, Object>();


                        file.put(
                            'contentDocumentId',
                            String.valueOf(
                                link.ContentDocumentId
                            )
                        );


                        file.put(
                            'contentVersionId',
                            String.valueOf(
                                link.ContentDocument
                                    .LatestPublishedVersionId
                            )
                        );


                        file.put(
                            'fileName',
                            buildFileName(
                                link.ContentDocument.Title,
                                extension
                            )
                        );


                        file.put(
                            'title',
                            link.ContentDocument.Title
                        );


                        file.put(
                            'extension',
                            extension
                        );


                        file.put(
                            'fileType',
                            link.ContentDocument.FileType
                        );


                        file.put(
                            'contentSize',
                            contentSize
                        );


                        file.put(
                            'retrievalMode',
                            retrievalMode
                        );


                        files.add(file);
                    }
                }


                /*
                 * ----------------------------------------------------
                 * Success response
                 * ----------------------------------------------------
                 */
                response.success = true;

                response.caseNumber =
                    caseRecord.CaseNumber;

                response.fileCount =
                    files.size();

                response.filesJson =
                    JSON.serialize(files);

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
     *
     * Only files that can reasonably be treated as UTF-8 text
     * should be included here.
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


        /*
         * Prevent:
         *
         * debug.log.log
         */
        if (
            title.toLowerCase().endsWith(suffix)
        ) {

            return title;
        }


        return title + '.' + extension;
    }
}