<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_IPS_Update_IPS_Project_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Active</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update IPS Project Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core IPS Update Project Record Type</fullName>
        <actions>
            <name>Core_IPS_Update_IPS_Project_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL(PRIORVALUE(Core_Status__c),&apos;Inactive&apos;), ISPICKVAL(Core_Status__c,&apos;Active&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
