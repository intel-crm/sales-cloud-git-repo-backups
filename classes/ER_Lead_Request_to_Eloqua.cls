/**************************************************************************************
Apex Class Name : ER_Lead_Request_to_Eloqua
Version     : 1.0 
Created Date: 29/11/2021
Description : Creating Lead from Registration record
* Modification Log :
* Developer                 Date                     Description
* ---------------------------------------------------------------------------- 
* Gaurav Kurwade          29/11/2021               Original Version
*************************************************************************************/

public with Sharing class ER_Lead_Request_to_Eloqua{
    
    
    Public PRM_Registration_Request__c registerUserDetails;
    
    @AuraEnabled
    public static String submitRegistrationDetails(String requestId){  
        List<Core_Lead_Staging__c> leadStageObj = new List<Core_Lead_Staging__c>();
        PRM_Registration_Request__c registerUserDetails;
        String leadObjectId;
        if(!String.isBlank(requestId))
        {	
            String escapeRequestId = String.escapeSingleQuotes(requestId);
            registerUserDetails = new PRM_Registration_Request__c();    
            if(Schema.sObjectType.PRM_Registration_Request__c.isAccessible())
            {
                registerUserDetails = [Select id,PRM_State_Province__c,PRM_Person_Phone_Number__c,PRM_Profession__c, Project_Description__c,Countries__c,
                                       PRM_Country__c,PRM_Account_Name__c, PRM_Last_Name__c,PRM_First_Name__c, PRM_Address_Line_2__c, PRM_Review_Note_txt__c,
                                       Account_ID__c,PRM_Contact_Salesforce_Id__c,PRM_Email_ID__c,PRM_City__c,PRM_Zip_Postal_Code__c,PRM_Address_Line_1__c,
                                       Project_Timeframe__c,Project_Size__c,PRM_Contact_Login_ID__c,Job_Title__c from PRM_Registration_Request__c where id=: escapeRequestId];
            }
            String leadEmail = registerUserDetails.PRM_Email_ID__c;
            //if(Schema.sObjectType.Core_Lead_Staging__c.isAccessible()){
                if((!String.isBlank(leadEmail)) && Schema.sObjectType.Core_Lead_Staging__c.isAccessible())
                {
                    leadStageObj = [Select id, Core_Email__c from Core_Lead_Staging__c where Core_Email__c=: leadEmail];
                }
                 
                  return leadStageObj.size() == 0? setToLeadStageObj(registerUserDetails):null;
        }
        return leadObjectId;
    }
    
    
    public static String setToLeadStageObj(PRM_Registration_Request__c registerUserDetails){
        
        String userDetailsBody = '{"fieldValues": ';
        List<JsonSerializer> JsonSerializerList = new List<JsonSerializer>();
        Map<String, ER_Core_Eloqua_Integration_for_Lead__mdt> eloquaIntMap = new Map<String, ER_Core_Eloqua_Integration_for_Lead__mdt>();
        if(Schema.sObjectType.ER_Core_Eloqua_Integration_for_Lead__mdt.isAccessible()){
            List<ER_Core_Eloqua_Integration_for_Lead__mdt> eloquaIntList = [select Id, MasterLabel, DeveloperName, Core_Value__c from ER_Core_Eloqua_Integration_for_Lead__mdt];

            for(ER_Core_Eloqua_Integration_for_Lead__mdt eloquaInt : eloquaIntList){
                eloquaIntMap.put(eloquaInt.DeveloperName, eloquaInt);
            }
        }
        Core_Lead_Staging__c leadStageObj = new Core_Lead_Staging__c();
        JsonSerializer js;
        String value;
        for(String eloquaInt : eloquaIntMap.keyset()){
            js = new JsonSerializer();
            js.type = 'FieldValue';
            js.id = eloquaIntMap.get(eloquaInt).MasterLabel;
            value = eloquaIntMap.get(eloquaInt).Core_Value__c;
            if(eloquaInt.equalsIgnoreCase('firstName') && registerUserDetails.PRM_First_Name__c <> null){
                js.value = registerUserDetails.PRM_First_Name__c;
                leadStageObj.Core_First_Name__c = registerUserDetails.PRM_First_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('lastName') && registerUserDetails.PRM_Last_Name__c <> null){
                js.value = registerUserDetails.PRM_Last_Name__c;
                leadStageObj.Core_Last_Name__c = registerUserDetails.PRM_Last_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('companyName') && registerUserDetails.PRM_Account_Name__c <> null){
                js.value = registerUserDetails.PRM_Account_Name__c;
                leadStageObj.Core_Company__c = registerUserDetails.PRM_Account_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('country') && registerUserDetails.PRM_Country__c <> null){
                js.value = registerUserDetails.Countries__c;
                leadStageObj.Core_Country__c = registerUserDetails.Countries__c;
            }
            if(eloquaInt.equalsIgnoreCase('state') && registerUserDetails.PRM_State_Province__c <> null){
                js.value = registerUserDetails.PRM_State_Province__c;
                leadStageObj.Core_State__c = registerUserDetails.PRM_State_Province__c;
            }
            if(eloquaInt.equalsIgnoreCase('email') && registerUserDetails.PRM_Email_ID__c <> null){
                js.value = registerUserDetails.PRM_Email_ID__c;
                leadStageObj.Core_Email__c = registerUserDetails.PRM_Email_ID__c;
            }
            if(eloquaInt.equalsIgnoreCase('phone') && registerUserDetails.PRM_Person_Phone_Number__c <> null){
                js.value = registerUserDetails.PRM_Person_Phone_Number__c;
                leadStageObj.Core_Business_Phone__c = registerUserDetails.PRM_Person_Phone_Number__c;
            }
            
            if(eloquaInt.equalsIgnoreCase('Profession') && registerUserDetails.PRM_Profession__c <> null){
                js.value =registerUserDetails.PRM_Profession__c;
                leadStageObj.Core_Profession__c = registerUserDetails.PRM_Profession__c;
            }
            
            /*             if(eloquaInt.equalsIgnoreCase('LeadFormSubmitDate')){
js.value = String.valueOf(system.now());
leadStageObj.Core_Lead_Form_Submit_Date__c = system.now();
}
*/ 
            if(eloquaInt.equalsIgnoreCase('City')){
                js.value = registerUserDetails.PRM_City__c;
                //  leadStageObj.City__c = registerUserDetails.PRM_City__c;
            }
            if(eloquaInt.equalsIgnoreCase('zip')){
                js.value = registerUserDetails.PRM_Zip_Postal_Code__c;
                //   leadStageObj.Zip_Postal_Code__c = registerUserDetails.PRM_Zip_Postal_Code__c;
            }
            if(eloquaInt.equalsIgnoreCase('Address')){
                js.value = registerUserDetails.PRM_Address_Line_1__c;
                //    leadStageObj.Address__c = registerUserDetails.PRM_Address_Line_1__c;
            }
            if(eloquaInt.equalsIgnoreCase('leadSource')){
                js.value = value;
                leadStageObj.Core_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('leadConversionPoint')){
                js.value = value;
                leadStageObj.Core_Lead_Conversion_Point__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sfdcCampaignID')){
                js.value = value;
                leadStageObj.Core_MktCampaign_Id__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('marketingTacticID')){
                js.value = value;
                leadStageObj.Core_Marketing_Tactic_ID__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sourceID')){
                js.value = value;
                leadStageObj.Core_Source_Id__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('LeadAction')){
                js.value = value;
                leadStageObj.Core_Lead_PMP_Action__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('LeadNotes')){       
                js.value = value+'; \n Registration Comment : '+(registerUserDetails.PRM_Review_Note_txt__c != null ? registerUserDetails.PRM_Review_Note_txt__c:'')+ '; \n Project Description : ' +(registerUserDetails.Project_Description__c != null ? registerUserDetails.Project_Description__c:'');
                leadStageObj.Core_Lead_Notes__c = value+'; \n Registration Comment : '+(registerUserDetails.PRM_Review_Note_txt__c != null ? registerUserDetails.PRM_Review_Note_txt__c:'')+ '; \n Project Description : ' +(registerUserDetails.Project_Description__c != null ? registerUserDetails.Project_Description__c:'');         
            }
            /*    if(eloquaInt.equalsIgnoreCase('Industry')){
js.value = value;
leadStageObj.Industry__c = value;
}
*/
            if(eloquaInt.equalsIgnoreCase('Address2')){
                js.value = registerUserDetails.PRM_Address_Line_2__c;
            }
            if(eloquaInt.equalsIgnoreCase('Address3')){
                js.value = null;
            }
            if(eloquaInt.equalsIgnoreCase('ProjectTimeFrame')){
                js.value = registerUserDetails.Project_Timeframe__c;
                //   leadStageObj.Core_Project_Timeframe__c = registerUserDetails.Project_Timeframe__c;
            }
            if(eloquaInt.equalsIgnoreCase('ProjectSize')){
                js.value = registerUserDetails.Project_Size__c;
                //    leadStageObj.Core_Project_Size__c = registerUserDetails.Project_Size__c;
            }
            if(eloquaInt.equalsIgnoreCase('have_rep_contact_me')){
                js.value = value;
            }
            
            if(eloquaInt.equalsIgnoreCase('job_title')){
                js.value = registerUserDetails.Job_Title__c;
            }
            
            
            if(js.value <> null){
                JsonSerializerList.add(js);
            }
        }
        
        String serializeData = JSON.serialize(JsonSerializerList);
        userDetailsBody = userDetailsBody + serializeData + '}';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HTTPResponse httpResp = new HTTPResponse();
        
        httpReq.setEndpoint('callout:DZP_LeadCreation_EloquaIntegration'); 
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setTimeout(120000);
        httpReq.setBody(userDetailsBody);
        httpResp = http.send(httpReq);
        
        //  sendEmailNotification(formType,leadStageObj,offeringName,partnerName);
        
        if(httpResp.getStatusCode() == 201){
            leadStageObj.Core_Status__c = 'Success';
        }else{
            leadStageObj.Core_Status__c = 'Failed';
            leadStageObj.Core_Eloqua_Error__c = httpResp.getBody();
        }
        if(Schema.sObjectType.Core_Lead_Staging__c.isCreateable()){
            insert leadStageObj;
        }
        
        return leadStageObj.id;
    }
    
    public class JsonSerializer{
        public String type;
        public String id;
        public String value;
    }
    
}