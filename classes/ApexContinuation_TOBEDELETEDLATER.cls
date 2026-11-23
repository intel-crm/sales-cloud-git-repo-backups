public class ApexContinuation_TOBEDELETEDLATER {
	
    @AuraEnabled(continuation=true cacheable=true)
    public static object startConProcess(){
        Continuation con = new Continuation(4);
        con.continuationMethod = 'processContinuation';
        con.state = 'Start Continuation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('www.google.com');
        req.setMethod('GET');
        con.addHttpRequest(req);
        return con;
        
    }
    
    //callbackMethod
    @AuraEnabled(cacheable=true)
    public static Object processContinuation(List<String> labels, object state){
        HttpResponse res = Continuation.getResponse(labels[0]);
        String result = res.getBody();
        return result;
        
        
    }
}