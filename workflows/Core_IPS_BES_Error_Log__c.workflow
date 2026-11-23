<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_BES_Support_Notification</fullName>
        <description>Support Team Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>12217293@intel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tusharx.garg.devcase@intel.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_IPS_BES_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_BES_Technical_Error</fullName>
        <description>Tecnnical Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>12217293@intel.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tusharx.garg.devcase@intel.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_BES_Technical_Notification</template>
    </alerts>
    <alerts>
        <fullName>Sending_mails_on_failure_to_respective_PDLs</fullName>
        <ccEmails>karthik.bandlax@intel.com</ccEmails>
        <description>Sending mails on failure to respective PDLs</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case_Outbound_failure_Recipients</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Sending_mails_on_Case_failure</template>
    </alerts>
    <rules>
        <fullName>Retry Count Email alert</fullName>
        <actions>
            <name>Sending_mails_on_failure_to_respective_PDLs</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(ISCHANGED( Core_IPS_Retry_Count__c ), Core_IPS_Retry_Count__c  &gt;= 3  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
