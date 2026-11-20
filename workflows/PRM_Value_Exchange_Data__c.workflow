<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PRM_MarketType_Update</fullName>
        <description>Vx Data Market Type Update</description>
        <field>PRM_Country_Market_Type_Nm__c</field>
        <literalValue>NA</literalValue>
        <name>PRM_MarketType_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PRM_VXData_MarketType_Update</fullName>
        <actions>
            <name>PRM_MarketType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>PRM_Value_Exchange_Data__c.PRM_Partner_Role_Nm__c</field>
            <operation>notEqual</operation>
            <value>Seller,Original Equipment Manufacturer (OEM)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
