<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_AutoPopulate_Plain_Comment</fullName>
        <field>Core_IPS_Comment__c</field>
        <formula>Core_IPS_Rich_Comment__c</formula>
        <name>Core IPS AutoPpulat Plain Cmmnt-Case RTF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test_for_plain_update_case_rtf_to_delete</fullName>
        <field>Test_fro_plain__c</field>
        <formula>Core_IPS_Rich_Comment__c</formula>
        <name>test for plain update case rtf to delete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Core_IPS_RTF_CaseComment_Backend_OutMsg</fullName>
        <apiVersion>35.0</apiVersion>
        <endpointUrl>https://dummy_user1:7Ha8oBPw!1!c@eip-generic-dummygroup2.cloudhub.io/smit/api/ips/NewIPSCaseUpdate</endpointUrl>
        <fields>Core_IPS_Case__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>ips.backend.integrationuser@intel.com.crm</integrationUser>
        <name>Core_IPS_RTF_CaseComment_Backend_OutMsg</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Core_IPS_RTF_CaseComment_Backend_WF</fullName>
        <actions>
            <name>Core_IPS_RTF_CaseComment_Backend_OutMsg</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <formula>AND( ($Profile.Name &lt;&gt; &apos;Integration&apos; &amp;&amp; $Profile.Name &lt;&gt; &apos;IPS Data Migration&apos;), Core_IPS_Case__r.Core_IPS_Backend_ID__c &lt;&gt; null ,  Core_IPS_Case__r.Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c &lt;&gt; null , Core_IPS_Case__r.Core_IPS_Backend_System__r.Core_IPS_Deactivated__c = false,  OR(ISPICKVAL(Core_Promote_Status__c, &apos;&apos;), ISPICKVAL(Core_Promote_Status__c, &apos;In Progress&apos;) ), OR( Core_IPS_Comment_Attachment_Id__c == null, Core_IPS_Comment_Attachment_Id__c == &apos;&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
