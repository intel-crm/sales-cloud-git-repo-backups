@isTest
global class Core_SA_ServiceWrapper_MockResponse implements HttpCalloutMock{
/*********************************************************************************************************************
Apex Class Name  : ore_SA_ServiceWrapper_MockResponse 
Version          : 1.0
Created Date     : March 2020
Function         : Mock response class for Core_SA_ServiceWrapper

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Harshad Panchal           03/17/2020             	Mock response class
*********************************************************************************************************************/
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
       
        if(request.getEndpoint().contains('topassists'))
        {  
        	res.setBody('{"total_count":3,"show":true,"AssistDetails":[{"title":"Assists Type 1","assist_id":"123","L1Key":"Contact","L1Val":"moti_akler@amat.com","L2Key":"Visit Date","L2Val":"30 Dec 2019","L3Key":"Product","L3Val":"Intel Xeon Bronze 3104 Processor","cim_id":"10102555","user_id":"1000"},{"title":"Assists Type 2","assist_id":"456","L1Key":"Url","L1Val":"https://www.google.com.</>Link to Google","L2Key":"Date","L2Val":"20 Aug 2019","L3Key":"Product","L3Val":"AMD ryzen 1400","cim_id":"10102555","user_id":"1000"},{"title":"Assists Type 3","assist_id":"789","L1Key":"Purchased Units","L1Val":"1133","L2Key":"Last Purchase Date","L2Val":"22 Sep 2019","L3Key":"Product","L3Val":"Intel SSD 545s Series,","cim_id":"10102555","user_id":"1000"}]}');
        }
        else if(request.getEndpoint().contains('unreadassists'))
        {
        	res.setbody('{"content":"You Have 31 Unread Assists!", "show":true}');
        }
        res.setStatusCode(200);
        return res;
	}
}