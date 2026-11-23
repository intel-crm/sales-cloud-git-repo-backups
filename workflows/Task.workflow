<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Task_email_from_Marketo</fullName>
        <description>Task email alert notification from marketo</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Task_notification_from_marketo</template>
    </alerts>
    <fieldUpdates>
        <fullName>Keep_Call_Result_Updated</fullName>
        <description>Field update to keep the call result field updated after Log a Call action is used</description>
        <field>CallDisposition</field>
        <formula>TEXT(Core_Call_Result__c)</formula>
        <name>Keep Call Result Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Keep Call Result Updated</fullName>
        <actions>
            <name>Keep_Call_Result_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Core_Call_Result__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow rule on the task object to take the data from the custom Call Result field (picklist) and stamp the values</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
