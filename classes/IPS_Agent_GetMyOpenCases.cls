global with sharing class IPS_Agent_GetMyOpenCases {

    global class Request {

        @InvocableVariable(required=true)
        global String userEmail;

    }

    global class Response {

        @InvocableVariable global Boolean success;
        @InvocableVariable global String message;

        @InvocableVariable global String caseNumber;

        @InvocableVariable global String userEmail;
        @InvocableVariable global String userId;

        @InvocableVariable global Integer caseCount;

        @InvocableVariable global String subject;
        @InvocableVariable global String status;
        @InvocableVariable global String priority;
        @InvocableVariable global String description;

        @InvocableVariable global String productName;
        @InvocableVariable global String resolution;

        @InvocableVariable global Datetime createdDate;
        @InvocableVariable global Datetime closedDate;

        @InvocableVariable global String comments;
        @InvocableVariable global String issueDescription;
        @InvocableVariable global String closureComment;

        @InvocableVariable global String ownerName;
        @InvocableVariable global String ownerEmail;

        @InvocableVariable global String internalNote;
        @InvocableVariable global String problemStatement;
        @InvocableVariable global String knowledgeBaseLink;
        @InvocableVariable global String projectCase;
    }

    @InvocableMethod
    global static List<Response> execute(
        List<Request> requests
    ) {

        List<Response> results =
            new List<Response>();

        try {

            if (
                requests == null ||
                requests.isEmpty()
            ) {

                Response errorRes =
                    new Response();

                errorRes.success =
                    false;

                errorRes.message =
                    'No requests received';

                results.add(
                    errorRes
                );

                return results;
            }

            Integer caseCount = 0;

            for (
                Request req : requests
            ) {

                String userEmail =
                    req.userEmail;

                if (
                    String.isBlank(
                        userEmail
                    )
                ) {

                    Response errorRes =
                        new Response();

                    errorRes.success =
                        false;

                    errorRes.message =
                        'userEmail is required';

                    results.add(
                        errorRes
                    );

                    continue;
                }

                List<Case> openCases = IPS_Agent_CaseSelector.getMyOpenCases(userEmail);

                if (
                    openCases == null
                ) {

                    Response errorRes =
                        new Response();

                    errorRes.success =
                        false;

                    errorRes.message =
                        'No cases returned for userEmail=' +
                        userEmail;

                    results.add(
                        errorRes
                    );

                    continue;
                }

                for (
                    Case c : openCases
                ) {

                    caseCount++;

                    Response res =
                        new Response();

                    res.success = true;
                    res.message = 'Success';

                    res.userId =
                        UserInfo.getUserId();

                    res.userEmail =
                        userEmail;

                    res.caseCount =
                        caseCount;

                    res.caseNumber =
                        c.CaseNumber;

                    res.subject =
                        c.Subject;

                    res.status =
                        c.Status;

                    res.priority =
                        c.Priority;

                    res.description =
                        c.Description;

                    res.productName =
                        c.Core_IPS_Product_name__c;

                    res.resolution =
                        c.Core_IPS_Resolution__c;

                    res.createdDate =
                        c.CreatedDate;

                    res.closedDate =
                        c.ClosedDate;

                    res.issueDescription =
                        c.Core_Issue_Description__c;

                    res.comments =
                        c.Comments;

                    res.closureComment =
                        c.Core_Closure_Comment__c;

                    res.ownerName =
                        c.Core_IPS_Case_Owner_Name__c;

                    res.ownerEmail =
                        c.Core_IPS_Case_Owner_Email__c;

                    res.internalNote =
                        c.Core_IPS_Internal_Note__c;

                    res.problemStatement =
                        c.Core_IPS_Problem_Statement__c;

                    res.knowledgeBaseLink =
                        c.Core_IPS_Knowledge_Base_Link__c;

                    res.projectCase =
                        c.Core_IPS_Project_Case__c;

                    results.add(
                        res
                    );
                }
            }

        } catch (
            Exception ex
        ) {

            Response errorRes =
                new Response();

            errorRes.success =
                false;

            errorRes.message =
                ex.getMessage();

            results.add(
                errorRes
            );
        }

        return results;
    }
}