<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_Case_BK_PromoteUpdate_Failure_Notify</fullName>
        <description>Core IPS Case BK PromoteUpdate Failure Notify</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Support_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IPS_Email_Templates/Core_IPS_Internal_Backend_Integration_Error</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Trigger_Error_Notification</fullName>
        <description>Trigger_Error_Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Support_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_CCP_Error_Notification_Template</template>
    </alerts>
    <rules>
        <fullName>Core_IPS_Case_Notify_BKPromote_Failure_WF</fullName>
        <actions>
            <name>Core_IPS_Case_BK_PromoteUpdate_Failure_Notify</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow sends notification to IPS Technical Support Group for Backend Promotion/Update Failure</description>
        <formula>AND( Core_Project__c = &apos;IPS Cloud&apos;,  Core_Severity__c = &apos;error&apos; , OR( Core_sObjectType__c = &apos;sf:Case&apos;, Core_sObjectType__c = &apos;sf:Core_IPS_Case_Comments__c&apos;,  Core_sObjectType__c = &apos;sf:Core_IPS_Case_Attachments__c&apos;), Core_Support_Email__c &lt;&gt; null)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF_CCP_Error_Notification</fullName>
        <actions>
            <name>Core_MDF_Trigger_Error_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Core_Log_Entry__c.Core_Project__c</field>
            <operation>equals</operation>
            <value>Consolidated Co-Marketing Program (CCP)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Core_Log_Entry__c.Core_Severity__c</field>
            <operation>equals</operation>
            <value>Critical</value>
        </criteriaItems>
        <description>Trigger error notification email on creation of Log entry for CCP.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
