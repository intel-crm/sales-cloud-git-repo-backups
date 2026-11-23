<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>PMP_Partner_Offering__c</label>
    <protected>false</protected>
    <values>
        <field>Default_Filter__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Default_for_Partner__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Enabled_for_Partners__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Filter_Label__c</field>
        <value xsi:type="xsd:string">Admin Review Queue</value>
    </values>
    <values>
        <field>Filter_Value__c</field>
        <value xsi:type="xsd:string">Where PMP_Partner_Offering_Lifecycle_Status_Nm__c = &apos;Admin Review&apos; and (( PMP_Translated_Languages__c includes (&apos;English&apos;) and PMP_Business_Segment_Nm__c includes (&apos;Internet of Things and Embedded&apos;)) or PMP_Business_Segment_Nm__c excludes (&apos;Internet of Things and Embedded&apos;))</value>
    </values>
</CustomMetadata>
