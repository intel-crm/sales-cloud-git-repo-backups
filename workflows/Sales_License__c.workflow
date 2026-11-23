<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Sales_UpdateAccount</fullName>
        <field>Sales_License_Account_Name_Txt__c</field>
        <formula>Sales_License_Primary_Admin_Contact__r.Core_Account__c</formula>
        <name>Sales_UpdateAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_UpdateStartDate</fullName>
        <field>Sales_License_Start_Date_Dt__c</field>
        <formula>TODAY()</formula>
        <name>Sales_UpdateStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_update_license_activation_code</fullName>
        <description>License Activation Code</description>
        <field>Sales_License_Activation_Code__c</field>
        <formula>LEFT(Id, 15)</formula>
        <name>Sales_update_license_activation_code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Sales_License_Activation_Code</fullName>
        <actions>
            <name>Sales_update_license_activation_code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For every order there should be unique License Activation Code.</description>
        <formula>NOT( ISBLANK(  Id  ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sales_updateLicenseRecord</fullName>
        <actions>
            <name>Sales_UpdateAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sales_UpdateStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Sales_License__c.Sales_License_Status__c</field>
            <operation>equals</operation>
            <value>Licensed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
