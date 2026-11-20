<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_NotifyClaimSubOnInvoiceDoc</fullName>
        <description>Notify Claim Submitters on VAT Invoice Upload</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyClaimSubOnInvoiceDoc</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_NotifyClaimSubOnInvoiceReminder</fullName>
        <description>Notify Claim Submitters on VAT Invoice Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_ReminderNotificationForVAT</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_VAT_Rejection_Notification_to_Submitter</fullName>
        <description>VAT Rejection Notification to Submitter</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyOnVATInvoiceRejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_MDF_Claim_VAT_Approve_Status_Update</fullName>
        <description>Update the VAT info record status as Approved while approved by approver.</description>
        <field>Core_MDF_Status_Txt__c</field>
        <literalValue>Approved</literalValue>
        <name>Claim_VAT Approve Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Claim_VAT_Reject_Status_Update</fullName>
        <description>Update the VAT info record status as Revision Required when rejected by approver</description>
        <field>Core_MDF_Status_Txt__c</field>
        <literalValue>Revision Required</literalValue>
        <name>Claim_VAT Reject Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Claim_VAT_Review_Status</fullName>
        <description>Update the VAT Info status as Under Review once the record is in approval queue</description>
        <field>Core_MDF_Status_Txt__c</field>
        <literalValue>Under Review</literalValue>
        <name>Claim VAT Review Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_VAT_Recall_Status_Update</fullName>
        <description>Update the statsus as Pending Documents</description>
        <field>Core_MDF_Status_Txt__c</field>
        <literalValue>Pending Documents</literalValue>
        <name>VAT Recall Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
