global with sharing class CIDAAS_ERPM_Callout {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'CIDAAS_ERPM_Callout'; 
    
    @InvocableMethod(label='ERPM API Callout' description='Assign ERPM Engagements' category= 'New Registration')
    public static void assignERPMEngagements(List<Id> requestIds) {        
        string json = '';
        Map<string, ERPMSFEngagementSetting__mdt> erpmSFSettingMap = new Map<string, ERPMSFEngagementSetting__mdt>();
        
        //Custom metadata to store entitlement/program to engagement mapping
        if(Schema.sObjectType.ERPMSFEngagementSetting__mdt.isAccessible()){
            for(ERPMSFEngagementSetting__mdt mdt : [SELECT EntitlementProgName__c, Code__c, Notify__c FROM ERPMSFEngagementSetting__mdt WITH SECURITY_ENFORCED]) {
                erpmSFSettingMap.put(mdt.EntitlementProgName__c,mdt);
            }
        }
        //Get regitration request details using request Ids
        if(Schema.sObjectType.PRM_Registration_Request__c.isAccessible()){
            for(PRM_Registration_Request__c request : [SELECT PRM_First_Name__c, PRM_Last_Name__c, PRM_Email_ID__c,
                                                       PRM_Job_Function__c, PRM_Preferred_Language__c,PRM_Profession__c,PRM_Country__c,
                                                       PRM_Address_Line_1__c,PRM_City__c, PRM_State_Province__c, PRM_Zip_Postal_Code__c,
                                                       PRM_Person_Phone_Number__c,Entitlement_Details__r.Name,PRM_Channel_Program__r.Name,
                                                       PRM_Subscriptions__c
                                                       FROM PRM_Registration_Request__c
                                                       WHERE Id =: requestIds WITH SECURITY_ENFORCED]){
                                                           //Generate payload using request
                                                           json = GeneratePayload(request, erpmSFSettingMap);
                                                           //Call eRPM setprofile v2 api only if payload is formed
                                                           if(string.IsNotBlank(json)) {
                                                               ExecuteAPI(json, request.Id, Label.eRPMSetProfileApigeeUrl);                                                  
                                                           }                                                                                                                                                       
                                                       }
        }
    }
    
    //Method generates json payload using registration request and metadata
    private static string GeneratePayload(PRM_Registration_Request__c request, Map<string, ERPMSFEngagementSetting__mdt> erpmSFMap) {
        Ent_Reg_eRPMApiModel.payload inputModel = new Ent_Reg_eRPMApiModel.payload();
        Ent_Reg_eRPMApiModel.PersonAccountProfile pAcctProfile = new Ent_Reg_eRPMApiModel.PersonAccountProfile();
        string requestValue = '';
        string payload = '';
        try {            
            //Basic profile information
            pAcctProfile.FirstName = request.PRM_First_Name__c;
            pAcctProfile.LastName = request.PRM_Last_Name__c;
            pAcctProfile.EmailID = request.PRM_Email_ID__c;
            pAcctProfile.JobFunction = request.PRM_Job_Function__c;
            pAcctProfile.LanguageCode = request.PRM_Preferred_Language__c;
            pAcctProfile.ExternalAttributes.ProfessionCode=request.PRM_Profession__c ;
        
            //Person physical address
            if(String.isNotBlank(request.PRM_Country__c)) {            
                Ent_Reg_eRPMApiModel.PersonPhysicalAddresses phyAddr =new Ent_Reg_eRPMApiModel.PersonPhysicalAddresses(request.PRM_Address_Line_1__c, request.PRM_City__c, 
                                                                         request.PRM_State_Province__c, request.PRM_Country__c, request.PRM_Zip_Postal_Code__c);
                pAcctProfile.PersonPhysicalAddresses.add(phyAddr);
            }
            //Person electronic address
            if(request.PRM_Person_Phone_Number__c != null) {
                pAcctProfile.PersonElectronicAddresses.add(new Ent_Reg_eRPMApiModel.PersonElectronicAddresses('PHONE', request.PRM_Person_Phone_Number__c));
            }
            
            //Identify if it entitlement based or program based and assign request value accordingly
            if(request.Entitlement_Details__c != null) {
                requestValue = request.Entitlement_Details__r.Name;
            }
            else if(request.PRM_Channel_Program__c != null) {
                requestValue = request.PRM_Channel_Program__r.Name;
            }
            
            //Check if metadata is available for given entitlement or program 
            if(String.isNotBlank(requestValue) && erpmSFMap.get(requestValue) != null) {
                //Fetch engagement from Custom metadata which stores entitlement/program to engagement mapping
                pAcctProfile.Memberships.add(new Ent_Reg_eRPMApiModel.Memberships(erpmSFMap.get(requestValue).Code__c,'ENGSTSAPRD'));
                //Subscriptions
                if(String.isNotBlank(request.PRM_Subscriptions__c)) {
                    pAcctProfile.Subscriptions = BuildSubscriptions(request.PRM_Subscriptions__c, erpmSFMap.get(requestValue).Code__c);
                }
                //Notify
                inputModel.blnNotify = erpmSFMap.get(requestValue).Notify__c;
            }//Returing empty payload if metadata is not found
            else {
                ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
                custEx.Message = 'Metadata information not found for '+requestValue;
                ER_ErrorUtility.createLogEntry('GeneratePayload', custEx, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, request.Id);
                return payload;
            }
            inputModel.PersonAccountProfile = pAcctProfile;
           
            payload = JSON.serialize(inputModel);
            //Exception class code coverage
            if(Test.isRunningTest() && request.Name == 'RDCAck2Exception'){
                throw new ER_ErrorUtility.CustomException('Empty');
            }
        }
        catch(Exception ex){
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
                       
            ER_ErrorUtility.createLogEntry('Error in GeneratePayload', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, request.Id);            
        }
        return payload;
    }
    
    //Build subscriptions from registration request object
    private static List<Ent_Reg_eRPMApiModel.Subscription> BuildSubscriptions(string subscriptions, string engagementCode)
    {
        List<Ent_Reg_eRPMApiModel.Subscription> psnSub = new List<Ent_Reg_eRPMApiModel.Subscription>();
        for(string sub : subscriptions.split(';'))
        {
            Ent_Reg_eRPMApiModel.Subscription psnSubscription = new Ent_Reg_eRPMApiModel.Subscription();
            psnSubscription.SubscriptionCode = sub;
            psnSubscription.SubscriptionStatusCode = 'USER-SUB';
            psnSubscription.EngagementCode = engagementCode;
            psnSub.add(psnSubscription);
        }       
        return psnSub;
    }
    
    @future(callout=true)
    global static void ExecuteAPI(string json, Id requestId, string url) {
        
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        string params = requestId;
        try {
            HttpRequest httpReq = new HttpRequest();
            HttpResponse response = new HttpResponse();
            //callout:<named credential><api endpoint>
            httpReq.setEndpoint(url);
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type','application/json');  
            httpReq.setTimeout(Integer.valueOf(Label.APIGEETimeout));
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