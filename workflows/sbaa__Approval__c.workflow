<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSG_Notify_on_Quote_approval</fullName>
        <description>PSG - Notify on Quote approval</description>
        <protected>false</protected>
        <recipients>
            <field>sbaa__ApprovedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSG_Email_Templates/PSG_Quote_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>PSG_Notify_on_Quote_rejection_app</fullName>
        <description>PSG - Notify on Quote rejection app</description>
        <protected>false</protected>
        <recipients>
            <field>core_cpq_Distributor__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>sbaa__RejectedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSG_Email_Templates/PSG_CP_Quote_Reject_Notification</template>
    </alerts>
</Workflow>
