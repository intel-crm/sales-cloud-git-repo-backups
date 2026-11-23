<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PRM_Update_Status_Change_Date</fullName>
        <description>This will save the Last Modified Date field into the Status Change Date field.</description>
        <field>PRM_Status_Change_Dt__c</field>
        <formula>LastModifiedDate</formula>
        <name>Update Status Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PRM_Account_Specialty_Association_Status_Change</fullName>
        <actions>
            <name>PRM_Update_Status_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to update the Status Change Date field whenever the status is changed</description>
        <formula>ISCHANGED( PRM_InActive_Ind__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
