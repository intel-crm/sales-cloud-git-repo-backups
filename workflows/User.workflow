<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>Core_Set_User_Defaults</fullName>
        <description>Uses flow to make set user preferences on create.</description>
        <flow>Core_Set_Default_User_Preferences</flow>
        <flowInputs>
            <name>UserName</name>
            <value>{!Username}</value>
        </flowInputs>
        <label>Set User Defaults</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Core_User_Set_Default_Preferences</fullName>
        <actions>
            <name>Core_Set_User_Defaults</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <description>Sets initial defaults for user preferences when a user is set up.</description>
        <formula>Len(Username) &gt; 0</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
