<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Data Center GPU</label>
    <protected>false</protected>
    <values>
        <field>Pricing_Field_Label__c</field>
        <value xsi:type="xsd:string">Product Name,Family Name,Material Id,Forecast Product Name</value>
    </values>
    <values>
        <field>Pricing_Field_Value__c</field>
        <value xsi:type="xsd:string">Name:Text,Core_Family_Nm__c:Text,Core_Item_Id__c:Text,Core_Forecast_Product_Name__c:Text</value>
    </values>
    <values>
        <field>Pricing_Query__c</field>
        <value xsi:type="xsd:string">Select Id,Name,Core_Family_Nm__c,Core_Forecast_Product_Name__c,Core_Item_Id__c from Product2</value>
    </values>
    <values>
        <field>Pricing_Record_Type_Pkl__c</field>
        <value xsi:type="xsd:string">Data Center GPU</value>
    </values>
    <values>
        <field>Pricing_Record_Type__c</field>
        <value xsi:type="xsd:string">Data Center GPU</value>
    </values>
    <values>
        <field>Pricing_SearchColumn_Field__c</field>
        <value xsi:type="xsd:string">AND Name Like &apos;{{searchString}}&apos;</value>
    </values>
    <values>
        <field>Pricing_Where_Clause__c</field>
        <value xsi:type="xsd:string">where ((IsActive = true and Core_Product_Org__c =&apos;Sales&apos; and Core_Product_Type__c = &apos;Graphics&apos; and Core_Hierarchy_ID__c = &apos;43&apos; and Core_Product_Group_EPM_ID__c!=null and Core_Product_Family__c = &apos;Data Center GPU&apos;) or (Name = &apos;Write In Product&apos;))</value>
    </values>
</CustomMetadata>
