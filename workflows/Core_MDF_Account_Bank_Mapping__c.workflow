<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_MDF_Update_AccountIdBankIdMapping</fullName>
        <description>It updates AccountIdBankIdMapping field with Account and Bank ids.</description>
        <field>Core_MDF_AccountIdBankIdMapping__c</field>
        <formula>Core_MDF_Account__c + Core_MDF_Bank__c</formula>
        <name>Update_AccountIdBankIdMapping</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_the_Program_Field</fullName>
        <field>Core_MDF_Program__c</field>
        <formula>TEXT(Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)</formula>
        <name>Update the Program Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_Update_the_Program</fullName>
        <actions>
            <name>Core_MDF_Update_the_Program_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>1 != 2</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF_WF_Update_AccountIdBankIdMapping</fullName>
        <actions>
            <name>Core_MDF_Update_AccountIdBankIdMapping</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>It updates the AccountIdBankIdMapping field with concatenated id of Account and Bank.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
