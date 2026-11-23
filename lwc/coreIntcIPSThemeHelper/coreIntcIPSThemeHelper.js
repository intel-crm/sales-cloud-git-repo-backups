import { LightningElement } from 'lwc';
// Need to import the setCssVariables method
import { setCssVariables } from 'c/coreIntcThemeHelper';

export default class CoreIntcIPSThemeHelper extends LightningElement {

  connectedCallback() {
    setCssVariables({
      coreIntcFullXsWidth: '100%',
      coreIntcFullSmallWidth: '100%',
      coreIntcFullMediumWidth: '100%',
      coreIntcFullLargeWidth: '100%',
    });
  }

}