/*************************************************************************************************************************************************************************
* Class Name  : Intel_Checkbox 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
// CHECKBOX - https://developer.salesforce.com/docs/component-library/bundle/lightning:checkboxGroup
    public class Intel_Checkbox extends Intel_Input {
      { type = 'checkbox'; }
      public String label { get; set; }
      // see custom checkbox lightning component documentation for more on these options
      public String interactionType { get; set; } { interactionType = 'default'; } // can be 'default', 'recursive', or 'parent'
      public String accordionType { get; set; } { accordionType = 'default'; } // can be 'default', 'accordion', 'search'
      public String valueType { get; set; } { valueType = 'default'; } // can be 'default', 'complex', 'picklist'
      public List<Intel_CheckboxOption> options { get; set; } { options = new List<Intel_CheckboxOption>(); }
      public Intel_Checkbox(){}
        
    }