<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Feature_Unique_Field_Update</fullName>
        <description>Updates the duplicate check field with a concatenated value of Feature Value and Feature Type</description>
        <field>Core_Check_Duplicate__c</field>
        <formula>Core_Feature_Value__c+Core_Feature_Type__c</formula>
        <name>Core_Feature_Unique_Field_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Feature_Duplicate_Check</fullName>
        <actions>
            <name>Core_Feature_Unique_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow rule to avoid duplication of combination of Type and Value for Feature records</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
