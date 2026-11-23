<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Mapping1</label>
    <protected>false</protected>
    <values>
        <field>PSG_Column__c</field>
        <value xsi:type="xsd:string">label: &apos;Product/Part#&apos;, fieldName: &apos;PSG_Product_Nm__c&apos;,type: &apos;lookup&apos;,editable: true,sortable: true,typeAttributes: {
                    placeholder: &apos;Select Product&apos;,
                    uniqueId: { fieldName: &apos;Id&apos; }, //pass Id of current record to lookup for context
                    object: &quot;Product2&quot;,
                    icon: &quot;standard:product&quot;,
                    label: &quot;Product/Part#&quot;,
                    displayFields: &quot;Name&quot;,
                    displayFormat: &quot;Name&quot;,
                    filters: &quot;&quot;,
                    valueId: {fieldName: &apos;ParentId&apos;},
                    defaultRecord: {fieldName: &apos;SBQQ__ProductName__c&apos;},
                }</value>
    </values>
    <values>
        <field>PSG_Context__c</field>
        <value xsi:type="xsd:string">Disty_Editable</value>
    </values>
</CustomMetadata>
