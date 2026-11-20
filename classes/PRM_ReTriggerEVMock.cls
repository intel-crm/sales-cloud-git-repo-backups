/*********************************************************************************************************************
Apex Class Name  : PRM_ReTriggerEVMock 
Version          : 1.0
Created Date     : AUG 2019
Function         : Mock response class for 'EV ReTrigger Functionality'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Rahul Kainth              20 Aug,2019             Mock response class for 'EV ReTrigger Functionality'

*********************************************************************************************************************/
@isTest
public class PRM_ReTriggerEVMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
        res.setbody('Email has been sent successfully to the user');
        res.setStatuscode(200);    
        return res;
        
    }
}