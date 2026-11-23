<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SWS_Send_Approved_Rejection_email_to_Submitter</fullName>
        <description>Send Approved/Rejection email to Submitter</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SWS_Email_Template/SWS_Approved_or_Rejected_Template</template>
    </alerts>
    <alerts>
        <fullName>SWS_Send_Rejection_Email_To_Customer</fullName>
        <description>Send Rejection Email To Customer</description>
        <protected>false</protected>
        <recipients>
            <field>SWS_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SWS_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SWS_Submitted_by_for_approval__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SWS_Email_Template/SWS_RejectionEmail</template>
    </alerts>
    <alerts>
        <fullName>SWS_Send_recalled_email_to_approver</fullName>
        <description>Send recalled email to approver</description>
        <protected>false</protected>
        <recipients>
            <field>SWS_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SWS_Email_Template/SWS_Recalled_status_template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Approved</fullName>
        <field>SWS_Approval_status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Recalled</fullName>
        <field>SWS_Approval_status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Update Approval Status to Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Rejected</fullName>
        <field>SWS_Approval_status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Submitted</fullName>
        <field>SWS_Approval_status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Lock</fullName>
        <field>SWS_Locked__c</field>
        <literalValue>1</literalValue>
        <name>Update Record Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Request_Status_To_Approved</fullName>
        <field>SWS_Request_Status__c</field>
        <literalValue>Awaiting_Submission</literalValue>
        <name>Update Request Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Request_Status_To_Reject</fullName>
        <field>SWS_Request_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Request Status To Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_request_status_to_Addition_Approv</fullName>
        <field>SWS_Request_Status__c</field>
        <literalValue>Additional_Approval_Pending</literalValue>
        <name>Update request status to Addition Approv</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
