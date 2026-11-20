<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Capture_Version</fullName>
        <description>Automatically sets the version number, going forward, from this point on . . .</description>
        <field>Core_Version__c</field>
        <formula>2</formula>
        <name>Capture Version</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Account_Profile_Version</fullName>
        <actions>
            <name>Core_Capture_Version</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This drives the latest version # of the account profile</description>
        <formula>(TRUE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
