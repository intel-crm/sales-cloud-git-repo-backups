/**
 * description:- UCD_BizOrgRequest Rest Controller, My Deals Team send request to salesforce and hit this api
 * params:-
 * return:- List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse>
 * Author and Data: ankit1x.sharma@intel.com  20/09/2021
 */
@RestResource(urlMapping = '/BusinessOrganizationRequest/*')
global without sharing class UCD_BizOrgRequestRestController {
    @HttpPost
    global static List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> CreatBusinessOrganizationRequest() {
        List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> invalidRequests = new List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse>();
        List<UCD_BizOrgRequestRestModel.AccountRestDetail> validAccountRequests = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
        // Parse request body
        UCD_BizOrgRequestRestModel requestModel = UCD_BizOrgRequestRestModel.parseRequestBody(RestContext.request.requestBody.toString());
        if(requestModel!=null && requestModel.AccountRequests != null){
            // check duplicate requests
            TagDuplicateAccountRequest(requestModel);
            //validate request
            validateRequest(requestModel,validAccountRequests, invalidRequests);
            // service layer call
            List <UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> serviceResponse = createAccountAndResponse(validAccountRequests);
            //return response
            serviceResponse.addAll(invalidRequests);
            return serviceResponse;
        }
        invalidRequests.add(createErrorResponse(null,null, 'Something Wrong in Request'));
        return invalidRequests; 
       
    }
   /**
    * description:- Validate request (Diffrentiate Valid Account and Invalid Account)
    * params:-UCD_BizOrgRequestRestModel,  List<UCD_BizOrgRequestRestModel.AccountRestDetail>, List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static void validateRequest(UCD_BizOrgRequestRestModel requestModel,
                                        List<UCD_BizOrgRequestRestModel.AccountRestDetail> validAccountRequests,
                                        List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> invalidRequests) {
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
            if (errors.size() > 0 || (requestModel.AccountRequests[i].IsDuplicate != null && requestModel.AccountRequests[i].IsDuplicate == true )) {
                String msg = (requestModel.AccountRequests[i].IsDuplicate != null && requestModel.AccountRequests[i].IsDuplicate == true )?'Duplicate Account Request': errors.toString().contains('(')? errors.toString().substring(1, errors.toString().length() - 1) : errors.toString();
                invalidRequests.add( createErrorResponse(null,requestModel.AccountRequests[i], msg) );
            } else {
                validAccountRequests.add(requestModel.AccountRequests[i]);
            }
        }
    }
   /**
    * description:- Validate Account Address
    * params:-UCD_BizOrgRequestRestModel,  List<UCD_BizOrgRequestRestModel.AccountRestDetail>, List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static List<String> validateAccountRequestAddresses(List<UCD_BizOrgRequestRestModel.AccountRestAddresses> addresses) {
        List<String> addressErrors = new List<String>();
        if(addresses != null){
            for (UCD_BizOrgRequestRestModel.AccountRestAddresses address : addresses) {
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
    * params:-UCD_BizOrgRequestRestModel,  List<UCD_BizOrgRequestRestModel.AccountRestDetail>, List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static void TagDuplicateAccountRequest(UCD_BizOrgRequestRestModel requestModel) {
        List<String> acctRequestsFilter = new List<String>();
        for (Integer index = 0; index < requestModel.AccountRequests.size(); index++) {
            // check for nulladdress
            if(requestModel.AccountRequests[index].Addresses != null){
                for (UCD_BizOrgRequestRestModel.AccountRestAddresses addressRef : requestModel.AccountRequests[index].Addresses) {
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
    * params:-UCD_BizOrgRequestRestModel,  List<UCD_BizOrgRequestRestModel.AccountRestDetail>, List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse>
    * return:-
    * Author and Data: Yashvir.Pathak@intel.com  22/10/2021
    */
    private static List < UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> createAccountAndResponse(List <UCD_BizOrgRequestRestModel.AccountRestDetail> validAccountListData) {
        UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
        List < UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> controllerResponse = new  List < UCD_BizOrgRequestRestModel.BusinessOrganizationResponse >();
        List < UCD_ACM_Models.BusinessOrganizationResponseforService > responseFromService = new List < UCD_ACM_Models.BusinessOrganizationResponseforService >();
        UCD_BizOrgRequestRestModel.BusinessOrganizationResponse responseObj;
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
     * params:- List < UCD_BizOrgRequestRestModel.AccountRestDetail >
     * return:-  List< UCD_ACM_Models.AccountModel>
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */
    private static List< UCD_ACM_Models.AccountModel> mappingControllerModelToSericeModel(List < UCD_BizOrgRequestRestModel.AccountRestDetail > requestModel) {
        UCD_ACM_Models.AccountModelForService accountModelForService = new UCD_ACM_Models.AccountModelForService();
        List <UCD_ACM_Models.AccountModel> lstaccountModel = new  List <UCD_ACM_Models.AccountModel>();
        for (UCD_BizOrgRequestRestModel.AccountRestDetail requestModelRecord : requestModel) {
            UCD_ACM_Models.AccountModel accountModel = new UCD_ACM_Models.AccountModel();
            accountModel.Name = requestModelRecord.Name;
            accountModel.CustomerAggregationTypeCode = requestModelRecord.CustomerAggregationTypeCode;
            accountModel.CustomerProcessEngagmentCode = requestModelRecord.CustomerProcessEngagmentCode;
            accountModel.RequesterName = requestModelRecord.RequesterName;
            accountModel.RequesterWWID = requestModelRecord.RequesterWWID;
            accountModel.CustomerURL =  requestModelRecord.CustomerURL;
            accountModel.RequesterEmail = requestModelRecord.RequesterEmail;
            accountModel.ParentBusinessPartyIdentifierReference = requestModelRecord.ParentBusinessPartyIdentifierReference;
            List< UCD_ACM_Models.AccountAddress > lstofnewModeladdr = new List< UCD_ACM_Models.AccountAddress >();
            for (UCD_BizOrgRequestRestModel.AccountRestAddresses addressRef : requestModelRecord.Addresses) {
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
                    for (UCD_BizOrgRequestRestModel.AccountRestRequestReference accountRef : requestModelRecord.AccountRequestReferences) {
                        //mapOfAccReqRef.put(accountRef.Name, accountRef.Value);	
                        mapOfAccReqRef.put('MyDeals', accountRef.Value);	
                    }
                    accountModel.AccountRequestReferences = mapOfAccReqRef;
                }else{
                        mapOfAccReqRef.put('MyDeals', '');	
                        accountModel.AccountRequestReferences = mapOfAccReqRef;
                }
                
            }else if(  requestModelRecord.AccountRequestReferences == null){
                        mapOfAccReqRef.put('MyDeals', '');	
                        accountModel.AccountRequestReferences = mapOfAccReqRef;
            }

            lstaccountModel.add(accountModel);
        }
        return lstaccountModel;
    }

    /**
     * description:- Create Error Response
     * params:- UCD_ACM_Models.BusinessOrganizationResponseforService, UCD_BizOrgRequestRestModel.AccountRestDetail, String errorMessage
     * return:- UCD_BizOrgRequestRestModel.BusinessOrganizationResponse
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */
    private static UCD_BizOrgRequestRestModel.BusinessOrganizationResponse createErrorResponse(UCD_ACM_Models.BusinessOrganizationResponseforService responseAfterInsertacc, UCD_BizOrgRequestRestModel.AccountRestDetail accountInController, String errorMessage ) {
        UCD_BizOrgRequestRestModel.BusinessOrganizationResponse responseObj = new UCD_BizOrgRequestRestModel.BusinessOrganizationResponse();
        UCD_BizOrgRequestRestModel.Data responseData = new UCD_BizOrgRequestRestModel.Data();
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
                for (UCD_BizOrgRequestRestModel.AccountRestAddresses addressRef : accountInController.Addresses) {
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
     * return:- UCD_BizOrgRequestRestModel.BusinessOrganizationResponse
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */
    private static UCD_BizOrgRequestRestModel.BusinessOrganizationResponse createSuccessResponse( UCD_ACM_Models.BusinessOrganizationResponseforService responseAfterInsertacc ) {
        UCD_BizOrgRequestRestModel.BusinessOrganizationResponse responseObj = new UCD_BizOrgRequestRestModel.BusinessOrganizationResponse();
        UCD_BizOrgRequestRestModel.Data responseData = new UCD_BizOrgRequestRestModel.Data();
        responseData.AccountId = responseAfterInsertacc.AccountId;
        responseData.CountryName = responseAfterInsertacc.CountryName;
        responseData.Name = responseAfterInsertacc.AccountData.Name;
        responseData.AccountStatus = responseAfterInsertacc.accountstatus;
        responseObj.Errormessage = null;
        responseObj.Status = 'Success';
        responseObj.Code = '200';
        responseObj.Data = responseData;
        return responseObj;
    }
}