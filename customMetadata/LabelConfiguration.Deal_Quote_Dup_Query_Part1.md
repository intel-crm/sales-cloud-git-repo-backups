<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Deal Quote Dup Query Part1</label>
    <protected>false</protected>
    <values>
        <field>Category__c</field>
        <value xsi:type="xsd:string">Deal</value>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">SELECT Id,Pricing_Project_Name_Nm__c, Name,Pricing_End_Customer_Account__c, (SELECT Id, Name,SBQQ__Product__c FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c</value>
    </values>
</CustomMetadata>
