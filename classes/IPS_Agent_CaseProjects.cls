global with sharing class IPS_Agent_CaseProjects {

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
     * RESPONSE
     * ============================================================
     */
    global class Response {

        @InvocableVariable
        global Boolean success;

        @InvocableVariable
        global String message;

        @InvocableVariable
        global String caseNumber;

        @InvocableVariable
        global String projectRecordId;

        @InvocableVariable
        global String projectId;

        @InvocableVariable
        global String projectName;

        @InvocableVariable
        global String projectDescription;
    }


    /*
     * ============================================================
     * MCP / INVOCABLE METHOD
     * ============================================================
     */
    @InvocableMethod(
        label='Get Case Project'
        description='Retrieves the IPS Project associated with a Salesforce Case'
    )
    global static List<Response> execute(
        List<Request> requests
    ) {

        List<Response> responses =
            new List<Response>();


        for (Request req : requests) {

            Response res =
                new Response();

            try {

                /*
                 * Validate request.
                 */
                if (
                    req == null ||
                    String.isBlank(req.caseNumber)
                ) {

                    throw new IPS_Agent_Exception(
                        'Case number is required'
                    );
                }


                String caseNumber =
                    req.caseNumber.trim();


                /*
                 * ------------------------------------------------
                 * STEP 1
                 *
                 * Retrieve the Case.
                 * ------------------------------------------------
                 */
                Case c =
                    IPS_Agent_CaseSelector.getCaseByNumber(
                        caseNumber
                    );


                /*
                 * ------------------------------------------------
                 * STEP 2
                 *
                 * Check whether the Case has an associated Project.
                 * ------------------------------------------------
                 */
                if (
                    c.Core_IPS_Project_Case__c == null
                ) {

                    res.success = true;

                    res.message =
                        'No project is associated with Case ' +
                        c.CaseNumber;

                    res.caseNumber =
                        c.CaseNumber;

                    responses.add(res);

                    continue;
                }


                /*
                 * ------------------------------------------------
                 * STEP 3
                 *
                 * Retrieve the related Project.
                 * ------------------------------------------------
                 */
                Core_IPS_Project__c project =
                    IPS_Agent_CaseSelector.getCaseProject(
                        c.Core_IPS_Project_Case__c
                    );


                /*
                 * ------------------------------------------------
                 * STEP 4
                 *
                 * Build MCP response.
                 * ------------------------------------------------
                 */
                res.success = true;

                res.message =
                    'Project found';

                res.caseNumber =
                    c.CaseNumber;

                res.projectRecordId =
                    String.valueOf(project.Id);

                res.projectId =
                    project.Core_IPS_Project_ID__c;

                res.projectName =
                    project.Name;

                res.projectDescription =
                    project.Core_Project_Description__c;

            }
            catch (Exception ex) {

                res.success = false;

                res.message =
                    ex.getMessage();
            }


            responses.add(
                res
            );
        }


        return responses;
    }
}