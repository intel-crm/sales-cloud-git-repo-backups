<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Activity_Copy_Opportunity_Amount</fullName>
        <description>Copies the Amount value from corresponding Opportunity.</description>
        <field>Core_Opportunity_Amount__c</field>
        <formula>Core_Opportunity__r.Amount</formula>
        <name>Core_Activity_Copy_Opportunity_Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Activity_Copy_Opportunity_Volume</fullName>
        <description>Copies the Volume value from corresponding Opportunity.</description>
        <field>Core_Opportunity_Volume__c</field>
        <formula>Core_Opportunity__r.Core_Opportunity_U_Base__c</formula>
        <name>Core_Activity_Copy_Opportunity_Volume</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Activity_Copy_Opportunity_Amount_And_Volume</fullName>
        <actions>
            <name>Core_Activity_Copy_Opportunity_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Activity_Copy_Opportunity_Volume</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Core_Marketing_Activity_Opportunity__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Copies the Amount and Volume from corresponding Opportunity object to the Marketing Activity Opportunity object.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
