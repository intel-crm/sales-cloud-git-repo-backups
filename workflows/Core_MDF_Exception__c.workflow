<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_ExceptionStatusUpdateAlert</fullName>
        <description>Core_MDF_ExceptionStatusUpdateAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_ExceptionApprovalStatusUpdate</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Status_to_Approved</fullName>
        <description>Update the status from Pending Review to Approved.</description>
        <field>Core_MDF_Exception_Status_nm__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Status_to_Denied</fullName>
        <description>Update exception status from Pending Review to Denied</description>
        <field>Core_MDF_Exception_Status_nm__c</field>
        <literalValue>Denied</literalValue>
        <name>Update Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
