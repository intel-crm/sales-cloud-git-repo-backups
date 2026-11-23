<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Core_Opp_MAG_Questionnaire_Should_Be_Fil</fullName>
        <field>Core_Compliance_Sub_Status__c</field>
        <literalValue>MAG Questionnaire should be filled out</literalValue>
        <name>Core_Opp_MAG_Questionnaire_Should_Be_Fil</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Core_Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Opp_MAG_Ready_for_GEC_Review</fullName>
        <field>Core_Compliance_Sub_Status__c</field>
        <literalValue>AR - GEC to review MINDS Questionnaire</literalValue>
        <name>Core_Opp_MAG_Ready_for_GEC_Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Core_Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Core_Opp_MAG_Ready_for_GEC_Review_Clarif</fullName>
        <field>Core_Compliance_Sub_Status__c</field>
        <literalValue>GEC to Review Responses to GEC Clarifying Questions</literalValue>
        <name>Core_Opp_MAG_Ready_for_GEC_Review_Clarif</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Core_Opportunity__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Core_MAG_Ready_for_GEC_Review</fullName>
        <actions>
            <name>Core_Opp_MAG_Ready_for_GEC_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the opportunity compliance sub-status to &quot;GEC to review MAG questionnaire&quot; when all answers in the form have been filled out</description>
        <formula>NOT( ISPICKVAL(Core_Opportunity__r.Core_Compliance_Sub_Status__c, &apos;ITAR Form Received (GEC to review ITAR Form)&apos;) || ISPICKVAL(Core_Opportunity__r.Core_Compliance_Sub_Status__c, &apos;ITAR Form Sent (ITAR Form should be filled out)&apos;))  &amp;&amp; IF(Core_Number_of_Questions__c &gt;= 1, Core_A1__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 2, Core_A2__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 3, Core_A3__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 4, Core_A4__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 5, Core_A5__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 6, Core_A6__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 7, Core_A7__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 8, Core_A8__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 9, Core_A9__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 10, Core_A10__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 11, Core_A11__c != &apos;&apos;, true) &amp;&amp;  IF(Core_Number_of_Questions__c &gt;= 12, Core_A12__c != &apos;&apos;, true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Core_MAG_Ready_for_GEC_Review_Clarifications</fullName>
        <actions>
            <name>Core_Opp_MAG_Ready_for_GEC_Review_Clarif</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the opportunity compliance sub-status to &quot;GEC to review responses to GEC clarifying questions&quot; when clarifying questions have been answered by the user</description>
        <formula>ISPICKVAL(Core_Opportunity__r.Core_Compliance_Sub_Status__c, &apos;AR - Owner to Respond to GEC Clarifying Questions&apos;) &amp;&amp; (ISCHANGED(Core_GEC_Comments_Response__c) || ISCHANGED(Core_A1__c) || ISCHANGED(Core_A2__c) || ISCHANGED(Core_A3__c) || ISCHANGED(Core_A4__c) || ISCHANGED(Core_A5__c) || ISCHANGED(Core_A6__c) || ISCHANGED(Core_A7__c) || ISCHANGED(Core_A8__c) || ISCHANGED(Core_A9__c) || ISCHANGED(Core_A10__c) || ISCHANGED(Core_A11__c) || ISCHANGED(Core_A12__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
