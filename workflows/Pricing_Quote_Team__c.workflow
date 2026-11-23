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
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteTeam_EmailNotification</template>
    </alerts>
    <rules>
        <fullName>Pricing_Send_Notification_to_Quote_Team_Member</fullName>
        <actions>
            <name>Pricing_Send_email_notification_to_Quote_Team_Member</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>To send notification to Quote team member on record creation</description>
        <formula>NOT((Pricing_Quote_Id__r.Pricing_Account_Executive_Nm__c == Pricing_Quote_Id__r.CreatedById &amp;&amp; Pricing_Quote_Id__r.Pricing_Account_Executive_Nm__c ==  $User.Id &amp;&amp;  Pricing_Quote_Team_Member_Id__c == $User.Id) ||  ((TEXT(Pricing_Role_Nm__c) == $Label.Pricing_Quote_Team_Role_ITS) &amp;&amp; (Pricing_Quote_Team_Member_Id__c == $User.Id) &amp;&amp; (Pricing_Quote_Id__r.CreatedById == Pricing_Quote_Team_Member_Id__c)) || (TEXT(Pricing_Role_Nm__c) == $Label.Pricing_Quote_Team_Role_FSE))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
