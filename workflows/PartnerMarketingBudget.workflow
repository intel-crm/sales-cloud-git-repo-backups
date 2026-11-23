<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_MDF_Status_Change_to_Approved</fullName>
        <description>After approval, Budget status field will be updated with &quot;approved&quot; value.</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status Change to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_Change_to_Rejected</fullName>
        <description>After rejection, Budget status field will be updated with &quot;rejected&quot; value</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Status Change to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
