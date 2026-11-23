<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Initial_Submission_Action_for_Quote_Approval</fullName>
        <description>Initial Submission Action for Quote Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>intelquoterequest@intel.com.crm.crmdevint</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteLineApprovalInitial_Notify</template>
    </alerts>
    <alerts>
        <fullName>Pricing_QuoteLine_Approval_Initial_Email</fullName>
        <description>Initial Submission Action for Quote Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>11579289@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteLineApprovalNotification</template>
    </alerts>
    <alerts>
        <fullName>Pricing_Tender_QuoteLine_Rejected_Notification</fullName>
        <description>Pricing Tender QuoteLine Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Pricing_Sales_Rep_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Pricing_Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ_Email_Templates/Pricing_QuoteLineRejectedNotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Pending_Further_Intel_Review_Status_UPD</fullName>
        <description>Pending Further Intel Review Status Update</description>
        <field>Pricing_Status_Nm__c</field>
        <literalValue>Pending Further Intel Review</literalValue>
        <name>Pending Further Intel Review Status UPD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pricing_Update_Status_to_Rejected</fullName>
        <field>Pricing_Update_Status_to_Rejected_cb__c</field>
        <literalValue>1</literalValue>
        <name>Update Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Is_Additional_T_C_Not_Blank_to_TRUE</fullName>
        <field>Pricing_Is_Additional_T_C_Not_Blank_cb__c</field>
        <literalValue>1</literalValue>
        <name>Set Is Additional T&amp;C Not Blank to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Is Additional T%27s %26 C%27s blank or not%3F</fullName>
        <actions>
            <name>Set_Is_Additional_T_C_Not_Blank_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update &quot;Is Additional T&apos;s &amp; C&apos;s Not Blank&quot; checkbox to TRUE if Additional T&apos;s &amp; C&apos;s is not NULL</description>
        <formula>AND(  
OR(
	$RecordType.Name =&apos;Pricing Tender Quote Line - Create&apos;,
	$RecordType.Name =&apos;Pricing Tender Quote Line - Submitted&apos;,
	$RecordType.Name =&apos;Pricing Tender Quote Line - Edit&apos;,
	$RecordType.Name =&apos;Pricing Tender Quote Line - ReadOnly&apos;
),
OR(
 ISNEW() , 
 ISCHANGED(Pricing_Additional_T_C_s_Txt__c) 
),
NOT(ISBLANK(Pricing_Additional_T_C_s_Txt__c))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
