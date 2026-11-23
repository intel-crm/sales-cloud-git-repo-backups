/********* 
* Author: Harshal Gosavi
* Date: 20/09/2021
* UCD_IQROrgRequestController 
* IQR Team send request and called this class
*********/

public without sharing class UCD_BizOrgRequestController {
    public static List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> createBusinessOrganizationRequest(UCD_BizOrgRequestModel requestModel){  
        List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> invalidRequests = new List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>();
        List<UCD_BizOrgRequestModel.AccountDetail> validAccountRequests = new List<UCD_BizOrgRequestModel.AccountDetail>();
        if(requestModel!=null){

            for(UCD_BizOrgRequestModel.AccountDetail accountDetail : requestModel.AccountRequests){

                if( accountDetail.AccountRequestReferences == null){
                    UCD_BizOrgRequestModel.AccountRequestReference requestReference = new UCD_BizOrgRequestModel.AccountRequestReference();
                    requestReference.Name = 'IQR';
                    requestReference.Value = '';
                    List<UCD_BizOrgRequestModel.AccountRequestReference> requestReferences = new List<UCD_BizOrgRequestModel.AccountRequestReference>();
                    requestReferences.add(requestReference);

                    accountDetail.AccountRequestReferences = requestReferences;
                }
                
            }
            
            
            
            // check duplicate requests
            TagDuplicateAccountRequest(requestModel);
            //validate request
            validateRequest(requestModel,validAccountRequests, invalidRequests);
            // service layer call
            List <UCD_BizOrgRequestModel.BusinessOrganizationResponse> serviceResponse = createAccountAndResponse(validAccountRequests);
            //return response
            serviceResponse.addAll(invalidRequests);
            return serviceResponse;
        }
        return null;
    }
    /**
    * description:- Validate request (Diffrentiate Valid Account and Invalid Account)
    * params:-UCD_BizOrgRequestModel,  List<UCD_BizOrgRequestModel.AccountDetail>, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static void validateRequest(UCD_BizOrgRequestModel requestModel,
                                        List<UCD_BizOrgRequestModel.AccountDetail> validAccountRequests,
                                        List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> invalidRequests) {
        for (Integer i = 0; i < requestModel.AccountRequests.size(); i++) {
            List<String> errors = new List<String>();
            // checks for mandatory fields
            if (String.isBlank(requestModel.AccountRequests[i].Name) ||
                String.isBlank(requestModel.AccountRequests[i].CustomerAggregationTypeCode) ||
                String.isBlank(requestModel.AccountRequests[i].CustomerProcessEngagmentCode)) {
                errors.add('Name, CustomerAggregationTypeCode and CustomerProcessEngagmentCode are mandatory fields');
            }
            //validate address
            errors.addAll(validateAccountRequestAddresses(requestModel.AccountRequests[i].Addresses != null?requestModel.AccountRequests[i].Addresses:null));
            // Categorize valid and invalid requests
            if (errors.size() > 0 || (requestModel.AccountRequests[i].IsDuplicate != null && requestModel.AccountRequests[i].IsDuplicate == true )){ 
                String msg = (requestModel.AccountRequests[i].IsDuplicate != null && requestModel.AccountRequests[i].IsDuplicate == true )?'Duplicate Account Request': errors.toString().contains('(')? errors.toString().substring(1, errors.toString().length() - 1) : errors.toString();
                invalidRequests.add( createErrorResponse(null,requestModel.AccountRequests[i], msg) );
            } else {
                validAccountRequests.add(requestModel.AccountRequests[i]);
            }
        }
    }
   /**
    * description:- Validate Account Address
    * params:-UCD_BizOrgRequestModel,  List<UCD_BizOrgRequestModel.AccountDetail>, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static List<String> validateAccountRequestAddresses(List<UCD_BizOrgRequestModel.AccountAddresses> addresses) {
        List<String> addressErrors = new List<String>();
        if(addresses != null){
            for (UCD_BizOrgRequestModel.AccountAddresses address : addresses) {
                if (String.isBlank(address.CountryCode) && String.isBlank(address.CountryName) ) {
                    addressErrors.add('CountryCode/CountryName is required');
                } else if (String.isNotBlank(address.CountryCode) && address.CountryCode.length() != 3) {
                    addressErrors.add('CountryCode length is not valid. Expected 3-character CountryCode');
                }
            }
        }else{
            addressErrors.add('Addresses is required');
        }
        return addressErrors;
    }

    /**
    * description:- Check Duplicate Account
    * params:-UCD_BizOrgRequestModel,  List<UCD_BizOrgRequestModel.AccountDetail>, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static void TagDuplicateAccountRequest(UCD_BizOrgRequestModel requestModel) {
        List<String> acctRequestsFilter = new List<String>();
        for (Integer index = 0; index < requestModel.AccountRequests.size(); index++) {
            //check for null
            if(requestModel.AccountRequests[index].Addresses != null){
                for (UCD_BizOrgRequestModel.AccountAddresses addressRef : requestModel.AccountRequests[index].Addresses) {
                    if (addressRef.TypeCode == 'Billing') {
                        String countryName = String.isNotBlank(addressRef.CountryName)?addressRef.CountryName: String.isNotBlank(addressRef.CountryCode) ?   UCD_ACM_Utils.validateCountryCode(addressRef.CountryCode) : '';
                        String nameAndCountry = (requestModel.AccountRequests[index].Name + '@' + countryName + '@' + requestModel.AccountRequests[index].CustomerAggregationTypeCode).toLowerCase();
                        //checking duplicate
                        if (acctRequestsFilter.contains(nameAndCountry)) {
                            requestModel.AccountRequests[index].IsDuplicate = true;
                        } else {
                            acctRequestsFilter.add(nameAndCountry);
                            requestModel.AccountRequests[index].IsDuplicate = false;
                        }
                    }
                }
            }
        }
    }

   /**
    * description:- Create Account, Create Success Response, Create Error Response
    * params:-UCD_BizOrgRequestModel,  List<UCD_BizOrgRequestModel.AccountDetail>, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static List < UCD_BizOrgRequestModel.BusinessOrganizationResponse> createAccountAndResponse(List <UCD_BizOrgRequestModel.AccountDetail> validAccountListData) {
        UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
        List < UCD_BizOrgRequestModel.BusinessOrganizationResponse> controllerResponse = new  List < UCD_BizOrgRequestModel.BusinessOrganizationResponse >();
        List < UCD_ACM_Models.BusinessOrganizationResponseforService > responseFromService = new List < UCD_ACM_Models.BusinessOrganizationResponseforService >();
        UCD_BizOrgRequestModel.BusinessOrganizationResponse responseObj;
        // Mapping model and sending data in Service
        if (validAccountListData.size() > 0) {
            List < UCD_ACM_Models.AccountModel > accountModel = mappingControllerModelToSericeModel(validAccountListData);
            responseFromService = accountServiceInstance.createBusinessOrganizationRequest(accountModel);
        }
        // Create Success and Error Response for responseFromService
        for (UCD_ACM_Models.BusinessOrganizationResponseforService controllerValidResponse : responseFromService) {
            responseObj = (String.isBlank(controllerValidResponse.ErrorMessage))? createSuccessResponse(controllerValidResponse): createErrorResponse(controllerValidResponse, null, '');
            controllerResponse.add(responseObj);
        }
        return controllerResponse;
    }


    /**
     * description:- Mapping fields from Controller model to Service model
     * params:- List < UCD_BizOrgRequestModel.AccountDetail >
     * return:-  List< UCD_ACM_Models.AccountModel>
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */
    private static List< UCD_ACM_Models.AccountModel> mappingControllerModelToSericeModel(List < UCD_BizOrgRequestModel.AccountDetail > requestModel) {
        UCD_ACM_Models.AccountModelForService accountModelForService = new UCD_ACM_Models.AccountModelForService();
        List <UCD_ACM_Models.AccountModel> lstaccountModel = new  List <UCD_ACM_Models.AccountModel>();
        for (UCD_BizOrgRequestModel.AccountDetail requestModelRecord : requestModel) {
            UCD_ACM_Models.AccountModel accountModel = new UCD_ACM_Models.AccountModel();
            accountModel.Name = requestModelRecord.Name;
            accountModel.CustomerAggregationTypeCode = requestModelRecord.CustomerAggregationTypeCode;
            accountModel.CustomerProcessEngagmentCode = requestModelRecord.CustomerProcessEngagmentCode;
            accountModel.RequesterName = requestModelRecord.RequesterName;
            accountModel.RequesterWWID = requestModelRecord.RequesterWWID;
            accountModel.RequesterEmail = requestModelRecord.RequesterEmail;
            accountModel.CustomerURL =  requestModelRecord.CustomerURL;
            accountModel.ParentBusinessPartyIdentifierReference = requestModelRecord.ParentBusinessPartyIdentifierReference;
            List< UCD_ACM_Models.AccountAddress > lstofnewModeladdr = new List< UCD_ACM_Models.AccountAddress >();
            for (UCD_BizOrgRequestModel.AccountAddresses addressRef : requestModelRecord.Addresses) {
                UCD_ACM_Models.AccountAddress newModelAddressRef = new UCD_ACM_Models.AccountAddress();
                newModelAddressRef.TypeCode  =  addressRef.TypeCode;
                newModelAddressRef.CountryCode = addressRef.CountryCode;
                newModelAddressRef.CountryName = addressRef.CountryName;
                lstofnewModeladdr.add(newModelAddressRef);
            }
            accountModel.Addresses = lstofnewModeladdr;

                Map < String , String > mapOfAccReqRef = new Map < String , String >();                
        if(requestModelRecord.AccountRequestReferences != null){
            if(requestModelRecord.AccountRequestReferences.size() > 0){
                for (UCD_BizOrgRequestModel.AccountRequestReference accountRef : requestModelRecord.AccountRequestReferences) {
                        //mapOfAccReqRef.put(accountRef.Name, accountRef.Value);     
                        mapOfAccReqRef.put('IQR', accountRef.Value);            
                    }
                accountModel.AccountRequestReferences = mapOfAccReqRef;
            }else{
                mapOfAccReqRef.put('IQR', '');	
                accountModel.AccountRequestReferences = mapOfAccReqRef;
            }

        }else if(  requestModelRecord.AccountRequestReferences == null){
            mapOfAccReqRef.put('IQR', '');	
            accountModel.AccountRequestReferences = mapOfAccReqRef;
            }

            lstaccountModel.add(accountModel);
        }
        return lstaccountModel;
    }

    /**
     * description:- Create Error Response
     * params:- UCD_ACM_Models.BusinessOrganizationResponseforService, UCD_BizOrgRequestModel.AccountDetail, String errorMessage
     * return:- UCD_BizOrgRequestModel.BusinessOrganizationResponse
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */
    private static UCD_BizOrgRequestModel.BusinessOrganizationResponse createErrorResponse(UCD_ACM_Models.BusinessOrganizationResponseforService responseAfterInsertacc, UCD_BizOrgRequestModel.AccountDetail accountInController, String errorMessage ) {
        UCD_BizOrgRequestModel.BusinessOrganizationResponse responseObj = new UCD_BizOrgRequestModel.BusinessOrganizationResponse();
        UCD_BizOrgRequestModel.Data responseData = new UCD_BizOrgRequestModel.Data();
        responseData.AccountId = null;
        responseData.AccountStatus = '';
        responseObj.Status = 'Error';
        responseObj.Code = '400';
        if (responseAfterInsertacc != null) {
            responseData.CountryName = responseAfterInsertacc.CountryName;
            responseData.Name = responseAfterInsertacc.AccountData.Name;
            responseData.DuplicateAccountId = responseAfterInsertacc.DuplicateAccountInfo != null ? responseAfterInsertacc.DuplicateAccountInfo.AccountId : '';
            responseData.DuplicateAccountRecordType = responseAfterInsertacc.DuplicateAccountInfo != null ? responseAfterInsertacc.DuplicateAccountInfo.RecordType : '';
            responseData.DuplicateAccountInfo = responseAfterInsertacc.DuplicateAccountInfo ;
            responseObj.Errormessage = responseAfterInsertacc.ErrorMessage;
        } else if (accountInController != null) {
            responseData.CountryName = '';
            if(accountInController.Addresses != null){
                for (UCD_BizOrgRequestModel.AccountAddresses addressRef : accountInController.Addresses) {
                    if (addressRef.TypeCode == 'Billing') {
                        responseData.CountryName = addressRef.CountryName;
                    }
                }
            }
            responseData.Name = accountInController.Name;
            responseObj.Errormessage = errorMessage;
        } else {
            responseObj.Errormessage = errorMessage;
        }
        responseObj.Data = responseData;
        return responseObj;
    }

    /**
     * description:- Create Success Response
     * params:- UCD_ACM_Models.BusinessOrganizationResponseforService
     * return:- UCD_BizOrgRequestModel.BusinessOrganizationResponse
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */
    private static UCD_BizOrgRequestModel.BusinessOrganizationResponse createSuccessResponse( UCD_ACM_Models.BusinessOrganizationResponseforService responseAfterInsertacc ) {
        UCD_BizOrgRequestModel.BusinessOrganizationResponse responseObj = new UCD_BizOrgRequestModel.BusinessOrganizationResponse();
        UCD_BizOrgRequestModel.Data responseData = new UCD_BizOrgRequestModel.Data();
        responseData.AccountId = responseAfterInsertacc.AccountId;
        responseData.CountryName = responseAfterInsertacc.CountryName;
        responseData.Name = responseAfterInsertacc.AccountData.Name;
        responseData.AccountStatus = responseAfterInsertacc.accountstatus;
        responseObj.errormessage = null;
        responseObj.status = 'Success';
        responseObj.code = '200';
        responseObj.data = responseData;
        return responseObj;
    }
}