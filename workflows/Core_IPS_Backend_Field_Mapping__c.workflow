<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_Case_BK_Field_Map_UniqueKey</fullName>
        <field>Core_IPS_Unique_Identifier_Key__c</field>
        <formula>Core_IPS_Backend_System__c &amp;  Core_IPS_Source_System__c &amp;  Core_IPS_Target_System__c &amp;  Core_IPS_Source_Field__c  &amp; Core_IPS_Target_Field__c</formula>
        <name>Core IPS Case BK Field Map UniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_IPS_Case_BK_Field_Map_UniqueKey</fullName>
        <actions>
            <name>Core_IPS_Case_BK_Field_Map_UniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
