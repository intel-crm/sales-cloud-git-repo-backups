<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>espy__WeeklyStatusEmail</fullName>
        <description>WeeklyStatusEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>ESPY_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>espy__ESPY_Templates/espy__Weekly_Batch_Job_Status</template>
    </alerts>
</Workflow>
