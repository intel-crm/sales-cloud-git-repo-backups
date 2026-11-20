import { LightningElement } from 'lwc';
import downtimeMessage from "@salesforce/label/c.PMP_Downtime_Message";

export default class MarketplaceDowntimeMessage extends LightningElement {
  label = {
    downtimeMessage
  };
}