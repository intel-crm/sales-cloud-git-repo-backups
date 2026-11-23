<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_PSG_Update_License_Activation_Code</fullName>
        <description>License Activation Code</description>
        <field>Sales_License_Activation_Code__c</field>
        <formula>LEFT(Id, 15)</formula>
        <name>Core_PSG_Update_License_Activation_Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_PSG_Order_License_Code_on_Subscription</fullName>
        <actions>
            <name>Core_PSG_Update_License_Activation_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For every order there should be unique License Activation Code.</description>
        <formula>NOT( ISBLANK( Id ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
