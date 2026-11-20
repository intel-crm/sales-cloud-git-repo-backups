<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Holding Count</label>
    <protected>false</protected>
    <values>
        <field>espy__EmailSubject__c</field>
        <value xsi:type="xsd:string">ESPY: Queued jobs in Holding status has reached threshold range above 80</value>
    </values>
    <values>
        <field>espy__Email_Body__c</field>
        <value xsi:type="xsd:string">HI Admin, the current count of queued jobs in Holding status has reached threshold range above 80. Further increase in the batch jobs beyond 100 may result in batch not getting executed. Please monitor the queue and take action as appropriate.</value>
    </values>
    <values>
        <field>espy__Email__c</field>
        <value xsi:type="xsd:string">espy_sfdc@intel.com</value>
    </values>
    <values>
        <field>espy__Is_Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>espy__Limit__c</field>
        <value xsi:type="xsd:double">80.0</value>
    </values>
    <values>
        <field>espy__Timing__c</field>
        <value xsi:type="xsd:double">5.0</value>
    </values>
</CustomMetadata>
