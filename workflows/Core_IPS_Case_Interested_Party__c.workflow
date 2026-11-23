<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_External_Email_Notification_New_EA</fullName>
        <description>Email Notification For External Interested Party</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
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
            <type>creator</type>
        </recipients>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>intel.premier.support.qa@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_Internal_Interested_Party_New_EA</template>
    </alerts>
    <alerts>
        <fullName>Test_Email_Notification</fullName>
        <ccEmails>amriteshx.sahu@intel.com</ccEmails>
        <ccEmails>yogeshx.sharma@intel.com</ccEmails>
        <description>Test_Email_Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IPS_Email_Templates_PSG_Onboarding/Core_IPS_Case_External_Interested_Party_New_EA</template>
    </alerts>
    <rules>
        <fullName>Test Interested Party</fullName>
        <actions>
            <name>Test_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_IPS_Case_Interested_Party__c.Type__c</field>
            <operation>equals</operation>
            <value>External</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
