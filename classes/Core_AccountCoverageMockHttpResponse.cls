@isTest public class Core_AccountCoverageMockHttpResponse implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response for fail condition
        HttpResponse res = new HttpResponse();
        res.setStatusCode(300);
        res.setStatus('failed');
      //   res.setStatusCode(200);
      //  res.setStatus('ok');
        return res;
    }
}