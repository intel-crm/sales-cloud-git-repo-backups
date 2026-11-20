<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Campaign Start Date</label>
    <protected>false</protected>
    <values>
        <field>Core_MDF_Column_Fields__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Core_MDF_Data_Type_Values__c</field>
        <value xsi:type="xsd:string">date</value>
    </values>
    <values>
        <field>Core_MDF_Field_API_Name__c</field>
        <value xsi:type="xsd:string">StartDate</value>
    </values>
    <values>
        <field>Core_MDF_Field_Label__c</field>
        <value xsi:type="xsd:string">Start Date</value>
    </values>
    <values>
        <field>Core_MDF_Fields_Editable__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Core_MDF_IsActive__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Core_MDF_Object_API_Name__c</field>
        <value xsi:type="xsd:string">Campaign</value>
    </values>
    <values>
        <field>Core_MDF_Object_Label__c</field>
        <value xsi:type="xsd:string">Campaign</value>
    </values>
    <values>
        <field>Core_MDF_Object_Record_Name__c</field>
        <value xsi:type="xsd:string">Name</value>
    </values>
    <values>
        <field>Core_MDF_ShareObjectFields__c</field>
        <value xsi:type="xsd:string">select CampaignId,CampaignAccessLevel,RowCause,UserOrGroupId,UserOrGroup.Name from CampaignShare where CampaignId</value>
    </values>
    <values>
        <field>LookupNameQuery__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>LookupToObjectName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>ShareObject__c</field>
        <value xsi:type="xsd:string">CampaignShare</value>
    </values>
</CustomMetadata>
