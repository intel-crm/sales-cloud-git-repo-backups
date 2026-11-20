<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_PRM_Update_Status_Change_Date</fullName>
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
        <fullName>PRM_Channel_Program_Level_Status_Change</fullName>
        <actions>
            <name>Core_PRM_Update_Status_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow is used to update the Status Change Date field whenever the Channel Program Level is changed (status changed to either Active or Inactive )</description>
        <formula>OR(ISCHANGED( PRM_Status_Nm__c ), ISCHANGED( PRM_Channel_Program_Level_Id__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
