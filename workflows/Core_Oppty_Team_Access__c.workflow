<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_template_to_confirm_rejection_of_a_member_for_the_Oppty_team</fullName>
        <description>Email template to confirm rejection of a member for the Oppty team</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Opportunity_Management/Core_OpptyTeamAccess_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_template_to_confirm_to_the_approver_of_addition_of_a_member_to_the_Oppty_t</fullName>
        <description>Email template to confirm addition of a member to the Oppty team</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Opportunity_Management/Core_OpptyTeamAccess_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Initial_Submit_Action</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Initial Submit Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
