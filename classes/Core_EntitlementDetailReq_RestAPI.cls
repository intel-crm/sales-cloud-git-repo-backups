@SuppressWarnings('PMD')

@RestResource(urlMapping='/EntitlementAutomation')
global without sharing class Core_EntitlementDetailReq_RestAPI {
    /*
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        String reqBody = request.requestbody.tostring();
        RestResponse resp = RestContext.response;
        OutputMessage om = new OutputMessage();
        try {
            if(!String.isEmpty(reqBody)){
                List<EntitlementDetailRequest> entDetReqs = (List<EntitlementDetailRequest>) JSON.deserialize(reqBody, List<EntitlementDetailRequest>.class); 
                //Core_EntitlementDetailReq_Handler.migrateData = True;
                List<Core_Entitlement_Detail_Request__c> coreEntDetReqs = new List<Core_Entitlement_Detail_Request__c>();
                for(EntitlementDetailRequest entDetReq : entDetReqs){
                    Core_Entitlement_Detail_Request__c req = new Core_Entitlement_Detail_Request__c();
                    req.Name = entDetReq.Name;
                    req.Core_Display_Name__c = entDetReq.Core_Display_Name;
                    req.Core_Category__c = entDetReq.Core_Category;
                    req.Core_Sub_Category__c =  entDetReq.Core_Sub_Category;
                    req.Core_Description__c = entDetReq.Core_Description;
                    req.Core_Help_Text__c = entDetReq.Core_Help_Text;
                    req.Core_ERPM_Engagement_Id__c = entDetReq.Core_ERPM_Engagement_Id;
                    req.Core_Engagement_Type__c = entDetReq.Core_Engagement_Type;
                    req.Core_Technical_Engagement_Code__c = entDetReq.Core_Technical_Engagement_Code;
                    req.Core_Technical_DeDup_Number__c = entDetReq.Core_Technical_DeDup_Number;
                    req.Core_AGS_Role_Id__c = entDetReq.Core_AGS_Role_Id;
                    req.Core_Technical_Name__c = entDetReq.Core_Technical_Name;
                    req.Core_Permission_Set_API_Nm__c = entDetReq.Core_Permission_Set_API_Nm;
                    req.Core_Public_Group_API_Nm__c = entDetReq.Core_Public_Group_API_Nm;
                    req.Core_DisplayOnUI__c = entDetReq.Core_DisplayOnUI;
                    req.Core_Applicable_Profiles__c = entDetReq.Core_Applicable_Profiles;
                    req.Core_IsMigrated__c = True;
                    coreEntDetReqs.add(req);
                }
                database.SaveResult[] result = database.insert(coreEntDetReqs, false);           
                if(Core_EntitlementDetailReq_Handler.errorMessages.size() > 0){
                    om.success = false;
                    om.validationErrors = new List<ValidationError>();
                    for(String entName : Core_EntitlementDetailReq_Handler.errorMessages.keySet()){
                        ValidationError err = new ValidationError();
                        err.entitlementName = entName;
                        err.errors = new Set<String>();
                        err.errors.addAll(Core_EntitlementDetailReq_Handler.errorMessages.get(entName));
                        om.validationErrors.add(err);
                    }
                    //om.validationErrors = Core_EntitlementDetailReq_Handler.errorMessages;
                }else {
                    om.success = true;
                } 
            }else {
                om.success = false;
                om.excption = 'Bad input. Please try with proper input data.';
            }
        }catch(Exception ex){
          om.success = false;
          om.excption = 'Error at Line#'+ex.getCause()+'; '+ex.getStackTraceString();  
        }
        //return om;
        resp.responseBody = Blob.valueOf(JSON.serialize(om));
    }
    global class OutputMessage {
        public boolean success {set; get;}
        public String excption {set; get;}
        public List<ValidationError> validationErrors {set; get;}
    }
    public class ValidationError {
        public String entitlementName {set; get;}
        public Set<String> errors {set; get;}
    }
    global static void createOBM(Set<Id> reqIds){
        if(reqIds.size() > 0){
            List<Core_Entitlement_Detail_Request__c> entDetReqs = [SELECT Name,Core_Display_Name__c,Core_Category__c, Core_Sub_Category__c, Core_Description__c, Core_Help_Text__c, Core_ERPM_Engagement_Id__c, Core_Engagement_Type__c, Core_Technical_Engagement_Code__c, Core_Technical_DeDup_Number__c, Core_AGS_Role_Id__c, Core_Technical_Name__c, Core_Permission_Set_API_Nm__c, Core_Public_Group_API_Nm__c, Core_DisplayOnUI__c, Core_Applicable_Profiles__c  FROM Core_Entitlement_Detail_Request__c WHERE Id IN :reqIds]; 
            //List<Core_Integration_Outbound_Message__c> obms = new List<Core_Integration_Outbound_Message__c>();
            if(entDetReqs.size() > 0 ){                
                String tags = '';
                List<EntitlementDetailRequest> reqs = new List<EntitlementDetailRequest>();
                for(Core_Entitlement_Detail_Request__c entDetReq : entDetReqs){
                    EntitlementDetailRequest req = new EntitlementDetailRequest();
                    //tags = String.isEmpty(tags) ? entDetReq.Name: tags+', '+entDetReq.Name;
                    req.Name = entDetReq.Name;
                    req.Core_Display_Name = entDetReq.Core_Display_Name__c;
                    req.Core_Category = entDetReq.Core_Category__c;
                    req.Core_Sub_Category =  entDetReq.Core_Sub_Category__c;
                    req.Core_Description = entDetReq.Core_Description__c;
                    req.Core_Help_Text = entDetReq.Core_Help_Text__c;
                    req.Core_ERPM_Engagement_Id = entDetReq.Core_ERPM_Engagement_Id__c;
                    req.Core_Engagement_Type = entDetReq.Core_Engagement_Type__c;
                    req.Core_Technical_Engagement_Code = entDetReq.Core_Technical_Engagement_Code__c;
                    req.Core_Technical_DeDup_Number = entDetReq.Core_Technical_DeDup_Number__c;
                    req.Core_AGS_Role_Id = entDetReq.Core_AGS_Role_Id__c;
                    req.Core_Technical_Name = entDetReq.Core_Technical_Name__c;
                    req.Core_Permission_Set_API_Nm = entDetReq.Core_Permission_Set_API_Nm__c;
                    req.Core_Public_Group_API_Nm = entDetReq.Core_Public_Group_API_Nm__c;
                    req.Core_DisplayOnUI = entDetReq.Core_DisplayOnUI__c;
                    req.Core_Applicable_Profiles = entDetReq.Core_Applicable_Profiles__c;
                    reqs.add(req);
                }
                Core_Integration_Outbound_Message__c obm = createAndGetOBM('Entitlement Automation', JSON.serialize(reqs), tags );
                insert obm;
                system.debug('OBM Id ===>'+obm.id);
                
               
            }
        }
    }
    private static Core_Integration_Outbound_Message__c createAndGetOBM (String MessageType, String payload, String tags){
        Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
        outboundMsg.Core_MessageType__c = MessageType;
        outboundMsg.Core_Payload__c ='<![CDATA[' +  payload + ']]>';
        outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
        return outboundMsg;
    }
    
    global class EntitlementDetailRequest {
        public String Name {set; get;}
        public String Core_Display_Name {set; get;}
        public String Core_Category {set; get;}
        public String Core_Sub_Category {set; get;}
        public String Core_Description {set; get;}
        public String Core_Help_Text {set; get;}
        public String Core_ERPM_Engagement_Id {set; get;}
        public String Core_Engagement_Type {set; get;}
        public String Core_Technical_Engagement_Code {set; get;}
        public String Core_Technical_DeDup_Number {set; get;}
        public String Core_AGS_Role_Id {set; get;}
        public String Core_Technical_Name {set; get;}
        public String Core_Permission_Set_API_Nm {set; get;}
        public String Core_Public_Group_API_Nm {set; get;}
        public boolean Core_DisplayOnUI {set; get;}
        public String Core_Applicable_Profiles {set; get;}
    }
    */
}