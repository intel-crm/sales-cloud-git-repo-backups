<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Update ACR on Soft Contact</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Class_Name__c</field>
        <value xsi:type="xsd:string">Core_Contact</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Inactivating ACR&apos;s on removal of EnterpriseId (Soft Contact Conversion)</value>
    </values>
    <values>
        <field>Inactive_for_Profile__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Inactive_for_User__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Contact</value>
    </values>
    <values>
        <field>Trigger_Events__c</field>
        <value xsi:type="xsd:string">After Update</value>
    </values>
</CustomMetadata>
