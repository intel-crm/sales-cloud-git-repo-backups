<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_PSG_Update_Sales_Status</fullName>
        <description>Update Orderable, Shippable and Quotable Checkboxes</description>
        <field>Core_Item_Orderable_Ind__c</field>
        <literalValue>1</literalValue>
        <name>Update Sales Status Flags</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Material_Id</fullName>
        <field>Core_Item_Id__c</field>
        <formula>Core_Item_Id__c</formula>
        <name>Material Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSG_Update_SalesVisibleUserEdit</fullName>
        <description>Update the Sales Visible User Edit flag</description>
        <field>Core_Sales_Visible_Flag_User_Edit__c</field>
        <literalValue>1</literalValue>
        <name>PSG_Update_SalesVisibleUserEdit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
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
    <rules>
        <fullName>PSG Edit Access on Product_Sales Visible Flag</fullName>
        <actions>
            <name>PSG_Update_SalesVisibleUserEdit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Allow PSG Marketing Super User to edit Sales Visible flag under Product Object</description>
        <formula>AND( $Profile.Name &lt;&gt; &apos;Core Integration&apos;,$Profile.Name &lt;&gt; &apos;Integration&apos; , ISCHANGED( Core_Sales_Visible_Flag__c),  OR(  Core_Item_Class_Nm__c==&apos;SV&apos;,Core_Item_Class_Nm__c==&apos;BD&apos;,Core_Item_Class_Nm__c==&apos;IC&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
