<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>VCAircall1</label>
    <protected>false</protected>
    <values>
        <field>voice_connector__VCCTIDevName__c</field>
        <value xsi:type="xsd:string">Aircall</value>
    </values>
    <values>
        <field>voice_connector__VCHttpBody__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>voice_connector__VCHttpCallId__c</field>
        <value xsi:type="xsd:double">1.0</value>
    </values>
    <values>
        <field>voice_connector__VCHttpEndpoint__c</field>
        <value xsi:type="xsd:string">/v1/calls</value>
    </values>
    <values>
        <field>voice_connector__VCHttpFilters__c</field>
        <value xsi:type="xsd:string">?from={0}&amp;to={1}&amp;per_page=50</value>
    </values>
    <values>
        <field>voice_connector__VCHttpHeaders__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>voice_connector__VCHttpMethod__c</field>
        <value xsi:type="xsd:string">GET</value>
    </values>
</CustomMetadata>
