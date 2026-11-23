<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sales_Alert_Order_Owner_on_SAP_submission_failure</fullName>
        <description>Alert Order Owner on SAP submission failure</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Order_Management/Sales_Order_Creation_Failed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Sales_Status</fullName>
        <field>Sales_status__c</field>
        <literalValue>Order Activated</literalValue>
        <name>Sales_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_PSG_Field update</fullName>
        <actions>
            <name>Sales_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
