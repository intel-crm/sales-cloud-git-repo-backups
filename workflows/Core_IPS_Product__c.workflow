<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_IPS_Notify_email_requestor_that_IPS_Product_is_Rejected</fullName>
        <description>Core IPS Notify email requestor that IPS Product is Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IPS_Email_Templates/Core_IPS_Project_Item_Internal_Item_Updated</template>
    </alerts>
    <alerts>
        <fullName>Core_IPS_Notify_email_requestor_that_IPS_product_is_Approved</fullName>
        <description>Core IPS Notify email requestor that IPS product is Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IPS_Email_Templates/Core_IPS_Project_Item_Internal_Item_Updated</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Is_Approved</fullName>
        <field>Is_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update Is Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Update_Project_Status_to_Active</fullName>
        <field>Core_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Project Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Core_IPS_Project__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_status_to_not_approved</fullName>
        <field>Status__c</field>
        <literalValue>Not Approved</literalValue>
        <name>status to not approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPS_Product_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>IPS_Product_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPS_Product_Status_Not_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Not Approved</literalValue>
        <name>IPS_Product_Status_Not_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPS_Product_Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>IPS_Product_Status_Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core IPS Update Project Status to Active</fullName>
        <actions>
            <name>Core_IPS_Update_Project_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Core_IPS_Product__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Core_IPS_Project__c.Core_Status__c</field>
            <operation>notEqual</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
