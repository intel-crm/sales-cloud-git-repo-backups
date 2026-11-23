<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PRM_Approve_Registration_Request</fullName>
        <description>This will set the status of  Registration Request to &apos;Approved&apos;</description>
        <field>PRM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approve Registration Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Reject_Registration_Request</fullName>
        <description>This will set the Registration Request status to &apos;Rejected&apos;</description>
        <field>PRM_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reject Registration Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Record_Lock</fullName>
        <description>To Check record is Locked or not</description>
        <field>PRM_isLocked__c</field>
        <literalValue>1</literalValue>
        <name>Update Record Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Submit_Request</fullName>
        <description>It updates &apos;isSubmitted&apos; field to true</description>
        <field>PRM_isSubmitted__c</field>
        <literalValue>1</literalValue>
        <name>Update Submit Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
