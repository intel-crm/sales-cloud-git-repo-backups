<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_ActivityStatusUpdate</fullName>
        <description>This email alert is used to notify user upon activity status update</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_StatusUpdate</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_ActivityStatusUpdateNotificationToExternalUser</fullName>
        <description>This email alert is used to notify external user upon activity status update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_ExternalStatusChange</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_Set_Rejected</fullName>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status Set Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_step_to_1</fullName>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>1</formula>
        <name>Approval step to 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_step_to_2</fullName>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>2</formula>
        <name>Approval step to 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_step_to_3</fullName>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>3</formula>
        <name>Approval step to 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_step_to_4</fullName>
        <description>Pending approval to planned</description>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>4</formula>
        <name>Approval step to 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Activity_Approval_Update</fullName>
        <description>Update Status field to Planned on Approval</description>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Planned</literalValue>
        <name>Core_MDF_Activity_Approval_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Activity_Rejection_Step</fullName>
        <description>Set Status to Pending Review on rejection</description>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Revision Required</literalValue>
        <name>Core_MDF_Activity_Rejection_Step</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Activity_Update_PA_Status</fullName>
        <description>Update pending approval status</description>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Activity Update PA Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_1</fullName>
        <field>Core_MDF_Approver_1__c</field>
        <name>Clear Approver 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_10</fullName>
        <field>Core_MDF_Approver_10__c</field>
        <name>Clear Approver 10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_2</fullName>
        <field>Core_MDF_Approver_2__c</field>
        <name>Clear Approver 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_3</fullName>
        <field>Core_MDF_Approver_3__c</field>
        <name>Clear Approver 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_4</fullName>
        <field>Core_MDF_Approver_4__c</field>
        <name>Clear Approver 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_5</fullName>
        <field>Core_MDF_Approver_5__c</field>
        <name>Clear Approver 5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_6</fullName>
        <field>Core_MDF_Approver_6__c</field>
        <name>Clear Approver 6</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_7</fullName>
        <field>Core_MDF_Approver_7__c</field>
        <name>Clear Approver 7</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_8</fullName>
        <field>Core_MDF_Approver_8__c</field>
        <name>Clear Approver 8</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Approver_9</fullName>
        <field>Core_MDF_Approver_9__c</field>
        <name>Clear Approver 9</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_FU_Activity_End_Date_Is_Changed</fullName>
        <field>Core_MDF_End_Date_Is_Changed_ind__c</field>
        <literalValue>1</literalValue>
        <name>Update End_Date_Is_Changed to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_PriorValueOfStatusUpdate</fullName>
        <field>Core_MDF_PriorValueOfStatus__c</field>
        <formula>TEXT(PRIORVALUE( Core_MDF_Fund_Request_Status__c  ))</formula>
        <name>Core_MDF_PriorValueOfStatusUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Steps_Complete_Zero</fullName>
        <description>Update the steps completed as Zero for external approval</description>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>0</formula>
        <name>Steps Complete Zero</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Activity_Close_Status</fullName>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Update Activity Close Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Budget_Amount_Local</fullName>
        <description>Update the Budget Amount Local field with Requested Amount value when it is blank</description>
        <field>Core_MDF_Budget_Amount_Local_amt__c</field>
        <formula>RequestedAmount</formula>
        <name>Update Budget Amount Local</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Budget_Currency</fullName>
        <description>Update Budget Currency to USD</description>
        <field>Core_MDF_Budget_Currency_cd__c</field>
        <literalValue>USD</literalValue>
        <name>Update Budget Currency</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Fund_Request_Status</fullName>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Update Fund Request Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_UpdateActivityStatusPriorValue</fullName>
        <actions>
            <name>Core_MDF_PriorValueOfStatusUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the field &quot;Core_MDF_PriorValueOfStatus&quot; to the previous value of the status if the status is changed</description>
        <formula>ISCHANGED(  Core_MDF_Fund_Request_Status__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF_UpdateBudgetAmountAndCurrency</fullName>
        <actions>
            <name>Core_MDF_Update_Budget_Amount_Local</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_MDF_Update_Budget_Currency</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to update Budget Amount Local with Requested Amount and Budget Currency with USD</description>
        <formula>AND( 	ISNULL(Core_MDF_Budget_Amount_Local_amt__c), 	ISPICKVAL(Core_MDF_Budget_Currency_cd__c,&apos;&apos;),     ISCHANGED(Core_MDF_Fund_Request_Status__c), 	OR( 		ISPICKVAL(Core_MDF_Fund_Request_Status__c, &apos;Planned&apos;), 		ISPICKVAL(Core_MDF_Fund_Request_Status__c, &apos;Revision Required&apos;) 	), 	ISPICKVAL(PRIORVALUE(Core_MDF_Fund_Request_Status__c), &apos;Pending Review&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_MDF_WF_Activity_Close</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>PartnerFundRequest.Core_MDF_End_Date_Is_Changed_ind__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundRequest.Core_MDF_Fund_Request_Status__c</field>
            <operation>notContain</operation>
            <value>Cancelled,Closed,Rejected,Pending Approval,Pending Review</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Update_Activity_Close_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>PartnerFundRequest.Core_MDF_ToBeClosedDate__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_MDF_WF_Activity_EndDate_Is_Changed</fullName>
        <actions>
            <name>Core_MDF_FU_Activity_End_Date_Is_Changed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(     ISNEW(),     ISCHANGED( Core_MDF_End_Date__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
