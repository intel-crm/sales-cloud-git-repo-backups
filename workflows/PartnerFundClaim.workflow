<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_Claim_Adjustment_Cancellation_Ext</fullName>
        <description>Core MDF Claim Adjustment Cancellation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Adj_Cancelled_Ext</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Adjustment_Cancellation_Internal</fullName>
        <description>Claim Adjustment Cancellation Owned by Internal User</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Adj_Cancelled_Int</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Notifications_Status_PAF</fullName>
        <description>Core MDF Claim Notifications - Status PAF</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Status_PAF</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Notifications_Status_PAF_Partner</fullName>
        <description>Core MDF Claim Notifications - Status PAF_Partner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Status_PAF_Partner</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Notifications_Status_on_Hold</fullName>
        <description>Core MDF Claim Notifications - Status on Hold for ESD reason</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Status_OnHold</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Notifications_Status_on_Hold_for_ESD_reason_Partner</fullName>
        <description>Core MDF Claim Notifications - Status on Hold for ESD reason Partner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Status_OnHold_Partner</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Status_Closed_External</fullName>
        <description>Claim Status Closed Owned by External User</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Closed_Ext</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Claim_Status_Closed_Internal</fullName>
        <description>Claim Status Closed Owned by Internal User</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Claim_Closed_Int</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_DocSubmissionConfirmation</fullName>
        <description>Core_MDF_DocSubmissionConfirmation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_DocSubmissionConfirmation</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_DocUploadRequestBefore15DaysAlert</fullName>
        <description>Core_MDF_DocUploadRequestBefore15DaysAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_DocUploadRequestBefore15Days</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_DocUploadRequestBefore5DaysAlert</fullName>
        <description>Core_MDF_DocUploadRequestBefore5DaysAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_DocUploadRequestBefore5Days</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_DocUploadRequestImmediateAlert</fullName>
        <description>Core_MDF_DocUploadRequestImmediateAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_DocumentUploadRequest</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Legacy_Before_Payment_Maximum_Attempts_Reached</fullName>
        <description>Core MDF Legacy Before Payment Maximum Attempts Reached</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Legacy_Before_Max_Attempts</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Legacy_Document_Submission_Window_Closed</fullName>
        <description>Core MDF Legacy Document Submission Window Closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Legacy_Doc_Sub_Window_Closed</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Legacy_Post_Payment_Document_Submission_Window_Closed</fullName>
        <description>Core MDF Legacy Post Payment Document Submission Window Closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Legacy_Post_DocSubWindowClosed</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Legacy_Post_Payment_Maximum_Attempts_Reached</fullName>
        <description>Core MDF Legacy Post Payment Maximum Attempts Reached</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Legacy_Post_Max_Attempt_Reached</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_NotifyClaimSubmitterOn_PICPass</fullName>
        <description>Core_MDF_NotifyClaimSubmitterOn_PICPass</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_NotifyClaimSubmitterOn_PICPass</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_PIC_Claim_Notification_Hold_Internal</fullName>
        <description>Core MDF Claim Notifications - Hold during PIC for Internal</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_PIC_Claim_OnHold</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_PIC_Claim_Notification_Hold_Partner</fullName>
        <description>Core MDF Claim Notifications - Hold during PIC for Partner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_PIC_Claim_OnHold_Partner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_MDF_Empty_Claim_Approval_Date</fullName>
        <field>Core_MDF_Claim_Comments__c</field>
        <name>Empty Claim Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_PIC_Pending</fullName>
        <field>Core_MDF_Status__c</field>
        <literalValue>PIC Pending</literalValue>
        <name>PIC Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_PIC_Review_Completed_to_True</fullName>
        <field>Core_MDF_PIC_Review_Completed__c</field>
        <literalValue>1</literalValue>
        <name>PIC Review Completed to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Payment_Clearance_Processing</fullName>
        <field>Core_MDF_Status__c</field>
        <literalValue>Payment Clearance Processing</literalValue>
        <name>Payment Clearance Processing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Reset_Approval_Stage</fullName>
        <field>Core_MDF_Approval_Stage_nm__c</field>
        <name>Reset Approval Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Set_Step_Counter_to_0</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>0</formula>
        <name>Set Step Counter to 0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Step_Counter_to_0</fullName>
        <field>Core_MDF_Approval_Step_Counter_nbr__c</field>
        <formula>0</formula>
        <name>Step Counter to 0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_UpdateFlaggedForReview_to_True</fullName>
        <field>Core_MDF_FlaggedForAudit__c</field>
        <literalValue>1</literalValue>
        <name>Update Flagged for Review to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_UpdateReviewType</fullName>
        <field>Core_MDF_Audit_Type__c</field>
        <literalValue>Document Hold</literalValue>
        <name>Update ReviewType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Claim_Approval_Date</fullName>
        <description>Stamp todays date on Claim Approval Date</description>
        <field>Core_MDF_Claim_Approval_Dt__c</field>
        <formula>TODAY()</formula>
        <name>Update Claim Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Claim_Eval_to_False</fullName>
        <field>Core_MDF_Claim_EvalInProgress_Ind__c</field>
        <literalValue>0</literalValue>
        <name>Update Claim Eval to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Claim_Status_Submitted</fullName>
        <field>Core_MDF_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Claim Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Eligible_for_PIC_to_true</fullName>
        <field>Core_MDF_Eligible_for_PIC__c</field>
        <literalValue>1</literalValue>
        <name>Update Eligible for PIC to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Review_Hold_to_True</fullName>
        <field>Core_MDF_Audit_Hold__c</field>
        <literalValue>1</literalValue>
        <name>Update Review Hold to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Status_to_Resub_Required</fullName>
        <field>Core_MDF_Status__c</field>
        <literalValue>Resubmission Required</literalValue>
        <name>Update Status to Resubmission Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Claim_Status_to_Denied</fullName>
        <field>Core_MDF_Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Update Claim Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Claim_Status_to_Paid</fullName>
        <description>Used to update the Claim status as &apos;Paid&apos;</description>
        <field>Core_MDF_Status__c</field>
        <literalValue>Paid</literalValue>
        <name>Update Claim Status to Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Document_Submission_Missed_Ind</fullName>
        <description>Used to check the Core_MDF_Document_Submission_Missed_Ind__c field.</description>
        <field>Core_MDF_Document_Submission_Missed_Ind__c</field>
        <literalValue>1</literalValue>
        <name>Update Document Submission Missed Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Legacy_Reminder_as_Reminder_1</fullName>
        <description>Update Legacy remainder field as &apos;Remainder 1&apos;</description>
        <field>Core_MDF_Legacy_Reminder_txt__c</field>
        <literalValue>Reminder 1</literalValue>
        <name>Update Legacy Reminder as Reminder 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Legacy_Reminder_as_Reminder_2</fullName>
        <description>Update Legacy reminder field as &apos;Reminder 2&apos;</description>
        <field>Core_MDF_Legacy_Reminder_txt__c</field>
        <literalValue>Reminder 2</literalValue>
        <name>Update Legacy Reminder as Reminder 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Legacy_Reminder_as_Reminder_3</fullName>
        <description>Update Legacy reminder field as &apos;Reminder 3&apos;</description>
        <field>Core_MDF_Legacy_Reminder_txt__c</field>
        <literalValue>Reminder 3</literalValue>
        <name>Update Legacy Reminder as Reminder 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_Document_Hold_Request_Notifications</fullName>
        <actions>
            <name>Core_MDF_DocUploadRequestImmediateAlert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>PartnerFundClaim.Core_MDF_Document_Hold_Ind__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundClaim.Core_MDF_Document_Hold_Eligibility_Ind__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundClaim.Core_MDF_Status__c</field>
            <operation>equals</operation>
            <value>Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundClaim.Core_MDF_Audit_Hold__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundClaim.RecordTypeId</field>
            <operation>contains</operation>
            <value>Client Co-Marketing Fund,Data Center Co-Marketing Fund</value>
        </criteriaItems>
        <description>This workflow rule is used to send notifications to claim submitter to upload documents before the due date
Reminders on 15th,25th day of document submission due date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_DocUploadRequestBefore5DaysAlert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>PartnerFundClaim.Core_MDF_Document_Submission_DueDate_dtm__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_UpdateFlaggedForReview_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Core_MDF_UpdateReviewType</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Core_MDF_Update_Review_Hold_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>PartnerFundClaim.Core_MDF_Document_Submission_DueDate_dtm__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_DocUploadRequestBefore15DaysAlert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>PartnerFundClaim.Core_MDF_Document_Submission_DueDate_dtm__c</offsetFromField>
            <timeLength>-15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
