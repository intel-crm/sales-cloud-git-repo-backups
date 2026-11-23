<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_User_Id</fullName>
        <field>Core_IPS_Unique_Owner_Group__c</field>
        <formula>IF( ISBLANK(Core_IPS_Case_Owner_Email__c) , Text(DATETIMEVALUE( NOW() )), Core_IPS_Case_Owner_Email__c)  &amp; Core_IPS_Support_Org__r.Id</formula>
        <name>Populate User Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core IPS Prevent Duplicate Case Owner</fullName>
        <actions>
            <name>Populate_User_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
