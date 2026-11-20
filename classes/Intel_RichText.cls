/*************************************************************************************************************************************************************************
* Class Name  : Intel_RichText 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
// RICH TEXT - https://developer.salesforce.com/docs/component-library/bundle/lightning:inputRichText
    public class Intel_RichText extends Intel_Input {
        public static Boolean isWorking() {
        return true;
    }
      //  { type = 'richtext'; }
      // public String label { get; set; }
      // // RICH TEXT EDITOR "FORMATS" (optional): Complete List -- (font, size, bold, italic, underline, strike, list, indent, align, clean, table, header)
      // public String formats { get; set; } { formats = 'font,size,bold,italic,underline,strike,list,indent,align,clean,table,header'; } // default list
    }