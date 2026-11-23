<aura:application extends="force:slds">
    <!-- 
  	<c:core_MDF_ActivitySegmentMapping program="Retail Marketing Funds" activityType="Seller - Per Unit SPIF"></c:core_MDF_ActivitySegmentMapping>
	
    <c:core_MDF_ActivitySegments activityProgram="Retail Marketing Funds" activityType="Seller - Per Unit SPIF" ></c:core_MDF_ActivitySegments>
	-->	
    <c:Core_MDF_LightningSObjectLookUp aura:id="activityIdRetail" label="{!$Label.c.Core_MDF_Request}"
                                                                               pluralLabel="{!$Label.c.Core_MDF_Request}" sObjectAPIName="PartnerFundRequest"
                                                                               instanceId="activityId" helpText="{!$Label.c.Core_MDF_Activity_Activity_Name_Help}"
                                                                               listIconSVGPath="/resource/Core_MDF_SLDS262/icons/standard-sprite/svg/symbols.svg#client"
                                                                               listIconClass="slds-icon-standard-user" searchString="{!v.activitySearchString}"
                                                                               returnFields="Title,Core_MDF_Activity_Number__c" required="true"
	                                                                           filterCriteria="{!'(Title LIKE @quote;%' + v.activitySearchString + '%@quote; OR Core_MDF_Activity_Number__c LIKE @quote;%' + v.activitySearchString + '%@quote;) AND ChannelPartner.Core_MDF_Active_Ind__c=true AND ' + v.activitySearchCriteria + ' AND RecordType.DeveloperName = @quote;' + v.activityRecordTypeDevName + '@quote; '}" />
    <c:Core_MDF_LightningSObjectLookUp aura:id="activityIdRetail" label="Account"
                                                                               pluralLabel="Accounts" sObjectAPIName="Account"
                                                                               instanceId="activityId" helpText="Account"
                                                                               listIconSVGPath="/resource/Core_MDF_SLDS262/icons/standard-sprite/svg/symbols.svg#client"
                                                                               listIconClass="slds-icon-standard-user" searchString="{!v.activitySearchString}"
                                                                               returnFields="Name" required="true"
	                                                                           filterCriteria="" />
    
</aura:application>