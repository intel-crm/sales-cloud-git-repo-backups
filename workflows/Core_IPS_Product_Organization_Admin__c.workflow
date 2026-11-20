<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_Insert_Admin_Name_Org</fullName>
        <description>Concatenate Support Org Number and User WWID who is being configured as a Support Org Admin.</description>
        <field>Core_IPS_Unique_Admin_User__c</field>
        <formula>Core_Product_Organization__r.Name  &amp; Core_Admin__r.Core_WWID__c</formula>
        <name>Core_IPS_Insert_Admin_Name_Org</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_Ensure_Support_Org_Admin_Is_Unique</fullName>
        <actions>
            <name>Core_IPS_Insert_Admin_Name_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow rule that populates a &apos;hidden&apos; field in Support Org Admin object to ensure each user can be added only once.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
