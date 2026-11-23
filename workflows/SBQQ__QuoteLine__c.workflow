<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Initial_Submission_Action_for_Quote_Approval</fullName>
        <description>Initial Submission Action for Quote Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>11579289@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteLineApprovalInitial_Notify</template>
    </alerts>
    <alerts>
        <fullName>Pricing_Tender_QuoteLine_Rejected_Notification</fullName>
        <description>Pricing Tender QuoteLine Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Pricing_Sales_Rep_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Pricing_Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteLineRejectedNotification</template>
    </alerts>
    <alerts>
        <fullName>Test_QuoteLine</fullName>
        <description>Test_QuoteLine</description>
        <protected>false</protected>
        <recipients>
            <recipient>11579289@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Test_QuoteLine</template>
    </alerts>
    <fieldUpdates>
        <fullName>Pending_Further_Intel_Review_Status_UPD</fullName>
        <description>Pending Further Intel Review Status Update</description>
        <field>Pricing_Status_Nm__c</field>
        <literalValue>Pending Further Intel Review</literalValue>
        <name>Pending Further Intel Review Status UPD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pricing_Dummy_Update</fullName>
        <field>Pricing_Status_Nm__c</field>
        <literalValue>Won</literalValue>
        <name>Pricing Dummy Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pricing_Update_Status_to_Rejected</fullName>
        <field>Pricing_Update_Status_to_Rejected_cb__c</field>
        <literalValue>1</literalValue>
        <name>Update Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
