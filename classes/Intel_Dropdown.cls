/*************************************************************************************************************************************************************************
* Class Name  : PMP_Dropdown 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
// DROPDOWN - https://developer.salesforce.com/docs/component-library/bundle/lightning:select
    public class Intel_Dropdown extends Intel_Input {
      { type = 'dropdown'; }
      public String label {get; set;}
      public String placeholder { get; set; }
      public Boolean hidePlaceholder { get; set; }
      public Boolean allowMultipleOptions { get; set; }
      public List<Intel_DropdownOption> options { get; set; }
      public Intel_Dropdown() { options = new List<Intel_DropdownOption>(); }
      
      public Intel_Dropdown(String field, String objName) {
        options = new List<Intel_DropdownOption>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
          options.add(new Intel_DropdownOption(pickListVal.getLabel(), pickListVal.getValue()));
        }
      }
     
     public Intel_Dropdown(Map<id,String> nameById) {
            options = new List<Intel_DropdownOption>();
            for (Id recordId :  nameById.keySet()){
              options.add(new Intel_DropdownOption(nameById.get(recordId), recordId));
            }            
      }
      public Intel_Dropdown(Map<string,String> nameByName) {
            options = new List<Intel_DropdownOption>();
            for (string pimId:  nameByName.keySet()){
              options.add(new Intel_DropdownOption(nameByName.get(pimId), pimId));
            }            
      }
        
    }