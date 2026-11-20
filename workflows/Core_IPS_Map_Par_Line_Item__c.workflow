<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Notify_email_requestor_that_line_item_status_has_changed</fullName>
        <description>Notify email requestor that line item status has changed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_PAR_Item_Internal_Closed</template>
    </alerts>
    <alerts>
        <fullName>Notify_email_requestor_that_line_item_status_has_changed</fullName>
        <description>Notify email requestor that MAP line item status has changed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_MAP_Item_Internal_Closed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_IPS_Line_Item_Update_Is_ParRequest</fullName>
        <field>Core_isPARRequest__c</field>
        <literalValue>0</literalValue>
        <name>Core IPS Line Item Update Is ParRequest</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Set_LI_Approver</fullName>
        <description>Set the name of the user that approved/rejected the PAR line item</description>
        <field>Core_LI_Approver__c</field>
        <formula>$User.Alias</formula>
        <name>Core IPS Set LI Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Set_LI_ApprvalStatus_to_Apprved</fullName>
        <field>Core_Line_Item_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Core IPS Set LI ApprvalStatus to Apprved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Set_LI_ApprvalStatus_to_Pending</fullName>
        <field>Core_Line_Item_Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Core IPS Set LI ApprvalStatus to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Set_LI_ApprvlStatus_to_Rejected</fullName>
        <field>Core_Line_Item_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Core IPS Set LI ApprvlStatus to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Set_LI_Decision_Date</fullName>
        <description>Set the current timestamp as the Decision Date</description>
        <field>Core_LI_Decision_Date__c</field>
        <formula>NOW()</formula>
        <name>Core IPS Set LI Decision Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Status_field_update</fullName>
        <field>Core_Status__c</field>
        <literalValue>ACTIVE</literalValue>
        <name>Core IPS Status field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_LineItem_Status_Inactive</fullName>
        <description>Set line item status to Inactive</description>
        <field>Core_Status__c</field>
        <literalValue>INACTIVE</literalValue>
        <name>Core IPS Update LineItem Status Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Line_Item_Status_Active</fullName>
        <description>Set line item status to active</description>
        <field>Core_Status__c</field>
        <literalValue>ACTIVE</literalValue>
        <name>Core IPS Update LineItem Stats to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_is_ParRequest</fullName>
        <description>Set is_ParRequest field to false.</description>
        <field>Core_isPARRequest__c</field>
        <literalValue>0</literalValue>
        <name>Core IPS Update is ParRequest</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_LineItem_Status</fullName>
        <actions>
            <name>Core_IPS_Status_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_IPS_MAP_PAR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PAR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Core_IPS_Map_Par_Line_Item__c.Core_Approval_Type__c</field>
            <operation>equals</operation>
            <value>Approval Required</value>
        </criteriaItems>
        <criteriaItems>
            <field>Core_IPS_Map_Par_Line_Item__c.Core_isPARRequest__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
