<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Test_email</fullName>
        <description>Test email</description>
        <protected>false</protected>
        <recipients>
            <recipient>11881735@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test_m/test_approval_url</template>
    </alerts>
    <rules>
        <fullName>Test Allocation Update</fullName>
        <actions>
            <name>Test_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>TotalApprovedFcs  &gt;  Amount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
