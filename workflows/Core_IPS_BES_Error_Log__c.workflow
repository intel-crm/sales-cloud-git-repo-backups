<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_BES_Support_Notification</fullName>
        <description>Support Team Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>11962478@intel.com.crm</recipient>
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
            <recipient>11962478@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_BES_Technical_Notification</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Error_Notification</fullName>
        <description>Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>11962478@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Exception_Notification</template>
    </alerts>
</Workflow>
