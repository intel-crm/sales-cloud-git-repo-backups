import { LightningElement, api } from "lwc";

// Import the URL for the static resource named 'intelPlaceholderGraphic'
// import GRAPHIC from '@salesforce/resourceUrl/ISGSimpleContentGraphic';

// Import custom labels
// import HEADING from '@salesforce/label/c.ISGSimpleContentHeading'
// import TAGLINE from '@salesforce/label/c.ISGSimpleContentTagline';

export default class PsMpSimpleContentCard extends LightningElement {
  @api heading;
  @api imageUrl;
  @api tagline;
  @api buttonAccessibilityLabel;
  @api buttonLabel;
  @api buttonEventParams;
 
 


  handleClick() {
    const buttonClick = new CustomEvent("clickbutton", {
      detail: {
        params: this.buttonEventParams
      }
    });
    this.dispatchEvent(buttonClick);
 
    }
  



  get ifs() {
    return {
      showButton: this.buttonLabel && this.buttonLabel !== "",
      showImage: this.imageUrl && this.imageUrl !== "",
      showHeading: this.heading && this.heading !== ""
    };
  }
}