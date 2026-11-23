<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Opportunity_PAR_Submitter_that_request_has_been_Approved_Rejected</fullName>
        <description>Notify Opportunity PAR Submitter that request has been Approved/Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>ips_do_not_reply@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IPS_Email_Templates/Core_IPS_Opportunity_PAR_For_Submitter</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved_Status</fullName>
        <field>Core_IPS_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Status</fullName>
        <field>Core_IPS_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update</fullName>
        <field>Core_IPS_Request_Justification__c</field>
        <formula>&quot;Core_IPS_Supported_ProductsName__c&quot;</formula>
        <name>Update Req Justification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approved_By</fullName>
        <field>Email_Template_Approved_By__c</field>
        <formula>$User.FirstName+&quot; &quot;+$User.LastName</formula>
        <name>Update Approved By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rejected_By</fullName>
        <field>Email_Template_Approved_By__c</field>
        <formula>$User.FirstName+&quot; &quot;+$User.LastName</formula>
        <name>Update Rejected By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_IPS_Send_Email_To_Submitter_On_Approval%2FRejection_OppPAR</fullName>
        <actions>
            <name>Notify_Opportunity_PAR_Submitter_that_request_has_been_Approved_Rejected</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Core_IPS_Approval_Status__c), 
OR( ISPICKVAL(Core_IPS_Approval_Status__c, &quot;Approved&quot;),
     ISPICKVAL(Core_IPS_Approval_Status__c, &quot;Rejected&quot;)
    ) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
