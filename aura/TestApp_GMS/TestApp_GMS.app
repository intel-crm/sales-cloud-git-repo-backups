<aura:application extends="force:slds" >
    <!-- <c:GMS_TestComp1 /> - ->
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    <aura:attribute name="showTable" type="boolean" default="false" />
    <aura:attribute name="showTableHeader" type="boolean" default="true" />
    <aura:attribute name="showCheckbox" type="boolean" default="true" />
    <aura:attribute name="showRowNumber" type="boolean" default="false" />
    
    <aura:attribute name="columns" type="List" default="[]" />
    <aura:attribute name="data" type="List" default="[]" />
    <aura:if isTrue="{!v.showTable}">
    	<!- - <c:core_MDF_customTreeGrid columns="{!v.columns}" treeData="{!v.data}" showTableHeader="{!v.showTableHeader}" showCheckbox="{!v.showCheckbox}" onrecordselection="{!c.getSelectedRecords}"></c:core_MDF_customTreeGrid>- ->
    </aura:if> <c:ParentCmp></c:ParentCmp>
    <c:gMSTestApp2 /> -->
    <!-- <c:Core_MDF_CampaignEdit recordId="701g0000001DFvXAAW"></c:Core_MDF_CampaignEdit>-->
    <!-- <c:Core_MDF_Campaign_QuickActions recordId="701g0000001a07iAAA"></c:Core_MDF_Campaign_QuickActions> -->
    <c:GMS_TestComp1></c:GMS_TestComp1>
    
</aura:application>