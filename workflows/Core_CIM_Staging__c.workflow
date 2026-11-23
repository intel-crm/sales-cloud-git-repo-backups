<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CIMtoSFInvalidRecordsEmail</fullName>
        <description>CIMtoSFInvalidRecordsEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>CIM_Failure_UserGroup</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CIM_Invalid_Records</template>
    </alerts>
    <alerts>
        <fullName>CIMtoSFfailedRecordsEmail</fullName>
        <description>CIMtoSFfailedRecordsEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>CIM_Failure_UserGroup</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CIM_Failure_Records</template>
    </alerts>
    <alerts>
        <fullName>Send_email_when_Cim_status_is_failed</fullName>
        <description>Send email when Cim status is failed</description>
        <protected>false</protected>
        <recipients>
            <recipient>12016582@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CIM_stage_Record_Failed</template>
    </alerts>
</Workflow>
