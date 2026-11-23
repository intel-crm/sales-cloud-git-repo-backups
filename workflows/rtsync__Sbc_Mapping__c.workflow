<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>rtsync__Update_Unique_Tuple_Field</fullName>
        <field>rtsync__Unique_Tuple__c</field>
        <formula>rtsync__sObjectType__c + rtsync__Record_Type_Id__c</formula>
        <name>Update Unique Tuple Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>rtsync__Update Unique Tuple</fullName>
        <actions>
            <name>rtsync__Update_Unique_Tuple_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
