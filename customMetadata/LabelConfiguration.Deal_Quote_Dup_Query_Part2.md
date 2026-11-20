<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Deal Quote Dup Query Part2</label>
    <protected>false</protected>
    <values>
        <field>Category__c</field>
        <value xsi:type="xsd:string">Deal</value>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">WHERE SBQQ__Account__c = :Core_Partner_Account_Id and Pricing_Program_Type_Nm__c = &apos;Financial Incentive&apos; and Pricing_End_Customer_Account__c = :Core_End_Customer_Account_Id and Pricing_Deal_Registration_Id__c = null</value>
    </values>
</CustomMetadata>
