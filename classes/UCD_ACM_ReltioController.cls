/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_ReltioController
Author And Date  : Chethan Kunder, 23 May 2024
Function         : This class has code for processing Reltio API Requests
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Chethan Kunder            23/05/2024              Created
* Rajveer Ranavat           20/06/2024              Updated code for Reltio updates
*********************************************************************************************************************/
public without sharing class UCD_ACM_ReltioController {
    private static UCD_ACM_ServiceContracts.IMDMService reltioServiceInstance = UCD_ACM_ReltioService.getInstance();

    @InvocableMethod(label='Trigger Update to Reltio' description='Sends the desired attribute update to Reltio via API' category='Account')
    public static List<UCD_ACM_ReltioModels.UpdateResponseModel> triggerUpdateToReltio(List<UCD_ACM_ReltioModels.UpdateRequestModel> lstRequests){
        List<UCD_ACM_ReltioModels.UpdateResponseModel> response = new List<UCD_ACM_ReltioModels.UpdateResponseModel>();
        response = entityUpdate(lstRequests);
        return response;
    }

    /**********Reltio Entity Update****************/
    private static  List<UCD_ACM_ReltioModels.UpdateResponseModel> entityUpdate(List<UCD_ACM_ReltioModels.UpdateRequestModel> lstRequests) {
        List<UCD_ACM_ReltioModels.UpdateResponseModel> listResponse = new List<UCD_ACM_ReltioModels.UpdateResponseModel>();
        if(!lstRequests.isEmpty()) {      
            Map<String, UCD_ACM_ReltioModels.UpdateRequest> mPayloads = new Map<String, UCD_ACM_ReltioModels.UpdateRequest>();
            mPayloads = createPayload(lstRequests);
            if(!mPayloads.isEmpty()) {
                listResponse = reltioServiceInstance.updateEntity(mPayloads);
            }
            
        }
        return listResponse;
    }

    private static Map<String, UCD_ACM_ReltioModels.UpdateRequest> createPayload(List<UCD_ACM_ReltioModels.UpdateRequestModel> lstRequests) {        
        Map<String, UCD_ACM_ReltioModels.UpdateRequest> payloadByBPId = new Map<String, UCD_ACM_ReltioModels.UpdateRequest>();
        for(UCD_ACM_ReltioModels.UpdateRequestModel request:lstRequests) {
            if(request.moduleName == 'OPID_UPDATE'){
            UCD_ACM_ReltioModels.UpdateRequest updateRequest = new UCD_ACM_ReltioModels.UpdateRequest(request.accountId, new UCD_ACM_ReltioModels.OPId(request.onePartnerId), new UCD_ACM_ReltioModels.OPIdActive(request.oPIdActive));
            payloadByBPId.put(String.format('{0}:{1}', new List<String>{request.bpId, request.accountId}), updateRequest);
            }
            else if(request.moduleName == 'COVERAGE_UPDATE'){
                UCD_ACM_ReltioModels.UpdateRequest updateRequest = new UCD_ACM_ReltioModels.updateRequest(request.accountId, new UCD_ACM_ReltioModels.SalesCoverage(request.acctPriCoverage));
                payloadByBPId.put(String.format('{0}:{1}', new List<String>{request.bpId, request.accountId}), updateRequest); 
            }
         }
       
        return payloadByBPId;
    }
}