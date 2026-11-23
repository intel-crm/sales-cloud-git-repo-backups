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
    <alerts>
        <fullName>Core_MDF_Proposal_Approval_Ext_Notification</fullName>
        <description>Notify External Users on Proposal Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>11829401@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_10_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_1_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_2_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_3_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_4_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_5_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_6_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_7_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_8_id__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_9_id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyProposalForExt</template>
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
        <fullName>Change_Status_to_Completed</fullName>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>Change Status to Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
        <fullName>Core_MDF_Clear_Approver_10_Value</fullName>
        <field>Core_MDF_Approver_10_id__c</field>
        <name>Clear Approver 10 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_1_Value</fullName>
        <field>Core_MDF_Approver_1_id__c</field>
        <name>Clear Approver 1 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_2_Value</fullName>
        <field>Core_MDF_Approver_2_id__c</field>
        <name>Clear Approver 2 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_3_Value</fullName>
        <field>Core_MDF_Approver_3_id__c</field>
        <name>Clear Approver 3 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_4_Value</fullName>
        <field>Core_MDF_Approver_4_id__c</field>
        <name>Clear Approver 4 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_5_Value</fullName>
        <field>Core_MDF_Approver_5_id__c</field>
        <name>Clear Approver 5 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_6_Value</fullName>
        <field>Core_MDF_Approver_6_id__c</field>
        <name>Clear Approver 6 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_7_Value</fullName>
        <field>Core_MDF_Approver_7_id__c</field>
        <name>Clear Approver 7 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_8_Value</fullName>
        <field>Core_MDF_Approver_8_id__c</field>
        <name>Clear Approver 8 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_9_Value</fullName>
        <field>Core_MDF_Approver_9_id__c</field>
        <name>Clear Approver 9 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
        <fullName>Core_MDF_IPA_Status_to_Pending_Approvals</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_IPA_Update_Stage</fullName>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <name>Update Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Core_MDF_L2_Approval_Completed</fullName>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <literalValue>L2 Approval</literalValue>
        <name>L2 Approval Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
        <fullName>Core_MDF_Remove_Submitted_Status</fullName>
        <field>Core_MDF_Campaign_Status__c</field>
        <name>Remove Submitted Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
        <fullName>Core_MDF_Status_to_In_Progress</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Status to In Progress</name>
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
        <fullName>Core_MDF_Update_Approver_Comment</fullName>
        <field>Core_MDF_Approver_Date__c</field>
        <formula>NOW() - 55*(1/24/60)</formula>
        <name>Update Approver Comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
        <fullName>IPA_Status_to_Pending_Approval</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPA_path_status_update_revision_required</fullName>
        <field>Core_MDF_Campaign_IPA_Path_Status__c</field>
        <literalValue>Revision Required</literalValue>
        <name>IPA path status update revision required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
        <fullName>Update_Approval_Status</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Comment_Approval</fullName>
        <field>Core_MDF_Approver_Date__c</field>
        <formula>NOW() - 55*(1/24/60)</formula>
        <name>Update Comment Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IPA_Approval_Status</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <name>Update IPA  Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IPA_Status_to_Pending_Approval</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IPA_Status_to_Pending_Approval_Re</fullName>
        <field>Core_MDF_IPA_Approval_Status_nm__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Update IPA Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ipa_path_status_update</fullName>
        <field>Core_MDF_Campaign_IPA_Path_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>ipa path status update</name>
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
    <rules>
        <fullName>Core_MDF_Campaign_Status_Change</fullName>
        <active>false</active>
        <formula>IF(StartDate &lt;= TODAY() &amp;&amp;   
EndDate &gt; TODAY() &amp;&amp; ISPICKVAL(Status ,&apos;Planned&apos;)
, true, false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Status_to_In_Progress</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_MDF_Campaign_Status_Change_to_Completed</fullName>
        <actions>
            <name>Change_Status_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>IF(AND(EndDate &lt; TODAY(),
OR(ISPICKVAL(Status ,&apos;Planned&apos;),
ISPICKVAL(Status ,&apos;In Progress&apos;)))
,true ,false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
