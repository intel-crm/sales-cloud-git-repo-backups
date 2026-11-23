global class IQR_BizOrgRequestRestHelper{

	private UCD_BizOrgRequestRestModel requestBody ;
 	private UCD_BizOrgRequestRestModel.ResponseWrap responseObj ;
 
 	global IQR_BizOrgRequestRestHelper(UCD_BizOrgRequestRestModel  requestBody){
		this.requestBody = requestBody ;
 	}
 
 	public UCD_BizOrgRequestRestModel.ResponseWrap IQR_BizOrgRequestHelperRecord(){
	
	try{
		if(String.isBlank(requestBody.Name) || String.isBlank(requestBody.CustomerAggregationTypeCode) || String.isBlank(requestBody.ContactEmailId) || String.isBlank(requestBody.TaxId)){

            responseObj = new UCD_BizOrgRequestRestModel.ResponseWrap();
			responseObj.isSuccess = false;
			responseObj.message = 'Failure Name/CustomerAggregationTypeCode/ContactEmailId/TaxId is mandatory';
			responseObj.responseCode = '201';
			responseObj.salesforceId = null;
            return responseObj;
		}
		
		/*	List < Account > accListRecord = new List < Account >();
			Account accRecord = new Account();
			accRecord.Name = requestBody.Name;
			accRecord.CustomerAggregationTypeCode = requestBody.CustomerAggregationTypeCode;
			accRecord.ContactEmailId = requestBody.ContactEmailId;
			accRecord.TaxId = requestBody.TaxId;
			
			accListRecord.add(accRecord);
			insert accListRecord ;
		*/
            responseObj = new UCD_BizOrgRequestRestModel.ResponseWrap();
			responseObj.isSuccess = true;
			responseObj.message = 'Success';
			responseObj.responseCode = '200';
			responseObj.salesforceId = null;
        	return responseObj;
		}
		catch(Exception ex){
			responseObj.isSuccess = false;
			responseObj.message = ex.getMessage();
			responseObj.responseCode = '201';
			responseObj.salesforceId = null;
        	return responseObj;
		}
	}
}