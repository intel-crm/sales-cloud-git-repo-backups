<aura:application controller="ReusableCustomDropdownAppController" extends="force:slds">

    <aura:attribute name="fromSelectedValue" type="Map" access="public" default="{'Id':'','Name':''}" />
     <aura:attribute name="disableTransferAmount" type="boolean" default="false" access="public"/>
    
    <aura:attribute name="partnersDataTo" type="Object[]" access="public" />
    <lightning:card title="Searchable Dropdown List" iconName="custom:custom30">
    <lightning:input required="true" aura:id="partner_" name="fromAccount" value="{! v.fromSelectedValue.Id}" disabled="{!v.disableTransferAmount}" />
    <!-- recordList = "" This field is optional, if not sent child component will prepare the data as per the criteria from the parent-->
        <c:core_MDF_AccountTransferDropdownList aura:id="fromAccountlwcComponent" 
                                            sObjectAPIName ="Account" 
                                            qureyFields="Name"
                                            filterCriteria="RecordTypeId = '0121J000000yaFXQAY'" 
                                            fieldLabel="From Account"  onselect="{!c.fromAccountToChange}" />
    </lightning:card>
    <c:reusableCustomDropdownWithSearchLwc aura:id="toAccountlwcComponent" fieldDisabled = "{!v.disableTransferAmount}"/>
    
    <lightning:button label="Demo" 
                              class="slds-m-top--medium"
                              variant="brand"
                      disabled="{!v.disableTransferAmount}"/>
                      
    <lightning:button label="Enabled" 
                              class="slds-m-top--medium"
                              variant="brand"
                              onclick="{!c.methodEnabled}"/> 
    
    <lightning:button label="Disabled" 
                              class="slds-m-top--medium"
                              variant="brand"
                              onclick="{!c.methodDisabled}"/> 
    
    
</aura:application>