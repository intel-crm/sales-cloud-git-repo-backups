<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Client</label>
    <protected>false</protected>
    <values>
        <field>Pricing_Field_Label__c</field>
        <value xsi:type="xsd:string">Product Name,Processor Number</value>
    </values>
    <values>
        <field>Pricing_Field_Value__c</field>
        <value xsi:type="xsd:string">Name:Text,Core_Processor_Number_Nm__c:Text</value>
    </values>
    <values>
        <field>Pricing_Query__c</field>
        <value xsi:type="xsd:string">Select Id,Name,Core_Processor_Number_Nm__c FROM Product2</value>
    </values>
    <values>
        <field>Pricing_Record_Type_Pkl__c</field>
        <value xsi:type="xsd:string">Client</value>
    </values>
    <values>
        <field>Pricing_SearchColumn_Field__c</field>
        <value xsi:type="xsd:string">AND Name Like &apos;{{searchString}}&apos;</value>
    </values>
    <values>
        <field>Pricing_Where_Clause__c</field>
        <value xsi:type="xsd:string">WHERE ((IsActive = true AND Core_Product_Org__c = &apos;Sales&apos; AND Core_Sales_Visible_Flag__c = true AND Core_Hierarchy_ID__c = &apos;43&apos; AND (Core_VerticalSegment__c = &apos;Mobile&apos; or Core_VerticalSegment__c = &apos;Desktop&apos; or Core_VerticalSegment__c = &apos;Workstation&apos; or Core_VerticalSegment__c = &apos;Embedded&apos; or Core_Cross_Selling_Product_Type_Nm__c = &apos;Client&apos;) AND Core_Processor_Number_Nm__c != null) OR Name = &apos;Write In Product&apos;)</value>
    </values>
</CustomMetadata>
