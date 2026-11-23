<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Rejection_Email_to_Customer</fullName>
        <description>Send Rejection Email to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>PRM_Email_ID__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Developer_Zone_Premier/SCRREQTORJTDNEW_DZP</template>
    </alerts>
    <fieldUpdates>
        <fullName>PRM_Approve_Registration_Request</fullName>
        <description>This will set the status of  Registration Request to &apos;Approved&apos;</description>
        <field>PRM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approve Registration Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Reject_Registration_Request</fullName>
        <description>This will set the Registration Request status to &apos;Rejected&apos;</description>
        <field>PRM_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reject Registration Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Record_Lock</fullName>
        <description>To Check record is Locked or not</description>
        <field>PRM_isLocked__c</field>
        <literalValue>1</literalValue>
        <name>Update Record Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Submit_Request</fullName>
        <description>It updates &apos;isSubmitted&apos; field to true</description>
        <field>PRM_isSubmitted__c</field>
        <literalValue>1</literalValue>
        <name>Update Submit Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Completed_Date</fullName>
        <field>Completed_date__c</field>
        <formula>NOW()</formula>
        <name>Update Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Rejected</fullName>
        <field>PRM_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Submit_Request</fullName>
        <description>It updates &apos;isSubmitted&apos; field to false</description>
        <field>PRM_isSubmitted__c</field>
        <literalValue>0</literalValue>
        <name>Update Submit Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Check for ProjectBudget and Status Reason</fullName>
        <actions>
            <name>Send_Rejection_Email_to_Customer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Status_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>2 OR (1 AND 3)</booleanFilter>
        <criteriaItems>
            <field>PRM_Registration_Request__c.PRM_Profile_Response__c</field>
            <operation>contains</operation>
            <value>pro_bud_less_10K</value>
        </criteriaItems>
        <criteriaItems>
            <field>PRM_Registration_Request__c.PRM_Status_Reason__c</field>
            <operation>equals</operation>
            <value>Auto rejected as the Account belongs to LAR/Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>PRM_Registration_Request__c.PRM_Status_Reason__c</field>
            <operation>equals</operation>
            <value>Auto rejected as the Account Project budget does not meet RDC Privilege criteria</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check status changed from new to approved</fullName>
        <actions>
            <name>Update_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>when status changed from new to approved</description>
        <formula>AND (       ISCHANGED(PRM_Status__c) &amp;&amp;        (         ISPICKVAL         (           PRIORVALUE (PRM_Status__c),&quot;new&quot;         )         &amp;&amp;         ISPICKVAL         (           (PRM_Status__c),&quot;Approved&quot;         )       )     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
