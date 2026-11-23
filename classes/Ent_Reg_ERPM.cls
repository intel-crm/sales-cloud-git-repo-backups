public class Ent_Reg_ERPM {
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'Ent_Reg_ERPM';
    
@InvocableMethod(label='Call to ERPM API' description='Insert Registration Request' category= 'New Registration')
  public static void insertRegistrationRequest(List<PRM_Registration_Request__c> reqs) {
    System.Debug(reqs[0].Name);
    System.Debug('Invoked!!');
      string json = '';
      Set<Id> requestIds = new Set<Id>(); 

      
      
      
      for(PRM_Registration_Request__c req : reqs){
          requestIds.add(req.Id);
      }
      
      for(PRM_Registration_Request__c request : [SELECT PRM_First_Name__c, PRM_Last_Name__c, PRM_Email_ID__c,
                                                    PRM_Job_Function__c, PRM_Preferred_Language__c,PRM_Profession__c,PRM_Country__c,
                                                    PRM_Address_Line_1__c,PRM_City__c, PRM_State_Province__c, PRM_Zip_Postal_Code__c,
                                                    PRM_Person_Phone_Number__c,Entitlement_Details__r.Name,PRM_Channel_Program__r.Name
                                                    FROM PRM_Registration_Request__c
                                                    WHERE Id =: requestIds]){
          json = GeneratePayload(request);
                                                        
      }
      
  }
    
    private static string GeneratePayload(PRM_Registration_Request__c request) {
        Ent_Reg_eRPMApiModel.payload inputModel = new Ent_Reg_eRPMApiModel.payload();
        Ent_Reg_eRPMApiModel.PersonAccountProfile pAcctProfile = new Ent_Reg_eRPMApiModel.PersonAccountProfile();
        string requestValue = '';
        
        pAcctProfile.FirstName = request.PRM_First_Name__c;
        pAcctProfile.LastName = request.PRM_Last_Name__c;
        pAcctProfile.EmailID = request.PRM_Email_ID__c;
        pAcctProfile.JobFunction = request.PRM_Job_Function__c;
        pAcctProfile.LanguageCode = request.PRM_Preferred_Language__c;
        pAcctProfile.ExternalAttributes.ProfessionCode=request.PRM_Profession__c ;
        
        if(String.isNotBlank(request.PRM_Country__c)) {            
            Ent_Reg_eRPMApiModel.PersonPhysicalAddresses phyAddr =new Ent_Reg_eRPMApiModel.PersonPhysicalAddresses(request.PRM_Address_Line_1__c, request.PRM_City__c, 
                                                                         request.PRM_State_Province__c, request.PRM_Country__c, request.PRM_Zip_Postal_Code__c);
            pAcctProfile.PersonPhysicalAddresses.add(phyAddr);
        }
        if(request.PRM_Person_Phone_Number__c != null) {
             pAcctProfile.PersonElectronicAddresses.add(new Ent_Reg_eRPMApiModel.PersonElectronicAddresses('PHONE', request.PRM_Person_Phone_Number__c));
        }
        system.debug('enttl- '+ request.Entitlement_Details__c);
        if(request.Entitlement_Details__c != null) {
            requestValue = request.Entitlement_Details__r.Name;
        }
        else if(request.PRM_Channel_Program__c != null) {
            requestValue = request.PRM_Channel_Program__r.Name;
        }
        system.debug('requestValue'+ requestValue);
        if(String.isNotBlank(requestValue)) {
        	ERPMSFEngagementSetting__mdt metadata = [SELECT EntitlementProgName__c, Code__c FROM ERPMSFEngagementSetting__mdt 
                                                 WHERE EntitlementProgName__c =: requestValue limit 1];
        	pAcctProfile.Memberships.add(new Ent_Reg_eRPMApiModel.Memberships(metadata.Code__c,'ENGSTSAPRD')); 
            system.debug('metadata'+ metadata);
        }
        
        inputModel.PersonAccountProfile = pAcctProfile;
        
        system.debug('json- '+ JSON.serialize(inputModel));
        return JSON.serialize(inputModel);
    }
    
    private static string GetToken() {
      HttpRequest httpReq = new HttpRequest();
      HttpResponse response = new HttpResponse();
      PRM_Token_Model token = new PRM_Token_Model();
        string access_token = '';
        string payload = '';
        try {
            httpReq.setEndpoint('https://apis-stage.intel.com/v1/auth/token');
            httpReq.setMethod('POST');
            httpReq.setHeader('content-type','application/x-www-form-urlencoded');
            payLoad ='grant_type=client_credentials&client_id=' +EncodingUtil.urlEncode('7794edfc-201c-42a8-a5dd-5c7f17263a51', 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode('0sPhGs5vDaIl.2Y.IyLq_U6n84ctD9Yv_z', 'UTF-8');
            httpReq.setBody(payLoad);
            response = new Http().send(httpReq);
            if (response.getStatusCode() == 200) {
                token = PRM_Token_Model.parse(response.getBody());
                access_token = token.access_token;
            }
            else {
                ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            	custEx.Message = response.getBody();            
            	ER_ErrorUtility.createLogEntry('Error in GetToken', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, null);
            }
        }
        catch(Exception ex){            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in GetToken- APIGEE', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, null);
        }
		return access_token;
    }
    
    private static void ExecuteAPI(string json, Id requestId) {
        string eRPMResponse = '';
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        string params = requestId;
        try {
            HttpRequest httpReq = new HttpRequest();
			HttpResponse response = new HttpResponse();
            httpReq.setEndpoint('callout:eRPM_Apigee/m2r/erpm/v1/profiles/set-profiles');
            httpReq.setMethod('POST');
            httpReq.setBody(json);
            response = new Http().send(httpReq);           
            custEx.Message = response.getBody();        
            ER_ErrorUtility.createLogEntry('ExecuteAPI', custEx, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, params);                    
        }
        catch(Exception ex){
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in ExecuteAPI- APIGEE', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
		
    }
}