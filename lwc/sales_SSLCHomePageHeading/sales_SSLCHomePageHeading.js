import { LightningElement } from 'lwc';
import sslcWelcomeMsg from '@salesforce/label/c.Sales_WelcomeSSLC_HTML';
import sslcAssitantMsg from '@salesforce/label/c.Sales_AssisstantSSLC_HTML';    
export default class sales_SSLCHomePageHeading extends LightningElement {
    
    label={
        sslcAssitantMsg,
        sslcWelcomeMsg

    };
}