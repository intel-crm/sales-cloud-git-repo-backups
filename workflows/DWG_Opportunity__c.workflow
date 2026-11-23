<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>UpdateTextField</fullName>
        <active>false</active>
        <formula>NOT(ISBLANK(Name))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
