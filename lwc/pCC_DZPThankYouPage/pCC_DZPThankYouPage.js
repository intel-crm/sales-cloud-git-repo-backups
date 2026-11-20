import { LightningElement } from 'lwc';
import HeaderHome from '@salesforce/label/c.IPA_Home_header';
import DZPThankYou from '@salesforce/label/c.PCC_DZPThankYouContent';
import DZPDisclaimerContent1 from '@salesforce/label/c.PCC_DZPDisclaimerContent_1';
import DZPDisclaimerPopUpMsg1 from '@salesforce/label/c.PRM_DZPPopUpMsg';

export default class PCC_DZPThankYouPage extends LightningElement {
    label = {
        HeaderHome,
        DZPThankYou
    }

    DZPDisclaimerContent = DZPDisclaimerPopUpMsg1 + ' ' +DZPDisclaimerContent1;
}