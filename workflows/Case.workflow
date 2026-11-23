<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Ask_Commissions_Email_is_sent_to_owner_when_the_status_field_updates</fullName>
        <description>Ask Commissions - Email is sent to owner when the status field updates</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Notification_to_Requestor_owner_when_status_changes_HTML</template>
    </alerts>
    <alerts>
        <fullName>Ask_Commissions_Notification_to_Manager_when_assigned_by_Direct</fullName>
        <description>Ask Commissions-Notification to Manager when assigned by Direct Report HTML</description>
        <protected>false</protected>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Notification_to_Manager_when_assigned_by_Direct_HTML</template>
    </alerts>
    <alerts>
        <fullName>CEP_Case_Assignment</fullName>
        <description>CEP Case Assignment - New</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CEP_Email_Templates/Core_CEP_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>CEP_Case_Reminder</fullName>
        <description>CEP Case Reminder - New</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CEP_Email_Templates/Core_CEP_Case_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Case_Assignment_Notification</fullName>
        <description>Case Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CEP_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Core_AAQC_Notification_on_Status_Equal_to_Awaiting_Requestor_s_Info</fullName>
        <description>Ask Commissions-Notification to Requestor on Status Equal to Awaiting Requestor’s Info</description>
        <protected>false</protected>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Requested_for__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Notification_to_Requester_on_Status_Awaiting_Requestor_s_Info_H</template>
    </alerts>
    <alerts>
        <fullName>Core_AAQC_Notification_on_Status_Equal_to_Awaiting_resolution_Confirmation</fullName>
        <description>Ask Commissions-Notification to Requester on Status Equal to Awaiting resolution confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Requested_for__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Alert_to_Requester_on_Status_Awaiting_resoluton_Confirmation_HT</template>
    </alerts>
    <alerts>
        <fullName>Core_AAQC_Notification_on_Status_Equal_to_Cancelled</fullName>
        <description>Ask Commissions-Notification to Requestor/owner  on Status Equal to Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Requested_for__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Notification_to_Requestor_owner_on_Status_Equal_to_Cancelled_HTM</template>
    </alerts>
    <alerts>
        <fullName>Core_AAQC_Notification_to_Owner_Requester_on_New_case</fullName>
        <description>Ask Commissions-Notification to Owner/Requester on New case</description>
        <protected>false</protected>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Requested_for__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Notification_to_Owner_Requester_on_New_case_HTML</template>
    </alerts>
    <alerts>
        <fullName>Core_AAQC_Notification_to_Owner_on_case_Re_assignment</fullName>
        <description>Ask Commissions-Notification to Owner on case Re-assignment</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_AAQC_Notification_to_Owner_on_case_Re_assignment_HTML</template>
    </alerts>
    <alerts>
        <fullName>Core_AAQC_Notification_to_Requestor_on_Status_Equal_to_Closed</fullName>
        <description>Ask Commissions-Notification to Requestor on Status Equal to Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Core_AAQC_Created_by_s_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_On_Behalf_Of__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_AAQC_Requested_for__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commissions_Notification_to_Requestor_on_Status_Equal_to_Closed_HTML</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Close_Notif_For_No_Assigned_Conact_Case</fullName>
        <description>Core IPS Case Close Notif For No Assigned Contact Case</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_No</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Close_Pending_Notification</fullName>
        <description>Core_IPS_Case_Close_Pending_Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Close_Pending_Notification_NAC</fullName>
        <description>Core_IPS_Case_Close_Pending_Notification_NAC</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Close_Pending_Reminder_Notification</fullName>
        <description>Core_IPS_Case_Close_Pending_Reminder_Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Close_Pending_Reminder_Notification_For_NAC</fullName>
        <description>Core_IPS_Case_Close_Pending_Reminder_Notification_For_NAC</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Closed_Notif</fullName>
        <description>Core IPS Case Closed Notif</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_No</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Create_Notification</fullName>
        <description>Core IPS Case Create Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Create_Notification_Except_Owner</fullName>
        <description>Core IPS Case Create Notification Except Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Create_Notification_For_NAC</fullName>
        <description>Core IPS Case Create Notification For NAC</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Agent</fullName>
        <description>Core IPS Case Comment Notif Agent New EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Agent</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Close_EA</fullName>
        <description>Core IPS Case Notif Ext Close EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS External Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Close</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Close_New_EA</fullName>
        <description>Core IPS Case Notif Ext Close New EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS External Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Supported_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Partner_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External_No_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Close_Pending_New_EA</fullName>
        <description>Core IPS Case Notif Ext Close Pending New EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS External Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Supported_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Partner_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External_Close_Pending</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Comment_EA</fullName>
        <description>Core IPS Case Notif Ext Comment EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS External Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Comment_Update_New_EA</fullName>
        <description>Core IPS Case Notif Ext Comment Update New EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Supported_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Comment_Update_Non_Contact_New_EA</fullName>
        <description>Core IPS Case Notif Ext Comment Update Non Contact New EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS External Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Partner_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Contact_Attachment_EA</fullName>
        <description>Core IPS Case Notif Ext Contact Attachment EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Attachment</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Contact_Close_EA</fullName>
        <description>Core IPS Case Notif Ext Contact Close EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Close_Survey</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Contact_Create_EA</fullName>
        <description>Core IPS Case Notif Ext Contact Create EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Create</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Contact_Reopen_EA</fullName>
        <description>Core IPS Case Notif Ext Contact Reopen EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Reopen</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Contact_Update_EA</fullName>
        <description>Core IPS Case Notif Ext Contact Update EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Contact_Update_New_EA</fullName>
        <description>Core IPS Case Notif Ext Contact Update New EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Supported_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Partner_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Create_New_EA</fullName>
        <description>Core IPS Case Notif Ext Create New EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Core_IPS_Supported_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Partner_Comment_New_EA</fullName>
        <description>Core IPS Case Notif Ext Partner Comment New EA</description>
        <protected>false</protected>
        <recipients>
            <field>Core_IPS_Partner_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External_Partner</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Reopen_EA</fullName>
        <description>Core IPS Case Notif Ext Reopen EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS External Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_External_Reopen</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Ext_Support_Assigned_New_EA</fullName>
        <description>Core IPS Case Notif Ext Support Assigned New EA</description>
        <protected>false</protected>
        <recipients>
            <field>Core_IPS_Partner_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_External_Contact_Close_Survey</fullName>
        <description>Core IPS Case Notif External Contact Close Survey</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Ext_Close_Survey</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_GEC_Case_EA</fullName>
        <description>Core IPS Case Notif GEC Case EA</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_GEC</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_GEC_Hold_Review_ISO</fullName>
        <description>Core IPS Case Notif GEC Hold Review ISO</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_No</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Assignment_EA</fullName>
        <description>Core IPS Case Notif Int Assignment EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Close_EA</fullName>
        <description>Core IPS Case Notif Int Close EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Close</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Comment_EA</fullName>
        <description>Core IPS Case Notif Int Comment EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_GEC_Create_EA</fullName>
        <description>Core IPS Case Notif Int GEC Create EA</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_GEC</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_ISO_Create_EA</fullName>
        <description>Core IPS Case Notif Int ISO Create EA</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Create</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Owner_Attachment_EA</fullName>
        <description>Core IPS Case Notif Int Owner Attachment EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Attachment</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Private_Comment_EA</fullName>
        <description>Core IPS Case Notif Int Private Comment EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Reopen_EA</fullName>
        <description>Core IPS Case Notif Int Reopen EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Reopen</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Request_Close_EA</fullName>
        <description>Core IPS Case Notif Int Request Close EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Request_Close</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Request_Reopen_EA</fullName>
        <description>Core IPS Case Notif Int Request Reopen EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Request_Reopen</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_SA_Attachment_EA</fullName>
        <description>Core IPS Case Notif Int SA Attachment EA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Attachment</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_SA_Closed_EA</fullName>
        <description>Core IPS Case Notif Int SA Closed EA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Close</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_SA_Create_EA</fullName>
        <description>Core IPS Case Notif Int SA Create EA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Create</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_SA_Reopen_EA</fullName>
        <description>Core IPS Case Notif Int SA Reopen EA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Reopen</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_SA_Update_EA</fullName>
        <description>Core IPS Case Notif Int SA Update EA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Update_EA</fullName>
        <description>Core IPS Case Notif Int Update EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_Update</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Int_Update_New_EA</fullName>
        <description>Core IPS Case Notif Int Update New EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Internal_Partner_Comment</fullName>
        <description>Core IPS Case Notif Internal Partner Comment</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Partner</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Private_Comment_New_EA</fullName>
        <description>Core IPS Case Notif Private Comment New EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Private</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_Public_Comment_New_EA</fullName>
        <description>Core IPS Case Notif Public Comment New EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>IPS Internal Interested Party</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>IPS Internal Interested Party Read Only</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_SLA_Overdue_EA</fullName>
        <description>Core IPS Case Notif SLA Overdue EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_SLA_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_SLA_Overdue_New_EA</fullName>
        <description>Core IPS Case Notif SLA Overdue New EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_SLA_Reminder_EA</fullName>
        <description>Core IPS Case Notif SLA Reminder EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Case_Internal_SLA_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_SLA_Reminder_New_EA</fullName>
        <description>Core IPS Case Notif SLA Reminder New EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Notif_for_ISO</fullName>
        <description>Core IPS Case Notif for ISO</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Sup_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Private</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Update_Notification</fullName>
        <description>Core IPS Case Update Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Case_Update_Notification_Except_Owner</fullName>
        <description>Core IPS Case Update Notification Except Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Core_Case_Co_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Private</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Comment_Notification_For_NAC</fullName>
        <description>Core IPS Comment Notification For NAC</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_MAG_Questionnaire_Completed_Notif</fullName>
        <description>Core IPS MAG Questionnaire Completed Notif</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_No</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Email_Alert_Before_15_Days_of_Document_Submission_Deadline_Date</fullName>
        <description>Core_MDF_Email Alert Before 15 Days of Document Submission Deadline Date</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyDocUploadBefore15Days</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Email_Alert_Before_5_Days_of_Document_Submission_Deadline_Date</fullName>
        <description>Core_MDF_Email Alert Before 5 Days of Document Submission Deadline Date</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyDocUploadBefore5Days</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Immediate_Email_Alert</fullName>
        <description>Core_MDF_Immediate Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyDocumentUpload</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_NotifyCaseOwnersOnMessage</fullName>
        <description>Case Owners receives an email if Claim Submitter submits any message</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Submitter_Message</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_NotifyClaimCaseReviewerOnMessage</fullName>
        <description>Claim Case Reviewers receives an email if Claim Submitter submits any message</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Case_Reviewer_Lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Submitter_Message</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_Claim_Submitter_on_Case_cancellation</fullName>
        <description>Core_MDF_Notify Claim Submitter on Case cancellation</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyonCaseCancellation</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notifying_Partner_for_Claim_Review_Status_Notice</fullName>
        <description>Core_MDF_Notifying Partner for Claim Review Status Notice</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Email_for_Claim_Review_Notice</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notifying_Partner_on_Case_creation_with_Under_Review_Status</fullName>
        <description>Core_MDF_Notifying Partner on Case creation with Under Review Status</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Claim_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyonCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Owner</fullName>
        <description>Email Case Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CEP_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_the_Owner_created_by_when_the_Case_comment_is_added</fullName>
        <description>Notification to the Owner/created by when the Case comment is added</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ask_Commission_Notification_Case_Comment_is_Updated_HTML</template>
    </alerts>
    <fieldUpdates>
        <fullName>Ask_Commissions_Assigning_Case_to_Triage</fullName>
        <description>Ask Commissions-Assigning Case to Triage Group on case Creation</description>
        <field>OwnerId</field>
        <lookupValue>Core_AAQC_Commissions_Triage_Group</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Ask Commissions-Assigning Case to Triage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_to_GEC_Record_Type</fullName>
        <description>This changes the case record type to GEC.</description>
        <field>RecordTypeId</field>
        <lookupValue>IPS_GEC_ReadOnly</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change to GEC Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_AAQC_Changing_Status_on_Owner_Chang</fullName>
        <description>Changing Case Status to Assigned when a Case Owner is changed and Status is New</description>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Changing Status on Owner Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_BK_Promote_End_DateTime_Blank</fullName>
        <field>Core_IPS_Backend_Promote_Success_DT__c</field>
        <name>Core_IPS_BK_Promote_End_DateTime_Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_BK_Promote_Start_DateTime</fullName>
        <field>Core_IPS_Backend_Promote_DT__c</field>
        <formula>NOW()</formula>
        <name>Core_IPS_BK_Promote_Start_DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_BK_Promote_Success_DT</fullName>
        <field>Core_IPS_Backend_Promote_Success_DT__c</field>
        <formula>NOW()</formula>
        <name>Core_IPS_BK_Promote_Success_DT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_CaseClassification</fullName>
        <description>Update the Case Classification to &apos;Intel Confidential&apos;</description>
        <field>Core_IPS_Classification__c</field>
        <literalValue>Intel Confidential</literalValue>
        <name>Core_IPS_CaseClassification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Escalated_Date</fullName>
        <description>Stamp Case Escalated Date with current date and time</description>
        <field>Core_IPS_Case_Escalated_Date__c</field>
        <formula>Now()</formula>
        <name>Core IPS Case Escalated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_GEC_Flag_Update_FU</fullName>
        <field>Core_IPS_GEC_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Case GEC Flag Update FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Non_SA_Assigned</fullName>
        <field>Core_IPS_Self_Assigned__c</field>
        <literalValue>0</literalValue>
        <name>Core IPS Case Non-SA Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Notif_Attachment_Uncheck_F</fullName>
        <field>Core_IPS_File_Attachment_Flag__c</field>
        <literalValue>0</literalValue>
        <name>Core IPS Case Notif Attachment Uncheck F</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Notif_DCG_RS_True</fullName>
        <field>Core_IPS_Restricted_Secret_Content__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Case Notif DCG RS True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Promote_Count</fullName>
        <description>Increment Case promotion or update to sent to backend</description>
        <field>Core_IPS_Promote_Count_Outbound__c</field>
        <formula>IF(ISBLANK(Core_IPS_Promote_Count_Outbound__c),1,Core_IPS_Promote_Count_Outbound__c) + 1</formula>
        <name>Core_IPS_Case_Promote_Count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Promote_Inbound_Count</fullName>
        <field>Core_IPS_Promote_Count_Inbound__c</field>
        <formula>IF(
ISBLANK( Core_IPS_Promote_Count_Inbound__c ), 
1, 
Core_IPS_Promote_Count_Inbound__c + 1
)</formula>
        <name>Core_IPS_Case_Promote_Inbound_Count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Reopen_Date_FU</fullName>
        <field>Core_IPS_Reopen_Date__c</field>
        <formula>Now()</formula>
        <name>Core IPS Case Reopen Date FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Case_Reopen_Flag_FU</fullName>
        <field>Core_IPS_Reopen_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Case Reopen Flag FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Change_GEC_Case_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>IPS_GEC_ReadOnly</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core IPS Change GEC Case Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Change_the_Case_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>Core_IPS_CaseQ_GEC_Cases</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Core IPS Change the Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Chg_to_Case_Closed_Record_type</fullName>
        <description>When an IPS case is closed, it should change to Close Case record type</description>
        <field>RecordTypeId</field>
        <lookupValue>IPS_Closed_Case</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core IPS Chg to Case Closed Recrd type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Clear_Next_Response_Date</fullName>
        <field>Core_Next_Response_Due_Date__c</field>
        <name>Core IPS Clear Next Response Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Closed_Status</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Core IPS Closed Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Closed_Sub_Status</fullName>
        <description>Update Case Sub Status to Closed.</description>
        <field>Core_Sub_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Core_IPS_Closed_Sub_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Flow_Approve_Status_Change</fullName>
        <field>RecordTypeId</field>
        <lookupValue>IPS_Case_Create</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core IPS GEC Flow Approve Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Flow_Changes</fullName>
        <field>Status</field>
        <literalValue>On Hold</literalValue>
        <name>Core IPS GEC Flow Changes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Is_Stopped_False</fullName>
        <field>IsStopped</field>
        <literalValue>0</literalValue>
        <name>Core IPS GEC Is Stopped False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Request_Status_Update</fullName>
        <field>Core_IPS_GEC_Request_Status__c</field>
        <literalValue>MAG Questionnaire Required</literalValue>
        <name>Core IPS GEC Request Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Status_Change</fullName>
        <field>Status</field>
        <literalValue>On Hold</literalValue>
        <name>Core IPS GEC Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Sub_Status_Change</fullName>
        <description>Sub Status as GEC Hold when Status is On Hold.</description>
        <field>Core_Sub_Status__c</field>
        <literalValue>GEC Hold</literalValue>
        <name>Core IPS GEC Sub Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_GEC_Sub_Status_Changed_To_Blank</fullName>
        <field>Core_Sub_Status__c</field>
        <name>Core IPS GEC Sub Status Changed To Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Hide_Reopen_after_30_days</fullName>
        <field>RecordTypeId</field>
        <lookupValue>IPS_GEC_ReadOnly</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core IPS Hide Reopen after 30 days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Main_Status_As_New</fullName>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>Core IPS Main Status As New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Request_Status_Update</fullName>
        <description>Updates the GEC Request Status field to Potential GEC reivew</description>
        <field>Core_IPS_GEC_Request_Status__c</field>
        <literalValue>MAG Questionnaire Required</literalValue>
        <name>Core IPS Request Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Reset_Core_Trigger_Nxt_Response</fullName>
        <field>Core_Trigger_Next_Response__c</field>
        <literalValue>0</literalValue>
        <name>Core_IPS_Rset Core Trgr Nxt Rspse</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Restart_Milestne_Clck_if_Stpped</fullName>
        <field>IsStopped</field>
        <literalValue>0</literalValue>
        <name>Core IPS Rstart Milstone Clck if Stopped</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Self_Assigned_To_True</fullName>
        <field>Core_IPS_Self_Assigned__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Self Assigned To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Set_Core_Trgr_Nxt_Rspns_to_True</fullName>
        <field>Core_Trigger_Next_Response__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Set Core Trgr Nxt Rspns to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Uncheck_Customer_Visible</fullName>
        <description>Uncheck Customer Visible checkbox on Case</description>
        <field>Core_IPS_Customer_Visible__c</field>
        <literalValue>0</literalValue>
        <name>Core_IPS_Uncheck_Customer_Visible</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Upd_Frst_Rspns_Completd_on_Case</fullName>
        <field>Core_First_Response_Completed__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Upd First Rspns Compltd on Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_UpdateCloseCaseRecordtype</fullName>
        <description>Update the Record type  of the Case after  the case is reopen</description>
        <field>RecordTypeId</field>
        <lookupValue>Core_IPS_Case_Create_Self_Assigned</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_IPS_UpdateCloseCaseRecordtype</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_UpdateCloseCaseRecordtypeWithCo</fullName>
        <description>this  Field  workflow will  work  when  the closed case is will  be reopen  and case have contact  information</description>
        <field>RecordTypeId</field>
        <lookupValue>IPS_Case_Create</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_IPS_UpdateCloseCaseRecordtypeWithCo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_UpdateCloseCaseRecordtypeWithc1</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Core_IPS_Case_Create_Self_Assigned</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_IPS_UpdateCloseCaseRecordtypeWithc1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Case_Request_Close_Stat</fullName>
        <description>This updates the Case Sub Status for the Internal User Case Layout</description>
        <field>Core_Sub_Status__c</field>
        <literalValue>Customer Requesting Close*</literalValue>
        <name>Core_IPS_Update Case Request Close Statu</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Case_Request_Close_Statu</fullName>
        <description>Updates the case status for both Internal and External Case Layout</description>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>Core_IPS_Update Case Request Close Statu</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Custom_Case_Queue_Field</fullName>
        <description>Update the Last Assigned Case Field on case.</description>
        <field>Core_IPS_Assigned_Queue__c</field>
        <formula>Owner:Queue.QueueName</formula>
        <name>Core IPS Update Custom Case Queue Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Email_Text_SLA_Overdue</fullName>
        <field>Core_IPS_email_text__c</field>
        <formula>&apos;IPS - SLA is overdue on Case&apos;</formula>
        <name>Core_IPS_Update_Email_Text_SLA_Overdue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Email_Text_SLA_Reminder</fullName>
        <field>Core_IPS_email_text__c</field>
        <formula>&apos;IPS - SLA expires in 4 hours on Case&apos;</formula>
        <name>Core_IPS_Update_Email_Text_SLA_Reminder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_case_Origin_for_Customer</fullName>
        <field>Origin</field>
        <literalValue>Web</literalValue>
        <name>Core IPS Update case Origin for Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_isNextResponseActive_Fla</fullName>
        <field>Core_IPS_isNextResponseActive__c</field>
        <literalValue>0</literalValue>
        <name>Core IPS Update isNextResponseActive Fla</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Updates_the_GEC_Flag_to_true</fullName>
        <description>Updates GEC Flag field on case to true</description>
        <field>Core_IPS_GEC_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Core_IPS Update the GEC Flag to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Change_status_to_Non_Compliant</fullName>
        <field>Core_MDF_Review_Case_Status__c</field>
        <literalValue>Non-compliant</literalValue>
        <name>Change status to Non-Compliant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Review_Case_Status</fullName>
        <field>Core_MDF_Status__c</field>
        <literalValue>Pending Documents</literalValue>
        <name>Core MDF Update Review Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPS_Update_Trigger_Next_Response_to_True</fullName>
        <field>Core_Trigger_Next_Response__c</field>
        <literalValue>1</literalValue>
        <name>IPS Update Trigger Next Response to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OwnerUpdatedYes</fullName>
        <field>Core_AAQC_Owner_Updated__c</field>
        <literalValue>1</literalValue>
        <name>OwnerUpdatedYes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Queue_Assignment</fullName>
        <description>Queue Assignment</description>
        <field>OwnerId</field>
        <lookupValue>CEP_Case</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Queue Assignment</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseAutoCloseDate</fullName>
        <field>Core_AAQC_Case_Auto_Close__c</field>
        <formula>CASE( 
MOD( datevalue( LastModifiedDate ) - DATE( 1900, 1, 7 ), 7 ), 
0, LastModifiedDate + 5, 
1, LastModifiedDate + 5 + 2 , 
2, LastModifiedDate + 5 + 2, 
3, LastModifiedDate + 5 + 2, 
4, LastModifiedDate + 5 + 2, 
5, LastModifiedDate + 5 + 2, 
6, LastModifiedDate + 5 + 1, 
null 
)</formula>
        <name>UpdateCaseAutoCloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Assignment_Field</fullName>
        <description>Update Case Assignment</description>
        <field>Case_Assignment__c</field>
        <literalValue>1</literalValue>
        <name>Update Assignment Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Core_IPS_CaseFieldUpdate_Backend_OutMsg</fullName>
        <apiVersion>35.0</apiVersion>
        <endpointUrl>https://dummy_user1:7Ha8oBPw!1!c@eip-generic-dummygroup2.cloudhub.io/smit/api/ips/NewIPSCaseObjectUpdate</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Core_IPS_Backend_ID__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ips.backend.integrationuser@intel.com.crm</integrationUser>
        <name>Core_IPS_CaseFieldUpdate_Backend_OutMsg</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Core_IPS_CaseStatusUpdate_Backend_OutMsg</fullName>
        <apiVersion>38.0</apiVersion>
        <endpointUrl>https://dummy_user1:7Ha8oBPw!1!c@eip-generic-dummygroup2.cloudhub.io/smit/api/ips/NewIPSCaseUpdate</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Core_IPS_Backend_ID__c</fields>
        <fields>Core_IPS_Backend_Previous_Status__c</fields>
        <fields>Core_Sub_Status__c</fields>
        <fields>Id</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ips.backend.integrationuser@intel.com.crm</integrationUser>
        <name>Core_IPS_CaseStatusUpdate_Backend_OutMsg</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Core_IPS_Case_Backend_OutMsg</fullName>
        <apiVersion>34.0</apiVersion>
        <description>Backend Case Outbound Message</description>
        <endpointUrl>https://dummy_user1:7Ha8oBPw!1!c@eip-generic-dummygroup2.cloudhub.io/smit/api/ips/NewIPSCasePromote</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Core_IPS_Backend_ID__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ips.backend.integrationuser@intel.com.crm</integrationUser>
        <name>Core_IPS_Case_Backend_OutMsg</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Core_IPS_Case_Depromote_Backend_OutMsg</fullName>
        <apiVersion>41.0</apiVersion>
        <description>Backend depromotion outbound messages</description>
        <endpointUrl>https://dummy_user1:7Ha8oBPw!1!c@eip-generic-dummygroup2.cloudhub.io/smit/api/ips/NewIPSCaseDePromote</endpointUrl>
        <fields>CaseNumber</fields>
        <fields>Core_IPS_Backend_Previous_Status__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>11738563@intel.com.crm</integrationUser>
        <name>Core_IPS_Case_Depromote_Backend_OutMsg</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Ask Commissions - Case Auto close feature based on time dependent customer replies</fullName>
        <actions>
            <name>UpdateCaseAutoCloseDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions - Case Auto close based on Time frame allotted to reply, before system automatically closes open case</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;, ISPICKVAL(Status ,&apos;Awaiting Resolution Confirmation&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions - Notification to Manager when assigned by Direct Report HTML</fullName>
        <actions>
            <name>Ask_Commissions_Notification_to_Manager_when_assigned_by_Direct</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;, NOT(ISBLANK( Core_AAQC_Created_by_s_Manager_Email__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Assigning Case to Triage Group on case Creation</fullName>
        <actions>
            <name>Ask_Commissions_Assigning_Case_to_Triage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>OwnerUpdatedYes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Assigning Case to Triage Group on case Creation</description>
        <formula>AND(RecordType.DeveloperName==&apos;Core_AAQC_Case_recordType&apos;, ISPICKVAL(Status,&apos;New&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Case Comment is added</fullName>
        <actions>
            <name>Notification_to_the_Owner_created_by_when_the_Case_comment_is_added</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>US110977 - E-mail sent to Case owner when End User responds</description>
        <formula>AND( RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;, ISCHANGED( Core_AAQC_Case_Comment_Id__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Changing Status to assigned when Owner Changes</fullName>
        <actions>
            <name>Core_AAQC_Changing_Status_on_Owner_Chang</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Changing Status to assigned when Owner Changes and Status is New</description>
        <formula>AND(RecordType.DeveloperName==&apos;Core_AAQC_Case_recordType&apos;,ISPICKVAL( Status , &apos;New&apos;),ISCHANGED(OwnerId),NOT(ISPICKVAL( PRIORVALUE( Status ), &quot;Draft&quot; )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Email to the owner%2Fcreator when the status is updated</fullName>
        <actions>
            <name>Ask_Commissions_Email_is_sent_to_owner_when_the_status_field_updates</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email is sent to owner/creator when the status is updated</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;, ISCHANGED(Status), NOT(ISNEW()))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Notification to Owner on Case Reassignment</fullName>
        <actions>
            <name>Core_AAQC_Notification_to_Owner_on_case_Re_assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Notification to Owner on Case Reassignment</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;, NOT(ISNEW()) ,ISCHANGED( OwnerId ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Notification to Requester on Status Equal to Awaiting resolution Confirmation</fullName>
        <actions>
            <name>Core_AAQC_Notification_on_Status_Equal_to_Awaiting_resolution_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Notification to Requester on Status Equal to Awaiting resolution Confirmation</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;,ISPICKVAL(Status ,&apos;Awaiting Resolution Confirmation&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Notification to Requestor on Status Equal to Awaiting Requestor%E2%80%99s Info</fullName>
        <actions>
            <name>Core_AAQC_Notification_on_Status_Equal_to_Awaiting_Requestor_s_Info</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Notification to Requestor on Status Equal to Awaiting Requestor’s Info</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;,ISPICKVAL(Status ,&apos;Awaiting Requestor’s Info&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Notification to Requestor on Status Equal to Closed</fullName>
        <actions>
            <name>Core_AAQC_Notification_to_Requestor_on_Status_Equal_to_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Notification to Requestor on Status Equal to Closed</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;,ISPICKVAL(Status ,&apos;Closed&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ask Commissions-Notification to Requestor%2Fowner on Status Equal to Cancelled</fullName>
        <actions>
            <name>Core_AAQC_Notification_on_Status_Equal_to_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ask Commissions-Notification to Requestor/owner  on Status Equal to Cancelled</description>
        <formula>AND(RecordType.DeveloperName ==&apos;Core_AAQC_Case_recordType&apos;,ISPICKVAL(Status ,&apos;Cancelled&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CEP Case Assignment</fullName>
        <actions>
            <name>Queue_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>CEP Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Integration User</value>
        </criteriaItems>
        <description>CEP Case Assignment when contact owner not assigned</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CEP Case Notification</fullName>
        <actions>
            <name>Email_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Assignment_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>CEP Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Case_Assignment__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>CEP Case Notification</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CEP Case Reminder - New</fullName>
        <active>false</active>
        <formula>AND ( CONTAINS(RecordType.Name, &apos;CEP Case&apos;), ISPICKVAL(Status, &apos;Open&apos;) || ISPICKVAL(Status, &apos;New&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CEP_Case_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core IPS Case Escalated Date Stamp</fullName>
        <actions>
            <name>Core_IPS_Case_Escalated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Case Escalated Date value needs to be stamped with Escalated Level changes</description>
        <formula>AND(ISCHANGED( Core_IPS_Escalated_Level__c ),OR(ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Level 2&quot;),			ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Level 3&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Domain Expert&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Engineering&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Consult Level 1 / Front Line&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Consult Level 2&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Consult Level 3&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Consult Domain Expert&quot;),ISPICKVAL(Core_IPS_Escalated_Level__c,&quot;Consult Engineering&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Non-SA Assigned</fullName>
        <actions>
            <name>Core_IPS_Case_Non_SA_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>IPS No Assigned Contact Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Self_Assigned__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>IPS Data Migration</value>
        </criteriaItems>
        <description>IPS Case Non-SA: When new Case is created/updated with record type other than Self Assigned then uncheck the checkbox field named Self Assigned.

(Case: Case Record TypeNOT EQUAL TOIPS Case Create Self Assigned) AND (Case: Self AssignedEQUALSTrue)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif DCG Restricted Secret</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_DCG_RS_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Core_Product_Organization__c</field>
            <operation>equals</operation>
            <value>Data Center</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Contact Attachment WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Contact_Attachment_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the External Contact letting them know that a file has been attached to their Case.</description>
        <formula>AND(RecordTypeId=&apos;012o0000000TPVh&apos;,  OR(ISPICKVAL( Status ,&apos;Open&apos;),ISPICKVAL( Status ,&apos;New&apos;)),  Core_IPS_File_Attachment_Flag__c , Core_IPS_Is_Notification_Active__c , Contact.Core_IPS_Active__c , NOT(Contact.Core_IPS_Email_Opt_Out__c) , Core_IPS_Customer_Visible__c,$Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Contact Close WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Contact_Close_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the External Contact letting them know that their Case has been Closed.</description>
        <formula>AND( ISCHANGED( Status ), ISPICKVAL( Status , &quot;Closed&quot;), Core_IPS_Is_Notification_Active__c = TRUE, OR(RecordType.Name = &quot;IPS Case Create&quot;, RecordType.Name = &quot;IPS Closed Case&quot;,RecordType.Name = &quot;IPS No Assigned Contact Case&quot;, RecordType.Name = &quot;IPS GEC ReadOnly&quot; ),  Contact.Core_IPS_Active__c = TRUE,  Contact.Core_IPS_Email_Opt_Out__c = FALSE, Core_IPS_Customer_Visible__c = TRUE  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Contact Create WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Contact_Create_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS Case Create,IPS GEC ReadOnly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Core_IPS_Email_Opt_Out__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Is_Notification_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Core_IPS_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Customer_Visible__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>IPS Case Notification: Workflow sends email notification to the External Contact letting them know that their Case has been Created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Contact Reopen WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Contact_Reopen_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the External Contact letting them know that their Case has been Reopened.</description>
        <formula>AND(  OR( RecordType.Name = &quot;IPS Case Create&quot;, RecordType.Name = &quot;IPS Closed Case&quot;), ISCHANGED(Status),  OR(ISPICKVAL(Status,&quot;Open&quot;),ISPICKVAL(Status,&quot;New&quot;)),  ISPICKVAL(PRIORVALUE(Status),&quot;Closed&quot;),  Contact.Core_IPS_Active__c = TRUE,  Contact.Core_IPS_Email_Opt_Out__c = FALSE,  Core_IPS_Is_Notification_Active__c = TRUE, Core_IPS_Customer_Visible__c = TRUE  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Contact Update WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Contact_Update_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the External Contact letting them know that an Update has been made on their Case.</description>
        <formula>AND( $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;,RecordType.Name = &apos;IPS Case Create&apos;, Contact.Core_IPS_Email_Opt_Out__c = FALSE,  Contact.Core_IPS_Active__c = TRUE,  Core_IPS_Is_Notification_Active__c = TRUE,  OR(ISPICKVAL(Status, &apos;New&apos;), ISPICKVAL(Status, &apos;Open&apos;)), ISCHANGED( Core_Last_Case_Comment__c ), Core_IPS_Customer_Visible__c = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Int Close WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Close_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Comm. Owner, Intel Support Owner, Internal and External Interested Parties letting them know that their Case has been Closed.</description>
        <formula>AND(   ISCHANGED( Status ),  ISPICKVAL( Status , &quot;Closed&quot;),  Core_IPS_Is_Notification_Active__c = TRUE, OR(RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id, RecordTypeId = $Label.Core_IPS_GEC_ReadOnly_RT_Id ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Int Close WF2 - External Only</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Close_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Comm. Owner, Intel Support Owner, Internal and External Interested Parties letting them know that their Case has been Closed.</description>
        <formula>AND(   ISCHANGED( Status ),  ISPICKVAL( Status , &quot;Closed&quot;),  Core_IPS_Is_Notification_Active__c = TRUE, OR(RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id, RecordTypeId = $Label.Core_IPS_GEC_ReadOnly_RT_Id ),  Core_IPS_Customer_Visible__c = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Int Comment WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Comment_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Case Co-Owner, Intel Support Owner, Internal and External Interested Parties letting them know that an Update has been made on their Case.</description>
        <formula>AND($Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;, OR(RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id ), OR(ISPICKVAL(Status, &apos;New&apos;), ISPICKVAL(Status, &apos;Open&apos;)), Core_IPS_Is_Notification_Active__c = TRUE, ISCHANGED( Core_Last_Case_Comment__c ), Core_IPS_Customer_Visible__c = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Int Reopen WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Reopen_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Comm. Owner, Intel Support Owner, Internal and External Interested Parties letting them know that their Case has been Reopened.</description>
        <formula>AND( OR(RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id), ISCHANGED(Status), OR(ISPICKVAL(Status,&quot;Open&quot;),ISPICKVAL(Status,&quot;New&quot;)), ISPICKVAL(PRIORVALUE(Status),&quot;Closed&quot;), Core_IPS_Is_Notification_Active__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Ext Int Reopen WF2 -External Only</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Ext_Reopen_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Comm. Owner, Intel Support Owner, Internal and External Interested Parties letting them know that their Case has been Reopened.</description>
        <formula>AND( OR(RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id), ISCHANGED(Status), OR(ISPICKVAL(Status,&quot;Open&quot;),ISPICKVAL(Status,&quot;New&quot;)), ISPICKVAL(PRIORVALUE(Status),&quot;Closed&quot;), Core_IPS_Is_Notification_Active__c =TRUE,  Core_IPS_Customer_Visible__c = TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif External Contact Close WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_External_Contact_Close_Survey</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the External Contact letting them know that their Case has been Closed with Survey link</description>
        <formula>AND(  	 ISCHANGED( Status ),  	 ISPICKVAL( Status , &quot;Closed&quot;),  	 Core_IPS_Is_Notification_Active__c = TRUE,  	 CONTAINS(RecordType.Name,&apos;IPS&apos;),           Contact.Core_IPS_Active__c = TRUE,  	 Contact.Core_IPS_Email_Opt_Out__c = FALSE, 	 Core_IPS_Customer_Visible__c = TRUE     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int GEC Case WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_GEC_Create_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow kicks off when a case is created on a MAG account.</description>
        <formula>IF(AND($Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;,Contact.Account.Core_Military_Aerospace_and_Government__c = TRUE, Core_IPS_GEC_Flag__c = TRUE, Core_IPS_Is_Notification_Active__c = TRUE),TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int GEC Create WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_GEC_Create_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>IF(AND(Contact.Account.Core_Military_Aerospace_and_Government__c = TRUE, Core_IPS_GEC_Flag__c = TRUE),TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int ISO Create WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_ISO_Create_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS Case Create,IPS GEC ReadOnly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Is_Notification_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>IPS Data Migration</value>
        </criteriaItems>
        <description>IPS Case Notification: Workflow sends email notification to the Intel Support Owner letting them know that a Contact they oversee has Created a Case.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int Owner Attachment WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Owner_Attachment_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Comm. Owner, Intel Support Owner, and Internal Interested Parties letting them know that a File has been attached to their Case.</description>
        <formula>AND(RecordTypeId=&apos;012o0000000TPVh&apos;, OR(ISPICKVAL( Status ,&apos;Open&apos;),ISPICKVAL( Status ,&apos;New&apos;)), Core_IPS_File_Attachment_Flag__c , Core_IPS_Is_Notification_Active__c,$Profile.Name &lt;&gt; &apos;IPS Data Migration&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int Private Comment</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Private_Comment_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( OR( RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id,RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id ), OR(ISPICKVAL(Status, &quot;New&quot;), ISPICKVAL(Status, &quot;Open&quot;)), Core_IPS_Is_Notification_Active__c = TRUE, ISCHANGED(  Core_Last_Private_Case_Comment__c  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int Request Close WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Request_Close_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(OR( RecordType.Name = &quot;IPS Case Create&quot;, RecordType.Name = &quot;IPS Closed Case&quot;,RecordType.Name = &quot;IPS No Assigned Contact Case&quot; ), Core_IPS_Is_Notification_Active__c = TRUE,  ISCHANGED(Core_Sub_Status__c),  ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Close&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int Request Reopen WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Request_Reopen_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( Core_IPS_Is_Notification_Active__c = TRUE,  ISCHANGED(Core_Sub_Status__c),  ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Reopen&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int SA Attachment WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_SA_Attachment_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the internal Case Creator(Self Assigned Case) letting them know that a File has been attached to their Case.</description>
        <formula>AND(RecordTypeId=&apos;012o0000000TPVg&apos;, OR(ISPICKVAL( Status ,&apos;Open&apos;),ISPICKVAL( Status ,&apos;New&apos;)), Core_IPS_Self_Assigned__c,  Core_IPS_File_Attachment_Flag__c , Core_IPS_Is_Notification_Active__c,$Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int SA Closed WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_SA_Closed_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Is_Notification_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>IPS Data Migration</value>
        </criteriaItems>
        <description>IPS Case Notification: Workflow sends email notification to the internal Case Creator(Self Assigned Case) letting them know that their Case has been Closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int SA Create WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_SA_Create_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Is_Notification_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>IPS Case Notification: Workflow sends email notification to the internal Case Creator(Self Assigned Case) letting them know that their Case has been Created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int SA Reopen WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_SA_Reopen_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the internal Case Creator(Self Assigned Case) letting them know that their Case has been Reopened.</description>
        <formula>AND( RecordType.Name = &quot;IPS No Assigned Contact Case&quot;, ISCHANGED(Status), ISPICKVAL(Status,&quot;Closed&quot;), ISPICKVAL(PRIORVALUE(Status),&quot;Open&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int SA Update WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_SA_Update_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the internal Case Creator(Self Assigned Case) when Case Owner and Case creator are different letting them know that an Update has been made on their Case.</description>
        <formula>AND(  $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id, OR(ISPICKVAL(Status, &quot;New&quot;), ISPICKVAL(Status, &quot;Open&quot;)), Core_IPS_Is_Notification_Active__c = TRUE, ISCHANGED( Core_Last_Case_Comment__c ),OwnerId &lt;&gt; CreatedById )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case Notif Int Update WF</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Update_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IPS Case Notification: Workflow sends email notification to the Case Owner, Comm. Owner, Intel Support Owner, and Internal Interested Parties letting them know that an Update has been made on their Case and Case Comment(Core IPS Case Notif Ext Int ComWF).</description>
        <formula>/*---------------------------Commented to optimize triggering of multiple notifications----------------------------------- AND( OR( RecordType.Name = &quot;IPS Case Create&quot;, RecordType.Name = &quot;IPS Closed Case&quot;,RecordType.Name = &quot;IPS No Assigned Contact Case&quot;, RecordType.Name = &quot;IPS GEC ReadOnly&quot; ), NOT(OR(ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Close&quot;) , ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Reopen&quot;))), OR( ISCHANGED(ContactId), ISCHANGED(AssetId), ISCHANGED(Core_IPS_Project_Case__c), ISCHANGED(Core_Sub_Status__c) ), Core_IPS_Is_Notification_Active__c = TRUE ) -------------------------------------------------------------------------------------------------------------------*/    AND(Core_IPS_Is_Notification_Active__c = TRUE,   	IF(  		OR( RecordTypeId = $Label.Core_IPS_Case_Create_RecordType_Id, RecordTypeId = $Label.Core_IPS_Closed_Case_RT_Id, RecordTypeId = $Label.Core_IPS_No_Assigned_Contact_Case_RT_Id), 		 		OR( ISCHANGED(Core_Severity__c ),  		 			AND( OR(ISPICKVAL(Status, &quot;New&quot;), ISPICKVAL(Status, &quot;Open&quot;) ), ISCHANGED( Core_Last_Case_Comment__c ) ), 			 			AND( NOT( OR(ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Close*&quot;) , 		ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Reopen&quot;) ) ), 			 				OR( ISCHANGED(ContactId), ISCHANGED(AssetId), ISCHANGED(Core_IPS_Project_Case__c),  				 					AND ( NOT(ISPICKVAL((PRIORVALUE(Core_Sub_Status__c)), &quot;Close-Pending&quot;)),ISCHANGED(Core_Sub_Status__c) ) 				 					 				)  			)  		), 		 		AND(RecordTypeId = $Label.Core_IPS_GEC_ReadOnly_RT_Id,  			OR( ISCHANGED(ContactId), ISCHANGED(AssetId), ISCHANGED(Core_IPS_Project_Case__c),  			 				AND ( NOT(ISPICKVAL((PRIORVALUE(Core_Sub_Status__c)), &quot;Close-Pending&quot;)),ISCHANGED(Core_Sub_Status__c) ),  			 				ISCHANGED(Core_Severity__c )  			),  			 			NOT( OR(ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Close*&quot;) , ISPICKVAL(Core_Sub_Status__c, &quot;Customer Requesting Reopen&quot;) ) )  		 		)  	 	)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Case SA Assigned</fullName>
        <actions>
            <name>Core_IPS_Self_Assigned_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Core_IPS_Self_Assigned__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>IPS Case SA: When a Case is created/updated with record type as Self Assigned then tick the checkbox field named Self Assigned.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS GEC Flow Changes</fullName>
        <actions>
            <name>Change_to_GEC_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_Change_the_Case_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_GEC_Flow_Changes</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_GEC_Sub_Status_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_Updates_the_GEC_Flag_to_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Core_IPS_GEC_Case__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case,IPS Case Create,IPS Closed Case,IPS GEC ReadOnly</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>IPS Data Migration</value>
        </criteriaItems>
        <description>Used for manual change of a regular IPS case to a MAG case. When an internal user checks the GEC Case checkbox on a case, this workflow will change the case to a GEC record type and kick off the GEC process flow.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS GEC Status For Approved</fullName>
        <actions>
            <name>Core_IPS_GEC_Flow_Approve_Status_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_GEC_Is_Stopped_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_GEC_Sub_Status_Changed_To_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_Main_Status_As_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When GEC team sets the GEC Status = Approved then the Main Case Status automatically should be changed to New, IsStopped becomes False and Record Type is changed to IPS Case Create.</description>
        <formula>IF(AND(ISPICKVAL(Core_IPS_GEC_Status__c,&apos;Approved&apos;), OR(Core_IPS_GEC_Case__c = TRUE,Core_IPS_GEC_Flag__c = TRUE)),TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS GEC Status For Permanent Hold</fullName>
        <actions>
            <name>Core_IPS_Closed_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When GEC team sets the GEC Status = Not Approved, then the main case Status automatically is changed to Closed.</description>
        <formula>IF(AND(ISPICKVAL(Core_IPS_GEC_Status__c,&apos;Not Approved&apos;), OR(Core_IPS_GEC_Flag__c = TRUE, Core_IPS_GEC_Case__c = TRUE)),TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core IPS Update case Origin for Customers</fullName>
        <actions>
            <name>Core_IPS_Update_case_Origin_for_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL($User.UserType,&apos;PowerCustomerSuccess&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core MDF Update Review Case Status</fullName>
        <actions>
            <name>Core_MDF_Update_Review_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Review Case Status will be updated to Pending Documents once the required more document checkbox checked.</description>
        <formula>IF(RecordType.DeveloperName==&apos;Core_MDF_Audit&apos; &amp;&amp; Core_MDF_More_Documentation_Required__c , true, false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Backend_Promotion_Outbound_Capture</fullName>
        <actions>
            <name>Core_IPS_Case_Promote_Count</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This WF capture the outbound case promotion details</description>
        <formula>AND(Core_IPS_Backend_System__c &lt;&gt; null, Core_IPS_Backend_ID__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Deactivated__c = false ,Core_IPS_BK_Flds_UpdatedAt__c &lt;&gt; Core_IPS_BK_Flds_UpdatedAt_PreVal__c , NOT(ISPICKVAL( Status , &apos;Closed&apos;)), ($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;) )  || AND(Core_IPS_Backend_System__c &lt;&gt; null, Core_IPS_Backend_ID__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Deactivated__c = false , Core_IPS_Backend_Previous_Status__c &lt;&gt; null, Core_IPS_Backend_Previous_Status__c &lt;&gt; &apos;&apos;, OR(ISCHANGED(Core_IPS_Backend_Previous_Status__c), ISCHANGED(Core_Sub_Status__c)) , ($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Backend_Promotion_Success_Capture</fullName>
        <actions>
            <name>Core_IPS_BK_Promote_Success_DT</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_Case_Promote_Inbound_Count</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This WF capture case promotion success details</description>
        <formula>ISCHANGED( Core_Promote_Status__c ) &amp;&amp; ISPICKVAL(Core_Promote_Status__c , &apos;DONE&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Backend_Promotion_Time_Capture_WF</fullName>
        <actions>
            <name>Core_IPS_BK_Promote_End_DateTime_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_BK_Promote_Start_DateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This WF capture the case promotion details</description>
        <formula>AND( (($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;)|| CONTAINS($User.Username, &apos;ips.file.integrationuser&apos;)),Core_IPS_Backend_ID__c == null,  Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Deactivated__c  = false,  ISPICKVAL( Core_Promote_Status__c , &apos;In Progress&apos;) , NOT(ISPICKVAL( Status , &apos;Closed&apos;)), ( ISBLANK(TEXT(Core_IPS_GEC_Status__c)) || ISPICKVAL( Core_IPS_GEC_Status__c, &apos;Approved&apos;) || ISPICKVAL( Core_IPS_GEC_Status__c, &apos;Approved with Guardrails&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_CaseClassification</fullName>
        <actions>
            <name>Core_IPS_CaseClassification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>The Classification value should default to &apos;Intel Confidential&apos; if the Account on the Case has an NDA. The Classification value should set to &apos;Public&apos; if the Account on the Case has no NDA.</description>
        <formula>AND($Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;,NOT(ISBLANK( Account.Core_CNDA_Number__c )))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_CaseClose_RecTypeChange</fullName>
        <actions>
            <name>Core_IPS_Chg_to_Case_Closed_Record_type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case,IPS Case Create,IPS GEC ReadOnly,IPS Case Read Only</value>
        </criteriaItems>
        <description>When an IPS Case status = Closed, change the record type to Case Closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Case_Backend_WF</fullName>
        <actions>
            <name>Core_IPS_Case_Backend_OutMsg</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>This work rule sends outbound message for a Case required to be promoted to backend System (JIRA, HSD ES..etc)</description>
        <formula>AND( (($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;)|| CONTAINS($User.Username, &apos;ips.file.integrationuser&apos;)),Core_IPS_Backend_ID__c == null,  Core_IPS_Backend_System__c !=null,  ISPICKVAL( Core_Promote_Status__c , &apos;In Progress&apos;) , NOT(ISPICKVAL( Status , &apos;Closed&apos;)), ( ISBLANK(TEXT(Core_IPS_GEC_Status__c)) || ISPICKVAL( Core_IPS_GEC_Status__c, &apos;Approved&apos;) || ISPICKVAL( Core_IPS_GEC_Status__c, &apos;Approved with Guardrails&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Case_Backend_depromotion_WF</fullName>
        <actions>
            <name>Core_IPS_Case_Depromote_Backend_OutMsg</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>This work rule sends outbound message for a Case when product and org got changed</description>
        <formula>AND( (CONTAINS( Core_IPS_Backend_Previous_Status__c ,&apos;disassociate&apos;)) ,(($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;)||(CONTAINS($User.Username, &apos;ips.file.integrationuser&apos;))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Case_FieldUpdate_Backend_WF</fullName>
        <actions>
            <name>Core_IPS_CaseFieldUpdate_Backend_OutMsg</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>This workflow triggers the outbound message to send backed relevant case fields updates including environmental details</description>
        <formula>AND(Core_IPS_Backend_System__c &lt;&gt; null,   Core_IPS_Backend_ID__c &lt;&gt; null,   Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null,  Core_IPS_Backend_System__r.Core_IPS_Deactivated__c = false ,Core_IPS_BK_Flds_UpdatedAt__c &lt;&gt;  Core_IPS_BK_Flds_UpdatedAt_PreVal__c , NOT(ISPICKVAL( Status , &apos;Closed&apos;)), ($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Case_Populate_Assigned_Case_Field</fullName>
        <actions>
            <name>Core_IPS_Update_Custom_Case_Queue_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>rule to auto-populate the Last Assigned Queue field on case.  Only assigns a value when case owner is set to a queue and then again anytime the owner changes to a different queue.</description>
        <formula>AND(Owner:Queue.Id &lt;&gt; NULL, CONTAINS(RecordType.DeveloperName, &quot;IPS_&quot;),Or(ISCHANGED(OwnerId), Isnew()))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Case_Send_Assignment_Notification</fullName>
        <actions>
            <name>Core_IPS_Case_Notif_Int_Assignment_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends IPS case assignment emails whenever: A new case is created, a case owner is changed, or the product on a case is changed.  Will exclude sending emails to a queue if the queue is in the exclusion custom label: Core_IPS_Case_Q_Exclude_Asgnmt_Email</description>
        <formula>AND(   $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;, /*Case must be of IPS record type */  CONTAINS(RecordType.DeveloperName, &apos;IPS_&apos;),  /*Ignore cases that specifically want notifications disabled by the the Migration Team */  Core_IPS_Is_Notification_Active__c,  /*If case owner is a queue and not a user then check if the queue id is in the queue notification exclusion list stored in custom label - if so, do not send notification */  IF(ISBLANK(Owner:Queue.Id), TRUE, NOT (CONTAINS($Label.Core_IPS_Case_Q_Exclude_Asgnmt_Email,Owner:Queue.DeveloperName))),  /*Case must also be new or have an owner change or a product change in order to send notification*/ OR( ISNEW(),ISCHANGED(OwnerId),ISCHANGED(Core_IPS_Product__c) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Case_StatusUpdate_Backend_WF</fullName>
        <actions>
            <name>Core_IPS_CaseStatusUpdate_Backend_OutMsg</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>This workflow triggers the outbound message to send backed relevant case status field updates</description>
        <formula>AND(Core_IPS_Backend_System__c &lt;&gt; null, Core_IPS_Backend_ID__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null, Core_IPS_Backend_System__r.Core_IPS_Deactivated__c = false , Core_IPS_Backend_Previous_Status__c  &lt;&gt; null, Core_IPS_Backend_Previous_Status__c  &lt;&gt; &apos;&apos;, OR(ISCHANGED(Core_IPS_Backend_Previous_Status__c), ISCHANGED(Core_Sub_Status__c)) , ($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Set_Status_Closed_after_20Days_ClosePending</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Core_Sub_Status__c</field>
            <operation>equals</operation>
            <value>Close-Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case,IPS Case Create,IPS Closed Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>US78262-System sets Case to Closed if no response from Customer Contact or ISO (FAE) within 20d.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_IPS_Chg_to_Case_Closed_Record_type</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Core_IPS_Closed_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Core_IPS_Closed_Sub_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>20</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_IPS_Uncheck_Customer_Visible</fullName>
        <actions>
            <name>Core_IPS_Uncheck_Customer_Visible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IPS No Assigned Contact Case</value>
        </criteriaItems>
        <description>Uncheck Customer Visible checkbox if case created of type No Assigned Case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Update Case Request Close Status</fullName>
        <actions>
            <name>Core_IPS_Update_Case_Request_Close_Stat</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_Update_Case_Request_Close_Statu</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Core_Request_Case_Close__c</field>
            <operation>equals</operation>
            <value>Close Case</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_UpdateCloseCaseRecordtype</fullName>
        <actions>
            <name>Core_IPS_UpdateCloseCaseRecordtype</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the record type  of the case after  the un-assigned case is re-open</description>
        <formula>AND(RecordType.DeveloperName = &apos;IPS_Closed_Case&apos;,ISPICKVAL(PRIORVALUE(Status),  &apos;Closed&apos;),NOT(ISPICKVAL(Status,&apos;Closed&apos;)) ,OR(ContactId=null,ContactId=&apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_UpdateCloseCaseRecordtypeWithContact</fullName>
        <actions>
            <name>Core_IPS_UpdateCloseCaseRecordtypeWithCo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the record type  of the case after  the un-assigned case is re-open</description>
        <formula>AND ( $User.ProfileId &lt;&gt; &apos;00e7A000000DfHp&apos;,  ( AND(Core_IPS_Self_Assigned__c=false ,NOT(ISNEW()),RecordType.DeveloperName = &apos;IPS_Closed_Case&apos;,ISPICKVAL(PRIORVALUE(Status),  &apos;Closed&apos;),NOT(ISPICKVAL(Status,&apos;Closed&apos;)),ContactId!=null) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_UpdateCloseCaseRecordtypeWithContact1</fullName>
        <actions>
            <name>Core_IPS_UpdateCloseCaseRecordtypeWithc1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the record type  of the case after  the un-assigned case is re-open</description>
        <formula>AND ( $User.ProfileId &lt;&gt; &apos;00e7A000000DfHp&apos;,  ( AND(Core_IPS_Self_Assigned__c=true,NOT(ISNEW()),RecordType.DeveloperName = &apos;IPS_Closed_Case&apos;,ISPICKVAL(PRIORVALUE(Status),  &apos;Closed&apos;),NOT(ISPICKVAL(Status,&apos;Closed&apos;)),ContactId!=null) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF Notifications to Partner for Claim Review Outcome Notice</fullName>
        <actions>
            <name>Core_MDF_Notifying_Partner_for_Claim_Review_Status_Notice</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Notification will be sent to Partner if the value of field &quot;Review Case Status&quot; is changed to either &quot;Compliant&quot; or &quot;Non-compliant&quot;</description>
        <formula>ISCHANGED(Core_MDF_Review_Case_Status__c) &amp;&amp; (RecordType.DeveloperName==&apos;Core_MDF_Audit&apos;) &amp;&amp; (ISPICKVAL(Core_MDF_Review_Case_Status__c,&apos;Compliant&apos;)||ISPICKVAL(Core_MDF_Review_Case_Status__c,&apos;Non-compliant&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF Notifications to Partner of Case Creation</fullName>
        <actions>
            <name>Core_MDF_Notifying_Partner_on_Case_creation_with_Under_Review_Status</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Notification will be sent to Partner when Case is created and Case in &quot;Under Review&quot; Status.</description>
        <formula>(RecordType.DeveloperName==&apos;Core_MDF_Audit&apos;) &amp;&amp;   (ISPICKVAL(Core_MDF_Status__c,&apos;Under Review&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF Notifications to Partner of Documents Required</fullName>
        <actions>
            <name>Core_MDF_Immediate_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>(RecordType.DeveloperName==&apos;Core_MDF_Audit&apos;) &amp;&amp;   (ISPICKVAL(Core_MDF_Status__c,&apos;Pending Documents&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Email_Alert_Before_15_Days_of_Document_Submission_Deadline_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Core_MDF_DocumentSubmissionDeadlineDate__c</offsetFromField>
            <timeLength>-15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Change_status_to_Non_Compliant</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Core_MDF_DocumentSubmissionDeadlineDate__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Email_Alert_Before_5_Days_of_Document_Submission_Deadline_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Core_MDF_DocumentSubmissionDeadlineDate__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_MDF Notifications to Partner of Documents Required v1</fullName>
        <actions>
            <name>Core_MDF_Immediate_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule is updated version of workflow rule&quot;Rule Core_MDF Notifications to Partner of Documents Required&quot;. Cases were getting closed on 29th day instead of 30th. Modified time trigger for field update &quot;Change status to Non-Compliant&quot; as a fix.</description>
        <formula>(RecordType.DeveloperName==&apos;Core_MDF_Audit&apos;) &amp;&amp;   (ISPICKVAL(Core_MDF_Status__c,&apos;Pending Documents&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Email_Alert_Before_15_Days_of_Document_Submission_Deadline_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Core_MDF_DocumentSubmissionDeadlineDate__c</offsetFromField>
            <timeLength>-15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Email_Alert_Before_5_Days_of_Document_Submission_Deadline_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Core_MDF_DocumentSubmissionDeadlineDate__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Change_status_to_Non_Compliant</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Core_MDF_DocumentSubmissionDeadlineDate__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_MDF Notifications to Partner of Documents Required v2</fullName>
        <actions>
            <name>Core_MDF_Immediate_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule is updated version of workflow rule &quot;Core_MDF Notifications to Partner of Documents Required v1&quot;. Updated Document Submission Due Date (Date) field with Document Submission Due Date (Date/Time) field.</description>
        <formula>(RecordType.DeveloperName==&apos;Core_MDF_Audit&apos;) &amp;&amp;   (ISPICKVAL(Core_MDF_Status__c,&apos;Pending Documents&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Email_Alert_Before_15_Days_of_Document_Submission_Deadline_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Core_MDF_Document_Submission_DueDate_dtm__c</offsetFromField>
            <timeLength>-15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Email_Alert_Before_5_Days_of_Document_Submission_Deadline_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Core_MDF_Document_Submission_DueDate_dtm__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Change_status_to_Non_Compliant</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Core_MDF_Document_Submission_DueDate_dtm__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
