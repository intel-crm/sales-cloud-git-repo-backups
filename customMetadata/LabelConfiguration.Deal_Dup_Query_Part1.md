<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Deal Dup Query Part1</label>
    <protected>false</protected>
    <values>
        <field>Category__c</field>
        <value xsi:type="xsd:string">Deal</value>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">SELECT Id,Owner.Name,OwnerId, Name,Core_Design_Registration_Nm__c, Core_Partner_Account_Id__r.Name,Core_End_Customer_Account_Id__c, Core_End_Customer_Account_Id__r.Name, (SELECT Id, Name, Core_Design_Product_Status_Nm__c, Core_Product_Id__c</value>
    </values>
</CustomMetadata>
