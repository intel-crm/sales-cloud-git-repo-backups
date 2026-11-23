<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_MDF_FU_Update_the_Program_Field_EAM</fullName>
        <field>Core_MDF_Program_txt__c</field>
        <formula>TEXT(Core_MDF_Exception_id__r.Core_MDF_Program_nm__c)</formula>
        <name>Update the Program Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_Update_the_Program</fullName>
        <actions>
            <name>Core_MDF_FU_Update_the_Program_Field_EAM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1 != 2</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
