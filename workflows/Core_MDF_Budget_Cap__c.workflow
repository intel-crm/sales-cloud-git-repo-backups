<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_MDF_Approved_Status_Update</fullName>
        <field>Core_MDF_Cap_Status_nm__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Rejected_Status_Update</fullName>
        <field>Core_MDF_Cap_Status_nm__c</field>
        <literalValue>Revision Required</literalValue>
        <name>Rejected Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Approve_Cap_Amount</fullName>
        <description>Approve Cap Amount Update with Requested Cap Amout</description>
        <field>Core_MDF_Approved_Cap_amt__c</field>
        <formula>Core_MDF_Requested_Cap_amt__c</formula>
        <name>Update Approve Cap Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
