/**
 * description:- 
 * params:-
 * return:- 
 * Author and Data: ankit1x.sharma@intel.com  27/10/2021
 */

@RestResource(urlMapping = '/BusinessOrganization/*')
global without sharing class UCD_ACM_BusinessOrganization {
    
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance(); 

    public static Long dt1Long = DateTime.now().getTime();
    
    @HttpPost
    global static UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse selectBusinessOrganization() {
        //Long dt1Long = DateTime.now().getTime();
        String Url = RestContext.request.requestURI.subString(RestContext.request.requestURI.lastIndexOf('/')+1);
        UCD_ACM_BusinessOrganizationModel requestModel = UCD_ACM_BusinessOrganizationModel.parseRequestBody(RestContext.request.requestBody.toString());
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response = businessOrganization(requestModel);
            
        return response;
    }

    public static UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse businessOrganization(UCD_ACM_BusinessOrganizationModel requestModel){
        //validateRequest(requestModel);
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response = mappingInController(requestModel);
        Long dt2Long = DateTime.now().getTime();
        Decimal milliseconds2 = Decimal.valueOf(dt2Long - dt1Long);
        response.ExecutionTime = milliseconds2;
        return response;
    }    

    /*private static void validateRequest(UCD_ACM_BusinessOrganizationModel requestModel){
        // transactonId is required
        // All Account is start with 001
        //Any logic for business logic
        // In Attributes Name have some value

    }*/

    private static UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse mappingInController(UCD_ACM_BusinessOrganizationModel requestModel){
        Boolean checkAttribute = true;
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response = new UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse();
       // for(UCD_ACM_BusinessOrganizationModel.AttributesData attribute : requestModel.Attributes){
           // if( attribute.AttributeName == 'AccountInformation' ){
                checkAttribute = false;
             //response = forAccountInformation( requestModel);
             response = accountServiceInstance.getBusinessOrganization(requestModel);
           // }
        //}
        //if(checkAttribute){
             //response =  forErrorResponse(requestModel);
        //}
        return response;
    }

     /*private static UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse forErrorResponse(UCD_ACM_BusinessOrganizationModel requestModel){
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response = new UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse();
        response.Status = '401';
        response.ExecutionTime = '25ms';
        response.InternalTxnID = NULL;
        response.Data = NULL;
        return response;
    }*/


}