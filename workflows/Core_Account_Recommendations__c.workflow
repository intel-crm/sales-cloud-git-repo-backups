<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Account_Recommendations_Set_Account</fullName>
        <field>Core_Account_ID__c</field>
        <formula>Core_Account__c</formula>
        <name>Core_Account_Recommendations_Set_Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Account_Recommendations_Set_Account_ID</fullName>
        <actions>
            <name>Core_Account_Recommendations_Set_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>1=1</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
