/******************************************************************************************************************************************
Class Name  : Core_IntegrationUtility
Version     : 1.0
Created Date: 17 NOV 2016
Function    : Classes, utility methods, and constants used in our integration processing

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/17/2016              Original version
* Akshay More [Draco]       22/07/2022              Updated to read Azure Group Response from Mulesoft
*****************************************************************************************************************************************/
global without sharing class Core_IntegrationUtility {

    // Class to hold the XML Person message from ERPM
    public class ERPM_Person {

        public String erpmPersonId     = '';
        public String loginId          = '';
        public String enterpriseId     = '';
        public String identityStatus   = '';
        public String inactIndicator   = '';
        public String isDeleteIndicator= '';

        public String title            = '';
        public String firstName        = '';
        public String lastName         = '';
        public String email            = '';
        public String englishFirstName = '';
        public String englishLastName  = '';

        public String erpmLanguageCode = '';
        public String jobFunctionCode  = '';
        public String doNotContact     = '';//Gireesh:US942207
        public DateTime marketingDoNotContactDate = Null;//Gireesh:US959755
        public DateTime salesDoNotContactDate = Null;//Gireesh:US942207

        public String phone            = '';
        public String mobilePhone      = '';
        public String fax              = '';

        public String mailingStreet1   = '';
        public String mailingStreet2   = '';
        public String mailingStreet3   = '';
        public String mailingStreet4   = '';
        public String mailingCity      = '';
        public String mailingState     = '';
        public String mailingPostalCode= '';
        public String mailingCountry   = '';
        public String externalUserState= '';
        public String externalStateChange = '';

       // public DateTime externalStateChange = null;

        public List<ERPM_Person_Account> personAccounts = new List<ERPM_Person_Account>();

        public List<ERPM_Engagement> personEngagements = new List<ERPM_Engagement>();
        Public ERPM_Person_Attribute Profession = new ERPM_Person_Attribute();

        public Boolean ignoreMessage    = false; // flag we can set to ignore the message completely
        public String ignoreReason      = ''; // reason we ignored it
        public DateTime publishTimestamp= null; // date/time the message was published from ERPM

        // ----------- #REGION :: eRPM Code Changes :: START ------------- //
        public List<eRPM_Subscription> eRPM_Subscriptions = new List<eRPM_Subscription>();
        public String changeAgentId     = '';
        //eRPM - Email Verification date and Last login date
        public String emailVerificationDate = '';
        public String lastLoginDate     = '';
        // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
    }

    // Class to hold the Person-to-Account mapping from ERPM
    public class ERPM_Person_Account {

        public String erpmAccountNumber = '';
        public String cimId             = '';
        public String accountName       = '';
        public String erpmDedupGroupCode= '';
        public String acctSalesCloudID      = '';

        //public ERPM_Person_Account_Relation personAccountRelation = new ERPM_Person_Account_Relation();
        public List<ERPM_Person_Account_Relation> personAccountRelations = new List<ERPM_Person_Account_Relation>();

        public List<ERPM_Engagement> personAccountEngagements = new List<ERPM_Engagement>();
    }

    // Class to hold the Engagement data from ERPM
    public class ERPM_Engagement {
        public String engagementCode       = '';
        public String engagementName       = '';
        public String engagementStatusCode = '';
        public String effectiveTierCode    = '';
        //eRPM-SF integration
        public String tierCode             = '';
        public String engagementStatusReasonCode = '';
        //Added by Quest Team
        public string effEndEngagmentDate='';

    }
    
    public class ERPM_Person_Attribute {
         public String Professioncode       = '';
     
     }

    // Class to hold the Person Account Relationship data from ERPM
    public class ERPM_Person_Account_Relation {
        public String relationCode         = '';
        public String relationName         = '';
        public String engagementCode       = '';
        public String engagementName       = ''; // Isn't in this part of the ERPM message, but will populate based on matching engagement code elsewhere in message
        public String engagementStatusCode = ''; // Isn't in this part of the ERPM message, but will populate based on matching engagement code elsewhere in message
        public String effectiveTierCode    = ''; // Isn't in this part of the ERPM message, but will populate based on matching engagement code elsewhere in message
        //Defaulting to 'N' - ERPM Team added
        public Boolean inactiveIndicator   = false;
        public String status = '';
    }

    // Class to hold the XML Account message from ERPM
    public class ERPM_Account {

        public String erpmAccountNumber = '';
        public String cimId             = '';
        public String sfdcId            = '';
        public String name              = '';
        public String legalName         = '';
        public String enggDedupGroupCode= '';
        public String PrimaryAddrType   = '';
        public String primaryStreet1    = '';
        public String primaryStreet2    = '';
        public String primaryStreet3    = '';
        public String primaryStreet4    = '';
        public String primaryCity       = '';
        public String primaryState      = '';
        public String primaryPostalCode = '';
        public String primaryCountry    = '';

        public String phone             = '';
        public String fax               = '';

        public List<ERPM_Engagement> accountEngagements = new List<ERPM_Engagement>();
        public Boolean ignoreMessage   = false; // flag we can set to ignore the message completely
         public String ignoreReason      = ''; // reason we ignored it
        // ----------- #REGION :: eRPM Code Changes :: START ------------- //


        public List<eRPM_Profile_Response> eRPM_Profile_Responses = new List<eRPM_Profile_Response>();
        public List<eRPM_Benefit> eRPM_Benefits = new List<eRPM_Benefit>();
        public SecondaryAddress secondaryAddress=new SecondaryAddress();
        public boolean eRPM_isITPBenefitCheck=false;

        //eRPM - Store Number Of Employees
        public String employees         = '';
        public String website           = '';
        public String employeeGrp       = '';
        // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
    }

    // Class to hold the ERPM "Blackbox" response -- basically success or failure of our
    // attempt to set up user/entitlements/etc. in ERPM
    public class ERPM_Blackbox_Response {

        // Note: these don't follow our typical naming of lowerCamelCase, since the ERPM response doesn't
        public String Status;
        public String ErrorCode;
        public String ErrorText;
        public String ErrorDetails;

        public String PersonID;
        public String EnterpriseID;
        public String LoginID;
        public String EmailID;

        public List<ERPM_Blackbox_Account> Accounts;
    }

    // Class to hold Account info from the ERPM Blackbox response
    public class ERPM_Blackbox_Account {

        // Note: these don't follow our typical naming of lowerCamelCase, since the ERPM response doesn't
        public String AccountNumber;
        public String CIMID;
        public String SalesCloudID;
    }

    //* Below code changes done by eRPM team to accomadate eRPM to SF integrations *//
    // ----------- #REGION :: eRPM Code Changes :: START ------------- //

     // This is class is to hold the eRPM Benefit and check against SF
     // Added by Manju on 07/09/2019
    public class eRPM_Benefit  {
        public string eRPM_BenefitCode;
        public string eRPM_BenefitEngagementCode;
        public string eRPM_BenefitInactiveIndicator;

        //TODO::REVISIT :: Inactive reason code is present in eRPM but not in SF, hence will decide later
        public string eRPM_Benefit_InactiveReasonCode;
        public string eRPM_Benefit_InactiveReason;
    }
    public class SecondaryAddress
    {
        public String secondaryStreet1    = '';
        public String secondaryStreet2    = '';
        public String secondaryStreet3    = '';
        public String secondaryStreet4    = '';
        public String secondaryCity       = '';
        public String secondaryState      = '';
        public String secondaryPostalCode = '';
        public String secondaryCountry    = '';
    }

    // This is class is to hold the eRPM Subscription and  to check against SF
    // Subcriptions are only at the contact level not at the account level
    public class eRPM_Subscription {
        public string eRPM_SubscriptionCode;
        public string eRPM_SubscriptionStatusCode;
        public string eRPM_EngagementCode;
    }

    // This is class is to hold the eRPM Extended Attributes and to check against SF
    public class eRPM_Profile_Response {
        public string eRPM_QuestionCode;
        public string eRPM_ResponseCode;
        public string eRPM_ResponseText;
    }

    //TODO::REVISIT :: We haven't define any contract for Legal Agreements yet, as we are still in progress of finalizing the approach //


    // ---------- #END REGION :: eRPM Code Changes  :: END ---------- //

    // Class to hold AGS responses -- basically success or failure of our attempt to set AGS roles
    public class AGS_Response {

        public String Id;
        public String enterpriseId;
        public String timestamp;
        public String email;
        public String EmailVerificationToken;
        public String passwordResetToken;
        public String firstName;
        public String lastName;
        public String loginId;
        public String language;
        public String country;
        public String error;
        public DateTime EVupdatedDate;

        public List<AGS_Response_Role> result;
    }

    // Class to hold AGS responses for each role
    public class AGS_Response_Role {

        public String roleName;
        public AGS_Response_Role_Result roleResult;
        public String GroupName;    // Team Draco - Updated to read Azure Group Response from Mulesoft
        public AGS_Response_Group_Result GroupResult;   // Team Draco - Updated to read Azure Group Response from Mulesoft

    }

    // Class to hold AGS role result
    public class AGS_Response_Role_Result {

        public String requestedBy;
        public String identityRequestStatus;
        public String workflowStatus;
        public String identityRequestId;
        public String enterpriseId;
        public String operation;
        public String status;

        public List<AGS_Response_Error> Errors;
    }

    // Class to hold AGS responses for each Group - Team Draco - Updated to read Azure Group Response from Mulesoft
    public class AGS_Response_Group_Result {

        public String status;
        public String operation;
        public String workflowStatus;
        public String error;

        public List<AGS_Response_Error> Errors;
    }

    // Class to hold AGS error messages for each role
    public class AGS_Response_Error {

        public String description;
        public String code;
        public String serviceCode;
        public String sourceSystemCode;
        public String sourceSystemMessage;
        public String requestId;
    }

    public class ERPM_Response_Error{
        public String errorCode;
        public String errorText;
        public String errorDescription;
        public String getErrorMessage(){
            String codeWithErrorDesc = ErrorText + ' '+errorDescription;
            return ( String.isNotBlank(codeWithErrorDesc) &&  codeWithErrorDesc.length() > 254 ) ? codeWithErrorDesc.substring(0, 254) : codeWithErrorDesc;
        }
    }

    // Class to wrap contacts in the format Box B needs them
    global class BoxB_ContactWrapper {

        public String CST_ID            = '';
        public String INTRNL_LGN_ID     = '';
        public String EXTRN_LGN_ID      = '';
        public String ACCT_ID           = '';
        public String FRST_NM           = '';
        public String LST_NM            = '';
        public String ENG_FRST_NM       = '';
        public String ENG_LST_NM        = '';
        public String EMAIL_ADDR_TXT    = '';
        public String PHN_ADDR_TXT      = '';
        public String EXTRN_ORG_NM      = '';
        public String CTRY_NM           = '';
        public String USR_ACCT_SUSP_DTM = '';
        public String PRI_OCCP_TTL_CD   = '';
        public String EBUS_AGT_STS_CD   = '';
        public Date   CREATE_DT         = null;
        public DateTime CHANGE_DTM      = null;
        public String CIMID             = '';
        public String ACCT_NM           = '';
    }

    // Helper method to ensure all of our "successful" integration messages are consistent
    public static String successfulInboundMessage(Id messageId) {
        return 'Timestamp: ' + Datetime.now() + ' GMT\r\nInbound Message ID: ' + messageId;
    }

    // Helper method to ensure all of our "failed" integration messages due to exceptions are consistent
    public static String failedInboundMessage(Id messageId, Exception ex) {
        return 'Timestamp: ' + Datetime.now() + ' GMT\r\nInbound Message ID: ' + messageId +
            '\r\n' + ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
    }

    // Helper method to ensure all of our "failed" integration messages with error code/text/details are consistent
    public static String failedInboundMessage(Id messageId, String errorCode, String errorText, String errorDetails) {
        return 'Timestamp: ' + Datetime.now() + ' GMT\r\nInbound Message ID: ' + messageId +
            '\r\nError Code: ' + errorCode + ', Error Text: ' + errorText + ', Error Details: ' + errorDetails;
    }

    // Helper method to convert the ERPM style datetime string (e.g. '04/17/2017 03:09:44 AM') to datetime
    public static Datetime convertERPMDatetimeStringToDatetime(String datetimeString) {
        Integer month = Integer.valueOf(datetimeString.split('/')[0]);
        Integer day   = Integer.valueOf(datetimeString.split('/')[1]);
        Integer year  = Integer.valueOf(datetimeString.split('/')[2].left(4));
        Integer hour  = Integer.valueOf(datetimeString.split(':')[0].right(2));
        Integer minute= Integer.valueOf(datetimeString.split(':')[1]);
        Integer second= Integer.valueOf(datetimeString.split(':')[2].left(2));
        String  amPm  = datetimeString.split(':')[2].right(2);
        if (amPm.toUpperCase() == 'PM' && hour < 12){ 
            hour += 12;
        }
        else if(amPm.toUpperCase() == 'AM' && hour == 12){
            hour-=12;
        }

        Datetime convertedDatetime = null;
        try {
            convertedDatetime = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
        }
        catch (Exception ex) {
        }
        return convertedDatetime;
    }


    //Validating Sting Payload fields to Parse
    private static string payloadSpace(String msg){
        if(null != msg){
            // Replacing ~~ if exists in the last 2 characters of the string replace with ''
            if(msg.length()>2 &&(msg.substring(msg.length()-2,msg.length()) == '~~') ){
                msg = msg.substring(0,msg.length()-2)+' ';
            }
            // Replacing ~~ if exists in the first 2 characters of the string replace with ''
            if(msg.length()>2 &&(msg.substring(0,2) == '~~') ){
                msg = ' '+msg.substring(2,msg.length());
            }
            return msg;
        }
        return '';
    }

    //Concatenating 4 Payload fields to Parse
    public static String getFullPayload(Core_Integration_Inbound_Message__c msg){
        string fullPayload;
        fullPayload = payloadSpace(msg.Core_Payload__c)
            +payloadSpace(msg.Core_Payload1__c)
            +payloadSpace(msg.Core_Payload2__c)
            +payloadSpace(msg.Core_Payload3__c);
        system.debug('Processed String'+fullPayload);
        return fullPayload;
    }

    // Helper method to insert any missing ERPM Engagement & Entitlement records from a list of inbound engagement codes
    // Note: per our current data model, this means there must be an Entitlement record with blank AGS role
    public static void insertMissingEngagementsEntitlements(List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs,
                                                            Set<String> erpmEnggCodes)
    {

        // For upcoming inserts
        List<Core_ERPM_Engagement__c> erpmEngagementsToInsert = new List<Core_ERPM_Engagement__c>();
        List<Core_Entitlement__c> entitlementsToInsert = new List<Core_Entitlement__c>();

        // Pull 2 sets of ERPM Engagement records:
        // - ALL that exist in the system
        // - All that also have an inactive Entitlement record w/blank AGS role
        // ...so we can see if we need to insert new inbound ones in both ERPM Engagement + Entitlement, or just Entitlement
        List<Core_ERPM_Engagement__c> fullSetERPMEngagements = [
            select Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c];
        List<Core_ERPM_Engagement__c> erpmEngagementsWithBlankRoleEntitlement = [
            select Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c
            where Id in (select Core_ERPM_Engagement_Id__c from Core_Entitlement__c where Core_AGS_Role_Id__c = '')];

        Set<String> fullSetERPMEngagementCodes = new Set<String>();
        Set<String> erpmEngagementCodesWithBlankRoleEntitlement = new Set<String>();

        for (Core_ERPM_Engagement__c engg : fullSetERPMEngagements)
            fullSetERPMEngagementCodes.add(engg.Core_Technical_Engagement_Code__c);
        for (Core_ERPM_Engagement__c engg : erpmEngagementsWithBlankRoleEntitlement)
            erpmEngagementCodesWithBlankRoleEntitlement.add(engg.Core_Technical_Engagement_Code__c);

        System.debug('##### fullSetERPMEngagementCodes: ' + fullSetERPMEngagementCodes);
        System.debug('##### erpmEngagementCodesWithBlankRoleEntitlement: ' + erpmEngagementCodesWithBlankRoleEntitlement);

        // Only execute the rest of the method if we don't have all of the inbound codes already in the Entitlement table with blank roles
        if (!erpmEngagementCodesWithBlankRoleEntitlement.containsAll(erpmEnggCodes)) {

            // Run through the Engagements, and add to our insert collection if needed
            for (Core_IntegrationUtility.ERPM_Engagement engg : erpmEnggs) {
                if (!fullSetERPMEngagementCodes.contains(engg.engagementCode)) {

                    if ((engg.engagementName == null) || (engg.engagementName == ''))
                        engg.engagementName = engg.engagementCode;

                    Core_ERPM_Engagement__c newEngg =
                        new Core_ERPM_Engagement__c(Name=engg.engagementName, Core_Technical_Name__c=engg.engagementName,
                                                    Core_Technical_Engagement_Code__c=engg.engagementCode, Core_IsActive__c=false);
                    erpmEngagementsToInsert.add(newEngg);
                    fullSetERPMEngagementCodes.add(engg.engagementCode); // Add it to our "full set" so we don't try to add it again
                }
            }

            // Perform DML INSERTs for ERPM Engagements & Entitlements
            System.debug('##### erpmEngagementsToInsert: ' + erpmEngagementsToInsert);
            if (erpmEngagementsToInsert.size() > 0)
                insert erpmEngagementsToInsert;

            // Re-pull our full set of ERPM Engagements now, and build a map of Engg Code to ID
            fullSetERPMEngagements = [select Id, Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c];
            Map<String,Id> fullSetERPMEngagementCodeIdMap = new Map<String,Id>();
            for (Core_ERPM_Engagement__c erpmEngagement : fullSetERPMEngagements)
                fullSetERPMEngagementCodeIdMap.put(erpmEngagement.Core_Technical_Engagement_Code__c, erpmEngagement.Id);

            // Now add Entitlement records for all ERPM Engagements that don't have a blank role Entitlement
            for (Core_IntegrationUtility.ERPM_Engagement engg : erpmEnggs) {
                if (!erpmEngagementCodesWithBlankRoleEntitlement.contains(engg.engagementCode)) {

                    if ((engg.engagementName == null) || (engg.engagementName == ''))
                        engg.engagementName = engg.engagementCode;

                    Core_Entitlement__c newEnt = new
                        Core_Entitlement__c(Core_ERPM_Engagement_Id__c=fullSetERPMEngagementCodeIdMap.get(engg.engagementCode),
                                            Name=engg.engagementName, Core_IsActive__c=false, Core_Display_Name__c=engg.engagementName);
                    entitlementsToInsert.add(newEnt);
                }
            }

            System.debug('##### entitlementsToInsert: ' + entitlementsToInsert);
            if (entitlementsToInsert.size() > 0)
                insert entitlementsToInsert;
        }
    }
    // Helper method to assist with building our Tags in Log Entries
    public static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
            }


    public static String exceptionMessageGenerator(Exception ex){
        String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
        return exceptionMessage;
    }

    public static String formatMultiSelectPicklist(List<String> values) {
    if (values == null) return null;
    return String.join(values, ';');
}


}