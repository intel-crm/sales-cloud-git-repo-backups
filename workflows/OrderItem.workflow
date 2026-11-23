<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateUnitPrice</fullName>
        <description>To Update Unit Price from Forced Unit Price</description>
        <field>UnitPrice</field>
        <name>UpdateUnitPrice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ToUpdateUnitPrice</fullName>
        <actions>
            <name>UpdateUnitPrice</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>OrderItem.UnitPriceForceOverride__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Unit price from Forced Unit Price</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
