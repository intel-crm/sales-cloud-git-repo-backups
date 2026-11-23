<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_Notify_IPA_ProposalManager_On_Acceptance</fullName>
        <description>This Email Alert will send notification to IPA Proposal Owner on Proposal Acceptance</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyOnIPAProposalApproval</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_IPA_UsersOnProposalRejection</fullName>
        <description>This Email Alert will send notification to IPA Proposal Owner on Proposal Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyOnIPAProposalRejection</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_IPA_UsersOnProposalTerminalRejection</fullName>
        <description>This Email Alert will send notification to IPA Proposal Owner on Proposal Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyOnTerminalRejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Business_Approver_Completed_Level</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>Business Approver</literalValue>
        <name>Business Approver Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Business_Approver_Rejected_Level</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>Business Approver</literalValue>
        <name>Business Approver Rejected Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_ApprovalStage</fullName>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <name>Clear ApprovalStage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Approval_Stage</fullName>
        <description>Clear Approval Stage after PCT Approval</description>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <name>Clear Approval Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_IPA_Approval_status</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <name>Clear IPA Approval status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Campaign_Approval_Status_Approved</fullName>
        <field>Core_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Core_Campaign_Approval_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Campaign_Approval_Status_Recalled</fullName>
        <field>Core_Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Core_Campaign_Approval_Status_Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Campaign_Approval_Status_Rejected</fullName>
        <field>Core_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Core_Campaign_Approval_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Campaign_Approval_Status_Submitted</fullName>
        <field>Core_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Core_Campaign_Approval_Status_Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approval_Stage</fullName>
        <description>Clear Approval Stage after PCT Approval</description>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <name>Clear Approval Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Last_Approv_Completed_Lvl</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <name>Clear Last Approval Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Customer_Acceptance_Rejected</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>Customer Acceptance</literalValue>
        <name>Customer Acceptance Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_IPA_Status_to_Pending_Approval</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_IPA_Status_to_Pending_Approval1</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Increament_Step_Counter</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>Core_MDF_Approval_Step_Counter_nbr__c + 1</formula>
        <name>Increament Step Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_L1_Completed_level</fullName>
        <description>When L1 approver approves it</description>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>L1 Approval</literalValue>
        <name>L1 Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_L1_Rejected_Level</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>L1 Approval</literalValue>
        <name>L1 Rejected Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_L2_Approval_Completed_Level</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>L2 Approval</literalValue>
        <name>L2 Approval Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_L2_Approval_Rejected_Level</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>L2 Approval</literalValue>
        <name>L2 Approval Rejected Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_L2_Region_Sales_Completed</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>L2 Regional Sales</literalValue>
        <name>L2 Region Sales Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_L2_Regional_Marketing_Completed</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>L2 Regional Marketing</literalValue>
        <name>L2 Regional Marketing Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Legal_Reviewer_Completed_Level</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>Legal Reviewer</literalValue>
        <name>Legal Reviewer Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Legal_Reviewer_Rejected_Level</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>Legal Reviewer</literalValue>
        <name>Legal Reviewer Rejected Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_PCT_Completed_Level</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>Price Reviewer</literalValue>
        <name>PCT Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_PCT_Rejected_Lvl</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>Price Reviewer</literalValue>
        <name>PCT Rejected Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_POR_Completed_Level</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>Program Office Reviewer</literalValue>
        <name>POR Completed Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_POR_Rejected_Level</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>Program Office Reviewer</literalValue>
        <name>POR Rejected Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_Campaign_Accepted</fullName>
        <field>Status</field>
        <literalValue>Campaign Accepted</literalValue>
        <name>Update Status to Campaign Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_to_Pending_Approval</fullName>
        <field>Status</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_StepCount_to_Four</fullName>
        <description>Step Count to Four</description>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>4</formula>
        <name>Step Count to Four</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Count_to_Four</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>4</formula>
        <name>Step Count to Four</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Count_to_One</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>1</formula>
        <name>Step Count to One</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Count_to_Three</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>3</formula>
        <name>Step Count to Three</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Count_to_Two</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>2</formula>
        <name>Step Count to Two</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Count_to_Zero</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>0</formula>
        <name>Step Count to Zero</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Count_to_Zero_PR</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>0</formula>
        <name>Step Count to Zero</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Approval_Stage</fullName>
        <description>Update Approval Stage to Price Review</description>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <literalValue>Price Reviewer</literalValue>
        <name>Update Approval Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Appvr_Comment</fullName>
        <field>Core_MDF_Approver_Date__c</field>
        <formula>NOW() - 55*(1/24/60)</formula>
        <name>Update Approver Comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Appvr_Date</fullName>
        <field>Core_MDF_Approver_Date__c</field>
        <formula>NOW() - 55*(1/24/60)</formula>
        <name>Update Approver Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_IPA_Approval_Status</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <name>Update IPA Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_IntelMDF_Approval_Status</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update Intel MDF Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_No_of_Reapprovals</fullName>
        <field>Core_MDF_No_of_Reapprovals_nbr__c</field>
        <formula>IF(  ISNULL( Core_MDF_No_of_Reapprovals_nbr__c ) , 1, Core_MDF_No_of_Reapprovals_nbr__c + 1)</formula>
        <name>Update No of Reapprovals</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Outcome_Edited_False</fullName>
        <field>Core_MDF_Outcome_Detail_Edited_Ind__c</field>
        <literalValue>0</literalValue>
        <name>Update Outcome Edited False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_RecordType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Core_MDF_Intel_Partner_Alliance</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update RecordType to IPA Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Status_to_Accepted</fullName>
        <field>Status</field>
        <literalValue>Proposal Accepted</literalValue>
        <name>Update Status to Proposal Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Status_to_Denied</fullName>
        <field>Status</field>
        <literalValue>Revision Required</literalValue>
        <name>Update Status to Revision Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Acceptance_Completed</fullName>
        <field>Core_MDF_Completed_Approval_Level_Nm__c</field>
        <literalValue>Customer Acceptance</literalValue>
        <name>Customer Acceptance Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>L2_Regional_Marketing_Rejected</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>L2 Regional Marketing</literalValue>
        <name>L2 Regional Marketing Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>L2_Regional_Sales_Rejected</fullName>
        <field>Core_MDF_Last_Rejected_Level_Nm__c</field>
        <literalValue>L2 Regional Sales</literalValue>
        <name>L2 Regional Sales Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Step_Count_to_Zero_PR</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>0</formula>
        <name>Step Count to Zero</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IPA_Status_to_Pending_Approval_PR</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_status_pending_Approval</fullName>
        <field>Status</field>
        <literalValue>Pending Approval</literalValue>
        <name>update status pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
