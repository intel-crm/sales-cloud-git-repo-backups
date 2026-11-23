@isTest
global class Core_IPS_BES_IDSID_ApigeeWrapperMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(request.getEndpoint().toLowerCase().contains('token')){
            response.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NQ", "token_type": "Bearer","expires_in": "3599", "ext_expires_in": "3599"}');
        } else if (request.getEndpoint().toLowerCase().contains('/user-details/')){
            response.setBody('{ "expand": "manager,personal,groups", "data": [{"sys_user.wwid": "11111111","sys_user.site": "BA","sys_user.email": "fnamex.lname@intel.com", "sys_user.orgunit_description": "CF CSS CUSTOMER SELLER SOLN","sys_user.group": "CorpIT Grp","sys_user.name": "LName, FNameX","sys_user.phone": null,"sys_user.badge_type": "GB","sys_user.campus": "SRR"}]}');
        }
        response.setStatusCode(200);        
        return response;
    }


}