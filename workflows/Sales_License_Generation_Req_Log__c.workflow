<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_log_table_Status_as_Complete</fullName>
        <field>Sales_Status__c</field>
        <literalValue>Complete</literalValue>
        <name>Update log table Status as Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update log table Status</fullName>
        <actions>
            <name>Update_log_table_Status_as_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Sales_License_Generation_Req_Log__c.Sales_File_Ext__c</field>
            <operation>equals</operation>
            <value>dat</value>
        </criteriaItems>
        <criteriaItems>
            <field>Sales_License_Generation_Req_Log__c.Sales_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
