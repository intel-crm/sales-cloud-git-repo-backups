@isTest
global class EventLogCoreExcptnBatchClassMock implements HttpCalloutMock {
    list<string> exceptionmsg = new list<string>();
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Success');
        res.setStatusCode(200);
        String[] data = res.getBody().split('\\n');
        for(integer i = 1;i<data.size();i++){
            exceptionmsg.add(data[i].split(',')[4].replace('"','') +'-' + data[i].split(',')[5] + '\n' + data[i].split(',')[6].replace('"',''));                     
            string str = data[i].split(',')[5];
            System.debug(str);
            integer location = str.IndexOf(':');
            Integer sIndexValue = str.indexOf(': ');
            String classname = str.substringAfter(': ');
        }
        return res;
    }    
}