<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Opp_Notify_TeamMember_On_Addition</fullName>
        <description>Core_Opp_Notify_TeamMember_On_Addition</description>
        <protected>false</protected>
        <recipients>
            <field>UserId</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Core_Opportunity_Management/Opportunity_Team_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_OppTM_Org</fullName>
        <description>Sets the Org on the Opportunity Team Member as the value of the Department on the User field</description>
        <field>Core_Org__c</field>
        <formula>User.Department</formula>
        <name>Core_OppTM_Org</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Opp_TM_OSC_Update</fullName>
        <description>Field update for Core_OSC_Snapshot on OpportunityTeamMember object</description>
        <field>Core_OSC_Snapshot__c</field>
        <formula>IF(User.Core_Is_OSC__c , 1,0)</formula>
        <name>Core Opp TM OSC Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core_OppTM_Set_Values_Upon_Creation</fullName>
        <actions>
            <name>Core_OppTM_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets values on the Opportunity Team member record when created</description>
        <failedMigrationToolVersion>242.5</failedMigrationToolVersion>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppTeamMember_Notify_Member_On_Addition</fullName>
        <actions>
            <name>Core_Opp_Notify_TeamMember_On_Addition</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email to the opportunity team member when added to the opportunity team.</description>
        <formula>CreatedById  &lt;&gt;  Id</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppTeamMember_OSC_Update</fullName>
        <actions>
            <name>Core_Opp_TM_OSC_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update Core_OSC_Snapshot upon team member creation.</description>
        <formula>ISNULL( Core_OSC_Snapshot__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
