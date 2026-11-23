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
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Opportunity_Management/Opportunity_Support_Team_Submit</template>
    </alerts>
    <alerts>
        <fullName>Test_Submit_Oppty_Support_Team</fullName>
        <description>Test_Submit Oppty Support Team</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Opportunity_Support_Team_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_Support_Test</template>
    </alerts>
    <alerts>
        <fullName>Test_Submit_Oppty_Support_Team_Approve_Reject</fullName>
        <description>Test_Submit Oppty Support Team Approve/Reject</description>
        <protected>false</protected>
        <recipients>
            <recipient>Team Member (100%)</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>11723537@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_Opportunity_Support_Rejection_Email_Template</template>
    </alerts>
</Workflow>
