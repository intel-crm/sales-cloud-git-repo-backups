<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Sales_update_license_activation_code</fullName>
        <description>License Activation Code</description>
        <field>Sales_License_Activation_Code__c</field>
        <formula>LEFT(Id, 15)</formula>
        <name>Sales_update_license_activation_code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Sales_License_Activation_Code</fullName>
        <actions>
            <name>Sales_update_license_activation_code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For every order there should be unique License Activation Code.</description>
        <formula>NOT( ISBLANK(  Id  ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
