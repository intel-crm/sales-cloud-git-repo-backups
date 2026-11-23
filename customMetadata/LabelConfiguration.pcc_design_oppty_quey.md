<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>pcc_design_oppty_quey</label>
    <protected>false</protected>
    <values>
        <field>Category__c</field>
        <value xsi:type="xsd:string">PCC</value>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">SELECT Id,Name,AccountId, (SELECT Id, Name,product2Id FROM OpportunityLineItems) FROM Opportunity WHERE AccountId = :Core_End_Customer_Account_Id</value>
    </values>
</CustomMetadata>
