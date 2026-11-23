<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Is_Retrieved_to_True</fullName>
        <field>PMP_Is_Retrieved_Ind__c</field>
        <literalValue>1</literalValue>
        <name>Is Retrieved to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>check Is Retrieved for download Mule Soft Documents</fullName>
        <active>false</active>
        <criteriaItems>
            <field>PMP_Rich_Media_Asset_Stage__c.PMP_Is_Retrieved_Ind__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Is_Retrieved_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>PMP_Rich_Media_Asset_Stage__c.Trigger_Delay__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
