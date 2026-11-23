<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_Adjustment_Creation_Notification_for_Adj_Req_from_Adjustment_Request</fullName>
        <description>Adjustment Creation Notification for Adj Req from Adjustment Request</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Ref_Claim_Owner_Email_Txt__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_MDF_Claim_Adj_Create_fromAdjReq_Ext</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Adjustment_Creation_Notification_for_Adj_Req_to_Internal_User</fullName>
        <description>Adjustment Creation Notification for Adj Req to internal User</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Ref_Claim_Owner_Email_Txt__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_MDF_Claim_Adj_Create_fromAdjReq_Int</template>
    </alerts>
</Workflow>
