@isTest
                        
global class Core_MockSeedsHttpResponse implements HttpCalloutMock  {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"AccountID":"6009855543","OpportunityID":"0000092555","OrderNumber":105624,"OrderStatus":"Overdue","RequestedDeliveryDate":"2014-07-02T00:00:00","ReturnPickupDate":"2014-08-01T00:00:00","Requestor":"POSSOLA","Submitter":"POSSOLA","ProductCode":"100000000000002768","LineItemStatus":"COMPLETED","ProductName":"SC5110P Xeon Phi with Intel® R2208GZ4GC Grizzly Pass","EstimatedShipDate":"2014-06-28T00:00:00","ActualShipDate":"2014-06-26T06:38:42.64","RequestedQty":1,"ShippedQty":1,"ProductDesc":"This Xeon Phi coprocessor card comes pre-installed in a Intel&nbsp;R2208GZ4GC Grizzly Pass server. This server has 2x Intel E5 - 2690 processors, 32GB RAM and a 1 TB SATA drive. This server has Red Hat and MPSS software loaded.<br />\n<br />\n<a href=\"http://ark.intel.com/products/56262/Intel-Server-System-R2208GZ4GC\" target=\"_blank\">http://ark.intel.com/products/56262/Intel-Server-System-R2208GZ4GC</a><br />\n<br />\n<a href=\"http://software.intel.com/en-us/mic-developer\" target=\"_blank\">http://software.intel.com/en-us/mic-developer</a><br />","ProductListDesc":"This Xeon Phi coprocessor card comes pre-installed in a Intel&nbsp;R2208GZ4GC Grizzly Pass server. This server has 2x Intel E5 - 2690 processors, 32GB RAM and a 1 TB SATA drive.&nbsp;This server has Red Hat and MPSS software loaded.","CompanyName":"Unicredit ","StreetAddress1":"Piazza Gae Aulenti 3  ","StreetAddress2":"Tower A","MailStop":"riccardo.prodam@unicredit.eu","City":"Milano","State":"MI","ZipCode":"20154","Country":"Italy","AttentionName":"Riccardo Prodam","AttentionNumber":"00393385968694","Notes":""}]');
        res.setStatusCode(200);
        
        System.debug(res);
        
        return res;
    }
}