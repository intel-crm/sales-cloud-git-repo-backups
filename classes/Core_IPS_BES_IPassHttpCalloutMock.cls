/*********************************************
* Name : Core_IPS_BES_IPassHttpCalloutMock 
* Author : Sai Krishna 
* Date Created : 14/10/2021
* Description : Mock callout class for Core_IPS_BES_IPassDataSync.
*   
************************************************/
@isTest
global class Core_IPS_BES_IPassHttpCalloutMock implements HttpCalloutMock{
     global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
		if(request.getEndpoint() == System.Label.Core_IPS_BES_Post_URL){
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Data sent to Ipass');
            response.setStatusCode(200);
        }/*Apex SFDX deployment test 15&17122025*/
        else if(request.getEndpoint() == System.Label.Core_IPS_BES_Post1_URL){
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Data not sent to Ipass');
            response.setStatusCode(400);
        }
         else if(request.getEndpoint() == 'callout:Core_IPS_Backend_System_Integration_DynamicSync'){
         //else if (request.getEndpoint().contains(System.Label.Core_IPS_BES_UserDetailsURL)){
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "expand": "manager,personal,groups", "data": [{"sys_user.wwid": "11111111","sys_user.site": "BA","sys_user.email": "fnamex.lname@intel.com", "sys_user.orgunit_description": "CF CSS CUSTOMER SELLER SOLN","sys_user.group": "CorpIT Grp","sys_user.name": "LName, FNameX","sys_user.phone": null,"sys_user.badge_type": "GB","sys_user.campus": "SRR"}]}');
            response.setStatusCode(200);
        }
        
        return response;
    }
}