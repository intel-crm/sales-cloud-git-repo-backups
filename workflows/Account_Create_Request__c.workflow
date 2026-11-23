<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Create_Request_Approved</fullName>
        <description>Account Create Request Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>12036590@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12113363@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ucdcustomerdataoperations@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Account_Create_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Account_Create_Request_Rejected</fullName>
        <description>Account Create Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>12036590@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>12113363@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>ucdcustomerdataoperations@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Account_Create_Request_Rejected</template>
    </alerts>
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
    <fieldUpdates>
        <fullName>Status_To_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_To_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Approve</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status to Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
