global with sharing class IPS_Agent_SendEmail {

    global class Request {

        @InvocableVariable(required=true)
        global String toAddress;

        @InvocableVariable(required=true)
        global String subject;

        @InvocableVariable(required=true)
        global String body;
    }

    global class Response {
        @InvocableVariable global Boolean success;
        @InvocableVariable global String message;
    }

    @InvocableMethod
    global static List<Response> execute(List<Request> requests) {

        List<Response> results = new List<Response>();

        for(Request req : requests){

            Response res = new Response();

            try {

                IPS_Agent_EmailService.sendEmail(
                    req.toAddress,
                    req.subject,
                    req.body
                );

                res.success = true;
                res.message = 'Email sent';

            } catch(Exception ex){

                res.success = false;
                res.message = ex.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}