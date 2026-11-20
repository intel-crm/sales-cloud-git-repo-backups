<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Deal Dup Query Part4</label>
    <protected>false</protected>
    <values>
        <field>Category__c</field>
        <value xsi:type="xsd:string">Deal</value>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">AND Id != :Id AND Core_Design_Registration_Status_Nm__c != &apos;Draft&apos; ORDER BY CreatedDate DESC</value>
    </values>
</CustomMetadata>
