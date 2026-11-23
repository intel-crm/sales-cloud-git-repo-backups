<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_External_Email_Notification_New_EA</fullName>
        <description>Email Notification For External Interested Party</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>intel.premier.support.qa@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External_Interested_Party_New_EA</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Internal_Email_Notification_New_EA</fullName>
        <description>Email Notification For Internal Interested Party</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>intel.premier.support.qa@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Interested_Party_New_EA</template>
    </alerts>
</Workflow>
