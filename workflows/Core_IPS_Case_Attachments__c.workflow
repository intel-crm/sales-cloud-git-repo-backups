<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_Attachment_Update_Case_Field_FU</fullName>
        <field>Core_IPS_File_Attachment_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Core IPS Attachment Update Case Field FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Core_Case__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_FUB</fullName>
        <field>Core_FileUploadedBy__c</field>
        <lookupValue>ips.backend.integrationuser@intel.com.crm</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Core_IPS_Update_FUB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Core_IPS_CaseAttachment_Backend_OutMsg</fullName>
        <apiVersion>34.0</apiVersion>
        <description>Backend Case Attachment Outbound Message</description>
        <endpointUrl>https://proxy_user1:7Ha8oBPw!1!c@eip-generic-proxygroup2-dev.cloudhub.io/smit/api/ips/NewIPSCaseUpdate</endpointUrl>
        <fields>Core_Case__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ips.backend.integrationuser@intel.com.crm</integrationUser>
        <name>Core_IPS_CaseAttachment_Backend_OutMsg</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Core IPS Attachment Update Case Field WF</fullName>
        <actions>
            <name>Core_IPS_Attachment_Update_Case_Field_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_IPS_Case_Attachments__c.Core_Upload_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>IPS Data Migration</value>
        </criteriaItems>
        <failedMigrationToolVersion>254.9.1</failedMigrationToolVersion>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_CaseAttachment_Backend_WF</fullName>
        <actions>
            <name>Core_IPS_CaseAttachment_Backend_OutMsg</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>This work rule sends outbound message for a case attachment created to an already promoted backend IPS case to backend System (JIRA, HSD ES..etc)</description>
        <formula>AND(Core_Case__r.Core_IPS_Backend_ID__c &lt;&gt; null, Core_Case__r.Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null, Core_Case__r.Core_IPS_Backend_System__r.Core_IPS_Deactivated__c = false , Core_Is_Migrated__c = false,(ISPICKVAL( Core_Promote_Status__c , &apos;&apos; ) || ISPICKVAL( Core_Promote_Status__c , &apos;In Progress&apos; )),(    ISPICKVAL(Core_Upload_Status__c, &apos;Complete&apos;)),  ( ($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;) || CONTAINS($User.Username, &apos;ips.file.integrationuser&apos;) || CONTAINS($User.Username, &apos;ips.backend.integrationuser&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Update_FUB_if_Null</fullName>
        <actions>
            <name>Core_IPS_Update_FUB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_IPS_Case_Attachments__c.Core_FileUploadedBy__c</field>
            <operation>equals</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>IPS Data Migration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
