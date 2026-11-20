<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
