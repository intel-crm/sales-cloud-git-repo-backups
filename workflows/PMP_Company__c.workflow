<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PMP_Company_Admin_Review_Alert_To_Admin</fullName>
        <description>PMP Company Admin Review Alert To Admin</description>
        <protected>false</protected>
        <recipients>
            <recipient>PMP_All_Intel_Admin_Users</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Submit_Template_for_Admin</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Edit_Required_Alert_To_Owner</fullName>
        <description>PMP Company Edit Required Alert To Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Edit_Template_for_Owner</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Edit_Required_First_Reminder_Alert_To_Owner</fullName>
        <description>PMP Company Edit Required First Reminder Alert To Owner</description>
        <protected>false</protected>
        <recipients>
            <field>PMP_Partner_Submitter_UserId__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>intel-partner-alliance@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_CompanyUpdateReqFirstNotification</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Edit_Required_Second_Reminder_Alert_To_Owner</fullName>
        <description>PMP Company Edit Required Second Reminder Alert To Owner</description>
        <protected>false</protected>
        <recipients>
            <field>PMP_Partner_Submitter_UserId__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>intel-partner-alliance@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_CompanyUpdateReqSecondNotification</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Reject_Alert_To_Owner</fullName>
        <description>PMP Company Reject Alert To Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Reject_Template_for_Owner</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Resubmit_Alert_To_Owner</fullName>
        <description>PMP Company Resubmit Alert To Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Resubmit_Template_for_Owner</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Resubmit_Alert_for_Admin</fullName>
        <description>PMP_Company_Resubmit_Alert_for_Admin</description>
        <protected>false</protected>
        <recipients>
            <field>PMP_Intel_Admin_Id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Resubmit_Template_for_Admin</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Resubmit_Alert_for_MPAdminGroup</fullName>
        <description>PMP_Company_Resubmit_Alert_for_MPAdminGroup</description>
        <protected>false</protected>
        <recipients>
            <recipient>PMP_All_Intel_Admin_Users</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Resubmit_Template_for_Admin</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Submitted_Alert_To_Owner</fullName>
        <description>PMP Company Submitted Alert To Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Submit_Template_for_Owner</template>
    </alerts>
    <alerts>
        <fullName>PMP_Company_Under_Review_Alert_To_Admin</fullName>
        <description>PMP_Company_Under_Review_Alert_To_Admin</description>
        <protected>false</protected>
        <recipients>
            <recipient>PMP_All_Intel_Admin_Users</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_PMP_Partner_MarketPlace_Templates/PMP_Company_Under_Review_Template_for_Admin</template>
    </alerts>
    <fieldUpdates>
        <fullName>PMP_LastStatusPublishedDate</fullName>
        <description>This is to update date when status is changed to published</description>
        <field>PMP_Company_Status_Published_Date_Dt__c</field>
        <formula>Today()</formula>
        <name>PMP_LastStatusPublishedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMP_LastStatusUpdate</fullName>
        <description>This is to store latest updated date of storefront details</description>
        <field>PMP_Last_Updated_Date_Dt__c</field>
        <formula>Today()</formula>
        <name>PMP_LastStatusUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMP_Sfid_Ref_Sync</fullName>
        <description>This field update is used to sync Sfid Ref sync</description>
        <field>PMP_Opid_Sfid_Ref_Txt__c</field>
        <formula>IF( LEN( PMP_Opid_Sfid_Txt__c )&lt;=255 ,PMP_Opid_Sfid_Txt__c , PMP_Opid_Sfid_Ref_Txt__c)</formula>
        <name>Sfid Ref Sync</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>One Partner Id Sync</fullName>
        <actions>
            <name>PMP_Sfid_Ref_Sync</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule is to sync opid sfid with one partner id  on Company record</description>
        <formula>PMP_Opid_Sfid_Txt__c&lt;&gt; PMP_Opid_Sfid_Ref_Txt__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PMP_CompanyUpdateRequiredReminder_WF</fullName>
        <active>false</active>
        <description>Trigger an Email Alert to Partner, if there is no action taken even after 3 days and even after 10 days</description>
        <formula>AND(ISPICKVAL(PMP_Company_Lifecycle_Status_Nm__c,&apos;Update Required&apos;), NOT(ISBLANK(PMP_Workflow_Three_Day_Trigger_Dt__c)), NOT(ISBLANK(PMP_Workflow_One_Week_Trigger_Dt__c)), IF ( PMP_Partner_Submitter_UserId__c !=NULL,   IF(PMP_Partner_Submitter_UserId__r.ContactId != NULL , Not(PMP_Partner_Submitter_UserId__r.Contact.Core_Do_Not_Contact__c), true),  false) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PMP_Company_Edit_Required_Second_Reminder_Alert_To_Owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>PMP_Company__c.PMP_Workflow_One_Week_Trigger_Dt__c</offsetFromField>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>PMP_Company_Edit_Required_First_Reminder_Alert_To_Owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>PMP_Company__c.PMP_Workflow_Three_Day_Trigger_Dt__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PMP_LastStatusUpdate_WF</fullName>
        <actions>
            <name>PMP_LastStatusUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow is used to update last updated date of storefront details.</description>
        <formula>OR(AND(ISCHANGED( PMP_Company_Lifecycle_Status_Nm__c), ISPICKVAL(PMP_Company_Lifecycle_Status_Nm__c, &apos;Admin Review&apos;)), AND(ISCHANGED( PMP_Company_Lifecycle_Status_Nm__c),ISPICKVAL( PMP_Company_Lifecycle_Status_Nm__c, &apos;Published&apos;),NOT(ISBLANK(PMP_Working_Copy_Id__c))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PMP_StatusPublishedDate_WF</fullName>
        <actions>
            <name>PMP_LastStatusPublishedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This is to store status published date of storefront</description>
        <formula>ISPICKVAL(  PMP_Company_Lifecycle_Status_Nm__c, &apos;Approved&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
