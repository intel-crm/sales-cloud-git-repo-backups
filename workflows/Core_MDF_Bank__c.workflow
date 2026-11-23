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
        <formula>IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Client_CoMarketing_Fund&quot;),&quot;Client Co-Marketing Fund;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Data_Center_CoMarketing_Fund&quot;),&quot;Data Center Co-Marketing Fund;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Service_Provider_CoMarketing_Fund&quot;),&quot;Service Provider Co-Marketing Fund;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Client_CoMarketing_Fund_Boost&quot;),&quot;Client Co-Marketing Fund Boost;&quot;,NULL)+
IF(INCLUDES(Core_MDF_Program__c, &quot;Core_MDF_Retail_Marketing_Funds&quot;),&quot;Retail Marketing Funds;&quot;,NULL)</formula>
        <name>Update the Bank Program Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_Update_Bank_Program_Value</fullName>
        <actions>
            <name>Core_MDF_Update_the_Bank_Program_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(),ISCHANGED(Core_MDF_Program__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF_Update_the_Status_to_Active_on_Effective_Date</fullName>
        <active>true</active>
        <description>This will call the Time based action to make the Bank as Active on the Effective Date.</description>
        <formula>AND(  	Core_MDF_ESD_Update__c == true,  	Core_MDF_ESD_Hold_Indicator__c == false,  	Core_MDF_Effective_Date__c  &gt;  TODAY(),   	Core_MDF_Ineffective_Selection_ind__c == false, 	OR(   		ISPICKVAL(Core_MDF_Hold_Payments_from_AP_file_ind__c,&apos;No&apos;), 		ISPICKVAL(Core_MDF_Hold_Payments_from_AP_file_ind__c,&apos;&apos;) 	) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Update_Bank_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Core_MDF_Bank__c.Core_MDF_Effective_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
