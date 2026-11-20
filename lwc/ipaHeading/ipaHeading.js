/** Documentation for the IPA Heading
 * <br>
 * This component is exposed in the Community Builder.
 * @namespace ipaHeading
 * @property {string} heading heading
 * @property {string} subheading subheading
 * @author Nick Demarest, last modified 20 July 2020
*/

import { LightningElement, api } from 'lwc';

export default class IpaHeading extends LightningElement {
    @api heading;
    @api subheading;
}