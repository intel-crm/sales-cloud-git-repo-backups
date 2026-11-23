<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_MDF_ActivityRejectionUpdate</fullName>
        <description>This email alert is used to notify Geo Approvers on Rejection by External Approver</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Activity_First_Approver_txt__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_StatusUpdate</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_ActivityStatusUpdate</fullName>
        <description>This email alert is used to notify user upon activity status update</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_StatusUpdate_Internal</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_ActivityStatusUpdateNotificationToExternalUser</fullName>
        <description>This email alert is used to notify external user upon activity status update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_ExternalStatusChange</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Activity_Prior_Approval_Notification</fullName>
        <description>Activity Prior Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Approver_10__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_1__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_3__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_4__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_5__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_6__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_7__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_8__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_9__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Activity_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Activity_Prior_Approval_Notification_External</fullName>
        <description>Activity Prior Approval Notification External</description>
        <protected>false</protected>
        <recipients>
            <field>Core_MDF_Approver_10__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_1__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_3__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_4__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_5__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_6__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_7__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_8__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Core_MDF_Approver_9__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_Activity_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_Notify_AfterTheFact_Users</fullName>
        <description>To notify After the Fact users when Activity is edited in past date</description>
        <protected>false</protected>
        <recipients>
            <recipient>Core_MDF_AfterTheFact_Users_Grp</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_StatusUpdate</template>
    </alerts>
    <alerts>
        <fullName>Core_MDF_RMF_ActivityStatusUpdate</fullName>
        <description>This email alert is used to notify RMF Internal user upon activity status update</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Core_MDF_RMF_StatusUpdate</template>
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
        <fullName>Clear_Activity_First_Approver</fullName>
        <description>To clear the Activity First Approver field</description>
        <field>Core_MDF_Activity_First_Approver_txt__c</field>
        <name>Clear Activity First Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Approval_Stage</fullName>
        <description>Clear Approval Stage</description>
        <field>Core_MDF_Approval_Stage__c</field>
        <literalValue>None</literalValue>
        <name>Clear Approval Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Approval_Stage_L1_app</fullName>
        <description>Clear Approval Stage</description>
        <field>Core_MDF_Approval_Stage__c</field>
        <name>Clear Approval Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Field_Modified</fullName>
        <field>Core_MDF_Is_Field_Modified__c</field>
        <literalValue>0</literalValue>
        <name>Clear Field Modified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_L1_Approver</fullName>
        <field>Core_MDF_L1_Approver_Id__c</field>
        <name>Clear L1 Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_L1_Primary_Approver</fullName>
        <field>Core_MDF_L1_Primary_Approver_Id__c</field>
        <name>Clear L1 Primary Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_User_Role_L1_Approver</fullName>
        <description>Clearing User Role L1 Approver</description>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role L1 Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_User_Role_L2_Approver</fullName>
        <description>Clear User Role L2 Approver</description>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role L2 Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_User_Role_POR</fullName>
        <description>Clearing User Role POR</description>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role POR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Core_MDF_Activity_InProgress_Update</fullName>
        <description>Set Activity status back to In-Progress</description>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>In-Progress</literalValue>
        <name>Core_MDF_Activity_InProgress_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Activity_Rejection_InProgressRR</fullName>
        <description>Set Status to In-Progress Revision Required on rejection</description>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>In-Progress Revision Required</literalValue>
        <name>Core_MDF_Activity_Rejection_InProgressRR</name>
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
        <description>Update pending review status</description>
        <field>Core_MDF_Fund_Request_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Activity Update Pending Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Approval_step_to_5</fullName>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>5</formula>
        <name>Approval step to 5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Approval_step_to_6</fullName>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>6</formula>
        <name>Approval Step to 6</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <fullName>Core_MDF_Clear_Approver_Comment_Field</fullName>
        <field>Core_MDF_Internal_Approval_Comment_txt__c</field>
        <name>Clear Approver Comment Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_Completed_Approval_step</fullName>
        <field>Core_MDF_Completed_Approval_Level_Name__c</field>
        <name>Clear Completed Approval step</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_L1_Manager</fullName>
        <field>Core_MDF_Activity_First_Approver_txt__c</field>
        <name>Clear L1 Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_PCT_Ind</fullName>
        <field>Core_MDF_Price_reviewer_check_ind__c</field>
        <literalValue>0</literalValue>
        <name>Clear PCT Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_POR_Ind</fullName>
        <field>Core_MDF_Program_Office_Check_ind__c</field>
        <literalValue>0</literalValue>
        <name>Clear POR Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_Ext_Approver</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role Ext Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_GeoLead</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role GeoLead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_L1_Mgr</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role L1 Mgr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_L2_Marketing</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role L2 Marketing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_L2_Mgr</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role L2 Mgr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_L2_Sales</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role L2 Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Clear_User_Role_PCT</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role PCT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_EEF_Clear_User_Role</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <name>Clear User Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
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
        <fullName>Core_MDF_Increment_step_counter</fullName>
        <description>Increment the step counter</description>
        <field>Core_MDF_Approval_Step_Completed__c</field>
        <formula>Core_MDF_Approval_Step_Completed__c + 1</formula>
        <name>Increment step counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <fullName>Core_MDF_Reset_ATF_Approval_Reqd_Ind</fullName>
        <field>Core_MDF_ATF_Approval_Reqd_ind__c</field>
        <literalValue>0</literalValue>
        <name>Reset ATF Approval Reqd Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Reset_ATF_Approved_Ind</fullName>
        <description>Reset Core_MDF_After_the_Fact_Approved_ind__c to False</description>
        <field>Core_MDF_After_the_Fact_Approved_ind__c</field>
        <literalValue>0</literalValue>
        <name>Reset ATF Approved Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Set_Activity_Approved_Ind</fullName>
        <field>Core_MDF_Is_Activity_Approved_ind__c</field>
        <literalValue>1</literalValue>
        <name>Set Activity Approved Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Act_NoInternal_CloseDt</fullName>
        <field>Core_MDF_No_Internal_Close_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Act NoInternalApprovalCloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_ActivityExpDate</fullName>
        <field>Core_MDF_Exp_Close_Dt__c</field>
        <formula>TODAY()</formula>
        <name>Update Activity Expected CloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Core_MDF_Update_Clos_Typ_To_Mis_Approval</fullName>
        <field>Core_MDF_Activity_Closure_Type__c</field>
        <literalValue>No External Approval</literalValue>
        <name>Update Closure Type to Missed Ext App</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_Closure_Type_to_Auto</fullName>
        <field>Core_MDF_Activity_Closure_Type__c</field>
        <literalValue>Auto</literalValue>
        <name>Update Closure Type to Auto</name>
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
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_Activating_Ext</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;External Activating Approver&quot;</formula>
        <name>Update User Role Activating External</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_Ext_Approver</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;External Approver&quot;</formula>
        <name>Update User Role Ext Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_GeoLead</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;Geo Lead&quot;</formula>
        <name>Update User Role GeoLead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_L1_Mgr</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L1 Mgr&quot;</formula>
        <name>Update User Role L1 Mgr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_L2_Marketing</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L2 Marketing&quot;</formula>
        <name>Update User Role L2 Marketing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_L2_Mgr</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L2 Mgr&quot;</formula>
        <name>Update User Role L2 Mgr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_L2_Sales</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L2 Sales&quot;</formula>
        <name>Update User Role L2 Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_PCT</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;PCT&quot;</formula>
        <name>Update User Role PCT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_Update_User_Role_Primary_Ext</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;External Primary Approver&quot;</formula>
        <name>Update User Role Primary External</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_User_Role_to_L1_Activating_App</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L1 Approval (Activating Partner)&quot;</formula>
        <name>User Role to L1 Activating Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_MDF_User_Role_to_L1_Primary_App</fullName>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L1 Approval (Primary Partner)&quot;</formula>
        <name>User Role to L1 Primary Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_IsRSMCreatedATFApprovedActivity</fullName>
        <description>to Reset the &quot;Is RSM Created ATF Approved Activity&quot; indicator</description>
        <field>Core_MDF_IsRSMCreatedATFApproved_Ind__c</field>
        <literalValue>0</literalValue>
        <name>Reset IsRSMCreatedATFApprovedActivity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ATF_Approved</fullName>
        <field>Core_MDF_After_the_Fact_Approved_ind__c</field>
        <literalValue>1</literalValue>
        <name>Update ATF Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Activity_CloseDate_to_Today</fullName>
        <field>Core_MDF_ToBeClosedDate__c</field>
        <formula>TODAY()</formula>
        <name>Update Activity CloseDate to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closure_Type_to_Approval_Close</fullName>
        <field>Core_MDF_Activity_Closure_Type__c</field>
        <literalValue>No Internal Approval</literalValue>
        <name>Update Closure Type to Approval Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsRSMCreatedATFApprovedActivity</fullName>
        <description>to update the &quot;Is RSM Created ATF Approved Activity &quot; Indicator</description>
        <field>Core_MDF_IsRSMCreatedATFApproved_Ind__c</field>
        <literalValue>1</literalValue>
        <name>Update IsRSMCreatedATFApprovedActivity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_User_Role_L1_Approver</fullName>
        <description>Updating User Role to L1 Approver</description>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L1 Approver&quot;</formula>
        <name>Update User Role L1 Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_User_Role_L2_Approver</fullName>
        <description>Update User Role L2 Approver</description>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;L2 Approver&quot;</formula>
        <name>Update User Role L2 Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_User_Role_POR</fullName>
        <description>Update User Role POR</description>
        <field>Core_MDF_UserRole_txt__c</field>
        <formula>&quot;Program Office Review&quot;</formula>
        <name>Update User Role POR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_MDF_PFR_Approval_Prior_Notification_External</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>PartnerFundRequest.RecordTypeId</field>
            <operation>equals</operation>
            <value>Retail Marketing Funds</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundRequest.Core_MDF_Fund_Request_Status__c</field>
            <operation>equals</operation>
            <value>Pending Approval</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Activity_Prior_Approval_Notification_External</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>PartnerFundRequest.Core_MDF_Start_Date__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Core_MDF_PFR_Approval_Prior_Notification_Internal</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>PartnerFundRequest.RecordTypeId</field>
            <operation>equals</operation>
            <value>Retail Marketing Funds</value>
        </criteriaItems>
        <criteriaItems>
            <field>PartnerFundRequest.Core_MDF_Fund_Request_Status__c</field>
            <operation>equals</operation>
            <value>Pending Review</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Core_MDF_Activity_Prior_Approval_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>PartnerFundRequest.Core_MDF_Start_Date__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
