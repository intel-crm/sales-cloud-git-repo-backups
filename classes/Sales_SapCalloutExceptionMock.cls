@TestVisible global class Sales_SapCalloutExceptionMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unable to tunnel through proxy. Proxy returns /"HTTP/1.1 503 Service Unavailable/"');
        throw e;
    }
}