<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_BO_BM_Delegated_Approver</fullName>
        <description>Notify BO/BM Delegated Approver</description>
        <protected>false</protected>
        <recipients>
            <field>sbaa__User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSG_Email_Templates/Notify_BO_BM_for_Delegated_Approver</template>
    </alerts>
    <rules>
        <fullName>Notify Delegated Approver 3 Days Before</fullName>
        <active>false</active>
        <criteriaItems>
            <field>sbaa__Approver__c.sbaa__DelegatedUserId__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_BO_BM_Delegated_Approver</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>sbaa__Approver__c.sbaa__DelegationEnd__c</offsetFromField>
            <timeLength>-3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
