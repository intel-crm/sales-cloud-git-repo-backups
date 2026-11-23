<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_DDR_Notify_Design_Owner_On_Approval</fullName>
        <description>Notify Design Owner On Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DDR_Email_Templates/Core_DDR_Notify_Design_Owner_On_Approval</template>
    </alerts>
    <alerts>
        <fullName>Core_DDR_Notify_Design_Owner_On_Rejection</fullName>
        <description>Notify Design Owner On Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DDR_Email_Templates/Core_DDR_Notify_Design_Owner_On_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Core_DDR_Send_Open_Design_Notification</fullName>
        <description>Send Open Design Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Partner_Account_Owner_Email_Txt__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>ddr.admin@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DDR_Email_Templates/Core_DDR_Notify_Owners_On_Open_Design</template>
    </alerts>
    <alerts>
        <fullName>Deal_Approved_Notification_Partner</fullName>
        <description>Deal Approved Notification to Partner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dealreg_partner@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Deal_Approved_Notification_to_Partner</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_for_Sales_Desk_ASMO</fullName>
        <description>Email alert for Sales Desk ASMO</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_ASMO</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_ASMO</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_for_sales_desk</fullName>
        <description>Email alert for sales desk</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_ASMO</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_ASMO</template>
    </alerts>
    <alerts>
        <fullName>PCC_Deal_Approved_Notification_to_Approver</fullName>
        <description>Deal Approved Notification to Approver</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Intel_Technical_Owner_Id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dealreg_partner@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/PCC_Deal_Approved_Notification_for_Approver_Template</template>
    </alerts>
    <alerts>
        <fullName>PCC_Deal_Rejected_Notification_to</fullName>
        <description>Deal Rejected Notification to Partner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dealreg_partner@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/PCC_Deal_Rejected_Notification_to_Partner</template>
    </alerts>
    <alerts>
        <fullName>PCC_Deal_Rejected_Notification_to_Approver</fullName>
        <description>Deal Rejected Notification to Approver</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Accepted_By_Id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dealreg_partner@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/PCC_Deal_Rejected_Notification_to_Approver_Template</template>
    </alerts>
    <alerts>
        <fullName>PCC_Notify_Channel_Ops_group_Email_Alert</fullName>
        <description>Notify Channel Ops group Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>AGS_Channel_Ops_Approver_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DDR_Email_Templates/PCC_Notify_Channel_Ops_Users</template>
    </alerts>
    <alerts>
        <fullName>Rebate_Analyst_Notification_For_Actions</fullName>
        <description>Rebate Analyst Notification For Actions</description>
        <protected>false</protected>
        <recipients>
            <recipient>PCC_Rebate_Claim_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>dealreg_partner@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PCC_RebateClaim/PCC_Rebate_Claim_Reminder_To_RA</template>
    </alerts>
    <alerts>
        <fullName>Sales_Desk_APJ</fullName>
        <description>Sales Desk APJ</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_APJ</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Email_Templates/Sales_Desk_APJ</template>
    </alerts>
    <alerts>
        <fullName>Sales_Desk_Approval_APJ</fullName>
        <description>Sales Desk Approval APJ</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_APJ</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_APJ</template>
    </alerts>
    <alerts>
        <fullName>Sales_Desk_Approval_EMEA</fullName>
        <description>Sales Desk Approval EMEA</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_EMEA</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_EMEA</template>
    </alerts>
    <alerts>
        <fullName>Sales_Desk_Approval_PRC</fullName>
        <description>Sales Desk Approval PRC</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_PRC</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_PRC</template>
    </alerts>
    <alerts>
        <fullName>Sales_Desk_EMEA</fullName>
        <description>Sales Desk EMEA</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_EMEA</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_EMEA</template>
    </alerts>
    <alerts>
        <fullName>Sales_Desk_PRC</fullName>
        <description>Sales Desk PRC</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Sales_Desk_PRC</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Email_Templates/Sales_Desk_PRC</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_PSAM_and_End_Customer_Account_Owner</fullName>
        <description>Send Email to PSAM and End Customer Account Owner</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Email_Templates/Notify_PSAM_and_End_Customer_Account_Owner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approve_the_Deal</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Approved</literalValue>
        <name>Approve the Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeStatusToDesignAccepted</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Design accepted</literalValue>
        <name>ChangeStatusToDesignAccepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Submitted</fullName>
        <description>Change Status to Submitted</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Submitted</literalValue>
        <name>Change Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Assign_Partner_Region</fullName>
        <field>Core_Partner_Account_Region_Cd__c</field>
        <formula>TEXT(Core_Partner_Account_Id__r.Core_Geo__c)</formula>
        <name>Assign Partner Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Design_Record_Type_To_Locked</fullName>
        <description>Updates the Record Type, so the page layout using this record type locks the fields in UI.</description>
        <field>RecordTypeId</field>
        <lookupValue>Core_Design_Registration_Partner</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Design Record Type To Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Design_Record_Type_To_Read_Only</fullName>
        <description>Updates the Record Type, so the page layout using this record type locks ALL the fields in UI.</description>
        <field>RecordTypeId</field>
        <lookupValue>Core_Design_Registration_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Design Record Type To Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Design_Record_Type_To_Unlocked</fullName>
        <description>Updates the Record Type, so the page layout using this record type unlocks the fields in UI.</description>
        <field>RecordTypeId</field>
        <lookupValue>Core_Design_Registration_Intel</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Design Record Type To Unlocked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Get_Partner_Account_Owner_Email</fullName>
        <description>Gets the Partner Account Owner&apos;s Email from the Partner Account tied to the Design.</description>
        <field>Core_Partner_Account_Owner_Email_Txt__c</field>
        <formula>Core_Partner_Account_Id__r.Owner.Email</formula>
        <name>Get Partner Account Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Set_Status_To_Abandoned</fullName>
        <description>Sets the Status of the Design to Abandoned.</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Abandoned</literalValue>
        <name>Set Status To Abandoned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Designaccepted</fullName>
        <description>This step will call when first level of approval is done and PSAM is covered.</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Deal accepted</literalValue>
        <name>Designaccepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PCC_Change_Record_Type</fullName>
        <description>Change Record Type to Deal Registration Partner</description>
        <field>RecordTypeId</field>
        <lookupValue>PCC_Deal_Registration_Partner</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to Deal Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PCC_Change_Record_Type_to_Deal_Partner</fullName>
        <description>Change Record Type to Deal Registration Partner</description>
        <field>RecordTypeId</field>
        <lookupValue>PCC_Deal_Registration_Partner</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to Deal Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PCC_Change_Status_to_Submitted</fullName>
        <description>Change Status to Submitted</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Submitted</literalValue>
        <name>Change Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PCC_Update_the_status_to_L1</fullName>
        <description>Update the status to L1</description>
        <field>PCC_Approval_Level__c</field>
        <literalValue>Level 1</literalValue>
        <name>Update the status to L1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recall_the_Deal</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Deal_Registration_Draft</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Recall the Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusChange</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Submitted</literalValue>
        <name>StatusChange</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusRemainUnchanged</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Pre-Approved</literalValue>
        <name>StatusRemainUnchanged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus</fullName>
        <description>Update Deal Status to Design Accepted</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Design accepted</literalValue>
        <name>UpdateStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Level_To_Two</fullName>
        <field>PCC_Approval_Level__c</field>
        <literalValue>Level 2</literalValue>
        <name>Update Approval Level To Two</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deal</fullName>
        <description>This action will mark deal as precheck completed</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Pre-Approved</literalValue>
        <name>Update Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deal_Precheck_Complete</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Pre-Approved</literalValue>
        <name>Update Deal = Precheck Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Deal_Registration_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_Lock</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Deal_Registration_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Draft</fullName>
        <field>Workflow_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Update Stage to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_To_Deal_Accepted</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Deal accepted</literalValue>
        <name>Update Status To Deal Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_to_Precheck_completed</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Pre-Approved</literalValue>
        <name>Update status to Precheck completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Record_status</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update the Record - status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Status_Deal_Accepted</fullName>
        <description>to Deal Accepted for Approval</description>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Design accepted</literalValue>
        <name>Update the Status = Deal Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_staus</fullName>
        <field>Core_Design_Registration_Status_Nm__c</field>
        <literalValue>Draft</literalValue>
        <name>Update the staus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>fedf</fullName>
        <field>Core_End_Customer_Contact_Phone_Txt__c</field>
        <name>fedf</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_DDR_Calculate_Partner_Region</fullName>
        <actions>
            <name>Core_DDR_Assign_Partner_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR(ISNEW(), ISCHANGED(Core_Partner_Account_Id__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Lock_Design</fullName>
        <actions>
            <name>Core_DDR_Design_Record_Type_To_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Changes the Record Type, so the design fields are NOT editable by Intel user.</description>
        <formula>Owner:User.Profile.Name = &apos;Partner&apos; &amp;&amp; NOT(RecordTypeId =  $Label.Core_DDR_Design_Locked_Record_Type_ID)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Send_Email_On_Design_Approval</fullName>
        <actions>
            <name>Core_DDR_Notify_Design_Owner_On_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_Design_Registration__c.Core_Design_Registration_Status_Nm__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Sends Email to Design Owner (Partner User) when Design is Approved.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Send_Email_On_Design_Rejection</fullName>
        <actions>
            <name>Core_DDR_Notify_Design_Owner_On_Rejection</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_Design_Registration__c.Core_Design_Registration_Status_Nm__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>Sends Email to Design Owner (Partner User) when Design is Rejected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Send_Email_On_Open_Design</fullName>
        <active>false</active>
        <description>Sends Email to Design Owner and Partner Account Owner when Design is Open for 150 days.</description>
        <formula>ISPICKVAL(Core_Design_Registration_Status_Nm__c, &apos;Submitted&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_DDR_Send_Open_Design_Notification</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Core_DDR_Get_Partner_Account_Owner_Email</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>150</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_DDR_Unlock_Design</fullName>
        <actions>
            <name>Core_DDR_Design_Record_Type_To_Unlocked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Changes the Record Type, so the design fields are editable by Intel user.</description>
        <formula>Owner:User.Profile.Name &lt;&gt; &apos;Partner&apos; &amp;&amp; NOT(RecordTypeId = $Label.Core_DDR_Design_Locked_Record_Type_ID)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Update_Status_To_Abandoned</fullName>
        <active>false</active>
        <description>Changes the Status of the Design to Abandoned if the Design is Open for 180 days.</description>
        <failedMigrationToolVersion>238.9.4</failedMigrationToolVersion>
        <formula>ISPICKVAL(Core_Design_Registration_Status_Nm__c, &apos;Submitted&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_DDR_Design_Record_Type_To_Read_Only</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Core_DDR_Set_Status_To_Abandoned</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Core_Design_Registration__c.CreatedDate</offsetFromField>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>test Time based</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Core_Design_Registration__c.Core_Design_Registration_Status_Nm__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
