<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_MDF_BankStatus</fullName>
        <description>Update the status after 1 hour of effective date</description>
        <field>Core_MDF_Bank_Status__c</field>
        <literalValue>Active</literalValue>
        <name>BankStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Bank_Status</fullName>
        <field>Core_MDF_Bank_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Bank Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_the_Bank_Program_Value</fullName>
        <field>Core_MDF_Program_Value__c</field>
        <formula>IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Client_CoMarketing_Fund&quot;),&quot;Client;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Data_Center_CoMarketing_Fund&quot;),&quot;Datacenter;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Service_Provider_CoMarketing_Fund&quot;),&quot;Service Provider Co-Marketing Fund;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Client_CoMarketing_Fund_Boost&quot;),&quot;Client Co-Marketing Fund Boost;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Retail_Marketing_Funds&quot;),&quot;Retail Marketing Funds;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Channel_MDF&quot;),&quot;Channel MDF;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Intel_Partner_Alliance&quot;),&quot;Intel Partner Alliance;&quot;,NULL)</formula>
        <name>Update the Bank Program Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
