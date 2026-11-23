<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Core_Contact_Engagement</fullName>
        <apiVersion>36.0</apiVersion>
        <description>Triggered when Contact has Engagement added / removed</description>
        <endpointUrl>https://dummydefault:WJ$K1ZmrZug7@eip-crm-dummy.cloudhub.io/smit/api/eip-crm-sls-contacts-sf2erpm/contact</endpointUrl>
        <fields>Core_Active__c</fields>
        <fields>Core_Contact__c</fields>
        <fields>Core_Engagement_Code__c</fields>
        <fields>Core_Engagement_Label__c</fields>
        <fields>Core_Engagement__c</fields>
        <fields>Core_ExtId__c</fields>
        <fields>Id</fields>
        <fields>Name</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>integration.user@intel.com.crm</integrationUser>
        <name>Core_Contact_Engagement</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Core_Contact_Engagement_OBM_Rule</fullName>
        <actions>
            <name>Core_Contact_Engagement</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Sends OBM on Contact Engagement change</description>
        <formula>(  ISNEW() ||  ISCHANGED(Core_Active__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
