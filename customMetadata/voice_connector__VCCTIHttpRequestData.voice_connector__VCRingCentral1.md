<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>VCRingCentral1</label>
    <protected>false</protected>
    <values>
        <field>voice_connector__VCCTIDevName__c</field>
        <value xsi:type="xsd:string">RingCentral</value>
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
        <value xsi:type="xsd:string">/restapi/v1.0/account/~/call-log</value>
    </values>
    <values>
        <field>voice_connector__VCHttpFilters__c</field>
        <value xsi:type="xsd:string">?withRecording=true&amp;dateFrom={0}&amp;dateTo={1}&amp;page=1&amp;perPage=1000&amp;showDeleted=false</value>
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
