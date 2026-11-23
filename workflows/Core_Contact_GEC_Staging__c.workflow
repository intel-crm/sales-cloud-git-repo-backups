<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_if_GEC_record_is_failed_3_times</fullName>
        <description>Send Email if GEC record is failed 3 times</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_Contact_GEC_EmailNotify_list</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>export.customer@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_GEC_Failed_Notification</template>
    </alerts>
    <rules>
        <fullName>Core_SendEmail_On_FailedGECRec</fullName>
        <actions>
            <name>Send_Email_if_GEC_record_is_failed_3_times</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_Contact_GEC_Staging__c.Core_Status__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Core_Contact_GEC_Staging__c.Core_GEC_Retry_Counter__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
