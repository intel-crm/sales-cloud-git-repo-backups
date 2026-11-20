<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sales_Alert_Order_Owner_on_SAP_submission_failure</fullName>
        <description>Alert Order Owner on SAP submission failure</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Order_Management/Sales_Order_Creation_Failed</template>
    </alerts>
</Workflow>
