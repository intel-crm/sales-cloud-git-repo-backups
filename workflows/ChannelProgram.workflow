<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_MDF_Chnl_Prog_UniqueId_Population</fullName>
        <description>To populate the channel program unique ID field with the combination of Name and Technical Program Name</description>
        <field>Core_MDF_Channel_Program_Unique_Id_nm__c</field>
        <formula>SUBSTITUTE(Name &amp; TEXT(Core_MDF_Technical_Program_Name__c), &apos; &apos;, &apos;&apos;)</formula>
        <name>Channel Program UniqueId Auto Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_Channel_Program_UniqueId_Field_Auto_Populate</fullName>
        <actions>
            <name>Core_MDF_Chnl_Prog_UniqueId_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ChannelProgram.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
