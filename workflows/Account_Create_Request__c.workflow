<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Request_Approved</fullName>
        <description>Account Request Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>ucd_AccountRequestApproverGroup</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>ucdcustomerdataoperations@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Account_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Account_Request_Creation</fullName>
        <description>Account Request Creation</description>
        <protected>false</protected>
        <recipients>
            <recipient>ucd_AccountRequestApproverGroup</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Request_Creation</template>
    </alerts>
</Workflow>
