<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Core_IPS_Update_IPS_Visible_Flag</fullName>
        <active>false</active>
        <description>Updates the IPS Visible flag such that if the value of the locally set visibility flag is blank, this field takes its value from IPS Visible set by Integration; Else the value of this field is taken from the locally set value (Y or N).</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Updt_Visible_4m_External_2_False</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Product2.Core_IPS_Visible_Flag_Internal__c</field>
            <operation>notContain</operation>
            <value>Yes,No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Core_IPS_Visible_Flag_External__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Copy the value of the integration/external flag into IPS Visible when the internal visible flag is blank. This rule evaluates FALSE condition of the integration flag.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Updt_Visible_4m_External_2_True</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Product2.Core_IPS_Visible_Flag_Internal__c</field>
            <operation>notContain</operation>
            <value>Yes,No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Core_IPS_Visible_Flag_External__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Copy the value of the integration/external flag into IPS Visible when the internal visible flag is blank. This rule evaluates TRUE condition of the external/integration flag.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Updt_Visible_4m_Internal_2_False</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Product2.Core_IPS_Visible_Flag_Internal__c</field>
            <operation>contains</operation>
            <value>No</value>
        </criteriaItems>
        <description>If the internal visible flag in not blank, copy it&apos;s value into IPS Visible flag. Ignore integration flag value. This rule evaluates the False value of internal flag.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
