/**************************************************************************************************************
Apex Class Name:  PRM_RetriggerEV_API
Version     : 1.0 
Created Date: 04 March 2020
Function    : Custom REST service for retriggering email verification
Modification Log :
* Developer             		Date              Description
* ----------------------------------------------------------------------------                 
* Pratik Sanganeria         03/04/2020        	Initial version
***************************************************************************************************************/
@RestResource(urlMapping='/RegistrationRequest/RetriggerEV')
global class PRM_RetriggerEV_API {
    @HttpPost
    global static void doPost(String LoginID,String BizOrgType)
    {
        RestResponse res = RestContext.response;
        Id emailLogID;
        try{
            Date endDate = Date.today().addDays(Integer.valueOf(System.label.PRM_RetriggerEV_NumberOfDays));
            PRM_Retrigger_EV_Utility.retrigger_EV(endDate,LoginID,BizOrgType,false,null);    
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Email has been triggered');                            
        }catch(Exception e){
            System.debug('ERROR 500!!!!');
            res.statusCode = 500;
            SalesforceError[] errs = new SalesforceError[]{ 
                new SalesforceError('0005','Email Retrigger Failed')
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(errs));           
        }
    }
    
    
    public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    } 
}