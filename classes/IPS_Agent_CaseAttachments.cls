global with sharing class IPS_Agent_CaseAttachments {

    /*
     * ============================================================
     * REQUEST
     * ============================================================
     */
    global class Request {

        @InvocableVariable(required=true)
        global String caseNumber;
    }


    /*
     * ============================================================
     * ATTACHMENT
     * ============================================================
     *
     * Represents one attachment associated with the Case.
     */
    global class Attachment {

        @InvocableVariable global String attachmentId;

        @InvocableVariable global String fileName;

        @InvocableVariable global String fileHyperlink;

        @InvocableVariable global String description;
    }


    /*
     * ============================================================
     * RESPONSE
     * ============================================================
     */
    global class Response {

        @InvocableVariable global Boolean success;

        @InvocableVariable global String message;

        @InvocableVariable global String caseNumber;

        @InvocableVariable global Integer attachmentCount;

        @InvocableVariable global List<Attachment> attachments;
    }


    /*
     * ============================================================
     * MCP / INVOCABLE METHOD
     * ============================================================
     */
    @InvocableMethod(
        label='Get Case Attachments'
        description='Retrieves attachment information associated with a Salesforce Case'
    )
    global static List<Response> execute(
        List<Request> requests
    ) {

        List<Response> responses =
            new List<Response>();


        for (Request req : requests) {

            Response res =  new Response();

            res.attachments =  new List<Attachment>();


            try {

                /*
                 * Validate request
                 */
                if (req == null ||  String.isBlank(req.caseNumber)
                ) {
                    throw new IPS_Agent_Exception(
                        'Case number is required'
                    );
                }


                String caseNumber =  req.caseNumber.trim();


                /*
                 * Verify Case exists.
                 */
                Case c = IPS_Agent_CaseSelector.getCaseByNumber(caseNumber);


                /*
                 * Get Case Attachments.
                 */
                List<Core_IPS_Case_Attachments__c> attachmentRecords = IPS_Agent_CaseSelector.getCaseAttachments(caseNumber);
                /*
                 * Convert Salesforce attachment records
                 * into MCP response objects.
                 */
                for (
                    Core_IPS_Case_Attachments__c record :
                    attachmentRecords
                ) {

                    Attachment attachment =
                        new Attachment();


                    attachment.attachmentId =
                        String.valueOf(record.Id);

                    attachment.fileName =
                        record.Core_File_Name__c;

                    attachment.fileHyperlink =
                        record.Core_File_URL__c;

                    attachment.description =
                        record.Core_File_Description__c;


                    res.attachments.add(
                        attachment
                    );
                }


                /*
                 * Build successful response.
                 */
                res.success = true;

                res.caseNumber =
                    c.CaseNumber;

                res.attachmentCount =
                    res.attachments.size();


                if (res.attachmentCount == 0) {

                    res.message =
                        'No attachments found for Case ' +
                        c.CaseNumber;

                }
                else {

                    res.message =
                        String.valueOf(
                            res.attachmentCount
                        ) +
                        ' attachment(s) found';
                }

            }
            catch (Exception ex) {

                res.success = false;

                res.message =
                    ex.getMessage();

                res.attachmentCount = 0;
            }


            responses.add(
                res
            );
        }


        return responses;
    }
}