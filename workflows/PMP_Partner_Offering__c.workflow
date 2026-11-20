<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Status_Date_Update</fullName>
        <description>To Update Last status update date</description>
        <field>PMP_Offering_Status_Update_Dt__c</field>
        <formula>NOW()</formula>
        <name>Status Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Date</fullName>
        <field>PMP_Offering_Status_Update_Dt__c</field>
        <formula>NOW()</formula>
        <name>Update Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Date123</fullName>
        <field>PMP_Offering_Status_Update_Dt__c</field>
        <name>Update Status Date123</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PMP Offering Expiry Reminders</fullName>
        <active>false</active>
        <description>This workflow is used to schedule templates</description>
        <formula>ISPICKVAL( PMP_Partner_Offering_Lifecycle_Status_Nm__c , &quot;Published&quot;) &amp;&amp; NOT(ISNULL(PMP_Partner_Offering_End_Dt__c)) &amp;&amp;  IF (PMP_Offering_Submitter_UserId__c!=NULL,   IF(PMP_Offering_Submitter_UserId__r.ContactId != NULL , Not(PMP_Offering_Submitter_UserId__r.Contact.Core_Do_Not_Contact__c), true),  false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>PMP_Partner_Offering__c.PMP_Partner_Offering_End_Dt__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>PMP_Partner_Offering__c.PMP_Partner_Offering_End_Dt__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>PMP_Partner_Offering__c.PMP_Partner_Offering_End_Dt__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PMP_OfferingUpdateRequiredReminder_WF</fullName>
        <active>false</active>
        <description>Trigger an Email Alert to Partner Offering Editor, if there is no action taken even after 3 days and even after 10 days</description>
        <formula>AND(ISPICKVAL(PMP_Partner_Offering_Lifecycle_Status_Nm__c,&apos;Update Required&apos;), NOT(ISBLANK(PMP_Intel_Admin_Id__c)), NOT(ISBLANK(PMP_Workflow_Three_Day_Trigger_Dt__c)), NOT(ISBLANK(PMP_Workflow_One_Week_Trigger_Dt__c)), IF (PMP_Offering_Submitter_UserId__c!=NULL,   IF(PMP_Offering_Submitter_UserId__r.ContactId != NULL , Not(PMP_Offering_Submitter_UserId__r.Contact.Core_Do_Not_Contact__c), true),  false))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>PMP_Partner_Offering__c.PMP_Workflow_One_Week_Trigger_Dt__c</offsetFromField>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>PMP_Partner_Offering__c.PMP_Workflow_Three_Day_Trigger_Dt__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
