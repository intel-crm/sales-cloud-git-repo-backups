<aura:application controller="Core_MDF_SearchableDropdownList" extends="force:slds">
	
    <aura:attribute name="fromSelectedValue" type="Map" access="public" default="{'Id':'','Name':''}" />
    
    <aura:attribute name="partnersDataTo" type="Object[]" access="public" />
    <lightning:card title="Custom Searchable Dropdown List" iconName="custom:custom63">
    <lightning:input required="true" aura:id="partner_" name="fromAccount" value="{! v.fromSelectedValue.Id}" readonly="true" disabled="true" />
    <!-- recordList = "" This field is optional, if not sent child component will prepare the data as per the criteria from the parent-->
        <c:core_MDF_Custom_Searchable_DropdownList aura:id="fromAccountlwcComponent" 
                                            sObjectAPIName ="Account" 
                                            qureyFields="Name"
                                            filterCriteria="RecordTypeId = '0121J000000yaFXQAY'" 
                                            fieldLabel="From Account"  onselect="{!c.fromAccountToChange}" />
    </lightning:card>
    
</aura:application>