<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_Case_BK_PromoteUpdate_Failure_Notify</fullName>
        <ccEmails>sushma.hamom@intel.com</ccEmails>
        <description>Core IPS Case BK PromoteUpdate Failure Notify</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Support_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>gangadharx.raju.udayabhanu.devcase@intel.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Internal_Backend_Integration_Error</template>
    </alerts>
    <alerts>
        <fullName>Quality_Builder_EmailAlert_For_Survey_Failure</fullName>
        <description>Quality Builder Email Alert  For Survey Failure</description>
        <protected>false</protected>
        <recipients>
            <recipient>12241492@intel.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Quality_Builder_Emails_For_Survey_Failure</template>
    </alerts>
    <rules>
        <fullName>Core_IPS_Case_Notify_BKPromote_Failure_WF</fullName>
        <actions>
            <name>Core_IPS_Case_BK_PromoteUpdate_Failure_Notify</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow sends notification to IPS Technical Support Group for Backend Promotion/Update Failure</description>
        <formula>AND( Core_Project__c = &apos;IPS Cloud&apos;,  Core_Severity__c = &apos;error&apos; , OR( Core_sObjectType__c = &apos;sf:Case&apos;, Core_sObjectType__c = &apos;sf:Core_IPS_Case_Comments__c&apos;,  Core_sObjectType__c = &apos;sf:Core_IPS_Case_Attachments__c&apos;), Core_Support_Email__c &lt;&gt; null)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
