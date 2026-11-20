/****************************************************************************************************
Apex Class Name : Pricing_UCD_IQR_FormRequest
Version         : 1.0 
Created Date    : -
Function        : This class is used to form requests sent to UCD
Modifications   :
*****************************************************************************************************
* Developer : Anjali                             
*****************************************************************************************************/

public without sharing class Pricing_UCD_IQR_FormRequest{
    //check for duplicate 
    @InvocableMethod(label='sendRequestToUCD' description='To send Request to UCD')
    public static void sendRequestToUCD(List<Id> quoteIdList) {
        try{
            List<Id> recordIdList = new List<Id>();
            Map<Id, String> objectIdMsgMap = new Map<Id, String>();//objId==>core log entry msg
            Map<Id, String> objectIdDetailsMap = new Map<Id, String>();//objId==>core log entry deatails(Request payload)

            if(quoteIdList.size() > 0) {
                for(Id quoteId : quoteIdList) {
                    String msg = 'UCD Request Flow executed for Quote Id:' +quoteId;
                    if(!recordIdList.contains(quoteId)) {
                        recordIdList.add(quoteId); 
                    }

                    if(!objectIdMsgMap.containsKey(quoteId)) {
                        objectIdMsgMap.put(quoteId, msg);
                    }

                    if(!objectIdDetailsMap.containsKey(quoteId)) {
                        objectIdDetailsMap.put(quoteId, '');
                    }
                }  
            }
            //create log entry if flow is returning quote ids if label has value 1
            if(Label.Pricing_UCD_Log_Entry_Switch == '1' && objectIdMsgMap.size() > 0 && objectIdDetailsMap.size() > 0) {
                createUCDLogEntry(objectIdMsgMap, objectIdDetailsMap,'');
            }
            createPayloadAsynch(recordIdList);
        } 
        catch(Exception e) {
            Pricing_Tender_Utility.getExceptionMessage(e);
            Pricing_Tender_Utility.logError(e);        
        }
    }

    // Add logs for Create Pay Loads 
     
    //to have the sending request part in different transaction made it future method
    @future
    public static void createPayloadAsynch(List<Id> recordIdList) {

    List<Pricing_Integration_Staging__c> PISRecordsList = new List<Pricing_Integration_Staging__c>();

        Map<String, String> mapEndCustomerNameAndCountry = new Map<String, String>();
        Datetime fiveMinBack = Datetime.now().addMinutes(-5);

        for(SBQQ__QuoteLine__c quoteLines : [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Pricing_End_Customer_Name__c, SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Id IN :recordIdList]){

            mapEndCustomerNameAndCountry.put(quoteLines.SBQQ__Quote__r.Pricing_End_Customer_Name__c,quoteLines.SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c );
        }
 
    for(Pricing_Integration_Staging__c pis : [SELECT Id, Pricing_Payload__c FROM  Pricing_Integration_Staging__c WHERE Pricing_QuoteID__c IN :recordIdList AND CreatedDate >= :fiveMinBack]){
            for(String endCustomerName : mapEndCustomerNameAndCountry.keySet()){
                if(pis.Pricing_Payload__c.contains(endCustomerName) && pis.Pricing_Payload__c.contains(mapEndCustomerNameAndCountry.get(endCustomerName))){
                    PISRecordsList.add(pis);
                }
            }
    }

        if(PISRecordsList.isEmpty()) {
            createPayloads(recordIdList);
        }
    }
    
    public static void createPayloads(List<Id> recordIdList) {
        try{
            UCD_BizOrgRequestModel bizModel = new UCD_BizOrgRequestModel();
            List<UCD_BizOrgRequestModel.AccountDetail> requestModelList = new List<UCD_BizOrgRequestModel.AccountDetail>();
            List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> responseModelList =  new List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>();
            Map<Id, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>> quoteIdResponseMap = new Map<Id, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>>();
            Map<Id, String> objIdMsgMap = new Map<Id, String>(); //objId==>core log entry msg
            Map<Id, String> objIdDetailsMap = new Map<Id, String>(); //objId==>core log entry details(Request payload)
            List<SBQQ__Quote__C> quoteList = [SELECT Id,Name,Pricing_End_Customer__r.Name,Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,Pricing_End_Customer_Country_Nm__c,Pricing_End_Customer_Name__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Account_Executive_Nm__c,Pricing_Intel_Sales_Rep_Email_Txt__c,SBQQ__SalesRep__c,Pricing_Account_Executive_Nm__r.Name, SBQQ__SalesRep__r.Name,Pricing_End_Customer_URL__c FROM SBQQ__Quote__C WHERE Id IN: recordIdList]; //CH
            Map<String, UCD_BizOrgRequestModel.AccountDetail> endCustCountryRequestPayloadMap = new Map<String, UCD_BizOrgRequestModel.AccountDetail>();//'customer Name : Country'==>Request Payload
            Map<String, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>> customerCountryResponsePayloadsMap = new  Map<String, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>>();//'customer Name : Country' ==> response payloads
            List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> errorResponseList = new List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>();//to create log entry in bulk scenario
            List<Pricing_Quote_Team__c> quoteTeamList = [SELECT Id, Pricing_Quote_Team_Member_Id__c, Pricing_Quote_Id__c,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Team_Member_Id__r.Name FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN: recordIdList AND Pricing_Quote_Team_Member_Id__r.IsActive = true AND Pricing_Grant_Access_Ind__c = true];
            String pricingMgrEmail;//to store RPM Email
      String pricingMgrName;//to store RPM Name
            Id currentLoggedInUserId = UserInfo.getUserId();
            User userDetail = [Select Id, Name, Email from User where Id =: currentLoggedInUserId];

            userNameEmailWrapper userData = new userNameEmailWrapper();
            userData.email = null;

            //mapping the RPM values from current user record to String variables
            if(userDetail != null) {
                pricingMgrEmail = userDetail.Email;
                pricingMgrName = userDetail.Name;
            }

      if(recordIdList.size() > 0) {
                for(SBQQ__Quote__C quoteRecord: quoteList) {
                    UCD_BizOrgRequestModel.AccountDetail requestModel = new UCD_BizOrgRequestModel.AccountDetail();
                    UCD_BizOrgRequestModel.AccountAddresses addressDetails = new UCD_BizOrgRequestModel.AccountAddresses();
                    List<UCD_BizOrgRequestModel.AccountAddresses> addressDetailsList = new  List<UCD_BizOrgRequestModel.AccountAddresses>();
                    UCD_BizOrgRequestModel.AccountRequestReference accReqRef = new UCD_BizOrgRequestModel.AccountRequestReference();
                    List<UCD_BizOrgRequestModel.AccountRequestReference> accReqRefList = new List<UCD_BizOrgRequestModel.AccountRequestReference>();
                    String msg = 'UCD Request sent successfully:' +quoteRecord.Id;
                    
                    //UCD Request Details
                    requestModel.Name = quoteRecord.Pricing_End_Customer_Name__c;
                    requestModel.CustomerUrl = quoteRecord.Pricing_End_Customer_URL__c;
                    requestModel.CustomerProcessEngagmentCode = Label.Pricing_UCD_Customer_Process_Engagement;//'DIR_PRC_EXCPT';
                    requestModel.CustomerAggregationTypeCode = Label.Pricing_UCD_Customer_Aggregation_Type;//'UNFD_CTRY_CUST';
                    
                    //CH.Start
                    // Check primary AE
                    if(isActiveAndHasPS(quoteRecord.Pricing_Account_Executive_Nm__c, Label.Pricing_Tender_PermissionSets_TenderAccountExecutive)){ // persmission Set check 
                        requestModel.RequesterEmail = quoteRecord.Pricing_Intel_Account_Exec_Email_Txt__c;//stores QL's AE Email
                        requestModel.RequesterName = quoteRecord.Pricing_Account_Executive_Nm__r.Name;//stores QL's AE Name 
                    }else if((userData = getUserNameEmail(quoteTeamList, Label.Pricing_Quote_Team_Role_Account_Executive, quoteRecord.Id, Label.Pricing_Tender_PermissionSets_TenderAccountExecutive)).email != null ){ // Check Quote Team AE
                        requestModel.RequesterEmail = userData.email;//stores QL's Shared AE Email
                        requestModel.RequesterName = userData.name;//stores QL's Shared AE Name
                    }else if(isActiveAndHasPS(quoteRecord.SBQQ__SalesRep__c,Label.Pricing_Tender_PermissionSets_TenderUser )){ //Check primary Sales rep
                        requestModel.RequesterEmail = quoteRecord.Pricing_Intel_Sales_Rep_Email_Txt__c;//stores QL's Sales Rep Email
                        requestModel.RequesterName = quoteRecord.SBQQ__SalesRep__r.Name;//stores QL's Sales Rep Name 
                    } else if((userData = getUserNameEmail(quoteTeamList, Label.Pricing_Quote_Team_Role_FSE, quoteRecord.Id, Label.Pricing_Tender_PermissionSets_TenderUser)).email != null ){ // Check Quote Team AE
                        requestModel.RequesterEmail = userData.email;//stores QL's Shared AE Email
                        requestModel.RequesterName = userData.name;//stores QL's Shared AE Name
                    } else{ // If AE and Sales Rep Not Available 
                        requestModel.RequesterEmail = pricingMgrEmail;//stores QL's RPM Email
                        requestModel.RequesterName = pricingMgrName;//stores QL's RPM Name
                    }
                    //CH.End
                    //check if the End Customer is not Write In End Customer
                    if(quoteRecord.Pricing_End_Customer__r.Name != Label.Pricing_IQR_API_WriteInEndCustomer){
                         requestModel.ParentBusinessPartyIdentifierReference = quoteRecord.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c;
                    }
                    //UCD Address details
                    addressDetails.CountryName = quoteRecord.Pricing_End_Customer_Country_Nm__c;
                    addressDetails.CountryCode = getCountryCode(quoteRecord.Pricing_End_Customer_Country_Nm__c);
                    addressDetailsList.add(addressDetails);
                    requestModel.Addresses = addressDetailsList;

                    //UCD Account Request Reference details
                    accReqRef.Name = 'IQR';
                    accReqRef.Value = quoteRecord.Name;
                    accReqRefList.add(accReqRef);
                    requestModel.AccountRequestReferences = accReqRefList; 

                    //to avoid duplicate request in same transaction and create an payload entry only once for same combination of end customer and country
                    if(!endCustCountryRequestPayloadMap.containsKey(quoteRecord.Pricing_End_Customer_Name__c + ' : ' + quoteRecord.Pricing_End_Customer_Country_Nm__c)) {
                        endCustCountryRequestPayloadMap.put(quoteRecord.Pricing_End_Customer_Name__c + ' : ' + quoteRecord.Pricing_End_Customer_Country_Nm__c, requestModel);
                    }
                    //requestModelList.add(requestModel);
 
                    //log entry message
                    if(!objIdMsgMap.containsKey(quoteRecord.Id)) {
                        objIdMsgMap.put(quoteRecord.Id, msg);
                    }
                    //log entry detail 
                    if(!objIdDetailsMap.containsKey(quoteRecord.Id)) {
                        objIdDetailsMap.put(quoteRecord.Id, JSON.serialize(requestModel)); // add the request payload to stamp in log entry
                    }
                }

                //add the unique customer contry resquests to requestModelList 
                for(String custCountry : endCustCountryRequestPayloadMap.keySet()) {
                    if (endCustCountryRequestPayloadMap.containsKey(custCountry)) {
                        requestModelList.add(endCustCountryRequestPayloadMap.get(custCountry));
                    }
                }

                if(requestModelList.size() > 0) {
                    bizModel.AccountRequests = requestModelList;
                }
                
                 //create log entry with request payload is label has value 1
                if(Label.Pricing_UCD_Log_Entry_Switch == '1' && objIdMsgMap.size() > 0 && objIdDetailsMap.size() > 0) {
                    createUCDLogEntry(objIdMsgMap, objIdDetailsMap,'');
                } 
                
                responseModelList = UCD_BizOrgRequestController.createBusinessOrganizationRequest(bizModel);

                //single quote 
                if(quoteList.Size() == 1) {
                    if(!quoteIdResponseMap.containsKey(recordIdList[0])) {
                        quoteIdResponseMap.put(recordIdList[0], responseModelList);// taking the 1st quote ID from the List as multiple quote submission is not real time scenario
                    }
                }

                //for bulk scenario
                if(quoteList.Size() > 1) {
                    //form the map of ('customer name : country name' ==> List of Responses)
                    for(UCD_BizOrgRequestModel.BusinessOrganizationResponse response : responseModelList) {
                        if(response.Status == Label.Pricing_UCD_Error_Status && response.Errormessage != Label.Pricing_UCD_Duplicate_Error_Msg) {
                            if(!errorResponseList.contains(response)) {
                                errorResponseList.add(response);
                            }
                        }

                        if(!customerCountryResponsePayloadsMap.containsKey(response.Data.Name +' : '+ response.Data.CountryName)) {
                            customerCountryResponsePayloadsMap.put(response.Data.Name +' : '+ response.Data.CountryName , new List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>{response});
                        } else {
                            customerCountryResponsePayloadsMap.get(response.Data.Name +' : '+ response.Data.CountryName).add(response);
                        }
                    }

                    //map the quote id with responses list needed to insert record PIS (quoteId ==> List of Responses)
                    for(SBQQ__Quote__C quoteRec: quoteList) {
                        if(customerCountryResponsePayloadsMap.containsKey(quoteRec.Pricing_End_Customer_Name__c + ' : ' + quoteRec.Pricing_End_Customer_Country_Nm__c)) {
                            if(!quoteIdResponseMap.containsKey(quoteRec.Id)) {
                                quoteIdResponseMap.put(quoteRec.Id , customerCountryResponsePayloadsMap.get(quoteRec.Pricing_End_Customer_Name__c + ' : ' + quoteRec.Pricing_End_Customer_Country_Nm__c));
                            }
                        }
                    }

                    if(errorResponseList.Size() > 0 && recordIdList.size() > 0) {
                        createUCDLogEntry(errorResponseList, recordIdList);
                    } 
                }
                
                if(quoteIdResponseMap.size() > 0) {
                    createPISRecord(quoteIdResponseMap);
                }
                          
            }
        }  catch(Exception e){
            Pricing_Tender_Utility.getExceptionMessage(e);
            Pricing_Tender_Utility.logError(e);        
        }
    }
    
    //get the country code from country 
    public static String getCountryCode(String country) {
        String countryCode;
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            if(f.getLabel() == country) {
                countryCode = f.getValue();
                break;
            }
        }
        return countryCode;
    }

    //method to create record in staging object 
    public static void createPISRecord(Map<Id, List<UCD_BizOrgRequestModel.BusinessOrganizationResponse>> recordIdResponseMap) {
        List<Pricing_Integration_Staging__c> stagingList = new List<Pricing_Integration_Staging__c>();
        List<Pricing_Integration_Staging__c> existingStagingRecordList = [SELECT Id, Pricing_SObjectId__c,Pricing_QuoteID__c, Pricing_UCD_Response_Type__c 
                                                                         FROM  Pricing_Integration_Staging__c 
                                                                         WHERE Pricing_Message_Type__c =:Label.Pricing_UCD_PIS_Message_Type 
                                                                            AND Pricing_SObjectId__c IN : recordIdResponseMap.keySet()];
        List<Pricing_Integration_Staging__c> pisRecordsToUpdateList = new List<Pricing_Integration_Staging__c>();
        Map<Id, String> quoteIdMsgMap = new Map<Id, String>();//objId==>core log entry msg
        Map<Id, String> quoteIdDetailsMap = new Map<Id, String>();//objId==>core log entry deatails(Request payload)
        List<UCD_ACM_Models.AccountResponseModel> duplicateResponseModelList = new List<UCD_ACM_Models.AccountResponseModel>();//to store the list duplicate account responses 

        for(Id recordId : recordIdResponseMap.keySet()) {
            UCD_BizOrgRequestModel.BusinessOrganizationResponse response = recordIdResponseMap.get(recordId)[0];
            UCD_BizOrgRequestModel.Data data = response.Data;
            
            Pricing_Integration_Staging__c pis = new Pricing_Integration_Staging__c();
            pis.Pricing_Payload__c = JSON.serialize(recordIdResponseMap.get(recordId)[0]);
            pis.Pricing_SObjectId__c = recordId;
            pis.Pricing_QuoteID__c = recordId;
            pis.Pricing_SObject__c = recordId.getSObjectType().getDescribe().getName();
            pis.Pricing_Status__c = (response.Status == Label.Pricing_UCD_Error_Status && response.Errormessage != Label.Pricing_UCD_Duplicate_Error_Msg) ? 'Failed' : 'Successful';
            //pis.Core_Origin__c = Label.Pricing_UCD_LogEntry_Origin; //

            //check the duplicate account and stamp request Id and the Duplicate request field
            if( String.isNotBlank(data.DuplicateAccountId) && (data.DuplicateAccountRecordType != Label.Pricing_UCD_Account_Duplicate_Requested_Record_Type)) {
                pis.Pricing_RequestID__c = data.DuplicateAccountId;
                pis.Pricing_UCD_Response_Type__c = Label.Pricing_UCD_Duplicate_Error_Msg;
                duplicateResponseModelList.add(data.DuplicateAccountInfo);
                //accountIdList.add(data.DuplicateAccountId);
            } else if(String.isNotBlank(data.DuplicateAccountId) && (data.DuplicateAccountRecordType == Label.Pricing_UCD_Account_Duplicate_Requested_Record_Type)) {
                pis.Pricing_RequestID__c = data.DuplicateAccountId;
                pis.Pricing_UCD_Response_Type__c = Label.Pricing_UCD_Requested_Duplicate_Account;
            } else if(String.isNotBlank(data.AccountId)) {
                pis.Pricing_RequestID__c = data.AccountId;
                pis.Pricing_UCD_Response_Type__c = Label.Pricing_UCD_Requested_Account;
            } else {
              //  pis.Pricing_RequestID__c = '';
            }

            pis.Pricing_Message_Type__c = Label.Pricing_UCD_PIS_Message_Type;
            stagingList.add(pis);

            //add the record to map if response is failed
            if(response.status == Label.Pricing_UCD_Error_Status && response.Errormessage != Label.Pricing_UCD_Duplicate_Error_Msg) {
                if(!quoteIdMsgMap.containsKey(recordId)) {
                    quoteIdMsgMap.put(recordId, 'Error ocurred in UCD response: ');
                }

                if(!quoteIdDetailsMap.containsKey(recordId)) {
                    quoteIdDetailsMap.put(recordId, JSON.serialize(recordIdResponseMap.get(recordId)[0]));
                }
            }
        }

        for(Pricing_Integration_Staging__c pisRec : existingStagingRecordList) {
            pisRec.Pricing_UCD_Response_Type__c = Label.Pricing_UCD_Response_Type_Resubmitted;
            if(!pisRecordsToUpdateList.contains(pisRec)) {
                pisRecordsToUpdateList.add(pisRec);
            }
        }

        if(pisRecordsToUpdateList.size() > 0) {
            update pisRecordsToUpdateList;
        }

        if(stagingList.size() > 0) {
            insert stagingList;
        }

        //create log entry for error response
        if(quoteIdMsgMap.size() > 0 && quoteIdDetailsMap.size() > 0) {
            createUCDLogEntry(quoteIdMsgMap, quoteIdDetailsMap,'Pricing_UCD_IQR_FormRequest.createPISRecord');
        }

        /*if(accountIdList.size() > 0) {
            sendDuplicateRequest(accountIdList);
        }*/

        if(duplicateResponseModelList.size() > 0) {
            formDuplicatePublisherResponse(duplicateResponseModelList);
        }
    }

    //form the payload for rejection with survivor account and send the survivor account request to UCD 
    public static void sendSurvivorRequest(List<String> accIdList) {
        try{
            UCD_ACM_BusinessOrganizationModel accSurvivorRequestModel = new UCD_ACM_BusinessOrganizationModel();
            UCD_ACM_BusinessOrganizationModel.BusinessOrganizationData bizOrgAccModel = new UCD_ACM_BusinessOrganizationModel.BusinessOrganizationData();
            List<UCD_ACM_BusinessOrganizationModel.AttributesData> bizOrgAttributeList = new List<UCD_ACM_BusinessOrganizationModel.AttributesData>();
            List < String > attributeList = new List < String > ((Label.Pricing_UCD_Account_Reuse_Attributes).split(':'));

            for(String arrString : attributeList) {
                UCD_ACM_BusinessOrganizationModel.AttributesData bizOrgAttribute = new UCD_ACM_BusinessOrganizationModel.AttributesData();
                bizOrgAttribute.AttributeName = arrString;
                bizOrgAttributeList.add(bizOrgAttribute);
            }

            accSurvivorRequestModel.TransactionId = Pricing_Tender_Utility.getGUID();
            bizOrgAccModel.AccountId = accIdList;
            accSurvivorRequestModel.Attributes = bizOrgAttributeList;
            accSurvivorRequestModel.BusinessOrganization = bizOrgAccModel;

            UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response = UCD_ACM_BusinessOrganization.businessOrganization(accSurvivorRequestModel);
            genereatePublisherRequest(response);
            
        } catch(Exception e){
            Pricing_Tender_Utility.getExceptionMessage(e);
            Pricing_Tender_Utility.logError(e);        
        }
    }      

    //form the response and map it to the publisher payload format
    public static void genereatePublisherRequest(UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse response) {
        List<Pricing_UCD_ResponseWrapper.ResponseData> responseWrapperList = new List<Pricing_UCD_ResponseWrapper.ResponseData>();
        set<String> custProcessEngSet = new set<String>();
        
        for(UCD_ACM_BusinessOrganizationModel.ResponseData data: response.Data) {
            for(UCD_ACM_BusinessOrganizationModel.cusProcEng custEng : data.AccountInformation.CustomerProcessEngagement) {
                custProcessEngSet.add(custEng.Code);
            } 
            // if CustomerAggregationType = UNFD_CTRY_CUST and CustomerProcessEngagement has 'DIR_PRC_EXCPT' for the pulisher response and process it
            if(data.AccountInformation.CustomerAggregationType.Code == Label.Pricing_UCD_Customer_Aggregation_Type && custProcessEngSet.contains(Label.Pricing_UCD_Customer_Process_Engagement)) {
                Pricing_UCD_ResponseWrapper.ResponseData responseWrapper = new Pricing_UCD_ResponseWrapper.ResponseData();
                List<Pricing_UCD_ResponseWrapper.CustomerProcessEngagement> processEngList =  new List<Pricing_UCD_ResponseWrapper.CustomerProcessEngagement>();
                List<Pricing_UCD_ResponseWrapper.ComplianceWatchList> cwlList = new List<Pricing_UCD_ResponseWrapper.ComplianceWatchList>();

                //L2 Details
                responseWrapper.BusinessPartyIdentifier = data.AccountInformation.BusinessPartyIdentifier;
                responseWrapper.AccountName = data.AccountInformation.AccountName;
                responseWrapper.AccountId = data.AccountInformation.AccountId;
                responseWrapper.MasteredSimplifiedAccountName = data.AccountMasteredDetails.SimplifiedAccountName;
                //Address Details
                for(UCD_ACM_BusinessOrganizationModel.AccountAddressInformation addressInfo : data.AccountAddressInformation) {
                    Pricing_UCD_ResponseWrapper.AccountAddress address = new Pricing_UCD_ResponseWrapper.AccountAddress();
                    address.TypeCode = addressInfo.AddressType;
                    address.CountryCode = addressInfo.Countrycode;
                    address.CountryName = getCountryLabel(addressInfo.Countrycode);
                    //address.CountryName = addressInfo.CountryName;
                    //Secondary address details
                    if(addressInfo.AddressType == Label.Pricing_UCD_Address_Type_Shipping) {
                        responseWrapper.SecondaryAddress = address;
                    }
                    //Primary address details
                    if(addressInfo.AddressType == Label.Pricing_UCD_Address_Type_Billing) {
                        responseWrapper.PrimaryAddress = address;
                    }
                }
                //L1 Details
                Pricing_UCD_ResponseWrapper.ResponseData l1Record = new Pricing_UCD_ResponseWrapper.ResponseData();
                l1Record.BusinessPartyIdentifier = data.ParentAccountInfomation.BusinessPartyIdentifier;
                l1Record.AccountId = data.ParentAccountInfomation.AccountId;
                l1Record.AccountName = data.ParentAccountInfomation.AccountName;
                l1Record.MasteredSimplifiedAccountName = data.ParentAccountInfomation.SimplifiedAccountName;
                responseWrapper.ParentAccount = l1Record;

                //Customer Process Engagement
                for(UCD_ACM_BusinessOrganizationModel.cusProcEng custEng : data.AccountInformation.CustomerProcessEngagement) {
                    Pricing_UCD_ResponseWrapper.CustomerProcessEngagement processEng = new Pricing_UCD_ResponseWrapper.CustomerProcessEngagement(custEng.Code,custEng.Name);
                    processEngList.add(processEng);
                }   

                if(processEngList.size() > 0) {
                    responseWrapper.CustomerProcessEngagement = processEngList;
                }
                
                //Customer Aggregation Type
                Pricing_UCD_ResponseWrapper.CustomerAggregationType custAggrTypeRec = new Pricing_UCD_ResponseWrapper.CustomerAggregationType(data.AccountInformation.CustomerAggregationType.Code,data.AccountInformation.CustomerAggregationType.Name);
                responseWrapper.CustomerAggregationType = custAggrTypeRec;

                //Compliance Watchlist
                if(data.AccountComplianceDetails != null) {
                    for(UCD_ACM_BusinessOrganizationModel.AccountComplianceDetails cwl : data.AccountComplianceDetails) {
                        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwlRecord = new Pricing_UCD_ResponseWrapper.ComplianceWatchList(cwl.Code,cwl.Name);
                        cwlList.add(cwlRecord);
                    }
                }
                
                if(cwlList.size() > 0) {
                    responseWrapper.ComplianceWatchList = cwlList;
                }

                //if(data.AccountInformation.CustomerAggregationType.Code == 'UNFD_CTRY_CUST' && CustomerProcessEngagement.contains('DIR_PRC_EXCPT'))
                responseWrapperList.add(responseWrapper);
            }
        }

        if(responseWrapperList.size() > 0) {
            if(!Test.isRunningTest()){            
            Pricing_UCD_IQR_Response_Handler.processUCDResponses(responseWrapperList);
            }
        }

    }

    public static String getCountryLabel(String countryCode) {
        String countryLabel;
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            if(f.getValue() == countryCode) {
                countryLabel = f.getLabel();
                break;
            }
        }
        return countryLabel;
    }


    //create log entry for debugging flow and future method
    public static void createUCDLogEntry(Map<Id, String> quoteIdMsgMap, Map<Id, String> quoteIdMsgDetailsMap,String classMethodName) {
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        for(Id quoteId : quoteIdMsgMap.keySet()) {
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
            logEntry.Core_sObjectId__c = quoteId;
            logEntry.Core_sObjectType__c = quoteId.getSObjectType().getDescribe().getName();
            logEntry.Core_Severity__c = (quoteIdMsgMap.get(quoteId).contains('UCD Request Flow executed for Quote Id:') || quoteIdMsgMap.get(quoteId).contains('UCD Request sent successfully:')) ? 'Low' :'Critical';
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Origin__c = Label.Pricing_UCD_LogEntry_Origin;
            logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
            logEntry.Core_Message__c =String.isNotBlank(classMethodName) ? Label.Pricing_IQR_SFDC_Environment + ':' +quoteIdMsgMap.get(quoteId) + ' ' + 'Class.' +classMethodName+ ' sObject Id:' +quoteId : quoteIdMsgMap.get(quoteId);
            logEntry.Core_Details__c = quoteIdMsgDetailsMap.get(quoteId);
            logEntry.Core_When__c = system.now();
            logEntryList.add(logEntry);
        } 
        if(logEntryList.size() > 0) {
            insert logEntryList;
        }
    }

    //Create log entry for errors in bulk scenario
    public static void createUCDLogEntry(List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> errorResponseList, List<Id> recordIdList) {
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        for(UCD_BizOrgRequestModel.BusinessOrganizationResponse ucdResponse : errorResponseList) {
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c();

            logEntry.Core_Severity__c = 'Critical';
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Origin__c = Label.Pricing_UCD_LogEntry_Origin;
            logEntry.Core_Message__c = Label.Pricing_IQR_SFDC_Environment + ': Error occured in UCD Response : Class.Pricing_UCD_IQR_FormRequest.createPayloads';
            logEntry.Core_sObjectType__c = recordIdList[0].getSObjectType().getDescribe().getName();
            logEntry.Core_Details__c = JSON.serialize(ucdResponse) + '\nQuote Ids: ' + recordIdList;
            logEntry.Core_When__c = system.now();
            logEntryList.add(logEntry);
        } 
        if(logEntryList.size() > 0) {
            insert logEntryList;
        }
    }

    //method to form request payload for duplicate account and process duplicate account
    public static void formDuplicatePublisherResponse(List<UCD_ACM_Models.AccountResponseModel> duplicateResponseModelList) {
        List<Pricing_UCD_ResponseWrapper.ResponseData> publisherRequestList = new List<Pricing_UCD_ResponseWrapper.ResponseData>();

        for(UCD_ACM_Models.AccountResponseModel responseModel : duplicateResponseModelList) {           
            String responseString = JSON.serialize(responseModel);
            Pricing_UCD_ResponseWrapper.ResponseData publisherRequest = (Pricing_UCD_ResponseWrapper.ResponseData)System.JSON.deserialize(responseString,Pricing_UCD_ResponseWrapper.ResponseData.class);
            publisherRequestList.add(publisherRequest);
        }

        if(publisherRequestList.size() > 0) {
            Pricing_UCD_IQR_Response_Handler.processUCDResponses(publisherRequestList);
        }

    }

    // User is Active and has permissionset 
    public static Boolean isActiveAndHasPS(Id UserId, String PermissionSetName){

        Integer isActiveCount = 0, PermissionSetCount = 0;
        Boolean hasPS = false ;
        if(UserId != null){
            isActiveCount = [SELECT count() from User WHERE Id =: UserId AND isActive = true];
            PermissionSetCount = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :UserId AND PermissionSet.Name = :PermissionSetName ];
        }
        hasPS = isActiveCount > 0 && PermissionSetCount > 0 ? true : false;
        return hasPS;
    }

    /**
    * @description Method used to retrigger UCD Request for a End Customer when a PIS request exists with a Rejected Account Record Type
    * @author Bharath Chandrashekar | 06-06-2023 
    * @param List<Id> quoteIdList 
    * @return Boolean
    **/
    @AuraEnabled
    public static Boolean resubmitUCDRequest(List<Id> quoteIdList){
        Boolean ucdPISRequestExists = false;
        try {
            List<Id> quoteIds = new List<Id>();
            List<Pricing_Integration_Staging__c> pisList = [SELECT Id, Pricing_Message_Type__c, Pricing_QuoteID__c, Pricing_QuoteID__r.Pricing_IsUnifiedCustomer__c, Pricing_RequestID__r.RecordType.Name, 
                                                        Pricing_UCD_Response_Type__c FROM Pricing_Integration_Staging__c 
                                                        WHERE Pricing_Message_Type__c =: Label.Pricing_UCD_PIS_Message_Type AND Pricing_QuoteID__c IN: quoteIdList ORDER BY CreatedDate desc];
            if(pisList.size() > 0){
                if(pisList[0].Pricing_RequestID__r.RecordType.Name == Label.Pricing_UCD_Record_Type_Rejected_Account){
                    quoteIds.add(pisList[0].Pricing_QuoteID__c);
                }
            }
            if(quoteIds.size() > 0){
                ucdPISRequestExists = true;
                sendRequestToUCD(quoteIds);
            }
            else{
                ucdPISRequestExists = false;
            }
        }
        catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
        }
        return ucdPISRequestExists;
    }

    public static userNameEmailWrapper getUserNameEmail(List<Pricing_Quote_Team__c> quoteTeamList, String role, Id quoteId, String permissionSet){
        userNameEmailWrapper u = new userNameEmailWrapper(); 
        for(Pricing_Quote_Team__c  qtl :  quoteTeamList){
            if(qtl.Pricing_Role_Nm__c == role && qtl.Pricing_Quote_Id__c == quoteId && isActiveAndHasPS(qtl.Pricing_Quote_Team_Member_Id__c, permissionSet)){
                u.email = qtl.Pricing_Quote_Team_Member_Id__r.Email;//stores QL's Shared AE Email
                u.name = qtl.Pricing_Quote_Team_Member_Id__r.Name;//stores QL's Shared AE Name
                break;
            }
        }
        return u;
    }

    public class userNameEmailWrapper
    {
        public String name {get; set;}
        public String email {get; set;}
    }
}