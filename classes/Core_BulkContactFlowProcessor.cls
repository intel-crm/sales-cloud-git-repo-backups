public without sharing class Core_BulkContactFlowProcessor {
    public class Request {
        @InvocableVariable
        public String contactIdsJson;
        @InvocableVariable
        public String operationType;
        @InvocableVariable
        public String oldContactMapJson;
    }
    @InvocableMethod(label='Process Bulk Contact Flow' description='This method will be called by the Bulk Contact Flow to process the contact records in bulk')
    public static void processBulkContactFlow(List<Request> request) {
        try{
            Set<Id> allContactIds = new Set<Id>();
            if(request != null && !request.isEmpty()){
                Request req = request[0];
                List<Id> contactIds = (List<Id>) System.Json.deserialize(req.contactIdsJson, List<Id>.class);
                allContactIds.addAll(contactIds);
                Map<Id, Contact> oldContactMap = (Map<Id, Contact>) System.Json.deserialize(req.oldContactMapJson, Map<Id, Contact>.class);
                processIntegrationQueue(allContactIds, req.operationType, oldContactMap);
            }
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('Core_BulkContactFlowProcessor', 'processBulkContactFlow', 
                               'Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString(), null);
        }
    }

    public static void processIntegrationQueue(Set<Id> contactIds, String operationType, Map<Id, Contact> oldContactMap) {
        try{
            System.debug('$$ContacId '+contactIds);
            if(contactIds != null && !contactIds.isEmpty()){
                List<Contact> contacts = [SELECT Id, AccountId, LastName, FirstName, Salutation, Name, RecordTypeId, 
                MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingStateCode, MailingCountryCode, MailingAddress, 
                Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, Email, Title, Department, LeadSource, Birthdate, Description, DoNotCall, 
                LastModifiedDate, Core_AGS_Integration_Message__c, Core_IPA_One_Partner_Id__c, Core_Country_Region__c, Core_IPS_By_Pass_Validation__c, 
                Core_eRPM_Language_Code__c, Core_Profiled_Engagements_Count__c, Core_AGS_Integration_Status__c, Core_Contact_B2B_Indicator__c, 
                Core_ERPM_Integration_Message__c, Core_ERPM_Integration_Status__c, Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, 
                Core_Enterprise_Id__c, Core_Identity_Status__c, Core_Login_Status__c, Core_Personal_Email_Indicator__c, Core_Tokenized__c, 
                Core_Set_ERPM_Status_Bypass__c, Core_Address_Line_1__c, Core_Alt_Language_Address_1__c, Core_Alt_Language_Address_2__c, Core_Alt_Language_City__c, 
                Core_Alt_Language_Postal_Code__c, Core_Alt_Language_country__c, Core_Central_Block__c, Core_City__c, Core_Deactivated__c, Core_Deactivation_Reason__c, 
                Core_Do_Not_Contact__c, Core_Job_Function__c, Core_Lead_Conversion_Flag__c, Core_LinkedIN__c, Core_Local_First_Name__c, Core_Local_Last_Name__c, 
                Core_Login_Id__c, Core_Preferred_Communication__c, Core_State__c, Core_Zip_Code__c, Core_Business_ID__c, Core_Engagement_Name__c, 
                Core_Job_Function_Code__c, Core_Language__c, Core_Points_Benefit_Admin__c, Core_Primary_Contact__c, Core_eRPM_Person_Id__c, Core_Account_Legal_Name__c, 
                Core_Account_Primary_City__c, Core_Account_Primary_Country__c, Core_Account_Primary_Postal_Code__c, Core_Account_Primary_State__c, 
                Core_Account_Primary_Street__c, Core_Account__c, Core_Status__c, Core_IPS_Active__c, Core_IPS_Email_Opt_Out__c, Core_IPS_Intel_Support_Owner__c, 
                Core_IPS_NDA_Acceptance_Date__c, Core_Old_Email__c, Core_Account_Changeable__c, Core_Republish_OBM_s__c, Core_AGS_Pending_Time__c, 
                Core_AGS_Status_Change_Date_Time__c, Core_Duration__c, Core_ERPM_Pending_Time__c, Core_ERPM_Status_Change_Date_Time__c, Contact_ID__c, 
                Core_ERPM_Integration_Publish_Timestamp__c, Core_AGS_Duration__c, Core_ERPM_Duration__c, Core_Email_Domain__c, Core_IPS_Employee_Customer__c, 
                Core_IPS_Region__c, Core_IPS_Sub_Region__c, Core_IPS_Is_Contact_Check__c, Core_IPS_Alternate_Support_Org__c, Core_IPS_Alternate_Support_Owner__c, 
                Core_Audience_List__c, Core_Audience__c, Core_MINDS__c, Core_ERPM_Integration_Queue_txt__c, Core_IPA_Contact_Segment__c, Core_IPA_Email_Verification_Date__c, 
                Core_IPA_Intel_Last_Login_Date__c, Core_IPA_Partner_Role__c, Core_Preferred_Language__c, Core_Marketing_Score1__c, Core_IPA_Partner_Community__c, 
                Core_IPA_PartnerRole__c, Core_AGS_Inactive__c, Core_AGS_Republish_Ind__c, PRM_IPA_Integration_Status__c, Core_Deletion_Reason__c, Core_Pronouns__c, 
                Core_IPS_Embargoed_State__c, Core_IPS_State__c, Core_Contacts_for_Marketing__c, Core_Account_Primary_Name__c, Core_Do_Not_Contact_Dtm__c, 
                Core_Marketing_Do_Not_Contact_Dtm__c, Core_Sales_Do_Not_Contact_Ind__c, Core_LS_Company_Name__c, Core_Profession__c, Username__c, 
                Core_Contact_Export_Compliance_Block__c, Core_Con_Export_Compliance_Block_Reason__c, Core_Is_FederationId_Valid_Ind__c, Core_User_Status__c, 
                Core_isEmailBounced_Ind__c, PRM_Community_Change_Agent__c, PRM_Community_History__c, External_User_State_Change_Date_Times__c, External_User_State__c, 
                Core_AGS_Retry_Count__c, Core_Entitlement_Assignment_Message__c, Core_Entitlement_Assignment_Status__c, Core_Entitlement_Status_Change_Date_Time__c, 
                Contacts_Fields_Merged__c, Mailing_Country_Region__c, PIPL_Consent_Date__c, Core_Contact_Marketing_Status__c  FROM Contact WHERE Id IN :contactIds];
                if(!contacts.isEmpty()){
                    Core_IntegrationQueueService.createQueueRecords(contacts, oldContactMap , operationType);
                }
            }
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('Core_BulkContactFlowProcessor', 'processIntegrationQueue', 
                               'Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString(), null);
        }
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
}