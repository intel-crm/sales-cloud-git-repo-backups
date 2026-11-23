<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_Budget_Rejection</fullName>
        <description>Core MDF Budget Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_MDF/Core_MDF_Budget_Rejection_Submitter</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_CCFB_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to CCFB Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_CCFB_Fin_Mgr_Queue_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_CCF_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to CCF Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_CCF_Fin_Mgr_Queue_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_DCF_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to DCF Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_DCF_Fin_Mgr_Queue_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_RMF_APJ_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to RMF APJ Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_Retail_APJ_FinMgr_Q_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_RMF_ASMO_LAR_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to RMF ASMO LAR Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_Retail_ASMOLAR_FinMgr_Q_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_RMF_ASMO_NAR_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to RMF ASMO NAR Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_Retail_ASMONAR_FinMgr_Q_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_RMF_EMEA_Email_Alert</fullName>
        <description>Budget Approval email sent to RMF EMEA Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_Retail_EMEA_FinMgr_Q_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_RMF_PRC_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to RMF PRC Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_Retail_PRC_FinMgr_Q_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_SPCF_Budget_Email_Alert</fullName>
        <description>Budget Approval email sent to SPCF Finance Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_SPCF_Fin_Mgr_Queue_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyBudgetApprovers</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_MDFBudget_Status_Change_to_Rejected</fullName>
        <description>After rejection, Budget status field will be updated with &quot;rejected&quot; value</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Budget Status Change to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_BudgetStatus_Change_to_Approved</fullName>
        <description>After approval, Budget status field will be updated with &quot;approved&quot; value.</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Budget Status Change to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_Change_to_Approved</fullName>
        <description>After approval, Budget status field will be updated with &quot;approved&quot; value.</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Released</literalValue>
        <name>Status Change to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_Change_to_Rejected</fullName>
        <description>After rejection, Budget status field will be updated with &quot;rejected&quot; value</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Status Change to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_Change_to_Released</fullName>
        <description>After approval, Budget status field will be updated with &quot;Released&quot; value.</description>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Released</literalValue>
        <name>Status Change to Released</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_update_to_Approved</fullName>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_update_to_Rejected</fullName>
        <field>Core_MDF_Budget_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Status update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amount_to_Total_Allocated_Amount</fullName>
        <description>Reverting Amount field value</description>
        <field>Amount</field>
        <formula>TotalAllocatedAmount</formula>
        <name>Update Amount to Total Allocated Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
