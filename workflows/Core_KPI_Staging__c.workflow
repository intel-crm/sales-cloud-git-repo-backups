<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>KPIfailedRecordsEmail</fullName>
        <description>KPIfailedRecordsEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_KPI_Failure_UserGroup</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Opportunity_Management/Core_KPI_Failure_Template</template>
    </alerts>
</Workflow>
