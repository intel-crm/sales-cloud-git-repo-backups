@isTest
global class Core_SalesSupportHomeControllerSeedsMock implements HTTPCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        
        System.assertEquals('GET', request.getMethod());
        
           String jsonStr = ' ['+
   '{'+
'"AccountID": "0012D00000aYiFUQA0",'+
'"OpportunityID": "006Df00000JboAYIAZ",'+
'"OrderNumber": 149988,'+
'"OrderStatus": "Pending",'+
'"RequestedDeliveryDate": "2023-07-30T18:30:00",'+
'"ReturnPickupDate": "2023-07-30T18:30:00",'+
'"Requestor": "HMOHDYUX",'+
'"Submitter": "HMOHDYUX",'+
'"ProductCode": "100000000000009356",'+
'"LineItemStatus": null,'+
'"ProductName": "Intel® Core™ i3-7350K Processor Kaby Lake SR35B [MM#954810]",'+
'"EstimatedShipDate": null,'+
'"ActualShipDate": null,'+
'"RequestedQty": 3,'+
'"ShippedQty": 0,'+
'"ProductDesc": "<br>",'+
'"ProductListDesc": "<p>Intel&#174; Core&#8482; i3-7350K Processor Kaby Lake (4M Cache, 4.20 GHz) SR35B [MM#954810]</p><p><span>ECCN:5A992C&nbsp;&nbsp;&nbsp;&nbsp; <span>CCATS:G077159&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span>US HTS:8542310001&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span></span><br></p>",'+
'"CompanyName": "Connoiseur Electronics Pvt. Ltd",'+
'"StreetAddress1": "12, 13th Main Road, Dupanahalli, ",'+
'"StreetAddress2": "Domlur Layout",'+
'"MailStop": "test@gmail.com",'+
'"City": "Bangalore",'+
'"State": "Karnataka",'+
'"ZipCode": "560008",'+
'"Country": "India",'+
'"AttentionName": "test Att",'+
'"AttentionNumber": "927187723",'+
'"Notes": ""'+
'},'+
'{'+
'"AccountID": "0012D00000aYiFUQA0",'+
'"OpportunityID": "006Df00000JboAYIAZ",'+
'"OrderNumber": 149987,'+
'"OrderStatus": "Pending",'+
'"RequestedDeliveryDate": "2023-07-31T18:30:00",'+
'"ReturnPickupDate": "2023-07-31T18:30:00",'+
'"Requestor": "HMOHDYUX",'+
'"Submitter": "HMOHDYUX",'+
'"ProductCode": "100000000000013224",'+
'"LineItemStatus": null,'+
'"ProductName": "Ethernet I/O Module XL710-QDA2 AXX2P40FRTIOM[MM#933743]",'+
'"EstimatedShipDate": null,'+
'"ActualShipDate": null,'+
'"RequestedQty": 2,'+
'"ShippedQty": 0,'+
'"ProductDesc": "",'+
'"ProductListDesc": "",'+
'"CompanyName": "McAfee Software (India) Pvt Ltd ",'+
'"StreetAddress1": "Embassy Golf Links Business Park, Pine Valley - 2nd Floor",'+
'"StreetAddress2": "Off Indiranagar - Koramangala Intermediate Ring Road",'+
'"MailStop": "test@email.com",'+
'"City": "Bangalore",'+
'"State": "Karnataka",'+
'"ZipCode": "560071",'+
'"Country": "India",'+
'"AttentionName": "Test Att Name",'+
'"AttentionNumber": "1876872618",'+
'"Notes": ""'+
'},'+
'{'+
'"AccountID": "0012D00000aYiFUQA0",'+
'"OpportunityID": "006Df00000JboAYIAZ",'+
'"OrderNumber": 149985,'+
'"OrderStatus": "Pending",'+
'"RequestedDeliveryDate": "2023-07-12T18:30:00",'+
'"ReturnPickupDate": "2023-07-25T18:30:00",'+
'"Requestor": "HMOHDYUX",'+
'"Submitter": "HMOHDYUX",'+
'"ProductCode": "100000000000013230",'+
'"LineItemStatus": null,'+
'"ProductName": "Cable Kit OCuLink* 2U 8 Port Switch #1[MM# 958268]",'+
'"EstimatedShipDate": null,'+
'"ActualShipDate": null,'+
'"RequestedQty": 1,'+
'"ShippedQty": 0,'+
'"ProductDesc": "<br>",'+
'"ProductListDesc": "<span>Tri-mode PCIe/SAS/SATA Storage Controller Adapter, 16 internal ports, Includes&nbsp;<span><span>(1) Intel&#174; RAID Adapter, (1) low-profile mounting bracket, Supports <span>Microsoft Windows, VMWare, Linux (SLES, RHEL), Solaris, FreeBSD.</span></span></span></span><br>",'+
'"CompanyName": "INTEL TECHNOLOGY INDIA PVT LTD ",'+
'"StreetAddress1": "136 OLD AIRPORT ROAD ",'+
'"StreetAddress2": "OPP TO LEELA PALACE",'+
'"MailStop": "test@inte.com",'+
'"City": "BANGALORE",'+
'"State": "KARNATAKA",'+
'"ZipCode": "560017",'+
'"Country": "India",'+
'"AttentionName": "test",'+
'"AttentionNumber": "1234",'+
'"Notes": ""'+
'}'+
  ']';
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(jsonStr);
        response.setStatusCode(200);
        response.setStatus('SUCCESS');
        return response;
             
         
    }

}