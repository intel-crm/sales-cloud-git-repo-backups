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
        <template>Testt/CIM_Invalid_Records</template>
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
        <template>Testt/CIM_Failure_Records</template>
    </alerts>
</Workflow>
