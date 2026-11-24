public with sharing class CsvHeaderReader {

    @InvocableMethod(label='Read CSV Headers')
    public static List<Response> readHeaders(
        List<Request> requests
    ) {
        List<Response> results = new List<Response>();

        for(Request req : requests){

            ContentVersion cv = [
                SELECT VersionData
                FROM ContentVersion
                WHERE Id = :req.contentVersionId
                LIMIT 1
            ];

            String csvText =
                cv.VersionData.toString();

            String firstLine =
                csvText.split('\n')[0];

            List<String> headers =
                firstLine.split(',');

            Response r = new Response();
            r.headersJson =
                JSON.serialize(headers);

            results.add(r);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String contentVersionId;
    }

    public class Response {
        @InvocableVariable
        public String headersJson;
    }
}