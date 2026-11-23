<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CIM_Outbound_Notification_Email</fullName>
        <description>CIM Outbound Notification Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>11636835@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testt/CIM_Outbound_Message</template>
    </alerts>
    <alerts>
        <fullName>CIM_Outbound_Notification_Email1</fullName>
        <description>CIM Outbound Notification Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>11636835@intel.com.crm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testt/CIM_Outbound_Message</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_Creation_to_Data_Ops</fullName>
        <ccEmails>intel.covered.accounts@intel.com</ccEmails>
        <description>Core_Account_Creation_to_Data_Ops</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Testt/New_Account_Creation_Data_Ops</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_Export_Compliance_Block_Alert</fullName>
        <description>Core_Account_Export_Compliance_Block_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>PRV_test/Compliance_Block_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_MAG_Governance</fullName>
        <ccEmails>export.customer@intel.com</ccEmails>
        <description>Core_Account_MAG_Governance</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>PRV_test/MAG_Account</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_New_Private_Account_Created</fullName>
        <description>Core_Account_New_Private_Account_Created</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Testt/New_Private_Account</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_Owner_Deactivation_Notification</fullName>
        <description>Core_Account_Owner_Deactivation_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Testt/Account_Owner_Deactivation_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_Account_Address_Concatenate</fullName>
        <description>To concatenate primary address into a field to check for duplicates</description>
        <field>Core_Address_Details__c</field>
        <formula>BillingStreet  +  BillingState  +  BillingCity  +  BillingCountry  +  BillingPostalCode</formula>
        <name>Core_Account_Address_Concatenate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Assign_One_Partner_Id</fullName>
        <description>Assign the 18 digit Account Id as One Partner Id.</description>
        <field>Core_IPA_One_Partner_Id__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>Core_Account_Assign_One_Partner_Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_First_Revenue_Date</fullName>
        <description>Update First Revenue Date only when the approved revenue has changed, and the first revenue date is null to begin with.</description>
        <field>Core_First_Revenue_Date__c</field>
        <formula>NOW()</formula>
        <name>Core_Account_First_Revenue_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Intel_RecordType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Mastered_Account</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_Account_Intel_RecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Record_Type_Active</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Mastered_Account</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_Account_Record_Type_Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Record_Type_Inactive</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Inactive_Account</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_Account_Record_Type_Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Record_Type_Mastered</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Mastered_Account</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Core_Account_Record_Type_Mastered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Set_PSG_Account_Flag</fullName>
        <description>Sets the value of &apos;PSG Sales&apos; to true.</description>
        <field>Core_PSG_Account__c</field>
        <literalValue>1</literalValue>
        <name>Core_Account_Set_PSG_Account_Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Update_CIM_ID_Old</fullName>
        <field>Core_CIM_ID_Old__c</field>
        <formula>PRIORVALUE(Core_CIM_ID__c)</formula>
        <name>Core_Account_Update_CIM_ID_Old</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Update_Membership_Chang_Ind</fullName>
        <description>Set the Membership Changed Indicator to TRUE</description>
        <field>Core_PMP_Membership_Change_Ind__c</field>
        <literalValue>1</literalValue>
        <name>Core_Account_Update_Membership_Chang_Ind</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Account_Update_Owner_Uncovered_Acct</fullName>
        <description>Updates account owner to &quot;Uncovered Account&quot;</description>
        <field>OwnerId</field>
        <lookupValue>uncovered.account@intel.com.crm</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Core_Account_Update_Owner_Uncovered_Acct</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_PSG_Tier_Update</fullName>
        <field>Core_Account_PSG_Tier__c</field>
        <literalValue>PSG-Tier 4</literalValue>
        <name>Default PSG Tier Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Group</fullName>
        <field>Core_Opportunity_Sales_Group_Txt__c</field>
        <formula>TEXT(Core_Sales_Groups__c)</formula>
        <name>Update Sales Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Core_Intmsg_Account_New</fullName>
        <apiVersion>32.0</apiVersion>
        <description>Send new account to integration server</description>
        <endpointUrl>https://8cc1c347-4525-4627-b9d8-0adb19ccbcbe:XHW8Q~ICPFmAqGH__wfPZ~MbLXSUdLthpuyMUduG@apis-sandbox.intel.com/m2r/sales-cloud/v1/accounts</endpointUrl>
        <fields>BillingCity</fields>
        <fields>BillingCountry</fields>
        <fields>BillingCountryCode</fields>
        <fields>BillingPostalCode</fields>
        <fields>BillingState</fields>
        <fields>BillingStateCode</fields>
        <fields>BillingStreet</fields>
        <fields>Core_Account_Legal_Name__c</fields>
        <fields>Core_CIM_ID__c</fields>
        <fields>Core_Deactivated__c</fields>
        <fields>Core_Deactivation_Reason__c</fields>
        <fields>Core_Sales_Group__c</fields>
        <fields>Core_Sales_Segment__c</fields>
        <fields>Fax</fields>
        <fields>Id</fields>
        <fields>Name</fields>
        <fields>Phone</fields>
        <fields>RecordTypeId</fields>
        <fields>Type</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>integration.user@intel.com.crm</integrationUser>
        <name>Send New Account to Integration</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Core_Intmsg_Account_PSG</fullName>
        <apiVersion>38.0</apiVersion>
        <description>Send PSG account to Siebel System (using integration server)</description>
        <endpointUrl>https://dummy_user3:j5s$S$Xo!s9w@eip-crm-dummy.cloudhub.io/smit/api/eip-crm-sls-siebel/account</endpointUrl>
        <fields>BillingCity</fields>
        <fields>BillingCountryCode</fields>
        <fields>BillingPostalCode</fields>
        <fields>BillingStateCode</fields>
        <fields>BillingStreet</fields>
        <fields>Core_Account_Tier__c</fields>
        <fields>Core_CIM_ID__c</fields>
        <fields>Core_Export_Compliance_Block__c</fields>
        <fields>Core_Military_Aerospace_and_Government__c</fields>
        <fields>Core_Partner_Alliance_Program__c</fields>
        <fields>Id</fields>
        <fields>Name</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>integration.user@intel.com.crm</integrationUser>
        <name>Send PSG Account to Integration</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Core_Account_AddressConcatenate</fullName>
        <actions>
            <name>Core_Account_Address_Concatenate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow rule to concatenate the address details.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Assign_One_Partner_Id</fullName>
        <actions>
            <name>Core_Account_Assign_One_Partner_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Account Group</value>
        </criteriaItems>
        <description>Assigns the One Partner Id to the Partner Account when it is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Deactive_Email</fullName>
        <actions>
            <name>Core_Account_Owner_Deactivation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If the field Deactivated is checked, an email notifies the Account Owner</description>
        <formula>AND( Core_Deactivated__c = True, $RecordType.DeveloperName &lt;&gt; &quot;Core_Partner_Account_Group&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Export_Compliance_Unblock</fullName>
        <actions>
            <name>Core_Account_Record_Type_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( PRIORVALUE(Core_Export_Compliance_Block__c )= TRUE, ISCHANGED( Core_Export_Compliance_Block__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Inactive_Record_Type</fullName>
        <actions>
            <name>Core_Account_Record_Type_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.Core_Deactivated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Core_Export_Compliance_Block__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Partner Account Group</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Intel_RecordType</fullName>
        <actions>
            <name>Core_Account_Intel_RecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Whenever Deactivated flag is changed into false,Then udpate record type as Intel Account.</description>
        <formula>AND( ISCHANGED(Core_Deactivated__c),  PRIORVALUE(Core_Deactivated__c) = TRUE,  Core_Deactivated__c = FALSE,  $RecordType.DeveloperName &lt;&gt; &quot;Core_Partner_Account_Group&quot;,  $RecordType.DeveloperName &lt;&gt; &quot;Mastered_Account&quot;,  $RecordType.DeveloperName &lt;&gt; &quot;Core_Account_Intel_Ultimate&quot;,   $RecordType.DeveloperName &lt;&gt; &quot;Core_MDF_Co_Marketing&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Mastered_Record_Type</fullName>
        <actions>
            <name>Core_Account_Record_Type_Mastered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND ( $Profile.Name &lt;&gt; &quot;Integration&quot;, NOT(ISBLANK( Core_CIM_ID__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_New Private Account</fullName>
        <actions>
            <name>Core_Account_New_Private_Account_Created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Core_Private__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Send_PSG_Account_To_Siebel</fullName>
        <actions>
            <name>Core_Intmsg_Account_PSG</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Sends the PSG Account info to PSG Siebel System (using outbound message to IPass).</description>
        <formula>AND((RecordType.DeveloperName &lt;&gt; &apos;Core_MDF_Co_Marketing&apos; || RecordType.DeveloperName &lt;&gt;&apos;Core_Partner_Account_Group&apos;), OR ( AND(ISNEW(), Core_PSG_Account__c), AND(Core_PSG_Account__c, (ISCHANGED(BillingStreet) || ISCHANGED(BillingCity) || ISCHANGED(BillingPostalCode) || ISCHANGED(BillingCountryCode)|| ISCHANGED(BillingStateCode) || ISCHANGED(Core_CIM_ID__c) || ISCHANGED(Core_Export_Compliance_Block__c) || ISCHANGED(Name) || ISCHANGED(Core_PSG_Account__c) || ISCHANGED(Core_Account_Tier__c) || ISCHANGED(Core_Partner_Alliance_Program__c) || ISCHANGED(Core_Military_Aerospace_and_Government__c) ) ) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Stamp_First_Revenue_Date_Only_Once</fullName>
        <actions>
            <name>Core_Account_First_Revenue_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update First Revenue Date only when the approved revenue has changed, and the first revenue date is null to begin with.</description>
        <formula>AND(ISCHANGED(Core_Total_Approved_Revenue_Amount__c), ISNULL(Core_First_Revenue_Date__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Update_Membership_Change_Ind</fullName>
        <actions>
            <name>Core_Account_Update_Membership_Chang_Ind</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Whenever Core_Account_Type__c is changed, update Core_PMP_Membership_Change_Ind__c to True</description>
        <formula>AND( ISCHANGED(Core_Account_Type__c), OR($RecordType.DeveloperName = &quot;Core_Partner_Account_Group&quot;, AND( $RecordType.DeveloperName = &quot;Mastered_Account&quot;, Core_IPA_One_Partner_Id__c = &apos;&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Update_Owner_Uncovered_Account</fullName>
        <actions>
            <name>Core_Account_Update_Owner_Uncovered_Acct</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>equals</operation>
            <value>Integration User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>equals</operation>
            <value>Integration_OBM User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>equals</operation>
            <value>ERPM.OBM Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>equals</operation>
            <value>CIM.OBM Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>equals</operation>
            <value>Salesforce System User</value>
        </criteriaItems>
        <description>When an account is created or updated, if the owner is &quot;Integration User/Integration OBM user&quot; (e.g. if it&apos;s created from iPaaS), change it to &quot;Uncovered Account&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_Sales_Group</fullName>
        <actions>
            <name>Update_Sales_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  TEXT(Core_Sales_Groups__c) &lt;&gt; &apos;Undefined&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Default PSG Tier</fullName>
        <actions>
            <name>Default_PSG_Tier_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (   ISBLANK(TEXT(Core_Account_PSG_Tier__c)),Core_PSG_Account__c = true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Core_Account_Change_Owner</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Change Account Owner</subject>
    </tasks>
</Workflow>
