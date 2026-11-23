<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Auto_Populate_EPM_Product_Name</fullName>
        <field>Core_Supported_Product_Name__c</field>
        <formula>Core_Product__r.Name</formula>
        <name>Core_Auto_Populate_EPM_Product_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Ensure_EPMID_Is_Unique_Per_Org</fullName>
        <description>Concatenation of Support Org Number (Org-001) and Product MD</description>
        <field>Core_Unique_Supported_Product__c</field>
        <formula>Core_Product_Organization__c &amp; Core_Product__r.Core_Unique_ID__c</formula>
        <name>Core_Ensure_EPMID_Is_Unique_Per_Org</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Insert_Codename</fullName>
        <description>Obtain codename value from Code_Name_Hidden_Evaluate_NA__c and insert it into text codename field (Core_IPS_Code_Name__c) to enable SOSL execution for Product search.</description>
        <field>Core_IPS_Code_Name__c</field>
        <formula>Code_Name_Hidden_Evaluate_NA__c</formula>
        <name>Core_IPS_Insert_Codename</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Insert_EPMID</fullName>
        <description>When a new Supported Product is created, copy the EPM ID from Product MD  to the Supported Product EPM ID field</description>
        <field>Core_Product_EPM_ID__c</field>
        <formula>Core_Product__r.Core_Unique_ID__c</formula>
        <name>Core_IPS_Insert_EPMID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_IPS_Uncheck_EOIS</fullName>
        <field>Core_EOIS__c</field>
        <literalValue>0</literalValue>
        <name>Core IPS Uncheck EOIS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPS_Updates_Access_Flag_to_True</fullName>
        <field>Core_Flag_Status__c</field>
        <literalValue>Auto Approve</literalValue>
        <name>IPS Updates Access Flag to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core IPS Uncheck EOIS</fullName>
        <actions>
            <name>Core_IPS_Uncheck_EOIS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Access Flag is changed from EOIS, uncheck EOIS checkbox</description>
        <formula>ISPICKVAL(PRIORVALUE(Core_Flag_Status__c),&apos;EOIS&apos;) &amp;&amp; 
ISCHANGED(Core_Flag_Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_Auto_Populate_EPM_Data</fullName>
        <actions>
            <name>Core_Auto_Populate_EPM_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Ensure_EPMID_Is_Unique_Per_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_IPS_Insert_EPMID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Auto populate EPM Product Name from the Product Master into the Supported Product Name field. Entry criteria is on Create only, as the Update scenario is handled thru trigger, to cascade changes down to Assets, MAP, PAR &amp; Case.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_Ensure_EPMID_Is_Unique_Per_Org</fullName>
        <actions>
            <name>Core_Ensure_EPMID_Is_Unique_Per_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Inserts (Support Org ID &amp;&amp; EPM ID) into a text field which is then checked for uniqueness. Cant use Formula, as uniqueness cannot be enforced on Formulae. Evaluated on Create only, as SP re-lookup to Product MD is prevented from UI.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Insert_Code_Name</fullName>
        <actions>
            <name>Core_IPS_Insert_Codename</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Inserts codename into the Code Name text field (Core_IPS_Code_Name__c) to allow Product search on it.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_IPS_Update Access Flag to Auto Approve for Public Product</fullName>
        <actions>
            <name>IPS_Updates_Access_Flag_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Core_IPS_Supported_Product__c.Core_IPS_Public_Product__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Access Flag field to Auto Approve whenever public product checkbox is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
