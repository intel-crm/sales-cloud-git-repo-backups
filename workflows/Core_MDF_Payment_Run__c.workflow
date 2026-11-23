<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_PaymentRun_Status_Completed</fullName>
        <description>Core_MDF_PaymentRun_Notifications_Status_Completed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_PaymentRun_Status_Completed</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_PaymentRun_Status_Error</fullName>
        <description>Core_MDF_PaymentRun_Notifications_Status_Error</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_PaymentRun_Status_Error</template>
    </alerts>
</Workflow>
