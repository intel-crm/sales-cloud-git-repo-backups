<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Ask Commissions- Link to Commissions Inquiry Record</fullName>
        <active>false</active>
        <description>When a commission inquiry record is created, populate the Commissions Inquiry field with “/commission inquiry id&quot;.</description>
        <formula>AND( 
Core_AAQC_Case__r.RecordType.DeveloperName == &apos;Core_AAQC_Case_recordType&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
