<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_Notify_CCF_Boost_Finance_User_upon_Budget_Escalation_Approval</fullName>
        <description>Notify CCF Boost Finance User upon Budget Escalation Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_CCF_Boost_Finance_User</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Budget_Escl_Approval_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_Claim_Case_Reviewer_upon_Late_Claim_Escalation_Approval</fullName>
        <description>Notify Claim Case Reviewer Manager upon Late Claim Escalation Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_Claim_Case_Reviewer_Mgr_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Late_Claim_Escalation_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_DCF_Finance_User_upon_Budget_Escalation_Approval</fullName>
        <description>Notify DCF Finance User upon Budget Escalation Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_DCF_Finance_User</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Budget_Escl_Approval_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_Finance_User_upon_Budget_Escalation_Approval</fullName>
        <description>Notify CCF Finance User upon Budget Escalation Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_CCF_Finance_User</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Budget_Escl_Approval_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_SPCF_Finance_User_upon_Budget_Escalation_Approval</fullName>
        <description>Notify SPCF Finance User upon Budget Escalation Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_CCP_SPCF_Finance_User</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Budget_Escl_Approval_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_the_Escalation_Submitter_when_Approved</fullName>
        <description>Notify Escalation Submitter when Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Escalation_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_the_Escalation_Submitter_when_Denied</fullName>
        <description>Notify Escalation Submitter when Denied</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Escalation_Approval_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_MDF_Cancel_Status</fullName>
        <field>Core_MDF_Escalation_Status_nm__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Cancel Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_to_Approved</fullName>
        <field>Core_MDF_Escalation_Status_nm__c</field>
        <literalValue>Approved</literalValue>
        <name>Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Status_to_Denied</fullName>
        <field>Core_MDF_Escalation_Status_nm__c</field>
        <literalValue>Denied</literalValue>
        <name>Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
