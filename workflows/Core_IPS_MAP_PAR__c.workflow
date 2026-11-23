<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Send_email_receipt_to_PAR_Submitter</fullName>
        <description>Send email receipt to PAR Submitter</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_PAR_Internal_Created</template>
    </alerts>
    <rules>
        <fullName>Core_PAR_Create_Notify_Submitter</fullName>
        <actions>
            <name>Core_Send_email_receipt_to_PAR_Submitter</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Core_IPS_MAP_PAR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PAR</value>
        </criteriaItems>
        <description>Send 1 email per PAR header to the PAR submitter</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
