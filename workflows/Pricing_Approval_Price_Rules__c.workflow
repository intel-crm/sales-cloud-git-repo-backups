<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Approval_Status_Update_To_Approve</fullName>
        <field>Pricing_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status Update To Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pricing_Update_Status_to_Rejected</fullName>
        <field>Pricing_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status Update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
