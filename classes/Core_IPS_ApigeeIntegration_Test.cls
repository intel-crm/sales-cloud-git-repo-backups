@isTest	
global class Core_IPS_ApigeeIntegration_Test {
    global static TestMethod void testMethod1(){
        
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, new Core_IPS_ApigeeHttpCalloutMock());
        // Call method to test
        Core_IPS_BES_ApigeeIntegration.MessageStatus status = Core_IPS_BES_ApigeeIntegration.sendJSONBody('[{"system_details":{"message_id":"BES OB-1181","message_type":"Case","source_system":"IPS","target_system":"hsdes:fpga:bug","source_id":"00219732","target_id":"1308659269"},"issue_information":{"account_country":"","account_cim_ultimate_id":"","account_cim_id":"84231098","account_id":"0013F00000Xyc6DQAR","account_billing_postal_code":"560100","account_billing_country":"IND","account_billing_state":"KA","account_billing_city":"Bangalore","account_billing_street":"#41 Cool Street.\r\nElectronic City","hc_next_actions":"","hc_help_needed":"","hc_latest_update":"","hc_executive_summary":"","hc_intel_disposition":"","hc_debug_progress":"","hc_customer_disposition":"","hc_hot_case":"false","legacy_id":"","backend_id":"","promote_status":"Done","system_owner":"","backend_system":"","case_source":"Internal Portal","last_modified_by_email":"farooqx.ahmed@intel.com","last_modified_by":"farooq Ahmed","date_time_last_modified":"2020-09-08 15:08:20","date_time_closed":"","date_time_close_pending":"","created_date":"2020-09-08 14:59:53","created_by_email":"farooqx.ahmed@intel.com","created_by":"farooq Ahmed","remove_notification_details":"false","knowledge_base_link":"","bug_doc_fix_id":"","case_closure_details":"","case_closure":"","date_time_escalated":"","escalated_level":"Level 1 / Front Line","last_update":"0.0","age_in_days":"0.0","gec":"false","minds_use":"false","partner_support_owner":"","partner_supported_account":"0013F00000XeHc3QAF","customer_reference_id":"","end_customer":"","product_variant":"","project_id":"","customer_visible":"false","classification":"Intel Confidential","sub_region":"NAR","region":"ASMO","support_level":"ROW","priority_reason":"","priority":"Medium","support_org":"Programmable Solutions Group","last_assigned_queue":"PSG-Admin","case_co-owner":"","case_owner_email":"","case_owner":"PSG-Admin","description":"Â End-to-End backend integration testing for demo2","subcategory":"Acceleration Boards","category":"Automotive","case_type":"Debug Request","severity_reason":"","severity":"Low","subject":"End-to-EndÂ backend integration testing for demo2","product_name":"IntelÂ® CycloneÂ® FPGA","project_name":"","intel_support_owner":"0053F000005nuSWQAY","contact_email":"contact2.bes@malinator.com","contact_name":"Contact-2 BES","account_name":"BES Account","sub_status":"","status":"New","case_number":"00219732","case_id":"5003F000007S64aQAC","case_subcategory_detail_ab":"Acceleration Boards","ip_product":"Basic Functions/Arithmetic/ALTERA_FP_ACC_CUSTOM","fpga_development_tools":"Quartus II Linux","version":"15.0 Update 2","erma#":"53","erma_rma":"User Fault found","additional_information":"<table><tr><td>account_billing_postal_code</td><td>560100</td></tr><tr><td>account_billing_country</td><td>IND</td></tr><tr><td>account_billing_state</td><td>KA</td></tr><tr><td>account_billing_city</td><td>Bangalore</td></tr><tr><td>account_billing_street</td><td>#41 Cool Street.\r\nElectronic City</td></tr><tr><td>account_name</td><td>BES Account</td></tr></table>"}}]');
        System.assert(status.status =='Success');
    }  
  
    global class Core_IPS_ApigeeHttpCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Success');
            System.assert(response!=null);
            return response; 
        }
    }
}