<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>PRM_Specialty_Benefit_Group_Asso_switch</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Class_Name__c</field>
        <value xsi:type="xsd:string">PRM_Specialty_Benefit_Group_Asso_Handler</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">This is used to throw error when user is trying to create a record with same Benefit Group to Same Specialty again</value>
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
        <value xsi:type="xsd:string">PRM_Specialty_Benefit_Group_Association__c</value>
    </values>
    <values>
        <field>Trigger_Events__c</field>
        <value xsi:type="xsd:string">before insert; before Update</value>
    </values>
</CustomMetadata>
