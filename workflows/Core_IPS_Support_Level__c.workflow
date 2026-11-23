<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_SupportOrgAndAccountKeyUpdate</fullName>
        <field>Core_IPS_SupportOrgAndAccountKey__c</field>
        <formula>LEFT(Core_IPS_Support_Org__c , 15) &amp; LEFT(Core_IPS_Account__c, 15)</formula>
        <name>SupportOrgAndAccountKeyUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_IPS_UpdateSupportLevelUniqueKey</fullName>
        <actions>
            <name>Core_IPS_SupportOrgAndAccountKeyUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the SupportOrgAndAccountKey Field.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
