<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_Account_Creation_to_Data_Ops</fullName>
        <description>Core_Account_Creation_to_Data_Ops</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/New_Account_Creation_Data_Ops</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_Export_Compliance_Block_Alert</fullName>
        <description>Core_Account_Export_Compliance_Block_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Compliance_Block_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_MAG_Governance</fullName>
        <description>Core_Account_MAG_Governance</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/MAG_Account</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_New_Private_Account_Created</fullName>
        <description>Core_Account_New_Private_Account_Created</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/New_Private_Account</template>
    </alerts>
    <alerts>
        <fullName>Core_Account_Owner_Deactivation_Notification</fullName>
        <description>Core_Account_Owner_Deactivation_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Account_Owner_Deactivation_Notification</template>
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
        <fullName>Core_Update_OwnerChngdFrmUncoverCheckBox</fullName>
        <description>Updates the field &apos;Core_Owner_Changed_From_Uncovered__c&apos;</description>
        <field>Core_Owner_Changed_From_Uncovered__c</field>
        <literalValue>1</literalValue>
        <name>Core_Update_OwnerChngdFrmUncoverCheckBox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
    <outboundMessages>
        <fullName>Core_Intmsg_Account_Updated_CIM_ID</fullName>
        <apiVersion>34.0</apiVersion>
        <description>Send updated CIM ID to integration server</description>
        <endpointUrl>https://8cc1c347-4525-4627-b9d8-0adb19ccbcbe:XHW8Q~ICPFmAqGH__wfPZ~MbLXSUdLthpuyMUduG@apis-sandbox.intel.com/m2r/sales-cloud/v1/accounts</endpointUrl>
        <fields>Core_CIM_ID_Old__c</fields>
        <fields>Core_CIM_ID__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>10557526@intel.com.crm</integrationUser>
        <name>Send Updated CIM ID to Integration</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Core_Account_AddressConcatenate</fullName>
        <actions>
            <name>Core_Account_Address_Concatenate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow rule to concatenate the address details.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Deactive_Email</fullName>
        <actions>
            <name>Core_Account_Owner_Deactivation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If the field Deactivated is checked, an email notifies the Account Owner</description>
        <formula>AND(
Core_Deactivated__c = True,
$RecordType.DeveloperName &lt;&gt; &quot;Core_Partner_Account_Group&quot;

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Export_Compliance_Unblock</fullName>
        <actions>
            <name>Core_Account_Record_Type_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <failedMigrationToolVersion>240.7.2</failedMigrationToolVersion>
        <formula>AND( PRIORVALUE(Core_Export_Compliance_Block__c )= TRUE, ISCHANGED( Core_Export_Compliance_Block__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Inactive_Record_Type</fullName>
        <actions>
            <name>Core_Account_Record_Type_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
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
        <active>true</active>
        <description>Whenever Deactivated flag is changed into false,Then udpate record type as Intel Account.</description>
        <formula>AND(
ISCHANGED(Core_Deactivated__c),
 PRIORVALUE(Core_Deactivated__c) = TRUE,
 Core_Deactivated__c = FALSE,
 $RecordType.DeveloperName &lt;&gt; &quot;Core_Partner_Account_Group&quot;,
 $RecordType.DeveloperName &lt;&gt; &quot;Mastered_Account&quot;,
 $RecordType.DeveloperName &lt;&gt; &quot;Core_Account_Intel_Ultimate&quot;, 
 $RecordType.DeveloperName &lt;&gt; &quot;Core_MDF_Co_Marketing&quot;
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_MAG Governance</fullName>
        <actions>
            <name>Core_Account_MAG_Governance</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If MAG is checked yes follow this process</description>
        <formula>AND ( Core_Military_Aerospace_and_Government__c =true, $User.FirstName = Owner.FirstName,   $User.LastName = Owner.LastName, $User.CommunityNickname = Owner.CommunityNickname,  $Profile.Name !=&apos;Integration&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
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
        <active>true</active>
        <criteriaItems>
            <field>Account.Core_Private__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_New_Intmsg_Rule</fullName>
        <actions>
            <name>Core_Intmsg_Account_New</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>On create, edit, send outbound message to IPass</description>
        <formula>AND(OR(RecordType.DeveloperName = &apos;Mastered_Account&apos;, RecordType.DeveloperName = &apos;Inactive_Account&apos;, RecordType.DeveloperName = &apos;Core_Account_Intel_Ultimate&apos;), ( ISNEW() || ISCHANGED(BillingStreet) || ISCHANGED(BillingCity) || ISCHANGED(BillingPostalCode) || ISCHANGED(BillingCountry) || ISCHANGED(BillingCountryCode) || ISCHANGED(BillingState) || ISCHANGED(BillingStateCode) || ISCHANGED(Core_Account_Country__c) || ISCHANGED(Core_Account_State_Province__c) || ISCHANGED(Core_Deactivated__c) || ISCHANGED(Phone) || ISCHANGED(Fax) || ISCHANGED(Name) || ISCHANGED(RecordTypeId) || (ISCHANGED(OwnerId) &amp;&amp; ISCHANGED(Core_Covered_Account__c))) &amp;&amp; (( NOT(ISNEW()) &amp;&amp; ($Profile.Name &lt;&gt; &quot;Integration&quot; || ( BEGINS( $User.Username , &apos;ucd_reltio_connector_user&apos;) ))) || ISNEW()))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Send_PSG_Account_To_Siebel</fullName>
        <actions>
            <name>Core_Intmsg_Account_PSG</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Sends the PSG Account info to PSG Siebel System (using outbound message to IPass).</description>
        <formula>AND((RecordType.DeveloperName &lt;&gt; &apos;Core_MDF_Co_Marketing&apos; || RecordType.DeveloperName &lt;&gt;&apos;Core_Partner_Account_Group&apos;), OR ( AND(ISNEW(), Core_PSG_Account__c), AND(Core_PSG_Account__c, (ISCHANGED(BillingStreet) || ISCHANGED(BillingCity) || ISCHANGED(BillingPostalCode) || ISCHANGED(BillingCountryCode)|| ISCHANGED(BillingStateCode) || ISCHANGED(Core_CIM_ID__c) || ISCHANGED(Core_Export_Compliance_Block__c) || ISCHANGED(Name) || ISCHANGED(Core_PSG_Account__c) || ISCHANGED(Core_Account_Tier__c) || ISCHANGED(Core_Partner_Alliance_Program__c) || ISCHANGED(Core_Military_Aerospace_and_Government__c) ) ) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Send_Updated_CIM_ID</fullName>
        <actions>
            <name>Core_Intmsg_Account_Updated_CIM_ID</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>If CIM ID is updated, sends the old &amp; new CIM ID to iPaaS (mainly for My Samples).</description>
        <formula>AND(OR(RecordType.DeveloperName = &apos;Mastered_Account&apos;, RecordType.DeveloperName = &apos;Inactive_Account&apos;, RecordType.DeveloperName = &apos;Core_Account_Intel_Ultimate&apos;), ISCHANGED(Core_CIM_ID_Old__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Set_PSG_Account_Flag</fullName>
        <actions>
            <name>Core_Account_Set_PSG_Account_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the &apos;PSG Account&apos; value to true if &apos;PSG Sales&apos; value is added to &apos;Sales Group&apos; field.</description>
        <formula>INCLUDES(Core_Sales_Group__c, &quot;PSG Sales&quot;) &amp;&amp;  Core_PSG_Account__c = false</formula>
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
        <fullName>Core_Account_Update_CIM_ID_Old</fullName>
        <actions>
            <name>Core_Account_Update_CIM_ID_Old</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When CIM ID is updated, stores the old CIM ID in the &quot;CIM ID Old&quot; field, so old &amp; new values can be sent out via outbound messages if needed</description>
        <formula>ISCHANGED(Core_CIM_ID__c)  &amp;&amp; (PRIORVALUE(Core_CIM_ID__c) != &apos;&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Account_Update_Owner_Uncovered_Account</fullName>
        <actions>
            <name>Core_Account_Update_Owner_Uncovered_Acct</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
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
        <failedMigrationToolVersion>240.8.2</failedMigrationToolVersion>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Direct_Account_Field_Update</fullName>
        <active>false</active>
        <formula>AND(
ISNEW(),
ParentId &lt;&gt; null
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_PopulatePricingParent</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Intel Account</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_OwnerChangedFromUncovered</fullName>
        <actions>
            <name>Core_Update_OwnerChngdFrmUncoverCheckBox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates when the owner of account record changes from Uncovered to any user</description>
        <formula>AND(
ISCHANGED(OwnerId),
NOT(ISNEW()),
PRIORVALUE(OwnerId) = $Label.Core_Uncovered_Account_ID,
OwnerId &lt;&gt; $Label.Core_Uncovered_Account_ID,
OR(TEXT(Industry) = Null,TEXT(Industry)=&apos;To Be Defined&apos;),
$Profile.Name &lt;&gt; &quot;Integration&quot;
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_Sales_Group</fullName>
        <actions>
            <name>Update_Sales_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
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
    <rules>
        <fullName>x Core_Account_Creation_Data_Ops_Notification</fullName>
        <actions>
            <name>Core_Account_Creation_to_Data_Ops</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.LastModifiedById</field>
            <operation>notContain</operation>
            <value>integration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>x Core_Account_Export_Compliance_Block</fullName>
        <actions>
            <name>Core_Account_Export_Compliance_Block_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Core_Export_Compliance_Block__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Export Compliance Block field is checked, send email to Account Owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>x Updates Partner Program CSM</fullName>
        <active>false</active>
        <description>Updates Partner Program CSM</description>
        <formula>True</formula>
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
