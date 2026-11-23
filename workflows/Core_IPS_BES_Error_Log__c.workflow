<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_BES_Support_Notification</fullName>
        <description>Support Team Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>12217293@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chetanx.yashwant.karanda@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>intel.premier.support.qa@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_IPS_BES_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_BES_Technical_Error</fullName>
        <description>Tecnnical Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>12217293@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chetanx.yashwant.karanda@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>intel.premier.support.qa@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_BES_Technical_Notification</template>
    </alerts>
</Workflow>
