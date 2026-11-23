<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Team_Scheduled_Job_Successfully_Processed</fullName>
        <description>Account Team Scheduled Job Successfully Processed</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Email_Distribution_List__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>10563705@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Opportunity_Management/Core_Batch_Success_Mail</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Email_Distibution_List</fullName>
        <field>Email_Distribution_List__c</field>
        <formula>Batch_Header__r.Email_Distribution_List__c</formula>
        <name>Update Email Distibution List</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Batch_Header__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Account Team Synchronization Successfully Processed</fullName>
        <actions>
            <name>Account_Team_Scheduled_Job_Successfully_Processed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_Batch_Processing__c.Core_Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
