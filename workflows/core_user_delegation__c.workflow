<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_SOS_for_Delegated_User</fullName>
        <description>Notify SOS for  Delegated User</description>
        <protected>false</protected>
        <recipients>
            <field>core_cpq_delegated_For__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>core_cpq_delegated_to__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSG_Email_Templates/Notify_SOS_for_delegated_user</template>
    </alerts>
    <rules>
        <fullName>Notify SOS  for end of delegation period</fullName>
        <active>false</active>
        <criteriaItems>
            <field>core_user_delegation__c.core_cpq_delegated_to__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notify SOS user for end of delegation period</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_SOS_for_Delegated_User</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>core_user_delegation__c.End_Date__c</offsetFromField>
            <timeLength>-3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
