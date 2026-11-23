<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PRM_Community_Enrollment_Request</fullName>
        <description>Community Enrollment Request</description>
        <protected>false</protected>
        <recipients>
            <field>PRM_Approver_Id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPA_English_Templates/COMMRQST</template>
    </alerts>
    <fieldUpdates>
        <fullName>PRM_Update_End_Date</fullName>
        <description>Update End date if status is Rejected</description>
        <field>PRM_End_Date_Dt__c</field>
        <formula>Now()</formula>
        <name>PRM_Update_End_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PRM Community Request</fullName>
        <actions>
            <name>PRM_Community_Enrollment_Request</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This  workflow will trigger email alert when a new record created for Community Request</description>
        <formula>NOT(ISBLANK( PRM_Approver_Id__c ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PRM_Update_EndDate</fullName>
        <actions>
            <name>PRM_Update_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>PRM_Partner_Community_Enrollment_Request__c.PRM_Status_Nm__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
