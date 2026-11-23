<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Entitlement_Request_Approved_Email</fullName>
        <description>Entitlement Request Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Entitlement_Automation/Core_EntitlementRequest_Approved</template>
    </alerts>
    <alerts>
        <fullName>Core_Entitlement_Request_Rejected_Email</fullName>
        <description>Entitlement Request Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Entitlement_Automation/Core_EntitlementRequest_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>EntitleRequest_Status_Approved</fullName>
        <field>Core_Status_Nm__c</field>
        <literalValue>Approved</literalValue>
        <name>EntitleRequest - Status - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EntitleRequest_Status_Rejected</fullName>
        <field>Core_Status_Nm__c</field>
        <literalValue>Rejected</literalValue>
        <name>EntitleRequest - Status - Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EntitleRequest_Status_Submitted</fullName>
        <field>Core_Status_Nm__c</field>
        <literalValue>Submitted</literalValue>
        <name>EntitleRequest - Status - Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
