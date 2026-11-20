<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PRM_Status_Update</fullName>
        <description>Updating the status to approved when Grouping method value is selected</description>
        <field>PRM_Recommendation_Status_Nm__c</field>
        <literalValue>In Process</literalValue>
        <name>Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PRM_Recommendation_Status_Update</fullName>
        <actions>
            <name>PRM_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow rule is used to update the status when user selects Grouping Method</description>
        <formula>AND(     ISNEW(),      ISPICKVAL( PRM_Recommendation_Status_Nm__c , &quot;New&quot;),      NOT( ISPICKVAL( PRM_Grouping_Method_Nm__c , &quot;&quot;) ),      RecordType.DeveloperName = &quot;PRM_OPID_Recommendation&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
