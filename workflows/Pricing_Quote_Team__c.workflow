<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Pricing_Send_email_notification_to_Quote_Team_Member</fullName>
        <description>Pricing Send email notification to Quote Team Member</description>
        <protected>false</protected>
        <recipients>
            <field>Pricing_Quote_Team_Member_Id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteTeam_EmailNotification</template>
    </alerts>
</Workflow>
