<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_DDR_Product_Record_Type_To_Locked</fullName>
        <description>Updates the Record Type, so the page layout using this record type locks the fields in UI.</description>
        <field>RecordTypeId</field>
        <lookupValue>Core_Design_Registration_Product_Partner</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Product Record Type To Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Update_Status_to_Retired</fullName>
        <description>Update the Status field to Retired.</description>
        <field>Core_Design_Product_Status_Nm__c</field>
        <literalValue>Retired</literalValue>
        <name>Update Status to Retired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_DDR_Lock_Product</fullName>
        <actions>
            <name>Core_DDR_Product_Record_Type_To_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Changes the Record Type, so the design product fields are NOT editable by Intel user.</description>
        <formula>LastModifiedBy.Profile.Name = &apos;Partner&apos; &amp;&amp; NOT(RecordTypeId =  $Label.Core_DDR_Design_Product_Locked_Record_Type_ID)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Retire_Product</fullName>
        <active>false</active>
        <description>Updates the Status to Retired one hour after the current date reaches the date specified in &apos;Retired As Of&apos; field.</description>
        <formula>NOT(ISBLANK(Core_Retired_As_Of_Dt__c)) &amp;&amp;  NOT (ISPICKVAL(Core_Design_Product_Status_Nm__c, &apos;Retired&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_DDR_Update_Status_to_Retired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Core_Design_Registration_Product__c.Core_Retired_As_Of_Dt__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
