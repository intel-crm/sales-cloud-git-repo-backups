<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Partner_Lead_Status_Update_Email_Notification</fullName>
        <description>Partner Lead Status Update Email Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>wsm-postmaster@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Core_Partner_Lead_Management/Core_Partner_Lead_Status_Update</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_Uncheck_Send_Email</fullName>
        <field>Core_Send_Email__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Send Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <flowActions>
        <fullName>Core_Set_User_Defaults</fullName>
        <description>Uses flow to make set user preferences on create.</description>
        <flow>Core_Set_Default_User_Preferences</flow>
        <flowInputs>
            <name>UserName</name>
            <value>{!Username}</value>
        </flowInputs>
        <label>Set User Defaults</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Core_PartnerLead_StatusUpdate_Email</fullName>
        <actions>
            <name>Core_Partner_Lead_Status_Update_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Core_Uncheck_Send_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Core_Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_User_Set_Default_Preferences</fullName>
        <actions>
            <name>Core_Set_User_Defaults</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <description>Sets initial defaults for user preferences when a user is set up.</description>
        <formula>Len(Username) &gt; 0</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
