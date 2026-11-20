/******************************************************************************************************************************************
Class Name  : Core_ERPM_API_Callout
Version     : 1.0
Created Date: 26 SEP 2022
Owner    : Team Draco
Function    : Logic for Assigning ERPM Engagements via the API call upon assignment of certain 2.0 Entitlements   

Modification Log :
* Developer                   Date                    Description
* ----------------------------------------------------------------------------
* Akshay Bhimrao More        26-SEP-2022             Original version
* Shreyas Sanghai	         17-JULY-2023            Added logic to send Subscription details in the Payload to ERPM
*****************************************************************************************************************************************/

global  without sharing class Core_ERPM_API_Callout {
    public static final String LOG_ENTRY_ORIGIN    = 'SFDC';
    public static final String LOG_ENTRY_PROJECT    = 'Entitlement';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'Set-Profile API Call to ERPM';
    
    @InvocableMethod(label='Core ERPM API Callout for Engagement' description='Assign ERPM Engagement of DZS upon assignment of DZP' category= 'Entitlement')
    public static void assignERPMEngagements(List<String> ContactIdEntitlementName) {        
        string json = '';
        Map<string, ERPMSFEngagementSetting__mdt> erpmSFSettingMap = new Map<string, ERPMSFEngagementSetting__mdt>();
        
        //Custom metadata to store entitlement/program to engagement mapping
        for(ERPMSFEngagementSetting__mdt mdt : [SELECT MasterLabel, EntitlementProgName__c, Code__c, Notify__c,core_removalRequired__c FROM ERPMSFEngagementSetting__mdt WHERE Core_Source__c IN ('Salesforce','Both')]) {
            erpmSFSettingMap.put(mdt.MasterLabel,mdt);
        }
        
        //Process the input string and seperate the contact Id and Entitlement Name
        Id contactId;
        String entitlementName = '';
        Boolean selected;
        Map<Id, List<String>> conIdEntitlMap = new Map<Id, List<String>>();
        for(String conEnt : ContactIdEntitlementName){
            contactId = (Id)conEnt.split('-->')[0];
            entitlementName = conEnt.split('-->')[1];
            selected=Boolean.valueOf(conEnt.split('-->')[2]);
            
            if(conIdEntitlMap.containsKey(contactId)){
                conIdEntitlMap.get(contactId).add(entitlementName);
            }
            else{
                conIdEntitlMap.put(contactId, new List<String>{entitlementName});
            }
        }
        
        List<Contact> conListAPI = [SELECT Id, FirstName, LastName, Email, Core_Job_Function__c, Core_Preferred_Language__c, Core_Profession__c, 
                                    Core_Account_Primary_Country__c,Core_Account_Primary_Street__c ,Core_Account_Primary_City__c, MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,
                                    Core_Account_Primary_State__c, Core_Account_Primary_Postal_Code__c,Phone,Core_Do_Not_Contact__c, Core_Login_Status__c,
                                    (SELECT PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.Name,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c FROM Contact_Subscription_Associations__r WHERE PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c=false)
                                    FROM Contact
                                    WHERE Id =: conIdEntitlMap.keySet()];
        
        //Get Contact details using ContactId
        for(Contact con : conListAPI){
            // Make Set-Profile API call ONLY if the user is Active OR the call is being made for Assignment (specifically for UIOLI)
            if(con.Core_Login_Status__c == 'Active' || String.isBlank(con.Core_Login_Status__c) || selected){
                //Generate payload using Contact
                json = GeneratePayload(con, erpmSFSettingMap, conIdEntitlMap.get(con.Id),selected);
                //Call eRPM setprofile v2 api only if payload is formed
                if(string.IsNotBlank(json)) {
                    ExecuteAPI(json, con.Id, con.Email, conIdEntitlMap.get(con.Id));                                                  
                }  
            }                                                                                                                                                        
        }                                                      
    }
    
    //Method generates json payload using registration request and metadata
    private static string GeneratePayload(Contact con, Map<string, ERPMSFEngagementSetting__mdt> erpmSFMap, List<String> entitlementName,Boolean selected) {
        Ent_Reg_eRPMApiModel.payload inputModel = new Ent_Reg_eRPMApiModel.payload();
        Ent_Reg_eRPMApiModel.PersonAccountProfile pAcctProfile = new Ent_Reg_eRPMApiModel.PersonAccountProfile();
        string payload = '';
        try {
            //Basic profile information
            pAcctProfile.FirstName = con.FirstName;
            pAcctProfile.LastName = con.LastName;
            pAcctProfile.EmailID = con.Email;
            pAcctProfile.JobFunction = con.Core_Job_Function__c;
            pAcctProfile.LanguageCode = con.Core_Preferred_Language__c;
            pAcctProfile.ExternalAttributes.ProfessionCode = con.Core_Profession__c;
            
            //Person physical address
            if(String.isNotBlank(con.MailingCountry)) {  
                String CountryCodeISO2 = getISO2CountryCode(con.MailingCountry) != null ? getISO2CountryCode(con.MailingCountry) : con.MailingCountry;
                Ent_Reg_eRPMApiModel.PersonPhysicalAddresses phyAddr =new Ent_Reg_eRPMApiModel.PersonPhysicalAddresses(con.MailingStreet , con.MailingCity,con.MailingState,CountryCodeISO2, con.MailingPostalCode);
                pAcctProfile.PersonPhysicalAddresses.add(phyAddr);
            }
            //Person electronic address
            if(con.Phone != null) {
                pAcctProfile.PersonElectronicAddresses.add(new Ent_Reg_eRPMApiModel.PersonElectronicAddresses('PHONE', con.Phone));
            }
            
            //Get the Engagement name for the Entitlement turned to TRUE-Complete state
            inputModel.blnNotify = true;
            if(entitlementName.size() != 0) {
                //Fetch engagement from Custom metadata which stores entitlement/program to engagement mapping
                for(String ent : entitlementName){
                    for(String engsettings :erpmSFMap.keyset()){
                        if(ent.equals(erpmSFMap.get(engsettings).EntitlementProgName__c) && selected ){
                            pAcctProfile.Memberships.add(new Ent_Reg_eRPMApiModel.Memberships(erpmSFMap.get(engsettings).Code__c,'ENGSTSAPRD'));  
                        }
                        if(ent.equals(erpmSFMap.get(engsettings).EntitlementProgName__c) && (!selected && erpmSFMap.get(engsettings).core_removalRequired__c)){
                            pAcctProfile.Memberships.add(new Ent_Reg_eRPMApiModel.Memberships(erpmSFMap.get(engsettings).Code__c,'ENGSTSRJTD'));  
                        }
                        if(ent.equals(erpmSFMap.get(engsettings).EntitlementProgName__c) && (!selected && !erpmSFMap.get(engsettings).core_removalRequired__c)){
                            //system.debug('Entitlement unselected but removal is not required.'); 
                        }
                        
                        if(erpmSFMap.get(engsettings).Notify__c == false){
                            inputModel.blnNotify = false;
                        }
                    }
                } 
            }
            
            for(PRM_ContactSubscriptionAssociation__c contSub : con.Contact_Subscription_Associations__r ){
                Ent_Reg_eRPMApiModel.Subscription psnSubscription = new Ent_Reg_eRPMApiModel.Subscription();
                psnSubscription.SubscriptionCode = contSub.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
                //psnSubscription.SubscriptionName = contSub.PRM_Partner_Subscription_Id__r.Name;
                if(con.Core_Do_Not_Contact__c){
                    psnSubscription.SubscriptionStatusCode = 'USER-UNSUB';
                }
                else{
                    psnSubscription.SubscriptionStatusCode = contSub.PRM_Status_Nm__c == 'Active' ? 'USER-SUB' :'USER-UNSUB';
                }
                pAcctProfile.Subscriptions.add(psnSubscription);
            }
            
            inputModel.PersonAccountProfile = pAcctProfile;
            payload = JSON.serialize(inputModel);
            if(Test.isRunningTest() && con.Email == 'test_rdcuser44@mailinator.com'){
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
            createLogEntry('Error in GeneratePayload', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, con.Id, null, null);            
        }
        return payload;
    }
    
    @future(callout=true)
    global static void ExecuteAPI(string json, Id requestId, string conEmail, List<String> entitlementList) {
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        string tags = requestId + ', Email: ' + conEmail;
        try {
            HttpRequest httpReq = new HttpRequest();
            HttpResponse response = new HttpResponse();
            //callout:<named credential><api endpoint>
            httpReq.setEndpoint('callout:APIGEE_A_E_Get_Roles/m2r/erpm/v1/profiles/set-profiles');
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type','application/json');  
            httpReq.setTimeout(Integer.valueOf(Label.APIGEETimeout));
            httpReq.setBody(json);
            response = new Http().send(httpReq);           
            custEx.Message = response.getBody();
            createLogEntry('Set-Profile API Call made to ERPM - Result: Success', custEx, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, tags, entitlementList, json);                    
        }
        catch(Exception ex){
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
            createLogEntry('Set-Profile API Call made to ERPM - Result: Error', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, tags, entitlementList, json);
        }    
    }
    
    public static String getISO2CountryCode (String countrycode) {
        List<Core_Country_Code_Mapping__c> lcs = Core_Country_Code_Mapping__c.getall().values();
        
        if(lcs != null && lcs.size() > 0) {
            for(Core_Country_Code_Mapping__c cs : lcs) {
                if(cs.ISO_Code__c == countrycode) {
                    return cs.Country_Code__c;
                }
            }
            return null;
        } else {
            return null;
        }
    }
    
    public static void createLogEntry(String Msg, ER_ErrorUtility.CustomException ex, String Severity, String scope, String params, List<String> entitlementList, String json){
        try{         
            String strDetailsAndEx = '';
            Id recordId = null;
            
            if( ex != null ) {
                strDetailsAndEx += 'Response from ERPM: ' + ex.Message + '\n \n';
                strDetailsAndEx += 'API Call made upon status turning to Complete of: ' + entitlementList + '\n \n ' + json;
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = scope,
                Core_Severity__c = Severity,
                Core_Message__c = Msg,
                Core_When__c = system.now(),
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = params
            );
            if(Schema.sObjectType.Core_Log_Entry__c.isCreateable())
            {insert objCLE;}
            
        }catch(Exception e){
        }
    }
}