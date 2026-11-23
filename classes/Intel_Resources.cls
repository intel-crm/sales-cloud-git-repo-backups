/*************************************************************************************************************************************************************************
* Class Name  : Intel_Resources 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality for Resource tab. Used in MarketplaceCreateProductController.Apex 
*
* Developer             Modification Log                Date                                    Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj                                       05-13-2019                              Created for displaying additional resources section on Tab 4
**************************************************************************************************************************************************************************/
// RESOURCES
    public class Intel_Resources extends Intel_Input {
      { type = 'resources'; }
      { apiName = 'resources'; }
      public String titleField { get; set; } { titleField = 'Name'; }
      public String urlField { get; set; } { urlField = 'PMP_Partner_Offering_Resource_URL_Txt__c'; }
      public String typeField { get; set; } { typeField = 'PMP_Resource_Type_Nm__c'; }
      public List<Intel_DropdownOption> typeOptions { get; set; } { typeOptions = new List<Intel_DropdownOption>(); }
    }