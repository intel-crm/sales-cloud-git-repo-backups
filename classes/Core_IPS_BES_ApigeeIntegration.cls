public class Core_IPS_BES_ApigeeIntegration {
    
    public Static MessageStatus sendJSONBody(String jSONString){
        String status='';
        Integer statusCode;
        Transient MessageStatus msgStatus;
        try{
           /* //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
            HttpRequest request = new HttpRequest();
            //request.setEndpoint(Label.Core_Apigee_EndPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type','application/x-www-form-urlencoded');
            Map<String,String> body = new Map<String,String>();
            //String paylod = 'grant_type=client_credentials&client_id='+ Label.Core_Apigee_ClientId +'&'+'client_secret='+ Label.Core_Apigee_client_secret;
            //request.setBody(paylod);
            Http http = new Http(); 
            HTTPResponse res = http.send(request);
            statusCode = res.getStatusCode();
            */ //changes made as part of the Namecredentials changes
            //if(res.getStatusCode() == 200){  
             //   map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(res.getBody());
                
               // String authorizationHeader = 'Bearer ' + (String) resultMap.get('access_token');
               String endpoint = 'callout:Core_IPS_BES_ApigeeIntegration_NewBackendSystem'; //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
                HttpRequest req = new HttpRequest();
                req.setTimeout(120000);
                req.setEndpoint(endpoint);
                //req.setEndpoint(Label.Core_Apigee_CaseEndPoint);
                req.setMethod('POST');
                //req.setHeader(Label.Core_Apigee_Auth, authorizationHeader);

                req.setHeader('Content-Type','application/json');
                //req.setBody('[{"Operation":{"Operation":"Promote"},"System Details":{"Message Id":"001","Source System":"IPS","Target system":"HSDES:fpga:bug","Additional Information":""},"Issue Information":{"case_type":"Feature Request","priority_reason":"","escalated_level":"Level 1  Front Line","customer_reference_id":"","knowledge_base_link":"","case_closure_details":"","end_customer":"","contact_name":"Test IPS Contact am","legacy_id":"","sub_region":"IJKK","last_assigned_queue":"IPS - Unassigned Cases","bug_doc_fix_id":"","backend_id":"","partner_supported_account":"","created_by":"Karthick","severity":"Low","case_owner_email":"","backend_system":"","severity_reason":"","remove_notification_details":"false","support_level":"ROW","system_owner":"","case_co-owner":"","account_name":"Test IPS Account am - Dont check MAG","minds_use":"false","promote_status":"","case_closure":"Enhancement Request","support_org":"Test_Org_000","case_owner":"IPS - Unassigned Cases","partner_support_owner":"0053F000000WxYmQAK","classification":"Intel Confidential","gec":"false","customer_visible":"true","age_in_days":"77.7","last_update":"","created_date":"2018-04-02 12:23:17","intel_support_owner":"005o0000004Mt6HAAS","case_source":"na","subcategory":"","category":"Design Tools","priority":"Low","sub_status":"","status":"New","product_name":"Skylake","contact_email":"ipsemail123@gmail.com","project_id":"IPJ-005022","description":"test","subject":"testranjini12345 ","case_number":"00211271","account_billing_street":"Lane","account_id":"0013F000004LibYQAS","account_billing_country":"FSM","account_billing_city":"San Jose","account_billing_state":"TRK","account_cim_id":"987654"}}]');
                //req.setBody('[{"Operation":{"Operation":"Promote"},"System Details":{"Message Id":"001","Source System":"IPS","Target system":"HSDES:fpga:bug","Additional Information":""},"Issue Information":{"account_id":"","legacy_id":"","backend_id":"","promote_status":"","system_owner":"","backend_system":"","case_source":"Customer Interface","created_date":"2018-11-29 08:33:08","created_by":"Banu Ranabahadur","remove_notification_details":"false","knowledge_base_link":"","bug_doc_fix_id":"","case_closure_details":"","case_closure":"","escalated_level":"Level 1 / Front Line","last_update":"0.0","age_in_days":"580.2","gec":"false","minds_use":"false","partner_support_owner":"0053F000000WxYmQAK","partner_supported_account":"0013F000004LibYQAS","customer_reference_id":"","end_customer":"","project_id":"IPJ-006042","customer_visible":"true","classification":"Intel Confidential","sub_region":"ROA","support_level":"ROW","priority_reason":"","priority":"Low","support_org":"Banu IPS Partner Support Org","last_assigned_queue":"IPS - Unassigned Cases","case_co-owner":"","case_owner_email":"","case_owner":"IPS - Unassigned Cases","description":"Region should be Test IPS Account am - Dont check MAG","subcategory":"","category":"","case_type":"Question","severity_reason":"","severity":"Low","subject":"Region should be Test IPS Account am - Dont check MAG","product_name":"Apollo Lake Mobile","project_name":"Banu Private Project","intel_support_owner":"0053F000000QvzsQAC","contact_email":"aa@mailinator.com","contact_name":"Aayushi Singhal","account_name":"Test IPS Account am - Dont check MAG","sub_status":"","status":"New","case_number":"00216964"}}]');
                req.setBody(JSONString);
                Http http1 = new Http();
                HTTPResponse response = http1.send(req);

                if(response.getStatusCode() == 200){
                    status = 'Apigee Success'; 
                    msgStatus = new MessageStatus(status, response.getStatusCode(), response.getStatus(), response.getBody());
                }else{
                    status = 'Apigee Failed';
                    msgStatus = new MessageStatus(status,response.getStatusCode(),response.getStatus(), response.getBody());
                }
            //}
       // else{
         //        status = 'Apigee Failed';
         //       msgStatus = new MessageStatus(status,res.getStatusCode(),res.getStatus(), res.getBody());
         //   }
        }catch(Exception e){
            status = 'Apigee Failed';
            //Core_Exceptions__c excep=new Core_Exceptions__c(Core_Class_Name__c='Core_IPS_BES_ApigeeIntegration',Core_Method_Name__c = 'sendJSONBody', Core_Exception__c=e.getMessage()+' '+e.getStackTraceString(), Core_Login_User_Id__c=userInfo.getUserId());
            //insert excep;
            // uncommented by Chiru, Previously below line commented
           // Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c = e.getMessage());
           // msgStatus = new MessageStatus(status, 0 ,'',e.getStackTraceString());
            String errorDescription = 'Error Reason : '+ e.getMessage() + '\n' +'Status Code :'+ statusCode + '\n' +'Trace : '+ e.getStackTraceString();
            msgStatus = new MessageStatus(status, 501 ,'',errorDescription); 
        }
        return msgStatus;
    }
    public class MessageStatus{
        public String message;
        public Integer code;
        public String status;
        public String body;
        public MessageStatus(String message, Integer code, String status, String body){
            this.message = message;
            this.code = code;
            this.status = status;
            this.body = body;
        }
        
    }
}