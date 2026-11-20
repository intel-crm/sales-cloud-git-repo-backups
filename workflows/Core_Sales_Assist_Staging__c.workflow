<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SalesAssitfailedRecordsEmail</fullName>
        <description>SalesAssitfailedRecordsEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_Sales_Assist_Failure_UserGroup</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Core_SalesAssist_Failure_Template</template>
    </alerts>
</Workflow>
