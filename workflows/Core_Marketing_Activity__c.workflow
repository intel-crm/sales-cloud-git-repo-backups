<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Activity_Prepend_Account_To_Name</fullName>
        <description>Takes the name of the Account associated to the Activity and pre-pends it to the Activity Name.</description>
        <field>Name</field>
        <formula>Core_Activity_Account__r.Name &amp; &apos; - &apos; &amp; Name</formula>
        <name>Core_Activity_Prepend_Account_To_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Activity_Prepend_Account_To_Name</fullName>
        <actions>
            <name>Core_Activity_Prepend_Account_To_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Core_Marketing_Activity__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Prepends the associated Account Name to the Activity Name.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
