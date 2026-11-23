<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Opportunity_Support_Team_Member_Assigned</fullName>
        <description>Opportunity Support Team Member Assigned</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Opportunity_Support_Team_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Opportunity_Management/Opportunity_Support_Team_Submit</template>
    </alerts>
</Workflow>
