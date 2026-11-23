<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Core_DDR_Send_Product_Cancel_Notification</fullName>
        <description>Send Product Cancel Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Core_Technical_Owner_Email_Txt__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salescrm_sb@intel.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DDR_Email_Templates/Core_DDR_Notify_Tech_Owner_On_Product_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Core_Approved_BU_Product_Segment</fullName>
        <description>Stamp the current BU Product Segment</description>
        <field>Core_Approved_BU_Product_Segment__c</field>
        <formula>Core_BU_Product_Segment__c</formula>
        <name>Approved BU Product Segment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Approved_BU_Product_Segment_Clear</fullName>
        <description>Clear Field</description>
        <field>Core_Approved_BU_Product_Segment__c</field>
        <name>Approved BU Product Segment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Approved_BU_Short_Name</fullName>
        <description>Stamp the current BU Short Name</description>
        <field>Core_Approved_BU_Short_Name__c</field>
        <formula>Core_BU_Short_Name__c</formula>
        <name>Approved BU Short Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Approved_BU_Short_Name_Clear</fullName>
        <description>Clear the Field</description>
        <field>Core_Approved_BU_Short_Name__c</field>
        <name>Approved BU Short Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_BU_Product_Segment_Update</fullName>
        <field>Core_BU_Product_Segment_New__c</field>
        <formula>Core_BU_ProductSegment__c</formula>
        <name>BU Product Segment Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_BU_Short_Name_Update</fullName>
        <field>Core_BU_Shortname_New__c</field>
        <formula>Core_BU_ShortName__c</formula>
        <name>BU Short Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_DDR_Get_Technical_Owner_Email</fullName>
        <description>Gets the Technical Owner Email from Opportunity. This will be used to send the notification.</description>
        <field>Core_Technical_Owner_Email_Txt__c</field>
        <formula>Opportunity.Core_Technical_Owner__r.Email</formula>
        <name>Get Technical Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Approved_User_Id</fullName>
        <description>Approved User Id is set when someone approves opportunity record</description>
        <field>Core_Approved_User_Id__c</field>
        <formula>LastModifiedBy.Id</formula>
        <name>Core_OppProd_Approved_User_Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Check_Lost_to_Open_Flag</fullName>
        <field>Core_Lost_to_Open_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Core_OppProd_Check_Lost_to_Open_Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Claim_Date_Population</fullName>
        <description>Populates the Claim Date field with the current date</description>
        <field>Core_Claim_Date__c</field>
        <formula>Now()</formula>
        <name>Core_OppProd_Claim_Date_Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_By</fullName>
        <description>Clears the value in the Approved By field</description>
        <field>Core_Approved_By__c</field>
        <name>Core_OppProd_Clear_Apprvd_By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Commissionable</fullName>
        <description>Reset the &apos;Approved Commissionable?&apos; field.</description>
        <field>Core_Approved_Commissionable__c</field>
        <name>Core_OppProd_Clear_Apprvd_Commissionable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Decision_Date</fullName>
        <description>Clears the value in the Approved Decision Date field</description>
        <field>Core_Approved_Decision_Date__c</field>
        <name>Core_OppProd_Clear_Apprvd_Decision_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_List_Price</fullName>
        <description>Clears the value in the Approved List Price field</description>
        <field>Core_Approved_List_Price__c</field>
        <name>Core_OppProd_Clear_Apprvd_List_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Opp_Owner</fullName>
        <description>Clears the value in the Approved Opportunity Owner field</description>
        <field>Core_Approved_Opportunity_Owner__c</field>
        <name>Core_OppProd_Clear_Apprvd_Opp_Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Quantity</fullName>
        <description>Clears the value in the Approved Quantity field</description>
        <field>Core_Approved_Quantity__c</field>
        <name>Core_OppProd_Clear_Apprvd_Quantity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Sales_Price</fullName>
        <description>Clears the value in the Approved Sales Price</description>
        <field>Core_Approved_Sales_Price__c</field>
        <name>Core_OppProd_Clear_Apprvd_Sales_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Tech_Owner</fullName>
        <description>Clears the value in the Approved Technical Owner field</description>
        <field>Core_Approved_Technical_Owner__c</field>
        <name>Core_OppProd_Clear_Apprvd_Tech_Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Apprvd_Total_Price</fullName>
        <description>Clears the value in the Approved Total Price field</description>
        <field>Core_Approved_Total_Price__c</field>
        <name>Core_OppProd_Clear_Apprvd_Total_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Claim_Date</fullName>
        <description>Clears the value in the Claim Date field</description>
        <field>Core_Claim_Date__c</field>
        <name>Core_OppProd_Clear_Claim_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Clear_Mgr_Apprvd_Date</fullName>
        <description>Clears the value in the Manager Approved Date field</description>
        <field>Core_Approved_Date__c</field>
        <name>Core_OppProd_Clear_Mgr_Apprvd_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Lost_Price_as_Sales_Price</fullName>
        <description>Sets Lost Sales Price to Sales Price</description>
        <field>Core_Lost_Sales_Price__c</field>
        <formula>UnitPrice</formula>
        <name>Core_OppProd_Lost_Price_as_Sales_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Lost_Sales_Price_to_0</fullName>
        <description>Sets the Lost Sales Price to null</description>
        <field>Core_Lost_Sales_Price__c</field>
        <name>Core_OppProd_Lost_Sales_Price_to_0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Production_Claim_Date_Clear</fullName>
        <description>Clears the value in the Production Claim Date field</description>
        <field>Core_Production_Claim_Date__c</field>
        <name>Core_OppProd_Production_Claim_Date_Clear</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Production_Claim_Date_Popul</fullName>
        <description>Populates the Production Claim Date field with the current date and time.</description>
        <field>Core_Production_Claim_Date__c</field>
        <formula>Now()</formula>
        <name>Core_OppProd_Production_Claim_Date_Popul</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Sales_Price_as_Lost_Price</fullName>
        <description>Sets Sales Price to Lost Sales Price</description>
        <field>UnitPrice</field>
        <formula>Core_Lost_Sales_Price__c</formula>
        <name>Core_OppProd_Sales_Price_as_Lost_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Sales_Price_to_0</fullName>
        <description>Updates the Sales Price to $0</description>
        <field>UnitPrice</field>
        <formula>0</formula>
        <name>Core_OppProd_Sales_Price_to_0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Set_Status_to_Pending</fullName>
        <description>Sets the Opportunity Product status to Pending</description>
        <field>Core_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Core_OppProd_Set_Status_to_Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Approved_By</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_By__c</field>
        <formula>Opportunity.Core_Approved_By__c</formula>
        <name>Core_OppProd_Snapshot_Approved_By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Approved_Date</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_Date__c</field>
        <formula>Opportunity.Core_Approved_Date__c</formula>
        <name>Core_OppProd_Snapshot_Approved_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Close_Date</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_Decision_Date__c</field>
        <formula>Opportunity.CloseDate</formula>
        <name>Core_OppProd_Snapshot_Close_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Commissionable</fullName>
        <description>Copies the &apos;Commissionable?&apos; value from Opportunity.</description>
        <field>Core_Approved_Commissionable__c</field>
        <formula>TEXT(Opportunity.Core_Commissionable__c)</formula>
        <name>Core_OppProd_Snapshot_Commissionable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_List_Price</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_List_Price__c</field>
        <formula>ListPrice</formula>
        <name>Core_OppProd_Snapshot_List_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Opp_Owner</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_Opportunity_Owner__c</field>
        <formula>TRIM( Opportunity.Owner.FirstName + &quot; &quot; + Opportunity.Owner.LastName )</formula>
        <name>Core_OppProd_Snapshot_Opp_Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Quantity</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_Quantity__c</field>
        <formula>Quantity</formula>
        <name>Core_OppProd_Snapshot_Quantity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Sales_Price</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_Sales_Price__c</field>
        <formula>UnitPrice</formula>
        <name>Core_OppProd_Snapshot_Sales_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Technical_Owner</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field</description>
        <field>Core_Approved_Technical_Owner__c</field>
        <formula>TRIM( Opportunity.Core_Technical_Owner__r.FirstName + &quot; &quot; + Opportunity.Core_Technical_Owner__r.LastName )</formula>
        <name>Core_OppProd_Snapshot_Technical_Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Snapshot_Total_Price</fullName>
        <description>Saves the regular field in the &quot;Approved&quot; snapshot field. Note: the formula calculates it as UnitPrice * Quantity since just saving TotalPrice doesn&apos;t work.</description>
        <field>Core_Approved_Total_Price__c</field>
        <formula>UnitPrice * Quantity</formula>
        <name>Core_OppProd_Snapshot_Total_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_Uncheck_Lost_to_Open_Flag</fullName>
        <description>Unchecks the Lost to Open Flag</description>
        <field>Core_Lost_to_Open_Flag__c</field>
        <literalValue>0</literalValue>
        <name>Core_OppProd_Uncheck_Lost_to_Open_Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_OppProd_WriteInProductFlag</fullName>
        <description>Update field WriteInProduct checkbox to true</description>
        <field>Core_Write_In_Product_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Core_OppProd_WriteInProductFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Set_BU_Product_Segment</fullName>
        <field>Core_BU_Product_Segment__c</field>
        <formula>Core_BU_ProductSegment__c</formula>
        <name>Set BU Product Segment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Set_BU_Shortname</fullName>
        <field>Core_BU_Short_Name__c</field>
        <formula>Core_BU_ShortName__c</formula>
        <name>Set BU Shortname</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_SupportGranted_Not_EntryDt_Populate</fullName>
        <description>Populates Entry Date-Time when Core_At_Risk_Status is changed to &quot;Support Granted By HQ&quot;</description>
        <field>Core_Support_Granted_Not_Entrance_Date__c</field>
        <formula>IF( 
 ISPICKVAL( Core_At_Risk_Status__c , &quot;Support Granted By HQ&quot;), NOW(),
 Core_Support_Granted_Not_Entrance_Date__c )</formula>
        <name>Core_SupportGranted_Not_EntryDt_Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_SupportProvide_Not_EntryDt_Populate</fullName>
        <field>Core_Support_Provided_Not_Entrance_Date__c</field>
        <formula>IF( 
 ISPICKVAL( Core_At_Risk_Status__c , &quot;Support Provided&quot;), 
 NOW(), Core_Support_Provided_Not_Entrance_Date__c )</formula>
        <name>Core_SupportProvide_Not_EntryDt_Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Core BU ShortName Update</fullName>
        <actions>
            <name>Core_Set_BU_Product_Segment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Set_BU_Shortname</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 AND 2) OR (3 AND 4) OR 5 )</booleanFilter>
        <criteriaItems>
            <field>OpportunityLineItem.Core_BU_ShortName__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Core_BU_ShortName__c</field>
            <operation>notEqual</operation>
            <value>Unassigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Core_BU_ProductSegment__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Core_BU_ProductSegment__c</field>
            <operation>notEqual</operation>
            <value>Unassigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>contains</operation>
            <value>Write In Product</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_DDR_Send_Email_On_Opportunity_Product_Cancellation</fullName>
        <actions>
            <name>Core_DDR_Send_Product_Cancel_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Core_DDR_Get_Technical_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Core_Channel_Opportunity_Ind__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends Email to Technical Owner when Product is Cancelled on Design/Opportunity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_BU_Values_Upon_Approval</fullName>
        <actions>
            <name>Core_Approved_BU_Product_Segment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Approved_BU_Short_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>contains</operation>
            <value>Win Approved</value>
        </criteriaItems>
        <description>When a product status is set to &quot;Win Approved&quot;, stamp the current BU Short Name and BU Segment on the product.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Claim_Date_Clear</fullName>
        <actions>
            <name>Core_OppProd_Clear_Claim_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>equals</operation>
            <value>On Hold</value>
        </criteriaItems>
        <description>Clears the Claim Date field if the product status changes to Pending or On Hold</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Claim_Date_Clear_on_Creation</fullName>
        <actions>
            <name>Core_OppProd_Clear_Claim_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears the Claim Date if it has a value when the Opportunity Product is created</description>
        <formula>ISNULL( Core_Claim_Date__c ) = False</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Claim_Date_Population</fullName>
        <actions>
            <name>Core_OppProd_Claim_Date_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the Claim Date with the date/time the Status is changed to Win Submitted, Lost, or Cancelled</description>
        <formula>AND(  ISCHANGED(Core_Status__c) = True,  OR( Text(Core_Status__c) = &quot;Win Submitted&quot;, Text(Core_Status__c) = &quot;Lost&quot;, Text(Core_Status__c) = &quot;Cancelled&quot; )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Clear_Approval_Fields</fullName>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Commissionable</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Decision_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_List_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Opp_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Quantity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Tech_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Apprvd_Total_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Clear_Mgr_Apprvd_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears the approval fields in two situations:
1) Products are created in a won status. This will prevent someone from cloning a product in won status
2) Changing a product status from won to another status that isn&apos;t won</description>
        <formula>OR(   AND(     ISNEW(),     OR(       CONTAINS(Text(Core_Status__c), &quot;Win&quot;),       TEXT(Core_Status__c) = &apos;Production Lost&apos;,       TEXT(Core_Status__c) = &apos;Production Cancelled&apos;,       NOT(ISNULL(Core_Approved_Quantity__c))     )   ),   AND(     ISCHANGED(Core_Status__c),     NOT(OR(       CONTAINS(Text(Core_Status__c), &quot;Win&quot;),      	TEXT(Core_Status__c) = &apos;Production Lost&apos;,     	TEXT(Core_Status__c) = &apos;Production Cancelled&apos;     ))   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Clear_BU_Fields</fullName>
        <actions>
            <name>Core_Approved_BU_Product_Segment_Clear</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_Approved_BU_Short_Name_Clear</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears the approval fields in two situations:
1) Products are created in a won status. This will prevent someone from cloning a product in won status
2) Changing a product status from won to another status that is prior to won</description>
        <formula>OR(   AND(     ISNEW(),     OR(       CONTAINS(Text(Core_Status__c), &quot;Win&quot;),       TEXT(Core_Status__c) = &apos;Production Lost&apos;,       TEXT(Core_Status__c) = &apos;Production Cancelled&apos;,       NOT(ISNULL(Core_Approved_Quantity__c))     )   ),   AND(     ISCHANGED(Core_Status__c),     NOT(OR(       CONTAINS(Text(Core_Status__c), &quot;Win&quot;),      	TEXT(Core_Status__c) = &apos;Production Lost&apos;,     	TEXT(Core_Status__c) = &apos;Production Cancelled&apos;     ))   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Lost_to_Open_Step_1a</fullName>
        <actions>
            <name>Core_OppProd_Sales_Price_as_Lost_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Sales Price to Lost Sales Price if:
- an Opportunity is moved from Lost, Cancelled, or Deleted Status to a status that isn&apos;t Lost/Cancelled/Deleted
- a user didn&apos;t manually type in a value in the Sales price</description>
        <formula>AND(  UnitPrice = 0,  OR( ISPICKVAL(PRIORVALUE (Core_Status__c), &quot;Lost&quot;) = True,  ISPICKVAL(PRIORVALUE (Core_Status__c), &quot;Cancelled&quot;) = True,  ISPICKVAL(PRIORVALUE (Core_Status__c), &quot;Deleted&quot;) = True ),  ISPICKVAL(Core_Status__c, &quot;Lost&quot;) = False, ISPICKVAL(Core_Status__c, &quot;Cancelled&quot;) = False, ISPICKVAL(Core_Status__c, &quot;Deleted&quot;) = False )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Lost_to_Open_Step_1b</fullName>
        <actions>
            <name>Core_OppProd_Check_Lost_to_Open_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks the Lost to Open flag</description>
        <formula>AND(  OR( ISPICKVAL(PRIORVALUE (Core_Status__c), &quot;Lost&quot;) = True,  ISPICKVAL(PRIORVALUE (Core_Status__c), &quot;Cancelled&quot;) = True,  ISPICKVAL(PRIORVALUE (Core_Status__c), &quot;Deleted&quot;) = True ),  ISPICKVAL(Core_Status__c, &quot;Lost&quot;) = False, ISPICKVAL(Core_Status__c, &quot;Cancelled&quot;) = False, ISPICKVAL(Core_Status__c, &quot;Deleted&quot;) = False )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Lost_to_Open_Step_2</fullName>
        <actions>
            <name>Core_OppProd_Lost_Sales_Price_to_0</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Uncheck_Lost_to_Open_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Lost_to_Open_Flag__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the Lost Sales Price to $0 if an Opportunity is moved from a Lost to an Open status</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Open_to_Lost_Step_1</fullName>
        <actions>
            <name>Core_OppProd_Lost_Price_as_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Lost Sales Price to the Sales Price if an Opportunity is set to Lost, Cancelled, or Deleted Status</description>
        <formula>IF(ISNEW() = True, OR( ISPICKVAL(Core_Status__c, &quot;Lost&quot;), ISPICKVAL(Core_Status__c, &quot;Cancelled&quot;), ISPICKVAL(Core_Status__c, &quot;Deleted&quot;) ),  AND( ISPICKVAL(PRIORVALUE (Core_Status__c),  &quot;Lost&quot;) = False,  ISPICKVAL(PRIORVALUE (Core_Status__c),  &quot;Cancelled&quot;) = False,  ISPICKVAL(PRIORVALUE (Core_Status__c),  &quot;Deleted&quot;) = False,  OR( ISPICKVAL(Core_Status__c, &quot;Lost&quot;), ISPICKVAL(Core_Status__c, &quot;Cancelled&quot;), ISPICKVAL(Core_Status__c, &quot;Deleted&quot;) )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Open_to_Lost_Step_2</fullName>
        <actions>
            <name>Core_OppProd_Sales_Price_to_0</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Sales Price to $0 if the Lost Amount field gets updated</description>
        <formula>IF(ISNEW() = True,  Core_Lost_Sales_Price__c &lt;&gt; 0, ISCHANGED(Core_Lost_Sales_Price__c) = True )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Production_Claim_Date_Clear</fullName>
        <actions>
            <name>Core_OppProd_Production_Claim_Date_Clear</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the claim date when changing status from Production Win, Production Lost, or Production Cancelled to another.</description>
        <formula>OR(AND(ISNEW(), NOT(ISNULL(Core_Production_Claim_Date__c))), AND(ISCHANGED(Core_Status__c),   OR(     ISPICKVAL(PRIORVALUE(Core_Status__c), &apos;Production Win&apos;), ISPICKVAL(PRIORVALUE(Core_Status__c), &apos;Production Lost&apos;), ISPICKVAL(PRIORVALUE(Core_Status__c), &apos;Production Cancelled&apos;)   ),   NOT(OR(     ISPICKVAL(Core_Status__c, &apos;Production Win&apos;), ISPICKVAL(Core_Status__c, &apos;Production Lost&apos;), ISPICKVAL(Core_Status__c, &apos;Production Cancelled&apos;)   )) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Production_Claim_Date_Population</fullName>
        <actions>
            <name>Core_OppProd_Production_Claim_Date_Popul</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamp the Production Claim Date when the status is changed to Production Win, Production Lost, or Production Cancelled.</description>
        <formula>AND( 	ISCHANGED(Core_Status__c),   OR(     ISPICKVAL(Core_Status__c, &apos;Production Win&apos;), ISPICKVAL(Core_Status__c, &apos;Production Lost&apos;), ISPICKVAL(Core_Status__c, &apos;Production Cancelled&apos;)   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Save_Key_Values_Upon_Approval</fullName>
        <actions>
            <name>Core_OppProd_Snapshot_Approved_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Commissionable</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_List_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Opp_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Quantity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Technical_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_OppProd_Snapshot_Total_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>contains</operation>
            <value>Win Approved</value>
        </criteriaItems>
        <description>Saves key values on the Opportunity Product at the time it was approved (into custom fields)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Status_Pending</fullName>
        <actions>
            <name>Core_OppProd_Set_Status_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>notEqual</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Sets the Opportunity Product Status to pending when an Opportunity Product is created with a status of anything besides pending. This prevents someone from cloning products in won/lost/cancelled/etc. status.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Support_Entrance_Date_Population</fullName>
        <actions>
            <name>Core_SupportGranted_Not_EntryDt_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_SupportProvide_Not_EntryDt_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populated the Date/Time when Opp Prod Status(Core_At_Risk_Status__c) is either selected as &quot;Support Granted By HQ&quot; or &quot;Support Requested&quot;</description>
        <formula>AND(  ISCHANGED( Core_At_Risk_Status__c ) = True,  OR(    ISPICKVAL(Core_At_Risk_Status__c, &quot;Support Granted By HQ&quot;) ,   ISPICKVAL(Core_At_Risk_Status__c, &quot;Support Provided&quot;)  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_Update_Approved_User_Id</fullName>
        <actions>
            <name>Core_OppProd_Approved_User_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Status__c</field>
            <operation>contains</operation>
            <value>Win Approved</value>
        </criteriaItems>
        <description>Update Approver Id of opportunity product</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_OppProd_WriteInProductFlag</fullName>
        <actions>
            <name>Core_OppProd_WriteInProductFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>equals</operation>
            <value>Write In Product</value>
        </criteriaItems>
        <description>Update WriteInProduct checkbox to true if Product Name is &apos;Write In Product&apos; ( UStory: 14406 )</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_Update_BU Information</fullName>
        <actions>
            <name>Core_BU_Product_Segment_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Core_BU_Short_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>OpportunityLineItem.Core_BU_ShortName__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Core_BU_ProductSegment__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>contains</operation>
            <value>Write In Product</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>KPI CPU Update</fullName>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Core_Product_Type__c</field>
            <operation>equals</operation>
            <value>Processors</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
