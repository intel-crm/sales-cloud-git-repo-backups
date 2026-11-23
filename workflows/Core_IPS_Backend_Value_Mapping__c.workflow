<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_Case_BK_FieldVal_Map_UniqueKey</fullName>
        <field>Core_IPS_Unique_Identifier_Key__c</field>
        <formula>Core_IPS_Backend_Field_Mapping__c &amp; Core_IPS_Source_Value__c &amp; Core_IPS_Target_Value__c &amp;  Core_IPS_Previous_Source_Value__c</formula>
        <name>Core IPS Case BK FieldVal Map UniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_IPS_Case_BK_FieldVal_Map_UniqueKey</fullName>
        <actions>
            <name>Core_IPS_Case_BK_FieldVal_Map_UniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Core_IPS_Target_Value__c &lt;&gt; null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
