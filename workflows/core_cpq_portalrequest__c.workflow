<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_for_PSG_Disty_Field_Update_Request_From_Chatbot</fullName>
        <description>Email alert for PSG Disty Field Update Request From Chatbot</description>
        <protected>false</protected>
        <recipients>
            <field>core_cpq_approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSG_Email_Templates/PSG_Disty_Field_Update_Request_From_bot</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_for_PSG_Disty_Quote_Deactivation_Request_From_Chatbot</fullName>
        <description>Email alert for PSG Disty Quote Deactivation Request From Chatbot</description>
        <protected>false</protected>
        <recipients>
            <field>core_cpq_approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSG_Email_Templates/PSG_Disty_Quote_Deactivation_From_bot</template>
    </alerts>
</Workflow>
